defmodule MsbmsSystInstanceMgrTest do
  use ExUnit.Case, async: true

  alias Mix.Tasks.Builddb

  @datastore_context_name :instmgr_app_context

  @datastore_options %{
    database_name: "msbms_syst_instance_mgr",
    database_owner: "msbms_syst_instance_mgr_owner",
    datastore_code: "msbms_syst_instance_mgr.testing.code",
    datastore_name: :msbms_syst_instance_mgr,
    contexts: [
      %{
        id: nil,
        description: "MsBmsSystInstanceMgr Testing Owner",
        database_role: "msbms_syst_instance_mgr_owner",
        database_password: nil,
        starting_pool_size: 0,
        start_context: false,
        login_context: false
      },
      %{
        id: @datastore_context_name,
        description: "MsBmsSystInstanceMgr Testing App User",
        database_role: "msbms_syst_instance_mgr_app_user",
        database_password: 'msbms_syst_instance_mgr.testing.code.app.user',
        starting_pool_size: 20,
        start_context: true,
        login_context: true
      },
      %{
        id: :msbms_syst_instance_mgr_api_user,
        description: "MsBmsSystInstanceMgr Testing Api User",
        database_role: "msbms_syst_instance_mgr_api_user",
        database_password: 'msbms_syst_instance_mgr.testing.code.app.user',
        starting_pool_size: 3,
        start_context: true,
        login_context: true
      }
    ],
    db_server: %{
      server_name: :test_server,
      start_server_databases: true,
      instance_production_dbserver: false,
      instance_sandbox_dbserver: true,
      db_host: "127.0.0.1",
      db_port: "5432",
      db_show_sensitive: true,
      db_log_level: :debug,
      db_max_databases: 1,
      context_defaults: [],
      server_salt: "msbms_syst_instance_mgr.testing.code.test.salt",
      dbadmin_password: "msbms.syst.dba.testing.password",
      dbadmin_pool_size: 1
    }
  }

  @migration_test_source_root_dir "../../../database"
  @migration_test_datastore_type "cmp_msbms_syst_instance_mgr"

  #  This testing presumes that the database schema is tested separately and is
  #  correct here.

  setup_all do
    setup_testing_database()

    on_exit(&cleanup_testing_database/0)
  end

  setup_all do
    setup_enums_service()
  end

  setup %{} do
    [datastore_context: MsbmsSystDatastore.set_datastore_context(@datastore_context_name)]
  end

  defp setup_testing_database do
    :ok = build_migrations()

    datastore_options = @datastore_options

    {:ok, :ready, _} = MsbmsSystDatastore.create_datastore(datastore_options)

    {:ok, _} =
      MsbmsSystDatastore.upgrade_datastore(
        datastore_options,
        @migration_test_datastore_type,
        msbms_owner: datastore_options.database_owner,
        msbms_appusr: "msbms_syst_instance_mgr_app_user",
        msbms_apiusr: "msbms_syst_instance_mgr_api_user"
      )

    {:ok, _, _} = MsbmsSystDatastore.start_datastore(datastore_options)
  end

  defp cleanup_testing_database do
    datastore_options = @datastore_options
    :ok = MsbmsSystDatastore.drop_datastore(datastore_options)
    File.rm_rf!("priv/database/cmp_msbms_syst_instance_mgr")
  end

  defp build_migrations do
    Builddb.run([
      "-t",
      @migration_test_datastore_type,
      "-c",
      "-s",
      @migration_test_source_root_dir
    ])
  end

  defp setup_enums_service do
    service_child_spec = %{
      id: MsbmsSystInstanceMgrTestingEnumService,
      start: {MsbmsSystEnums, :start_link, [{:instance_mgr, @datastore_context_name}]}
    }

    start_supervised!(service_child_spec)
    :ok
  end

  doctest MsbmsSystInstanceMgr

  test "Can List Applications" do
    assert {:ok, apps} = MsbmsSystInstanceMgr.list_applications()
    assert 2 = length(apps)
    assert %MsbmsSystInstanceMgr.Data.SystApplications{internal_name: "test_app_1"} = hd(apps)
  end

  test "Can List All Owners" do
    assert {:ok, owners} = MsbmsSystInstanceMgr.list_owners()
    assert 4 <= length(owners)
  end

  test "Can List Sorted Owners" do
    assert {:ok, owners} = MsbmsSystInstanceMgr.list_owners(sort: true)
    assert 4 <= length(owners)
    assert %{owner_internal_name: "owner_1"} = hd(owners)
  end

  test "Can List Owners by Status" do
    assert {:ok, owners} =
             MsbmsSystInstanceMgr.list_owners(
               owner_state_functional_types: [:owner_states_active]
             )

    assert 2 <= length(owners)
  end

  test "Can List Sorted Owners by Status" do
    assert {:ok, owners} =
             MsbmsSystInstanceMgr.list_owners(
               sort: true,
               owner_state_functional_types: [:owner_states_inactive]
             )

    assert 2 <= length(owners)
    assert %{owner_internal_name: "owner_2"} = hd(owners)
  end

  test "Can Create New Owner" do
    default_owner_state = MsbmsSystEnums.get_default_enum_item(:instance_mgr, "owner_states")

    assert {:ok, %MsbmsSystInstanceMgr.Data.SystOwners{internal_name: "owner_create_1"}} =
             MsbmsSystInstanceMgr.create_owner(
               "owner_create_1",
               "Owner Create Test",
               default_owner_state.id
             )
  end

  test "Can Change Existing Owner Internal Name" do
    change = %{internal_name: "changed_owner_create_2"}

    default_owner_state = MsbmsSystEnums.get_default_enum_item(:instance_mgr, "owner_states")

    {:ok, test_owner} =
      MsbmsSystInstanceMgr.create_owner(
        "owner_create_2",
        "Owner Change Internal Name Test",
        default_owner_state.id
      )

    assert {:ok, %MsbmsSystInstanceMgr.Data.SystOwners{internal_name: "changed_owner_create_2"}} =
             MsbmsSystInstanceMgr.set_owner_values(test_owner.id, change)
  end

  test "Can Change Existing Owner Display Name" do
    change = %{display_name: "Owner Change Display Name Test Is Changed"}

    default_owner_state = MsbmsSystEnums.get_default_enum_item(:instance_mgr, "owner_states")

    {:ok, test_owner} =
      MsbmsSystInstanceMgr.create_owner(
        "owner_create_3",
        "Owner Change Display Name Test",
        default_owner_state.id
      )

    assert {:ok,
            %MsbmsSystInstanceMgr.Data.SystOwners{
              display_name: "Owner Change Display Name Test Is Changed"
            }} = MsbmsSystInstanceMgr.set_owner_values(test_owner.id, change)
  end

  test "Can Change Existing Owner Owner State" do
    default_owner_state = MsbmsSystEnums.get_default_enum_item(:instance_mgr, "owner_states")

    new_state =
      MsbmsSystEnums.get_default_enum_item(:instance_mgr, "owner_states",
        functional_type_name: "owner_states_inactive"
      )

    change = %{owner_state_id: new_state.id}

    {:ok, test_owner} =
      MsbmsSystInstanceMgr.create_owner(
        "owner_create_4",
        "Owner Change Owner State Test",
        default_owner_state.id
      )

    assert {:ok,
            %MsbmsSystInstanceMgr.Data.SystOwners{
              owner_state_id: updated_id
            }} = MsbmsSystInstanceMgr.set_owner_values(test_owner.id, change)

    assert new_state.id == updated_id
  end

  test "Can Change Existing Owner Multiple Values" do
    default_owner_state = MsbmsSystEnums.get_default_enum_item(:instance_mgr, "owner_states")

    new_state =
      MsbmsSystEnums.get_default_enum_item(:instance_mgr, "owner_states",
        functional_type_name: "owner_states_inactive"
      )

    change = %{
      owner_state_id: new_state.id,
      internal_name: "owner_create_5_changed",
      display_name: "Owner Change Owner Multi Test Changed"
    }

    {:ok, test_owner} =
      MsbmsSystInstanceMgr.create_owner(
        "owner_create_5",
        "Owner Change Owner Multi Test",
        default_owner_state.id
      )

    assert {:ok, updated_owner} = MsbmsSystInstanceMgr.set_owner_values(test_owner.id, change)

    assert new_state.id == updated_owner.owner_state_id
    assert "owner_create_5_changed" == updated_owner.internal_name
    assert "Owner Change Owner Multi Test Changed" == updated_owner.display_name
  end

  test "Can Purge a Single Purge Eligible Owner" do
    default_owner_state =
      MsbmsSystEnums.get_default_enum_item(:instance_mgr, "owner_states",
        functional_type_name: "owner_states_purge_eligible"
      )

    {:ok, test_owner} =
      MsbmsSystInstanceMgr.create_owner(
        "owner_purge_1",
        "Owner Purge Single Owner Test",
        default_owner_state.id
      )

    assert {:ok, {1, _rows}} = MsbmsSystInstanceMgr.purge_owner(test_owner.id)
  end

  test "Cannot Purge a Single Ineligible Owner" do
    default_owner_state = MsbmsSystEnums.get_default_enum_item(:instance_mgr, "owner_states")

    {:ok, test_owner} =
      MsbmsSystInstanceMgr.create_owner(
        "owner_purge_2",
        "Owner No Purge Single Owner Test",
        default_owner_state.id
      )

    assert {:error, _reason} = MsbmsSystInstanceMgr.purge_owner(test_owner.id)
  end

  test "Can Purge a All Purge Eligible Owners" do
    default_owner_state =
      MsbmsSystEnums.get_default_enum_item(:instance_mgr, "owner_states",
        functional_type_name: "owner_states_purge_eligible"
      )

    {:ok, _} =
      MsbmsSystInstanceMgr.create_owner(
        "owner_purge_3",
        "Owner Purge All Eligible Owners 1",
        default_owner_state.id
      )

    {:ok, _} =
      MsbmsSystInstanceMgr.create_owner(
        "owner_purge_4",
        "Owner Purge All Eligible Owners 2",
        default_owner_state.id
      )

    assert {:ok, {2, _rows}} = MsbmsSystInstanceMgr.purge_all_eligible_owners()

    # A second call should result in no deletions, but no error.  This test could
    # cause race conditions... keep an eye on if that concern is real.
    assert {:ok, {0, _rows}} = MsbmsSystInstanceMgr.purge_all_eligible_owners()
  end

  test "Can Get Owner by Internal Name" do
    assert {:ok, %MsbmsSystInstanceMgr.Data.SystOwners{internal_name: "owner_1"}} =
             MsbmsSystInstanceMgr.get_owner_by_name("owner_1")

    MsbmsSystInstanceMgr.get_owner_by_name("owner_1")
  end

  test "Can Get Unfiltered/Unsorted Instances List" do
    assert {:ok, instances_list} = MsbmsSystInstanceMgr.list_instances()

    assert is_list(instances_list)
  end

  test "Can Filter Instances List by Instance Types" do
    assert {:ok, instances_list} =
             MsbmsSystInstanceMgr.list_instances(instance_types: ["instance_types_big_instance"])

    assert Enum.reduce(instances_list, true, fn instance, acc ->
             instance.instance_type_display_name == "Instance Types / Big Instance" and acc
           end)
  end

  test "Can Filter Instances List by Instance State Functional Types" do
    assert {:ok, instances_list} =
             MsbmsSystInstanceMgr.list_instances(
               instance_state_functional_types: [:instance_states_active]
             )

    assert Enum.reduce(instances_list, true, fn instance, acc ->
             instance.instance_state_functional_type_name == "instance_states_active" and acc
           end)
  end

  test "Can Filter Instances List by Owner" do
    {:ok, test_owner} = MsbmsSystInstanceMgr.get_owner_by_name("owner_3")

    assert {:ok, instances_list} = MsbmsSystInstanceMgr.list_instances(owner_id: test_owner.id)

    assert Enum.reduce(instances_list, true, fn instance, acc ->
             instance.owner_id == test_owner.id and acc
           end)
  end

  test "Can Filter Instances List by Owner State Functional Types" do
    assert {:ok, instances_list} =
             MsbmsSystInstanceMgr.list_instances(
               owner_state_functional_types: [:owner_states_active]
             )

    assert Enum.reduce(instances_list, true, fn instance, acc ->
             instance.owner_state_functional_type_name == "owner_states_active" and acc
           end)
  end

  test "Can Filter Instances List by Applications" do
    assert {:ok, instances_list} =
             MsbmsSystInstanceMgr.list_instances(applications: ["test_app_1"])

    assert Enum.reduce(instances_list, true, fn instance, acc ->
             instance.application_display_name == "Test App 1" and acc
           end)
  end

  test "Can Apply Application Sort to Instances List" do
    assert {:ok, instances_list} = MsbmsSystInstanceMgr.list_instances(sort: [:application])

    assert Enum.reduce(instances_list, {true, nil}, fn instance, acc ->
             {
               elem(acc, 0) and instance.application_display_name >= elem(acc, 1),
               instance.application_display_name
             }
           end)
  end

  test "Can Apply Owner Sort to Instances List" do
    assert {:ok, instances_list} = MsbmsSystInstanceMgr.list_instances(sort: [:owner])

    assert Enum.reduce(instances_list, {true, nil}, fn instance, acc ->
             {
               elem(acc, 0) and instance.owner_display_name >= elem(acc, 1),
               instance.owner_display_name
             }
           end)
  end

  test "Can Apply Instance Sort to Instances List" do
    assert {:ok, instances_list} = MsbmsSystInstanceMgr.list_instances(sort: [:instance])

    assert Enum.reduce(instances_list, {true, nil}, fn instance, acc ->
             {
               elem(acc, 0) and instance.instance_display_name >= elem(acc, 1),
               instance.instance_display_name
             }
           end)
  end

  test "Can Retrieve Single Instance" do
    assert {:ok, %MsbmsSystInstanceMgr.Data.SystInstances{internal_name: "test_instance_1"}} =
             MsbmsSystInstanceMgr.get_instance_by_name("test_instance_1")
  end

  test "Can List Instance Types" do
    assert {:ok, instance_types_list} = MsbmsSystInstanceMgr.list_instance_types(:instance_mgr)
  end

  test "Can create Instance Type" do
    new_instance_type = %{
      internal_name: "can_create_instance_type",
      display_name: "Can Create Instance Type",
      enum_default: true,
      user_description: "Can Create Instance Type Description",
      external_name: "Can Create Instance Type",
      user_options: %{
        datastore_contexts: [
          %{
            id: :test_datastore_context_1,
            db_pool_size: 3
          },
          %{
            id: :test_datastore_context_1,
            db_pool_size: 3
          }
        ]
      }
    }

    assert {:ok, %MsbmsSystEnums.Data.SystEnumItems{internal_name: "can_create_instance_type"}} =
             MsbmsSystInstanceMgr.create_instance_type(:instance_mgr, new_instance_type)
  end

  test "Can Get Instance by Instance Internal Name" do
    assert {:ok, %MsbmsSystEnums.Data.SystEnumItems{internal_name: "instance_types_big_instance"}} =
             MsbmsSystInstanceMgr.get_instance_type_by_name(
               :instance_mgr,
               "instance_types_big_instance"
             )
  end

  test "Can Set Instance Type Values" do
    instance_type_changes = %{
      external_name: "Standard Instance (Changed)",
      display_name: "Instance Types / Std. Instance (Changed)"
    }

    assert {:ok,
            %MsbmsSystEnums.Data.SystEnumItems{
              internal_name: "instance_types_std_instance",
              external_name: "Standard Instance (Changed)",
              display_name: "Instance Types / Std. Instance (Changed)"
            }} =
             MsbmsSystInstanceMgr.set_instance_type_values(
               :instance_mgr,
               "instance_types_std_instance",
               instance_type_changes
             )
  end
end
