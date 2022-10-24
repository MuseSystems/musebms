# Source File: credential_password_test.exs
# Location:    musebms/components/system/msbms_syst_authentication/test/credential_password_test.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule CredentialPasswordTest do
  use AuthenticationTestCase, async: true

  import Ecto.Query

  alias MsbmsSystAuthentication.Data
  alias MsbmsSystAuthentication.Impl

  test "Can test Credential by Access Account ID" do
    {:ok, access_account_id} =
      Impl.AccessAccount.get_access_account_id_by_name("password_history_test_accnt")

    # The effective password rule for the access account is a combination of the
    # access account owner defined password rules and the global password rules
    # (global rules where the owner rules are 'weaker').  The effective password
    # rule for these tests is therefore:
    #
    # {
    #   "password_length": {
    #     "lower": 12,
    #     "upper": 128,
    #     "inclusion": "[]"
    #   },
    #   "require_upper_case": 2,
    #   "require_lower_case": 2,
    #   "require_numbers": 2,
    #   "require_symbols": 2,
    #   "disallow_recently_used": 2,
    #   "disallow_compromised": true
    # }

    # Acceptable Password
    assert [] = Impl.Credential.Password.test_credential(access_account_id, "AAaa11!!1234")

    # password_rule_length_min
    assert Impl.Credential.Password.test_credential(access_account_id, "AAaa11!!")
           |> Enum.any?(fn element -> {:password_rule_length_min, _} = element end)

    # password_rule_length_max
    assert Impl.Credential.Password.test_credential(
             access_account_id,
             "AAaa11!!1234567890123456789012345678912345678901234567890123" <>
               "45678AAaa11!!12345678901234567890123456789123456789012345678901234567"
           )
           |> Enum.any?(fn element -> {:password_rule_length_max, _} = element end)

    # password_rule_required_upper
    assert Impl.Credential.Password.test_credential(access_account_id, "aaaa11!!1234")
           |> Enum.any?(fn element -> {:password_rule_required_upper, _} = element end)

    # password_rule_required_lower
    assert Impl.Credential.Password.test_credential(access_account_id, "AAAa11!!1234")
           |> Enum.any?(fn element -> {:password_rule_required_lower, _} = element end)

    # password_rule_required_numbers
    assert Impl.Credential.Password.test_credential(access_account_id, "AAaa1n!!nnnn")
           |> Enum.any?(fn element -> {:password_rule_required_numbers, _} = element end)

    # password_rule_required_symbols
    assert Impl.Credential.Password.test_credential(access_account_id, "AAaa11!11234")
           |> Enum.any?(fn element -> {:password_rule_required_symbols, _} = element end)

    # password_rule_disallowed_password
    assert Impl.Credential.Password.test_credential(access_account_id, "Disallowed!Test#01")
           |> Enum.any?(fn element -> {:password_rule_disallowed_password, _} = element end)

    # password_rule_recent_password
    assert Impl.Credential.Password.test_credential(access_account_id, "PassHist#01!")
           |> Enum.any?(fn element -> {:password_rule_recent_password, _} = element end)
  end

  test "Can get Password Credential confirmation errors" do
    {:ok, access_account_id} =
      Impl.AccessAccount.get_access_account_id_by_name("owned_all_access")

    assert {:wrong_credential, []} =
             Impl.Credential.Password.confirm_credential(
               access_account_id,
               MsbmsSystUtils.get_random_string(48)
             )

    # Test with bogus access_account_id value to force :no_credential
    assert {:no_credential, []} =
             Impl.Credential.Password.confirm_credential(
               "c51edfbd-db46-44dd-9385-e44b1d45d706",
               "owned.all.access.test.password"
             )
  end

  test "Can do basic Password confirmation" do
    {:ok, access_account_id} =
      Impl.AccessAccount.get_access_account_id_by_name("owned_all_access")

    assert {:confirmed, []} =
             Impl.Credential.Password.confirm_credential(
               access_account_id,
               nil,
               "owned.all.access.test.password"
             )
  end

  test "Can confirm Password and require MFA" do
    {:ok, access_account_id} =
      Impl.AccessAccount.get_access_account_id_by_name(
        "credential_password_confirm_mfa_test_accnt"
      )

    assert {:confirmed, [:require_mfa | []]} =
             Impl.Credential.Password.confirm_credential(
               access_account_id,
               "password.confirm.mfa.test.password"
             )
  end

  test "Can confirm Password and require Forced Reset" do
    {:ok, access_account_id} =
      Impl.AccessAccount.get_access_account_id_by_name(
        "credential_password_confirm_force_test_accnt"
      )

    assert {:confirmed, ext_state} =
             Impl.Credential.Password.confirm_credential(
               access_account_id,
               "password.confirm.force.test.password"
             )

    assert Enum.member?(ext_state, :require_mfa)
    assert Enum.member?(ext_state, :reset_forced)
  end

  # Note that the effective password rule for max age is 10 days using test
  # credentials indicating last_updated 11 days ago.

  test "Can confirm Password and require Age Reset" do
    {:ok, access_account_id} =
      Impl.AccessAccount.get_access_account_id_by_name(
        "credential_password_confirm_age_test_accnt"
      )

    assert {:confirmed, ext_state} =
             Impl.Credential.Password.confirm_credential(
               access_account_id,
               "password.confirm.age.test.password"
             )

    assert Enum.member?(ext_state, :require_mfa)
    assert Enum.member?(ext_state, :reset_age)
  end

  test "Can confirm Password and require Disallowed Password Reset" do
    {:ok, access_account_id} =
      Impl.AccessAccount.get_access_account_id_by_name(
        "credential_password_confirm_disallowed_test_accnt"
      )

    assert {:confirmed, ext_state} =
             Impl.Credential.Password.confirm_credential(
               access_account_id,
               "Disallowed!Test#01"
             )

    assert Enum.member?(ext_state, :require_mfa)
    assert Enum.member?(ext_state, :reset_disallowed)
  end

  test "Can insert new Password Credential" do
    {:ok, access_account_id} =
      Impl.AccessAccount.get_access_account_id_by_name("credential_password_create_new_test_acct")

    assert :ok =
             Impl.Credential.Password.set_credential(access_account_id, "TestPassword!123!", nil)
  end

  test "Can update Password Credential" do
    {:ok, access_account_id} =
      Impl.AccessAccount.get_access_account_id_by_name("credential_password_update_test_acct")

    # It is conceivable that this will generate a password that is not valid
    # according to the rules, but I expect that with 64 characters the chances
    # of randomly generating an invalid password is low.

    new_pwd = MsbmsSystUtils.get_random_string(64, '0123456789ABCDEFGHIJabcdefghij`~!@#$%^&*')

    test_time = DateTime.truncate(DateTime.utc_now(), :second)

    assert :ok = Impl.Credential.Password.set_credential(access_account_id, new_pwd, nil)

    assert {:confirmed, _} =
             Impl.Credential.Password.confirm_credential(
               access_account_id,
               new_pwd
             )

    cred =
      from(c in Data.SystCredentials,
        join: ei in assoc(c, :credential_type),
        where:
          c.access_account_id == ^access_account_id and
            ei.internal_name == "credential_types_sysdef_password"
      )
      |> MsbmsSystDatastore.one!()

    assert DateTime.compare(test_time, cred.last_updated) in [:eq, :lt]
  end

  test "Cannot update Password when recently used" do
    {:ok, access_account_id} =
      Impl.AccessAccount.get_access_account_id_by_name("credential_password_reuse_test_acct")

    # It is conceivable that this will generate a password that is not valid
    # according to the rules, but I expect that with 64 characters the chances
    # of randomly generating an invalid password is low.

    new1_pwd = MsbmsSystUtils.get_random_string(64, '0123456789ABCDEFGHIJabcdefghij`~!@#$%^&*')
    new2_pwd = MsbmsSystUtils.get_random_string(64, '0123456789ABCDEFGHIJabcdefghij`~!@#$%^&*')
    new3_pwd = MsbmsSystUtils.get_random_string(64, '0123456789ABCDEFGHIJabcdefghij`~!@#$%^&*')

    assert :ok = Impl.Credential.Password.set_credential(access_account_id, new1_pwd, nil)

    assert :ok = Impl.Credential.Password.set_credential(access_account_id, new2_pwd, nil)

    assert {:invalid_credential, [{:password_rule_recent_password, _}]} =
             Impl.Credential.Password.set_credential(
               access_account_id,
               new1_pwd,
               nil
             )

    assert :ok = Impl.Credential.Password.set_credential(access_account_id, new3_pwd, nil)

    assert :ok = Impl.Credential.Password.set_credential(access_account_id, new1_pwd, nil)
  end

  test "Cannot insert invalid Password Credential" do
    {:ok, access_account_id} =
      Impl.AccessAccount.get_access_account_id_by_name(
        "credential_password_create_reject_test_acct"
      )

    assert {:invalid_credential, [{:password_rule_length_min, _}]} =
             Impl.Credential.Password.set_credential(access_account_id, "AAaa11!!", nil)

    assert {:invalid_credential, [{:password_rule_length_max, _}]} =
             Impl.Credential.Password.set_credential(
               access_account_id,
               "AAaa11!!1234567890123456789012345678912345678901234567890123" <>
                 "45678AAaa11!!12345678901234567890123456789123456789012345678901234567",
               nil
             )

    assert {:invalid_credential, [{:password_rule_required_upper, _}]} =
             Impl.Credential.Password.set_credential(access_account_id, "aaaa11!!1234", nil)

    assert {:invalid_credential, [{:password_rule_required_lower, _}]} =
             Impl.Credential.Password.set_credential(access_account_id, "AAAa11!!1234", nil)

    assert {:invalid_credential, [{:password_rule_required_numbers, _}]} =
             Impl.Credential.Password.set_credential(access_account_id, "AAaa1n!!nnnn", nil)

    assert {:invalid_credential, [{:password_rule_required_symbols, _}]} =
             Impl.Credential.Password.set_credential(access_account_id, "AAaa11!11234", nil)

    assert {:invalid_credential, [{:password_rule_disallowed_password, _}]} =
             Impl.Credential.Password.set_credential(access_account_id, "Disallowed!Test#01", nil)

    assert {:invalid_credential, [{:password_rule_recent_password, _}]} =
             Impl.Credential.Password.set_credential(access_account_id, "PassHist#02!", nil)
  end

  test "Can retrieve Credential record" do
    {:ok, access_account_id} =
      Impl.AccessAccount.get_access_account_id_by_name("owned_all_access")

    assert %Data.SystCredentials{} =
             Impl.Credential.Password.get_credential_record(access_account_id)
  end

  test "Can delete Credential by Access Account ID" do
    {:ok, access_account_id} =
      Impl.AccessAccount.get_access_account_id_by_name("credential_password_delete1_test_acct")

    assert :ok = Impl.Credential.Password.delete_credential(access_account_id)
  end

  test "Can delete Credential by Credential record" do
    {:ok, access_account_id} =
      Impl.AccessAccount.get_access_account_id_by_name("credential_password_delete2_test_acct")

    cred =
      from(c in Data.SystCredentials,
        join: ei in assoc(c, :credential_type),
        where:
          c.access_account_id == ^access_account_id and
            ei.internal_name == "credential_types_sysdef_password"
      )
      |> MsbmsSystDatastore.one!()

    assert :ok = Impl.Credential.Password.delete_credential(cred)
  end
end
