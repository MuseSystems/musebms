# Source File: application.ex
# Location:    musebms/subsystems/mssub_mcp/lib/runtime/application.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MssubMcp.Runtime.Application do
  use Application

  @moduledoc false
  require Logger

  use MssubMcp.Macros

  mcp_constants()

  @impl true
  @spec start(Application.start_type(), term()) ::
          {:ok, pid()} | {:ok, pid(), Application.state()} | {:error, term()}
  def start(_type, _args) do
    case setup_rate_limiter() do
      :ok ->
        instance_manager_spec = %{
          id: MssubMcpInstanceMgr,
          start:
            {MscmpSystInstance, :start_link,
             [
               [
                 supervisor_name: @mcp_instances_config.supervisor_name,
                 registry_name: @mcp_instances_config.registry_name,
                 instance_supervisor_name: @mcp_instances_config.instance_supervisor_name,
                 task_supervisor_name: @mcp_instances_config.task_supervisor_name
               ]
             ]}
        }

        enum_service_spec = %{
          id: MssubMcpEnumsService,
          start:
            {MscmpSystEnums, :start_link, [{@mcp_enums_service_name, @mcp_db_app_access_context}]}
        }

        settings_service_spec = %{
          id: MssubMcpSettingsService,
          start:
            {MscmpSystSettings, :start_link,
             [{@mcp_settings_service_name, @mcp_db_app_access_context}]}
        }

        limiter_service_spec = %{
          id: MssubMcpLimiterService,
          start:
            {MscmpSystLimiter, :start_link,
             [[supervisor_name: @mcp_limiter_config.supervisor_name]]}
        }

        mcp_service_children = [
          MssubMcp.Runtime.Datastore.child_spec(datastore_name: @mcp_datastore_supervisor_name),
          instance_manager_spec,
          enum_service_spec,
          settings_service_spec,
          limiter_service_spec
        ]

        result =
          Supervisor.start_link(mcp_service_children,
            strategy: :one_for_one,
            name: @mcp_supervisor_name
          )

        # TODO: This return should probably be checked for errors rather than
        #       just glossed over like this.
        _ = MscmpSystLimiter.init_rate_limiter()

        result

      error ->
        raise MscmpSystError,
          code: :undefined_error,
          message: "Unable to setup Mnesia for MscmpSystLimiter.",
          cause: error
    end
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      reraise MscmpSystError,
        code: :undefined_error,
        message: "Failure trying to start MCP Subsystem",
        cause: error
  end

  defp setup_rate_limiter do
    with :stopped <- :mnesia.stop(),
         :ok <- maybe_create_mnesia_schema() do
      :mnesia.start()
    else
      error ->
        raise MscmpSystError,
          code: :undefined_error,
          message: "Unable to setup Mnesia for MscmpSystLimiter.",
          cause: error
    end
  end

  defp maybe_create_mnesia_schema do
    case :mnesia.create_schema([node()]) do
      {:error, {_node, {:already_exists, _node_again}}} -> :ok
      :ok -> :ok
    end
  end
end
