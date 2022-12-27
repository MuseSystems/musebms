# Source File: processing_test.exs
# Location:    musebms/subsystems/mssub_mcp/test/processing_test.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MssubMcpTest do
  use MssubMcp.Macros
  use ExUnit.Case, async: false

  mcp_constants()

  test "Can process in the MCP Service Context" do
    mcp_enums_service = @mcp_enums_service_name
    mcp_settings_service = @mcp_settings_service_name

    assert mcp_enums_service != nil
    assert mcp_settings_service != nil

    assert MscmpSystEnums.get_enums_service() == nil
    assert MscmpSystSettings.get_settings_service() == nil

    assert MssubMcp.process_operation(&MscmpSystEnums.get_enums_service/0) == mcp_enums_service

    assert MssubMcp.process_operation(&MscmpSystSettings.get_settings_service/0) ==
             mcp_settings_service

    assert {:ok, _owner_id} =
             MssubMcp.process_operation(fn -> MscmpSystInstance.get_owner_id_by_name("owner1") end)

    assert MscmpSystEnums.get_enums_service() == nil
    assert MscmpSystSettings.get_settings_service() == nil
  end

  test "Can start and stop MCP Service Context" do
    mcp_enums_service = @mcp_enums_service_name
    mcp_settings_service = @mcp_settings_service_name

    assert mcp_enums_service != nil
    assert mcp_settings_service != nil

    assert MscmpSystEnums.get_enums_service() == nil
    assert MscmpSystSettings.get_settings_service() == nil

    assert {datastore_context, nil, nil} = MssubMcp.start_mcp_service_context()

    assert MscmpSystEnums.get_enums_service() == @mcp_enums_service_name
    assert MscmpSystSettings.get_settings_service() == @mcp_settings_service_name

    assert :ok = MssubMcp.stop_mcp_service_context({datastore_context, nil, nil})

    assert MscmpSystEnums.get_enums_service() == nil
    assert MscmpSystSettings.get_settings_service() == nil
  end
end
