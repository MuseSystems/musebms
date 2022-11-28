# Source File: processing.ex
# Location:    musebms/subsystems/mssub_mcp/lib/runtime/processing.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MssubMcp.Runtime.Processing do
  @moduledoc false

  @default_enums_service_name :mssub_mcp_enums_service
  @default_settings_service_name :mssub_mcp_settings_service

  @spec process_operation(function()) :: any()
  def process_operation(operation) do
    mcp_enums_service =
      Application.get_env(:mssub_mcp, :enums_service_name, @default_enums_service_name)

    mcp_settings_service =
      Application.get_env(:mssub_mcp, :settings_service_name, @default_settings_service_name)

    starting_enums_service = MscmpSystEnums.put_enums_service(mcp_enums_service)
    starting_settings_service = MscmpSystSettings.put_settings_service(mcp_settings_service)
    starting_datastore_context = MscmpSystDb.put_datastore_context(:mssub_mcp_app_access)

    result = operation.()

    MscmpSystDb.put_datastore_context(starting_datastore_context)
    MscmpSystSettings.put_settings_service(starting_settings_service)
    MscmpSystEnums.put_enums_service(starting_enums_service)

    result
  end
end
