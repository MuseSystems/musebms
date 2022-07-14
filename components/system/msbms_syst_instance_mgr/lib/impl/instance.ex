# Source File: instance.ex
# Location:    components/system/msbms_syst_instance_mgr/lib/impl/instance.ex
# Project:     msbms
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https: //muse.systems

defmodule MsbmsSystInstanceMgr.Impl.Instance do
  import Ecto.Query
  import MsbmsSystUtils

  alias MsbmsSystInstanceMgr.Data

  require Logger

  # The below is used as a salting value for Instance Context password
  # generation.  The overall approach, including this value, is almost certainly
  # a bad idea and terribly naive.  Put "magic" in the name to make apparent
  # that something isn't right here.
  @password_magic <<56, 14, 219, 174, 116, 26, 213, 144, 140, 191, 255, 187, 27, 58, 226, 253>>

  def create_instance(instance_params) do
    instance_params
    |> Data.SystInstances.insert_changeset()
    |> MsbmsSystDatastore.insert!(returning: true)
    |> then(&{:ok, &1})
  end

  def get_instance_datastore_options(instance_id, startup_options) when is_binary(instance_id) do
    from(i in Data.SystInstances,
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
    |> MsbmsSystDatastore.one!()
    |> get_instance_datastore_options(startup_options)
  end

  def get_instance_datastore_options(
        %Data.SystInstances{application: %Data.SystApplications{}, instance_contexts: [_ | _]} =
          instance,
        startup_options
      ) do
    instance_dbserver =
      MsbmsSystOptions.get_dbserver_by_name(startup_options, instance.dbserver_name)

    global_pepper = MsbmsSystOptions.get_global_pepper_value(startup_options)

    contexts =
      Enum.map(
        instance.instance_contexts,
        &get_instance_context_datastore_options(&1, instance, instance_dbserver, startup_options)
      )

    %{
      database_name: instance.internal_name,
      datastore_code: global_pepper,
      datastore_name: String.to_atom(instance.internal_name),
      contexts: contexts,
      db_server: instance_dbserver
    }
  end

  def get_instance_datastore_options(%Data.SystInstances{id: instance_id}, startup_options) do
    get_instance_datastore_options(instance_id, startup_options)
  end

  defp get_instance_context_datastore_options(
         instance_context,
         instance_data,
         instance_dbserver,
         startup_options
       ) do
    %{
      context_name: String.to_atom(instance_context.internal_name),
      description:
        instance_data.display_name <>
          " / " <> instance_context.application_context.display_name,
      database_role: instance_context.internal_name,
      database_password:
        get_instance_context_password([
          instance_context.context_code,
          @password_magic,
          instance_dbserver.server_salt,
          MsbmsSystOptions.get_global_pepper_value(startup_options),
          instance_data.instance_code
        ]),
      starting_pool_size: instance_context.db_pool_size,
      start_context:
        instance_context.application_context.start_context and instance_context.start_context,
      login_context: instance_context.application_context.login_context,
      database_owner_context: instance_context.application_context.database_owner_context
    }
  end

  defp get_instance_context_password(password_list) do
    Enum.reduce(password_list, "", &(&2 <> &1))
    |> then(&:crypto.hash(:blake2b, &1))
    |> Base.encode64(padding: false)
  end

  def initialize_instance(instance_id, startup_options, opts) do
    opts = resolve_options(opts, get_default_instance_state_ids())

    {:ok, initializing_instance} =
      from(i in Data.SystInstances, where: i.id == ^instance_id)
      |> MsbmsSystDatastore.one!()
      |> verify_initialization_eligibility()
      |> set_instance_state(opts[:initializing_state_id])

    datastore_options = get_instance_datastore_options(initializing_instance.id, startup_options)

    datastore_options
    |> MsbmsSystDatastore.create_datastore(opts)
    |> process_create_datastore_result(initializing_instance, datastore_options, opts)
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MsbmsSystError{
          code: :undefined_error,
          message: "Failure initializing Instance.",
          cause: error
        }
      }
  end

  defp verify_initialization_eligibility(
         %Data.SystInstances{instance_state_id: instance_state_id} = instance
       ) do
    functional_type_name =
      MsbmsSystEnums.get_functional_type_by_enum_item_id("instance_states", instance_state_id)

    verify_initialization_eligibility(functional_type_name, instance)
  end

  defp verify_initialization_eligibility("instance_states_uninitialized", instance), do: instance

  defp verify_initialization_eligibility(state_functional_type, instance)
       when is_binary(state_functional_type) do
    raise MsbmsSystError,
      code: :invalid_parameter,
      message: "The requested Instance is not in a valid state for initialization.",
      cause: %{instance_state_functional_type_name: state_functional_type, instance: instance}
  end

  defp verify_initialization_eligibility(_instance_state, instance) do
    raise MsbmsSystError,
      code: :unknown_error,
      message: "Unknown error found during Instance initialization eligibility check.",
      cause: %{instance: instance}
  end

  def set_instance_state(instance, instance_state_id) do
    instance
    |> Data.SystInstances.update_changeset(%{instance_state_id: instance_state_id})
    |> MsbmsSystDatastore.update!(returning: true)
    |> then(&{:ok, &1})
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MsbmsSystError{
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
    :ok = MsbmsSystDatastore.drop_datastore(datastore_options)

    {:ok, _} = set_instance_state(instance, opts[:failed_state_id])

    {:error,
     %MsbmsSystError{
       code: :undefined_error,
       message: "Instance initialization error found.",
       cause: error
     }}
  end

  def get_default_instance_state_ids() do
    initializing_state_id =
      MsbmsSystEnums.get_default_enum_item("instance_states",
        functional_type_name: "instance_states_initializing"
      ).id

    active_state_id =
      MsbmsSystEnums.get_default_enum_item("instance_states",
        functional_type_name: "instance_states_active"
      ).id

    failed_state_id =
      MsbmsSystEnums.get_default_enum_item("instance_states",
        functional_type_name: "instance_states_failed"
      ).id

    initialized_state_id =
      MsbmsSystEnums.get_default_enum_item("instance_states",
        functional_type_name: "instance_states_initialized"
      ).id

    migrating_state_id =
      MsbmsSystEnums.get_default_enum_item("instance_states",
        functional_type_name: "instance_states_migrating"
      ).id

    [
      initializing_state_id: initializing_state_id,
      active_state_id: active_state_id,
      failed_state_id: failed_state_id,
      initializing_state_id: initializing_state_id,
      initialized_state_id: initialized_state_id,
      migrating_state_id: migrating_state_id
    ]
  end

  def get_standard_migration_bindings(instance_id) do
    from(
      i in Data.SystInstances,
      join: ic in assoc(i, :instance_contexts),
      join: ac in assoc(ic, :application_context),
      where: i.id == ^instance_id,
      select: {ac.internal_name, ic.internal_name}
    )
    |> MsbmsSystDatastore.all()
    |> Enum.map(&{String.to_atom(elem(&1, 0)), elem(&1, 1)})
  end

  def purge_instance(instance_id, startup_options) when is_binary(instance_id) do
    from(
      i in Data.SystInstances,
      join: is in assoc(i, :instance_state),
      join: isft in assoc(is, :functional_type),
      where: i.id == ^instance_id,
      preload: [instance_state: {is, functional_type: isft}]
    )
    |> MsbmsSystDatastore.one!()
    |> purge_instance(startup_options)
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MsbmsSystError{
          code: :undefined_error,
          message: "Failure deleting Instance by ID.",
          cause: error
        }
      }
  end

  def purge_instance(
        %Data.SystInstances{
          instance_state: %MsbmsSystEnums.Data.SystEnumItems{
            functional_type: %MsbmsSystEnums.Data.SystEnumFunctionalTypes{
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
        %MsbmsSystError{
          code: :undefined_error,
          message: "Failure deleting Instance.",
          cause: error
        }
      }
  end

  def purge_instance(%Data.SystInstances{id: instance_id}, startup_options) do
    purge_instance(instance_id, startup_options)
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MsbmsSystError{
          code: :undefined_error,
          message: "Failure deleting Instance by struct.",
          cause: error
        }
      }
  end

  defp maybe_perform_instance_purge("instance_states_purge_eligible", instance, startup_options) do
    datastore_options = get_instance_datastore_options(instance, startup_options)
    :ok = MsbmsSystDatastore.drop_datastore(datastore_options)
    _ = MsbmsSystDatastore.delete!(instance)
    :ok
  end

  defp maybe_perform_instance_purge(functional_type, _instance, _startup_options),
    do:
      raise(MsbmsSystError,
        code: :invalid_parameter,
        message: "Invalid Instance State Functional Type for Purge.",
        cause: %{parameters: [functional_type: functional_type]}
      )
end
