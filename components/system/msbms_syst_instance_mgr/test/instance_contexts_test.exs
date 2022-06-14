# Source File: instance_contexts_test.exs
# Location:    components/system/msbms_syst_instance_mgr/test/instance_contexts_test.exs
# Project:     msbms
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https: //muse.systems

defmodule InstanceContextsTest do
  use InstanceMgrTestCase, async: true

  test "Can Get Instance Contexts" do
    assert {:ok, [_ | _]} = MsbmsSystInstanceMgr.list_instance_contexts()
  end

  test "Can Get Instance Contexts Filtered by instance_id" do
    {:ok, [instance | _]} = MsbmsSystInstanceMgr.list_instances()

    assert {:ok, contexts} =
             MsbmsSystInstanceMgr.list_instance_contexts(instance_id: instance.instance_id)

    Enum.each(contexts, fn context ->
      assert context.instance_id == instance.instance_id
    end)
  end

  test "Can Get Instance Contexts Filtered by instance_name" do
    {:ok, [instance | _]} = MsbmsSystInstanceMgr.list_instances()

    assert {:ok, contexts} =
             MsbmsSystInstanceMgr.list_instance_contexts(
               instance_name: instance.instance_internal_name
             )

    Enum.each(contexts, fn context ->
      assert context.instance.internal_name == instance.instance_internal_name
    end)
  end

  test "Can Get Instance Contexts Filtered by owner_id" do
    {:ok, [owner | _]} = MsbmsSystInstanceMgr.list_owners()

    assert {:ok, contexts} = MsbmsSystInstanceMgr.list_instance_contexts(owner_id: owner.owner_id)

    Enum.each(contexts, fn context ->
      assert context.instance.owner_id == owner.owner_id
    end)
  end

  test "Can Get Instance Contexts Filtered by owner_name" do
    {:ok, [owner | _]} = MsbmsSystInstanceMgr.list_owners()

    assert {:ok, contexts} =
             MsbmsSystInstanceMgr.list_instance_contexts(owner_name: owner.owner_internal_name)

    Enum.each(contexts, fn context ->
      assert context.instance.owner_id == owner.owner_id
    end)
  end

  test "Can Get Instance Contexts Filtered by application_id" do
    {:ok, [application | _]} = MsbmsSystInstanceMgr.list_applications()

    assert {:ok, contexts} =
             MsbmsSystInstanceMgr.list_instance_contexts(application_id: application.id)

    Enum.each(contexts, fn context ->
      assert context.instance.application_id == application.id
    end)
  end

  test "Can Get Instance Contexts Filtered by application_name" do
    {:ok, [application | _]} = MsbmsSystInstanceMgr.list_applications()

    assert {:ok, contexts} =
             MsbmsSystInstanceMgr.list_instance_contexts(
               application_name: application.internal_name
             )

    Enum.each(contexts, fn context ->
      assert context.instance.application_id == application.id
    end)
  end

  test "Can Get Instance Contexts Filtered by start_context" do
    assert {:ok, contexts} = MsbmsSystInstanceMgr.list_instance_contexts(start_context: true)

    Enum.each(contexts, fn context ->
      assert context.application_context.start_context == true
    end)

    assert {:ok, contexts} = MsbmsSystInstanceMgr.list_instance_contexts(start_context: false)

    Enum.each(contexts, fn context ->
      assert context.application_context.start_context == false
    end)
  end

  test "Can Get Instance Contexts Filtered by database_owner_context" do
    assert {:ok, contexts} =
             MsbmsSystInstanceMgr.list_instance_contexts(database_owner_context: true)

    Enum.each(contexts, fn context ->
      assert context.application_context.database_owner_context == true
    end)

    assert {:ok, contexts} =
             MsbmsSystInstanceMgr.list_instance_contexts(database_owner_context: false)

    Enum.each(contexts, fn context ->
      assert context.application_context.database_owner_context == false
    end)
  end

  test "Can Get Instance Contexts Filtered by login_context" do
    assert {:ok, contexts} = MsbmsSystInstanceMgr.list_instance_contexts(login_context: true)

    Enum.each(contexts, fn context ->
      assert context.application_context.login_context == true
    end)

    assert {:ok, contexts} = MsbmsSystInstanceMgr.list_instance_contexts(login_context: false)

    Enum.each(contexts, fn context ->
      assert context.application_context.login_context == false
    end)
  end

  test "Can Update Instance Context Values" do
    {:ok, [instance_context | _]} =
      MsbmsSystInstanceMgr.list_instance_contexts(login_context: true)

    assert {:ok, new_instance_context} =
             MsbmsSystInstanceMgr.set_instance_context_values(
               instance_context.id,
               %{
                 start_context: !instance_context.start_context,
                 db_pool_size: instance_context.db_pool_size + 9,
                 context_code: "testing update code"
               }
             )

    assert new_instance_context.start_context == !instance_context.start_context
    assert new_instance_context.db_pool_size == instance_context.db_pool_size + 9
    assert "testing update code" == new_instance_context.context_code

    assert {:ok, new_instance_context} =
             MsbmsSystInstanceMgr.set_instance_context_values(
               instance_context.id,
               %{
                 start_context: instance_context.start_context,
                 db_pool_size: instance_context.db_pool_size,
                 context_code: instance_context.context_code
               }
             )

    assert new_instance_context.start_context == instance_context.start_context
    assert new_instance_context.db_pool_size == instance_context.db_pool_size
    assert new_instance_context.context_code == instance_context.context_code
  end
end
