# Source File: integration_test.exs
# Location:    musebms/components/system/msbms_syst_instance_mgr/test/integration_test.exs
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

  alias MsbmsSystInstanceMgr.Data

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
        dbadmin_password: "msbms.syst.dba.testing.password",
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
        internal_name: "instance_types_std",
        display_name: "Instance Type / Standard",
        external_name: "Standard Instance",
        user_description: "A Standard instance type",
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
      assert {:ok, _instance_type} = MsbmsSystInstanceMgr.create_instance_type(params)
    end)
  end

  test "Step 2: Create Instance Type Applications" do
    instance_type = MsbmsSystEnums.get_enum_item_by_name("instance_types", "instance_types_sml")

    application_id =
      from(a in Data.SystApplications, where: a.internal_name == "app1", select: a.id)
      |> MsbmsSystDatastore.one!()

    assert {:ok, _} =
             MsbmsSystInstanceMgr.create_instance_type_application(
               instance_type.id,
               application_id
             )

    instance_type = MsbmsSystEnums.get_enum_item_by_name("instance_types", "instance_types_std")

    application_id =
      from(a in Data.SystApplications, where: a.internal_name == "app2", select: a.id)
      |> MsbmsSystDatastore.one!()

    assert {:ok, _} =
             MsbmsSystInstanceMgr.create_instance_type_application(
               instance_type.id,
               application_id
             )
  end

  test "Step 3: Update Instance Type Context Defaults" do
    from(
      itc in Data.SystInstanceTypeContexts,
      join: ita in assoc(itc, :instance_type_application),
      join: it in assoc(ita, :instance_type),
      join: ac in assoc(itc, :application_context),
      preload: [instance_type_application: {ita, instance_type: it}, application_context: ac],
      where: ac.login_context
    )
    |> MsbmsSystDatastore.all()
    |> Enum.each(fn instance_type_context ->
      db_pool_size =
        case instance_type_context.instance_type_application.instance_type.internal_name do
          "instance_types_sml" -> 1
          "instance_types_std" -> 3
          _ -> 0
        end

      assert {:ok, %Data.SystInstanceTypeContexts{default_db_pool_size: updated_db_pool_size}} =
               MsbmsSystInstanceMgr.update_instance_type_context(instance_type_context, %{
                 default_db_pool_size: db_pool_size
               })

      assert db_pool_size == updated_db_pool_size
    end)
  end

  test "Step 4: Create Owners" do
    owner1_state = MsbmsSystEnums.get_default_enum_item("owner_states")

    owner1_params = %{
      internal_name: "owner1",
      display_name: "Owner 1",
      owner_state_id: owner1_state.id
    }

    assert {:ok, owner1} = MsbmsSystInstanceMgr.create_owner(owner1_params)

    assert owner1.internal_name == owner1_params.internal_name
    assert owner1.display_name == owner1_params.display_name
    assert owner1.owner_state_id == owner1_params.owner_state_id

    owner2_state =
      MsbmsSystEnums.get_default_enum_item(
        "owner_states",
        functional_type_name: "owner_states_inactive"
      )

    owner2_params = %{
      internal_name: "owner2",
      display_name: "Owner 2",
      owner_state_id: owner2_state.id
    }

    assert {:ok, owner2} = MsbmsSystInstanceMgr.create_owner(owner2_params)

    assert owner2.internal_name == owner2_params.internal_name
    assert owner2.display_name == owner2_params.display_name
    assert owner2.owner_state_id == owner2_params.owner_state_id
  end

  test "Step 5: Create Instances" do
    new_instance1_params = %{
      internal_name: "app1_owner1",
      display_name: "App 1 / Owner 1",
      application_name: "app1",
      instance_type_name: "instance_types_sml",
      owner_name: "owner1",
      instance_code: :crypto.strong_rand_bytes(16),
      dbserver_name: "testing_db_server"
    }

    assert {:ok, new_instance1} = MsbmsSystInstanceMgr.create_instance(new_instance1_params)

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

    assert {:ok, new_instance2} = MsbmsSystInstanceMgr.create_instance(new_instance2_params)

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

    assert {:ok, new_instance3} = MsbmsSystInstanceMgr.create_instance(new_instance3_params)

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

    assert {:ok, new_instance4} = MsbmsSystInstanceMgr.create_instance(new_instance4_params)

    assert new_instance4.internal_name == new_instance4_params.internal_name
    assert new_instance4.display_name == new_instance4_params.display_name
    assert new_instance4.instance_code == new_instance4_params.instance_code
  end

  test "Step 6: Initialize Instances" do
    from(i in Data.SystInstances)
    |> MsbmsSystDatastore.all()
    |> Enum.each(fn test_instance ->
      assert {:ok, initialized_instance} =
               MsbmsSystInstanceMgr.initialize_instance(test_instance.id, @startup_options)

      datastore_options =
        MsbmsSystInstanceMgr.get_instance_datastore_options(
          initialized_instance.id,
          @startup_options
        )

      assert {:ok, :ready, context_states} =
               MsbmsSystDatastore.get_datastore_state(datastore_options)

      Enum.each(context_states, &assert(%{context: _, state: :ready} = &1))

      assert "instance_states_initialized" =
               MsbmsSystEnums.get_functional_type_by_enum_item_id(
                 "instance_states",
                 initialized_instance.instance_state_id
               )
    end)
  end

  test "Step 7: Start Instances" do
    assert :ok =
             MsbmsSystInstanceMgr.start_all_applications(@startup_options,
               migrations_root_dir:
                 "../../../database/components/system/msbms_syst_instance_mgr/testing_support"
             )
  end

  test "Step 8: Make use of Instances" do
    from(
      ic in Data.SystInstanceContexts,
      join: a in assoc(ic, :application_context),
      where: a.login_context and a.start_context,
      select: [:internal_name]
    )
    |> MsbmsSystDatastore.all()
    |> Enum.each(fn context ->
      starting_datastore_context = MsbmsSystDatastore.current_datastore_context()

      MsbmsSystDatastore.set_datastore_context(String.to_atom(context.internal_name))

      assert MsbmsSystDatastore.query_for_value!("""
             SELECT true
               FROM testing.test_header
              WHERE test_value = '#{context.internal_name}'
              LIMIT 1;
             """)

      MsbmsSystDatastore.set_datastore_context(starting_datastore_context)
    end)
  end

  test "Step 9: Stop Instances" do
    assert :ok = MsbmsSystInstanceMgr.stop_all_applications([])
  end

  test "Step 10: Purge Instances" do
    %MsbmsSystEnums.Data.SystEnumItems{id: purge_instance_state_id} =
      MsbmsSystEnums.get_default_enum_item(
        "instance_states",
        functional_type_name: "instance_states_purge_eligible"
      )

    update_params = %{instance_state_id: purge_instance_state_id}

    from(i in Data.SystInstances)
    |> MsbmsSystDatastore.all()
    |> Enum.each(fn test_instance ->
      Data.SystInstances.update_changeset(test_instance, update_params)
      |> MsbmsSystDatastore.update!()

      assert :ok = MsbmsSystInstanceMgr.purge_instance(test_instance.id, @startup_options)
    end)
  end
end
