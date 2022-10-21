# Source File: disallowed_password_test.ex
# Location:    musebms/components/system/msbms_syst_authentication/test/disallowed_password_test.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule DisallowedPasswordTest do
  use AuthenticationTestCase, async: true

  alias MsbmsSystAuthentication.Impl

  test "Can add Disallowed Password" do
    assert :ok =
             Impl.DisallowedPasswords.add_disallowed_password("can_add_disallowed_password_test")

    # The attempt to add a duplicate entry should still return :ok even though
    # at the database level the insert is ignored (ON CONFLICT/DO NOTHING).

    assert :ok =
             Impl.DisallowedPasswords.add_disallowed_password("can_add_disallowed_password_test")
  end

  test "Can test if password is disallowed" do
    assert {:ok, true} = Impl.DisallowedPasswords.password_disallowed("Disallowed!Test#02")
    assert {:ok, false} = Impl.DisallowedPasswords.password_disallowed("NotDisallowed!Test#02")
  end

  test "Can delete Disallowed Password once" do
    assert {:ok, :deleted} =
             Impl.DisallowedPasswords.delete_disallowed_password("DeleteDisallowed!Test#02")

    assert {:ok, :no_record} =
             Impl.DisallowedPasswords.delete_disallowed_password("DeleteDisallowed!Test#02")
  end
end
