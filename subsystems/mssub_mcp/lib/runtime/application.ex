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

  @supervisor_name MssubMcp.Supervisor
  @datastore_supervisor_name MssubMcp.DatastoreSupervisor
  @default_enums_service_name :mssub_mcp_enums_service
  @default_settings_service_name :mssub_mcp_settings_service

  @impl true
  @spec start(Application.start_type(), term()) ::
          {:ok, pid()} | {:ok, pid(), Application.state()} | {:error, term()}
  def start(_type, args) do
    opts = MscmpSystUtils.resolve_options(args[:opts], datastore_name: @datastore_supervisor_name)

    case setup_rate_limiter() do
      {:ok, _} ->
        enum_service_spec = %{
          id: MssubMcpEnumsService,
          start:
            {MscmpSystEnums, :start_link,
             [
               {Application.get_env(:mssub_mcp, :enums_service_name, @default_enums_service_name),
                :mssub_mcp_app_access}
             ]}
        }

        settings_service_spec = %{
          id: MssubMcpSettingsService,
          start:
            {MscmpSystSettings, :start_link,
             [
               {Application.get_env(
                  :mssub_mcp,
                  :settings_service_name,
                  @default_settings_service_name
                ), :mssub_mcp_app_access}
             ]}
        }

        mcp_service_children = [
          MssubMcp.Runtime.Datastore.child_spec(opts),
          enum_service_spec,
          settings_service_spec
        ]

        Supervisor.start_link(mcp_service_children, strategy: :one_for_one, name: @supervisor_name)

      error ->
        raise MscmpSystError,
          code: :undefined_error,
          message: "Unable to start MCP Subsystem",
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
         :ok <- maybe_create_mnesia_schema(),
         :ok <- :mnesia.start() do
      MscmpSystLimiter.init_rate_limiter()
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
