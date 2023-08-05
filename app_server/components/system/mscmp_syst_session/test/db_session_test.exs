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

  import Ecto.Query

  alias MscmpSystSession.Impl

  @moduletag :capture_log

  test "Can generate Session Name" do
    session_name = Impl.DbSession.generate_session_name()

    assert String.length(session_name) == 16
  end

  test "Can create new Session with defaults" do
    assert {:ok, _} = Impl.DbSession.create_session(%{new_key: "new_value"}, [])
  end

  test "Can create new Session with custom name" do
    assert {:ok, _} =
             Impl.DbSession.create_session(%{new_key: "new_value"},
               session_name: "create_session_test"
             )

    found =
      from(s in Msdata.SystSessions, where: s.internal_name == "create_session_test")
      |> MscmpSystDb.exists?()

    assert found == true
  end

  test "Can create Session with custom expires after" do
    current_timestamp = DateTime.utc_now()
    expires_secs = :rand.uniform(10_000)

    a_little_before =
      DateTime.add(current_timestamp, expires_secs - 5) |> DateTime.truncate(:second)

    a_little_after =
      DateTime.add(current_timestamp, expires_secs + 5) |> DateTime.truncate(:second)

    assert {:ok, session_name} =
             Impl.DbSession.create_session(%{new_key: "new_value"}, expires_after: expires_secs)

    session =
      from(s in Msdata.SystSessions, where: s.internal_name == ^session_name)
      |> MscmpSystDb.one!()

    assert DateTime.compare(a_little_before, session.session_expires) in [:lt, :eq]
    assert DateTime.compare(a_little_after, session.session_expires) in [:gt, :eq]
  end

  test "Can update existing Session with defaults" do
    assert :ok =
             Impl.DbSession.update_session("update_session", %{updated_key: "updated_value"}, [])
  end

  test "Can update existing Session with custom expires after" do
    current_timestamp = DateTime.utc_now()
    expires_secs = :rand.uniform(10_000)

    a_little_before =
      DateTime.add(current_timestamp, expires_secs - 5) |> DateTime.truncate(:second)

    a_little_after =
      DateTime.add(current_timestamp, expires_secs + 5) |> DateTime.truncate(:second)

    assert :ok =
             Impl.DbSession.update_session("update_session_date", %{updated_key: "updated_value"},
               expires_after: expires_secs
             )

    session =
      from(s in Msdata.SystSessions, where: s.internal_name == "update_session_date")
      |> MscmpSystDb.one!()

    assert DateTime.compare(a_little_before, session.session_expires) in [:lt, :eq]
    assert DateTime.compare(a_little_after, session.session_expires) in [:gt, :eq]
  end

  test "Cannot update expired Session" do
    assert {:ok, :not_found} =
             Impl.DbSession.update_session("expired_session", %{updated: "updated"}, [])
  end

  test "Can get existing Session data with defaults" do
    assert {:ok, %{"test_key" => "test_value"}} = Impl.DbSession.get_session("get_session", [])
  end

  test "Can get existing Session data with custom expires after" do
    current_timestamp = DateTime.utc_now()
    expires_secs = :rand.uniform(10_000)

    a_little_before =
      DateTime.add(current_timestamp, expires_secs - 5) |> DateTime.truncate(:second)

    a_little_after =
      DateTime.add(current_timestamp, expires_secs + 5) |> DateTime.truncate(:second)

    assert {:ok, %{"test_key" => "test_value"}} =
             Impl.DbSession.get_session("get_session", expires_after: expires_secs)

    session =
      from(s in Msdata.SystSessions, where: s.internal_name == "get_session")
      |> MscmpSystDb.one!()

    assert DateTime.compare(a_little_before, session.session_expires) in [:lt, :eq]
    assert DateTime.compare(a_little_after, session.session_expires) in [:gt, :eq]
  end

  test "Can refresh Session expiration date with defaults" do
    assert :ok = Impl.DbSession.refresh_session_expiration("get_session", [])
  end

  test "Can refresh Session expiration date with custom expires after" do
    current_timestamp = DateTime.utc_now()
    expires_secs = :rand.uniform(10_000)

    a_little_before =
      DateTime.add(current_timestamp, expires_secs - 5) |> DateTime.truncate(:second)

    a_little_after =
      DateTime.add(current_timestamp, expires_secs + 5) |> DateTime.truncate(:second)

    assert :ok =
             Impl.DbSession.refresh_session_expiration("get_session", expires_after: expires_secs)

    session =
      from(s in Msdata.SystSessions, where: s.internal_name == "get_session")
      |> MscmpSystDb.one!()

    assert DateTime.compare(a_little_before, session.session_expires) in [:lt, :eq]
    assert DateTime.compare(a_little_after, session.session_expires) in [:gt, :eq]
  end

  test "Cannot refresh Session expiration date" do
    assert {:ok, :not_found} = Impl.DbSession.refresh_session_expiration("expired_session", [])
  end

  test "Cannot get expired Session" do
    assert {:ok, :not_found} = Impl.DbSession.get_session("expired_session", [])
  end

  test "Can delete existing Session" do
    assert :ok = Impl.DbSession.delete_session("delete_session")
  end

  test "Can delete expired Session" do
    assert :ok = Impl.DbSession.delete_session("delete_expired_session")
  end
end
