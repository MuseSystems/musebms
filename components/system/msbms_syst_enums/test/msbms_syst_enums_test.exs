defmodule MsbmsSystEnumsTest do
  use ExUnit.Case, async: true

  import Ecto.Query

  alias Mix.Tasks.Builddb

  @datastore_options %{
    database_name: "msbms_syst_enums",
    database_owner: "msbms_syst_enums_owner",
    datastore_code: "msbms_syst_enums.testing.code",
    datastore_name: :msbms_syst_enums,
    contexts: [
      %{
        id: nil,
        description: "MsBmsSystEnums Testing Owner",
        database_role: "msbms_syst_enums_owner",
        database_password: nil,
        starting_pool_size: 0,
        start_context: false,
        login_context: false
      },
      %{
        id: :enums_app_context,
        description: "MsBmsSystEnums Testing App User",
        database_role: "msbms_syst_enums_app_user",
        database_password: 'msbms_syst_enums.testing.code.app.user',
        starting_pool_size: 20,
        start_context: true,
        login_context: true
      },
      %{
        id: :msbms_syst_enums_api_user,
        description: "MsBmsSystEnums Testing Api User",
        database_role: "msbms_syst_enums_api_user",
        database_password: 'msbms_syst_enums.testing.code.app.user',
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
      server_salt: "msbms_syst_enums.testing.code.test.salt",
      dbadmin_password: "msbms.syst.dba.testing.password",
      dbadmin_pool_size: 1
    }
  }

  @migration_test_source_root_dir "../../../database"
  @migration_test_datastore_type "cmp_msbms_syst_enums"

  @datastore_context_name :enums_app_context

  #  This testing presumes that the database schema is tested separately and is
  #  correct here.

  setup_all do
    setup_test_environment()

    service_child_spec = %{
      id: EnumsTest,
      start: {MsbmsSystEnums, :start_link, [{:enums_instance, @datastore_context_name}]}
    }

    start_supervised!(service_child_spec)

    on_exit(&cleanup_test_environment/0)
  end

  defp setup_test_environment do
    :ok = build_migrations()

    datastore_options = @datastore_options

    {:ok, :ready, _} = MsbmsSystDatastore.create_datastore(datastore_options)

    {:ok, _} =
      MsbmsSystDatastore.upgrade_datastore(
        datastore_options,
        @migration_test_datastore_type,
        msbms_owner: datastore_options.database_owner,
        msbms_appusr: "msbms_syst_enums_app_user",
        msbms_apiusr: "msbms_syst_enums_api_user"
      )

    {:ok, _, _} = MsbmsSystDatastore.start_datastore(datastore_options)
  end

  defp cleanup_test_environment do
    datastore_options = @datastore_options
    :ok = MsbmsSystDatastore.drop_datastore(datastore_options)
    File.rm_rf!("priv/database/cmp_msbms_syst_enums")
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

  doctest MsbmsSystEnums

  test "Get Enum Values" do
    assert %MsbmsSystEnums.Data.SystEnums{
             internal_name: "test_syst_enum_one",
             enum_items: enum_items
           } = MsbmsSystEnums.get_enum_values(:enums_instance, "test_syst_enum_one")

    assert is_list(enum_items)
    assert 3 = length(enum_items)
  end

  test "Get All Enum Values" do
    assert all_enums = MsbmsSystEnums.get_all_enum_values(:enums_instance)
    assert is_list(all_enums)
    assert length(all_enums) >= 4

    all_enum_internal_names = Enum.map(all_enums, fn enum -> enum.internal_name end)

    assert true ===
             [
               "test_syst_enum_one",
               "test_syst_enum_two",
               "test_syst_enum_three",
               "example_enumeration"
             ]
             |> Enum.reduce(true, fn name, acc -> name in all_enum_internal_names and acc end)
  end

  test "Is Enumeration System Defined / True" do
    assert true === MsbmsSystEnums.get_enum_syst_defined(:enums_instance, "test_syst_enum_one")
  end

  test "Is Enumeration User Maintainable" do
    assert false ===
             MsbmsSystEnums.get_enum_user_maintainable(:enums_instance, "test_syst_enum_one")

    assert true ===
             MsbmsSystEnums.get_enum_user_maintainable(:enums_instance, "test_syst_enum_three")
  end

  test "Get Enum Items" do
    assert enum_items = MsbmsSystEnums.get_enum_items(:enums_instance, "test_syst_enum_one")
    assert 3 = length(enum_items)
  end

  test "Get Enum Functional Types" do
    assert functional_types =
             MsbmsSystEnums.get_enum_functional_types(:enums_instance, "test_syst_enum_one")

    assert 2 = length(functional_types)
  end

  test "Create New Enumeration With Functional Types" do
    new_enum = %{
      internal_name: "create_enum_test",
      display_name: "Create Enum Test",
      user_description: "A test of enumeration creation.",
      functional_types: [
        %{
          internal_name: "create_enum_func_type_one",
          display_name: "Create Enum Test / Func Type One",
          external_name: "Func Type One",
          user_description: "A testing functional type - One"
        },
        %{
          internal_name: "create_enum_func_type_two",
          display_name: "Create Enum Test / Func Type Two",
          external_name: "Func Type Two",
          user_description: "A testing functional type - Two"
        }
      ],
      enum_items: [
        %{
          internal_name: "create_enum_test_item_three",
          display_name: "Create Enum Test / Item Three",
          external_name: "Item Three",
          user_description: "A testing enumeration item",
          enum_default: false,
          functional_type_default: false,
          functional_type_internal_name: "create_enum_func_type_one"
        },
        %{
          internal_name: "create_enum_test_item_one",
          display_name: "Create Enum Test / Item One",
          external_name: "Item One",
          user_description: "A testing enumeration item",
          enum_default: true,
          functional_type_default: true,
          functional_type_internal_name: "create_enum_func_type_one",
          sort_order: 1
        },
        %{
          internal_name: "create_enum_test_item_two",
          display_name: "Create Enum Test / Item Two",
          external_name: "Item Two",
          user_description: "A testing enumeration item",
          enum_default: false,
          functional_type_default: true,
          functional_type_internal_name: "create_enum_func_type_two",
          sort_order: 2
        }
      ]
    }

    assert :ok = MsbmsSystEnums.create_enum(:enums_instance, new_enum)

    assert %{internal_name: "create_enum_test"} =
             MsbmsSystEnums.get_enum_values(:enums_instance, "create_enum_test")

    saved_enum_items = MsbmsSystEnums.get_sorted_enum_items(:enums_instance, "create_enum_test")

    assert 3 = length(saved_enum_items)

    assert %{internal_name: "create_enum_test_item_one", sort_order: 1} = hd(saved_enum_items)
  end

  test "Create New Enumeration With No Items" do
    new_enum = %{
      internal_name: "create_enum_no_items_test",
      display_name: "Create Enum No Items Test",
      user_description: "A test of enumeration creation.",
      functional_types: [
        %{
          internal_name: "create_enum_no_items_func_type_one",
          display_name: "Create Enum No Items Test / Func Type One",
          external_name: "Func Type One",
          user_description: "A testing functional type - One"
        },
        %{
          internal_name: "create_enum_no_items_func_type_two",
          display_name: "Create Enum No Items Test / Func Type Two",
          external_name: "Func Type Two",
          user_description: "A testing functional type - Two"
        }
      ]
    }

    assert :ok = MsbmsSystEnums.create_enum(:enums_instance, new_enum)

    assert %{internal_name: "create_enum_no_items_test", functional_types: functional_types} =
             MsbmsSystEnums.get_enum_values(:enums_instance, "create_enum_no_items_test")

    assert 2 == length(functional_types)

    saved_enum_items =
      MsbmsSystEnums.get_sorted_enum_items(:enums_instance, "create_enum_no_items_test")

    assert 0 = length(saved_enum_items)
  end

  test "Create New Enumeration Without Functional Types" do
    new_enum = %{
      internal_name: "create_enum_test_no_func_type",
      display_name: "Create Enum Test No Func Type",
      user_description: "A test of enumeration creation without functional types.",
      enum_items: [
        %{
          internal_name: "create_enum_test_no_func_type_item_three",
          display_name: "Create Enum Test No Func Type / Item Three",
          external_name: "Item Three",
          user_description: "A testing enumeration item",
          functional_type_default: false,
          enum_default: false
        },
        %{
          internal_name: "create_enum_test_no_func_type_item_one",
          display_name: "Create Enum Test No Func Type / Item One",
          external_name: "Item One",
          user_description: "A testing enumeration item",
          functional_type_default: false,
          enum_default: true,
          sort_order: 1
        },
        %{
          internal_name: "create_enum_test_no_func_type_item_two",
          display_name: "Create Enum Test No Func Type / Item Two",
          external_name: "Item Two",
          user_description: "A testing enumeration item",
          functional_type_default: false,
          enum_default: false,
          sort_order: 2
        }
      ]
    }

    assert :ok = MsbmsSystEnums.create_enum(:enums_instance, new_enum)

    assert %{internal_name: "create_enum_test_no_func_type"} =
             MsbmsSystEnums.get_enum_values(:enums_instance, "create_enum_test_no_func_type")

    saved_enum_items =
      MsbmsSystEnums.get_sorted_enum_items(:enums_instance, "create_enum_test_no_func_type")

    assert 3 = length(saved_enum_items)

    assert %{internal_name: "create_enum_test_no_func_type_item_one", sort_order: 1} =
             hd(saved_enum_items)
  end

  test "Create New Enumeration Without Functional Types or Items" do
    new_enum = %{
      internal_name: "create_enum_test_no_func_type_no_items",
      display_name: "Create Enum Test No Func Type or Items",
      user_description: "A test of enumeration creation without functional types or enum items."
    }

    assert :ok = MsbmsSystEnums.create_enum(:enums_instance, new_enum)

    assert %{internal_name: "create_enum_test_no_func_type_no_items"} =
             MsbmsSystEnums.get_enum_values(
               :enums_instance,
               "create_enum_test_no_func_type_no_items"
             )

    saved_enum_items =
      MsbmsSystEnums.get_sorted_enum_items(
        :enums_instance,
        "create_enum_test_no_func_type_no_items"
      )

    assert 0 = length(saved_enum_items)
  end

  test "Create New Enumeration Functional Type" do
    success_enum = %{
      internal_name: "create_func_type_test_success_enum",
      display_name: "Create Functional Type Enumeration (Success)",
      user_description: "A test enumeration to allow creating new functional types. (Success)"
    }

    :ok = MsbmsSystEnums.create_enum(:enums_instance, success_enum)

    failure_enum = %{
      internal_name: "create_func_type_test_failure_enum",
      display_name: "Create Functional Type Enumeration (Failure)",
      user_description: "A test enumeration to allow creating new functional types. (Failure)",
      enum_items: [
        %{
          internal_name: "create_func_type_test_failure_enum_item",
          display_name: "Create Func Type / Item One",
          external_name: "Item Three",
          user_description: "A testing enumeration item",
          functional_type_default: false,
          enum_default: true
        }
      ]
    }

    :ok = MsbmsSystEnums.create_enum(:enums_instance, failure_enum)

    success_func_type = %{
      internal_name: "create_func_type_test_success",
      display_name: "Create Functional Type Test Success",
      external_name: "Functional Type",
      user_description: "Testing the creation of functional types. (Success)"
    }

    failure_func_type = %{
      internal_name: "create_func_type_test_failure",
      display_name: "Create Functional Type Test Failure",
      external_name: "Functional Type",
      user_description: "Testing the creation of functional types. (Failure)"
    }

    assert :ok =
             MsbmsSystEnums.create_enum_functional_type(
               :enums_instance,
               "create_func_type_test_success_enum",
               success_func_type
             )

    # The test below should fail since it has enum items defined, but currently
    # doesn't require functional types.  We cannot create a new requirement
    # for functional types under these conditions.

    assert {:error, _} =
             MsbmsSystEnums.create_enum_functional_type(
               :enums_instance,
               "create_func_type_test_failure_enum",
               failure_func_type
             )

    # This test should fail because the enum "test_syst_enum_one" is system
    # defined and therefore is not user maintainable in terms of functional
    # types.

    assert {:error, _} =
             MsbmsSystEnums.create_enum_functional_type(
               :enums_instance,
               "test_syst_enum_one",
               failure_func_type
             )
  end

  test "Create New Enumeration Item" do
    success_enum_no_types = %{
      internal_name: "create_enum_item_enum_no_types",
      display_name: "Create Enum Item Enumeration - No Types (Success)",
      user_description: "A test enumeration for creating enum items without types. (Success)"
    }

    success_enum_with_types = %{
      internal_name: "create_enum_item_enum_with_types",
      display_name: "Create Enum Item Enumeration - With Types (Success)",
      user_description: "A test enumeration for creating enum items with types. (Success)",
      functional_types: [
        %{
          internal_name: "create_enum_item_enum_with_types_type",
          display_name: "Create Enum Item Functional Type Success",
          external_name: "Functional Type",
          user_description: "A test functional type to test enum item creation. (Success)"
        }
      ]
    }

    :ok = MsbmsSystEnums.create_enum(:enums_instance, success_enum_no_types)
    :ok = MsbmsSystEnums.create_enum(:enums_instance, success_enum_with_types)

    untyped_enum_item = %{
      internal_name: "create_enum_item_no_type_test",
      display_name: "Create Enum Item Test / No Type",
      external_name: "Create Enum Item",
      user_description: "untyped_enum_item",
      enum_default: true,
      functional_type_default: false
    }

    assert :ok =
             MsbmsSystEnums.create_enum_item(
               :enums_instance,
               success_enum_no_types.internal_name,
               untyped_enum_item
             )

    # Failure enum since we identify a functional type when the enumeration
    # has no defined functional types.
    failure_untyped_enum_item = %{
      internal_name: "failure_create_enum_item_no_type_test",
      display_name: "Failure Create Enum Item Test / No Type",
      external_name: "Create Enum Item",
      user_description:
        "Failure enum since we identify a functional type when the enumeration has no defined functional types.",
      enum_default: true,
      functional_type_default: false,
      functional_type_internal_name: "create_enum_item_enum_with_types_type"
    }

    assert {:error, _} =
             MsbmsSystEnums.create_enum_item(
               :enums_instance,
               success_enum_no_types.internal_name,
               failure_untyped_enum_item
             )

    type_enum_item = %{
      internal_name: "create_enum_item_with_type_test",
      display_name: "Create Enum Item Test / With Type",
      external_name: "Create Enum Item",
      user_description: "A testing enumeration item",
      enum_default: true,
      functional_type_default: true,
      functional_type_internal_name: "create_enum_item_enum_with_types_type"
    }

    assert :ok =
             MsbmsSystEnums.create_enum_item(
               :enums_instance,
               success_enum_with_types.internal_name,
               type_enum_item
             )

    # Failure since we don't identify any functional type when one is required.
    failure_type_enum_item = %{
      internal_name: "failure_create_enum_item_with_type_test",
      display_name: "Failure Create Enum Item Test / With Type",
      external_name: "Create Enum Item",
      user_description:
        "Failure since we don't identify any functional type when one is required.",
      enum_default: true,
      functional_type_default: false
    }

    assert {:error, _} =
             MsbmsSystEnums.create_enum_item(
               :enums_instance,
               success_enum_with_types.internal_name,
               failure_type_enum_item
             )

    system_untyped_enum_item = %{
      internal_name: "create_enum_item_system_no_type_test",
      display_name: "Create Enum Item Test / System No Type",
      external_name: "Create Enum Item",
      user_description: "system_untyped_enum_item",
      enum_default: true,
      functional_type_default: false
    }

    assert :ok =
             MsbmsSystEnums.create_enum_item(
               :enums_instance,
               "test_syst_enum_two",
               system_untyped_enum_item
             )

    system_type_enum_item = %{
      internal_name: "create_enum_item_system_with_type_test",
      display_name: "Create Enum Item Test / System With Type",
      external_name: "Create Enum Item",
      user_description: "system_type_enum_item",
      enum_default: true,
      functional_type_default: true,
      functional_type_internal_name: "enum_three_active"
    }

    assert :ok =
             MsbmsSystEnums.create_enum_item(
               :enums_instance,
               "test_syst_enum_three",
               system_type_enum_item
             )

    # Failure due to asking for a functional type belonging to another enum.
    failure_system_type_enum_item = %{
      internal_name: "failure_create_enum_item_system_with_type_test",
      display_name: "Failure Create Enum Item Test / System With Type",
      external_name: "Create Enum Item",
      user_description: "Failure due to asking for a functional type belonging to another enum.",
      enum_default: true,
      functional_type_default: true,
      functional_type_internal_name: "create_enum_item_enum_with_types_type"
    }

    assert {:error, _} =
             MsbmsSystEnums.create_enum_item(
               :enums_instance,
               "test_syst_enum_three",
               failure_system_type_enum_item
             )

    # Failure due to trying to add an enum item to a system defined enum which
    # is not user_maintainable
    failure_system_type_enum_item_not_allowed = %{
      internal_name: "failure_create_enum_item_system_with_type_test_not_allowed",
      display_name: "Failure Create Enum Item Test Not Allowed/ System With Type",
      external_name: "Create Enum Item",
      user_description:
        "Failure due to trying to add an enum item to a system defined enum which is not user_maintainable.",
      enum_default: true,
      functional_type_default: true,
      functional_type_internal_name: "enum_one_active"
    }

    assert {:error, _} =
             MsbmsSystEnums.create_enum_item(
               :enums_instance,
               "test_syst_enum_one",
               failure_system_type_enum_item_not_allowed
             )
  end

  test "System Defined Enum Changes" do
    change_internal_name = %{internal_name: "test_one_change_name_test"}
    change_display_name = %{display_name: "Enum Test One / Change Name Test"}
    change_user_description = %{user_description: "Updated user description test"}
    change_default_user_options = %{default_user_options: %{"test" => "option"}}

    assert {:error, _} =
             MsbmsSystEnums.set_enum_values(
               :enums_instance,
               "test_syst_enum_one",
               change_internal_name
             )

    assert %{internal_name: "test_syst_enum_one"} =
             MsbmsSystEnums.get_enum_values(:enums_instance, "test_syst_enum_one")

    assert :ok =
             MsbmsSystEnums.set_enum_values(
               :enums_instance,
               "test_syst_enum_one",
               change_display_name
             )

    assert %{display_name: "Enum Test One / Change Name Test"} =
             MsbmsSystEnums.get_enum_values(:enums_instance, "test_syst_enum_one")

    assert :ok =
             MsbmsSystEnums.set_enum_values(
               :enums_instance,
               "test_syst_enum_one",
               change_user_description
             )

    assert %{user_description: "Updated user description test"} =
             MsbmsSystEnums.get_enum_values(:enums_instance, "test_syst_enum_one")

    assert :ok =
             MsbmsSystEnums.set_enum_values(
               :enums_instance,
               "test_syst_enum_one",
               change_default_user_options
             )

    assert %{default_user_options: %{"test" => "option"}} =
             MsbmsSystEnums.get_enum_values(:enums_instance, "test_syst_enum_one")
  end

  test "User Defined Enum Changes" do
    new_enum = %{
      internal_name: "user_define_enum_changes_test_old",
      display_name: "User Enum Changes Test / Old",
      user_description: "User Enum Changes Test Old.",
      default_user_options: %{"old_user_option" => "test"}
    }

    :ok = MsbmsSystEnums.create_enum(:enums_instance, new_enum)

    change_internal_name = %{internal_name: "user_define_enum_changes_test_new"}
    change_display_name = %{display_name: "User Enum Changes Test / New"}
    change_user_description = %{user_description: "User Enum Changes Test New."}
    change_default_user_options = %{default_user_options: %{"new_user_option" => "test"}}

    assert :ok =
             MsbmsSystEnums.set_enum_values(
               :enums_instance,
               "user_define_enum_changes_test_old",
               change_internal_name
             )

    catch_error(
      MsbmsSystEnums.get_enum_values(:enums_instance, "user_define_enum_changes_test_old")
    )

    assert %{internal_name: "user_define_enum_changes_test_new"} =
             MsbmsSystEnums.get_enum_values(:enums_instance, "user_define_enum_changes_test_new")

    assert :ok =
             MsbmsSystEnums.set_enum_values(
               :enums_instance,
               "user_define_enum_changes_test_new",
               change_display_name
             )

    assert %{display_name: "User Enum Changes Test / New"} =
             MsbmsSystEnums.get_enum_values(:enums_instance, "user_define_enum_changes_test_new")

    assert :ok =
             MsbmsSystEnums.set_enum_values(
               :enums_instance,
               "user_define_enum_changes_test_new",
               change_user_description
             )

    assert %{user_description: "User Enum Changes Test New."} =
             MsbmsSystEnums.get_enum_values(:enums_instance, "user_define_enum_changes_test_new")

    assert :ok =
             MsbmsSystEnums.set_enum_values(
               :enums_instance,
               "user_define_enum_changes_test_new",
               change_default_user_options
             )

    assert %{default_user_options: %{"new_user_option" => "test"}} =
             MsbmsSystEnums.get_enum_values(:enums_instance, "user_define_enum_changes_test_new")
  end

  test "System Defined Functional Type Changes" do
    change_internal_name = %{internal_name: "test_one_change_name_test"}
    change_display_name = %{display_name: "Enum Test One / Change Name Test"}
    change_user_description = %{user_description: "Updated user description test"}
    change_external_name = %{external_name: "Changed Test External Name"}

    other_enum = MsbmsSystEnums.get_enum_values(:enums_instance, "test_syst_enum_two")

    %{functional_types: functional_types} =
      MsbmsSystEnums.get_enum_values(:enums_instance, "test_syst_enum_one")

    orig_functional_type = Enum.find(functional_types, &(&1.internal_name == "enum_one_active"))

    change_enum_id = %{enum_id: other_enum.id}

    assert {:error, _} =
             MsbmsSystEnums.set_enum_functional_type_values(
               :enums_instance,
               "test_syst_enum_one",
               "enum_one_active",
               change_internal_name
             )

    assert {:error, _} =
             MsbmsSystEnums.set_enum_functional_type_values(
               :enums_instance,
               "test_syst_enum_one",
               "enum_one_active",
               change_enum_id
             )

    assert :ok =
             MsbmsSystEnums.set_enum_functional_type_values(
               :enums_instance,
               "test_syst_enum_one",
               "enum_one_active",
               change_display_name
             )

    assert :ok =
             MsbmsSystEnums.set_enum_functional_type_values(
               :enums_instance,
               "test_syst_enum_one",
               "enum_one_active",
               change_user_description
             )

    assert :ok =
             MsbmsSystEnums.set_enum_functional_type_values(
               :enums_instance,
               "test_syst_enum_one",
               "enum_one_active",
               change_external_name
             )

    %{functional_types: functional_types} =
      MsbmsSystEnums.get_enum_values(:enums_instance, "test_syst_enum_one")

    updated_functional_type =
      Enum.find(functional_types, &(&1.internal_name == "enum_one_active"))

    assert %{internal_name: "enum_one_active"} = orig_functional_type

    assert updated_functional_type.enum_id == orig_functional_type.enum_id

    assert %{user_description: "Updated user description test"} = updated_functional_type

    assert %{display_name: "Enum Test One / Change Name Test"} = updated_functional_type

    assert %{external_name: "Changed Test External Name"} = updated_functional_type
  end

  test "User Defined Functional Type Changes" do
    new_enum = %{
      internal_name: "user_def_func_type_changes_enum",
      display_name: "User Enum Functional Type Changes Test",
      user_description: "An enum for user defined functional type change testing.",
      default_user_options: %{"user_option" => "test"},
      functional_types: [
        %{
          internal_name: "user_def_func_type_changes_old",
          display_name: "User Defined Enum Functional Type Old",
          external_name: "User Defined Enum Functional Type Old",
          user_description: "User Defined Enum Functional Type Old"
        }
      ]
    }

    :ok = MsbmsSystEnums.create_enum(:enums_instance, new_enum)

    change_internal_name = %{internal_name: "user_def_func_type_changes_new"}
    change_display_name = %{display_name: "User Defined Enum Functional Type New"}
    change_user_description = %{user_description: "User Defined Enum Functional Type New"}
    change_external_name = %{external_name: "User Defined Enum Functional Type New"}

    other_enum = MsbmsSystEnums.get_enum_values(:enums_instance, "test_syst_enum_two")

    %{functional_types: functional_types} =
      MsbmsSystEnums.get_enum_values(:enums_instance, "user_def_func_type_changes_enum")

    orig_functional_type =
      Enum.find(functional_types, &(&1.internal_name == "user_def_func_type_changes_old"))

    change_enum_id = %{enum_id: other_enum.id}

    assert {:error, _} =
             MsbmsSystEnums.set_enum_functional_type_values(
               :enums_instance,
               "user_def_func_type_changes_enum",
               "user_def_func_type_changes_old",
               change_enum_id
             )

    assert :ok =
             MsbmsSystEnums.set_enum_functional_type_values(
               :enums_instance,
               "user_def_func_type_changes_enum",
               "user_def_func_type_changes_old",
               change_internal_name
             )

    assert :ok =
             MsbmsSystEnums.set_enum_functional_type_values(
               :enums_instance,
               "user_def_func_type_changes_enum",
               "user_def_func_type_changes_new",
               change_display_name
             )

    assert :ok =
             MsbmsSystEnums.set_enum_functional_type_values(
               :enums_instance,
               "user_def_func_type_changes_enum",
               "user_def_func_type_changes_new",
               change_user_description
             )

    assert :ok =
             MsbmsSystEnums.set_enum_functional_type_values(
               :enums_instance,
               "user_def_func_type_changes_enum",
               "user_def_func_type_changes_new",
               change_external_name
             )

    %{functional_types: functional_types} =
      MsbmsSystEnums.get_enum_values(:enums_instance, "user_def_func_type_changes_enum")

    updated_functional_type =
      Enum.find(functional_types, &(&1.internal_name == "user_def_func_type_changes_new"))

    assert updated_functional_type.enum_id == orig_functional_type.enum_id

    assert %{user_description: "User Defined Enum Functional Type New"} = updated_functional_type

    assert %{display_name: "User Defined Enum Functional Type New"} = updated_functional_type

    assert %{external_name: "User Defined Enum Functional Type New"} = updated_functional_type
  end

  test "System Defined Enum Item Set Values" do
    change_internal_name = %{internal_name: "test_one_change_name_test"}
    change_display_name = %{display_name: "Enum Test One / Change Name Test"}
    change_user_description = %{user_description: "Updated user description test"}
    change_external_name = %{external_name: "Changed Test External Name"}
    change_enum_default = %{enum_default: false}
    change_functional_type_default = %{functional_type_default: false}
    change_sort_order = %{sort_order: 2}
    change_user_options = %{user_options: %{"user_key1" => 1, "user_key2" => 2, "user_key3" => 3}}

    other_enum = MsbmsSystEnums.get_enum_values(:enums_instance, "test_syst_enum_two")

    %{enum_items: enum_items} =
      MsbmsSystEnums.get_enum_values(:enums_instance, "test_syst_enum_one")

    orig_enum_item = Enum.find(enum_items, &(&1.internal_name == "enum_one_active"))

    change_enum_id = %{enum_id: other_enum.id}

    orig_functional_type =
      MsbmsSystEnums.get_enum_functional_types(:enums_instance, "test_syst_enum_one")
      |> Enum.find(&(&1.internal_name == "enum_one_active"))

    other_functional_type =
      MsbmsSystEnums.get_enum_functional_types(:enums_instance, "test_syst_enum_one")
      |> Enum.find(&(&1.internal_name == "enum_one_inactive"))

    change_functional_type = %{functional_type_id: other_functional_type.id}

    assert {:error, _} =
             MsbmsSystEnums.set_enum_item_values(
               :enums_instance,
               "test_syst_enum_one",
               "enum_one_active",
               change_internal_name
             )

    assert {:error, _} =
             MsbmsSystEnums.set_enum_item_values(
               :enums_instance,
               "test_syst_enum_one",
               "enum_one_active",
               change_enum_id
             )

    assert {:error, _} =
             MsbmsSystEnums.set_enum_item_values(
               :enums_instance,
               "test_syst_enum_one",
               "enum_one_active",
               change_functional_type
             )

    assert :ok =
             MsbmsSystEnums.set_enum_item_values(
               :enums_instance,
               "test_syst_enum_one",
               "enum_one_active",
               change_display_name
             )

    assert :ok =
             MsbmsSystEnums.set_enum_item_values(
               :enums_instance,
               "test_syst_enum_one",
               "enum_one_active",
               change_user_description
             )

    assert :ok =
             MsbmsSystEnums.set_enum_item_values(
               :enums_instance,
               "test_syst_enum_one",
               "enum_one_active",
               change_enum_default
             )

    assert :ok =
             MsbmsSystEnums.set_enum_item_values(
               :enums_instance,
               "test_syst_enum_one",
               "enum_one_active",
               change_functional_type_default
             )

    assert :ok =
             MsbmsSystEnums.set_enum_item_values(
               :enums_instance,
               "test_syst_enum_one",
               "enum_one_active",
               change_sort_order
             )

    assert :ok =
             MsbmsSystEnums.set_enum_item_values(
               :enums_instance,
               "test_syst_enum_one",
               "enum_one_active",
               change_user_options
             )

    assert :ok =
             MsbmsSystEnums.set_enum_item_values(
               :enums_instance,
               "test_syst_enum_one",
               "enum_one_active",
               change_external_name
             )

    %{enum_items: enum_items} =
      MsbmsSystEnums.get_enum_values(:enums_instance, "test_syst_enum_one")

    updated_enum_item = Enum.find(enum_items, &(&1.internal_name == "enum_one_active"))

    assert %{internal_name: "enum_one_active"} = orig_enum_item

    assert updated_enum_item.enum_id == orig_enum_item.enum_id

    assert %{user_description: "Updated user description test"} = updated_enum_item

    assert %{display_name: "Enum Test One / Change Name Test"} = updated_enum_item

    assert %{external_name: "Changed Test External Name"} = updated_enum_item
  end

  test "User Defined Enum Item Set Values" do
    new_enum = %{
      internal_name: "user_def_enum_item_changes_enum",
      display_name: "User Enum Item Changes Test",
      user_description: "An enum for user defined enum item  change testing.",
      default_user_options: %{"user_option" => "test"},
      functional_types: [
        %{
          internal_name: "user_def_enum_item_changes_func_type",
          display_name: "User Defined Enum Item Functional Type",
          external_name: "User Defined Enum Item Functional Type",
          user_description: "User Defined Enum Item Functional Type"
        }
      ],
      enum_items: [
        %{
          internal_name: "user_def_enum_item_changes_old",
          display_name: "User Defined Enum Item Changes Old",
          external_name: "User Defined Enum Item Changes Old",
          user_description: "User Defined Enum Item Changes Old",
          functional_type_internal_name: "user_def_enum_item_changes_func_type",
          functional_type_default: true,
          enum_default: true
        }
      ]
    }

    :ok = MsbmsSystEnums.create_enum(:enums_instance, new_enum)

    change_internal_name = %{internal_name: "user_def_enum_item_changes_new"}
    change_display_name = %{display_name: "User Defined Enum Item Changes New"}
    change_user_description = %{user_description: "User Defined Enum Item Changes New"}
    change_external_name = %{external_name: "User Defined Enum Item Changes New"}
    change_enum_default = %{enum_default: false}
    change_functional_type_default = %{functional_type_default: false}
    change_sort_order = %{sort_order: 2}
    change_user_options = %{user_options: %{"user_key1" => 1, "user_key2" => 2, "user_key3" => 3}}

    other_enum = MsbmsSystEnums.get_enum_values(:enums_instance, "test_syst_enum_two")

    %{enum_items: enum_items} =
      MsbmsSystEnums.get_enum_values(:enums_instance, "user_def_enum_item_changes_enum")

    orig_enum_item =
      Enum.find(enum_items, &(&1.internal_name == "user_def_enum_item_changes_old"))

    change_enum_id = %{enum_id: other_enum.id}

    orig_functional_type =
      MsbmsSystEnums.get_enum_functional_types(:enums_instance, "user_def_enum_item_changes_enum")
      |> Enum.find(&(&1.internal_name == "user_def_enum_item_changes_func_type"))

    other_functional_type =
      MsbmsSystEnums.get_enum_functional_types(:enums_instance, "test_syst_enum_one")
      |> Enum.find(&(&1.internal_name == "enum_one_inactive"))

    change_functional_type = %{functional_type_id: other_functional_type.id}

    assert {:error, _} =
             MsbmsSystEnums.set_enum_item_values(
               :enums_instance,
               "user_def_enum_item_changes_enum",
               "user_def_enum_item_changes_old",
               change_enum_id
             )

    assert {:error, _} =
             MsbmsSystEnums.set_enum_item_values(
               :enums_instance,
               "user_def_enum_item_changes_enum",
               "user_def_enum_item_changes_old",
               change_functional_type
             )

    assert :ok =
             MsbmsSystEnums.set_enum_item_values(
               :enums_instance,
               "user_def_enum_item_changes_enum",
               "user_def_enum_item_changes_old",
               change_internal_name
             )

    assert :ok =
             MsbmsSystEnums.set_enum_item_values(
               :enums_instance,
               "user_def_enum_item_changes_enum",
               "user_def_enum_item_changes_new",
               change_display_name
             )

    assert :ok =
             MsbmsSystEnums.set_enum_item_values(
               :enums_instance,
               "user_def_enum_item_changes_enum",
               "user_def_enum_item_changes_new",
               change_user_description
             )

    assert :ok =
             MsbmsSystEnums.set_enum_item_values(
               :enums_instance,
               "user_def_enum_item_changes_enum",
               "user_def_enum_item_changes_new",
               change_enum_default
             )

    assert :ok =
             MsbmsSystEnums.set_enum_item_values(
               :enums_instance,
               "user_def_enum_item_changes_enum",
               "user_def_enum_item_changes_new",
               change_functional_type_default
             )

    assert :ok =
             MsbmsSystEnums.set_enum_item_values(
               :enums_instance,
               "user_def_enum_item_changes_enum",
               "user_def_enum_item_changes_new",
               change_sort_order
             )

    assert :ok =
             MsbmsSystEnums.set_enum_item_values(
               :enums_instance,
               "user_def_enum_item_changes_enum",
               "user_def_enum_item_changes_new",
               change_user_options
             )

    assert :ok =
             MsbmsSystEnums.set_enum_item_values(
               :enums_instance,
               "user_def_enum_item_changes_enum",
               "user_def_enum_item_changes_new",
               change_external_name
             )

    %{enum_items: enum_items} =
      MsbmsSystEnums.get_enum_values(:enums_instance, "user_def_enum_item_changes_enum")

    updated_enum_item =
      Enum.find(enum_items, &(&1.internal_name == "user_def_enum_item_changes_new"))

    assert %{internal_name: "user_def_enum_item_changes_new"} = updated_enum_item

    assert updated_enum_item.enum_id == orig_enum_item.enum_id

    assert updated_enum_item.functional_type_id == orig_enum_item.functional_type_id

    assert %{user_description: "User Defined Enum Item Changes New"} = updated_enum_item

    assert %{display_name: "User Defined Enum Item Changes New"} = updated_enum_item

    assert %{external_name: "User Defined Enum Item Changes New"} = updated_enum_item

    assert %{sort_order: 2} = updated_enum_item

    assert %{enum_default: false} = updated_enum_item

    assert %{functional_type_default: false} = updated_enum_item

    assert %{user_options: %{"user_key1" => 1, "user_key2" => 2, "user_key3" => 3}} =
             updated_enum_item
  end

  test "Delete User Defined Enumeration" do
    new_enum = %{
      internal_name: "delete_user_defined_enum",
      display_name: "Delete User Defined Enum",
      user_description: "A test enumeration for deletion.",
      default_user_options: %{"user_option" => "test"},
      functional_types: [
        %{
          internal_name: "delete_user_defined_enum__enum_func_type",
          display_name: "Delete User Defined Enum Enum Functional Type",
          external_name: "Delete User Defined Enum Enum Functional Type",
          user_description: "Delete User Defined Enum Enum Functional Type"
        }
      ],
      enum_items: [
        %{
          internal_name: "delete_user_defined_enum_enum_item",
          display_name: "Delete User Defined Enum Enum Item",
          external_name: "Delete User Defined Enum Enum Item",
          user_description: "Delete User Defined Enum Enum Item",
          functional_type_internal_name: "delete_user_defined_enum__enum_func_type",
          functional_type_default: true,
          enum_default: true
        }
      ]
    }

    :ok = MsbmsSystEnums.create_enum(:enums_instance, new_enum)

    assert(
      %MsbmsSystEnums.Data.SystEnums{} =
        MsbmsSystEnums.get_enum_values(:enums_instance, "delete_user_defined_enum")
    )

    assert :ok = MsbmsSystEnums.delete_enum(:enums_instance, "delete_user_defined_enum")

    catch_error(MsbmsSystEnums.get_enum_values(:enums_instance, "delete_user_defined_enum"))
  end

  test "Delete System Defined Enumeration" do
    assert {:error, _} = MsbmsSystEnums.delete_enum(:enums_instance, "test_syst_enum_three")

    assert(
      %MsbmsSystEnums.Data.SystEnums{} =
        MsbmsSystEnums.get_enum_values(:enums_instance, "test_syst_enum_three")
    )
  end

  test "Delete User Defined Functional_type" do
    new_enum = %{
      internal_name: "delete_user_defined_functional_type_enum",
      display_name: "Delete User Defined Functional Type Enum",
      user_description: "A test enumeration for functional type deletion.",
      default_user_options: %{"user_option" => "test"},
      functional_types: [
        %{
          internal_name: "delete_user_def_functional_type_failure",
          display_name: "Delete User Defined Functional Type Failure",
          external_name: "Delete User Defined Functional Type Failure",
          user_description: "Delete User Defined Functional Type Failure"
        },
        %{
          internal_name: "delete_user_def_functional_type_success",
          display_name: "Delete User Defined Functional Type Success",
          external_name: "Delete User Defined Functional Type Success",
          user_description: "Delete User Defined Functional Type Success"
        }
      ],
      enum_items: [
        %{
          internal_name: "delete_user_def_functional_type_enum_item",
          display_name: "Delete User Defined Functional Type Enum Item",
          external_name: "Delete User Defined Functional Type Enum Item",
          user_description: "Delete User Defined Functional Type Enum Item",
          functional_type_internal_name: "delete_user_def_functional_type_failure",
          functional_type_default: true,
          enum_default: true
        }
      ]
    }

    :ok = MsbmsSystEnums.create_enum(:enums_instance, new_enum)

    before_functional_types =
      MsbmsSystEnums.get_enum_functional_types(
        :enums_instance,
        "delete_user_defined_functional_type_enum"
      )

    assert 2 = length(before_functional_types)

    assert :ok =
             MsbmsSystEnums.delete_enum_functional_type(
               :enums_instance,
               "delete_user_defined_functional_type_enum",
               "delete_user_def_functional_type_success"
             )

    assert {:error, _} =
             MsbmsSystEnums.delete_enum_functional_type(
               :enums_instance,
               "delete_user_defined_functional_type_enum",
               "delete_user_def_functional_type_failure"
             )

    after_functional_types =
      MsbmsSystEnums.get_enum_functional_types(
        :enums_instance,
        "delete_user_defined_functional_type_enum"
      )

    assert 1 = length(after_functional_types)
  end

  test "Delete System Defined Functional Types" do
    before_functional_types =
      MsbmsSystEnums.get_enum_functional_types(
        :enums_instance,
        "test_syst_enum_three"
      )

    assert 2 = length(before_functional_types)

    assert {:error, _} =
             MsbmsSystEnums.delete_enum_functional_type(
               :enums_instance,
               "test_syst_enum_three",
               "enum_three_active"
             )

    after_functional_types =
      MsbmsSystEnums.get_enum_functional_types(
        :enums_instance,
        "test_syst_enum_three"
      )

    assert 2 = length(after_functional_types)
  end

  test "Delete User Defined Enum Items / User Defined Enum" do
    new_enum = %{
      internal_name: "delete_user_def_enum_item_enum",
      display_name: "Delete User Defined Enum Item Enum",
      user_description: "A test enumeration for functional type deletion.",
      default_user_options: %{"user_option" => "test"},
      functional_types: [
        %{
          internal_name: "delete_user_def_functional_type_one",
          display_name: "Delete User Defined Enum Item One",
          external_name: "Delete User Defined Enum Item One",
          user_description: "Delete User Defined Enum Item One"
        },
        %{
          internal_name: "delete_user_def_functional_type_two",
          display_name: "Delete User Defined Enum Item Two",
          external_name: "Delete User Defined Enum Item Two",
          user_description: "Delete User Defined Enum Item Two"
        }
      ],
      enum_items: [
        %{
          internal_name: "delete_user_def_enum_item_one",
          display_name: "Delete User Defined Enum Item One",
          external_name: "Delete User Defined Enum Item One",
          user_description: "Delete User Defined Enum Item One",
          functional_type_internal_name: "delete_user_def_functional_type_one",
          functional_type_default: true,
          enum_default: true
        },
        %{
          internal_name: "delete_user_def_enum_item_two",
          display_name: "Delete User Defined Enum Item Two",
          external_name: "Delete User Defined Enum Item Two",
          user_description: "Delete User Defined Enum Item Two",
          functional_type_internal_name: "delete_user_def_functional_type_two",
          functional_type_default: true,
          enum_default: false
        }
      ]
    }

    :ok = MsbmsSystEnums.create_enum(:enums_instance, new_enum)

    before_enum_items =
      MsbmsSystEnums.get_enum_items(
        :enums_instance,
        "delete_user_def_enum_item_enum"
      )

    assert 2 = length(before_enum_items)

    assert :ok =
             MsbmsSystEnums.delete_enum_item(
               :enums_instance,
               "delete_user_def_enum_item_enum",
               "delete_user_def_enum_item_two"
             )

    after_enum_items =
      MsbmsSystEnums.get_enum_items(
        :enums_instance,
        "delete_user_def_enum_item_enum"
      )

    assert 1 = length(after_enum_items)
  end

  test "Delete User Defined Enum Items / System Defined Enum" do
    new_enum_item = %{
      internal_name: "delete_user_def_enum_item_syst_enum",
      display_name: "Delete User Defined Enum Item One/Syst Enum",
      external_name: "Delete User Defined Enum Item One / System Enum",
      user_description: "Delete User Defined Enum Item One for System Defined Enumeration",
      functional_type_internal_name: "enum_three_active",
      functional_type_default: false,
      enum_default: true
    }

    :ok = MsbmsSystEnums.create_enum_item(:enums_instance, "test_syst_enum_three", new_enum_item)

    false =
      MsbmsSystEnums.get_enum_items(:enums_instance, "test_syst_enum_three")
      |> Enum.find(&(&1.internal_name == "delete_user_def_enum_item_syst_enum"))
      |> is_nil()

    assert :ok =
             MsbmsSystEnums.delete_enum_item(
               :enums_instance,
               "test_syst_enum_three",
               "delete_user_def_enum_item_syst_enum"
             )

    assert true =
             MsbmsSystEnums.get_enum_items(:enums_instance, "test_syst_enum_three")
             |> Enum.find(&(&1.internal_name == "delete_user_def_enum_item_syst_enum"))
             |> is_nil()
  end

  test "Delete System Defined Enum Item" do
    false =
      MsbmsSystEnums.get_enum_items(:enums_instance, "test_syst_enum_three")
      |> Enum.find(&(&1.internal_name == "enum_three_closed"))
      |> is_nil()

    assert {:error, _} =
             MsbmsSystEnums.delete_enum_item(
               :enums_instance,
               "test_syst_enum_three",
               "enum_three_closed"
             )

    assert false ==
             MsbmsSystEnums.get_enum_items(:enums_instance, "test_syst_enum_three")
             |> Enum.find(&(&1.internal_name == "enum_three_closed"))
             |> is_nil()
  end
end
