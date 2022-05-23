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

  test "Can Create Simple Instance" do
    new_instance_params = %{
      internal_name: "create_simple_instance",
      display_name: "Create Simple Instance",
      application_name: "test_app_1",
      owner_name: "owner_1"
    }

    assert {:ok, _new_instance} = MsbmsSystInstanceMgr.create_instance(new_instance_params)
  end

  test "Can Create Complex Instance" do
    new_instance_params = %{
      internal_name: "create_complex_instance",
      display_name: "Create Complex Instance",
      application_name: "test_app_2",
      owner_name: "owner_2",
      instance_type_name: "instance_types_sml_instance",
      instance_state_name: "instance_states_sysdef_inactive",
      owning_instance_name: "test_instance_5",
      instance_options: %{
        "dbserver_name" => "instance_db",
        "datastore_contexts" => [
          %{
            "application_context" => "test_datastore_context_1",
            "db_pool_size" => 10
          },
          %{
            "application_context" => "extra_context",
            "db_pool_size" => 10
          }
        ]
      }
    }

    assert {:ok, new_instance} = MsbmsSystInstanceMgr.create_instance(new_instance_params)
    assert %{instance_options: %{"datastore_contexts" => contexts}} = new_instance

    assert %{"db_pool_size" => 10} =
             Enum.find(contexts, &(&1["application_context"] == "test_datastore_context_1"))

    assert %{"db_pool_size" => 3} =
             Enum.find(contexts, &(&1["application_context"] == "test_datastore_context_2"))
  end

  test "Can Modify Instance Values" do
    updated_values = %{
      display_name: "Updated Display Name"
    }
  end
end
