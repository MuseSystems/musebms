# Source File: instance.ex
# Location:    musebms/components/system/mscmp_syst_instance/lib/impl/instance.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystInstance.Impl.Instance do
  @moduledoc false

  import Ecto.Query

  alias MscmpSystInstance.Impl
  alias MscmpSystInstance.Types

  require Logger

  # The below is used as a salting value for Instance Context password
  # generation.  The overall approach, including this value, is almost certainly
  # a bad idea and terribly naive.  Put "magic" in the name to make apparent
  # that something isn't right here.
  @password_magic <<56, 14, 219, 174, 116, 26, 213, 144, 140, 191, 255, 187, 27, 58, 226, 253>>

  ##############################################################################
  #
  # create_instance
  #
  #

  @spec create_instance(Types.instance_params()) ::
          {:ok, Msdata.SystInstances.t()} | {:error, MscmpSystError.t()}
  def create_instance(instance_params) do
    instance_params
    |> Msdata.SystInstances.insert_changeset()
    |> MscmpSystDb.insert!(returning: true)
    |> then(&{:ok, &1})
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {:error,
       %MscmpSystError{
         code: :undefined_error,
         message: "Failure creating new Instance.",
         cause: error
       }}
  end

  ##############################################################################
  #
  # get_instance_datastore_options
  #
  #

  # Retrieves the Datastore Options based on the Instance database record and
  # the provided Startup Options.

  @spec get_instance_datastore_options(
          Types.instance_id() | Msdata.SystInstances.t(),
          startup_options :: map()
        ) ::
          MscmpSystDb.Types.DatastoreOptions.t()
  def get_instance_datastore_options(instance_id, startup_options) when is_binary(instance_id) do
    from(i in Msdata.SystInstances,
      as: :instances,
      join: a in assoc(i, :application),
      as: :applications,
      join: ic in assoc(i, :instance_contexts),
      as: :instance_contexts,
      join: ac in assoc(ic, :application_context),
      as: :application_contexts,
      where: i.id == ^instance_id,
      preload: [application: a, instance_contexts: {ic, application_context: ac}]
    )
    |> MscmpSystDb.one!()
    |> get_instance_datastore_options(startup_options)
  end

  def get_instance_datastore_options(
        %Msdata.SystInstances{application: %Msdata.SystApplications{}, instance_contexts: [_ | _]} =
          instance,
        startup_options
      ) do
    instance_dbserver =
      MscmpSystOptions.get_dbserver_by_name(startup_options, instance.dbserver_name)

    global_pepper = MscmpSystOptions.get_global_pepper_value(startup_options)

    contexts =
      Enum.map(
        instance.instance_contexts,
        &get_instance_context_datastore_options(&1, instance, instance_dbserver, startup_options)
      )

    %MscmpSystDb.Types.DatastoreOptions{
      database_name: instance.internal_name,
      datastore_code: global_pepper,
      datastore_name: String.to_atom(instance.internal_name),
      contexts: contexts,
      db_server: instance_dbserver
    }
  end

  def get_instance_datastore_options(%Msdata.SystInstances{id: instance_id}, startup_options) do
    get_instance_datastore_options(instance_id, startup_options)
  end

  defp get_instance_context_datastore_options(
         instance_context,
         instance_data,
         instance_dbserver,
         startup_options
       ) do
    %MscmpSystDb.Types.DatastoreContext{
      context_name: String.to_atom(instance_context.internal_name),
      description:
        instance_data.display_name <>
          " / " <> instance_context.application_context.display_name,
      database_role: instance_context.internal_name,
      database_password:
        get_context_password([
          instance_context.context_code,
          @password_magic,
          instance_dbserver.server_salt,
          MscmpSystOptions.get_global_pepper_value(startup_options),
          instance_data.instance_code
        ]),
      starting_pool_size: instance_context.db_pool_size,
      start_context:
        instance_context.application_context.start_context and instance_context.start_context,
      login_context: instance_context.application_context.login_context,
      database_owner_context: instance_context.application_context.database_owner_context
    }
  end

  defp get_context_password(password_list) do
    Enum.reduce(password_list, "", &(&2 <> &1))
    |> then(&:crypto.hash(:blake2b, &1))
    |> Base.encode64(padding: false)
  end

  ##############################################################################
  #
  # initialize_instance
  #
  #

  @spec initialize_instance(Types.instance_id(), startup_options :: map(), opts :: Keyword.t()) ::
          {:ok, Msdata.SystInstances.t()} | {:error, MscmpSystError.t()}
  def initialize_instance(instance_id, startup_options, opts) do
    opts = Keyword.merge(opts, get_default_instance_state_ids())

    {:ok, initializing_instance} =
      from(i in Msdata.SystInstances, where: i.id == ^instance_id)
      |> MscmpSystDb.one!()
      |> verify_initialization_eligibility()
      |> set_instance_state(opts[:initializing_state_id])

    datastore_options = get_instance_datastore_options(initializing_instance.id, startup_options)

    create_datastore_opts = Keyword.take(opts, [:db_shutdown_timeout])

    datastore_options
    |> MscmpSystDb.create_datastore(create_datastore_opts)
    |> process_create_datastore_result(initializing_instance, datastore_options, opts)
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MscmpSystError{
          code: :undefined_error,
          message: "Failure initializing Instance.",
          cause: error
        }
      }
  end

  defp verify_initialization_eligibility(
         %Msdata.SystInstances{instance_state_id: instance_state_id} = instance
       ) do
    functional_type_name =
      MscmpSystEnums.get_functional_type_by_item_id("instance_states", instance_state_id)

    verify_initialization_eligibility(functional_type_name, instance)
  end

  defp verify_initialization_eligibility("instance_states_uninitialized", instance), do: instance

  defp verify_initialization_eligibility(state_functional_type, instance)
       when is_binary(state_functional_type) do
    raise MscmpSystError,
      code: :invalid_parameter,
      message: "The requested Instance is not in a valid state for initialization.",
      cause: %{instance_state_functional_type_name: state_functional_type, instance: instance}
  end

  ##############################################################################
  #
  # set_instance_state
  #
  #

  # TODO: This is one of a number of places where we might want to consider a
  #       more formal state machine definition since there are allowed and
  #       disallowed state transitions.  Battle for a different day.

  @spec set_instance_state(Msdata.SystInstances.t(), Types.instance_state_id()) ::
          {:ok, Msdata.SystInstances.t()} | {:error, MscmpSystError.t()}
  def set_instance_state(instance, instance_state_id) do
    instance
    |> Msdata.SystInstances.update_changeset(%{instance_state_id: instance_state_id})
    |> MscmpSystDb.update!(returning: true)
    |> then(&{:ok, &1})
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MscmpSystError{
          code: :undefined_error,
          message: "Failure setting Instance State.",
          cause: error
        }
      }
  end

  defp process_create_datastore_result({:ok, :ready, _context_states}, instance, _, opts) do
    set_instance_state(instance, opts[:initialized_state_id])
  end

  defp process_create_datastore_result(error, instance, datastore_options, opts) do
    :ok = MscmpSystDb.drop_datastore(datastore_options)

    {:ok, _} = set_instance_state(instance, opts[:failed_state_id])

    {:error,
     %MscmpSystError{
       code: :undefined_error,
       message: "Instance initialization error found.",
       cause: error
     }}
  end

  ##############################################################################
  #
  # get_default_instance_state_ids
  #
  #

  @spec get_default_instance_state_ids() :: Keyword.t()
  def get_default_instance_state_ids do
    initializing_state =
      Impl.InstanceState.get_instance_state_default(:instance_states_initializing)

    active_state = Impl.InstanceState.get_instance_state_default(:instance_states_active)

    failed_state = Impl.InstanceState.get_instance_state_default(:instance_states_failed)

    initialized_state =
      Impl.InstanceState.get_instance_state_default(:instance_states_initialized)

    migrating_state = Impl.InstanceState.get_instance_state_default(:instance_states_migrating)

    [
      initializing_state_id: initializing_state.id,
      active_state_id: active_state.id,
      failed_state_id: failed_state.id,
      initialized_state_id: initialized_state.id,
      migrating_state_id: migrating_state.id
    ]
  end

  ##############################################################################
  #
  # get_standard_migration_bindings
  #
  #

  # Returns the standard bindings expected by Instance migrations which are
  # applied during Instance Datastore updates.
  #
  # Migration bindings are the Instance specific values that are to be
  # substituted into the SQL migration files.  The most typical example of such
  # a standard binding is the names of the Datastore Context database roles
  # which, in the migrations, must be given permission to access the database
  # objects in the Datastore.

  @spec get_standard_migration_bindings(Types.instance_id()) :: Keyword.t()
  def get_standard_migration_bindings(instance_id) do
    from(
      i in Msdata.SystInstances,
      join: ic in assoc(i, :instance_contexts),
      join: ac in assoc(ic, :application_context),
      where: i.id == ^instance_id,
      select: {ac.internal_name, ic.internal_name}
    )
    |> MscmpSystDb.all()
    |> Enum.map(&{String.to_atom(elem(&1, 0)), elem(&1, 1)})
  end

  ##############################################################################
  #
  # get_instance_by_name
  #
  #

  # Returns a populated SystInstances struct for the requested Instance internal
  # name.
  #
  # Populated in this case means that statusing information is populated.

  @spec get_instance_by_name(Types.instance_name()) ::
          {:ok, Msdata.SystInstances.t()} | {:error, MscmpSystError.t()}
  def get_instance_by_name(instance_name) when is_binary(instance_name) do
    from(
      i in Msdata.SystInstances,
      join: is in assoc(i, :instance_state),
      join: isft in assoc(is, :functional_type),
      where: i.internal_name == ^instance_name,
      preload: [instance_state: {is, functional_type: isft}]
    )
    |> MscmpSystDb.one!()
    |> then(&{:ok, &1})
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MscmpSystError{
          code: :undefined_error,
          message: "Failure retrieving Instance by internal name.",
          cause: error
        }
      }
  end

  ##############################################################################
  #
  # get_instance_id_by_name
  #
  #

  # Returns the ID of a SystInstances record as looked up by its internal name.

  @spec get_instance_id_by_name(Types.instance_name()) ::
          {:ok, Types.instance_id()} | {:error, MscmpSystError.t()}
  def get_instance_id_by_name(instance_name) do
    from(i in Msdata.SystInstances, select: i.id, where: i.internal_name == ^instance_name)
    |> MscmpSystDb.one!()
    |> then(&{:ok, &1})
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MscmpSystError{
          code: :undefined_error,
          message: "Failure retrieving Instance ID by internal name.",
          cause: error
        }
      }
  end

  ##############################################################################
  #
  # purge_instance
  #
  #

  @spec purge_instance(Types.instance_id() | Msdata.SystInstances.t(), startup_options :: map()) ::
          :ok | {:error, MscmpSystError.t()}
  def purge_instance(instance_id, startup_options) when is_binary(instance_id) do
    from(
      i in Msdata.SystInstances,
      join: is in assoc(i, :instance_state),
      join: isft in assoc(is, :functional_type),
      where: i.id == ^instance_id,
      preload: [instance_state: {is, functional_type: isft}]
    )
    |> MscmpSystDb.one!()
    |> purge_instance(startup_options)
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MscmpSystError{
          code: :undefined_error,
          message: "Failure deleting Instance by ID.",
          cause: error
        }
      }
  end

  def purge_instance(
        %Msdata.SystInstances{
          instance_state: %Msdata.SystEnumItems{
            functional_type: %Msdata.SystEnumFunctionalTypes{
              internal_name: functional_type
            }
          }
        } = instance,
        startup_options
      ) do
    maybe_perform_instance_purge(functional_type, instance, startup_options)
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MscmpSystError{
          code: :undefined_error,
          message: "Failure purging Instance.",
          cause: error
        }
      }
  end

  def purge_instance(%Msdata.SystInstances{id: instance_id}, startup_options),
    do: purge_instance(instance_id, startup_options)

  defp maybe_perform_instance_purge("instance_states_purge_eligible", instance, startup_options) do
    datastore_options = get_instance_datastore_options(instance, startup_options)
    :ok = MscmpSystDb.drop_datastore(datastore_options)
    _ = MscmpSystDb.delete!(instance)
    :ok
  end

  defp maybe_perform_instance_purge(functional_type, _instance, _startup_options),
    do:
      raise(MscmpSystError,
        code: :invalid_parameter,
        message: "Invalid Instance State Functional Type for purge.",
        cause: %{parameters: [functional_type: functional_type]}
      )
end
