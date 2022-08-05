# Source File: enum_items_test.exs
# Location:    musebms/components/system/msbms_syst_enums/test/enum_items_test.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule EnumItemsTest do
  use EnumsTestCase, async: true

  test "Get Enum Items" do
    assert enum_items = MsbmsSystEnums.list_enum_items("test_syst_enum_one")
    assert 3 = length(enum_items)
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

    :ok = MsbmsSystEnums.create_enum(success_enum_no_types)
    :ok = MsbmsSystEnums.create_enum(success_enum_with_types)

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
      functional_type_name: "create_enum_item_enum_with_types_type"
    }

    assert {:error, _} =
             MsbmsSystEnums.create_enum_item(
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
      functional_type_name: "create_enum_item_enum_with_types_type"
    }

    assert :ok =
             MsbmsSystEnums.create_enum_item(
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
      functional_type_name: "enum_three_active"
    }

    assert :ok =
             MsbmsSystEnums.create_enum_item(
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
      functional_type_name: "create_enum_item_enum_with_types_type"
    }

    assert {:error, _} =
             MsbmsSystEnums.create_enum_item(
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
      functional_type_name: "enum_one_active"
    }

    assert {:error, _} =
             MsbmsSystEnums.create_enum_item(
               "test_syst_enum_one",
               failure_system_type_enum_item_not_allowed
             )
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

    other_enum = MsbmsSystEnums.get_enum_values("test_syst_enum_two")

    %{enum_items: enum_items} = MsbmsSystEnums.get_enum_values("test_syst_enum_one")

    orig_enum_item = Enum.find(enum_items, &(&1.internal_name == "enum_one_active"))

    change_enum_id = %{enum_id: other_enum.id}

    orig_functional_type =
      MsbmsSystEnums.list_enum_functional_types("test_syst_enum_one")
      |> Enum.find(&(&1.internal_name == "enum_one_active"))

    other_functional_type =
      MsbmsSystEnums.list_enum_functional_types("test_syst_enum_one")
      |> Enum.find(&(&1.internal_name == "enum_one_inactive"))

    change_functional_type = %{functional_type_id: other_functional_type.id}

    assert {:error, _} =
             MsbmsSystEnums.set_enum_item_values(
               "test_syst_enum_one",
               "enum_one_active",
               change_internal_name
             )

    assert {:error, _} =
             MsbmsSystEnums.set_enum_item_values(
               "test_syst_enum_one",
               "enum_one_active",
               change_enum_id
             )

    assert {:error, _} =
             MsbmsSystEnums.set_enum_item_values(
               "test_syst_enum_one",
               "enum_one_active",
               change_functional_type
             )

    assert :ok =
             MsbmsSystEnums.set_enum_item_values(
               "test_syst_enum_one",
               "enum_one_active",
               change_display_name
             )

    assert :ok =
             MsbmsSystEnums.set_enum_item_values(
               "test_syst_enum_one",
               "enum_one_active",
               change_user_description
             )

    assert :ok =
             MsbmsSystEnums.set_enum_item_values(
               "test_syst_enum_one",
               "enum_one_active",
               change_enum_default
             )

    assert :ok =
             MsbmsSystEnums.set_enum_item_values(
               "test_syst_enum_one",
               "enum_one_active",
               change_functional_type_default
             )

    assert :ok =
             MsbmsSystEnums.set_enum_item_values(
               "test_syst_enum_one",
               "enum_one_active",
               change_sort_order
             )

    assert :ok =
             MsbmsSystEnums.set_enum_item_values(
               "test_syst_enum_one",
               "enum_one_active",
               change_user_options
             )

    assert :ok =
             MsbmsSystEnums.set_enum_item_values(
               "test_syst_enum_one",
               "enum_one_active",
               change_external_name
             )

    %{enum_items: enum_items} = MsbmsSystEnums.get_enum_values("test_syst_enum_one")

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
          functional_type_name: "user_def_enum_item_changes_func_type",
          functional_type_default: true,
          enum_default: true
        }
      ]
    }

    :ok = MsbmsSystEnums.create_enum(new_enum)

    change_internal_name = %{internal_name: "user_def_enum_item_changes_new"}
    change_display_name = %{display_name: "User Defined Enum Item Changes New"}
    change_user_description = %{user_description: "User Defined Enum Item Changes New"}
    change_external_name = %{external_name: "User Defined Enum Item Changes New"}
    change_enum_default = %{enum_default: false}
    change_functional_type_default = %{functional_type_default: false}
    change_sort_order = %{sort_order: 2}
    change_user_options = %{user_options: %{"user_key1" => 1, "user_key2" => 2, "user_key3" => 3}}

    other_enum = MsbmsSystEnums.get_enum_values("test_syst_enum_two")

    %{enum_items: enum_items} = MsbmsSystEnums.get_enum_values("user_def_enum_item_changes_enum")

    orig_enum_item =
      Enum.find(enum_items, &(&1.internal_name == "user_def_enum_item_changes_old"))

    change_enum_id = %{enum_id: other_enum.id}

    orig_functional_type =
      MsbmsSystEnums.list_enum_functional_types("user_def_enum_item_changes_enum")
      |> Enum.find(&(&1.internal_name == "user_def_enum_item_changes_func_type"))

    other_functional_type =
      MsbmsSystEnums.list_enum_functional_types("test_syst_enum_one")
      |> Enum.find(&(&1.internal_name == "enum_one_inactive"))

    change_functional_type = %{functional_type_id: other_functional_type.id}

    assert {:error, _} =
             MsbmsSystEnums.set_enum_item_values(
               "user_def_enum_item_changes_enum",
               "user_def_enum_item_changes_old",
               change_enum_id
             )

    assert {:error, _} =
             MsbmsSystEnums.set_enum_item_values(
               "user_def_enum_item_changes_enum",
               "user_def_enum_item_changes_old",
               change_functional_type
             )

    assert :ok =
             MsbmsSystEnums.set_enum_item_values(
               "user_def_enum_item_changes_enum",
               "user_def_enum_item_changes_old",
               change_internal_name
             )

    assert :ok =
             MsbmsSystEnums.set_enum_item_values(
               "user_def_enum_item_changes_enum",
               "user_def_enum_item_changes_new",
               change_display_name
             )

    assert :ok =
             MsbmsSystEnums.set_enum_item_values(
               "user_def_enum_item_changes_enum",
               "user_def_enum_item_changes_new",
               change_user_description
             )

    assert :ok =
             MsbmsSystEnums.set_enum_item_values(
               "user_def_enum_item_changes_enum",
               "user_def_enum_item_changes_new",
               change_enum_default
             )

    assert :ok =
             MsbmsSystEnums.set_enum_item_values(
               "user_def_enum_item_changes_enum",
               "user_def_enum_item_changes_new",
               change_functional_type_default
             )

    assert :ok =
             MsbmsSystEnums.set_enum_item_values(
               "user_def_enum_item_changes_enum",
               "user_def_enum_item_changes_new",
               change_sort_order
             )

    assert :ok =
             MsbmsSystEnums.set_enum_item_values(
               "user_def_enum_item_changes_enum",
               "user_def_enum_item_changes_new",
               change_user_options
             )

    assert :ok =
             MsbmsSystEnums.set_enum_item_values(
               "user_def_enum_item_changes_enum",
               "user_def_enum_item_changes_new",
               change_external_name
             )

    %{enum_items: enum_items} = MsbmsSystEnums.get_enum_values("user_def_enum_item_changes_enum")

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

  test "Delete User Defined Enum Items / System Defined Enum" do
    new_enum_item = %{
      internal_name: "delete_user_def_enum_item_syst_enum",
      display_name: "Delete User Defined Enum Item One/Syst Enum",
      external_name: "Delete User Defined Enum Item One / System Enum",
      user_description: "Delete User Defined Enum Item One for System Defined Enumeration",
      functional_type_name: "enum_three_active",
      functional_type_default: false,
      enum_default: true
    }

    :ok = MsbmsSystEnums.create_enum_item("test_syst_enum_three", new_enum_item)

    false =
      MsbmsSystEnums.list_enum_items("test_syst_enum_three")
      |> Enum.find(&(&1.internal_name == "delete_user_def_enum_item_syst_enum"))
      |> is_nil()

    assert :ok =
             MsbmsSystEnums.delete_enum_item(
               "test_syst_enum_three",
               "delete_user_def_enum_item_syst_enum"
             )

    assert true =
             MsbmsSystEnums.list_enum_items("test_syst_enum_three")
             |> Enum.find(&(&1.internal_name == "delete_user_def_enum_item_syst_enum"))
             |> is_nil()
  end

  test "Delete System Defined Enum Item" do
    false =
      MsbmsSystEnums.list_enum_items("test_syst_enum_three")
      |> Enum.find(&(&1.internal_name == "enum_three_closed"))
      |> is_nil()

    assert {:error, _} =
             MsbmsSystEnums.delete_enum_item(
               "test_syst_enum_three",
               "enum_three_closed"
             )

    assert false ==
             MsbmsSystEnums.list_enum_items("test_syst_enum_three")
             |> Enum.find(&(&1.internal_name == "enum_three_closed"))
             |> is_nil()
  end

  test "Get Default Enum Item" do
    assert %MsbmsSystEnums.Data.SystEnumItems{internal_name: "enum_three_active"} =
             MsbmsSystEnums.get_default_enum_item("test_syst_enum_three")
  end

  test "Get Default Enum Item for Functional Type" do
    assert %MsbmsSystEnums.Data.SystEnumItems{internal_name: "enum_three_closed"} =
             MsbmsSystEnums.get_default_enum_item("test_syst_enum_three",
               functional_type_name: "enum_three_inactive"
             )
  end
end
