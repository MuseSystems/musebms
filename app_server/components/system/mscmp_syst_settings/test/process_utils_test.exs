# Source File: process_utils_test.exs
# Location:    musebms/components/system/mscmp_syst_settings/test/process_utils_test.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule ProcessUtilsTest do
  @moduledoc false

  use SettingsTestCase, async: true

  alias MscmpSystSettings.Runtime.ProcessUtils

  @moduletag :unit
  @moduletag :capture_log

  test "process utils operations" do
    service_name = TestSupport.get_settings_service_name()
    settings_table = GenServer.call(service_name, :get_settings_table)

    # Test get/put service operations
    assert service_name == ProcessUtils.get_service()
    assert settings_table == ProcessUtils.get_settings_table()

    # Test clearing service
    assert service_name == ProcessUtils.put_service(nil)
    assert nil == ProcessUtils.get_service()
    assert nil == ProcessUtils.get_settings_table()

    # Test restoring service
    assert nil == ProcessUtils.put_service(service_name)
    assert service_name == ProcessUtils.get_service()
    assert settings_table == ProcessUtils.get_settings_table()
  end
end
