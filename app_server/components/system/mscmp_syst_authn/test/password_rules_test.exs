# Source File: password_rules_test.exs
# Location:    musebms/components/system/mscmp_syst_authn/test/password_rules_test.exs
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
  use AuthenticationTestCase, async: false

  import Ecto.Query

  alias MscmpSystAuthn.Impl

  alias MscmpSystDb.DbTypes

  @moduletag :capture_log

  test "Can add Disallowed Password" do
    assert :ok = Impl.PasswordRules.create_disallowed_password("can_add_disallowed_password_test")

    assert :ok =
             Impl.PasswordRules.create_disallowed_password!("can_add_disallowed_password_test_a")

    # The attempt to add a duplicate entry should still return :ok even though
    # at the database level the insert is ignored (ON CONFLICT/DO NOTHING).

    assert :ok = Impl.PasswordRules.create_disallowed_password("can_add_disallowed_password_test")

    assert :ok =
             Impl.PasswordRules.create_disallowed_password!("can_add_disallowed_password_test_a")
  end

  test "Can test if password is disallowed" do
    assert {:ok, true} = Impl.PasswordRules.password_disallowed("Disallowed!Test#02")
    assert {:ok, false} = Impl.PasswordRules.password_disallowed("NotDisallowed!Test#02")

    assert true == Impl.PasswordRules.password_disallowed?("Disallowed!Test#02")
    assert false == Impl.PasswordRules.password_disallowed?("NotDisallowed!Test#02")
  end

  test "Can delete Disallowed Password once" do
    assert {:ok, :deleted} =
             Impl.PasswordRules.delete_disallowed_password("DeleteDisallowed!Test#02")

    assert {:ok, :not_found} =
             Impl.PasswordRules.delete_disallowed_password("DeleteDisallowed!Test#02")

    assert :deleted = Impl.PasswordRules.delete_disallowed_password!("DeleteDisallowed!Test#02a")

    assert :not_found =
             Impl.PasswordRules.delete_disallowed_password!("DeleteDisallowed!Test#02a")
  end

  test "Can retrieve Global Password Rules" do
    {:ok, first_pwd_rules} = Impl.PasswordRules.get_global_password_rules()

    assert %Msdata.SystGlobalPasswordRules{id: first_rule_id} = first_pwd_rules

    assert is_binary(first_rule_id)

    second_pwd_rules = Impl.PasswordRules.get_global_password_rules!()

    assert %Msdata.SystGlobalPasswordRules{id: second_rule_id} = second_pwd_rules

    assert is_binary(second_rule_id)
  end

  test "Can update Global Password Rules / Success Tuple" do
    {:ok, original_pwd_rules} = Impl.PasswordRules.get_global_password_rules()

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

    {:ok, updated_pwd_rules} =
      Impl.PasswordRules.update_global_password_rules(original_pwd_rules, update_params)

    {:ok, revert_pwd_rules} = Impl.PasswordRules.update_global_password_rules(revert_params)

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

    assert :eq = DbTypes.compare(revert_params.password_length, revert_pwd_rules.password_length)
    assert :eq = DbTypes.compare(revert_params.max_age, revert_pwd_rules.max_age)
    assert revert_params.require_upper_case == revert_pwd_rules.require_upper_case
    assert revert_params.require_lower_case == revert_pwd_rules.require_lower_case
    assert revert_params.require_numbers == revert_pwd_rules.require_numbers
    assert revert_params.require_symbols == revert_pwd_rules.require_symbols
    assert revert_params.disallow_recently_used == revert_pwd_rules.disallow_recently_used
    assert revert_params.disallow_compromised == revert_pwd_rules.disallow_compromised
    assert revert_params.require_mfa == revert_pwd_rules.require_mfa

    assert MapSet.equal?(
             MapSet.new(revert_params.allowed_mfa_types),
             MapSet.new(revert_pwd_rules.allowed_mfa_types)
           )
  end

  test "Can update Global Password Rules / Raise on Error" do
    {:ok, original_pwd_rules} = Impl.PasswordRules.get_global_password_rules()

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

    updated_pwd_rules =
      Impl.PasswordRules.update_global_password_rules!(original_pwd_rules, update_params)

    revert_pwd_rules = Impl.PasswordRules.update_global_password_rules!(revert_params)

    assert :eq = DbTypes.compare(update_params.password_length, updated_pwd_rules.password_length)
    assert :eq = DbTypes.compare(update_params.max_age, updated_pwd_rules.max_age)
    assert update_params.require_upper_case == updated_pwd_rules.require_upper_case
    assert update_params.require_lower_case == updated_pwd_rules.require_lower_case
    assert update_params.require_numbers == updated_pwd_rules.require_numbers
    assert update_params.require_symbols == updated_pwd_rules.require_symbols
    assert update_params.disallow_recently_used == updated_pwd_rules.disallow_recently_used
    assert update_params.disallow_compromised == updated_pwd_rules.disallow_compromised
    assert update_params.require_mfa == updated_pwd_rules.require_mfa

    assert :eq = DbTypes.compare(revert_params.password_length, revert_pwd_rules.password_length)
    assert :eq = DbTypes.compare(revert_params.max_age, revert_pwd_rules.max_age)
    assert revert_params.require_upper_case == revert_pwd_rules.require_upper_case
    assert revert_params.require_lower_case == revert_pwd_rules.require_lower_case
    assert revert_params.require_numbers == revert_pwd_rules.require_numbers
    assert revert_params.require_symbols == revert_pwd_rules.require_symbols
    assert revert_params.disallow_recently_used == revert_pwd_rules.disallow_recently_used
    assert revert_params.disallow_compromised == revert_pwd_rules.disallow_compromised
    assert revert_params.require_mfa == revert_pwd_rules.require_mfa

    assert MapSet.equal?(
             MapSet.new(update_params.allowed_mfa_types),
             MapSet.new(updated_pwd_rules.allowed_mfa_types)
           )
  end

  test "Can create Owner Password Rules / Success Tuple" do
    {:ok, owner_id} = MscmpSystInstance.get_owner_id_by_name("owner4")

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
             Impl.PasswordRules.create_owner_password_rules(owner_id, insert_params)

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

    from(opwr in Msdata.SystOwnerPasswordRules, where: opwr.owner_id == ^owner_id)
    |> MscmpSystDb.delete_all()
  end

  test "Can create Owner Password Rules / Raise on Error" do
    {:ok, owner_id} = MscmpSystInstance.get_owner_id_by_name("owner4")

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

    assert new_pwd_rules =
             Impl.PasswordRules.create_owner_password_rules!(owner_id, insert_params)

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

    from(opwr in Msdata.SystOwnerPasswordRules, where: opwr.owner_id == ^owner_id)
    |> MscmpSystDb.delete_all()
  end

  test "Can retrieve Owner Password Rules" do
    {:ok, owner_id} = MscmpSystInstance.get_owner_id_by_name("owner1")

    assert {:ok, %Msdata.SystOwnerPasswordRules{id: rule_id, owner_id: rule_owner_id}} =
             Impl.PasswordRules.get_owner_password_rules(owner_id)

    assert owner_id == rule_owner_id
    assert is_binary(rule_id)
  end

  test "Can update Owner Password Rules / Success Tuple" do
    {:ok, owner_id} = MscmpSystInstance.get_owner_id_by_name("owner2")

    {:ok, original_pwd_rules} = Impl.PasswordRules.get_owner_password_rules(owner_id)

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

    {:ok, updated_pwd_rules} =
      Impl.PasswordRules.update_owner_password_rules(owner_id, update_params)

    {:ok, revert_pwd_rules} =
      Impl.PasswordRules.update_owner_password_rules(updated_pwd_rules, revert_params)

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

    assert :eq = DbTypes.compare(revert_params.password_length, revert_pwd_rules.password_length)
    assert :eq = DbTypes.compare(revert_params.max_age, revert_pwd_rules.max_age)
    assert revert_params.require_upper_case == revert_pwd_rules.require_upper_case
    assert revert_params.require_lower_case == revert_pwd_rules.require_lower_case
    assert revert_params.require_numbers == revert_pwd_rules.require_numbers
    assert revert_params.require_symbols == revert_pwd_rules.require_symbols
    assert revert_params.disallow_recently_used == revert_pwd_rules.disallow_recently_used
    assert revert_params.disallow_compromised == revert_pwd_rules.disallow_compromised
    assert revert_params.require_mfa == revert_pwd_rules.require_mfa

    assert MapSet.equal?(
             MapSet.new(revert_params.allowed_mfa_types),
             MapSet.new(revert_pwd_rules.allowed_mfa_types)
           )
  end

  test "Can update Owner Password Rules / Raise on Error" do
    {:ok, owner_id} = MscmpSystInstance.get_owner_id_by_name("owner2")

    {:ok, original_pwd_rules} = Impl.PasswordRules.get_owner_password_rules(owner_id)

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

    updated_pwd_rules = Impl.PasswordRules.update_owner_password_rules!(owner_id, update_params)
    revert_pwd_rules = Impl.PasswordRules.update_owner_password_rules!(owner_id, revert_params)

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

    assert :eq = DbTypes.compare(revert_params.password_length, revert_pwd_rules.password_length)
    assert :eq = DbTypes.compare(revert_params.max_age, revert_pwd_rules.max_age)
    assert revert_params.require_upper_case == revert_pwd_rules.require_upper_case
    assert revert_params.require_lower_case == revert_pwd_rules.require_lower_case
    assert revert_params.require_numbers == revert_pwd_rules.require_numbers
    assert revert_params.require_symbols == revert_pwd_rules.require_symbols
    assert revert_params.disallow_recently_used == revert_pwd_rules.disallow_recently_used
    assert revert_params.disallow_compromised == revert_pwd_rules.disallow_compromised
    assert revert_params.require_mfa == revert_pwd_rules.require_mfa

    assert MapSet.equal?(
             MapSet.new(revert_params.allowed_mfa_types),
             MapSet.new(revert_pwd_rules.allowed_mfa_types)
           )
  end

  test "Can delete Owner Password Rules" do
    {:ok, owner_id} = MscmpSystInstance.get_owner_id_by_name("owner3")

    assert {:ok, :deleted} = Impl.PasswordRules.delete_owner_password_rules(owner_id)

    assert {:ok, :not_found} = Impl.PasswordRules.delete_owner_password_rules(owner_id)

    assert :not_found = Impl.PasswordRules.get_owner_password_rules!(owner_id)

    {:ok, owner_id} = MscmpSystInstance.get_owner_id_by_name("owner5")

    assert :deleted = Impl.PasswordRules.delete_owner_password_rules!(owner_id)

    assert :not_found = Impl.PasswordRules.delete_owner_password_rules!(owner_id)

    assert :not_found = Impl.PasswordRules.get_owner_password_rules!(owner_id)
  end

  test "Can get Access Account effective Password Rules / Success Tuple" do
    {:ok, access_account_id} =
      Impl.AccessAccount.get_access_account_id_by_name("owned_all_access")

    assert {:ok, effective_pwd_rules} =
             Impl.PasswordRules.get_access_account_password_rule(access_account_id)

    assert %{password_length: pwd_length} = effective_pwd_rules

    # Can't weaken global rules, so even though the owner rule defines a minimum
    # password length of 6, the global minimum of 8 characters will apply.  This
    # holds for the disallowed_compromised as well which is owner defined as
    # false, but globally defined as true (`true` is the stronger value).

    assert :eq =
             DbTypes.compare(pwd_length, %DbTypes.IntegerRange{
               lower: 8,
               upper: 1024,
               lower_inclusive: true,
               upper_inclusive: true
             })

    assert %{disallow_compromised: true} = effective_pwd_rules
  end

  test "Can get Access Account effective Password Rules / Raise on Error" do
    {:ok, access_account_id} =
      Impl.AccessAccount.get_access_account_id_by_name("owned_all_access")

    assert effective_pwd_rules =
             Impl.PasswordRules.get_access_account_password_rule!(access_account_id)

    assert %{password_length: pwd_length} = effective_pwd_rules

    # Can't weaken global rules, so even though the owner rule defines a minimum
    # password length of 6, the global minimum of 8 characters will apply.  This
    # holds for the disallowed_compromised as well which is owner defined as
    # false, but globally defined as true (`true` is the stronger value).

    assert :eq =
             DbTypes.compare(pwd_length, %DbTypes.IntegerRange{
               lower: 8,
               upper: 1024,
               lower_inclusive: true,
               upper_inclusive: true
             })

    assert %{disallow_compromised: true} = effective_pwd_rules
  end
end
