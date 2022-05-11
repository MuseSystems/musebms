# Source File: owner_states_test.exs
# Location:    components/system/msbms_syst_instance_mgr/test/owner_states_test.exs
# Project:     msbms
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https: //muse.systems

defmodule OwnerStatesTest do
  use InstanceMgrTestCase, async: true

  test "Can List Owner States" do
    assert {:ok, owner_states} = MsbmsSystInstanceMgr.list_owner_states()

    assert 4 <= length(owner_states)
  end

  test "Can Create Owner State" do
    new_state = %{
      internal_name: "owner_state_create_state_test",
      display_name: "Owner State / Create State Test",
      external_name: "Create Owner State Test",
      user_description: "A test of Owner state creation.",
      functional_type_name: "owner_states_active"
    }

    assert {:ok,
            %MsbmsSystEnums.Data.SystEnumItems{internal_name: "owner_state_create_state_test"}} =
             MsbmsSystInstanceMgr.create_owner_state(new_state)
  end

  test "Can Get Owner State Values by Name" do
    assert {:ok,
            %MsbmsSystEnums.Data.SystEnumItems{
              internal_name: "owner_states_sysdef_suspended"
            }} = MsbmsSystInstanceMgr.get_owner_state_by_name("owner_states_sysdef_suspended")
  end

  test "Can Set Owner State Values" do
    new_state = %{
      internal_name: "owner_state_modify_test",
      display_name: "Owner State / Modify State Test",
      external_name: "Modify Owner State Test",
      user_description: "A test of Owner state modification.",
      functional_type_name: "owner_states_inactive"
    }

    changes = %{
      internal_name: "owner_state_modify_test_changed",
      display_name: "Owner State / Modify State Test (Changed)",
      external_name: "Modify Owner State Test (Changed)",
      user_description: "A test of Owner state modification. (Changed)",
      functional_type_default: true
    }

    {:ok, _created_state} = MsbmsSystInstanceMgr.create_owner_state(new_state)

    assert {:ok, updated_state} =
             MsbmsSystInstanceMgr.set_owner_state_values("owner_state_modify_test", changes)

    assert %MsbmsSystEnums.Data.SystEnumItems{
             internal_name: "owner_state_modify_test_changed"
           } = updated_state
  end

  test "Can Delete Owner State" do
    new_state = %{
      internal_name: "owner_state_delete_test",
      display_name: "Owner State / Delete State Test",
      external_name: "Delete Owner State Test",
      user_description: "A test of Owner state deletion.",
      functional_type_name: "owner_states_inactive"
    }

    {:ok, created_state} = MsbmsSystInstanceMgr.create_owner_state(new_state)

    assert :ok = MsbmsSystInstanceMgr.delete_owner_state("owner_state_delete_test")
  end
end
