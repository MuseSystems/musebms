# Source File: settings_test_case.ex
# Location:    musebms/components/system/mscmp_syst_settings/test/support/settings_test_case.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule SettingsTestCase do
  @moduledoc false

  use ExUnit.CaseTemplate

  setup do
    [
      datastore_context:
        MscmpSystDb.put_datastore_context(
          {:via, Registry,
           {MscmpSystSettings.TestRegistry, TestSupport.get_datastore_context_name()}}
        ),
      settings_service: MscmpSystSettings.put_service(TestSupport.get_settings_service_name())
    ]
  end
end
