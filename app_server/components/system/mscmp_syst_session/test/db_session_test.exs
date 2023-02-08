# Source File: db_session_test.exs
# Location:    musebms/app_server/components/system/mscmp_syst_session/test/db_session_test.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule DbSessionTest do
  use SessionTestCase, async: true

  alias MscmpSystSession.Impl

  @moduletag :capture_log

  test "Can create new Session" do
    assert {:ok, _} = Impl.DbSession.create_session(%{new_key: "new_value"}, 3600)
  end

  test "Can update existing Session" do
    assert :ok =
             Impl.DbSession.update_session(
               "update_session",
               %{updated_key: "updated_value"},
               3600
             )
  end

  test "Cannot update expired Session" do
    assert {:ok, :not_found} =
             Impl.DbSession.update_session("expired_session", %{updated: "updated"}, 3600)
  end

  test "Can get existing Session data" do
    assert {:ok, %{"test_key" => "test_value"}} = Impl.DbSession.get_session("get_session", 3600)
  end

  test "Can refresh Session expiration date" do
    assert :ok = Impl.DbSession.refresh_session_expiration("get_session", 36000)
  end

  test "Cannot refresh Session expiration date" do
    assert {:ok, :not_found} = Impl.DbSession.refresh_session_expiration("expired_session", 36000)
  end

  test "Cannot get expired Session" do
    assert {:ok, :not_found} = Impl.DbSession.get_session("expired_session", 3600)
  end

  test "Can delete existing Session" do
    assert :ok = Impl.DbSession.delete_session("delete_session")
  end

  test "Can delete expired Session" do
    assert :ok = Impl.DbSession.delete_session("delete_expired_session")
  end
end
