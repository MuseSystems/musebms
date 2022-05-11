defmodule MsbmsSystEnumsTest do
  use EnumsTestCase, async: true

  test "Get Enum Values" do
    assert %MsbmsSystEnums.Data.SystEnums{
             internal_name: "test_syst_enum_one",
             enum_items: enum_items
           } = MsbmsSystEnums.get_enum_values("test_syst_enum_one")

    assert is_list(enum_items)
    assert 3 = length(enum_items)
  end

  test "Get All Enum Values" do
    assert all_enums = MsbmsSystEnums.get_all_enum_values()
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
    assert true === MsbmsSystEnums.get_enum_syst_defined("test_syst_enum_one")
  end

  test "Is Enumeration User Maintainable" do
    assert false ===
             MsbmsSystEnums.get_enum_user_maintainable("test_syst_enum_one")

    assert true ===
             MsbmsSystEnums.get_enum_user_maintainable("test_syst_enum_three")
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
          functional_type_name: "create_enum_func_type_one"
        },
        %{
          internal_name: "create_enum_test_item_one",
          display_name: "Create Enum Test / Item One",
          external_name: "Item One",
          user_description: "A testing enumeration item",
          enum_default: true,
          functional_type_default: true,
          functional_type_name: "create_enum_func_type_one",
          sort_order: 1
        },
        %{
          internal_name: "create_enum_test_item_two",
          display_name: "Create Enum Test / Item Two",
          external_name: "Item Two",
          user_description: "A testing enumeration item",
          enum_default: false,
          functional_type_default: true,
          functional_type_name: "create_enum_func_type_two",
          sort_order: 2
        }
      ]
    }

    assert :ok = MsbmsSystEnums.create_enum(new_enum)

    assert %{internal_name: "create_enum_test"} =
             MsbmsSystEnums.get_enum_values("create_enum_test")

    saved_enum_items = MsbmsSystEnums.get_sorted_enum_items("create_enum_test")

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

    assert :ok = MsbmsSystEnums.create_enum(new_enum)

    assert %{internal_name: "create_enum_no_items_test", functional_types: functional_types} =
             MsbmsSystEnums.get_enum_values("create_enum_no_items_test")

    assert 2 == length(functional_types)

    saved_enum_items = MsbmsSystEnums.get_sorted_enum_items("create_enum_no_items_test")

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

    assert :ok = MsbmsSystEnums.create_enum(new_enum)

    assert %{internal_name: "create_enum_test_no_func_type"} =
             MsbmsSystEnums.get_enum_values("create_enum_test_no_func_type")

    saved_enum_items = MsbmsSystEnums.get_sorted_enum_items("create_enum_test_no_func_type")

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

    assert :ok = MsbmsSystEnums.create_enum(new_enum)

    assert %{internal_name: "create_enum_test_no_func_type_no_items"} =
             MsbmsSystEnums.get_enum_values("create_enum_test_no_func_type_no_items")

    saved_enum_items =
      MsbmsSystEnums.get_sorted_enum_items("create_enum_test_no_func_type_no_items")

    assert 0 = length(saved_enum_items)
  end

  test "System Defined Enum Changes" do
    change_internal_name = %{internal_name: "test_one_change_name_test"}
    change_display_name = %{display_name: "Enum Test One / Change Name Test"}
    change_user_description = %{user_description: "Updated user description test"}
    change_default_user_options = %{default_user_options: %{"test" => "option"}}

    assert {:error, _} =
             MsbmsSystEnums.set_enum_values(
               "test_syst_enum_one",
               change_internal_name
             )

    assert %{internal_name: "test_syst_enum_one"} =
             MsbmsSystEnums.get_enum_values("test_syst_enum_one")

    assert :ok =
             MsbmsSystEnums.set_enum_values(
               "test_syst_enum_one",
               change_display_name
             )

    assert %{display_name: "Enum Test One / Change Name Test"} =
             MsbmsSystEnums.get_enum_values("test_syst_enum_one")

    assert :ok =
             MsbmsSystEnums.set_enum_values(
               "test_syst_enum_one",
               change_user_description
             )

    assert %{user_description: "Updated user description test"} =
             MsbmsSystEnums.get_enum_values("test_syst_enum_one")

    assert :ok =
             MsbmsSystEnums.set_enum_values(
               "test_syst_enum_one",
               change_default_user_options
             )

    assert %{default_user_options: %{"test" => "option"}} =
             MsbmsSystEnums.get_enum_values("test_syst_enum_one")
  end

  test "User Defined Enum Changes" do
    new_enum = %{
      internal_name: "user_define_enum_changes_test_old",
      display_name: "User Enum Changes Test / Old",
      user_description: "User Enum Changes Test Old.",
      default_user_options: %{"old_user_option" => "test"}
    }

    :ok = MsbmsSystEnums.create_enum(new_enum)

    change_internal_name = %{internal_name: "user_define_enum_changes_test_new"}
    change_display_name = %{display_name: "User Enum Changes Test / New"}
    change_user_description = %{user_description: "User Enum Changes Test New."}
    change_default_user_options = %{default_user_options: %{"new_user_option" => "test"}}

    assert :ok =
             MsbmsSystEnums.set_enum_values(
               "user_define_enum_changes_test_old",
               change_internal_name
             )

    catch_error(MsbmsSystEnums.get_enum_values("user_define_enum_changes_test_old"))

    assert %{internal_name: "user_define_enum_changes_test_new"} =
             MsbmsSystEnums.get_enum_values("user_define_enum_changes_test_new")

    assert :ok =
             MsbmsSystEnums.set_enum_values(
               "user_define_enum_changes_test_new",
               change_display_name
             )

    assert %{display_name: "User Enum Changes Test / New"} =
             MsbmsSystEnums.get_enum_values("user_define_enum_changes_test_new")

    assert :ok =
             MsbmsSystEnums.set_enum_values(
               "user_define_enum_changes_test_new",
               change_user_description
             )

    assert %{user_description: "User Enum Changes Test New."} =
             MsbmsSystEnums.get_enum_values("user_define_enum_changes_test_new")

    assert :ok =
             MsbmsSystEnums.set_enum_values(
               "user_define_enum_changes_test_new",
               change_default_user_options
             )

    assert %{default_user_options: %{"new_user_option" => "test"}} =
             MsbmsSystEnums.get_enum_values("user_define_enum_changes_test_new")
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
          functional_type_name: "delete_user_defined_enum__enum_func_type",
          functional_type_default: true,
          enum_default: true
        }
      ]
    }

    :ok = MsbmsSystEnums.create_enum(new_enum)

    assert(
      %MsbmsSystEnums.Data.SystEnums{} =
        MsbmsSystEnums.get_enum_values("delete_user_defined_enum")
    )

    assert :ok = MsbmsSystEnums.delete_enum("delete_user_defined_enum")

    catch_error(MsbmsSystEnums.get_enum_values("delete_user_defined_enum"))
  end

  test "Delete System Defined Enumeration" do
    assert {:error, _} = MsbmsSystEnums.delete_enum("test_syst_enum_three")

    assert(
      %MsbmsSystEnums.Data.SystEnums{} = MsbmsSystEnums.get_enum_values("test_syst_enum_three")
    )
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
          functional_type_name: "delete_user_def_functional_type_one",
          functional_type_default: true,
          enum_default: true
        },
        %{
          internal_name: "delete_user_def_enum_item_two",
          display_name: "Delete User Defined Enum Item Two",
          external_name: "Delete User Defined Enum Item Two",
          user_description: "Delete User Defined Enum Item Two",
          functional_type_name: "delete_user_def_functional_type_two",
          functional_type_default: true,
          enum_default: false
        }
      ]
    }

    :ok = MsbmsSystEnums.create_enum(new_enum)

    before_enum_items = MsbmsSystEnums.get_enum_items("delete_user_def_enum_item_enum")

    assert 2 = length(before_enum_items)

    assert :ok =
             MsbmsSystEnums.delete_enum_item(
               "delete_user_def_enum_item_enum",
               "delete_user_def_enum_item_two"
             )

    after_enum_items = MsbmsSystEnums.get_enum_items("delete_user_def_enum_item_enum")

    assert 1 = length(after_enum_items)
  end
end
