# Source File: functional_types_test.exs
# Location:    musebms/components/system/mscmp_syst_enums/test/functional_types_test.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule FunctionalTypesTest do
  use EnumsTestCase, async: true

  @moduletag :unit
  @moduletag :capture_log

  test "Get Enum Functional Types" do
    assert functional_types = MscmpSystEnums.list_enum_functional_types("test_syst_enum_one")

    assert 2 = length(functional_types)
  end

  test "Create New Enumeration Functional Type" do
    success_enum = %{
      internal_name: "create_func_type_test_success_enum",
      display_name: "Create Functional Type Enumeration (Success)",
      user_description: "A test enumeration to allow creating new functional types. (Success)"
    }

    :ok = MscmpSystEnums.create_enum(success_enum)

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

    :ok = MscmpSystEnums.create_enum(failure_enum)

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
             MscmpSystEnums.create_enum_functional_type(
               "create_func_type_test_success_enum",
               success_func_type
             )

    # The test below should fail since it has enum items defined, but currently
    # doesn't require functional types.  We cannot create a new requirement
    # for functional types under these conditions.

    assert {:error, _} =
             MscmpSystEnums.create_enum_functional_type(
               "create_func_type_test_failure_enum",
               failure_func_type
             )

    # This test should fail because the enum "test_syst_enum_one" is system
    # defined and therefore is not user maintainable in terms of functional
    # types.

    assert {:error, _} =
             MscmpSystEnums.create_enum_functional_type(
               "test_syst_enum_one",
               failure_func_type
             )
  end

  test "System Defined Functional Type Changes" do
    change_internal_name = %{internal_name: "test_one_change_name_test"}
    change_display_name = %{display_name: "Enum Test One / Change Name Test"}
    change_user_description = %{user_description: "Updated user description test"}
    change_external_name = %{external_name: "Changed Test External Name"}

    other_enum = MscmpSystEnums.get_enum_values("test_syst_enum_two")

    %{functional_types: functional_types} = MscmpSystEnums.get_enum_values("test_syst_enum_one")

    orig_functional_type = Enum.find(functional_types, &(&1.internal_name == "enum_one_active"))

    change_enum_id = %{enum_id: other_enum.id}

    assert {:error, _} =
             MscmpSystEnums.set_enum_functional_type_values(
               "test_syst_enum_one",
               "enum_one_active",
               change_internal_name
             )

    assert {:error, _} =
             MscmpSystEnums.set_enum_functional_type_values(
               "test_syst_enum_one",
               "enum_one_active",
               change_enum_id
             )

    assert :ok =
             MscmpSystEnums.set_enum_functional_type_values(
               "test_syst_enum_one",
               "enum_one_active",
               change_display_name
             )

    assert :ok =
             MscmpSystEnums.set_enum_functional_type_values(
               "test_syst_enum_one",
               "enum_one_active",
               change_user_description
             )

    assert :ok =
             MscmpSystEnums.set_enum_functional_type_values(
               "test_syst_enum_one",
               "enum_one_active",
               change_external_name
             )

    %{functional_types: functional_types} = MscmpSystEnums.get_enum_values("test_syst_enum_one")

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

    :ok = MscmpSystEnums.create_enum(new_enum)

    change_internal_name = %{internal_name: "user_def_func_type_changes_new"}
    change_display_name = %{display_name: "User Defined Enum Functional Type New"}
    change_user_description = %{user_description: "User Defined Enum Functional Type New"}
    change_external_name = %{external_name: "User Defined Enum Functional Type New"}

    other_enum = MscmpSystEnums.get_enum_values("test_syst_enum_two")

    %{functional_types: functional_types} =
      MscmpSystEnums.get_enum_values("user_def_func_type_changes_enum")

    orig_functional_type =
      Enum.find(functional_types, &(&1.internal_name == "user_def_func_type_changes_old"))

    change_enum_id = %{enum_id: other_enum.id}

    assert {:error, _} =
             MscmpSystEnums.set_enum_functional_type_values(
               "user_def_func_type_changes_enum",
               "user_def_func_type_changes_old",
               change_enum_id
             )

    assert :ok =
             MscmpSystEnums.set_enum_functional_type_values(
               "user_def_func_type_changes_enum",
               "user_def_func_type_changes_old",
               change_internal_name
             )

    assert :ok =
             MscmpSystEnums.set_enum_functional_type_values(
               "user_def_func_type_changes_enum",
               "user_def_func_type_changes_new",
               change_display_name
             )

    assert :ok =
             MscmpSystEnums.set_enum_functional_type_values(
               "user_def_func_type_changes_enum",
               "user_def_func_type_changes_new",
               change_user_description
             )

    assert :ok =
             MscmpSystEnums.set_enum_functional_type_values(
               "user_def_func_type_changes_enum",
               "user_def_func_type_changes_new",
               change_external_name
             )

    %{functional_types: functional_types} =
      MscmpSystEnums.get_enum_values("user_def_func_type_changes_enum")

    updated_functional_type =
      Enum.find(functional_types, &(&1.internal_name == "user_def_func_type_changes_new"))

    assert updated_functional_type.enum_id == orig_functional_type.enum_id

    assert %{user_description: "User Defined Enum Functional Type New"} = updated_functional_type

    assert %{display_name: "User Defined Enum Functional Type New"} = updated_functional_type

    assert %{external_name: "User Defined Enum Functional Type New"} = updated_functional_type
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
          functional_type_name: "delete_user_def_functional_type_failure",
          functional_type_default: true,
          enum_default: true
        }
      ]
    }

    :ok = MscmpSystEnums.create_enum(new_enum)

    before_functional_types =
      MscmpSystEnums.list_enum_functional_types("delete_user_defined_functional_type_enum")

    assert 2 = length(before_functional_types)

    assert :ok =
             MscmpSystEnums.delete_enum_functional_type(
               "delete_user_defined_functional_type_enum",
               "delete_user_def_functional_type_success"
             )

    assert {:error, _} =
             MscmpSystEnums.delete_enum_functional_type(
               "delete_user_defined_functional_type_enum",
               "delete_user_def_functional_type_failure"
             )

    after_functional_types =
      MscmpSystEnums.list_enum_functional_types("delete_user_defined_functional_type_enum")

    assert 1 = length(after_functional_types)
  end

  test "Delete System Defined Functional Types" do
    before_functional_types = MscmpSystEnums.list_enum_functional_types("test_syst_enum_three")

    assert 2 = length(before_functional_types)

    assert {:error, _} =
             MscmpSystEnums.delete_enum_functional_type(
               "test_syst_enum_three",
               "enum_three_active"
             )

    after_functional_types = MscmpSystEnums.list_enum_functional_types("test_syst_enum_three")

    assert 2 = length(after_functional_types)
  end
end
