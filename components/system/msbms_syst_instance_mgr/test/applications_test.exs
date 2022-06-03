# Source File: applications_test.exs
# Location:    components/system/msbms_syst_instance_mgr/test/applications_test.exs
# Project:     msbms
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https: //muse.systems

defmodule ApplicationsTest do
  use InstanceMgrTestCase, async: true

  test "Can List Applications" do
    assert {:ok, apps} = MsbmsSystInstanceMgr.list_applications()
    assert 2 = length(apps)
    assert %MsbmsSystInstanceMgr.Data.SystApplications{internal_name: "app1"} = hd(apps)
  end
end
