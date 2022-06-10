# Source File: instance_states_test.exs
# Location:    components/system/msbms_syst_instance_mgr/test/instance_states_test.exs
# Project:     msbms
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https: //muse.systems

defmodule InstanceStatesTest do
  use InstanceMgrTestCase, async: true

  test "Can List Instance States" do
    assert {:ok, instance_states} = MsbmsSystInstanceMgr.list_instance_states()

    assert 6 <= length(instance_states)
  end

  test "Can Create Instance State" do
    new_state = %{
      internal_name: "instance_state_create_state_test",
      display_name: "Instance State / Create State Test",
      external_name: "Create Instance State Test",
      user_description: "A test of instance state creation.",
      functional_type_name: "instance_states_active"
    }

    assert {:ok,
            %MsbmsSystEnums.Data.SystEnumItems{internal_name: "instance_state_create_state_test"}} =
             MsbmsSystInstanceMgr.create_instance_state(new_state)
  end

  test "Can Get Instance State Values by Name" do
    assert {:ok,
            %MsbmsSystEnums.Data.SystEnumItems{
              internal_name: "instance_states_sysdef_uninitialized"
            }} =
             MsbmsSystInstanceMgr.get_instance_state_by_name(
               "instance_states_sysdef_uninitialized"
             )
  end

  test "Can Set Instance State Values" do
    new_state = %{
      internal_name: "instance_state_modify_test",
      display_name: "Instance State / Modify State Test",
      external_name: "Modify Instance State Test",
      user_description: "A test of instance state modification.",
      functional_type_name: "instance_states_inactive"
    }

    changes = %{
      internal_name: "instance_state_modify_test_changed",
      display_name: "Instance State / Modify State Test (Changed)",
      external_name: "Modify Instance State Test (Changed)",
      user_description: "A test of instance state modification. (Changed)",
      functional_type_default: true
    }

    {:ok, _created_state} = MsbmsSystInstanceMgr.create_instance_state(new_state)

    assert {:ok, updated_state} =
             MsbmsSystInstanceMgr.set_instance_state_values("instance_state_modify_test", changes)

    assert %MsbmsSystEnums.Data.SystEnumItems{
             internal_name: "instance_state_modify_test_changed"
           } = updated_state
  end

  test "Can Delete Instance State" do
    new_state = %{
      internal_name: "instance_state_delete_test",
      display_name: "Instance State / Delete State Test",
      external_name: "Delete Instance State Test",
      user_description: "A test of instance state deletion.",
      functional_type_name: "instance_states_inactive"
    }

    {:ok, _created_state} = MsbmsSystInstanceMgr.create_instance_state(new_state)

    assert :ok = MsbmsSystInstanceMgr.delete_instance_state("instance_state_delete_test")
  end
end
