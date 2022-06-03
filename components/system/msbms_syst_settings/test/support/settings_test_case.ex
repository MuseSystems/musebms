# Source File: settings_test_case.ex
# Location:    components/system/msbms_syst_settings/test/support/settings_test_case.ex
# Project:     msbms
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https: //muse.systems

defmodule SettingsTestCase do
  use ExUnit.CaseTemplate
  @moduledoc false

  setup do
    [
      datastore_context:
        MsbmsSystDatastore.set_datastore_context(TestSupport.get_testing_datastore_context_id())
    ]
  end

  setup do
    MsbmsSystSettings.put_settings_service(:settings_instance)
    :ok
  end
end
