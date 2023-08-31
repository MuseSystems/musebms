# Source File: integration_test.exs
# Location:    musebms/app_server/components/system/mscmp_syst_session/test/integration_test.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule IntegrationTest do
  use SessionTestCase, async: false

  import Ecto.Query

  @moduletag :integration
  @moduletag :capture_log

  # ==============================================================================================
  #
  # Topic 1: Non-expired Sessions
  #
  # ==============================================================================================

  test "Step 1.01: Non-Expired / Random Name Session Processing." do
    assert {:ok, session_name} =
             MscmpSystSession.create_session(%{test_key1: "test_value", test_key2: 1234})

    assert {:ok, %{"test_key1" => "test_value", "test_key2" => 1234}} =
             MscmpSystSession.get_session(session_name, expires_after: 4600)

    assert :ok = MscmpSystSession.update_session(session_name, %{updated_key: "updated_value"})

    assert {:ok, %{"updated_key" => "updated_value"}} =
             MscmpSystSession.get_session(session_name, expires_after: 4600)

    assert MscmpSystDb.exists?(Msdata.SystSessions) == true

    assert :ok = MscmpSystSession.delete_session(session_name)

    assert MscmpSystDb.exists?(Msdata.SystSessions) == false
  end

  test "Step 1.02: Non-Expired Create Session" do
    assert {:ok, "non_random_session_name"} =
             MscmpSystSession.create_session(%{test_key1: "test_value", test_key2: 1234},
               session_name: "non_random_session_name"
             )
  end

  test "Step 1.03: Non-Expired Get Session" do
    assert {:ok, %{"test_key1" => "test_value", "test_key2" => 1234}} =
             MscmpSystSession.get_session("non_random_session_name", expires_after: 4600)
  end

  test "Step 1.04: Non-Expired Update Session" do
    assert :ok =
             MscmpSystSession.update_session("non_random_session_name", %{
               updated_key: "updated_value"
             })

    assert {:ok, %{"updated_key" => "updated_value"}} =
             MscmpSystSession.get_session("non_random_session_name", expires_after: 4600)
  end

  test "Step 1.05: Non-Expired Delete Session" do
    assert MscmpSystDb.exists?(Msdata.SystSessions) == true

    assert :ok = MscmpSystSession.delete_session("non_random_session_name")

    assert MscmpSystDb.exists?(Msdata.SystSessions) == false
  end

  # ==============================================================================================
  #
  # Topic 2: Expired Sessions
  #
  # ==============================================================================================

  test "Step 2.01: Cannot Get Expired Session" do
    {:ok, session_name} = MscmpSystSession.create_session(%{key: "value"}, expires_after: 0)

    Process.sleep(1000)

    assert {:ok, :not_found} = MscmpSystSession.get_session(session_name)
  end

  test "Step 2.02: Cannot Update Expired Session" do
    {:ok, session_name} = MscmpSystSession.create_session(%{key: "value"}, expires_after: 0)

    Process.sleep(1000)

    assert {:ok, :not_found} =
             MscmpSystSession.update_session(session_name, %{updated_key: "updated_value"})
  end

  test "Step 2.03: Delete Expired Session" do
    {:ok, session_name} = MscmpSystSession.create_session(%{key: "value"}, expires_after: 0)

    Process.sleep(1000)

    assert :ok = MscmpSystSession.delete_session(session_name)
  end

  # ==============================================================================================
  #
  # Topic 3: Purge Sessions
  #
  # ==============================================================================================

  test "Step 3.01: Purge Sessions" do
    {:ok, _} = MscmpSystSession.create_session(%{key: "value"}, expires_after: 0)

    {:ok, _} = MscmpSystSession.create_session(%{key: "value"})

    Process.sleep(1000)

    count_query = from(s in Msdata.SystSessions, select: count(s.id))

    # Note that the Topic 2 testing may leave some expired records behind.
    # We shouldn't depend on that here for our test, but we need to be sure
    # we accommodate the possibility here.

    assert MscmpSystDb.one(count_query) >= 2

    assert :ok = MscmpSystSession.purge_expired_sessions()

    assert assert MscmpSystDb.one(count_query) == 1
  end
end
