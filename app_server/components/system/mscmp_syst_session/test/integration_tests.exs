# Source File: integration_tests.exs
# Location:    musebms/app_server/components/system/mscmp_syst_session/test/integration_tests.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule IntegrationTests do
  use SessionTestCase, async: false

  import Ecto.Query

  alias MscmpSystDb.DbTypes

  @moduletag :integration
  @moduletag :capture_log

  # ==============================================================================================
  #
  # Topic 1: Non-expired Sessions
  #
  # ==============================================================================================

  test "Step 1.01: Non-expired Session Processing." do
    assert {:ok, session_name} =
             MscmpSystSession.create_session(%{test_key1: "test_value", test_key2: 1234})

    assert {:ok, %{"test_key1" => "test_value", "test_key2" => 1234}} =
             MscmpSystSession.get_session(session_name, 4600)

    assert :ok = MscmpSystSession.update_session(session_name, %{updated_key: "updated_value"})

    assert {:ok, %{"updated_key" => "updated_value"}} =
             MscmpSystSession.get_session(session_name, 4600)

    assert MscmpSystDb.exists?(Msdata.SystSessions) == true

    assert :ok = MscmpSystSession.delete_session(session_name)

    assert MscmpSystDb.exists?(Msdata.SystSessions) == false
  end

  # ==============================================================================================
  #
  # Topic 2: Expired Sessions
  #
  # ==============================================================================================

  test "Step 2.01: Get Expired Session" do
    {:ok, session_name} = MscmpSystSession.create_session(%{key: "value"}, 0)

    Process.sleep(1000)

    assert {:ok, :not_found} = MscmpSystSession.get_session(session_name)
  end

  test "Step 2.02: Update Expired Session" do
    {:ok, session_name} = MscmpSystSession.create_session(%{key: "value"}, 0)

    Process.sleep(1000)

    assert {:ok, :not_found} =
             MscmpSystSession.update_session(session_name, %{updated_key: "updated_value"})
  end

  test "Step 2.03: Delete Expired Session" do
    {:ok, session_name} = MscmpSystSession.create_session(%{key: "value"}, 0)

    Process.sleep(1000)

    assert :ok = MscmpSystSession.delete_session(session_name)
  end

  # ==============================================================================================
  #
  # Topic 3: Purge Sessions
  #
  # ==============================================================================================

  test "Step 3.01: Purge Sessions" do
    {:ok, _} = MscmpSystSession.create_session(%{key: "value"}, 0)

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
