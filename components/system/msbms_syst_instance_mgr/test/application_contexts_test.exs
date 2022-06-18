# Source File: application_contexts_test.exs
# Location:    components/system/msbms_syst_instance_mgr/test/application_contexts_test.exs
# Project:     msbms
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https: //muse.systems

defmodule ApplicationContextsTest do
  use InstanceMgrTestCase, async: true

  test "Can Get Application Context ID by Name" do
    application_context_id = MsbmsSystInstanceMgr.get_application_context_id_by_name("app1_owner")

    assert {:ok, _} = Ecto.UUID.cast(application_context_id)
  end

  test "Get Application Context ID by Name Fails Correctly" do
    catch_error(MsbmsSystInstanceMgr.get_application_context_id_by_name("non_existent_context"))
  end

  test "Can Get Application Context List" do
    assert {:ok, [_ | _]} = MsbmsSystInstanceMgr.list_application_contexts()
  end

  test "Can Get Application Contexts by Application Name with Extended Data" do
    assert {:ok, application_contexts} =
             MsbmsSystInstanceMgr.list_application_contexts(
               filters: [application_name: "app1"],
               extra_data: [:application]
             )

    Enum.each(application_contexts, fn context ->
      assert context.application.internal_name == "app1"
    end)
  end

  test "Can Get Application Contexts by Start Context" do
    assert {:ok, application_contexts} =
             MsbmsSystInstanceMgr.list_application_contexts(filters: [start_context: true])

    Enum.each(application_contexts, fn context ->
      assert true == context.start_context
    end)

    assert {:ok, application_contexts} =
             MsbmsSystInstanceMgr.list_application_contexts(filters: [start_context: false])

    Enum.each(application_contexts, fn context ->
      assert false == context.start_context
    end)
  end

  test "Can Get Application Contexts by Login Context" do
    assert {:ok, application_contexts} =
             MsbmsSystInstanceMgr.list_application_contexts(filters: [login_context: true])

    Enum.each(application_contexts, fn context ->
      assert true == context.login_context
    end)

    assert {:ok, application_contexts} =
             MsbmsSystInstanceMgr.list_application_contexts(filters: [login_context: false])

    Enum.each(application_contexts, fn context ->
      assert false == context.login_context
    end)
  end

  test "Can Get Application Contexts by Application ID" do
    {:ok, [application | _]} = MsbmsSystInstanceMgr.list_applications()

    assert {:ok, application_contexts} =
             MsbmsSystInstanceMgr.list_application_contexts(
               filters: [application_id: application.id]
             )

    Enum.each(application_contexts, fn context ->
      assert context.application_id == application.id
    end)
  end

  test "Can Get Application Contexts with Option Combo" do
    {:ok, [application | _]} = MsbmsSystInstanceMgr.list_applications()

    # Some parameters here are redundant, but should not be contradictory since
    # they are sourced from the same parent record. App owner contexts should 1)
    # always exist; and 2) should always be start_context = false and
    # login_context = false.
    assert {:ok, application_contexts} =
             MsbmsSystInstanceMgr.list_application_contexts(
               filters: [
                 application_id: application.id,
                 application_name: application.internal_name,
                 start_context: false,
                 login_context: false
               ]
             )

    Enum.each(application_contexts, fn context ->
      assert application.id == context.application.id
      assert application.internal_name == context.application.internal_name
      assert false == context.start_context
      assert false == context.login_context
    end)
  end

  test "Can Change Login Context Application Context Start Context" do
    {:ok, orig_application_context} =
      MsbmsSystInstanceMgr.get_application_context_by_name("app1_apiusr")

    assert {:ok, new_application_context} =
             MsbmsSystInstanceMgr.set_application_context_start_context(
               orig_application_context.id,
               !orig_application_context.start_context
             )

    assert new_application_context.start_context == !orig_application_context.start_context

    assert {:ok, new_application_context} =
             MsbmsSystInstanceMgr.set_application_context_start_context(
               orig_application_context.id,
               orig_application_context.start_context
             )

    assert new_application_context.start_context == orig_application_context.start_context
  end
end
