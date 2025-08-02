# Source File: credential_password_test.exs
# Location:    musebms/app_server/components/system/mscmp_syst_authn/test/credential_password_test.exs
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
  @moduledoc false

  # credo:disable-for-this-file Credo.Check.Design.AliasUsage
  #
  # In the tests we'll be more permissive of failing this check for now.
  # In application code we should adhere to our configured checks.

  use AuthenticationTestCase, async: true

  import Ecto.Query

  alias MscmpSystAuthn.Impl

  @moduletag :unit
  @moduletag :capture_log

  describe "password validation" do
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
      assert :ok = Impl.Credential.Password.test_credential(access_account_id, "AAaa11!!1234")

      assert_raise FunctionClauseError, fn ->
        Impl.Credential.Password.test_credential(access_account_id, nil)
      end

      # password_rule_length_min
      assert {:error, {:invalid_credential, violations}} =
               Impl.Credential.Password.test_credential(access_account_id, "AAaa11!!")

      assert Enum.any?(violations, fn element -> {:password_rule_length_min, _} = element end)

      # password_rule_length_max
      assert {:error, {:invalid_credential, violations}} =
               Impl.Credential.Password.test_credential(
                 access_account_id,
                 "AAaa11!!1234567890123456789012345678912345678901234567890123" <>
                   "45678AAaa11!!12345678901234567890123456789123456789012345678901234567"
               )

      assert Enum.any?(violations, fn element -> {:password_rule_length_max, _} = element end)

      # password_rule_required_upper
      assert {:error, {:invalid_credential, violations}} =
               Impl.Credential.Password.test_credential(access_account_id, "aaaa11!!1234")

      assert Enum.any?(violations, fn element -> {:password_rule_required_upper, _} = element end)

      # password_rule_required_lower
      assert {:error, {:invalid_credential, violations}} =
               Impl.Credential.Password.test_credential(access_account_id, "AAAa11!!1234")

      assert Enum.any?(violations, fn element -> {:password_rule_required_lower, _} = element end)

      # password_rule_required_numbers
      assert {:error, {:invalid_credential, violations}} =
               Impl.Credential.Password.test_credential(access_account_id, "AAaa1n!!nnnn")

      assert Enum.any?(violations, fn element ->
               {:password_rule_required_numbers, _} = element
             end)

      # password_rule_required_symbols
      assert {:error, {:invalid_credential, violations}} =
               Impl.Credential.Password.test_credential(access_account_id, "AAaa11!11234")

      assert Enum.any?(violations, fn element ->
               {:password_rule_required_symbols, _} = element
             end)

      # password_rule_disallowed_password
      assert {:error, {:invalid_credential, violations}} =
               Impl.Credential.Password.test_credential(access_account_id, "Disallowed!Test#01")

      assert Enum.any?(violations, fn element ->
               {:password_rule_disallowed_password, _} = element
             end)

      # password_rule_recent_password
      assert {:error, {:invalid_credential, violations}} =
               Impl.Credential.Password.test_credential(access_account_id, "PassHist#01!")

      assert Enum.any?(violations, fn element -> {:password_rule_recent_password, _} = element end)
    end
  end

  describe "credential confirmation" do
    test "Can get Password Credential confirmation errors" do
      {:ok, access_account_id} =
        Impl.AccessAccount.get_access_account_id_by_name("owned_all_access")

      assert {:ok, {:wrong_credential, []}} =
               Impl.Credential.Password.confirm_credential(
                 access_account_id,
                 Msutils.String.get_random_string(48)
               )

      # Test with bogus access_account_id value to force :no_credential
      assert {:ok, {:no_credential, []}} =
               Impl.Credential.Password.confirm_credential(
                 "c51edfbd-db46-44dd-9385-e44b1d45d706",
                 "owned.all.access.test.password"
               )
    end

    test "Can do basic Password confirmation" do
      {:ok, access_account_id} =
        Impl.AccessAccount.get_access_account_id_by_name("owned_all_access")

      assert {:ok, {:confirmed, []}} =
               Impl.Credential.Password.confirm_credential(
                 access_account_id,
                 nil,
                 "owned.all.access.test.password"
               )
    end

    test "Can confirm Password and require MFA" do
      {:ok, _access_account_id} =
        Impl.AccessAccount.get_access_account_id_by_name(
          "credential_password_confirm_mfa_test_accnt"
        )
    end

    test "Can confirm Password and require Forced Reset" do
      {:ok, access_account_id} =
        Impl.AccessAccount.get_access_account_id_by_name(
          "credential_password_confirm_force_test_accnt"
        )

      assert {:ok, {:confirmed, ext_state}} =
               Impl.Credential.Password.confirm_credential(
                 access_account_id,
                 "password.confirm.force.test.password"
               )

      assert Enum.member?(ext_state, :require_mfa)
      assert Enum.member?(ext_state, :reset_forced)
    end

    test "Can confirm Password and require Age Reset" do
      {:ok, access_account_id} =
        Impl.AccessAccount.get_access_account_id_by_name(
          "credential_password_confirm_age_test_accnt"
        )

      assert {:ok, {:confirmed, ext_state}} =
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

      assert {:ok, {:confirmed, ext_state}} =
               Impl.Credential.Password.confirm_credential(
                 access_account_id,
                 "Disallowed!Test#01"
               )

      assert Enum.member?(ext_state, :require_mfa)
      assert Enum.member?(ext_state, :reset_disallowed)
    end
  end

  describe "credential management" do
    test "Can insert new Password Credential" do
      {:ok, access_account_id} =
        Impl.AccessAccount.get_access_account_id_by_name(
          "credential_password_create_new_test_acct"
        )

      assert {:ok, %Msdata.SystCredentials{}} =
               Impl.Credential.Password.set_credential(
                 access_account_id,
                 "TestPassword!123!",
                 nil
               )
    end

    test "Can update Password Credential" do
      {:ok, access_account_id} =
        Impl.AccessAccount.get_access_account_id_by_name("credential_password_update_test_acct")

      # It is conceivable that this will generate a password that is not valid
      # according to the rules, but I expect that with 64 characters the chances
      # of randomly generating an invalid password is low.

      new_pwd = Msutils.String.get_random_string(64, ~c"0123456789ABCDEFGHIJabcdefghij`~!@#$%^&*")

      test_time = DateTime.truncate(DateTime.utc_now(), :second)

      assert {:ok, %Msdata.SystCredentials{}} =
               Impl.Credential.Password.set_credential(access_account_id, new_pwd, nil)

      assert {:ok, {:confirmed, _}} =
               Impl.Credential.Password.confirm_credential(
                 access_account_id,
                 new_pwd
               )

      cred =
        from(c in Msdata.SystCredentials,
          join: ei in assoc(c, :credential_type),
          where:
            c.access_account_id == ^access_account_id and
              ei.internal_name == "credential_types_sysdef_password"
        )
        |> MscmpSystDb.one!()

      assert DateTime.compare(test_time, cred.last_updated) in [:eq, :lt]
    end

    test "Cannot update Password when recently used" do
      {:ok, access_account_id} =
        Impl.AccessAccount.get_access_account_id_by_name("credential_password_reuse_test_acct")

      # It is conceivable that this will generate a password that is not valid
      # according to the rules, but I expect that with 64 characters the chances
      # of randomly generating an invalid password is low.

      new1_pwd =
        Msutils.String.get_random_string(64, ~c"0123456789ABCDEFGHIJabcdefghij`~!@#$%^&*")

      new2_pwd =
        Msutils.String.get_random_string(64, ~c"0123456789ABCDEFGHIJabcdefghij`~!@#$%^&*")

      new3_pwd =
        Msutils.String.get_random_string(64, ~c"0123456789ABCDEFGHIJabcdefghij`~!@#$%^&*")

      assert {:ok, %Msdata.SystCredentials{}} =
               Impl.Credential.Password.set_credential(access_account_id, new1_pwd, nil)

      assert {:ok, %Msdata.SystCredentials{}} =
               Impl.Credential.Password.set_credential(access_account_id, new2_pwd, nil)

      assert {:error, {:invalid_credential, [{:password_rule_recent_password, _}]}} =
               Impl.Credential.Password.set_credential(
                 access_account_id,
                 new1_pwd,
                 nil
               )

      assert {:ok, %Msdata.SystCredentials{}} =
               Impl.Credential.Password.set_credential(access_account_id, new3_pwd, nil)

      assert {:ok, %Msdata.SystCredentials{}} =
               Impl.Credential.Password.set_credential(access_account_id, new1_pwd, nil)
    end

    test "Cannot insert invalid Password Credential" do
      {:ok, access_account_id} =
        Impl.AccessAccount.get_access_account_id_by_name(
          "credential_password_create_reject_test_acct"
        )

      assert {:error, {:invalid_credential, [{:password_rule_length_min, _}]}} =
               Impl.Credential.Password.set_credential(access_account_id, "AAaa11!!", nil)

      assert {:error, {:invalid_credential, [{:password_rule_length_max, _}]}} =
               Impl.Credential.Password.set_credential(
                 access_account_id,
                 "AAaa11!!1234567890123456789012345678912345678901234567890123" <>
                   "45678AAaa11!!12345678901234567890123456789123456789012345678901234567",
                 nil
               )

      assert {:error, {:invalid_credential, [{:password_rule_required_upper, _}]}} =
               Impl.Credential.Password.set_credential(access_account_id, "aaaa11!!1234", nil)

      assert {:error, {:invalid_credential, [{:password_rule_required_lower, _}]}} =
               Impl.Credential.Password.set_credential(access_account_id, "AAAa11!!1234", nil)

      assert {:error, {:invalid_credential, [{:password_rule_required_numbers, _}]}} =
               Impl.Credential.Password.set_credential(access_account_id, "AAaa1n!!nnnn", nil)

      assert {:error, {:invalid_credential, [{:password_rule_required_symbols, _}]}} =
               Impl.Credential.Password.set_credential(access_account_id, "AAaa11!11234", nil)

      assert {:error, {:invalid_credential, [{:password_rule_disallowed_password, _}]}} =
               Impl.Credential.Password.set_credential(
                 access_account_id,
                 "Disallowed!Test#01",
                 nil
               )

      assert {:error, {:invalid_credential, [{:password_rule_recent_password, _}]}} =
               Impl.Credential.Password.set_credential(access_account_id, "PassHist#02!", nil)
    end

    test "Can retrieve Credential record" do
      {:ok, access_account_id} =
        Impl.AccessAccount.get_access_account_id_by_name("owned_all_access")

      assert {:ok, %Msdata.SystCredentials{}} =
               Impl.Credential.Password.get_credential_record(access_account_id)
    end
  end

  describe "credential deletion" do
    test "Can delete Credential by Access Account ID" do
      {:ok, access_account_id} =
        Impl.AccessAccount.get_access_account_id_by_name("credential_password_delete1_test_acct")

      assert :ok = Impl.Credential.Password.delete_credential(access_account_id)

      {:ok, access_account_id} =
        Impl.AccessAccount.get_access_account_id_by_name("credential_password_delete3_test_acct")

      assert :ok = Impl.Credential.Password.delete_credential(access_account_id)
    end

    test "Can delete Credential by Credential record" do
      {:ok, access_account_id} =
        Impl.AccessAccount.get_access_account_id_by_name("credential_password_delete2_test_acct")

      cred =
        from(c in Msdata.SystCredentials,
          join: ei in assoc(c, :credential_type),
          where:
            c.access_account_id == ^access_account_id and
              ei.internal_name == "credential_types_sysdef_password"
        )
        |> MscmpSystDb.one!()

      assert :ok = Impl.Credential.Password.delete_credential(cred)

      {:ok, access_account_id} =
        Impl.AccessAccount.get_access_account_id_by_name("credential_password_delete4_test_acct")

      cred =
        from(c in Msdata.SystCredentials,
          join: ei in assoc(c, :credential_type),
          where:
            c.access_account_id == ^access_account_id and
              ei.internal_name == "credential_types_sysdef_password"
        )
        |> MscmpSystDb.one!()

      assert :ok = Impl.Credential.Password.delete_credential(cred)
    end
  end
end
