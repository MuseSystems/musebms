# Source File: service_test.exs
# Location:    musebms/app_server/components/system/mscmp_syst_settings/test/service_test.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule ServiceTest do
  @moduledoc false

  use SettingsTestCase, async: true

  @moduletag :unit
  @moduletag :capture_log

  test "service operations" do
    service_name = TestSupport.get_settings_service_name()

    # Test that the settings table is a valid reference
    assert is_reference(GenServer.call(service_name, :get_settings_table))

    # Test service refresh
    assert :ok = GenServer.call(service_name, :refresh)

    # Test service create/update/delete operations
    test_setting = %{
      internal_name: "test_service_setting",
      display_name: "Test Service Setting",
      user_description: "A test setting for service operations"
    }

    assert :ok = GenServer.call(service_name, {:create, test_setting})

    update_params = %{
      display_name: "Updated Service Setting",
      setting_integer: 42
    }

    assert :ok =
             GenServer.call(service_name, {:update, "test_service_setting", update_params})

    assert :ok = GenServer.call(service_name, {:delete, "test_service_setting"})
  end

  test "service handles database settings" do
    service_name = TestSupport.get_settings_service_name()
    settings_table = GenServer.call(service_name, :get_settings_table)

    # Verify preloaded test settings exist
    assert [{_, setting_one}] = :ets.lookup(settings_table, "test_setting_one")
    assert setting_one.display_name == "Test Setting One"
    assert setting_one.setting_integer == 111
    assert setting_one.setting_text == "Test Setting One Text"

    assert [{_, setting_two}] = :ets.lookup(settings_table, "test_setting_two")
    assert setting_two.display_name == "Test Setting Two"
    assert setting_two.setting_integer == 222
    assert setting_two.setting_text == "Test Setting Two Text"
  end
end
