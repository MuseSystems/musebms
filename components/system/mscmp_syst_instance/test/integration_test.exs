# Source File: integration_test.exs
# Location:    musebms/components/system/mscmp_syst_instance/test/integration_test.exs
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
  use InstanceMgrTestCase, async: false

  import Ecto.Query

  @moduletag :integration

  @startup_options %{
    global_dbserver_name: "testing_db_server",
    global_pepper_value: :crypto.strong_rand_bytes(16),
    available_server_pools: ["primary"],
    dbserver: [
      %{
        server_name: "testing_db_server",
        start_server_instances: false,
        server_pools: ["primary"],
        db_host: "127.0.0.1",
        db_port: 5432,
        db_show_sensitive: true,
        db_max_instances: 0,
        server_salt: :crypto.strong_rand_bytes(16),
        dbadmin_password: "muse.syst.dba.testing.password",
        dbadmin_pool_size: 1
      }
    ]
  }

  test "Step 1: Create Instance Types" do
    instance_type_params = [
      %{
        internal_name: "instance_types_sml",
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
      test_internal_name = params.internal_name

      assert {:ok, %Msdata.SystEnumItems{internal_name: ^test_internal_name}} =
               MscmpSystInstance.create_instance_type(params)
    end)

    assert nil ==
             MscmpSystInstance.get_instance_type_default()

    assert {:ok, %Msdata.SystEnumItems{internal_name: "instance_types_std"}} =
             MscmpSystInstance.create_instance_type(%{
               internal_name: "instance_types_std",
               display_name: "Instance Type / Standard",
               external_name: "Standard Instance",
               user_description: "A Standard instance type",
               enum_default: true,
               user_options: %{allowed_server_pools: ["primary"]}
             })

    assert %Msdata.SystEnumItems{internal_name: "instance_types_std"} =
             MscmpSystInstance.get_instance_type_default()
  end

  test "Step 2: Create Instance Type Applications" do
    inst_type_small = MscmpSystInstance.get_instance_type_by_name("instance_types_sml")
    assert %Msdata.SystEnumItems{internal_name: "instance_types_sml"} = inst_type_small

    app1_id = MscmpSystInstance.get_application_id_by_name("app1")

    assert is_binary(app1_id)

    assert {:ok, _} =
             MscmpSystInstance.create_instance_type_application(inst_type_small.id, app1_id)

    inst_type_std = MscmpSystInstance.get_instance_type_by_name("instance_types_std")
    assert %Msdata.SystEnumItems{internal_name: "instance_types_std"} = inst_type_std

    app2_id = MscmpSystInstance.get_application_id_by_name("app2")

    assert is_binary(app2_id)

    assert {:ok, _} =
             MscmpSystInstance.create_instance_type_application(inst_type_std.id, app2_id)
  end

  test "Step 3: Update Instance Type Context Defaults" do
    from(
      itc in Msdata.SystInstanceTypeContexts,
      join: ita in assoc(itc, :instance_type_application),
      join: it in assoc(ita, :instance_type),
      join: ac in assoc(itc, :application_context),
      preload: [instance_type_application: {ita, instance_type: it}, application_context: ac],
      where: ac.login_context
    )
    |> MscmpSystDb.all()
    |> Enum.each(fn instance_type_context ->
      db_pool_size =
        case instance_type_context.instance_type_application.instance_type.internal_name do
          "instance_types_sml" -> 1
          "instance_types_std" -> 3
          _ -> 0
        end

      assert {:ok, %Msdata.SystInstanceTypeContexts{default_db_pool_size: updated_db_pool_size}} =
               MscmpSystInstance.update_instance_type_context(instance_type_context, %{
                 default_db_pool_size: db_pool_size
               })

      assert db_pool_size == updated_db_pool_size
    end)
  end

  test "Step 4: Create Owners" do
    assert %Msdata.SystEnumItems{internal_name: "owner_states_sysdef_active"} =
             owner1_state = MscmpSystInstance.get_owner_state_default()

    owner1_params = %{
      internal_name: "owner1",
      display_name: "Owner 1",
      owner_state_id: owner1_state.id
    }

    assert {:ok, owner1} = MscmpSystInstance.create_owner(owner1_params)

    assert owner1.internal_name == owner1_params.internal_name
    assert owner1.display_name == owner1_params.display_name
    assert owner1.owner_state_id == owner1_params.owner_state_id

    assert owner2_state = MscmpSystInstance.get_owner_state_default(:owner_states_inactive)

    owner2_params = %{
      internal_name: "owner2",
      display_name: "Owner 2",
      owner_state_id: owner2_state.id
    }

    assert {:ok, owner2} = MscmpSystInstance.create_owner(owner2_params)

    assert owner2.internal_name == owner2_params.internal_name
    assert owner2.display_name == owner2_params.display_name
    assert owner2.owner_state_id == owner2_params.owner_state_id
  end

  test "Step 5: Create Instances" do
    assert %Msdata.SystEnumItems{internal_name: "instance_states_sysdef_uninitialized"} =
             MscmpSystInstance.get_instance_state_default()

    new_instance1_params = %{
      internal_name: "app1_owner1",
      display_name: "App 1 / Owner 1",
      application_name: "app1",
      instance_type_name: "instance_types_sml",
      owner_name: "owner1",
      instance_code: :crypto.strong_rand_bytes(16),
      dbserver_name: "testing_db_server"
    }

    assert {:ok, new_instance1} = MscmpSystInstance.create_instance(new_instance1_params)

    assert new_instance1.internal_name == new_instance1_params.internal_name
    assert new_instance1.display_name == new_instance1_params.display_name
    assert new_instance1.instance_code == new_instance1_params.instance_code

    new_instance2_params = %{
      internal_name: "app1_owner2",
      display_name: "App 1 / Owner 2",
      application_name: "app1",
      instance_type_name: "instance_types_sml",
      owner_name: "owner2",
      instance_code: :crypto.strong_rand_bytes(16),
      dbserver_name: "testing_db_server"
    }

    assert {:ok, new_instance2} = MscmpSystInstance.create_instance(new_instance2_params)

    assert new_instance2.internal_name == new_instance2_params.internal_name
    assert new_instance2.display_name == new_instance2_params.display_name
    assert new_instance2.instance_code == new_instance2_params.instance_code

    new_instance3_params = %{
      internal_name: "app2_owner1",
      display_name: "App 2 / Owner 1",
      application_name: "app2",
      instance_type_name: "instance_types_std",
      owner_name: "owner1",
      instance_code: :crypto.strong_rand_bytes(16),
      dbserver_name: "testing_db_server"
    }

    assert {:ok, new_instance3} = MscmpSystInstance.create_instance(new_instance3_params)

    assert new_instance3.internal_name == new_instance3_params.internal_name
    assert new_instance3.display_name == new_instance3_params.display_name
    assert new_instance3.instance_code == new_instance3_params.instance_code

    new_instance4_params = %{
      internal_name: "app2_owner2",
      display_name: "App 2 / Owner 2",
      application_name: "app2",
      instance_type_name: "instance_types_std",
      owner_name: "owner2",
      instance_code: :crypto.strong_rand_bytes(16),
      dbserver_name: "testing_db_server"
    }

    assert {:ok, new_instance4} = MscmpSystInstance.create_instance(new_instance4_params)

    assert new_instance4.internal_name == new_instance4_params.internal_name
    assert new_instance4.display_name == new_instance4_params.display_name
    assert new_instance4.instance_code == new_instance4_params.instance_code
  end

  test "Step 6: Initialize Instances" do
    from(i in Msdata.SystInstances)
    |> MscmpSystDb.all()
    |> Enum.each(fn test_instance ->
      assert {:ok, initialized_instance} =
               MscmpSystInstance.initialize_instance(test_instance.id, @startup_options)

      datastore_options =
        MscmpSystInstance.get_instance_datastore_options(
          initialized_instance.id,
          @startup_options
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

  test "Step 7: Start Instances" do
    assert :ok =
             MscmpSystInstance.start_all_applications(@startup_options,
               migrations_root_dir:
                 "../../../database/components/system/mscmp_syst_instance/testing_support"
             )
  end

  test "Step 8: Make use of Instances" do
    from(
      ic in Msdata.SystInstanceContexts,
      join: a in assoc(ic, :application_context),
      where: a.login_context and a.start_context,
      select: [:internal_name]
    )
    |> MscmpSystDb.all()
    |> Enum.each(fn context ->
      starting_datastore_context = MscmpSystDb.current_datastore_context()

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

  test "Step 9: Stop Instances" do
    assert :ok = MscmpSystInstance.stop_all_applications([])
  end

  test "Step 10: Purge Instances" do
    %Msdata.SystEnumItems{id: purge_instance_state_id} =
      MscmpSystInstance.get_instance_state_default(:instance_states_purge_eligible)

    assert is_binary(purge_instance_state_id)

    update_params = %{instance_state_id: purge_instance_state_id}

    from(i in Msdata.SystInstances)
    |> MscmpSystDb.all()
    |> Enum.each(fn test_instance ->
      Msdata.SystInstances.update_changeset(test_instance, update_params)
      |> MscmpSystDb.update!()

      assert :ok = MscmpSystInstance.purge_instance(test_instance.id, @startup_options)
    end)
  end
end
