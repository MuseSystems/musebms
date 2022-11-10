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
  import IP, only: [sigil_i: 2]

  alias MsbmsSystAuthentication.Data
  alias MsbmsSystDatastore.DbTypes

  @moduletag :integration

  # ==============================================================================================
  #
  # Topic 1: Initial Authentication System Setup
  #
  # ==============================================================================================

  test "Step 1.01: Manage Disallowed Passwords" do
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

  test "Step 1.02: Manage Global Network Rules" do
    orig_pwd_rules = MsbmsSystAuthentication.get_global_password_rules!()

    new_rule_params = %{
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

    revert_rule_params = %{
      password_length: orig_pwd_rules.password_length,
      max_age: orig_pwd_rules.max_age,
      require_upper_case: orig_pwd_rules.require_upper_case,
      require_lower_case: orig_pwd_rules.require_lower_case,
      require_numbers: orig_pwd_rules.require_numbers,
      require_symbols: orig_pwd_rules.require_symbols,
      disallow_recently_used: orig_pwd_rules.disallow_recently_used,
      disallow_compromised: orig_pwd_rules.disallow_compromised,
      require_mfa: orig_pwd_rules.require_mfa,
      allowed_mfa_types: orig_pwd_rules.allowed_mfa_types
    }

    {:ok, new_pwd_rules} =
      MsbmsSystAuthentication.update_global_password_rules(orig_pwd_rules, new_rule_params)

    {:ok, _} = MsbmsSystAuthentication.update_global_password_rules(revert_rule_params)

    assert :eq = DbTypes.compare(new_pwd_rules.password_length, new_rule_params.password_length)
    assert :eq = DbTypes.compare(new_pwd_rules.max_age, new_rule_params.max_age)
    assert new_pwd_rules.require_upper_case == new_rule_params.require_upper_case
    assert new_pwd_rules.require_lower_case == new_rule_params.require_lower_case
    assert new_pwd_rules.require_numbers == new_rule_params.require_numbers
    assert new_pwd_rules.require_symbols == new_rule_params.require_symbols
    assert new_pwd_rules.disallow_recently_used == new_rule_params.disallow_recently_used
    assert new_pwd_rules.disallow_compromised == new_rule_params.disallow_compromised
    assert new_pwd_rules.require_mfa == new_rule_params.require_mfa
    assert new_pwd_rules.allowed_mfa_types == new_rule_params.allowed_mfa_types
  end

  test "Step 1.03: Add Owner Password Rules" do
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
             MsbmsSystAuthentication.create_owner_password_rules(owner_id, pwd_rule_params)

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

  test "Step 1.04: Manage Disallowed Host" do
    assert {:ok, %Data.SystDisallowedHosts{}} =
             MsbmsSystAuthentication.create_disallowed_host(~i"10.10.10.2")

    assert {:ok, :deleted} = MsbmsSystAuthentication.delete_disallowed_host_addr(~i"10.10.10.2")

    assert {:ok, :not_found} = MsbmsSystAuthentication.delete_disallowed_host_addr(~i"10.10.10.2")

    assert {:ok, %Data.SystDisallowedHosts{id: delete_id}} =
             MsbmsSystAuthentication.create_disallowed_host(~i"10.10.10.3")

    assert {:ok, :deleted} = MsbmsSystAuthentication.delete_disallowed_host(delete_id)

    assert {:ok, :not_found} = MsbmsSystAuthentication.delete_disallowed_host(delete_id)

    # Disallowed Host for later tests

    assert {:ok, %Data.SystDisallowedHosts{}} =
             MsbmsSystAuthentication.create_disallowed_host(~i"10.10.10.1")

    assert {:ok, true} = MsbmsSystAuthentication.host_disallowed(~i"10.10.10.1")
    assert false == MsbmsSystAuthentication.host_disallowed?(~i"10.10.10.2")
  end

  test "Step 1.05: Add Global Network Rules" do
    # The following sequence of rules should result in a file set of Global
    # Network Rules which look like:
    #
    #  1) Allow: 10.100.170/24
    #  2) Deny:  10.100.160.1 - 10.100.190.254
    #  3) Deny:  10.100.150.0/24

    assert {:ok, _} =
             MsbmsSystAuthentication.create_global_network_rule(%{
               ordering: 1,
               functional_type: :deny,
               ip_host_or_network: ~i"10.100.150.0/24"
             })

    assert {:ok, _} =
             MsbmsSystAuthentication.create_global_network_rule(%{
               ordering: 1,
               functional_type: :deny,
               ip_host_range_lower: ~i"10.100.160.1",
               ip_host_range_upper: ~i"10.100.190.254"
             })

    assert {:ok, _} =
             MsbmsSystAuthentication.create_global_network_rule(%{
               ordering: 1,
               functional_type: :allow,
               ip_host_or_network: ~i"10.100.170.0/24"
             })
  end

  test "Step 1.06: Add Owner Network Rules" do
    {:ok, owner_id} = MsbmsSystInstanceMgr.get_owner_id_by_name("owner2")

    # The following sequence of rules should result in a file set of Owner
    # Network Rules which look like:
    #
    #  1) Allow: 10.120.170/24
    #  2) Deny:  10.120.160.1 - 10.120.190.254
    #  3) Deny:  10.120.150.0/24

    assert {:ok, _} =
             MsbmsSystAuthentication.create_owner_network_rule(owner_id, %{
               ordering: 1,
               functional_type: :deny,
               ip_host_or_network: ~i"10.120.150.0/24"
             })

    assert {:ok, _} =
             MsbmsSystAuthentication.create_owner_network_rule(owner_id, %{
               ordering: 1,
               functional_type: :deny,
               ip_host_range_lower: ~i"10.120.160.1",
               ip_host_range_upper: ~i"10.120.190.254"
             })

    assert {:ok, _} =
             MsbmsSystAuthentication.create_owner_network_rule(owner_id, %{
               ordering: 1,
               functional_type: :allow,
               ip_host_or_network: ~i"10.120.170.0/24"
             })
  end

  test "Step 1.07: Add Instance Network Rules" do
    {:ok, instance_id} =
      MsbmsSystInstanceMgr.get_instance_id_by_name("app1_owner2_instance_types_std")

    # The following sequence of rules should result in a file set of Owner
    # Network Rules which look like:
    #
    #  1) Allow: 10.130.170/24
    #  2) Deny:  10.130.160.1 - 10.130.190.254
    #  3) Deny:  10.130.150.0/24

    assert {:ok, _} =
             MsbmsSystAuthentication.create_instance_network_rule(instance_id, %{
               ordering: 1,
               functional_type: :deny,
               ip_host_or_network: ~i"10.130.150.0/24"
             })

    assert {:ok, _} =
             MsbmsSystAuthentication.create_instance_network_rule(instance_id, %{
               ordering: 1,
               functional_type: :deny,
               ip_host_range_lower: ~i"10.130.160.1",
               ip_host_range_upper: ~i"10.130.190.254"
             })

    assert {:ok, _} =
             MsbmsSystAuthentication.create_instance_network_rule(instance_id, %{
               ordering: 1,
               functional_type: :allow,
               ip_host_or_network: ~i"10.130.170.0/24"
             })
  end

  test "Step 1.08: Violate Host Rate Limit" do
    assert false == MsbmsSystAuthentication.host_disallowed?(~i"10.10.20.123")
    assert :rejected_host_check = violate_host_rate_limit(~i"10.10.20.123", 100)
    assert true == MsbmsSystAuthentication.host_disallowed?(~i"10.10.20.123")
  end

  test "Step 1.09: Cannot violate Host Rate Limit using explicitly allowed Host" do
    assert false == MsbmsSystAuthentication.host_disallowed?(~i"10.100.170.170")
    assert :test_limit_reached = violate_host_rate_limit(~i"10.100.170.170", 100)
    assert false == MsbmsSystAuthentication.host_disallowed?(~i"10.100.170.170")
  end

  # ==============================================================================================
  #
  # Topic 2: Unowned Access Accounts
  #
  # ==============================================================================================

  test "Step 2.01: Add Unowned Access Accounts" do
    state = MsbmsSystEnums.get_default_enum_item("access_account_states")

    assert {:ok, %MsbmsSystAuthentication.Data.SystAccessAccounts{}} =
             MsbmsSystAuthentication.create_access_account(%{
               internal_name: "unowned_access_account",
               external_name: "Unowned Access Account",
               access_account_state_id: state.id,
               allow_global_logins: true
             })
  end

  test "Step 2.02: Test Password for Unowned Access Account" do
    {:ok, access_account_id} =
      MsbmsSystAuthentication.get_access_account_id_by_name("unowned_access_account")

    assert {:ok, [password_rule_length_min: 8]} =
             MsbmsSystAuthentication.test_credential(access_account_id, "short")

    assert {:ok, [password_rule_disallowed_password: true]} =
             MsbmsSystAuthentication.test_credential(access_account_id, "DisallowedPassword#123#")

    assert {:ok, []} =
             MsbmsSystAuthentication.test_credential(access_account_id, "A valid password.")
  end

  test "Step 2.03: Attempt Bad Password for Unowned Access Account" do
    # This test is more about testing the error result tuple of
    # create_authenticator_email_password/4.  We want to be sure that password
    # rule violations are easier to get to than some misc errors can be.

    {:ok, access_account_id} =
      MsbmsSystAuthentication.get_access_account_id_by_name("unowned_access_account")

    assert {:error, %MsbmsSystError{cause: cause}} =
             MsbmsSystAuthentication.create_authenticator_email_password(
               access_account_id,
               "UnownedAccessAccount@MuseSystems.Com",
               "short"
             )

    assert {:invalid_credential, [password_rule_length_min: 8]} = cause
  end

  test "Step 2.04: Create Email/Password for Unowned Access Account" do
    # For the Unowned Access Account type, create_validated will default to
    # false as this is the common realistic scenario.  Owned Access Accounts
    # will more likely be created already validated.

    {:ok, access_account_id} =
      MsbmsSystAuthentication.get_access_account_id_by_name("unowned_access_account")

    assert {:ok, authenticator_result} =
             MsbmsSystAuthentication.create_authenticator_email_password(
               access_account_id,
               "UnownedAccessAccount@MuseSystems.Com",
               "Unowned testing password"
             )

    assert access_account_id == authenticator_result.access_account_id
    assert "UnownedAccessAccount@musesystems.com" == authenticator_result.account_identifier
    assert nil != authenticator_result[:validation_identifier]
    assert nil != authenticator_result[:validation_credential]
  end

  test "Step 2.05: Violate Rate Limit for Unowned Access Account Validation Identity" do
    validator_identity =
      from(vi in Data.SystIdentities,
        join: emi in Data.SystIdentities,
        on: emi.id == vi.validates_identity_id,
        join: ei in assoc(emi, :identity_type),
        join: aa in assoc(emi, :access_account),
        where:
          aa.internal_name == "unowned_access_account" and
            ei.internal_name == "identity_types_sysdef_email" and
            is_nil(emi.validated)
      )
      |> MsbmsSystDatastore.one!()

    assert :rejected_rate_limited =
             violate_validator_rate_limit(
               validator_identity.account_identifier,
               ~i"10.123.123.123",
               nil,
               100
             )
  end

  test "Step 2.06: Revoke Validation Identity for Unowned Access Account Email" do
    email_identity_id =
      from(i in Data.SystIdentities,
        join: ei in assoc(i, :identity_type),
        join: aa in assoc(i, :access_account),
        where:
          aa.internal_name == "unowned_access_account" and
            ei.internal_name == "identity_types_sysdef_email" and
            is_nil(i.validated),
        select: i.id
      )
      |> MsbmsSystDatastore.one!()

    assert {:ok, :deleted} =
             MsbmsSystAuthentication.revoke_validator_for_identity_id(email_identity_id)

    assert {:ok, :not_found} =
             MsbmsSystAuthentication.revoke_validator_for_identity_id(email_identity_id)
  end

  test "Step 2.07: Try to set Email/Password again for Unowned Access Account" do
    # A little test to be sure that create_authenticator_email_password/4 has no
    # obvious bypasses.

    {:ok, access_account_id} =
      MsbmsSystAuthentication.get_access_account_id_by_name("unowned_access_account")

    assert {:error, %MsbmsSystError{}} =
             MsbmsSystAuthentication.create_authenticator_email_password(
               access_account_id,
               "UnownedAccessAccount@MuseSystems.Com",
               "Unowned testing password"
             )
  end

  test "Step 2.08: Create New Email Validator for Unowned Access Account" do
    email_identity =
      from(i in Data.SystIdentities,
        join: ei in assoc(i, :identity_type),
        join: aa in assoc(i, :access_account),
        where:
          aa.internal_name == "unowned_access_account" and
            ei.internal_name == "identity_types_sysdef_email" and
            is_nil(i.validated)
      )
      |> MsbmsSystDatastore.one!()

    assert {:ok, validator_result} =
             MsbmsSystAuthentication.request_identity_validation(email_identity.id,
               credential_token: "My Known Token"
             )

    assert email_identity.access_account_id == validator_result.access_account_id
    assert nil != validator_result[:validation_identifier]
    assert "My Known Token" = validator_result[:validation_credential]
  end

  test "Step 2.09: Validator confirmation for Unowned Access Account" do
    validator_identity =
      from(vi in Data.SystIdentities,
        join: emi in Data.SystIdentities,
        on: emi.id == vi.validates_identity_id,
        join: ei in assoc(emi, :identity_type),
        join: aa in assoc(emi, :access_account),
        where:
          aa.internal_name == "unowned_access_account" and
            ei.internal_name == "identity_types_sysdef_email" and
            is_nil(emi.validated)
      )
      |> MsbmsSystDatastore.one!()

    # First try some failure modes
    assert {:ok, disallowed_host_state} =
             MsbmsSystAuthentication.authenticate_validation_token(
               validator_identity.account_identifier,
               "My Known Token",
               ~i"10.10.10.1"
             )

    assert %{status: :rejected_host_check} = disallowed_host_state
    assert %{applied_network_rule: %{precedence: :disallowed}} = disallowed_host_state

    assert {:ok, denied_host_state} =
             MsbmsSystAuthentication.authenticate_validation_token(
               validator_identity.account_identifier,
               "My Known Token",
               ~i"10.100.180.125"
             )

    assert %{status: :rejected_host_check} = denied_host_state
    assert %{applied_network_rule: %{precedence: :global}} = denied_host_state

    # Good attempt
    assert {:ok, auth_state} =
             MsbmsSystAuthentication.authenticate_validation_token(
               validator_identity.account_identifier,
               "My Known Token",
               ~i"10.100.170.125"
             )

    assert %{status: :authenticated} = auth_state
    assert %{applied_network_rule: %{precedence: :global}} = auth_state

    assert from(i in Data.SystIdentities,
             join: ei in assoc(i, :identity_type),
             join: aa in assoc(i, :access_account),
             where:
               aa.internal_name == "unowned_access_account" and
                 ei.internal_name == "identity_types_sysdef_email" and
                 not is_nil(i.validated)
           )
           |> MsbmsSystDatastore.exists?()

    refute from(vi in Data.SystIdentities,
             join: emi in Data.SystIdentities,
             on: emi.id == vi.validates_identity_id,
             join: ei in assoc(emi, :identity_type),
             join: aa in assoc(emi, :access_account),
             where:
               aa.internal_name == "unowned_access_account" and
                 ei.internal_name == "identity_types_sysdef_email"
           )
           |> MsbmsSystDatastore.exists?()
  end

  test "Step 2.10: Invite Unowned Access Account to Instances" do
    # Basic Invite

    {:ok, access_account_id} =
      MsbmsSystAuthentication.get_access_account_id_by_name("unowned_access_account")

    {:ok, owner1_instance_id} =
      MsbmsSystInstanceMgr.get_instance_id_by_name("app1_owner1_instance_types_std")

    assert {:ok, %Data.SystAccessAccountInstanceAssocs{} = invited_aaia_owner1} =
             MsbmsSystAuthentication.invite_to_instance(access_account_id, owner1_instance_id)

    assert nil == invited_aaia_owner1.access_granted

    # Invite w/Custom Expiration

    {:ok, owner2_instance_id} =
      MsbmsSystInstanceMgr.get_instance_id_by_name("app1_owner2_instance_types_std")

    assert {:ok, %Data.SystAccessAccountInstanceAssocs{} = invited_aaia_owner2} =
             MsbmsSystAuthentication.invite_to_instance(access_account_id, owner2_instance_id,
               expiration_days: 10
             )

    test_date = Date.utc_today() |> Date.add(10)

    assert :eq =
             DbTypes.compare(test_date, DateTime.to_date(invited_aaia_owner2.invitation_expires))

    assert nil == invited_aaia_owner2.access_granted

    # Invite w/Create Accepted Option

    {:ok, owner3_instance_id} =
      MsbmsSystInstanceMgr.get_instance_id_by_name("app1_owner3_instance_types_std")

    assert {:ok, %Data.SystAccessAccountInstanceAssocs{} = invited_aaia_owner3} =
             MsbmsSystAuthentication.invite_to_instance(access_account_id, owner3_instance_id,
               create_accepted: true
             )

    assert Date.utc_today() == DateTime.to_date(invited_aaia_owner3.access_granted)
  end

  test "Step 2.11: Accept Instance Invite to Unowned Access Account" do
    {:ok, access_account_id} =
      MsbmsSystAuthentication.get_access_account_id_by_name("unowned_access_account")

    {:ok, instance_id} =
      MsbmsSystInstanceMgr.get_instance_id_by_name("app1_owner1_instance_types_std")

    assert {:ok, aaia_record} =
             MsbmsSystAuthentication.accept_instance_invite(access_account_id, instance_id)

    assert %Data.SystAccessAccountInstanceAssocs{} = aaia_record
  end

  test "Step 2.12: Decline Instance Invite to Unowned Access Account" do
    {:ok, access_account_id} =
      MsbmsSystAuthentication.get_access_account_id_by_name("unowned_access_account")

    {:ok, instance_id} =
      MsbmsSystInstanceMgr.get_instance_id_by_name("app1_owner2_instance_types_std")

    assert {:ok, aaia_record} =
             MsbmsSystAuthentication.decline_instance_invite(access_account_id, instance_id)

    assert %Data.SystAccessAccountInstanceAssocs{} = aaia_record
  end

  test "Step 2.13: Authenticate Unowned Access Account using Email/Password" do
    # Instance access invite was explicitly accepted in earlier step.
    {:ok, instance1_id} =
      MsbmsSystInstanceMgr.get_instance_id_by_name("app1_owner1_instance_types_std")

    assert {:ok, auth_status1} =
             MsbmsSystAuthentication.authenticate_email_password(
               "UnownedAccessAccount@Musesystems.Com",
               "Unowned testing password",
               ~i"10.100.170.10",
               instance_id: instance1_id
             )

    assert %{status: :authenticated} = auth_status1

    # Instance access was created as accepted.
    {:ok, instance3_id} =
      MsbmsSystInstanceMgr.get_instance_id_by_name("app1_owner3_instance_types_std")

    assert {:ok, auth_status3} =
             MsbmsSystAuthentication.authenticate_email_password(
               "UnownedAccessAccount@Musesystems.Com",
               "Unowned testing password",
               ~i"10.100.170.10",
               instance_id: instance3_id
             )

    assert %{status: :authenticated} = auth_status3
  end

  test "Step 2.14: Fail Authentication Unowned Access Account / Bad Password" do
    {:ok, instance_id} =
      MsbmsSystInstanceMgr.get_instance_id_by_name("app1_owner1_instance_types_std")

    assert {:ok, auth_status} =
             MsbmsSystAuthentication.authenticate_email_password(
               "UnownedAccessAccount@musesystems.com",
               "A Bad Password",
               ~i"10.100.170.10",
               instance_id: instance_id
             )

    assert %{status: :rejected} = auth_status
  end

  test "Step 2.15: Fail Authentication Unowned Access Account / Bad Instance" do
    # This instance access was declined in an earlier step.
    {:ok, instance_id} =
      MsbmsSystInstanceMgr.get_instance_id_by_name("app1_owner2_instance_types_std")

    assert {:ok, auth_status} =
             MsbmsSystAuthentication.authenticate_email_password(
               "UnownedAccessAccount@Musesystems.Com",
               "Unowned testing password",
               ~i"10.100.170.10",
               instance_id: instance_id
             )

    assert %{status: :rejected} = auth_status
  end

  test "Step 2.16: Fail Authentication Unowned Access Account / Bad Email Case" do
    {:ok, instance_id} =
      MsbmsSystInstanceMgr.get_instance_id_by_name("app1_owner1_instance_types_std")

    assert {:ok, auth_status} =
             MsbmsSystAuthentication.authenticate_email_password(
               "unownedaccessaccount@Musesystems.Com",
               "Unowned testing password",
               ~i"10.100.170.10",
               instance_id: instance_id
             )

    assert %{status: :rejected} = auth_status
  end

  test "Step 2.17: Authentication Continuance Unowned Access Account / Instance" do
    assert {:ok, parial_auth_status} =
             MsbmsSystAuthentication.authenticate_email_password(
               "UnownedAccessAccount@musesystems.com",
               "Unowned testing password",
               ~i"10.100.170.10"
             )

    assert %{status: :pending} = parial_auth_status
    assert Enum.member?(parial_auth_status.pending_operations, :require_instance)

    {:ok, instance_id} =
      MsbmsSystInstanceMgr.get_instance_id_by_name("app1_owner1_instance_types_std")

    assert {:ok, complete_auth_status} =
             MsbmsSystAuthentication.authenticate_email_password(parial_auth_status,
               instance_id: instance_id
             )

    assert %{status: :authenticated} = complete_auth_status
  end

  test "Step 2.18: Failed Continuance Unowned Access Account / Bad Instance" do
    assert {:ok, partial_auth_status} =
             MsbmsSystAuthentication.authenticate_email_password(
               "UnownedAccessAccount@musesystems.com",
               "Unowned testing password",
               ~i"10.100.170.10"
             )

    assert %{status: :pending} = partial_auth_status
    assert Enum.member?(partial_auth_status.pending_operations, :require_instance)

    {:ok, instance_id} =
      MsbmsSystInstanceMgr.get_instance_id_by_name("app1_owner2_instance_types_std")

    assert {:ok, rejected_auth_status} =
             MsbmsSystAuthentication.authenticate_email_password(partial_auth_status,
               instance_id: instance_id
             )

    assert %{status: :rejected} = rejected_auth_status
  end

  test "Step 2.19: Test if Unowned Access Account Password is Recoverable" do
    {:ok, access_account_id} =
      MsbmsSystAuthentication.get_access_account_id_by_name("unowned_access_account")

    assert :ok = MsbmsSystAuthentication.access_account_credential_recoverable!(access_account_id)
  end

  test "Step 2.20: Create Unowned Access Account Email/Password Recovery Authenticator" do
    {:ok, access_account_id} =
      MsbmsSystAuthentication.get_access_account_id_by_name("unowned_access_account")

    assert :ok = MsbmsSystAuthentication.access_account_credential_recoverable!(access_account_id)

    assert {:ok, recovery_result} =
             MsbmsSystAuthentication.request_password_recovery(access_account_id,
               recovery_token: "My Known Token"
             )

    assert access_account_id == recovery_result.access_account_id
    assert nil != recovery_result[:account_identifier]
    assert "My Known Token" = recovery_result[:credential]
  end

  test "Step 2.21: Cannot Double Unowned Access Account Email/Password Recovery Authenticator" do
    {:ok, access_account_id} =
      MsbmsSystAuthentication.get_access_account_id_by_name("unowned_access_account")

    assert :existing_recovery =
             MsbmsSystAuthentication.access_account_credential_recoverable!(access_account_id)

    assert {:error, %MsbmsSystError{cause: :existing_recovery}} =
             MsbmsSystAuthentication.request_password_recovery(access_account_id,
               recovery_token: "My Known Token"
             )
  end

  test "Step 2.22: Revoke Unowned Access Account Email/Password Recovery Authenticator" do
    {:ok, access_account_id} =
      MsbmsSystAuthentication.get_access_account_id_by_name("unowned_access_account")

    assert :existing_recovery =
             MsbmsSystAuthentication.access_account_credential_recoverable!(access_account_id)

    assert {:ok, :deleted} = MsbmsSystAuthentication.revoke_password_recovery(access_account_id)
    assert {:ok, :not_found} = MsbmsSystAuthentication.revoke_password_recovery(access_account_id)
    assert :ok = MsbmsSystAuthentication.access_account_credential_recoverable!(access_account_id)
  end

  test "Step 2.23: Confirm Unowned Access Account Email/Password Recovery Authenticator" do
    # A previous test left no outstanding recovery to authenticate, so recreate here.
    {:ok, access_account_id} =
      MsbmsSystAuthentication.get_access_account_id_by_name("unowned_access_account")

    {:ok, recovery_result} =
      MsbmsSystAuthentication.request_password_recovery(access_account_id,
        recovery_token: "My Known Token"
      )

    assert :existing_recovery =
             MsbmsSystAuthentication.access_account_credential_recoverable!(access_account_id)

    # Some failure modes
    assert {:ok, disallowed_host_state} =
             MsbmsSystAuthentication.authenticate_recovery_token(
               recovery_result.account_identifier,
               "My Known Token",
               ~i"10.10.10.1"
             )

    assert %{status: :rejected_host_check} = disallowed_host_state
    assert %{applied_network_rule: %{precedence: :disallowed}} = disallowed_host_state

    assert {:ok, denied_host_state} =
             MsbmsSystAuthentication.authenticate_recovery_token(
               recovery_result.account_identifier,
               "My Known Token",
               ~i"10.100.180.125"
             )

    assert %{status: :rejected_host_check} = denied_host_state
    assert %{applied_network_rule: %{precedence: :global}} = denied_host_state

    assert {:ok, bad_token_state} =
             MsbmsSystAuthentication.authenticate_recovery_token(
               recovery_result.account_identifier,
               MsbmsSystUtils.get_random_string(20),
               ~i"10.100.170.10"
             )

    assert %{status: :rejected} = bad_token_state
    assert %{applied_network_rule: %{precedence: :global}} = bad_token_state

    # Good Attempt
    assert {:ok, auth_state} =
             MsbmsSystAuthentication.authenticate_recovery_token(
               recovery_result.account_identifier,
               "My Known Token",
               ~i"10.100.170.10"
             )

    assert %{status: :authenticated} = auth_state

    assert :ok = MsbmsSystAuthentication.access_account_credential_recoverable!(access_account_id)
  end

  test "Step 2.24: Create Account Code for Unowned Access Account" do
    {:ok, access_account_id} =
      MsbmsSystAuthentication.get_access_account_id_by_name("unowned_access_account")

    assert {:ok, authenticator_result} =
             MsbmsSystAuthentication.create_or_reset_account_code(access_account_id,
               account_code: "Unowned Access Account Code"
             )

    assert authenticator_result.access_account_id == access_account_id
    assert authenticator_result.account_identifier == "Unowned Access Account Code"
  end

  test "Step 2.25: Identify Unowned Access Account by Account Code" do
    assert {:ok, :not_found} =
             MsbmsSystAuthentication.identify_access_account_by_code("A Bad Code", nil)

    assert {:ok, %Data.SystIdentities{}} =
             MsbmsSystAuthentication.identify_access_account_by_code(
               "Unowned Access Account Code",
               nil
             )
  end

  test "Step 2.26: Reset Unowned Access Account Code" do
    {:ok, %Data.SystIdentities{} = identity} =
      MsbmsSystAuthentication.identify_access_account_by_code(
        "Unowned Access Account Code",
        nil
      )

    assert {:ok, authenticator_result} =
             MsbmsSystAuthentication.create_or_reset_account_code(identity.access_account_id)

    assert authenticator_result.access_account_id == identity.access_account_id
    assert authenticator_result.account_identifier != "Unowned Access Account Code"
  end

  test "Step 2.27: Get Account Code by Unowned Access Account ID" do
    {:ok, access_account_id} =
      MsbmsSystAuthentication.get_access_account_id_by_name("unowned_access_account")

    assert {:ok, :not_found} =
             MsbmsSystAuthentication.get_account_code_by_access_account_id(Ecto.UUID.generate())

    assert {:ok, %Data.SystIdentities{}} =
             MsbmsSystAuthentication.get_account_code_by_access_account_id(access_account_id)
  end

  test "Step 2.28: Revoke Account Code by Unowned Access Account ID" do
    {:ok, access_account_id} =
      MsbmsSystAuthentication.get_access_account_id_by_name("unowned_access_account")

    assert {:ok, :not_found} = MsbmsSystAuthentication.revoke_account_code(Ecto.UUID.generate())

    assert {:ok, :deleted} = MsbmsSystAuthentication.revoke_account_code(access_account_id)
  end

  test "Step 2.29: Create API Token for Unowned Access Account" do
    {:ok, access_account_id} =
      MsbmsSystAuthentication.get_access_account_id_by_name("unowned_access_account")

    assert {:ok, authenticator_result} =
             MsbmsSystAuthentication.create_authenticator_api_token(access_account_id,
               identity_token: "unowned_api_token_identity",
               credential_token: "unowned_api_token_credential"
             )

    assert authenticator_result.access_account_id == access_account_id
    assert authenticator_result.account_identifier == "unowned_api_token_identity"
    assert authenticator_result.credential == "unowned_api_token_credential"

    assert {:error, _} =
             MsbmsSystAuthentication.create_authenticator_api_token(access_account_id,
               identity_token: "unowned_api_token_identity",
               credential_token: "unowned_api_token_credential"
             )
  end

  test "Step 2.30: Authenticate API Token for Unowned Access Account" do
    {:ok, instance_id} =
      MsbmsSystInstanceMgr.get_instance_id_by_name("app1_owner1_instance_types_std")

    {:ok, access_account_id} =
      MsbmsSystAuthentication.get_access_account_id_by_name("unowned_access_account")

    # Some failure modes

    assert {:ok, bad_instance_state} =
             MsbmsSystAuthentication.authenticate_api_token(
               "unowned_api_token_identity",
               "unowned_api_token_credential",
               ~i"10.100.170.10",
               nil
             )

    assert bad_instance_state.status == :rejected

    assert {:ok, bad_host_state} =
             MsbmsSystAuthentication.authenticate_api_token(
               "unowned_api_token_identity",
               "unowned_api_token_credential",
               ~i"10.100.160.10",
               instance_id
             )

    assert bad_host_state.status == :rejected_host_check

    assert {:ok, bad_credential_state} =
             MsbmsSystAuthentication.authenticate_api_token(
               "unowned_api_token_identity",
               "bad_api_token_credential",
               ~i"10.100.170.10",
               instance_id
             )

    assert bad_credential_state.status == :rejected

    # Successful auth test

    assert {:ok, auth_state} =
             MsbmsSystAuthentication.authenticate_api_token(
               "unowned_api_token_identity",
               "unowned_api_token_credential",
               ~i"10.100.170.10",
               instance_id
             )

    assert auth_state.status == :authenticated
    assert auth_state.access_account_id == access_account_id
  end

  test "Step 2.31: Set Unowned Access Account API Token External Name" do
    {:ok, access_account_id} =
      MsbmsSystAuthentication.get_access_account_id_by_name("unowned_access_account")

    target_identity =
      from(i in Data.SystIdentities,
        join: ei in assoc(i, :identity_type),
        where:
          ei.internal_name == "identity_types_sysdef_api" and
            i.access_account_id == ^access_account_id
      )
      |> MsbmsSystDatastore.one!()

    assert is_nil(target_identity.external_name)

    assert {:ok, updated_identity} =
             MsbmsSystAuthentication.update_api_token_external_name(
               target_identity.id,
               "A Test API Token"
             )

    assert updated_identity.external_name == "A Test API Token"
  end

  test "Step 2.32: Revoke Unowned Access Account API Token" do
    {:ok, access_account_id} =
      MsbmsSystAuthentication.get_access_account_id_by_name("unowned_access_account")

    target_identity =
      from(i in Data.SystIdentities,
        join: ei in assoc(i, :identity_type),
        where:
          ei.internal_name == "identity_types_sysdef_api" and
            i.access_account_id == ^access_account_id
      )
      |> MsbmsSystDatastore.one!()

    assert {:ok, :deleted} = MsbmsSystAuthentication.revoke_api_token(target_identity.id)
    assert {:ok, :not_found} = MsbmsSystAuthentication.revoke_api_token(target_identity.id)
  end

  # ==============================================================================================
  #
  # Topic 3: Owned Access Accounts
  #
  # ==============================================================================================

  test "Step 3.XX: Add Owned Access Accounts" do
    {:ok, owner1_id} = MsbmsSystInstanceMgr.get_owner_id_by_name("owner1")

    state = MsbmsSystEnums.get_default_enum_item("access_account_states")

    assert {:ok, %MsbmsSystAuthentication.Data.SystAccessAccounts{} = access_account1} =
             MsbmsSystAuthentication.create_access_account(%{
               owning_owner_name: "owner1",
               internal_name: "owner1_access_account",
               external_name: "Owner 1 Access Account",
               access_account_state_id: state.id,
               allow_global_logins: false
             })

    assert access_account1.owning_owner_id == owner1_id

    {:ok, owner2_id} = MsbmsSystInstanceMgr.get_owner_id_by_name("owner2")

    assert {:ok, %MsbmsSystAuthentication.Data.SystAccessAccounts{}} =
             MsbmsSystAuthentication.create_access_account(%{
               owning_owner_id: owner2_id,
               internal_name: "owner2_access_account",
               external_name: "Owner 2 Access Account",
               access_account_state_id: state.id,
               allow_global_logins: false
             })

    # Owner 3 Access Account is just being created for later testing; doesn't
    # add much here.

    {:ok, owner3_id} = MsbmsSystInstanceMgr.get_owner_id_by_name("owner3")

    assert {:ok, %MsbmsSystAuthentication.Data.SystAccessAccounts{}} =
             MsbmsSystAuthentication.create_access_account(%{
               owning_owner_id: owner3_id,
               internal_name: "owner3_access_account",
               external_name: "Owner 3 Access Account",
               access_account_state_id: state.id,
               allow_global_logins: false
             })
  end

  test "Step 3.XX: Invite Owned Access Account to Instances" do
    # Basic Invite

    {:ok, owner1_account_id} =
      MsbmsSystAuthentication.get_access_account_id_by_name("owner1_access_account")

    {:ok, owner1_instance_id} =
      MsbmsSystInstanceMgr.get_instance_id_by_name("app1_owner1_instance_types_std")

    assert {:ok, %Data.SystAccessAccountInstanceAssocs{} = invited_aaia_owner1} =
             MsbmsSystAuthentication.invite_to_instance(owner1_account_id, owner1_instance_id)

    assert nil == invited_aaia_owner1.access_granted

    # Invite w/Custom Expiration

    {:ok, owner2_account_id} =
      MsbmsSystAuthentication.get_access_account_id_by_name("owner2_access_account")

    {:ok, owner2_instance_id} =
      MsbmsSystInstanceMgr.get_instance_id_by_name("app1_owner2_instance_types_std")

    assert {:ok, %Data.SystAccessAccountInstanceAssocs{} = invited_aaia_owner2} =
             MsbmsSystAuthentication.invite_to_instance(owner2_account_id, owner2_instance_id,
               expiration_days: 10
             )

    test_date = Date.utc_today() |> Date.add(10)

    assert :eq =
             DbTypes.compare(test_date, DateTime.to_date(invited_aaia_owner2.invitation_expires))

    assert nil == invited_aaia_owner2.access_granted

    # Invite w/Create Accepted Option

    {:ok, owner3_account_id} =
      MsbmsSystAuthentication.get_access_account_id_by_name("owner3_access_account")

    {:ok, owner3_instance_id} =
      MsbmsSystInstanceMgr.get_instance_id_by_name("app1_owner3_instance_types_std")

    assert {:ok, %Data.SystAccessAccountInstanceAssocs{} = invited_aaia_owner3} =
             MsbmsSystAuthentication.invite_to_instance(owner3_account_id, owner3_instance_id,
               create_accepted: true
             )

    assert Date.utc_today() == DateTime.to_date(invited_aaia_owner3.access_granted)
  end

  # ==============================================================================================
  #
  # Test Support Functions
  #
  # ==============================================================================================

  # Identity Rate Limit Support

  defp violate_validator_rate_limit(identifier, host_addr, owner_id, limit),
    do: violate_validator_rate_limit(identifier, host_addr, owner_id, :rejected, limit)

  defp violate_validator_rate_limit(_identifier, _host_addr, _owner_id, :rejected, 0),
    do: :test_limit_reached

  defp violate_validator_rate_limit(identifier, host_addr, owner_id, :rejected, limit) do
    {:ok, auth_state} =
      MsbmsSystAuthentication.authenticate_validation_token(
        identifier,
        MsbmsSystUtils.get_random_string(40),
        host_addr,
        owning_owner_id: owner_id
      )

    violate_validator_rate_limit(identifier, host_addr, owner_id, auth_state.status, limit - 1)
  end

  defp violate_validator_rate_limit(_identifier, _host_addr, _owner_id, status, _limit),
    do: status

  # Host Rate Limit Support

  defp violate_host_rate_limit(host_addr, limit),
    do: violate_host_rate_limit(host_addr, :rejected, limit)

  defp violate_host_rate_limit(_host_addr, :rejected, 0),
    do: :test_limit_reached

  defp violate_host_rate_limit(host_addr, :rejected, limit) do
    {:ok, auth_state} =
      MsbmsSystAuthentication.authenticate_validation_token(
        MsbmsSystUtils.get_random_string(40),
        MsbmsSystUtils.get_random_string(40),
        host_addr
      )

    violate_host_rate_limit(host_addr, auth_state.status, limit - 1)
  end

  defp violate_host_rate_limit(_host_addr, status, _limit),
    do: status
end
