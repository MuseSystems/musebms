# Source File: doctests_test.exs
# Location:    components/system/msbms_syst_instance_mgr/test/doctests_test.exs
# Project:     msbms
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https: //muse.systems

defmodule DoctestsTest do
  use InstanceMgrTestCase, async: true

  setup_all do
    _ = MsbmsSystDatastore.set_datastore_context(TestSupport.get_testing_datastore_context_id())
    MsbmsSystEnums.put_enums_service(:instance_mgr)

    :ok
  end

  doctest MsbmsSystInstanceMgr
end
