# Source File: macros.ex
# Location:    musebms/subsystems/mssub_mcp/lib/macros.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MssubMcp.Macros do
  @moduledoc false

  defmacro __using__(_opts) do
    quote do
      import MssubMcp.Macros
    end
  end

  defmacro mcp_constants() do
    quote do
      @mcp_supervisor_name MssubMcp.Supervisor
      @mcp_datastore_supervisor_name MssubMcp.DatastoreSupervisor
      @mcp_enums_service_name MssubMcp.Services.Enums
      @mcp_settings_service_name MssubMcp.Services.Settings
      @mcp_instances_config %{
        supervisor_name: MssubMcp.InstanceMgrSupervisor,
        registry_name: MssubMcp.InstanceMgrRegistry,
        instance_supervisor_name: MssubMcp.InstancesSupervisor,
        task_supervisor_name: MssubMcp.InstanceMgrTaskSupervisor
      }

      @mcp_limiter_config %{
        supervisor_name: MssubMcp.LimiterSupervisor
      }

      @mcp_db_name "mssub_mcp"
      @mcp_db_owner_role "mssub_mcp_owner"
      @mcp_db_app_access_role "mssub_mcp_app_access"
      @mcp_db_app_access_context MssubMcp.AppAccess
    end
  end

  defmacro mcp_opfn(func_call, do: block) do
    quote do
      def unquote(func_call) do
        starting_enums_service = MscmpSystEnums.put_enums_service(@mcp_enums_service_name)

        starting_settings_service =
          MscmpSystSettings.put_settings_service(@mcp_settings_service_name)

        starting_datastore_context = MscmpSystDb.put_datastore_context(@mcp_db_app_access_context)

        result = unquote(block)

        _ = MscmpSystDb.put_datastore_context(starting_datastore_context)
        _ = MscmpSystSettings.put_settings_service(starting_settings_service)
        _ = MscmpSystEnums.put_enums_service(starting_enums_service)

        result
      end
    end
  end
end
