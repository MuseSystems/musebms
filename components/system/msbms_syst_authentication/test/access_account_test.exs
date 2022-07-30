# Source File: access_account_test.exs
# Location:    musebms/components/system/msbms_syst_authentication/test/access_account_test.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https: //muse.systems

defmodule AccessAccountTest do
  use AuthenticationTestCase, async: true

  alias MsbmsSystAuthentication.Data

  test "Can get Access Account ID by Name" do
    assert {:ok, access_account_id} =
             MsbmsSystAuthentication.get_access_account_id_by_name("accnt1")

    assert is_binary(access_account_id)
  end
end
