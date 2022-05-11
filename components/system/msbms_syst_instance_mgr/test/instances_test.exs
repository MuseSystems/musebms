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

  test "Can Get Unfiltered/Unsorted Instances List" do
    assert {:ok, instances_list} = MsbmsSystInstanceMgr.list_instances()

    assert is_list(instances_list)
  end

  test "Can Filter Instances List by Instance Types" do
    assert {:ok, instances_list} =
             MsbmsSystInstanceMgr.list_instances(instance_types: ["instance_types_big_instance"])

    assert Enum.reduce(instances_list, true, fn instance, acc ->
             instance.instance_type_display_name == "Instance Types / Big Instance" and acc
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
    {:ok, test_owner} = MsbmsSystInstanceMgr.get_owner_by_name("owner_3")

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
    assert {:ok, instances_list} =
             MsbmsSystInstanceMgr.list_instances(applications: ["test_app_1"])

    assert Enum.reduce(instances_list, true, fn instance, acc ->
             instance.application_display_name == "Test App 1" and acc
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
    assert {:ok, %MsbmsSystInstanceMgr.Data.SystInstances{internal_name: "test_instance_1"}} =
             MsbmsSystInstanceMgr.get_instance_by_name("test_instance_1")
  end
end
