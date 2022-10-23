# Source File: integration_test.exs
# Location:    musebms/components/system/msbms_syst_authentication/test/integration_test.exs
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
  use AuthenticationTestCase, async: false

  import Ecto.Query

  alias MsbmsSystAuthentication.Data
  alias MsbmsSystDatastore.DbTypes

  @moduletag :integration

  test "Step 01: Manage Disallowed Passwords" do
    assert :ok = MsbmsSystAuthentication.create_disallowed_password("IntegrationDuplicateTest")
    assert :ok = MsbmsSystAuthentication.create_disallowed_password("IntegrationDuplicateTest")

    assert :ok = MsbmsSystAuthentication.create_disallowed_password("IntegrationDeleteTest")

    assert {:ok, :deleted} =
             MsbmsSystAuthentication.delete_disallowed_password("IntegrationDeleteTest")

    assert {:ok, :not_found} =
             MsbmsSystAuthentication.delete_disallowed_password("IntegrationDeleteTest")

    # Add password for later test usage

    assert :ok = MsbmsSystAuthentication.create_disallowed_password("DisallowedPassword#123#")
  end

  test "Step 02: Add Owner Password Rules" do
    # The effective password rule for the access account is a combination of the
    # access account owner defined password rules and the global password rules
    # (global rules where the owner rules are 'weaker').  The effective password
    # rule for Owner 2 in these tests is therefore:
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
    #   "disallow_compromised": true,
    #   "require_mfa": true,
    #   "allowed_mfa_types": ["credential_types_secondary_totp"]
    # }

    {:ok, owner_id} = MsbmsSystInstanceMgr.get_owner_id_by_name("owner2")

    pwd_rule_params = %{
      password_length: %DbTypes.IntegerRange{lower: 12, upper: 64, upper_inclusive: true},
      max_age: %DbTypes.Interval{days: 10},
      require_upper_case: 2,
      require_lower_case: 2,
      require_numbers: 2,
      require_symbols: 2,
      disallow_recently_used: 2,
      disallow_compromised: false,
      require_mfa: true,
      allowed_mfa_types: ["credential_types_secondary_totp"]
    }

    assert {:ok, pwd_rules} =
             MsbmsSystAuthentication.Impl.PasswordRules.create_password_rules(
               owner_id,
               pwd_rule_params
             )

    assert %Data.SystOwnerPasswordRules{} = pwd_rules
    assert :eq = DbTypes.compare(pwd_rule_params.password_length, pwd_rules.password_length)
    assert :eq = DbTypes.compare(pwd_rule_params.max_age, pwd_rules.max_age)
    assert 2 = pwd_rules.require_upper_case
    assert 2 = pwd_rules.require_lower_case
    assert 2 = pwd_rules.require_numbers
    assert 2 = pwd_rules.require_symbols
    assert 2 = pwd_rules.disallow_recently_used
    assert pwd_rules.disallow_compromised == false
    assert pwd_rules.require_mfa == true
    assert ["credential_types_secondary_totp"] = pwd_rules.allowed_mfa_types
  end
end
