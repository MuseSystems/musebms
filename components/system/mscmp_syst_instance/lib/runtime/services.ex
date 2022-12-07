# Source File: services.ex
# Location:    musebms/components/system/mscmp_syst_instance/lib/runtime/services.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystInstance.Runtime.Services do
  import Ecto.Query

  alias MscmpSystInstance.Impl
  alias MscmpSystInstance.Types

  require Logger

  @default_supervisor_name MscmpSystInstance.Supervisor
  @default_registry_name MscmpSystInstance.Registry
  @default_instance_supervisor_name MscmpSystInstance.InstanceSupervisor
  @default_task_supervisor_name MscmpSystInstance.TaskSupervisor

  @moduledoc false

  @spec start_link(Keyword.t()) :: Supervisor.on_start_child()
  def start_link(opts) do
    opts =
      MscmpSystUtils.resolve_options(opts,
        supervisor_name: @default_supervisor_name,
        registry_name: @default_registry_name,
        instance_supervisor_name: @default_instance_supervisor_name,
        task_supervisor_name: @default_task_supervisor_name
      )

    inst_mgr_spec = [
      {DynamicSupervisor, strategy: :one_for_one, name: opts[:instance_supervisor_name]},
      {Task.Supervisor, name: opts[:task_supervisor_name]},
      {Registry, keys: :unique, name: opts[:registry_name]}
    ]

    Supervisor.start_link(inst_mgr_spec, strategy: :one_for_one, name: opts[:supervisor_name])
  end

  @spec start_application(
          Types.application_id() | Msdata.SystApplications.t(),
          startup_options :: map(),
          Keyword.t()
        ) ::
          :ok | {:error, MscmpSystError.t()}
  def start_application(application_id, startup_options, opts) when is_binary(application_id) do
    from(a in Msdata.SystApplications,
      where: a.id == ^application_id,
      select: [:id, :internal_name]
    )
    |> MscmpSystDb.one!()
    |> start_application(startup_options, opts)
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MscmpSystError{
          code: :undefined_error,
          message: "Failure starting Application by ID.",
          cause: error
        }
      }
  end

  def start_application(
        %Msdata.SystApplications{id: application_id} = application,
        startup_options,
        opts
      ) do
    opts =
      MscmpSystUtils.resolve_options(opts,
        max_concurrency: default_max_concurrency(),
        task_supervisor_name: @default_task_supervisor_name,
        instance_supervisor_name: @default_instance_supervisor_name,
        registry_name: @default_registry_name
      )

    supervisor_name = get_application_supervisor_name(application, opts)

    {:ok, _} = start_application_supervisor(supervisor_name, opts)

    current_datastore_context = MscmpSystDb.current_datastore_context()
    current_enums_service = MscmpSystEnums.get_enums_service()

    from(
      i in Msdata.SystInstances,
      join: a in assoc(i, :application),
      where: a.id == ^application_id,
      preload: [application: a, instance_contexts: [:application_context]]
    )
    |> MscmpSystDb.all()
    |> then(
      &Task.Supervisor.async_stream_nolink(
        opts[:task_supervisor_name],
        &1,
        fn instance ->
          _ = MscmpSystDb.put_datastore_context(current_datastore_context)
          _ = MscmpSystEnums.put_enums_service(current_enums_service)
          start_instance(instance, startup_options, opts)
        end,
        opts
      )
    )
    |> Enum.to_list()
    |> Enum.reduce(:ok, fn result, acc ->
      case result do
        {:ok, :ok} ->
          acc

        {:error, _} = error ->
          {:error,
           %MscmpSystError{
             code: :undefined_error,
             message: "Failure starting Instance.",
             cause: error
           }}
      end
    end)
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MscmpSystError{
          code: :undefined_error,
          message: "Failure starting Application.",
          cause: error
        }
      }
  end

  defp start_application_supervisor(application_supervisor_name, opts) do
    application_spec =
      {DynamicSupervisor, strategy: :one_for_one, name: application_supervisor_name}

    {:ok, _} = DynamicSupervisor.start_child(opts[:instance_supervisor_name], application_spec)
  end

  defp default_max_concurrency do
    if System.schedulers_online() < 4 do
      1
    else
      (System.schedulers_online() / 4) |> floor()
    end
  end

  # Starts all Applications.

  @spec start_all_applications(startup_options :: map(), Keyword.t()) ::
          :ok | {:error, MscmpSystError.t()}
  def start_all_applications(startup_options, opts) do
    from(a in Msdata.SystApplications, select: [:id, :internal_name])
    |> MscmpSystDb.all()
    |> Enum.each(&start_application(&1, startup_options, opts))
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MscmpSystError{
          code: :undefined_error,
          message: "Failure starting Applications.",
          cause: error
        }
      }
  end

  @spec start_instance(
          Types.instance_id() | Msdata.SystInstances.t(),
          startup_options :: map(),
          Keyword.t()
        ) :: :ok | {:error, MscmpSystError.t()}
  def start_instance(instance_id, startup_options, opts) when is_binary(instance_id) do
    from(
      i in Msdata.SystInstances,
      join: a in assoc(i, :application),
      where: i.id == ^instance_id,
      preload: [application: a, instance_contexts: [:application_context]]
    )
    |> MscmpSystDb.one!()
    |> start_instance(startup_options, opts)
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MscmpSystError{
          code: :undefined_error,
          message: "Failure starting Instance by ID.",
          cause: error
        }
      }
  end

  # TODO: This is too "happy path" centric.  There are failure modes that can be
  #       handled resiliently and probably should be.  Defer for now.
  def start_instance(
        %Msdata.SystInstances{application: %Msdata.SystApplications{}, instance_contexts: [_ | _]} =
          instance,
        startup_options,
        opts
      ) do
    resolved_migration_bindings =
      MscmpSystUtils.resolve_options(
        opts[:migration_bindings],
        Impl.Instance.get_standard_migration_bindings(instance.id)
      )

    default_options = [
      {:instance_supervisor_name, @default_instance_supervisor_name},
      {:registry_name, @default_registry_name}
      | Impl.Instance.get_default_instance_state_ids()
    ]

    opts =
      MscmpSystUtils.resolve_options(opts, default_options)
      |> Keyword.put(:migration_bindings, resolved_migration_bindings)

    true = valid_startup_instance_state?(instance)

    application_supervisor = get_application_supervisor_name(instance.application, opts)
    instance_supervisor_name = get_instance_supervisor_name(instance, opts)

    {:ok, _} = start_instance_supervisor(application_supervisor, instance_supervisor_name)

    {:ok, migrating_instance} =
      Impl.Instance.set_instance_state(instance, opts[:migrating_state_id])

    datastore_options =
      MscmpSystInstance.Impl.Instance.get_instance_datastore_options(
        instance,
        startup_options
      )

    {:ok, _} =
      MscmpSystDb.upgrade_datastore(
        datastore_options,
        instance.application.internal_name,
        opts[:migration_bindings],
        opts
      )

    datastore_supervisor_name = get_datastore_supervisor_name(instance, opts)

    datastore_child_spec =
      MscmpSystDb.Datastore.child_spec(
        datastore_options,
        name: datastore_supervisor_name
      )

    {:ok, _, _} = DynamicSupervisor.start_child(instance_supervisor_name, datastore_child_spec)

    {:ok, _} = Impl.Instance.set_instance_state(migrating_instance, opts[:active_state_id])

    :ok
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MscmpSystError{
          code: :undefined_error,
          message: "Failure starting Instance.",
          cause: error
        }
      }
  end

  def start_instance(%Msdata.SystInstances{id: instance_id}, startup_options, opts),
    do: start_instance(instance_id, startup_options, opts)

  defp get_datastore_supervisor_name(instance, opts),
    do: {:via, Registry, {opts[:registry_name], {:datastore_supervisor, instance.internal_name}}}

  defp get_instance_supervisor_name(instance, opts),
    do: {:via, Registry, {opts[:registry_name], {:instance_supervisor, instance.internal_name}}}

  defp get_application_supervisor_name(application, opts) do
    {:via, Registry, {opts[:registry_name], {:application_supervisor, application.internal_name}}}
  end

  defp start_instance_supervisor(application_supervisor, instance_supervisor_name) do
    instance_spec = {DynamicSupervisor, strategy: :one_for_one, name: instance_supervisor_name}

    DynamicSupervisor.start_child(application_supervisor, instance_spec)
  end

  defp valid_startup_instance_state?(%Msdata.SystInstances{} = instance) do
    MscmpSystEnums.get_functional_type_by_enum_item_id(
      "instance_states",
      instance.instance_state_id
    ) in ["instance_states_initialized", "instance_states_active"]
  end

  @spec stop_instance(Types.instance_id() | Msdata.SystInstances.t(), Keyword.t()) ::
          :ok | {:error, MscmpSystError.t()}
  def stop_instance(instance_id, opts) when is_binary(instance_id) do
    from(i in Msdata.SystInstances, where: i.id == ^instance_id, preload: [:instance_contexts])
    |> MscmpSystDb.one!()
    |> stop_instance(opts)
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MscmpSystError{
          code: :undefined_error,
          message: "Failure stopping Instance by ID.",
          cause: error
        }
      }
  end

  # TODO: While we stop the Datastore explicitly, I think this probably doesn't
  #       do anything.  Stopping the Instance Supervisor I believe will stop the
  #       Datastore Contexts anyway since they're supervised processed.  Check
  #       out how necessary this is and if we should do something about it.
  def stop_instance(
        %Msdata.SystInstances{
          internal_name: instance_name,
          instance_contexts: [_ | _] = instance_contexts
        },
        opts
      ) do
    opts = MscmpSystUtils.resolve_options(opts, registry_name: @default_registry_name)

    :ok =
      instance_contexts
      |> Enum.map(&%{context_name: String.to_atom(&1.internal_name)})
      |> MscmpSystDb.stop_datastore(opts[:db_shutdown_timeout] || 60_000)

    stop_instance_supervisor(instance_name, opts)
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MscmpSystError{
          code: :undefined_error,
          message: "Failure stopping Instance.",
          cause: error
        }
      }
  end

  def stop_instance(%Msdata.SystInstances{id: instance_id}, opts),
    do: stop_instance(instance_id, opts)

  defp stop_instance_supervisor(instance_name, opts) do
    opts = MscmpSystUtils.resolve_options(opts, supervisor_shutdown_timeout: 60_000)

    Registry.lookup(opts[:registry_name], {:instance_supervisor, instance_name})
    |> maybe_stop_instance_supervisor(opts)
  end

  defp maybe_stop_instance_supervisor([{instance_supervisor, _} | _], opts) do
    DynamicSupervisor.stop(instance_supervisor, :normal, opts[:supervisor_shutdown_timeout])
  end

  defp maybe_stop_instance_supervisor(_, _opts), do: nil

  @spec stop_application(Types.application_id() | Msdata.SystApplications.t(), Keyword.t()) ::
          :ok | {:error, MscmpSystError.t()}
  def stop_application(application_id, opts) when is_binary(application_id) do
    from(a in Msdata.SystApplications,
      where: a.id == ^application_id,
      select: [:id, :internal_name]
    )
    |> MscmpSystDb.one!()
    |> stop_application(opts)
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MscmpSystError{
          code: :undefined_error,
          message: "Failure stopping Application by ID.",
          cause: error
        }
      }
  end

  def stop_application(
        %Msdata.SystApplications{id: application_id, internal_name: application_name},
        opts
      ) do
    opts = MscmpSystUtils.resolve_options(opts, registry_name: @default_registry_name)

    from(i in Msdata.SystInstances,
      join: a in assoc(i, :application),
      where: a.id == ^application_id,
      preload: [:instance_contexts]
    )
    |> MscmpSystDb.all()
    |> Enum.each(&stop_instance(&1, opts))

    stop_application_supervisor(application_name, opts)
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MscmpSystError{
          code: :undefined_error,
          message: "Failure stopping Application.",
          cause: error
        }
      }
  end

  defp stop_application_supervisor(application_name, opts) do
    opts = MscmpSystUtils.resolve_options(opts, supervisor_shutdown_timeout: 60_000)

    # TODO: Some tests fail if the following sleep is omitted.  We will want to
    #       resolve this if only to have confidence in why this extra call + 1ms
    #       actually makes a difference, but for now hack over it.  The failure
    #       we see from this in our tests wouldn't indicate a critical failure
    #       and we've more important things to do right now.

    Process.sleep(1)

    DynamicSupervisor.stop(
      {:via, Registry, {opts[:registry_name], {:application_supervisor, application_name}}},
      :normal,
      opts[:supervisor_shutdown_timeout]
    )
  end

  # TODO: This function needs to be better able to report failures.  It's
  #       conceivable that any individual Application stop could fail while
  #       others may succeed.  This shouldn't be a common case, but it should be
  #       better handled nonetheless.
  @spec stop_all_applications(Keyword.t()) :: :ok | {:error, MscmpSystError.t()}
  def stop_all_applications(opts) do
    from(a in Msdata.SystApplications, select: [:id, :internal_name])
    |> MscmpSystDb.all()
    |> Enum.each(&stop_application(&1, opts))
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MscmpSystError{
          code: :undefined_error,
          message: "Failure stopping all started Applications.",
          cause: error
        }
      }
  end
end
