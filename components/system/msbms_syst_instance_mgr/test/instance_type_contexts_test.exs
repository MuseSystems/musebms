# Source File: instance_type_contexts_test.exs
# Location:    components/system/msbms_syst_instance_mgr/test/instance_type_contexts_test.exs
# Project:     msbms
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https: //muse.systems

defmodule InstanceTypeContextTest do
  use InstanceMgrTestCase, async: true

  test "Can Get Instance Type Contexts" do
    assert {:ok, [_ | _]} =
             MsbmsSystInstanceMgr.get_instance_type_contexts()
             |> IO.inspect()
  end

  test "Can Get Instance Type Contexts Filtered by Instance Type Name" do
    assert {:ok, instance_type_contexts} =
             MsbmsSystInstanceMgr.get_instance_type_contexts(
               instance_type_name: "instance_types_big"
             )

    Enum.each(instance_type_contexts, fn context ->
      assert context.instance_type.internal_name == "instance_types_big"
    end)
  end

  test "Can Get Instance Type Contexts Filtered by Instance Type ID" do
    {:ok, instance_type} = MsbmsSystInstanceMgr.get_instance_type_by_name("instance_types_sml")

    assert {:ok, instance_type_contexts} =
             MsbmsSystInstanceMgr.get_instance_type_contexts(instance_type_id: instance_type.id)

    Enum.each(instance_type_contexts, fn context ->
      assert context.instance_type.internal_name == "instance_types_sml"
    end)
  end

  test "Can Get Instance Type Contexts Combined Filters" do
    {:ok, instance_type} = MsbmsSystInstanceMgr.get_instance_type_by_name("instance_types_std")

    # These filters are redundant, but shouldn't prevent the test from running
    # successfully; except in the case where they contradict which should return
    # nothing... this is good test that both params are being added.
    assert {:ok, instance_type_contexts} =
             MsbmsSystInstanceMgr.get_instance_type_contexts(
               instance_type_id: instance_type.id,
               instance_type_name: "instance_types_std"
             )

    Enum.each(instance_type_contexts, fn context ->
      assert context.instance_type.internal_name == "instance_types_std"
    end)

    assert {:ok, []} =
             MsbmsSystInstanceMgr.get_instance_type_contexts(
               instance_type_id: instance_type.id,
               instance_type_name: "instance_types_big"
             )
  end

  test "Can Update Instance Type Context Default DB Pool Size" do
    {:ok, [instance_type_context | _]} =
      MsbmsSystInstanceMgr.get_instance_type_contexts(login_context: true)

    assert {:ok, updated_instance_type_context} =
             MsbmsSystInstanceMgr.set_instance_type_context_values(
               instance_type_context.id,
               instance_type_context.default_db_pool_size + 7
             )

    assert updated_instance_type_context.default_db_pool_size ==
             instance_type_context.default_db_pool_size + 7

    assert {:ok, updated_instance_type_context} =
             MsbmsSystInstanceMgr.set_instance_type_context_values(
               instance_type_context.id,
               instance_type_context.default_db_pool_size
             )

    assert updated_instance_type_context.default_db_pool_size ==
             instance_type_context.default_db_pool_size
  end

  test "Can Get Instance Type Context by ID" do
    {:ok, [instance_type_context | _]} =
      MsbmsSystInstanceMgr.get_instance_type_contexts(
        login_context: false,
        application_name: "app1"
      )

    assert {:ok, found_instance_type_context} =
             MsbmsSystInstanceMgr.get_instance_type_context_by_id(instance_type_context.id)

    assert found_instance_type_context.id == instance_type_context.id
  end
end
