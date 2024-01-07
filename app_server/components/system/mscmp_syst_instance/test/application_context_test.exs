# Source File: application_context_test.exs
# Location:    musebms/components/system/mscmp_syst_instance/test/application_context_test.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule ApplicationContextTest do
  use InstanceMgrTestCase, async: true

  alias MscmpSystInstance.Impl

  @moduletag :unit
  @moduletag :capture_log

  test "Can create an Application Context record" do
    owner_context_params = %{
      internal_name: "app3_owner",
      display_name: "App 3 owner",
      application_name: "app3",
      description: "App 3 Owner Description",
      start_context: false,
      login_context: false,
      database_owner_context: true
    }

    assert {:ok, owner_context} =
             Impl.ApplicationContexts.create_application_context(owner_context_params)

    assert owner_context.internal_name == owner_context_params.internal_name
    assert owner_context.display_name == owner_context_params.display_name
    assert owner_context.description == owner_context_params.description
    assert owner_context.start_context == owner_context_params.start_context
    assert owner_context.login_context == owner_context_params.login_context
    assert owner_context.database_owner_context == owner_context_params.database_owner_context

    app_id = Impl.Application.get_application_id_by_name("app3")

    owner_context_params = %{
      internal_name: "app3_ctx1",
      display_name: "App 3 Ctx1",
      application_id: app_id,
      description: "App 3 Context 1 Description",
      start_context: true,
      login_context: true,
      database_owner_context: false
    }

    assert {:ok, owner_context} =
             Impl.ApplicationContexts.create_application_context(owner_context_params)

    assert owner_context.internal_name == owner_context_params.internal_name
    assert owner_context.display_name == owner_context_params.display_name
    assert owner_context.description == owner_context_params.description
    assert owner_context.start_context == owner_context_params.start_context
    assert owner_context.login_context == owner_context_params.login_context
    assert owner_context.database_owner_context == owner_context_params.database_owner_context
  end

  test "Can get Application Context ID by Name" do
    assert app_context_id =
             Impl.ApplicationContexts.get_application_context_id_by_name("app1_appusr")

    assert is_binary(app_context_id)

    assert nil ==
             Impl.ApplicationContexts.get_application_context_id_by_name("nonexistent_context")
  end

  test "Can update an Application Context record" do
    upd1_params = %{
      display_name: "Updated App 3 UptCtx",
      description: "Updated App 3 Update",
      start_context: false
    }

    app_context_id = Impl.ApplicationContexts.get_application_context_id_by_name("app3_uptctx")

    assert {:ok, upd1_context} =
             Impl.ApplicationContexts.update_application_context(app_context_id, upd1_params)

    assert upd1_params.display_name == upd1_context.display_name
    assert upd1_params.description == upd1_context.description
    assert upd1_params.start_context == upd1_context.start_context

    upd2_params = %{
      display_name: "Re-Updated App 3 UptCtx",
      description: "Re-Updated App 3 Update",
      start_context: true
    }

    assert {:ok, upd2_context} =
             Impl.ApplicationContexts.update_application_context(upd1_context, upd2_params)

    assert upd2_params.display_name == upd2_context.display_name
    assert upd2_params.description == upd2_context.description
    assert upd2_params.start_context == upd2_context.start_context
  end

  test "Can delete an Application Context record" do
    app_context_id = Impl.ApplicationContexts.get_application_context_id_by_name("app3_delctx")

    assert {:ok, :deleted} = Impl.ApplicationContexts.delete_application_context(app_context_id)
    assert {:ok, :not_found} = Impl.ApplicationContexts.delete_application_context(app_context_id)
  end

  test "Can list Application Context records" do
    app_id = Impl.Application.get_application_id_by_name("app2")

    assert {:ok, filtered_contexts} = Impl.ApplicationContexts.list_application_contexts(app_id)
    assert [%Msdata.SystApplicationContexts{} | _] = filtered_contexts

    assert :ok = Enum.each(filtered_contexts, &assert(&1.application_id == app_id))

    assert {:ok, unfiltered_contexts} = Impl.ApplicationContexts.list_application_contexts(nil)
    assert [%Msdata.SystApplicationContexts{} | _] = unfiltered_contexts

    assert length(filtered_contexts) < length(unfiltered_contexts)
  end
end
