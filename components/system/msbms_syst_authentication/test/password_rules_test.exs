# Source File: password_rules_test.exs
# Location:    musebms/components/system/msbms_syst_authentication/test/password_rules_test.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule PasswordRulesTest do
  use AuthenticationTestCase, async: true

  alias MsbmsSystAuthentication.Data
  alias MsbmsSystAuthentication.Impl

  alias MsbmsSystDatastore.DbTypes

  test "Can add Disallowed Password" do
    assert :ok = Impl.PasswordRules.create_disallowed_password("can_add_disallowed_password_test")

    # The attempt to add a duplicate entry should still return :ok even though
    # at the database level the insert is ignored (ON CONFLICT/DO NOTHING).

    assert :ok = Impl.PasswordRules.create_disallowed_password("can_add_disallowed_password_test")
  end

  test "Can test if password is disallowed" do
    assert {:ok, true} = Impl.PasswordRules.password_disallowed("Disallowed!Test#02")
    assert {:ok, false} = Impl.PasswordRules.password_disallowed("NotDisallowed!Test#02")
  end

  test "Can delete Disallowed Password once" do
    assert {:ok, :deleted} =
             Impl.PasswordRules.delete_disallowed_password("DeleteDisallowed!Test#02")

    assert {:ok, :no_record} =
             Impl.PasswordRules.delete_disallowed_password("DeleteDisallowed!Test#02")
  end

  test "Can retrieve Global Password Rules" do
    global_pwd_rules = Impl.PasswordRules.get_global_password_rules()

    assert %Data.SystGlobalPasswordRules{id: global_rule_id} = global_pwd_rules

    assert is_binary(global_rule_id)
  end

  test "Can update Global Password Rules" do
    # Note that changes here can influence other tests that might be running
    # concurrently.  This is OK and values in those other tests should be well
    # chosen to avoid conflicts with either set of password rules below.

    original_pwd_rules = Impl.PasswordRules.get_global_password_rules()

    update_params = %{
      password_length: %DbTypes.IntegerRange{
        lower: 9,
        upper: 150,
        lower_inclusive: true,
        upper_inclusive: true
      },
      max_age: %DbTypes.Interval{months: 12, days: 200, secs: 59, microsecs: 100},
      require_upper_case: 1,
      require_lower_case: 1,
      require_numbers: 1,
      require_symbols: 1,
      disallow_recently_used: 50,
      disallow_compromised: false,
      require_mfa: true,
      allowed_mfa_types: ["credential_types_secondary_totp"]
    }

    revert_params = %{
      password_length: original_pwd_rules.password_length,
      max_age: original_pwd_rules.max_age,
      require_upper_case: original_pwd_rules.require_upper_case,
      require_lower_case: original_pwd_rules.require_lower_case,
      require_numbers: original_pwd_rules.require_numbers,
      require_symbols: original_pwd_rules.require_symbols,
      disallow_recently_used: original_pwd_rules.disallow_recently_used,
      disallow_compromised: original_pwd_rules.disallow_compromised,
      require_mfa: original_pwd_rules.require_mfa,
      allowed_mfa_types: original_pwd_rules.allowed_mfa_types
    }

    updated_pwd_rules = Impl.PasswordRules.update_global_password_rules(update_params)
    _ = Impl.PasswordRules.update_global_password_rules(revert_params)

    assert :eq = DbTypes.compare(update_params.password_length, updated_pwd_rules.password_length)
    assert :eq = DbTypes.compare(update_params.max_age, updated_pwd_rules.max_age)
    assert update_params.require_upper_case == updated_pwd_rules.require_upper_case
    assert update_params.require_lower_case == updated_pwd_rules.require_lower_case
    assert update_params.require_numbers == updated_pwd_rules.require_numbers
    assert update_params.require_symbols == updated_pwd_rules.require_symbols
    assert update_params.disallow_recently_used == updated_pwd_rules.disallow_recently_used
    assert update_params.disallow_compromised == updated_pwd_rules.disallow_compromised
    assert update_params.require_mfa == updated_pwd_rules.require_mfa

    assert MapSet.equal?(
             MapSet.new(update_params.allowed_mfa_types),
             MapSet.new(updated_pwd_rules.allowed_mfa_types)
           )
  end

  test "Can create Owner Password Rules" do
    {:ok, owner_id} = MsbmsSystInstanceMgr.get_owner_id_by_name("owner4")

    insert_params = %{
      password_length: %DbTypes.IntegerRange{
        lower: 12,
        upper: 256,
        lower_inclusive: true,
        upper_inclusive: true
      },
      max_age: %DbTypes.Interval{months: 12},
      require_upper_case: 1,
      require_lower_case: 1,
      require_numbers: 1,
      require_symbols: 1,
      disallow_recently_used: 50,
      disallow_compromised: false,
      require_mfa: true,
      allowed_mfa_types: ["credential_types_secondary_totp"]
    }

    assert {:ok, new_pwd_rules} =
             Impl.PasswordRules.create_password_rules(owner_id, insert_params)

    assert :eq = DbTypes.compare(insert_params.password_length, new_pwd_rules.password_length)
    assert :eq = DbTypes.compare(insert_params.max_age, new_pwd_rules.max_age)
    assert insert_params.require_upper_case == new_pwd_rules.require_upper_case
    assert insert_params.require_lower_case == new_pwd_rules.require_lower_case
    assert insert_params.require_numbers == new_pwd_rules.require_numbers
    assert insert_params.require_symbols == new_pwd_rules.require_symbols
    assert insert_params.disallow_recently_used == new_pwd_rules.disallow_recently_used

    assert false == new_pwd_rules.disallow_compromised

    assert insert_params.require_mfa == new_pwd_rules.require_mfa

    assert MapSet.equal?(
             MapSet.new(insert_params.allowed_mfa_types),
             MapSet.new(new_pwd_rules.allowed_mfa_types)
           )
  end

  test "Can retrieve Owner Password Rules" do
    {:ok, owner_id} = MsbmsSystInstanceMgr.get_owner_id_by_name("owner1")

    assert %Data.SystOwnerPasswordRules{id: rule_id, owner_id: rule_owner_id} =
             Impl.PasswordRules.get_password_rules(owner_id)

    assert owner_id == rule_owner_id
    assert is_binary(rule_id)
  end

  test "Can update Owner Password Rules" do
    # Note that changes here can influence other tests that might be running
    # concurrently.  This is OK and values in those other tests should be well
    # chosen to avoid conflicts with either set of password rules below.

    {:ok, owner_id} = MsbmsSystInstanceMgr.get_owner_id_by_name("owner2")

    original_pwd_rules = Impl.PasswordRules.get_password_rules(owner_id)

    update_params = %{
      password_length: %DbTypes.IntegerRange{
        lower: 8,
        upper: 128,
        lower_inclusive: true,
        upper_inclusive: true
      },
      max_age: %DbTypes.Interval{months: 12, days: 200, secs: 59, microsecs: 100},
      require_upper_case: 1,
      require_lower_case: 1,
      require_numbers: 1,
      require_symbols: 1,
      disallow_recently_used: 50,
      disallow_compromised: false,
      require_mfa: true,
      allowed_mfa_types: ["credential_types_secondary_totp"]
    }

    revert_params = %{
      password_length: original_pwd_rules.password_length,
      max_age: original_pwd_rules.max_age,
      require_upper_case: original_pwd_rules.require_upper_case,
      require_lower_case: original_pwd_rules.require_lower_case,
      require_numbers: original_pwd_rules.require_numbers,
      require_symbols: original_pwd_rules.require_symbols,
      disallow_recently_used: original_pwd_rules.disallow_recently_used,
      disallow_compromised: original_pwd_rules.disallow_compromised,
      require_mfa: original_pwd_rules.require_mfa,
      allowed_mfa_types: original_pwd_rules.allowed_mfa_types
    }

    updated_pwd_rules = Impl.PasswordRules.update_password_rules(owner_id, update_params)
    _ = Impl.PasswordRules.update_password_rules(owner_id, revert_params)

    assert :eq = DbTypes.compare(update_params.password_length, updated_pwd_rules.password_length)
    assert :eq = DbTypes.compare(update_params.max_age, updated_pwd_rules.max_age)
    assert update_params.require_upper_case == updated_pwd_rules.require_upper_case
    assert update_params.require_lower_case == updated_pwd_rules.require_lower_case
    assert update_params.require_numbers == updated_pwd_rules.require_numbers
    assert update_params.require_symbols == updated_pwd_rules.require_symbols
    assert update_params.disallow_recently_used == updated_pwd_rules.disallow_recently_used
    assert update_params.disallow_compromised == updated_pwd_rules.disallow_compromised
    assert update_params.require_mfa == updated_pwd_rules.require_mfa

    assert MapSet.equal?(
             MapSet.new(update_params.allowed_mfa_types),
             MapSet.new(updated_pwd_rules.allowed_mfa_types)
           )
  end

  test "Can delete Owner Password Rules" do
    {:ok, owner_id} = MsbmsSystInstanceMgr.get_owner_id_by_name("owner3")

    assert :ok = Impl.PasswordRules.delete_password_rules(owner_id)

    assert nil == Impl.PasswordRules.get_password_rules(owner_id)
  end

  test "Can get Access Account effective Password Rules" do
    {:ok, access_account_id} =
      Impl.AccessAccount.get_access_account_id_by_name("owned_all_access")

    effective_pwd_rules = Impl.PasswordRules.get_access_account_password_rule(access_account_id)

    assert %{password_length: pwd_length} = effective_pwd_rules

    # Can't weaken global rules, so even though the owner rule defines a minimum
    # password length of 6, the global minimum of 8 characters will apply.  This
    # holds for the disallowed_compromised as well which is owner defined as
    # false, but globally defined as true (`true` is the stronger value).

    assert :eq ==
             DbTypes.compare(pwd_length, %DbTypes.IntegerRange{
               lower: 8,
               upper: 1024,
               lower_inclusive: true,
               upper_inclusive: true
             })

    assert %{disallow_compromised: true} = effective_pwd_rules
  end
end
