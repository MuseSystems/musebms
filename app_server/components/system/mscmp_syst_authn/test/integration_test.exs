# Source File: integration_test.exs
# Location:    musebms/components/system/mscmp_syst_authn/test/integration_test.exs
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

  alias MscmpSystDb.DbTypes

  @moduletag :integration
  @moduletag :capture_log

  # ==============================================================================================
  #
  # Topic 1: Initial Authentication System Setup
  #
  # ==============================================================================================

  test "Step 1.01: Manage Disallowed Passwords" do
    assert false == MscmpSystAuthn.disallowed_passwords_populated?()

    assert :ok = MscmpSystAuthn.create_disallowed_password("IntegrationDuplicateTest")
    assert :ok = MscmpSystAuthn.create_disallowed_password("IntegrationDuplicateTest")

    assert :ok = MscmpSystAuthn.create_disallowed_password("IntegrationDeleteTest")

    assert {:ok, :deleted} = MscmpSystAuthn.delete_disallowed_password("IntegrationDeleteTest")

    assert {:ok, :not_found} = MscmpSystAuthn.delete_disallowed_password("IntegrationDeleteTest")

    assert :ok =
             Path.join(["database", "test_pg_disallowed_passwords.txt"])
             |> File.stream!()
             |> MscmpSystAuthn.load_disallowed_passwords(pg_format: true)

    assert :ok =
             Path.join(["database", "test_plain_disallowed_passwords.txt"])
             |> File.stream!()
             |> Stream.map(&String.trim_trailing(&1, "\n"))
             |> MscmpSystAuthn.load_disallowed_passwords()

    assert true == MscmpSystAuthn.disallowed_passwords_populated?()

    # Add password for later test usage

    assert :ok = MscmpSystAuthn.create_disallowed_password("DisallowedPassword#123#")
  end

  test "Step 1.02: Manage Global Network Rules" do
    orig_pwd_rules = MscmpSystAuthn.get_global_password_rules!()

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
      MscmpSystAuthn.update_global_password_rules(orig_pwd_rules, new_rule_params)

    {:ok, _} = MscmpSystAuthn.update_global_password_rules(revert_rule_params)

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

    generic_rules = MscmpSystAuthn.get_generic_password_rules(orig_pwd_rules)

    assert generic_rules.owner_id == nil
    assert generic_rules.access_account_id == nil
    assert orig_pwd_rules.password_length == generic_rules.password_length
    assert orig_pwd_rules.max_age == generic_rules.max_age
    assert orig_pwd_rules.require_upper_case == generic_rules.require_upper_case
    assert orig_pwd_rules.require_lower_case == generic_rules.require_lower_case
    assert orig_pwd_rules.require_numbers == generic_rules.require_numbers
    assert orig_pwd_rules.require_symbols == generic_rules.require_symbols
    assert orig_pwd_rules.disallow_recently_used == generic_rules.disallow_recently_used
    assert orig_pwd_rules.disallow_compromised == generic_rules.disallow_compromised
    assert orig_pwd_rules.require_mfa == generic_rules.require_mfa
    assert orig_pwd_rules.allowed_mfa_types == generic_rules.allowed_mfa_types
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

    {:ok, owner_id} = MscmpSystInstance.get_owner_id_by_name("owner2")

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
             MscmpSystAuthn.create_owner_password_rules(owner_id, pwd_rule_params)

    assert %Msdata.SystOwnerPasswordRules{} = pwd_rules
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

    generic_rules = MscmpSystAuthn.get_generic_password_rules(pwd_rules)

    assert generic_rules.owner_id == owner_id
    assert generic_rules.access_account_id == nil
    assert pwd_rules.password_length == generic_rules.password_length
    assert pwd_rules.max_age == generic_rules.max_age
    assert pwd_rules.require_upper_case == generic_rules.require_upper_case
    assert pwd_rules.require_lower_case == generic_rules.require_lower_case
    assert pwd_rules.require_numbers == generic_rules.require_numbers
    assert pwd_rules.require_symbols == generic_rules.require_symbols
    assert pwd_rules.disallow_recently_used == generic_rules.disallow_recently_used
    assert pwd_rules.disallow_compromised == generic_rules.disallow_compromised
    assert pwd_rules.require_mfa == generic_rules.require_mfa
    assert pwd_rules.allowed_mfa_types == generic_rules.allowed_mfa_types
  end

  test "Step 1.04: Manage Disallowed Host" do
    assert {:ok, %Msdata.SystDisallowedHosts{}} =
             MscmpSystAuthn.create_disallowed_host(~i"10.10.10.2")

    assert {:ok, :deleted} = MscmpSystAuthn.delete_disallowed_host_addr(~i"10.10.10.2")

    assert {:ok, :not_found} = MscmpSystAuthn.delete_disallowed_host_addr(~i"10.10.10.2")

    assert {:ok, %Msdata.SystDisallowedHosts{id: delete_id}} =
             MscmpSystAuthn.create_disallowed_host(~i"10.10.10.3")

    assert {:ok, :deleted} = MscmpSystAuthn.delete_disallowed_host(delete_id)

    assert {:ok, :not_found} = MscmpSystAuthn.delete_disallowed_host(delete_id)

    # Disallowed Host for later tests

    assert {:ok, %Msdata.SystDisallowedHosts{}} =
             MscmpSystAuthn.create_disallowed_host(~i"10.10.10.1")

    assert {:ok, true} = MscmpSystAuthn.host_disallowed(~i"10.10.10.1")
    assert false == MscmpSystAuthn.host_disallowed?(~i"10.10.10.2")
  end

  test "Step 1.05: Add Global Network Rules" do
    # The following sequence of rules should result in a file set of Global
    # Network Rules which look like:
    #
    #  1) Allow: 10.100.170/24
    #  2) Deny:  10.100.160.1 - 10.100.190.254
    #  3) Deny:  10.100.150.0/24

    assert {:ok, _} =
             MscmpSystAuthn.create_global_network_rule(%{
               ordering: 1,
               functional_type: :deny,
               ip_host_or_network: ~i"10.100.150.0/24"
             })

    assert {:ok, _} =
             MscmpSystAuthn.create_global_network_rule(%{
               ordering: 1,
               functional_type: :deny,
               ip_host_range_lower: ~i"10.100.160.1",
               ip_host_range_upper: ~i"10.100.190.254"
             })

    assert {:ok, _} =
             MscmpSystAuthn.create_global_network_rule(%{
               ordering: 1,
               functional_type: :allow,
               ip_host_or_network: ~i"10.100.170.0/24"
             })
  end

  test "Step 1.06: Add Owner Network Rules" do
    {:ok, owner_id} = MscmpSystInstance.get_owner_id_by_name("owner2")

    # The following sequence of rules should result in a file set of Owner
    # Network Rules which look like:
    #
    #  1) Allow: 10.120.170/24
    #  2) Deny:  10.120.160.1 - 10.120.190.254
    #  3) Deny:  10.120.150.0/24

    assert {:ok, _} =
             MscmpSystAuthn.create_owner_network_rule(owner_id, %{
               ordering: 1,
               functional_type: :deny,
               ip_host_or_network: ~i"10.120.150.0/24"
             })

    assert {:ok, _} =
             MscmpSystAuthn.create_owner_network_rule(owner_id, %{
               ordering: 1,
               functional_type: :deny,
               ip_host_range_lower: ~i"10.120.160.1",
               ip_host_range_upper: ~i"10.120.190.254"
             })

    assert {:ok, _} =
             MscmpSystAuthn.create_owner_network_rule(owner_id, %{
               ordering: 1,
               functional_type: :allow,
               ip_host_or_network: ~i"10.120.170.0/24"
             })
  end

  test "Step 1.07: Add Instance Network Rules" do
    {:ok, instance_id} =
      MscmpSystInstance.get_instance_id_by_name("app1_owner2_instance_types_std")

    # The following sequence of rules should result in a file set of Owner
    # Network Rules which look like:
    #
    #  1) Allow: 10.130.170/24
    #  2) Deny:  10.130.160.1 - 10.130.190.254
    #  3) Deny:  10.130.150.0/24

    assert {:ok, _} =
             MscmpSystAuthn.create_instance_network_rule(instance_id, %{
               ordering: 1,
               functional_type: :deny,
               ip_host_or_network: ~i"10.130.150.0/24"
             })

    assert {:ok, _} =
             MscmpSystAuthn.create_instance_network_rule(instance_id, %{
               ordering: 1,
               functional_type: :deny,
               ip_host_range_lower: ~i"10.130.160.1",
               ip_host_range_upper: ~i"10.130.190.254"
             })

    assert {:ok, _} =
             MscmpSystAuthn.create_instance_network_rule(instance_id, %{
               ordering: 1,
               functional_type: :allow,
               ip_host_or_network: ~i"10.130.170.0/24"
             })
  end

  test "Step 1.08: Violate Host Rate Limit" do
    assert false == MscmpSystAuthn.host_disallowed?(~i"10.10.20.123")
    assert :rejected_host_check = violate_host_rate_limit(~i"10.10.20.123", 100)
    assert true == MscmpSystAuthn.host_disallowed?(~i"10.10.20.123")
  end

  test "Step 1.09: Cannot violate Host Rate Limit using explicitly allowed Host" do
    assert false == MscmpSystAuthn.host_disallowed?(~i"10.100.170.170")
    assert :test_limit_reached = violate_host_rate_limit(~i"10.100.170.170", 100)
    assert false == MscmpSystAuthn.host_disallowed?(~i"10.100.170.170")
  end

  # ==============================================================================================
  #
  # Topic 2: Unowned Access Accounts
  #
  # ==============================================================================================

  test "Step 2.01: Add Unowned Access Accounts" do
    state = MscmpSystEnums.get_default_enum_item("access_account_states")

    assert false == MscmpSystAuthn.access_account_exists?()

    assert false ==
             MscmpSystAuthn.access_account_exists?(access_account_name: "unowned_access_account")

    assert {:ok, %Msdata.SystAccessAccounts{} = access_account} =
             MscmpSystAuthn.create_access_account(%{
               internal_name: "unowned_access_account",
               external_name: "Unowned Access Account",
               access_account_state_id: state.id,
               allow_global_logins: true
             })

    assert true == MscmpSystAuthn.access_account_exists?()

    assert true ==
             MscmpSystAuthn.access_account_exists?(access_account_name: "unowned_access_account")

    assert true == MscmpSystAuthn.access_account_exists?(access_account_id: access_account.id)
  end

  test "Step 2.02: Test Password for Unowned Access Account" do
    {:ok, access_account_id} =
      MscmpSystAuthn.get_access_account_id_by_name("unowned_access_account")

    disallowed_pgload_pwd = "load_test_password_" <> Integer.to_string(:rand.uniform(100))
    disallowed_plain_pwd = "plain_load_test_password_" <> Integer.to_string(:rand.uniform(100))

    assert {:ok, [password_rule_length_min: 8]} =
             MscmpSystAuthn.test_credential(access_account_id, "short")

    assert {:ok, [password_rule_disallowed_password: true]} =
             MscmpSystAuthn.test_credential(access_account_id, "DisallowedPassword#123#")

    assert {:ok, [password_rule_disallowed_password: true]} =
             MscmpSystAuthn.test_credential(access_account_id, disallowed_pgload_pwd)

    assert {:ok, [password_rule_disallowed_password: true]} =
             MscmpSystAuthn.test_credential(access_account_id, disallowed_plain_pwd)

    assert {:ok, []} = MscmpSystAuthn.test_credential(access_account_id, "A valid password.")
  end

  test "Step 2.03: Attempt Bad Password for Unowned Access Account" do
    # This test is more about testing the error result tuple of
    # create_authenticator_email_password/4.  We want to be sure that password
    # rule violations are easier to get to than some misc errors can be.

    {:ok, access_account_id} =
      MscmpSystAuthn.get_access_account_id_by_name("unowned_access_account")

    assert {:error, %MscmpSystError{cause: cause}} =
             MscmpSystAuthn.create_authenticator_email_password(
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
      MscmpSystAuthn.get_access_account_id_by_name("unowned_access_account")

    assert {:ok, authenticator_result} =
             MscmpSystAuthn.create_authenticator_email_password(
               access_account_id,
               "UnownedAccessAccount@MuseSystems.Com",
               "Unowned testing password"
             )

    assert access_account_id == authenticator_result.access_account_id
    assert "UnownedAccessAccount@musesystems.com" == authenticator_result.account_identifier
    assert nil != authenticator_result.validation_identifier
    assert nil != authenticator_result.validation_credential
  end

  test "Step 2.05: Violate Rate Limit for Unowned Access Account Validation Identity" do
    validator_identity =
      from(vi in Msdata.SystIdentities,
        join: emi in Msdata.SystIdentities,
        on: emi.id == vi.validates_identity_id,
        join: ei in assoc(emi, :identity_type),
        join: aa in assoc(emi, :access_account),
        where:
          aa.internal_name == "unowned_access_account" and
            ei.internal_name == "identity_types_sysdef_email" and
            is_nil(emi.validated)
      )
      |> MscmpSystDb.one!()

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
      from(i in Msdata.SystIdentities,
        join: ei in assoc(i, :identity_type),
        join: aa in assoc(i, :access_account),
        where:
          aa.internal_name == "unowned_access_account" and
            ei.internal_name == "identity_types_sysdef_email" and
            is_nil(i.validated),
        select: i.id
      )
      |> MscmpSystDb.one!()

    assert {:ok, :deleted} = MscmpSystAuthn.revoke_validator_for_identity_id(email_identity_id)

    assert {:ok, :not_found} = MscmpSystAuthn.revoke_validator_for_identity_id(email_identity_id)
  end

  test "Step 2.07: Try to set Email/Password again for Unowned Access Account" do
    # A little test to be sure that create_authenticator_email_password/4 has no
    # obvious bypasses.

    {:ok, access_account_id} =
      MscmpSystAuthn.get_access_account_id_by_name("unowned_access_account")

    assert {:error, %MscmpSystError{}} =
             MscmpSystAuthn.create_authenticator_email_password(
               access_account_id,
               "UnownedAccessAccount@MuseSystems.Com",
               "Unowned testing password"
             )
  end

  test "Step 2.08: Create New Email Validator for Unowned Access Account" do
    email_identity =
      from(i in Msdata.SystIdentities,
        join: ei in assoc(i, :identity_type),
        join: aa in assoc(i, :access_account),
        where:
          aa.internal_name == "unowned_access_account" and
            ei.internal_name == "identity_types_sysdef_email" and
            is_nil(i.validated)
      )
      |> MscmpSystDb.one!()

    assert {:ok, validator_result} =
             MscmpSystAuthn.request_identity_validation(email_identity.id,
               credential_token: "My Known Token"
             )

    assert email_identity.access_account_id == validator_result.access_account_id
    assert nil != validator_result.validation_identifier
    assert "My Known Token" = validator_result.validation_credential
  end

  test "Step 2.09: Validator confirmation for Unowned Access Account" do
    validator_identity =
      from(vi in Msdata.SystIdentities,
        join: emi in Msdata.SystIdentities,
        on: emi.id == vi.validates_identity_id,
        join: ei in assoc(emi, :identity_type),
        join: aa in assoc(emi, :access_account),
        where:
          aa.internal_name == "unowned_access_account" and
            ei.internal_name == "identity_types_sysdef_email" and
            is_nil(emi.validated)
      )
      |> MscmpSystDb.one!()

    # First try some failure modes
    assert {:ok, disallowed_host_state} =
             MscmpSystAuthn.authenticate_validation_token(
               validator_identity.account_identifier,
               "My Known Token",
               ~i"10.10.10.1"
             )

    assert %{status: :rejected_host_check} = disallowed_host_state
    assert %{applied_network_rule: %{precedence: :disallowed}} = disallowed_host_state

    assert {:ok, denied_host_state} =
             MscmpSystAuthn.authenticate_validation_token(
               validator_identity.account_identifier,
               "My Known Token",
               ~i"10.100.180.125"
             )

    assert %{status: :rejected_host_check} = denied_host_state
    assert %{applied_network_rule: %{precedence: :global}} = denied_host_state

    # Good attempt
    assert {:ok, auth_state} =
             MscmpSystAuthn.authenticate_validation_token(
               validator_identity.account_identifier,
               "My Known Token",
               ~i"10.100.170.125"
             )

    assert %{status: :authenticated} = auth_state
    assert %{applied_network_rule: %{precedence: :global}} = auth_state

    assert from(i in Msdata.SystIdentities,
             join: ei in assoc(i, :identity_type),
             join: aa in assoc(i, :access_account),
             where:
               aa.internal_name == "unowned_access_account" and
                 ei.internal_name == "identity_types_sysdef_email" and
                 not is_nil(i.validated)
           )
           |> MscmpSystDb.exists?()

    refute from(vi in Msdata.SystIdentities,
             join: emi in Msdata.SystIdentities,
             on: emi.id == vi.validates_identity_id,
             join: ei in assoc(emi, :identity_type),
             join: aa in assoc(emi, :access_account),
             where:
               aa.internal_name == "unowned_access_account" and
                 ei.internal_name == "identity_types_sysdef_email"
           )
           |> MscmpSystDb.exists?()
  end

  test "Step 2.10: Invite Unowned Access Account to Instances" do
    # Basic Invite

    {:ok, access_account_id} =
      MscmpSystAuthn.get_access_account_id_by_name("unowned_access_account")

    {:ok, owner1_instance_id} =
      MscmpSystInstance.get_instance_id_by_name("app1_owner1_instance_types_std")

    assert {:ok, %Msdata.SystAccessAccountInstanceAssocs{} = invited_aaia_owner1} =
             MscmpSystAuthn.invite_to_instance(access_account_id, owner1_instance_id)

    assert nil == invited_aaia_owner1.access_granted

    # Invite w/Custom Expiration

    {:ok, owner2_instance_id} =
      MscmpSystInstance.get_instance_id_by_name("app1_owner2_instance_types_std")

    assert {:ok, %Msdata.SystAccessAccountInstanceAssocs{} = invited_aaia_owner2} =
             MscmpSystAuthn.invite_to_instance(access_account_id, owner2_instance_id,
               expiration_days: 10
             )

    test_date = Date.utc_today() |> Date.add(10)

    assert :eq =
             DbTypes.compare(test_date, DateTime.to_date(invited_aaia_owner2.invitation_expires))

    assert nil == invited_aaia_owner2.access_granted

    # Invite w/Create Accepted Option

    {:ok, owner3_instance_id} =
      MscmpSystInstance.get_instance_id_by_name("app1_owner3_instance_types_std")

    assert {:ok, %Msdata.SystAccessAccountInstanceAssocs{} = invited_aaia_owner3} =
             MscmpSystAuthn.invite_to_instance(access_account_id, owner3_instance_id,
               create_accepted: true
             )

    assert Date.utc_today() == DateTime.to_date(invited_aaia_owner3.access_granted)
  end

  test "Step 2.11: Accept Instance Invite to Unowned Access Account" do
    {:ok, access_account_id} =
      MscmpSystAuthn.get_access_account_id_by_name("unowned_access_account")

    {:ok, instance_id} =
      MscmpSystInstance.get_instance_id_by_name("app1_owner1_instance_types_std")

    assert {:ok, aaia_record} =
             MscmpSystAuthn.accept_instance_invite(access_account_id, instance_id)

    assert %Msdata.SystAccessAccountInstanceAssocs{} = aaia_record
  end

  test "Step 2.12: Decline Instance Invite to Unowned Access Account" do
    {:ok, access_account_id} =
      MscmpSystAuthn.get_access_account_id_by_name("unowned_access_account")

    {:ok, instance_id} =
      MscmpSystInstance.get_instance_id_by_name("app1_owner2_instance_types_std")

    assert {:ok, aaia_record} =
             MscmpSystAuthn.decline_instance_invite(access_account_id, instance_id)

    assert %Msdata.SystAccessAccountInstanceAssocs{} = aaia_record
  end

  test "Step 2.13: Authenticate Unowned Access Account using Email/Password" do
    # Instance access invite was explicitly accepted in earlier step.
    {:ok, instance1_id} =
      MscmpSystInstance.get_instance_id_by_name("app1_owner1_instance_types_std")

    assert {:ok, auth_status1} =
             MscmpSystAuthn.authenticate_email_password(
               "UnownedAccessAccount@Musesystems.Com",
               "Unowned testing password",
               ~i"10.100.170.10",
               instance_id: instance1_id
             )

    assert %{status: :authenticated} = auth_status1

    # Instance access was created as accepted.
    {:ok, instance3_id} =
      MscmpSystInstance.get_instance_id_by_name("app1_owner3_instance_types_std")

    assert {:ok, auth_status3} =
             MscmpSystAuthn.authenticate_email_password(
               "UnownedAccessAccount@Musesystems.Com",
               "Unowned testing password",
               ~i"10.100.170.10",
               instance_id: instance3_id
             )

    assert %{status: :authenticated} = auth_status3
  end

  test "Step 2.14: Authenticate Unowned Access Account using Email/Password with Instance Bypass" do
    assert {:ok, auth_status1} =
             MscmpSystAuthn.authenticate_email_password(
               "UnownedAccessAccount@Musesystems.Com",
               "Unowned testing password",
               ~i"10.100.170.10",
               instance_id: :bypass
             )

    assert %{status: :authenticated} = auth_status1
  end

  test "Step 2.15: Fail Authentication Unowned Access Account / Bad Password" do
    {:ok, instance_id} =
      MscmpSystInstance.get_instance_id_by_name("app1_owner1_instance_types_std")

    assert {:ok, auth_status} =
             MscmpSystAuthn.authenticate_email_password(
               "UnownedAccessAccount@musesystems.com",
               "A Bad Password",
               ~i"10.100.170.10",
               instance_id: instance_id
             )

    assert %{status: :rejected} = auth_status
  end

  test "Step 2.16: Fail Authentication Unowned Access Account / Bad Instance" do
    # This instance access was declined in an earlier step.
    {:ok, instance_id} =
      MscmpSystInstance.get_instance_id_by_name("app1_owner2_instance_types_std")

    assert {:ok, auth_status} =
             MscmpSystAuthn.authenticate_email_password(
               "UnownedAccessAccount@Musesystems.Com",
               "Unowned testing password",
               ~i"10.100.170.10",
               instance_id: instance_id
             )

    assert %{status: :rejected} = auth_status
  end

  test "Step 2.17: Fail Authentication Unowned Access Account / Bad Email Case" do
    {:ok, instance_id} =
      MscmpSystInstance.get_instance_id_by_name("app1_owner1_instance_types_std")

    assert {:ok, auth_status} =
             MscmpSystAuthn.authenticate_email_password(
               "unownedaccessaccount@Musesystems.Com",
               "Unowned testing password",
               ~i"10.100.170.10",
               instance_id: instance_id
             )

    assert %{status: :rejected} = auth_status
  end

  test "Step 2.18: Authentication Continuance Unowned Access Account / Instance" do
    assert {:ok, parial_auth_status} =
             MscmpSystAuthn.authenticate_email_password(
               "UnownedAccessAccount@musesystems.com",
               "Unowned testing password",
               ~i"10.100.170.10"
             )

    assert %{status: :pending} = parial_auth_status
    assert Enum.member?(parial_auth_status.pending_operations, :require_instance)

    {:ok, instance_id} =
      MscmpSystInstance.get_instance_id_by_name("app1_owner1_instance_types_std")

    assert {:ok, complete_auth_status} =
             MscmpSystAuthn.authenticate_email_password(parial_auth_status,
               instance_id: instance_id
             )

    assert %{status: :authenticated} = complete_auth_status
  end

  test "Step 2.19: Failed Continuance Unowned Access Account / Bad Instance" do
    assert {:ok, partial_auth_status} =
             MscmpSystAuthn.authenticate_email_password(
               "UnownedAccessAccount@musesystems.com",
               "Unowned testing password",
               ~i"10.100.170.10"
             )

    assert %{status: :pending} = partial_auth_status
    assert Enum.member?(partial_auth_status.pending_operations, :require_instance)

    {:ok, instance_id} =
      MscmpSystInstance.get_instance_id_by_name("app1_owner2_instance_types_std")

    assert {:ok, rejected_auth_status} =
             MscmpSystAuthn.authenticate_email_password(partial_auth_status,
               instance_id: instance_id
             )

    assert %{status: :rejected} = rejected_auth_status
  end

  test "Step 2.20: Failed Continuance Unowned Access Account / Deadline Surpassed" do
    assert {:ok, parial_auth_status} =
             MscmpSystAuthn.authenticate_email_password(
               "UnownedAccessAccount@musesystems.com",
               "Unowned testing password",
               ~i"10.100.170.10"
             )

    assert %{status: :pending} = parial_auth_status
    assert Enum.member?(parial_auth_status.pending_operations, :require_instance)

    past_deadline = DateTime.utc_now() |> DateTime.add(-5, :minute)

    expired_auth_status = Map.put(parial_auth_status, :deadline, past_deadline)

    {:ok, instance_id} =
      MscmpSystInstance.get_instance_id_by_name("app1_owner1_instance_types_std")

    assert {:ok, rejected_auth_status} =
             MscmpSystAuthn.authenticate_email_password(expired_auth_status,
               instance_id: instance_id
             )

    assert %{status: :rejected_deadline_expired} = rejected_auth_status
  end

  test "Step 2.21: Test if Unowned Access Account Password is Recoverable" do
    {:ok, access_account_id} =
      MscmpSystAuthn.get_access_account_id_by_name("unowned_access_account")

    assert :ok = MscmpSystAuthn.access_account_credential_recoverable!(access_account_id)
  end

  test "Step 2.22: Create Unowned Access Account Email/Password Recovery Authenticator" do
    {:ok, access_account_id} =
      MscmpSystAuthn.get_access_account_id_by_name("unowned_access_account")

    assert :ok = MscmpSystAuthn.access_account_credential_recoverable!(access_account_id)

    assert {:ok, recovery_result} =
             MscmpSystAuthn.request_password_recovery(access_account_id,
               credential_token: "My Known Token"
             )

    assert access_account_id == recovery_result.access_account_id
    assert nil != recovery_result.account_identifier
    assert "My Known Token" = recovery_result.credential
  end

  test "Step 2.23: Cannot Double Unowned Access Account Email/Password Recovery Authenticator" do
    {:ok, access_account_id} =
      MscmpSystAuthn.get_access_account_id_by_name("unowned_access_account")

    assert :existing_recovery =
             MscmpSystAuthn.access_account_credential_recoverable!(access_account_id)

    assert {:error, %MscmpSystError{cause: :existing_recovery}} =
             MscmpSystAuthn.request_password_recovery(access_account_id,
               credential_token: "My Known Token"
             )
  end

  test "Step 2.24: Revoke Unowned Access Account Email/Password Recovery Authenticator" do
    {:ok, access_account_id} =
      MscmpSystAuthn.get_access_account_id_by_name("unowned_access_account")

    assert :existing_recovery =
             MscmpSystAuthn.access_account_credential_recoverable!(access_account_id)

    assert {:ok, :deleted} = MscmpSystAuthn.revoke_password_recovery(access_account_id)
    assert {:ok, :not_found} = MscmpSystAuthn.revoke_password_recovery(access_account_id)
    assert :ok = MscmpSystAuthn.access_account_credential_recoverable!(access_account_id)
  end

  test "Step 2.25: Confirm Unowned Access Account Email/Password Recovery Authenticator" do
    # A previous test left no outstanding recovery to authenticate, so recreate here.
    {:ok, access_account_id} =
      MscmpSystAuthn.get_access_account_id_by_name("unowned_access_account")

    {:ok, recovery_result} =
      MscmpSystAuthn.request_password_recovery(access_account_id,
        credential_token: "My Known Token"
      )

    assert :existing_recovery =
             MscmpSystAuthn.access_account_credential_recoverable!(access_account_id)

    # Some failure modes
    assert {:ok, disallowed_host_state} =
             MscmpSystAuthn.authenticate_recovery_token(
               recovery_result.account_identifier,
               "My Known Token",
               ~i"10.10.10.1"
             )

    assert %{status: :rejected_host_check} = disallowed_host_state
    assert %{applied_network_rule: %{precedence: :disallowed}} = disallowed_host_state

    assert {:ok, denied_host_state} =
             MscmpSystAuthn.authenticate_recovery_token(
               recovery_result.account_identifier,
               "My Known Token",
               ~i"10.100.180.125"
             )

    assert %{status: :rejected_host_check} = denied_host_state
    assert %{applied_network_rule: %{precedence: :global}} = denied_host_state

    assert {:ok, bad_token_state} =
             MscmpSystAuthn.authenticate_recovery_token(
               recovery_result.account_identifier,
               MscmpSystUtils.get_random_string(20),
               ~i"10.100.170.10"
             )

    assert %{status: :rejected} = bad_token_state
    assert %{applied_network_rule: %{precedence: :global}} = bad_token_state

    # Good Attempt
    assert {:ok, auth_state} =
             MscmpSystAuthn.authenticate_recovery_token(
               recovery_result.account_identifier,
               "My Known Token",
               ~i"10.100.170.10"
             )

    assert %{status: :authenticated} = auth_state

    assert :ok = MscmpSystAuthn.access_account_credential_recoverable!(access_account_id)
  end

  test "Step 2.26: Reset Password for Unowned Access Account" do
    {:ok, access_account_id} =
      MscmpSystAuthn.get_access_account_id_by_name("unowned_access_account")

    {:ok, instance1_id} =
      MscmpSystInstance.get_instance_id_by_name("app1_owner1_instance_types_std")

    assert {:ok, before_auth_status} =
             MscmpSystAuthn.authenticate_email_password(
               "UnownedAccessAccount@Musesystems.Com",
               "Unowned testing password",
               ~i"10.100.170.10",
               instance_id: instance1_id
             )

    assert %{status: :authenticated} = before_auth_status

    assert :ok =
             MscmpSystAuthn.reset_password_credential(
               access_account_id,
               "Reset unowned testing password"
             )

    assert {:ok, after_auth_status} =
             MscmpSystAuthn.authenticate_email_password(
               "UnownedAccessAccount@Musesystems.Com",
               "Reset unowned testing password",
               ~i"10.100.170.10",
               instance_id: instance1_id
             )

    assert %{status: :authenticated} = after_auth_status

    assert {:ok, oldpw_auth_status} =
             MscmpSystAuthn.authenticate_email_password(
               "UnownedAccessAccount@Musesystems.Com",
               "Unowned testing password",
               ~i"10.100.170.10",
               instance_id: instance1_id
             )

    assert %{status: :rejected} = oldpw_auth_status
  end

  test "Step 2.27: Create Account Code for Unowned Access Account" do
    {:ok, access_account_id} =
      MscmpSystAuthn.get_access_account_id_by_name("unowned_access_account")

    assert {:ok, authenticator_result} =
             MscmpSystAuthn.create_or_reset_account_code(access_account_id,
               account_code: "Unowned Access Account Code"
             )

    assert authenticator_result.access_account_id == access_account_id
    assert authenticator_result.account_identifier == "Unowned Access Account Code"
  end

  test "Step 2.28: Identify Unowned Access Account by Account Code" do
    assert {:ok, :not_found} = MscmpSystAuthn.identify_access_account_by_code("A Bad Code", nil)

    assert {:ok, %Msdata.SystIdentities{}} =
             MscmpSystAuthn.identify_access_account_by_code(
               "Unowned Access Account Code",
               nil
             )
  end

  test "Step 2.29: Reset Unowned Access Account Code" do
    {:ok, %Msdata.SystIdentities{} = identity} =
      MscmpSystAuthn.identify_access_account_by_code(
        "Unowned Access Account Code",
        nil
      )

    assert {:ok, authenticator_result} =
             MscmpSystAuthn.create_or_reset_account_code(identity.access_account_id)

    assert authenticator_result.access_account_id == identity.access_account_id
    assert authenticator_result.account_identifier != "Unowned Access Account Code"
  end

  test "Step 2.30: Get Account Code by Unowned Access Account ID" do
    {:ok, access_account_id} =
      MscmpSystAuthn.get_access_account_id_by_name("unowned_access_account")

    assert {:ok, :not_found} =
             MscmpSystAuthn.get_account_code_by_access_account_id(Ecto.UUID.generate())

    assert {:ok, %Msdata.SystIdentities{}} =
             MscmpSystAuthn.get_account_code_by_access_account_id(access_account_id)
  end

  test "Step 2.31: Revoke Account Code by Unowned Access Account ID" do
    {:ok, access_account_id} =
      MscmpSystAuthn.get_access_account_id_by_name("unowned_access_account")

    assert {:ok, :not_found} = MscmpSystAuthn.revoke_account_code(Ecto.UUID.generate())

    assert {:ok, :deleted} = MscmpSystAuthn.revoke_account_code(access_account_id)
  end

  test "Step 2.32: Create API Token for Unowned Access Account" do
    {:ok, access_account_id} =
      MscmpSystAuthn.get_access_account_id_by_name("unowned_access_account")

    assert {:ok, authenticator_result} =
             MscmpSystAuthn.create_authenticator_api_token(access_account_id,
               identity_token: "unowned_api_token_identity",
               credential_token: "unowned_api_token_credential"
             )

    assert authenticator_result.access_account_id == access_account_id
    assert authenticator_result.account_identifier == "unowned_api_token_identity"
    assert authenticator_result.credential == "unowned_api_token_credential"

    assert {:error, _} =
             MscmpSystAuthn.create_authenticator_api_token(access_account_id,
               identity_token: "unowned_api_token_identity",
               credential_token: "unowned_api_token_credential"
             )
  end

  test "Step 2.33: Authenticate API Token for Unowned Access Account" do
    {:ok, instance_id} =
      MscmpSystInstance.get_instance_id_by_name("app1_owner1_instance_types_std")

    {:ok, access_account_id} =
      MscmpSystAuthn.get_access_account_id_by_name("unowned_access_account")

    # Some failure modes

    assert {:ok, bad_instance_state} =
             MscmpSystAuthn.authenticate_api_token(
               "unowned_api_token_identity",
               "unowned_api_token_credential",
               ~i"10.100.170.10",
               nil
             )

    assert bad_instance_state.status == :rejected

    assert {:ok, bad_host_state} =
             MscmpSystAuthn.authenticate_api_token(
               "unowned_api_token_identity",
               "unowned_api_token_credential",
               ~i"10.100.160.10",
               instance_id
             )

    assert bad_host_state.status == :rejected_host_check

    assert {:ok, bad_credential_state} =
             MscmpSystAuthn.authenticate_api_token(
               "unowned_api_token_identity",
               "bad_api_token_credential",
               ~i"10.100.170.10",
               instance_id
             )

    assert bad_credential_state.status == :rejected

    # Successful auth test

    assert {:ok, auth_state} =
             MscmpSystAuthn.authenticate_api_token(
               "unowned_api_token_identity",
               "unowned_api_token_credential",
               ~i"10.100.170.10",
               instance_id
             )

    assert auth_state.status == :authenticated
    assert auth_state.access_account_id == access_account_id
  end

  test "Step 2.34: Authenticate API Token for Unowned Access Account with Instance Bypass" do
    {:ok, access_account_id} =
      MscmpSystAuthn.get_access_account_id_by_name("unowned_access_account")

    # Successful auth test

    assert {:ok, auth_state} =
             MscmpSystAuthn.authenticate_api_token(
               "unowned_api_token_identity",
               "unowned_api_token_credential",
               ~i"10.100.170.10",
               :bypass
             )

    assert auth_state.status == :authenticated
    assert auth_state.access_account_id == access_account_id
  end

  test "Step 2.35: Set Unowned Access Account API Token External Name" do
    {:ok, access_account_id} =
      MscmpSystAuthn.get_access_account_id_by_name("unowned_access_account")

    target_identity =
      from(i in Msdata.SystIdentities,
        join: ei in assoc(i, :identity_type),
        where:
          ei.internal_name == "identity_types_sysdef_api" and
            i.access_account_id == ^access_account_id
      )
      |> MscmpSystDb.one!()

    assert is_nil(target_identity.external_name)

    assert {:ok, updated_identity} =
             MscmpSystAuthn.update_api_token_external_name(
               target_identity.id,
               "A Test API Token"
             )

    assert updated_identity.external_name == "A Test API Token"
  end

  test "Step 2.36: Revoke Unowned Access Account API Token" do
    {:ok, access_account_id} =
      MscmpSystAuthn.get_access_account_id_by_name("unowned_access_account")

    target_identity =
      from(i in Msdata.SystIdentities,
        join: ei in assoc(i, :identity_type),
        where:
          ei.internal_name == "identity_types_sysdef_api" and
            i.access_account_id == ^access_account_id
      )
      |> MscmpSystDb.one!()

    assert {:ok, :deleted} = MscmpSystAuthn.revoke_api_token(target_identity.id)
    assert {:ok, :not_found} = MscmpSystAuthn.revoke_api_token(target_identity.id)
  end

  # ==============================================================================================
  #
  # Topic 3: Owned Access Accounts
  #
  # ==============================================================================================

  # Note that Owned Access Account functionality doesn't significantly differ
  # from Unowned Access Accounts in most ways; the primary difference is during
  # the authentication process where we have no known Access Account and have to
  # resolve that via an Identity record's account_identifier field.  Identifiers
  # are only unique by Owner so this is the case we most have to focus on
  # special Owned Access Account testing.  This being the case, only those tests
  # needed for later authentication related tests and the authentication tests
  # themselves will be made here.

  test "Step 3.01: Add Owned Access Accounts" do
    {:ok, owner1_id} = MscmpSystInstance.get_owner_id_by_name("owner1")

    state = MscmpSystAuthn.get_access_account_state_default()

    assert {:ok, %Msdata.SystAccessAccounts{} = access_account1} =
             MscmpSystAuthn.create_access_account(%{
               owning_owner_name: "owner1",
               internal_name: "owner1_access_account",
               external_name: "Owner 1 Access Account",
               access_account_state_id: state.id,
               allow_global_logins: false
             })

    assert access_account1.owning_owner_id == owner1_id

    {:ok, owner2_id} = MscmpSystInstance.get_owner_id_by_name("owner2")

    assert {:ok, %Msdata.SystAccessAccounts{}} =
             MscmpSystAuthn.create_access_account(%{
               owning_owner_id: owner2_id,
               internal_name: "owner2_access_account",
               external_name: "Owner 2 Access Account",
               access_account_state_id: state.id,
               allow_global_logins: false
             })

    # Owner 3 Access Account is just being created for later testing; doesn't
    # add much here.

    {:ok, owner3_id} = MscmpSystInstance.get_owner_id_by_name("owner3")

    assert {:ok, %Msdata.SystAccessAccounts{}} =
             MscmpSystAuthn.create_access_account(%{
               owning_owner_id: owner3_id,
               internal_name: "owner3_access_account",
               external_name: "Owner 3 Access Account",
               access_account_state_id: state.id,
               allow_global_logins: false
             })
  end

  test "Step 3.02: Test Password for Owned Access Account" do
    {:ok, owner1_access_account_id} =
      MscmpSystAuthn.get_access_account_id_by_name("owner1_access_account")

    assert {:ok, [password_rule_length_min: 8]} =
             MscmpSystAuthn.test_credential(owner1_access_account_id, "short")

    assert {:ok, [password_rule_disallowed_password: true]} =
             MscmpSystAuthn.test_credential(
               owner1_access_account_id,
               "DisallowedPassword#123#"
             )

    assert {:ok, []} = MscmpSystAuthn.test_credential(owner1_access_account_id, "a1b2c3d4")

    {:ok, owner2_access_account_id} =
      MscmpSystAuthn.get_access_account_id_by_name("owner2_access_account")

    assert {:ok, [password_rule_disallowed_password: true]} =
             MscmpSystAuthn.test_credential(
               owner2_access_account_id,
               "DisallowedPassword#123#"
             )

    assert {:ok, owner2_violations} =
             MscmpSystAuthn.test_credential(owner2_access_account_id, "a1b2c3d4")

    assert Enum.member?(owner2_violations, {:password_rule_length_min, 12})
    assert Enum.member?(owner2_violations, {:password_rule_required_upper, 2})
    assert Enum.member?(owner2_violations, {:password_rule_required_symbols, 2})
  end

  test "Step 3.03: Create Email/Password for Owned Access Account" do
    # For the Unowned Access Account type, create_validated will default to
    # false as this is the common realistic scenario.  Owned Access Accounts
    # will more likely be created already validated.

    {:ok, owner1_access_account_id} =
      MscmpSystAuthn.get_access_account_id_by_name("owner1_access_account")

    assert {:ok, owner1_result} =
             MscmpSystAuthn.create_authenticator_email_password(
               owner1_access_account_id,
               "owned.access.account@MuseSystems.Com",
               "owner1.password",
               create_validated: true
             )

    assert owner1_access_account_id == owner1_result.access_account_id
    assert "owned.access.account@musesystems.com" == owner1_result.account_identifier
    assert nil == owner1_result.validation_identifier
    assert nil == owner1_result.validation_credential

    {:ok, owner2_access_account_id} =
      MscmpSystAuthn.get_access_account_id_by_name("owner2_access_account")

    # Note that the email address (account_identifier) can be the same across
    # owners so that gets tested here.
    assert {:ok, owner2_result} =
             MscmpSystAuthn.create_authenticator_email_password(
               owner2_access_account_id,
               "owned.access.account@MuseSystems.Com",
               "Owner2.Password.123",
               create_validated: true
             )

    assert owner2_access_account_id == owner2_result.access_account_id
    assert "owned.access.account@musesystems.com" == owner2_result.account_identifier
    assert nil == owner2_result.validation_identifier
    assert nil == owner2_result.validation_credential
  end

  test "Step 3.04: Violate Rate Limit for Owned Access Account Email Identity" do
    {:ok, owner1_id} = MscmpSystInstance.get_owner_id_by_name("owner1")

    assert :rejected_rate_limited =
             violate_email_rate_limit(
               "owned.access.account@MuseSystems.Com",
               ~i"10.123.123.123",
               owner1_id,
               100
             )

    {:ok, owner2_id} = MscmpSystInstance.get_owner_id_by_name("owner2")

    assert {:ok, %{status: :rejected_rate_limited}} =
             MscmpSystAuthn.authenticate_email_password(
               "owned.access.account@musesystems.com",
               MscmpSystUtils.get_random_string(40),
               ~i"10.123.123.123",
               owning_owner_id: owner2_id
             )

    _ = MscmpSystLimiter.delete_counters(:identifier, "owned.access.account@musesystems.com")

    assert {:ok, %{status: :rejected}} =
             MscmpSystAuthn.authenticate_email_password(
               "owned.access.account@musesystems.com",
               MscmpSystUtils.get_random_string(40),
               ~i"10.123.123.123",
               owning_owner_id: owner2_id
             )
  end

  test "Step 3.05: Invite Owned Access Account to Instances" do
    # Basic Invite

    {:ok, owner1_account_id} =
      MscmpSystAuthn.get_access_account_id_by_name("owner1_access_account")

    {:ok, owner1_instance_id} =
      MscmpSystInstance.get_instance_id_by_name("app1_owner1_instance_types_std")

    assert {:ok, %Msdata.SystAccessAccountInstanceAssocs{} = invited_aaia_owner1} =
             MscmpSystAuthn.invite_to_instance(owner1_account_id, owner1_instance_id,
               create_accepted: true
             )

    assert nil != invited_aaia_owner1.access_granted

    # Invite w/Custom Expiration

    {:ok, owner2_account_id} =
      MscmpSystAuthn.get_access_account_id_by_name("owner2_access_account")

    {:ok, owner2_instance_id} =
      MscmpSystInstance.get_instance_id_by_name("app1_owner2_instance_types_std")

    assert {:ok, %Msdata.SystAccessAccountInstanceAssocs{} = invited_aaia_owner2} =
             MscmpSystAuthn.invite_to_instance(owner2_account_id, owner2_instance_id,
               expiration_days: 10
             )

    test_date = Date.utc_today() |> Date.add(10)

    assert :eq =
             DbTypes.compare(test_date, DateTime.to_date(invited_aaia_owner2.invitation_expires))

    assert nil == invited_aaia_owner2.access_granted
  end

  test "Step 3.06: Accept Instance Invite to Owned Access Account" do
    {:ok, access_account_id} =
      MscmpSystAuthn.get_access_account_id_by_name("owner2_access_account")

    {:ok, instance_id} =
      MscmpSystInstance.get_instance_id_by_name("app1_owner2_instance_types_std")

    assert {:ok, aaia_record} =
             MscmpSystAuthn.accept_instance_invite(access_account_id, instance_id)

    assert %Msdata.SystAccessAccountInstanceAssocs{} = aaia_record
  end

  test "Step 3.07: Authenticate Owned Access Account using Email/Password" do
    # Instance access invite was explicitly accepted in earlier step.
    {:ok, instance1_id} =
      MscmpSystInstance.get_instance_id_by_name("app1_owner1_instance_types_std")

    {:ok, owner1_id} = MscmpSystInstance.get_owner_id_by_name("owner1")

    assert {:ok, auth_status1} =
             MscmpSystAuthn.authenticate_email_password(
               "owned.access.account@MuseSystems.Com",
               "owner1.password",
               ~i"10.100.170.10",
               instance_id: instance1_id,
               owning_owner_id: owner1_id
             )

    assert %{status: :authenticated} = auth_status1

    # Instance access was created as accepted.
    {:ok, instance2_id} =
      MscmpSystInstance.get_instance_id_by_name("app1_owner2_instance_types_std")

    {:ok, owner2_id} = MscmpSystInstance.get_owner_id_by_name("owner2")

    assert {:ok, auth_status2} =
             MscmpSystAuthn.authenticate_email_password(
               "owned.access.account@MuseSystems.Com",
               "Owner2.Password.123",
               ~i"10.100.170.10",
               instance_id: instance2_id,
               owning_owner_id: owner2_id
             )

    assert %{status: :pending} = auth_status2
    assert Enum.member?(auth_status2.pending_operations, :require_mfa)

    # TODO: MFA isn't yet implemented so closing the pending authentication
    #       status in a test will come later.
  end

  test "Step 3.08: Create Account Code for Owned Access Account" do
    {:ok, access_account_id} =
      MscmpSystAuthn.get_access_account_id_by_name("owner1_access_account")

    assert {:ok, authenticator_result} =
             MscmpSystAuthn.create_or_reset_account_code(access_account_id,
               account_code: "Owner1 Access Account Code"
             )

    assert authenticator_result.access_account_id == access_account_id
    assert authenticator_result.account_identifier == "Owner1 Access Account Code"
  end

  test "Step 3.09: Identify Owned Access Account by Account Code" do
    {:ok, owner1_id} = MscmpSystInstance.get_owner_id_by_name("owner1")

    assert {:ok, :not_found} = MscmpSystAuthn.identify_access_account_by_code("A Bad Code", nil)

    assert {:ok, :not_found} =
             MscmpSystAuthn.identify_access_account_by_code(
               "Owner1 Access Account Code",
               nil
             )

    assert {:ok, %Msdata.SystIdentities{}} =
             MscmpSystAuthn.identify_access_account_by_code(
               "Owner1 Access Account Code",
               owner1_id
             )
  end

  test "Step 3.10: Create API Token for Owned Access Account" do
    {:ok, access_account_id} =
      MscmpSystAuthn.get_access_account_id_by_name("owner1_access_account")

    assert {:ok, authenticator_result} =
             MscmpSystAuthn.create_authenticator_api_token(access_account_id,
               identity_token: "owner1_api_token_identity",
               credential_token: "owner1_api_token_credential"
             )

    assert authenticator_result.access_account_id == access_account_id
    assert authenticator_result.account_identifier == "owner1_api_token_identity"
    assert authenticator_result.credential == "owner1_api_token_credential"
  end

  test "Step 3.11: Authenticate API Token for Owned Access Account" do
    {:ok, instance_id} =
      MscmpSystInstance.get_instance_id_by_name("app1_owner1_instance_types_std")

    {:ok, access_account_id} =
      MscmpSystAuthn.get_access_account_id_by_name("owner1_access_account")

    {:ok, owner1_id} = MscmpSystInstance.get_owner_id_by_name("owner1")

    # Some failure modes

    assert {:ok, bad_instance_state} =
             MscmpSystAuthn.authenticate_api_token(
               "owner1_api_token_identity",
               "owner1_api_token_credential",
               ~i"10.100.170.10",
               nil,
               owning_owner_id: owner1_id
             )

    assert bad_instance_state.status == :rejected

    assert {:ok, bad_host_state} =
             MscmpSystAuthn.authenticate_api_token(
               "owner1_api_token_identity",
               "owner1_api_token_credential",
               ~i"10.100.160.10",
               instance_id,
               owning_owner_id: owner1_id
             )

    assert bad_host_state.status == :rejected_host_check

    assert {:ok, bad_credential_state} =
             MscmpSystAuthn.authenticate_api_token(
               "owner1_api_token_identity",
               "bad_api_token_credential",
               ~i"10.100.170.10",
               instance_id,
               owning_owner_id: owner1_id
             )

    assert bad_credential_state.status == :rejected

    # Successful auth test

    assert {:ok, auth_state} =
             MscmpSystAuthn.authenticate_api_token(
               "owner1_api_token_identity",
               "owner1_api_token_credential",
               ~i"10.100.170.10",
               instance_id,
               owning_owner_id: owner1_id
             )

    assert auth_state.status == :authenticated
    assert auth_state.access_account_id == access_account_id
  end

  # ==============================================================================================
  #
  # Topic 4: Enumeration Access Functions
  #
  # ==============================================================================================

  test "Step 4.01: Can retrieve Identity Type by Internal Name" do
    assert %Msdata.SystEnumItems{internal_name: "identity_types_sysdef_account"} =
             MscmpSystAuthn.get_identity_type_by_name("identity_types_sysdef_account")

    assert nil == MscmpSystAuthn.get_identity_type_by_name("nonexistent_type")
  end

  test "Step 4.02: Can retrieve system default Identity Type" do
    assert %Msdata.SystEnumItems{internal_name: "identity_types_sysdef_email"} =
             MscmpSystAuthn.get_identity_type_default()
  end

  test "Step 4.03: Can retrieve functional type default Identity Type" do
    assert %Msdata.SystEnumItems{internal_name: "identity_types_sysdef_api"} =
             MscmpSystAuthn.get_identity_type_default(:identity_types_api)
  end

  test "Step 4.04: Can retrieve Credential Type by Internal Name" do
    assert %Msdata.SystEnumItems{internal_name: "credential_types_sysdef_mfa_totp"} =
             MscmpSystAuthn.get_credential_type_by_name("credential_types_sysdef_mfa_totp")

    assert nil == MscmpSystAuthn.get_credential_type_by_name("nonexistent_type")
  end

  test "Step 4.05: Can retrieve system default Credential Type" do
    assert %Msdata.SystEnumItems{internal_name: "credential_types_sysdef_password"} =
             MscmpSystAuthn.get_credential_type_default()
  end

  test "Step 4.06: Can retrieve functional type default Credential Type" do
    assert %Msdata.SystEnumItems{internal_name: "credential_types_sysdef_token_api"} =
             MscmpSystAuthn.get_credential_type_default(:credential_types_token_api)
  end

  test "Step 4.07: Can retrieve Access Account State by Internal Name" do
    assert %Msdata.SystEnumItems{internal_name: "access_account_states_sysdef_active"} =
             MscmpSystAuthn.get_access_account_state_by_name(
               "access_account_states_sysdef_active"
             )

    assert nil == MscmpSystAuthn.get_access_account_state_by_name("nonexistent_type")
  end

  test "Step 4.08: Can retrieve system default Access Account State" do
    assert %Msdata.SystEnumItems{internal_name: "access_account_states_sysdef_pending"} =
             MscmpSystAuthn.get_access_account_state_default(nil)
  end

  test "Step 4.09: Can retrieve functional type default Access Account State" do
    assert %Msdata.SystEnumItems{internal_name: "access_account_states_sysdef_inactive"} =
             MscmpSystAuthn.get_access_account_state_default(:access_account_states_inactive)
  end

  # ==============================================================================================
  #
  # Test Support Functions
  #
  # ==============================================================================================

  # Identity Rate Limit Support / Validator

  defp violate_validator_rate_limit(identifier, host_addr, owner_id, limit),
    do: violate_validator_rate_limit(identifier, host_addr, owner_id, :rejected, limit)

  defp violate_validator_rate_limit(_identifier, _host_addr, _owner_id, :rejected, 0),
    do: :test_limit_reached

  defp violate_validator_rate_limit(identifier, host_addr, owner_id, :rejected, limit) do
    {:ok, auth_state} =
      MscmpSystAuthn.authenticate_validation_token(
        identifier,
        MscmpSystUtils.get_random_string(40),
        host_addr,
        owning_owner_id: owner_id
      )

    violate_validator_rate_limit(identifier, host_addr, owner_id, auth_state.status, limit - 1)
  end

  defp violate_validator_rate_limit(_identifier, _host_addr, _owner_id, status, _limit),
    do: status

  # Identity Rate Limit Support / Email

  defp violate_email_rate_limit(identifier, host_addr, owner_id, limit),
    do: violate_email_rate_limit(identifier, host_addr, owner_id, :rejected, limit)

  defp violate_email_rate_limit(_identifier, _host_addr, _owner_id, :rejected, 0),
    do: :test_limit_reached

  defp violate_email_rate_limit(identifier, host_addr, owner_id, :rejected, limit) do
    {:ok, auth_state} =
      MscmpSystAuthn.authenticate_email_password(
        identifier,
        MscmpSystUtils.get_random_string(40),
        host_addr,
        owning_owner_id: owner_id
      )

    violate_email_rate_limit(identifier, host_addr, owner_id, auth_state.status, limit - 1)
  end

  defp violate_email_rate_limit(_identifier, _host_addr, _owner_id, status, _limit),
    do: status

  # Host Rate Limit Support

  defp violate_host_rate_limit(host_addr, limit),
    do: violate_host_rate_limit(host_addr, :rejected, limit)

  defp violate_host_rate_limit(_host_addr, :rejected, 0),
    do: :test_limit_reached

  defp violate_host_rate_limit(host_addr, :rejected, limit) do
    {:ok, auth_state} =
      MscmpSystAuthn.authenticate_validation_token(
        MscmpSystUtils.get_random_string(40),
        MscmpSystUtils.get_random_string(40),
        host_addr
      )

    violate_host_rate_limit(host_addr, auth_state.status, limit - 1)
  end

  defp violate_host_rate_limit(_host_addr, status, _limit),
    do: status
end
