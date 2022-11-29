# Source File: integration_test.exs
# Location:    musebms/subsystems/mssub_mcp/test/integration_test.exs
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
  use ExUnit.Case, async: false

  import Ecto.Query
  import IP, only: [sigil_i: 2]

  alias MscmpSystDb.DbTypes

  @moduletag :integration
  @moduletag :capture_log

  @startup_options_path "ms_startup_options.toml"
  @migrations_root_dir "../../database/subsystems/mssub_mcp/testing_support"

  # ==============================================================================================
  #
  # Topic 1: Instance Management
  #
  # ==============================================================================================

  test "Step 1.01: Create Instance Types" do
    instance_type_params = [
      %{
        internal_name: "instance_types_small",
        display_name: "Instance Type / Small",
        external_name: "Small Instance",
        user_description: "A small instance type",
        user_options: %{allowed_server_pools: ["primary"]}
      },
      %{
        internal_name: "instance_types_big",
        display_name: "Instance Type / Big",
        external_name: "Big Instance",
        user_description: "A big instance type",
        user_options: %{allowed_server_pools: ["primary"]}
      }
    ]

    mcp_operations = fn ->
      Enum.each(instance_type_params, fn params ->
        assert {:ok, _instance_type} = MscmpSystInstance.create_instance_type(params)
      end)
    end

    assert :ok = MssubMcp.process_operation(mcp_operations)
  end

  test "Step 1.02: Create Instance Type Applications" do
    mcp_operations = fn ->
      instance_type = MscmpSystInstance.get_instance_type_by_name("instance_types_small")

      application_id = MscmpSystInstance.get_application_id_by_name("test_app")

      MscmpSystInstance.create_instance_type_application(instance_type.id, application_id)
    end

    assert {:ok, %Msdata.SystInstanceTypeApplications{}} =
             MssubMcp.process_operation(mcp_operations)
  end

  test "Step 1.03: Create Owners" do
    mcp_operations = fn ->
      owner1_state = MscmpSystInstance.get_owner_state_default()

      owner1_params = %{
        internal_name: "test_owner1",
        display_name: "Testing Owner",
        owner_state_id: owner1_state.id
      }

      {:ok, owner1} = MscmpSystInstance.create_owner(owner1_params)

      assert owner1.internal_name == owner1_params.internal_name
      assert owner1.display_name == owner1_params.display_name
      assert owner1.owner_state_id == owner1_params.owner_state_id

      owner2_state = MscmpSystInstance.get_owner_state_default()

      owner2_params = %{
        internal_name: "test_owner2",
        display_name: "Testing Owner 2",
        owner_state_id: owner2_state.id
      }

      {:ok, owner2} = MscmpSystInstance.create_owner(owner2_params)

      assert owner2.internal_name == owner2_params.internal_name
      assert owner2.display_name == owner2_params.display_name
      assert owner2.owner_state_id == owner2_params.owner_state_id

      :ok
    end

    assert :ok = MssubMcp.process_operation(mcp_operations)
  end

  test "Step 1.04: Create Instances" do
    mcp_operations = fn ->
      new_instance1_params = %{
        internal_name: "test_app_test_owner1_inst1",
        display_name: "Test App / Test Owner 1 / Instance 1",
        application_name: "test_app",
        instance_type_name: "instance_types_small",
        owner_name: "test_owner1",
        instance_code: :crypto.strong_rand_bytes(16),
        dbserver_name: "testing_server"
      }

      assert {:ok, new_instance1} = MscmpSystInstance.create_instance(new_instance1_params)

      assert new_instance1.internal_name == new_instance1_params.internal_name
      assert new_instance1.display_name == new_instance1_params.display_name
      assert new_instance1.instance_code == new_instance1_params.instance_code

      new_instance2_params = %{
        internal_name: "test_app_test_owner1_inst2",
        display_name: "Test App / Test Owner 1 / Instance 2",
        application_name: "test_app",
        instance_type_name: "instance_types_small",
        owner_name: "test_owner2",
        instance_code: :crypto.strong_rand_bytes(16),
        dbserver_name: "testing_server"
      }

      assert {:ok, new_instance2} = MscmpSystInstance.create_instance(new_instance2_params)

      assert new_instance2.internal_name == new_instance2_params.internal_name
      assert new_instance2.display_name == new_instance2_params.display_name
      assert new_instance2.instance_code == new_instance2_params.instance_code

      new_instance3_params = %{
        internal_name: "test_app_test_owner2_inst3",
        display_name: "Test App / Test Owner 2 / Instance 3",
        application_name: "test_app",
        instance_type_name: "instance_types_small",
        owner_name: "test_owner2",
        instance_code: :crypto.strong_rand_bytes(16),
        dbserver_name: "testing_server"
      }

      assert {:ok, new_instance3} = MscmpSystInstance.create_instance(new_instance3_params)

      assert new_instance3.internal_name == new_instance3_params.internal_name
      assert new_instance3.display_name == new_instance3_params.display_name
      assert new_instance3.instance_code == new_instance3_params.instance_code

      new_instance4_params = %{
        internal_name: "test_app_test_owner2_inst4",
        display_name: "Test App / Test Owner 2 / Instance 4",
        application_name: "test_app",
        instance_type_name: "instance_types_small",
        owner_name: "test_owner2",
        instance_code: :crypto.strong_rand_bytes(16),
        dbserver_name: "testing_server"
      }

      assert {:ok, new_instance4} = MscmpSystInstance.create_instance(new_instance4_params)

      assert new_instance4.internal_name == new_instance4_params.internal_name
      assert new_instance4.display_name == new_instance4_params.display_name
      assert new_instance4.instance_code == new_instance4_params.instance_code

      :ok
    end

    assert :ok = MssubMcp.process_operation(mcp_operations)
  end

  test "Step 1.05: Initialize Instances" do
    startup_options = MscmpSystOptions.get_options!(@startup_options_path)

    mcp_operations = fn ->
      from(i in Msdata.SystInstances)
      |> MscmpSystDb.all()
      |> Enum.each(fn test_instance ->
        assert {:ok, initialized_instance} =
                 MscmpSystInstance.initialize_instance(test_instance.id, startup_options)

        datastore_options =
          MscmpSystInstance.get_instance_datastore_options(
            initialized_instance.id,
            startup_options
          )

        assert {:ok, :ready, context_states} = MscmpSystDb.get_datastore_state(datastore_options)

        Enum.each(context_states, &assert(%{context: _, state: :ready} = &1))

        assert "instance_states_initialized" =
                 MscmpSystEnums.get_functional_type_by_enum_item_id(
                   "instance_states",
                   initialized_instance.instance_state_id
                 )
      end)
    end

    assert :ok = MssubMcp.process_operation(mcp_operations)
  end

  test "Step 1.06: Start Instances" do
    startup_options = MscmpSystOptions.get_options!(@startup_options_path)

    mcp_operations = fn ->
      MscmpSystInstance.start_all_applications(startup_options,
        migrations_root_dir: @migrations_root_dir
      )
    end

    assert :ok = MssubMcp.process_operation(mcp_operations)
  end

  test "Step 1.07: Make use of Instances" do
    mcp_operations = fn ->
      from(
        ic in Msdata.SystInstanceContexts,
        join: a in assoc(ic, :application_context),
        where: a.login_context and a.start_context,
        select: [:internal_name]
      )
      |> MscmpSystDb.all()
      |> Enum.each(fn context ->
        starting_datastore_context =
          MscmpSystDb.put_datastore_context(String.to_atom(context.internal_name))

        assert MscmpSystDb.query_for_value!("""
               SELECT true
                 FROM testing.test_header
                WHERE test_value = '#{context.internal_name}'
                LIMIT 1;
               """)

        MscmpSystDb.put_datastore_context(starting_datastore_context)
      end)
    end

    assert :ok = MssubMcp.process_operation(mcp_operations)
  end

  # ==============================================================================================
  #
  # Topic 2: Authentication - Initial System Setup
  #
  # ==============================================================================================

  test "Step 2.01: Manage Disallowed Passwords" do
    assert :ok =
             MssubMcp.process_operation(fn ->
               MscmpSystAuthn.create_disallowed_password("IntegrationDuplicateTest")
             end)

    assert :ok =
             MssubMcp.process_operation(fn ->
               MscmpSystAuthn.create_disallowed_password("IntegrationDuplicateTest")
             end)

    assert :ok =
             MssubMcp.process_operation(fn ->
               MscmpSystAuthn.create_disallowed_password("IntegrationDeleteTest")
             end)

    assert {:ok, :deleted} =
             MssubMcp.process_operation(fn ->
               MscmpSystAuthn.delete_disallowed_password("IntegrationDeleteTest")
             end)

    assert {:ok, :not_found} =
             MssubMcp.process_operation(fn ->
               MscmpSystAuthn.delete_disallowed_password("IntegrationDeleteTest")
             end)

    # Add password for later test usage

    assert :ok =
             MssubMcp.process_operation(fn ->
               MscmpSystAuthn.create_disallowed_password("DisallowedPassword#123#")
             end)
  end

  test "Step 2.02: Manage Global Network Rules" do
    mcp_operations = fn ->
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

      :ok
    end

    assert :ok = MssubMcp.process_operation(mcp_operations)
  end

  test "Step 2.03: Add Owner Password Rules" do
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

    mcp_operations = fn ->
      {:ok, owner_id} = MscmpSystInstance.get_owner_id_by_name("test_owner2")

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

      :ok
    end

    assert :ok = MssubMcp.process_operation(mcp_operations)
  end

  test "Step 2.04: Manage Disallowed Host" do
    mcp_operations = fn ->
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

      :ok
    end

    assert :ok = MssubMcp.process_operation(mcp_operations)
  end

  test "Step 2.05: Add Owner Network Rules" do
    mcp_operations = fn ->
      {:ok, owner_id} = MscmpSystInstance.get_owner_id_by_name("test_owner2")

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

      :ok
    end

    assert :ok = MssubMcp.process_operation(mcp_operations)
  end

  test "Step 2.06: Add Instance Network Rules" do
    mcp_operations = fn ->
      {:ok, instance_id} = MscmpSystInstance.get_instance_id_by_name("test_app_test_owner1_inst2")

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

      :ok
    end

    assert :ok = MssubMcp.process_operation(mcp_operations)
  end

  test "Step 2.07: Violate Host Rate Limit" do
    mcp_operations = fn ->
      assert false == MscmpSystAuthn.host_disallowed?(~i"10.10.20.123")
      assert :rejected_host_check = violate_host_rate_limit(~i"10.10.20.123", 100)
      assert true == MscmpSystAuthn.host_disallowed?(~i"10.10.20.123")
      :ok
    end

    assert :ok = MssubMcp.process_operation(mcp_operations)
  end

  # ==============================================================================================
  #
  # Topic 3: Authentication - Access Account Maintenance & Authentication
  #
  # ==============================================================================================

  test "Step 3.01: Add Owned Access Accounts" do
    assert :ok =
             MssubMcp.process_operation(fn ->
               {:ok, owner1_id} = MscmpSystInstance.get_owner_id_by_name("test_owner1")

               state = MscmpSystAuthn.get_access_account_state_default()

               assert {:ok, %Msdata.SystAccessAccounts{} = access_account1} =
                        MscmpSystAuthn.create_access_account(%{
                          owning_owner_name: "test_owner1",
                          internal_name: "owner1_access_account",
                          external_name: "Owner 1 Access Account",
                          access_account_state_id: state.id,
                          allow_global_logins: false
                        })

               assert access_account1.owning_owner_id == owner1_id

               :ok
             end)

    assert :ok =
             MssubMcp.process_operation(fn ->
               {:ok, owner2_id} = MscmpSystInstance.get_owner_id_by_name("test_owner2")

               state = MscmpSystAuthn.get_access_account_state_default()

               assert {:ok, %Msdata.SystAccessAccounts{}} =
                        MscmpSystAuthn.create_access_account(%{
                          owning_owner_id: owner2_id,
                          internal_name: "owner2_access_account",
                          external_name: "Owner 2 Access Account",
                          access_account_state_id: state.id,
                          allow_global_logins: false
                        })

               :ok
             end)
  end

  test "Step 3.02: Create Email/Password for Owned Access Account" do
    # For the Unowned Access Account type, create_validated will default to
    # false as this is the common realistic scenario.  Owned Access Accounts
    # will more likely be created already validated.
    owner1_mcp_ops = fn ->
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
      assert nil == owner1_result[:validation_identifier]
      assert nil == owner1_result[:validation_credential]
      :ok
    end

    owner2_mcp_ops = fn ->
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
      assert nil == owner2_result[:validation_identifier]
      assert nil == owner2_result[:validation_credential]
      :ok
    end

    assert :ok = MssubMcp.process_operation(owner1_mcp_ops)
    assert :ok = MssubMcp.process_operation(owner2_mcp_ops)
  end

  test "Step 3.03: Violate Rate Limit for Owned Access Account Email Identity" do
    owner1_mcp_ops = fn ->
      {:ok, owner1_id} = MscmpSystInstance.get_owner_id_by_name("test_owner1")

      assert :rejected_rate_limited =
               violate_email_rate_limit(
                 "owned.access.account@MuseSystems.Com",
                 ~i"10.123.123.123",
                 owner1_id,
                 100
               )

      :ok
    end

    owner2_mcp_ops = fn ->
      {:ok, owner2_id} = MscmpSystInstance.get_owner_id_by_name("test_owner2")

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

      :ok
    end

    assert :ok = MssubMcp.process_operation(owner1_mcp_ops)
    assert :ok = MssubMcp.process_operation(owner2_mcp_ops)
  end

  test "Step 3.04: Invite Owned Access Account to Instances" do
    # Basic Invite

    owner1_mcp_ops = fn ->
      {:ok, owner1_account_id} =
        MscmpSystAuthn.get_access_account_id_by_name("owner1_access_account")

      {:ok, owner1_instance_id} =
        MscmpSystInstance.get_instance_id_by_name("test_app_test_owner1_inst1")

      assert {:ok, %Msdata.SystAccessAccountInstanceAssocs{} = invited_aaia_owner1} =
               MscmpSystAuthn.invite_to_instance(owner1_account_id, owner1_instance_id,
                 create_accepted: true
               )

      assert nil != invited_aaia_owner1.access_granted

      :ok
    end

    # Invite w/Custom Expiration

    owner2_mcp_ops = fn ->
      {:ok, owner2_account_id} =
        MscmpSystAuthn.get_access_account_id_by_name("owner2_access_account")

      {:ok, owner2_instance_id} =
        MscmpSystInstance.get_instance_id_by_name("test_app_test_owner2_inst3")

      assert {:ok, %Msdata.SystAccessAccountInstanceAssocs{} = invited_aaia_owner2} =
               MscmpSystAuthn.invite_to_instance(owner2_account_id, owner2_instance_id,
                 expiration_days: 10
               )

      test_date = Date.utc_today() |> Date.add(10)

      assert :eq =
               DbTypes.compare(
                 test_date,
                 DateTime.to_date(invited_aaia_owner2.invitation_expires)
               )

      assert nil == invited_aaia_owner2.access_granted

      :ok
    end

    assert :ok = MssubMcp.process_operation(owner1_mcp_ops)
    assert :ok = MssubMcp.process_operation(owner2_mcp_ops)
  end

  test "Step 3.05: Accept Instance Invite to Owned Access Account" do
    mcp_operations = fn ->
      {:ok, access_account_id} =
        MscmpSystAuthn.get_access_account_id_by_name("owner2_access_account")

      {:ok, instance_id} = MscmpSystInstance.get_instance_id_by_name("test_app_test_owner2_inst3")

      assert {:ok, aaia_record} =
               MscmpSystAuthn.accept_instance_invite(access_account_id, instance_id)

      assert %Msdata.SystAccessAccountInstanceAssocs{} = aaia_record

      :ok
    end

    assert :ok = MssubMcp.process_operation(mcp_operations)
  end

  test "Step 3.06: Authenticate Owned Access Account using Email/Password" do
    owner1_mcp_ops = fn ->
      {:ok, instance1_id} =
        MscmpSystInstance.get_instance_id_by_name("test_app_test_owner1_inst1")

      {:ok, owner1_id} = MscmpSystInstance.get_owner_id_by_name("test_owner1")

      assert {:ok, auth_status1} =
               MscmpSystAuthn.authenticate_email_password(
                 "owned.access.account@MuseSystems.Com",
                 "owner1.password",
                 ~i"10.100.170.10",
                 instance_id: instance1_id,
                 owning_owner_id: owner1_id
               )

      assert %{status: :authenticated} = auth_status1
      :ok
    end

    owner2_mcp_ops = fn ->
      {:ok, instance2_id} =
        MscmpSystInstance.get_instance_id_by_name("test_app_test_owner2_inst3")

      {:ok, owner2_id} = MscmpSystInstance.get_owner_id_by_name("test_owner2")

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

      :ok
    end

    assert :ok = MssubMcp.process_operation(owner1_mcp_ops)
    assert :ok = MssubMcp.process_operation(owner2_mcp_ops)
  end

  # ==============================================================================================
  #
  # Topic 4: Instance Purge & Clean-up
  #
  # ==============================================================================================

  test "Step 4.01: Stop Instances" do
    MssubMcp.process_operation(fn ->
      MscmpSystInstance.stop_all_applications()
    end)

    assert true
  end

  test "Step 4.02: Purge Instances" do
    startup_options = MscmpSystOptions.get_options!(@startup_options_path)

    mcp_operations = fn ->
      purge_instance_state =
        MscmpSystInstance.get_instance_state_default(:instance_states_purge_eligible)

      update_params = %{instance_state_id: purge_instance_state.id}

      from(i in Msdata.SystInstances)
      |> MscmpSystDb.all()
      |> Enum.each(fn test_instance ->
        Msdata.SystInstances.update_changeset(test_instance, update_params)
        |> MscmpSystDb.update!()

        assert :ok = MscmpSystInstance.purge_instance(test_instance.id, startup_options)
      end)
    end

    assert :ok = MssubMcp.process_operation(mcp_operations)
  end

  # ==============================================================================================
  #
  # Test Support Functions
  #
  # ==============================================================================================

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
end
