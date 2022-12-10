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
  @moduletag :capture_log

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

  test "Step 1: Create Application Failure Conditions" do
    fail1_params = %{
      internal_name: "ap",
      display_name: "Fail internal name too short",
      syst_description: "Fail internal name"
    }

    assert {:error, _} = MscmpSystInstance.create_application(fail1_params)

    fail2_params = %{
      internal_name: "fail_app2",
      display_name: "short",
      syst_description: "Fail display name"
    }

    assert {:error, _} = MscmpSystInstance.create_application(fail2_params)

    fail3_params = %{
      internal_name: "fail_app3",
      display_name: "No Desc"
    }

    assert {:error, _} = MscmpSystInstance.create_application(fail3_params)
  end

  test "Step 2: Create Application" do
    app1_params = %{
      internal_name: "app1",
      display_name: "App 1 Needs Updating",
      syst_description: "App One Description Needs Updating"
    }

    assert {:ok, new1_app} = MscmpSystInstance.create_application(app1_params)

    assert app1_params.internal_name == new1_app.internal_name
    assert app1_params.display_name == new1_app.display_name
    assert app1_params.syst_description == new1_app.syst_description

    app2_params = %{
      internal_name: "app2",
      display_name: "App #2",
      syst_description: "App Two Description"
    }

    assert {:ok, new2_app} = MscmpSystInstance.create_application(app2_params)

    assert app2_params.internal_name == new2_app.internal_name
    assert app2_params.display_name == new2_app.display_name
    assert app2_params.syst_description == new2_app.syst_description
  end

  test "Step 3: Update Application" do
    app_params = %{
      display_name: "App #1",
      syst_description: "App One Description."
    }

    assert app_id = MscmpSystInstance.get_application_id_by_name("app1")

    assert {:ok, upd_app} = MscmpSystInstance.update_application(app_id, app_params)

    assert app_params.display_name == upd_app.display_name
    assert app_params.syst_description == upd_app.syst_description
  end

  test "Step 4: Create Application Contexts" do
    assert app1_id = MscmpSystInstance.get_application_id_by_name("app1")

    context_params_list = [
      %{
        internal_name: "app1_owner",
        display_name: "App 1 Owner",
        application_id: app1_id,
        description: "App 1 Owner",
        start_context: false,
        login_context: false,
        database_owner_context: true
      },
      %{
        internal_name: "app1_appusr",
        display_name: "App 1 AppUsr Needs Updating",
        application_id: app1_id,
        description: "App 1 AppUsr Needs Updating",
        start_context: false,
        login_context: true,
        database_owner_context: false
      },
      %{
        internal_name: "app1_apiusr",
        display_name: "App 1 ApiUsr",
        application_id: app1_id,
        description: "App 1 API user Context",
        start_context: true,
        login_context: true,
        database_owner_context: false
      },
      %{
        internal_name: "app2_owner",
        display_name: "App 2 Owner",
        application_name: "app2",
        description: "App 2 Owner",
        start_context: false,
        login_context: false,
        database_owner_context: true
      },
      %{
        internal_name: "app2_appusr",
        display_name: "App 2 AppUsr",
        application_name: "app2",
        description: "App 2 App",
        start_context: true,
        login_context: true,
        database_owner_context: false
      },
      %{
        internal_name: "app2_apiusr",
        display_name: "App 2 ApiUsr",
        application_name: "app2",
        description: "App 2 API",
        start_context: true,
        login_context: true,
        database_owner_context: false
      }
    ]

    context_params_list
    |> Enum.each(fn context_params ->
      assert {:ok, context} = MscmpSystInstance.create_application_context(context_params)

      assert context_params.internal_name == context.internal_name
      assert context_params.display_name == context.display_name
      assert context_params.description == context.description
      assert context_params.start_context == context.start_context
      assert context_params.login_context == context.login_context
      assert context_params.database_owner_context == context.database_owner_context
    end)
  end

  test "Step 5: Update Application Contexts" do
    assert app_context_id = MscmpSystInstance.get_application_context_id_by_name("app1_appusr")

    update_params = %{
      display_name: "App 1 AppUsr",
      description: "App 1 AppUsr",
      start_context: true
    }

    assert {:ok, updated_context} =
             MscmpSystInstance.update_application_context(app_context_id, update_params)

    assert update_params.display_name == updated_context.display_name
    assert update_params.description == updated_context.description
    assert update_params.start_context == updated_context.start_context
  end

  test "Step 6: Create Instance Types" do
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

  test "Step 7: Create Instance Type Applications" do
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

  test "Step 8: Update Instance Type Context Defaults" do
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

  test "Step 9: Create Owners" do
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

  test "Step 10: Create Instances" do
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

  test "Step 11: Initialize Instances" do
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

  test "Step 12: Start Instances" do
    assert :ok =
             MscmpSystInstance.start_all_applications(@startup_options,
               migrations_root_dir:
                 "../../../database/components/system/mscmp_syst_instance/testing_support"
             )
  end

  test "Step 13: Make use of Instances" do
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

  test "Step 14: Stop Instances" do
    assert :ok = MscmpSystInstance.stop_all_applications([])
  end

  test "Step 15: Purge Instances" do
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

  test "Step 16: Delete Application Contexts" do
    assert app_context1_id = MscmpSystInstance.get_application_context_id_by_name("app1_apiusr")
    assert app_context2_id = MscmpSystInstance.get_application_context_id_by_name("app1_appusr")
    assert app_context3_id = MscmpSystInstance.get_application_context_id_by_name("app2_apiusr")
    assert app_context4_id = MscmpSystInstance.get_application_context_id_by_name("app2_appusr")

    assert {:ok, :deleted} = MscmpSystInstance.delete_application_context(app_context1_id)
    assert {:ok, :not_found} = MscmpSystInstance.delete_application_context(app_context1_id)

    assert {:ok, :deleted} = MscmpSystInstance.delete_application_context(app_context2_id)
    assert {:ok, :deleted} = MscmpSystInstance.delete_application_context(app_context3_id)
    assert {:ok, :deleted} = MscmpSystInstance.delete_application_context(app_context4_id)
  end
end
