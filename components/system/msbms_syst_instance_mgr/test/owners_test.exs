# Source File: owners_test.exs
# Location:    components/system/msbms_syst_instance_mgr/test/owners_test.exs
# Project:     msbms
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https: //muse.systems

defmodule OwnersTest do
  use InstanceMgrTestCase, async: true

  test "Can List All Owners" do
    assert {:ok, owners} = MsbmsSystInstanceMgr.list_owners()
    assert 4 <= length(owners)
  end

  test "Can List Sorted Owners" do
    assert {:ok, owners} = MsbmsSystInstanceMgr.list_owners(sort: true)
    assert 4 <= length(owners)
    assert %{owner_internal_name: "owner_1"} = hd(owners)
  end

  test "Can List Owners by Status" do
    assert {:ok, owners} =
             MsbmsSystInstanceMgr.list_owners(
               owner_state_functional_types: [:owner_states_active]
             )

    assert 2 <= length(owners)
  end

  test "Can List Sorted Owners by Status" do
    assert {:ok, owners} =
             MsbmsSystInstanceMgr.list_owners(
               sort: true,
               owner_state_functional_types: [:owner_states_inactive]
             )

    assert 2 <= length(owners)
    assert %{owner_internal_name: "owner_2"} = hd(owners)
  end

  test "Can Create New Owner" do
    default_owner_state = MsbmsSystEnums.get_default_enum_item("owner_states")

    assert {:ok, %MsbmsSystInstanceMgr.Data.SystOwners{internal_name: "owner_create_1"}} =
             MsbmsSystInstanceMgr.create_owner(
               "owner_create_1",
               "Owner Create Test",
               default_owner_state.id
             )
  end

  test "Can Change Existing Owner Internal Name" do
    change = %{internal_name: "changed_owner_create_2"}

    default_owner_state = MsbmsSystEnums.get_default_enum_item("owner_states")

    {:ok, test_owner} =
      MsbmsSystInstanceMgr.create_owner(
        "owner_create_2",
        "Owner Change Internal Name Test",
        default_owner_state.id
      )

    assert {:ok, %MsbmsSystInstanceMgr.Data.SystOwners{internal_name: "changed_owner_create_2"}} =
             MsbmsSystInstanceMgr.set_owner_values("owner_create_2", change)
  end

  test "Can Change Existing Owner Display Name" do
    change = %{display_name: "Owner Change Display Name Test Is Changed"}

    default_owner_state = MsbmsSystEnums.get_default_enum_item("owner_states")

    {:ok, test_owner} =
      MsbmsSystInstanceMgr.create_owner(
        "owner_create_3",
        "Owner Change Display Name Test",
        default_owner_state.id
      )

    assert {:ok,
            %MsbmsSystInstanceMgr.Data.SystOwners{
              display_name: "Owner Change Display Name Test Is Changed"
            }} = MsbmsSystInstanceMgr.set_owner_values("owner_create_3", change)
  end

  test "Can Change Existing Owner Owner State" do
    default_owner_state = MsbmsSystEnums.get_default_enum_item("owner_states")

    new_state =
      MsbmsSystEnums.get_default_enum_item("owner_states",
        functional_type_name: "owner_states_inactive"
      )

    change = %{owner_state_id: new_state.id}

    {:ok, test_owner} =
      MsbmsSystInstanceMgr.create_owner(
        "owner_create_4",
        "Owner Change Owner State Test",
        default_owner_state.id
      )

    assert {:ok,
            %MsbmsSystInstanceMgr.Data.SystOwners{
              owner_state_id: updated_id
            }} = MsbmsSystInstanceMgr.set_owner_values("owner_create_4", change)

    assert new_state.id == updated_id
  end

  test "Can Change Existing Owner Multiple Values" do
    default_owner_state = MsbmsSystEnums.get_default_enum_item("owner_states")

    new_state =
      MsbmsSystEnums.get_default_enum_item("owner_states",
        functional_type_name: "owner_states_inactive"
      )

    change = %{
      owner_state_id: new_state.id,
      internal_name: "owner_create_5_changed",
      display_name: "Owner Change Owner Multi Test Changed"
    }

    {:ok, test_owner} =
      MsbmsSystInstanceMgr.create_owner(
        "owner_create_5",
        "Owner Change Owner Multi Test",
        default_owner_state.id
      )

    assert {:ok, updated_owner} = MsbmsSystInstanceMgr.set_owner_values("owner_create_5", change)

    assert new_state.id == updated_owner.owner_state_id
    assert "owner_create_5_changed" == updated_owner.internal_name
    assert "Owner Change Owner Multi Test Changed" == updated_owner.display_name
  end

  test "Can Purge a Single Purge Eligible Owner" do
    default_owner_state =
      MsbmsSystEnums.get_default_enum_item("owner_states",
        functional_type_name: "owner_states_purge_eligible"
      )

    {:ok, test_owner} =
      MsbmsSystInstanceMgr.create_owner(
        "owner_purge_1",
        "Owner Purge Single Owner Test",
        default_owner_state.id
      )

    assert {:ok, {1, _rows}} = MsbmsSystInstanceMgr.purge_owner("owner_purge_1")
  end

  test "Cannot Purge a Single Ineligible Owner" do
    default_owner_state = MsbmsSystEnums.get_default_enum_item("owner_states")

    {:ok, test_owner} =
      MsbmsSystInstanceMgr.create_owner(
        "owner_purge_2",
        "Owner No Purge Single Owner Test",
        default_owner_state.id
      )

    assert {:error, _reason} = MsbmsSystInstanceMgr.purge_owner("owner_purge_2")
  end

  test "Can Purge a All Purge Eligible Owners" do
    default_owner_state =
      MsbmsSystEnums.get_default_enum_item("owner_states",
        functional_type_name: "owner_states_purge_eligible"
      )

    {:ok, _} =
      MsbmsSystInstanceMgr.create_owner(
        "owner_purge_3",
        "Owner Purge All Eligible Owners 1",
        default_owner_state.id
      )

    {:ok, _} =
      MsbmsSystInstanceMgr.create_owner(
        "owner_purge_4",
        "Owner Purge All Eligible Owners 2",
        default_owner_state.id
      )

    assert {:ok, {2, _rows}} = MsbmsSystInstanceMgr.purge_all_eligible_owners()

    # A second call should result in no deletions, but no error.  This test could
    # cause race conditions... keep an eye on if that concern is real.
    assert {:ok, {0, _rows}} = MsbmsSystInstanceMgr.purge_all_eligible_owners()
  end

  test "Can Get Owner by Internal Name" do
    assert {:ok, %MsbmsSystInstanceMgr.Data.SystOwners{internal_name: "owner_1"}} =
             MsbmsSystInstanceMgr.get_owner_by_name("owner_1")

    MsbmsSystInstanceMgr.get_owner_by_name("owner_1")
  end
end
