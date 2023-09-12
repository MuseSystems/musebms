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

  @startup_options_path "test_startup_options.toml"
  @migrations_root_dir "../../../database/subsystems/mssub_mcp/testing_support"

  # Special Note:
  #
  # The purpose of these tests isn't to prove that MscmpSystInstance or
  # MscmpSystAuthn are working correctly on an individual basis but rather that
  # they work together when needed and that MssubMcp can make available the
  # required services upon which these components depend (Enum, Settings, Rate
  # Limiter, Database).  Given this, the tests below will be duplicative of the
  # equivalent integration tests in those modules, but not comprehensively so.

  # ==============================================================================================
  #
  # Topic 1: Application Management
  #
  # ==============================================================================================

  test "Step 1.01: Create Application" do
    app1_params = %{
      internal_name: "test_app",
      display_name: "Test App Needs Updating",
      syst_description: "Test App Description Needs Updating"
    }

    assert {:ok, new1_app} = MssubMcp.create_application(app1_params)

    assert app1_params.internal_name == new1_app.internal_name
    assert app1_params.display_name == new1_app.display_name
    assert app1_params.syst_description == new1_app.syst_description
  end

  test "Step 1.02: Update Application" do
    app_params = %{
      display_name: "Test App",
      syst_description: "Test App Description."
    }

    assert app_id = MssubMcp.get_application_id_by_name("test_app")

    assert {:ok, upd_app} = MssubMcp.update_application(app_id, app_params)

    assert app_params.display_name == upd_app.display_name
    assert app_params.syst_description == upd_app.syst_description
  end

  test "Step 1.03: Create Application Contexts" do
    assert app1_id = MssubMcp.get_application_id_by_name("test_app")

    context_params_list = [
      %{
        internal_name: "test_app_owner",
        display_name: "Test App Owner",
        application_id: app1_id,
        description: "Test App Owner",
        start_context: false,
        login_context: false,
        database_owner_context: true
      },
      %{
        internal_name: "test_app_access",
        display_name: "Test App Access Needs Updating",
        application_id: app1_id,
        description: "Test App Access Needs Updating",
        start_context: false,
        login_context: true,
        database_owner_context: false
      }
    ]

    context_params_list
    |> Enum.each(fn context_params ->
      assert {:ok, context} = MssubMcp.create_application_context(context_params)

      assert context_params.internal_name == context.internal_name
      assert context_params.display_name == context.display_name
      assert context_params.description == context.description
      assert context_params.start_context == context.start_context
      assert context_params.login_context == context.login_context
      assert context_params.database_owner_context == context.database_owner_context
    end)
  end

  test "Step 1.04: Update Application Context" do
    assert app_context_id = MssubMcp.get_application_context_id_by_name("test_app_access")

    update_params = %{
      display_name: "Test App Access",
      description: "Test App Access",
      start_context: true
    }

    assert {:ok, updated_context} =
             MssubMcp.update_application_context(app_context_id, update_params)

    assert update_params.display_name == updated_context.display_name
    assert update_params.description == updated_context.description
    assert update_params.start_context == updated_context.start_context
  end

  # ==============================================================================================
  #
  # Topic 2: Instance Management
  #
  # ==============================================================================================

  test "Step 2.01: Create Instance Types" do
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

    Enum.each(instance_type_params, fn params ->
      assert {:ok, _instance_type} = MssubMcp.create_instance_type(params)
    end)
  end

  test "Step 2.02: Create Instance Type Applications" do
    instance_type = MssubMcp.get_instance_type_by_name("instance_types_small")

    assert %Msdata.SystEnumItems{} = instance_type

    application_id = MssubMcp.get_application_id_by_name("test_app")

    assert is_binary(application_id)

    assert {:ok, %Msdata.SystInstanceTypeApplications{}} =
             MssubMcp.create_instance_type_application(instance_type.id, application_id)
  end

  test "Step 2.03: Verify Owners Don't Exist" do
    assert false == MssubMcp.owner_exists?()
    assert false == MssubMcp.owner_exists?(owner_name: "mcp_owner")
  end

  test "Step 2.04: Verify Access Accounts Don't Exist" do
    assert false == MssubMcp.access_account_exists?()
    assert false == MssubMcp.access_account_exists?(access_account_name: "platform_admin")
  end

  test "Step 2.05: Test MCP Platform Bootstrapping" do
    owner_state = MssubMcp.get_owner_state_default(:owner_states_active)

    owner_params = %{
      internal_name: "mcp_owner",
      display_name: "Platform Owner",
      owner_state_id: owner_state.id
    }

    access_account_state =
      MssubMcp.get_access_account_state_default(:access_account_states_active)

    access_account_params = %{
      internal_name: "platform_admin",
      external_name: "Platform Administrator",
      owning_owner_name: "mcp_owner",
      allow_global_logins: false,
      access_account_state_id: access_account_state.id
    }

    bootstrap_params = %{
      owner: owner_params,
      access_account: access_account_params,
      authenticator_type: :email_password,
      account_identifier: "test_platform_admin@musesystems.com",
      credential: "MCP Testing Password",
      application: :mcp
    }

    assert {:ok, _} = MssubMcp.bootstrap_tenant(bootstrap_params)
  end

  test "Step 2.06: Verify Owners Do Exist" do
    assert true == MssubMcp.owner_exists?()
    assert true == MssubMcp.owner_exists?(owner_name: "mcp_owner")
  end

  test "Step 2.07: Verify Access Accounts Do Exist" do
    assert true == MssubMcp.access_account_exists?()
    assert true == MssubMcp.access_account_exists?(access_account_name: "platform_admin")
  end

  test "Step 2.08: Create Owners" do
    owner1_state = MssubMcp.get_owner_state_default()

    owner1_params = %{
      internal_name: "test_owner1",
      display_name: "Testing Owner",
      owner_state_id: owner1_state.id
    }

    {:ok, owner1} = MssubMcp.create_owner(owner1_params)

    assert true == MssubMcp.owner_exists?(owner_id: owner1.id)

    assert owner1.internal_name == owner1_params.internal_name
    assert owner1.display_name == owner1_params.display_name
    assert owner1.owner_state_id == owner1_params.owner_state_id

    owner2_state = MssubMcp.get_owner_state_default()

    owner2_params = %{
      internal_name: "test_owner2",
      display_name: "Testing Owner 2",
      owner_state_id: owner2_state.id
    }

    {:ok, owner2} = MssubMcp.create_owner(owner2_params)

    assert owner2.internal_name == owner2_params.internal_name
    assert owner2.display_name == owner2_params.display_name
    assert owner2.owner_state_id == owner2_params.owner_state_id
  end

  # TODO: Once we add tests for Tenant.bootstrap/1, be sure to test the ability
  #       of the function to default Owner & Access Account internal names to
  #       the random string if not internal_names are not otherwise provided.

  test "Step 2.09: Create Instances w/MssubMcp.process_operation" do
    mcp_ops_func = fn ->
      new_instance1_params = %{
        internal_name: "test_app_test_owner1_inst1",
        display_name: "Test App / Test Owner 1 / Instance 1",
        application_name: "test_app",
        instance_type_name: "instance_types_small",
        owner_name: "test_owner1",
        instance_code: :crypto.strong_rand_bytes(16),
        dbserver_name: "testing_server"
      }

      assert {:ok, new_instance1} = MssubMcp.create_instance(new_instance1_params)

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

      assert {:ok, new_instance2} = MssubMcp.create_instance(new_instance2_params)

      assert new_instance2.internal_name == new_instance2_params.internal_name
      assert new_instance2.display_name == new_instance2_params.display_name
      assert new_instance2.instance_code == new_instance2_params.instance_code

      :ok
    end

    assert :ok = MssubMcp.process_operation(mcp_ops_func)
  end

  test "Step 2.10: Create Instances w/MssubMcp Wrapper API" do
    new_instance3_params = %{
      internal_name: "test_app_test_owner2_inst3",
      display_name: "Test App / Test Owner 2 / Instance 3",
      application_name: "test_app",
      instance_type_name: "instance_types_small",
      owner_name: "test_owner2",
      instance_code: :crypto.strong_rand_bytes(16),
      dbserver_name: "testing_server"
    }

    assert {:ok, new_instance3} = MssubMcp.create_instance(new_instance3_params)

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

    assert {:ok, new_instance4} = MssubMcp.create_instance(new_instance4_params)

    assert new_instance4.internal_name == new_instance4_params.internal_name
    assert new_instance4.display_name == new_instance4_params.display_name
    assert new_instance4.instance_code == new_instance4_params.instance_code
  end

  test "Step 2.11: Initialize Instances" do
    startup_options = MscmpSystOptions.get_options!(@startup_options_path)

    mcp_ops_func = fn ->
      from(i in Msdata.SystInstances)
      |> MscmpSystDb.all()
      |> Enum.each(fn test_instance ->
        assert {:ok, initialized_instance} =
                 MssubMcp.initialize_instance(test_instance.id, startup_options)

        datastore_options =
          MssubMcp.get_instance_datastore_options(
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

    assert :ok = MssubMcp.process_operation(mcp_ops_func)
  end

  test "Step 2.12: Start Instances" do
    startup_options = MscmpSystOptions.get_options!(@startup_options_path)

    assert :ok =
             MssubMcp.start_all_applications(startup_options,
               migrations_root_dir: @migrations_root_dir
             )
  end

  test "Step 2.13: Make use of Instances" do
    mcp_ops_func = fn ->
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

    assert :ok = MssubMcp.process_operation(mcp_ops_func)
  end

  # ==============================================================================================
  #
  # Topic 3: Authentication - Initial System Setup
  #
  # ==============================================================================================

  test "Step 3.01: Manage Disallowed Passwords" do
    assert false == MssubMcp.disallowed_passwords_populated?()

    assert :ok = MssubMcp.create_disallowed_password("IntegrationDuplicateTest")

    assert :ok = MssubMcp.create_disallowed_password("IntegrationDuplicateTest")

    assert :ok = MssubMcp.create_disallowed_password("IntegrationDeleteTest")

    assert {:ok, :deleted} = MssubMcp.delete_disallowed_password("IntegrationDeleteTest")

    assert {:ok, :not_found} = MssubMcp.delete_disallowed_password("IntegrationDeleteTest")

    assert :ok =
             Path.join(["database", "test_pg_disallowed_passwords.txt"])
             |> File.stream!()
             |> MssubMcp.load_disallowed_passwords(pg_format: true)

    assert :ok =
             Path.join(["database", "test_plain_disallowed_passwords.txt"])
             |> File.stream!()
             |> Stream.map(&String.trim_trailing(&1, "\n"))
             |> MssubMcp.load_disallowed_passwords()

    assert true == MssubMcp.disallowed_passwords_populated?()

    # Add password for later test usage

    assert :ok = MssubMcp.create_disallowed_password("DisallowedPassword#123#")
  end

  test "Step 3.02: Manage Global Network Rules" do
    orig_pwd_rules = MssubMcp.get_global_password_rules!()

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

    {:ok, new_pwd_rules} = MssubMcp.update_global_password_rules(orig_pwd_rules, new_rule_params)

    {:ok, _} = MssubMcp.update_global_password_rules(revert_rule_params)

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

    generic_rules = MssubMcp.get_generic_password_rules(orig_pwd_rules)

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

  test "Step 3.03: Add Owner Password Rules" do
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

    {:ok, owner_id} = MssubMcp.get_owner_id_by_name("test_owner2")

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

    assert {:ok, pwd_rules} = MssubMcp.create_owner_password_rules(owner_id, pwd_rule_params)

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

    generic_rules = MssubMcp.get_generic_password_rules(pwd_rules)

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

  test "Step 3.04: Manage Disallowed Host" do
    assert {:ok, %Msdata.SystDisallowedHosts{}} = MssubMcp.create_disallowed_host(~i"10.10.10.2")

    assert {:ok, :deleted} = MssubMcp.delete_disallowed_host_addr(~i"10.10.10.2")

    assert {:ok, :not_found} = MssubMcp.delete_disallowed_host_addr(~i"10.10.10.2")

    assert {:ok, %Msdata.SystDisallowedHosts{id: delete_id}} =
             MssubMcp.create_disallowed_host(~i"10.10.10.3")

    assert {:ok, :deleted} = MssubMcp.delete_disallowed_host(delete_id)

    assert {:ok, :not_found} = MssubMcp.delete_disallowed_host(delete_id)

    # Disallowed Host for later tests

    assert {:ok, %Msdata.SystDisallowedHosts{}} = MssubMcp.create_disallowed_host(~i"10.10.10.1")

    assert {:ok, true} = MssubMcp.host_disallowed(~i"10.10.10.1")
    assert false == MssubMcp.host_disallowed?(~i"10.10.10.2")
  end

  test "Step 3.05: Add Owner Network Rules" do
    {:ok, owner_id} = MssubMcp.get_owner_id_by_name("test_owner2")

    # The following sequence of rules should result in a file set of Owner
    # Network Rules which look like:
    #
    #  1) Allow: 10.120.170/24
    #  2) Deny:  10.120.160.1 - 10.120.190.254
    #  3) Deny:  10.120.150.0/24

    assert {:ok, _} =
             MssubMcp.create_owner_network_rule(owner_id, %{
               ordering: 1,
               functional_type: :deny,
               ip_host_or_network: ~i"10.120.150.0/24"
             })

    assert {:ok, _} =
             MssubMcp.create_owner_network_rule(owner_id, %{
               ordering: 1,
               functional_type: :deny,
               ip_host_range_lower: ~i"10.120.160.1",
               ip_host_range_upper: ~i"10.120.190.254"
             })

    assert {:ok, _} =
             MssubMcp.create_owner_network_rule(owner_id, %{
               ordering: 1,
               functional_type: :allow,
               ip_host_or_network: ~i"10.120.170.0/24"
             })
  end

  test "Step 3.06: Add Instance Network Rules" do
    {:ok, instance_id} = MssubMcp.get_instance_id_by_name("test_app_test_owner1_inst2")

    # The following sequence of rules should result in a file set of Owner
    # Network Rules which look like:
    #
    #  1) Allow: 10.130.170/24
    #  2) Deny:  10.130.160.1 - 10.130.190.254
    #  3) Deny:  10.130.150.0/24

    assert {:ok, _} =
             MssubMcp.create_instance_network_rule(instance_id, %{
               ordering: 1,
               functional_type: :deny,
               ip_host_or_network: ~i"10.130.150.0/24"
             })

    assert {:ok, _} =
             MssubMcp.create_instance_network_rule(instance_id, %{
               ordering: 1,
               functional_type: :deny,
               ip_host_range_lower: ~i"10.130.160.1",
               ip_host_range_upper: ~i"10.130.190.254"
             })

    assert {:ok, _} =
             MssubMcp.create_instance_network_rule(instance_id, %{
               ordering: 1,
               functional_type: :allow,
               ip_host_or_network: ~i"10.130.170.0/24"
             })
  end

  test "Step 3.07: Violate Host Rate Limit" do
    assert false == MssubMcp.host_disallowed?(~i"10.10.20.123")
    assert :rejected_host_check = violate_host_rate_limit(~i"10.10.20.123", 100)
    assert true == MssubMcp.host_disallowed?(~i"10.10.20.123")
  end

  # ==============================================================================================
  #
  # Topic 4: Authentication - Access Account Maintenance & Authentication
  #
  # ==============================================================================================

  test "Step 4.01: Add Owned Access Accounts" do
    {:ok, owner1_id} = MssubMcp.get_owner_id_by_name("test_owner1")

    state = MssubMcp.get_access_account_state_default()

    assert {:ok, %Msdata.SystAccessAccounts{} = access_account1} =
             MssubMcp.create_access_account(%{
               owning_owner_name: "test_owner1",
               internal_name: "owner1_access_account",
               external_name: "Owner 1 Access Account",
               access_account_state_id: state.id,
               allow_global_logins: false
             })

    assert true == MssubMcp.access_account_exists?(access_account_id: access_account1.id)

    assert access_account1.owning_owner_id == owner1_id

    {:ok, owner2_id} = MssubMcp.get_owner_id_by_name("test_owner2")

    state = MssubMcp.get_access_account_state_default()

    assert {:ok, %Msdata.SystAccessAccounts{}} =
             MssubMcp.create_access_account(%{
               owning_owner_id: owner2_id,
               internal_name: "owner2_access_account",
               external_name: "Owner 2 Access Account",
               access_account_state_id: state.id,
               allow_global_logins: false
             })
  end

  test "Step 4.02: Create Email/Password for Owned Access Account" do
    # For the Unowned Access Account type, create_validated will default to
    # false as this is the common realistic scenario.  Owned Access Accounts
    # will more likely be created already validated.
    {:ok, owner1_access_account_id} =
      MssubMcp.get_access_account_id_by_name("owner1_access_account")

    assert {:ok, owner1_result} =
             MssubMcp.create_authenticator_email_password(
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
      MssubMcp.get_access_account_id_by_name("owner2_access_account")

    # Note that the email address (account_identifier) can be the same across
    # owners so that gets tested here.
    assert {:ok, owner2_result} =
             MssubMcp.create_authenticator_email_password(
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

  test "Step 4.03: Violate Rate Limit for Owned Access Account Email Identity" do
    {:ok, owner1_id} = MssubMcp.get_owner_id_by_name("test_owner1")

    assert :rejected_rate_limited =
             violate_email_rate_limit(
               "owned.access.account@MuseSystems.Com",
               ~i"10.123.123.123",
               owner1_id,
               100
             )

    {:ok, owner2_id} = MssubMcp.get_owner_id_by_name("test_owner2")

    assert {:ok, %{status: :rejected_rate_limited}} =
             MssubMcp.authenticate_email_password(
               "owned.access.account@musesystems.com",
               MscmpSystUtils.get_random_string(40),
               ~i"10.123.123.123",
               owning_owner_id: owner2_id
             )

    _ = MscmpSystLimiter.delete_counters(:identifier, "owned.access.account@musesystems.com")

    assert {:ok, %{status: :rejected}} =
             MssubMcp.authenticate_email_password(
               "owned.access.account@musesystems.com",
               MscmpSystUtils.get_random_string(40),
               ~i"10.123.123.123",
               owning_owner_id: owner2_id
             )
  end

  test "Step 4.04: Invite Owned Access Account to Instances" do
    # Basic Invite

    {:ok, owner1_account_id} = MssubMcp.get_access_account_id_by_name("owner1_access_account")

    {:ok, owner1_instance_id} = MssubMcp.get_instance_id_by_name("test_app_test_owner1_inst1")

    assert {:ok, %Msdata.SystAccessAccountInstanceAssocs{} = invited_aaia_owner1} =
             MssubMcp.invite_to_instance(owner1_account_id, owner1_instance_id,
               create_accepted: true
             )

    assert nil != invited_aaia_owner1.access_granted

    # Invite w/Custom Expiration

    {:ok, owner2_account_id} = MssubMcp.get_access_account_id_by_name("owner2_access_account")

    {:ok, owner2_instance_id} = MssubMcp.get_instance_id_by_name("test_app_test_owner2_inst3")

    assert {:ok, %Msdata.SystAccessAccountInstanceAssocs{} = invited_aaia_owner2} =
             MssubMcp.invite_to_instance(owner2_account_id, owner2_instance_id,
               expiration_days: 10
             )

    test_date = Date.utc_today() |> Date.add(10)

    assert :eq =
             DbTypes.compare(
               test_date,
               DateTime.to_date(invited_aaia_owner2.invitation_expires)
             )

    assert nil == invited_aaia_owner2.access_granted
  end

  test "Step 4.05: Accept Instance Invite to Owned Access Account" do
    {:ok, access_account_id} = MssubMcp.get_access_account_id_by_name("owner2_access_account")

    {:ok, instance_id} = MssubMcp.get_instance_id_by_name("test_app_test_owner2_inst3")

    assert {:ok, aaia_record} = MssubMcp.accept_instance_invite(access_account_id, instance_id)

    assert %Msdata.SystAccessAccountInstanceAssocs{} = aaia_record
  end

  test "Step 4.06: Authenticate Owned Access Account using Email/Password" do
    {:ok, instance1_id} = MssubMcp.get_instance_id_by_name("test_app_test_owner1_inst1")

    {:ok, owner1_id} = MssubMcp.get_owner_id_by_name("test_owner1")

    assert {:ok, auth_status1} =
             MssubMcp.authenticate_email_password(
               "owned.access.account@MuseSystems.Com",
               "owner1.password",
               ~i"10.100.170.10",
               instance_id: instance1_id,
               owning_owner_id: owner1_id
             )

    assert %{status: :authenticated} = auth_status1

    {:ok, instance2_id} = MssubMcp.get_instance_id_by_name("test_app_test_owner2_inst3")

    {:ok, owner2_id} = MssubMcp.get_owner_id_by_name("test_owner2")

    assert {:ok, auth_status2} =
             MssubMcp.authenticate_email_password(
               "owned.access.account@MuseSystems.Com",
               "Owner2.Password.123",
               ~i"10.100.170.10",
               instance_id: instance2_id,
               owning_owner_id: owner2_id
             )

    assert %{status: :pending} = auth_status2
    assert Enum.member?(auth_status2.pending_operations, :require_mfa)
  end

  test "Step 4.07: Reset Password for Owned Access Account" do
    {:ok, instance1_id} = MssubMcp.get_instance_id_by_name("test_app_test_owner1_inst1")

    {:ok, owner1_id} = MssubMcp.get_owner_id_by_name("test_owner1")

    assert {:ok, before_auth_status} =
             MssubMcp.authenticate_email_password(
               "owned.access.account@MuseSystems.Com",
               "owner1.password",
               ~i"10.100.170.10",
               instance_id: instance1_id,
               owning_owner_id: owner1_id
             )

    assert %{status: :authenticated, access_account_id: access_account_id} = before_auth_status

    assert :ok = MssubMcp.reset_password_credential(access_account_id, "reset.owner1.password")

    assert {:ok, after_auth_status} =
             MssubMcp.authenticate_email_password(
               "owned.access.account@MuseSystems.Com",
               "reset.owner1.password",
               ~i"10.100.170.10",
               instance_id: instance1_id,
               owning_owner_id: owner1_id
             )

    assert %{status: :authenticated} = after_auth_status

    assert {:ok, oldpw_auth_status} =
             MssubMcp.authenticate_email_password(
               "owned.access.account@MuseSystems.Com",
               "owner1.password",
               ~i"10.100.170.10",
               instance_id: instance1_id,
               owning_owner_id: owner1_id
             )

    assert %{status: :rejected} = oldpw_auth_status
  end

  # ==============================================================================================
  #
  # Topic 5: Session Management
  #
  # ==============================================================================================

  test "Step 5.01: Non-expired Session Processing." do
    assert {:ok, session_name} =
             MssubMcp.create_session(%{test_key1: "test_value", test_key2: 1234},
               session_name: "test_session_5.01"
             )

    assert {:ok, %{"test_key1" => "test_value", "test_key2" => 1234}} =
             MssubMcp.get_session(session_name)

    assert :ok =
             MssubMcp.update_session(session_name, %{updated_key: "updated_value"},
               expires_after: 3600
             )

    assert {:ok, %{"updated_key" => "updated_value"}} =
             MssubMcp.get_session(session_name, expires_after: 4600)

    assert MssubMcp.process_operation(fn -> MscmpSystDb.exists?(Msdata.SystSessions) end) == true

    assert :ok = MssubMcp.delete_session(session_name)

    assert MssubMcp.process_operation(fn -> MscmpSystDb.exists?(Msdata.SystSessions) end) == false
  end

  test "Step 5.02: Get Expired Session" do
    {:ok, session_name} = MssubMcp.create_session(%{key: "value"}, expires_after: 0)

    Process.sleep(1000)

    assert {:ok, :not_found} = MssubMcp.get_session(session_name, expires_after: 3600)
  end

  test "Step 5.03: Update Expired Session" do
    {:ok, session_name} = MssubMcp.create_session(%{key: "value"}, expires_after: 0)

    Process.sleep(1000)

    assert {:ok, :not_found} =
             MssubMcp.update_session(session_name, %{updated_key: "updated_value"},
               expires_after: 3600
             )
  end

  test "Step 5.04: Delete Expired Session" do
    {:ok, session_name} = MssubMcp.create_session(%{key: "value"}, expires_after: 0)

    Process.sleep(1000)

    assert :ok = MssubMcp.delete_session(session_name)
  end

  test "Step 5.05: Purge Sessions" do
    {:ok, _} = MssubMcp.create_session(%{key: "value"}, expires_after: 0)

    {:ok, _} = MssubMcp.create_session(%{key: "value"}, expires_after: 3600)

    Process.sleep(1000)

    count_query = from(s in Msdata.SystSessions, select: count(s.id))

    # Note that the Topic 2 testing may leave some expired records behind.
    # We shouldn't depend on that here for our test, but we need to be sure
    # we accommodate the possibility here.

    assert MssubMcp.process_operation(fn -> MscmpSystDb.one(count_query) end) >= 2

    assert :ok = MssubMcp.purge_expired_sessions()

    assert MssubMcp.process_operation(fn -> MscmpSystDb.one(count_query) end) == 1
  end

  # ==============================================================================================
  #
  # Topic 6: Permissions Management
  #
  # ==============================================================================================

  test "Step 6.01: Grant Permission Role to Access Account" do
    {:ok, access_account_id} = MssubMcp.get_access_account_id_by_name("owner1_access_account")

    selector = %MscmpSystMcpPerms.Types.AccessAccountPermsSelector{
      access_account_id: access_account_id
    }

    mcp_role_id =
      MssubMcp.process_operation(fn ->
        from(pr in Msdata.SystPermRoles, where: pr.internal_name == "mcp_login", select: pr.id)
        |> MscmpSystDb.one!()
      end)

    assert :ok = MssubMcp.grant_perm_role(selector, mcp_role_id)

    assert {:error, _} = MssubMcp.grant_perm_role(selector, mcp_role_id)

    global_role_id =
      MssubMcp.process_operation(fn ->
        from(pr in Msdata.SystPermRoles, where: pr.internal_name == "global_login", select: pr.id)
        |> MscmpSystDb.one!()
      end)

    assert :ok = MssubMcp.grant_perm_role(selector, global_role_id)

    assert {:error, _} = MssubMcp.grant_perm_role(selector, global_role_id)
  end

  test "Step 6.02: Get effective Permission grants for Access Account" do
    {:ok, access_account_id} = MssubMcp.get_access_account_id_by_name("owner1_access_account")

    selector = %MscmpSystMcpPerms.Types.AccessAccountPermsSelector{
      access_account_id: access_account_id
    }

    assert {:ok, %{} = all_grants} = MssubMcp.get_effective_perm_grants(selector)

    assert {
             "mcp_login",
             %MscmpSystPerms.Types.PermGrantValue{
               view_scope: :unused,
               maint_scope: :unused,
               admin_scope: :unused,
               ops_scope: :all
             }
           } =
             Enum.find(all_grants, fn curr_grant ->
               case curr_grant do
                 {"mcp_login", _} -> true
                 _ -> false
               end
             end)

    assert {
             "global_login",
             %MscmpSystPerms.Types.PermGrantValue{
               view_scope: :unused,
               maint_scope: :unused,
               admin_scope: :unused,
               ops_scope: :all
             }
           } =
             Enum.find(all_grants, fn curr_grant ->
               case curr_grant do
                 {"global_login", _} -> true
                 _ -> false
               end
             end)

    assert {:ok, %{} = filtered1_grants} =
             MssubMcp.get_effective_perm_grants(selector,
               permissions: ["mcp_login"]
             )

    assert {
             "mcp_login",
             %MscmpSystPerms.Types.PermGrantValue{
               view_scope: :unused,
               maint_scope: :unused,
               admin_scope: :unused,
               ops_scope: :all
             }
           } =
             Enum.find(filtered1_grants, fn curr_grant ->
               case curr_grant do
                 {"mcp_login", _} -> true
                 _ -> false
               end
             end)

    assert nil ==
             Enum.find(filtered1_grants, fn curr_grant ->
               case curr_grant do
                 {"global_login", _} -> true
                 _ -> false
               end
             end)

    assert {:ok, %{} = filtered2_grants} =
             MssubMcp.get_effective_perm_grants(selector,
               permissions: "global_login"
             )

    assert {
             "global_login",
             %MscmpSystPerms.Types.PermGrantValue{
               view_scope: :unused,
               maint_scope: :unused,
               admin_scope: :unused,
               ops_scope: :all
             }
           } =
             Enum.find(filtered2_grants, fn curr_grant ->
               case curr_grant do
                 {"global_login", _} -> true
                 _ -> false
               end
             end)

    assert nil ==
             Enum.find(filtered2_grants, fn curr_grant ->
               case curr_grant do
                 {"mcp_login", _} -> true
                 _ -> false
               end
             end)
  end

  test "Step 6.03: Look-up Permission Role Record ID by Name" do
    global_role_id =
      MssubMcp.process_operation(fn ->
        from(pr in Msdata.SystPermRoles, where: pr.internal_name == "global_login", select: pr.id)
        |> MscmpSystDb.one!()
      end)

    assert ^global_role_id =
             MssubMcp.get_perm_role_id_by_name("mcp_access_accounts", "global_login")

    assert is_nil(MssubMcp.get_perm_role_id_by_name("mcp_access_accounts", "nonexistent_role"))
  end

  test "Step 6.04: List Access Account Permission Role Grants" do
    {:ok, access_account_id} = MssubMcp.get_access_account_id_by_name("owner1_access_account")

    selector = %MscmpSystMcpPerms.Types.AccessAccountPermsSelector{
      access_account_id: access_account_id
    }

    assert {:ok, perm_roles} = MssubMcp.list_perm_grants(selector)

    assert 2 == length(perm_roles)

    assert %Msdata.SystPermRoles{internal_name: "mcp_login"} =
             Enum.find(perm_roles, &(&1.internal_name == "mcp_login"))

    assert %Msdata.SystPermRoles{internal_name: "global_login"} =
             Enum.find(perm_roles, &(&1.internal_name == "global_login"))

    assert {:ok, perm_roles} = MssubMcp.list_perm_grants(selector, include_perms: true)

    assert 2 == length(perm_roles)

    assert %Msdata.SystPermRoles{internal_name: "mcp_login"} =
             mcp_login = Enum.find(perm_roles, &(&1.internal_name == "mcp_login"))

    assert %Msdata.SystPermRoleGrants{perm: %Msdata.SystPerms{}} =
             Enum.find(mcp_login.perm_role_grants, &(&1.perm.internal_name == "mcp_login"))

    assert %Msdata.SystPermRoles{internal_name: "global_login"} =
             global_login = Enum.find(perm_roles, &(&1.internal_name == "global_login"))

    assert %Msdata.SystPermRoleGrants{perm: %Msdata.SystPerms{}} =
             Enum.find(global_login.perm_role_grants, &(&1.perm.internal_name == "global_login"))
  end

  test "Step 6.05: List Access Account Permission Denials" do
    {:ok, access_account_id} = MssubMcp.get_access_account_id_by_name("owner1_access_account")

    selector = %MscmpSystMcpPerms.Types.AccessAccountPermsSelector{
      access_account_id: access_account_id
    }

    # Right now this is effectively a no-op since no explicit permission
    # denial process exists for Access Accounts
    assert {:ok, []} = MssubMcp.list_perm_denials(selector)
  end

  test "Step 6.06: Revoke Access Account Permission Role" do
    {:ok, access_account_id} = MssubMcp.get_access_account_id_by_name("owner1_access_account")

    selector = %MscmpSystMcpPerms.Types.AccessAccountPermsSelector{
      access_account_id: access_account_id
    }

    global_role_id =
      MssubMcp.process_operation(fn ->
        from(pr in Msdata.SystPermRoles, where: pr.internal_name == "global_login", select: pr.id)
        |> MscmpSystDb.one!()
      end)

    assert {:ok, :deleted} = MssubMcp.revoke_perm_role(selector, global_role_id)
    assert {:ok, :not_found} = MssubMcp.revoke_perm_role(selector, global_role_id)

    {:ok, all_grants} = MssubMcp.get_effective_perm_grants(selector)

    assert {
             "mcp_login",
             %MscmpSystPerms.Types.PermGrantValue{
               view_scope: :unused,
               maint_scope: :unused,
               admin_scope: :unused,
               ops_scope: :all
             }
           } =
             Enum.find(all_grants, fn curr_grant ->
               case curr_grant do
                 {"mcp_login", _} -> true
                 _ -> false
               end
             end)

    assert {
             "global_login",
             %MscmpSystPerms.Types.PermGrantValue{
               view_scope: :deny,
               maint_scope: :deny,
               admin_scope: :deny,
               ops_scope: :deny
             }
           } ==
             Enum.find(all_grants, fn curr_grant ->
               case curr_grant do
                 {"global_login", _} -> true
                 _ -> false
               end
             end)

    mcp_role_id =
      MssubMcp.process_operation(fn ->
        from(pr in Msdata.SystPermRoles, where: pr.internal_name == "mcp_login", select: pr.id)
        |> MscmpSystDb.one!()
      end)

    assert {:ok, :deleted} = MssubMcp.revoke_perm_role(selector, mcp_role_id)
    assert {:ok, :not_found} = MssubMcp.revoke_perm_role(selector, mcp_role_id)

    {:ok, all_grants} = MssubMcp.get_effective_perm_grants(selector)

    assert {
             "mcp_login",
             %MscmpSystPerms.Types.PermGrantValue{
               view_scope: :deny,
               maint_scope: :deny,
               admin_scope: :deny,
               ops_scope: :deny
             }
           } =
             Enum.find(all_grants, fn curr_grant ->
               case curr_grant do
                 {"mcp_login", _} -> true
                 _ -> false
               end
             end)

    assert {
             "global_login",
             %MscmpSystPerms.Types.PermGrantValue{
               view_scope: :deny,
               maint_scope: :deny,
               admin_scope: :deny,
               ops_scope: :deny
             }
           } ==
             Enum.find(all_grants, fn curr_grant ->
               case curr_grant do
                 {"global_login", _} -> true
                 _ -> false
               end
             end)
  end

  # ==============================================================================================
  #
  # Topic 7: Instance Purge & Clean-up
  #
  # ==============================================================================================

  test "Step 7.01: Stop Instances" do
    assert :ok = MssubMcp.stop_all_applications()
  end

  test "Step 7.02: Purge Instances" do
    startup_options = MscmpSystOptions.get_options!(@startup_options_path)

    purge_instance_state = MssubMcp.get_instance_state_default(:instance_states_purge_eligible)

    update_params = %{instance_state_id: purge_instance_state.id}

    mcp_ops_func = fn ->
      from(i in Msdata.SystInstances)
      |> MscmpSystDb.all()
      |> Enum.each(fn test_instance ->
        Msdata.SystInstances.update_changeset(test_instance, update_params)
        |> MscmpSystDb.update!()

        assert :ok = MssubMcp.purge_instance(test_instance.id, startup_options)
      end)
    end

    :ok = MssubMcp.process_operation(mcp_ops_func)
  end

  # ==============================================================================================
  #
  # Topic 8: Application Context Delete
  #
  # ==============================================================================================

  test "Step 8.01: Delete Application Contexts" do
    assert app_context1_id = MssubMcp.get_application_context_id_by_name("test_app_access")

    assert {:ok, :deleted} = MssubMcp.delete_application_context(app_context1_id)
    assert {:ok, :not_found} = MssubMcp.delete_application_context(app_context1_id)
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
      MssubMcp.authenticate_validation_token(
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
      MssubMcp.authenticate_email_password(
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
