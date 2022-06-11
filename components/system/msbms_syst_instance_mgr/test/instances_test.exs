# Source File: instances_test.exs
# Location:    components/system/msbms_syst_instance_mgr/test/instances_test.exs
# Project:     msbms
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https: //muse.systems

defmodule InstancesTest do
  use InstanceMgrTestCase, async: true

  alias MsbmsSystInstanceMgr.Data

  test "Can Get Unfiltered/Unsorted Instances List" do
    assert {:ok, instances_list} = MsbmsSystInstanceMgr.list_instances()
    assert is_list(instances_list)
  end

  test "Can Filter Instances List by Instance Types" do
    assert {:ok, instances_list} =
             MsbmsSystInstanceMgr.list_instances(instance_types: ["instance_types_big"])

    assert Enum.reduce(instances_list, true, fn instance, acc ->
             instance.instance_type_display_name == "Instance Types / Big" and acc
           end)
  end

  test "Can Filter Instances List by Instance State Functional Types" do
    assert {:ok, instances_list} =
             MsbmsSystInstanceMgr.list_instances(
               instance_state_functional_types: [:instance_states_active]
             )

    assert Enum.reduce(instances_list, true, fn instance, acc ->
             instance.instance_state_functional_type_name == "instance_states_active" and acc
           end)
  end

  test "Can Filter Instances List by Owner" do
    {:ok, test_owner} = MsbmsSystInstanceMgr.get_owner_by_name("owner3")

    assert {:ok, instances_list} = MsbmsSystInstanceMgr.list_instances(owner_id: test_owner.id)

    assert Enum.reduce(instances_list, true, fn instance, acc ->
             instance.owner_id == test_owner.id and acc
           end)
  end

  test "Can Filter Instances List by Owner State Functional Types" do
    assert {:ok, instances_list} =
             MsbmsSystInstanceMgr.list_instances(
               owner_state_functional_types: [:owner_states_active]
             )

    assert Enum.reduce(instances_list, true, fn instance, acc ->
             instance.owner_state_functional_type_name == "owner_states_active" and acc
           end)
  end

  test "Can Filter Instances List by Applications" do
    assert {:ok, instances_list} = MsbmsSystInstanceMgr.list_instances(applications: ["app1"])

    assert Enum.reduce(instances_list, true, fn instance, acc ->
             instance.application_display_name == "App 1" and acc
           end)
  end

  test "Can Apply Application Sort to Instances List" do
    assert {:ok, instances_list} = MsbmsSystInstanceMgr.list_instances(sort: [:application])

    assert Enum.reduce(instances_list, {true, nil}, fn instance, acc ->
             {
               elem(acc, 0) and instance.application_display_name >= elem(acc, 1),
               instance.application_display_name
             }
           end)
  end

  test "Can Apply Owner Sort to Instances List" do
    assert {:ok, instances_list} = MsbmsSystInstanceMgr.list_instances(sort: [:owner])

    assert Enum.reduce(instances_list, {true, nil}, fn instance, acc ->
             {
               elem(acc, 0) and instance.owner_display_name >= elem(acc, 1),
               instance.owner_display_name
             }
           end)
  end

  test "Can Apply Instance Sort to Instances List" do
    assert {:ok, instances_list} = MsbmsSystInstanceMgr.list_instances(sort: [:instance])

    assert Enum.reduce(instances_list, {true, nil}, fn instance, acc ->
             {
               elem(acc, 0) and instance.instance_display_name >= elem(acc, 1),
               instance.instance_display_name
             }
           end)
  end

  test "Can Retrieve Single Instance" do
    assert {:ok,
            %MsbmsSystInstanceMgr.Data.SystInstances{
              internal_name: "app2_owner4_instance_types_big"
            }} = MsbmsSystInstanceMgr.get_instance_by_name("app2_owner4_instance_types_big")
  end

  test "Can Create Instance" do
    new_instance_params = %{
      internal_name: "create_complex_instance",
      display_name: "Create Complex Instance",
      application_name: "app2",
      owner_name: "owner2",
      instance_type_name: "instance_types_sml",
      instance_state_name: "instance_states_sysdef_inactive",
      owning_instance_name: "app2_owner2_instance_types_big",
      instance_code: :crypto.strong_rand_bytes(16)
    }

    assert {:ok, %Data.SystInstances{internal_name: "create_complex_instance"}} =
             MsbmsSystInstanceMgr.create_instance(new_instance_params)
  end

  test "Can Modify Instance Values" do
    update_values = %{
      display_name: "Updated Display Name"
    }

    assert {:ok, updated_instance} =
             MsbmsSystInstanceMgr.set_instance_values(
               "app2_owner4_instance_types_big",
               update_values
             )

    assert %{display_name: "Updated Display Name"} = updated_instance
  end

  test "Can Purge a Single Purge Eligible Instance" do
    {:ok, _test_instance} =
      MsbmsSystInstanceMgr.create_instance(%{
        internal_name: "delete_test",
        display_name: "Delete Instance Test",
        application_name: "app2",
        owner_name: "owner2",
        instance_type_name: "instance_types_sml",
        instance_state_name: "instance_states_sysdef_purge_eligible",
        instance_code: :crypto.strong_rand_bytes(16)
      })

    assert {:ok, {1, _rows}} = MsbmsSystInstanceMgr.purge_instance("delete_test")
  end

  test "Cannot Purge a Single Ineligible Instance" do
    {:ok, _test_instance} =
      MsbmsSystInstanceMgr.create_instance(%{
        internal_name: "no_delete_test",
        display_name: "Can't Delete Instance Test",
        application_name: "app2",
        owner_name: "owner2",
        instance_type_name: "instance_types_sml",
        instance_state_name: "instance_states_sysdef_active",
        instance_code: :crypto.strong_rand_bytes(16)
      })

    assert {:error, _reason} = MsbmsSystInstanceMgr.purge_instance("no_delete_test")
  end

  test "Can Purge a All Purge Eligible Owners" do
    default_owner_state =
      MsbmsSystEnums.get_default_enum_item("owner_states",
        functional_type_name: "owner_states_purge_eligible"
      )

    {:ok, _} =
      MsbmsSystInstanceMgr.create_owner(
        "ownerpurge_3",
        "Owner Purge All Eligible Owners 1",
        default_owner_state.id
      )

    {:ok, _} =
      MsbmsSystInstanceMgr.create_owner(
        "ownerpurge_4",
        "Owner Purge All Eligible Owners 2",
        default_owner_state.id
      )

    assert {:ok, {2, _rows}} = MsbmsSystInstanceMgr.purge_all_eligible_owners()

    # A second call should result in no deletions, but no error.  This test could
    # cause race conditions... keep an eye on if that concern is real.
    assert {:ok, {0, _rows}} = MsbmsSystInstanceMgr.purge_all_eligible_owners()
  end
end
