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

  use MssubMcp.Macros

  mcp_constants()

  @spec process_operation((() -> any())) :: any()
  mcp_opfn process_operation(operation) do
    operation.()
  end

  @spec start_mcp_service_context() ::
          {atom() | pid() | nil, MscmpSystEnums.Types.service_name() | nil,
           MscmpSystSettings.Types.service_name() | nil}
  def start_mcp_service_context do
    start_enums_service = MscmpSystEnums.put_enums_service(@mcp_enums_service_name)
    start_settings_service = MscmpSystSettings.put_settings_service(@mcp_settings_service_name)
    start_datastore_context = MscmpSystDb.put_datastore_context(@mcp_db_app_access_context)

    {start_datastore_context, start_enums_service, start_settings_service}
  end

  @spec stop_mcp_service_context(
          {atom() | pid() | nil, MscmpSystEnums.Types.service_name() | nil,
           MscmpSystSettings.Types.service_name() | nil}
        ) :: :ok
  def stop_mcp_service_context(
        {datastore_context_name, enums_service_name, settings_service_name}
      ) do
    _ = MscmpSystDb.put_datastore_context(datastore_context_name)
    _ = MscmpSystSettings.put_settings_service(settings_service_name)
    _ = MscmpSystEnums.put_enums_service(enums_service_name)
    :ok
  end
end
