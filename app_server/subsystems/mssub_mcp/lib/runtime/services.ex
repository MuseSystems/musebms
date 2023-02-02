# Source File: services.ex
# Location:    musebms/subsystems/mssub_mcp/lib/runtime/services.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MssubMcp.Runtime.Services do
  alias MssubMcp.Runtime

  @moduledoc false

  use MssubMcp.Macros

  mcp_constants()

  def init(args) do
    datastore_options = Runtime.Options.get_datastore_options(args[:startup_options], args)

    datastore_spec =
      MscmpSystDb.Datastore.child_spec(datastore_options, [
        {:name, @mcp_datastore_supervisor_name} | args
      ])

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

    mcp_service_children = [
      datastore_spec,
      instance_manager_spec,
      enum_service_spec,
      settings_service_spec
    ]

    Supervisor.init(mcp_service_children, strategy: :one_for_one)
  end
end
