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

  test "Step 1.08: Stop Instances" do
    MssubMcp.process_operation(fn ->
      MscmpSystInstance.stop_all_applications()
    end)

    assert true
  end

  test "Step 1.09: Purge Instances" do
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
end
