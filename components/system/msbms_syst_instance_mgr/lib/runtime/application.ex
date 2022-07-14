# Source File: application.ex
# Location:    components/system/msbms_syst_instance_mgr/lib/runtime/application.ex
# Project:     msbms
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https: //muse.systems

defmodule MsbmsSystInstanceMgr.Runtime.Application do
  import Ecto.Query
  import MsbmsSystUtils

  alias MsbmsSystInstanceMgr.Data
  alias MsbmsSystInstanceMgr.Impl

  require Logger

  @inst_mgr_name MsbmsSystInstanceMgr.Supervisor
  @task_mgr_name MsbmsSystInstanceMgr.TaskSupervisor
  @registry MsbmsSystInstanceMgr.Registry

  @moduledoc false

  ##############################################################################
  # Application
  # ----------------------------------------------------------------------------
  #
  # The Application Module handles runtime aspects of the MsbmsInstanceMgr
  # component such as always started components and secondary supervision tree
  # startup.
  #
  ##############################################################################

  # start/2 is called automatically on OTP application start-up.

  def start(_type, _args) do
    inst_mgr_spec = [
      {DynamicSupervisor, strategy: :one_for_one, name: @inst_mgr_name},
      {Task.Supervisor, name: @task_mgr_name},
      {Registry, keys: :unique, name: @registry}
    ]

    Supervisor.start_link(inst_mgr_spec, strategy: :one_for_one)
  end

  # Starts an application supervisor which will monitor all instance
  # supervisors.  The goal is to isolate each application from other
  # applications on the server.

  def start_application(application_id, startup_options, opts) when is_binary(application_id) do
    from(a in Data.SystApplications, where: a.id == ^application_id, select: [:id, :internal_name])
    |> MsbmsSystDatastore.one!()
    |> start_application(startup_options, opts)
  end

  def start_application(
        %Data.SystApplications{id: application_id} = application,
        startup_options,
        opts
      ) do
    opts = resolve_options(opts, max_concurrency: default_max_concurrency())

    supervisor_name = get_application_supervisor_name(application)

    {:ok, _} = start_application_supervisor(supervisor_name)

    current_datastore_context = MsbmsSystDatastore.current_datastore_context()
    current_enums_service = MsbmsSystEnums.get_enums_service()

    from(
      i in Data.SystInstances,
      join: a in assoc(i, :application),
      where: a.id == ^application_id,
      preload: [application: a, instance_contexts: [:application_context]]
    )
    |> MsbmsSystDatastore.all()
    |> then(
      &Task.Supervisor.async_stream_nolink(
        @task_mgr_name,
        &1,
        fn instance ->
          MsbmsSystDatastore.set_datastore_context(current_datastore_context)
          MsbmsSystEnums.put_enums_service(current_enums_service)
          start_instance(instance, startup_options, opts)
        end,
        opts
      )
    )
    |> Enum.to_list()
  rescue
    error -> Logger.error(Exception.format(:error, error, __STACKTRACE__))
  end

  defp start_application_supervisor(application_supervisor_name) do
    application_spec =
      {DynamicSupervisor, strategy: :one_for_one, name: application_supervisor_name}

    {:ok, _} = DynamicSupervisor.start_child(@inst_mgr_name, application_spec)
  end

  defp default_max_concurrency() do
    if System.schedulers_online() < 4 do
      1
    else
      (System.schedulers_online() / 4) |> floor()
    end
  end

  # Starts all application supervisors.

  def start_all_applications(startup_options, opts) do
    from(a in Data.SystApplications, select: [:id, :internal_name])
    |> MsbmsSystDatastore.all()
    |> Enum.each(&start_application(&1, startup_options, opts))
  end

  # Starts an instance and places it under the appropriate application's
  # supervisor.  An instance is essentially a tenant environment running a
  # specific application (our sense of the word).  Each tenant's runtime
  # characteristics are independent of other tenants on the system. Note that we
  # assume that the Application supervisor is already started.

  def start_instance(instance_id, startup_options, opts) when is_binary(instance_id) do
    from(
      i in Data.SystInstances,
      join: a in assoc(i, :application),
      where: i.id == ^instance_id,
      preload: [application: a, instance_contexts: [:application_context]]
    )
    |> MsbmsSystDatastore.one!()
    |> start_instance(startup_options, opts)
  end

  # TODO: This is too "happy path" centric.  There are failure modes that can be
  #       handled resiliently and probably should be.  Defer for now.
  def start_instance(
        %Data.SystInstances{application: %Data.SystApplications{}, instance_contexts: [_ | _]} =
          instance,
        startup_options,
        opts
      ) do
    resolved_migration_bindings =
      resolve_options(
        opts[:migration_bindings],
        Impl.Instance.get_standard_migration_bindings(instance.id)
      )

    default_options = Impl.Instance.get_default_instance_state_ids()

    opts =
      resolve_options(opts, default_options)
      |> Keyword.put(:migration_bindings, resolved_migration_bindings)

    true = valid_startup_instance_state?(instance)

    application_supervisor = get_application_supervisor_name(instance.application)
    instance_supervisor_name = get_instance_supervisor_name(instance)

    {:ok, _} = start_instance_supervisor(application_supervisor, instance_supervisor_name)

    {:ok, migrating_instance} =
      Impl.Instance.set_instance_state(instance, opts[:migrating_state_id])

    datastore_options =
      MsbmsSystInstanceMgr.Impl.Instance.get_instance_datastore_options(
        instance,
        startup_options
      )

    {:ok, _} =
      MsbmsSystDatastore.upgrade_datastore(
        datastore_options,
        instance.application.internal_name,
        opts[:migration_bindings],
        opts
      )

    datastore_supervisor_name = get_datastore_supervisor_name(instance)

    datastore_child_spec =
      MsbmsSystDatastore.Datastore.child_spec(
        datastore_options,
        name: datastore_supervisor_name
      )

    {:ok, _, _} = DynamicSupervisor.start_child(instance_supervisor_name, datastore_child_spec)

    {:ok, _} = Impl.Instance.set_instance_state(migrating_instance, opts[:active_state_id])

    :ok
  rescue
    error -> Logger.error(Exception.format(:error, error, __STACKTRACE__))
  end

  def start_instance(%Data.SystInstances{id: instance_id}, startup_options, opts),
    do: start_instance(instance_id, startup_options, opts)

  defp get_datastore_supervisor_name(instance) do
    {:via, Registry, {@registry, {:datastore_supervisor, instance.internal_name}}}
  end

  defp get_instance_supervisor_name(instance) do
    {:via, Registry, {@registry, {:instance_supervisor, instance.internal_name}}}
  end

  defp get_application_supervisor_name(application) do
    {:via, Registry, {@registry, {:application_supervisor, application.internal_name}}}
  end

  defp start_instance_supervisor(application_supervisor, instance_supervisor_name) do
    instance_spec = {DynamicSupervisor, strategy: :one_for_one, name: instance_supervisor_name}

    DynamicSupervisor.start_child(application_supervisor, instance_spec)
  end

  defp valid_startup_instance_state?(%Data.SystInstances{} = instance) do
    MsbmsSystEnums.get_functional_type_by_enum_item_id(
      "instance_states",
      instance.instance_state_id
    ) in ["instance_states_initialized", "instance_states_active"]
  end

  def stop_instance(instance_id, opts) when is_binary(instance_id) do
    from(i in Data.SystInstances, where: i.id == ^instance_id, preload: [:instance_contexts])
    |> MsbmsSystDatastore.one!()
    |> stop_instance(opts)
  end

  def stop_instance(
        %Data.SystInstances{
          internal_name: instance_name,
          instance_contexts: [_ | _] = instance_contexts
        },
        opts
      ) do
    :ok = stop_instance_supervisor(instance_name, opts)

    :ok =
      instance_contexts
      |> Enum.map(&%{id: String.to_atom(&1.internal_name)})
      |> MsbmsSystDatastore.stop_datastore(opts)
  end

  def stop_instance(%Data.SystInstances{id: instance_id}, opts),
    do: stop_instance(instance_id, opts)

  defp stop_instance_supervisor(instance_name, opts) do
    opts = resolve_options(opts, supervisor_shutdown_timeout: 60_000)

    if [{instance_supervisor, _} | _] =
         Registry.lookup(@registry, {:instance_supervisor, instance_name}) do
      DynamicSupervisor.stop(instance_supervisor, :normal, opts[:supervisor_shutdown_timeout])
    end
  end

  def stop_application(application_id, opts) when is_binary(application_id) do
    from(a in Data.SystApplications, where: a.id == ^application_id, select: [:id, :internal_name])
    |> MsbmsSystDatastore.one!()
    |> stop_application(opts)
  end

  def stop_application(
        %Data.SystApplications{id: application_id, internal_name: application_name},
        opts
      ) do
    from(i in Data.SystInstances,
      join: a in assoc(i, :application),
      where: a.id == ^application_id,
      preload: [:instance_contexts]
    )
    |> MsbmsSystDatastore.all()
    |> Enum.each(&stop_instance(&1, opts))

    :ok = stop_application_supervisor(application_name, opts)
  end

  defp stop_application_supervisor(application_name, opts) do
    opts = resolve_options(opts, supervisor_shutdown_timeout: 60_000)

    DynamicSupervisor.stop(
      {:via, Registry, {@registry, {:application_supervisor, application_name}}},
      :normal,
      opts[:supervisor_shutdown_timeout]
    )
  end

  def stop_all_applications(opts) do
    from(a in Data.SystApplications, select: [:id, :internal_name])
    |> MsbmsSystDatastore.all()
    |> Enum.each(&stop_application(&1, opts))
  end
end
