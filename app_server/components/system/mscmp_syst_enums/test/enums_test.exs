# Source File: enums_test.exs
# Location:    musebms/app_server/components/system/mscmp_syst_enums/test/enums_test.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule EnumsTest do
  @moduledoc false

  # Unit tests verify the correct functioning of individual implementation
  # module functions. We test the Impl.Enums module functions directly
  # rather than going through the API layer.
  #
  # Write operations (create/update/delete) are called via GenServer since
  # they need to modify the protected ETS table, but we're still testing
  # the Impl.Enums module behavior.

  use EnumsTestCase, async: true

  alias MscmpSystEnums.Impl.Enums
  alias MscmpSystEnums.Runtime.ProcessUtils

  @moduletag :unit
  @moduletag :capture_log

  # Helper to get the ETS table from the running service
  defp get_enums_table do
    ProcessUtils.get_enums_table()
  end

  # Helper to get the service name
  defp get_service do
    ProcessUtils.get_service()
  end

  describe "get_values/2 tests" do
    test "retrieve enum values from ETS table" do
      enums_table = get_enums_table()

      assert %Msdata.SystEnums{
               internal_name: "test_syst_enum_one",
               enum_items: enum_items
             } = Enums.get_values(enums_table, "test_syst_enum_one")

      assert is_list(enum_items)
      assert 3 == length(enum_items)
    end

    test "retrieve enum with functional types" do
      enums_table = get_enums_table()

      assert %Msdata.SystEnums{
               internal_name: "test_syst_enum_one",
               functional_types: functional_types
             } = Enums.get_values(enums_table, "test_syst_enum_one")

      assert is_list(functional_types)
      assert 2 == length(functional_types)
    end

    test "retrieve enum without functional types" do
      enums_table = get_enums_table()

      assert %Msdata.SystEnums{
               internal_name: "test_syst_enum_two",
               functional_types: functional_types
             } = Enums.get_values(enums_table, "test_syst_enum_two")

      assert [] == functional_types
    end
  end

  describe "list_all/1 tests" do
    test "retrieve all enums from ETS table" do
      enums_table = get_enums_table()

      assert all_enums = Enums.list_all(enums_table)
      assert is_list(all_enums)
      assert length(all_enums) >= 3

      all_enum_internal_names = Enum.map(all_enums, fn enum -> enum.internal_name end)

      assert "test_syst_enum_one" in all_enum_internal_names
      assert "test_syst_enum_two" in all_enum_internal_names
      assert "test_syst_enum_three" in all_enum_internal_names
    end

    test "all returned items are SystEnums structs" do
      enums_table = get_enums_table()

      all_enums = Enums.list_all(enums_table)

      assert Enum.all?(all_enums, fn enum -> match?(%Msdata.SystEnums{}, enum) end)
    end
  end

  describe "get_syst_defined/2 tests" do
    test "returns true for system defined enum" do
      enums_table = get_enums_table()

      assert true === Enums.get_syst_defined(enums_table, "test_syst_enum_one")
    end

    test "returns true for all test enums (all are system defined)" do
      enums_table = get_enums_table()

      assert true === Enums.get_syst_defined(enums_table, "test_syst_enum_two")
      assert true === Enums.get_syst_defined(enums_table, "test_syst_enum_three")
    end
  end

  describe "get_user_maintainable/2 tests" do
    test "returns false for non-user-maintainable enum" do
      enums_table = get_enums_table()

      assert false === Enums.get_user_maintainable(enums_table, "test_syst_enum_one")
    end

    test "returns true for user-maintainable enum" do
      enums_table = get_enums_table()

      assert true === Enums.get_user_maintainable(enums_table, "test_syst_enum_two")
      assert true === Enums.get_user_maintainable(enums_table, "test_syst_enum_three")
    end
  end

  describe "list_items/2 tests" do
    test "retrieve items list for enum" do
      enums_table = get_enums_table()

      assert enum_items = Enums.list_items(enums_table, "test_syst_enum_one")
      assert is_list(enum_items)
      assert 3 == length(enum_items)

      assert Enum.all?(enum_items, fn item -> match?(%Msdata.SystEnumItems{}, item) end)
    end

    test "items have expected internal names" do
      enums_table = get_enums_table()

      enum_items = Enums.list_items(enums_table, "test_syst_enum_one")
      item_names = Enum.map(enum_items, & &1.internal_name)

      assert "enum_one_cancelled" in item_names
      assert "enum_one_closed" in item_names
      assert "enum_one_active" in item_names
    end

    test "retrieve items for enum with no functional types" do
      enums_table = get_enums_table()

      assert enum_items = Enums.list_items(enums_table, "test_syst_enum_two")
      # At least 3 seeded items, may have more from other async tests
      assert length(enum_items) >= 3
    end
  end

  describe "list_sorted_items/2 tests" do
    test "items are sorted by sort_order" do
      enums_table = get_enums_table()

      sorted_items = Enums.list_sorted_items(enums_table, "test_syst_enum_one")

      assert is_list(sorted_items)
      assert 3 == length(sorted_items)

      # Verify sorting
      sort_orders = Enum.map(sorted_items, & &1.sort_order)
      assert sort_orders == Enum.sort(sort_orders)
    end

    test "sorted items contain all items" do
      enums_table = get_enums_table()

      unsorted_items = Enums.list_items(enums_table, "test_syst_enum_two")
      sorted_items = Enums.list_sorted_items(enums_table, "test_syst_enum_two")

      unsorted_ids = Enum.map(unsorted_items, & &1.id) |> Enum.sort()
      sorted_ids = Enum.map(sorted_items, & &1.id) |> Enum.sort()

      assert unsorted_ids == sorted_ids
    end
  end

  describe "list_functional_types/2 tests" do
    test "retrieve functional types for enum" do
      enums_table = get_enums_table()

      assert functional_types =
               Enums.list_functional_types(enums_table, "test_syst_enum_one")

      assert is_list(functional_types)
      assert 2 == length(functional_types)

      assert Enum.all?(functional_types, fn ft ->
               match?(%Msdata.SystEnumFunctionalTypes{}, ft)
             end)
    end

    test "functional types have expected internal names" do
      enums_table = get_enums_table()

      functional_types = Enums.list_functional_types(enums_table, "test_syst_enum_one")
      ft_names = Enum.map(functional_types, & &1.internal_name)

      assert "enum_one_active" in ft_names
      assert "enum_one_inactive" in ft_names
    end

    test "returns empty list for enum with no functional types" do
      enums_table = get_enums_table()

      assert [] === Enums.list_functional_types(enums_table, "test_syst_enum_two")
    end
  end

  describe "get_item_by_name/3 tests" do
    test "retrieve existing item by name" do
      enums_table = get_enums_table()

      assert %Msdata.SystEnumItems{internal_name: "enum_two_closed"} =
               Enums.get_item_by_name(enums_table, "test_syst_enum_two", "enum_two_closed")
    end

    test "retrieve item with functional type" do
      enums_table = get_enums_table()

      assert %Msdata.SystEnumItems{
               internal_name: "enum_one_active",
               functional_type: %Msdata.SystEnumFunctionalTypes{
                 internal_name: "enum_one_active"
               }
             } = Enums.get_item_by_name(enums_table, "test_syst_enum_one", "enum_one_active")
    end

    test "returns nil for non-existent item" do
      enums_table = get_enums_table()

      assert nil ===
               Enums.get_item_by_name(
                 enums_table,
                 "test_syst_enum_one",
                 "non_existent_item"
               )
    end
  end

  describe "get_item_by_id/3 tests" do
    test "retrieve item by id" do
      enums_table = get_enums_table()

      [test_enum_item | _] = Enums.list_items(enums_table, "test_syst_enum_one")

      assert ^test_enum_item =
               Enums.get_item_by_id(enums_table, "test_syst_enum_one", test_enum_item.id)
    end

    test "returns nil for non-existent id" do
      enums_table = get_enums_table()

      fake_uuid = Ecto.UUID.generate()

      assert nil === Enums.get_item_by_id(enums_table, "test_syst_enum_one", fake_uuid)
    end
  end

  describe "get_default_item/3 tests" do
    test "retrieve enum default item without functional type" do
      enums_table = get_enums_table()

      assert %Msdata.SystEnumItems{
               internal_name: "enum_two_active",
               enum_default: true
             } = Enums.get_default_item(enums_table, "test_syst_enum_two", [])
    end

    test "retrieve functional type default item" do
      enums_table = get_enums_table()

      assert %Msdata.SystEnumItems{
               internal_name: "enum_one_active",
               functional_type_default: true
             } =
               Enums.get_default_item(enums_table, "test_syst_enum_one",
                 functional_type_name: "enum_one_active"
               )

      assert %Msdata.SystEnumItems{
               internal_name: "enum_one_closed",
               functional_type_default: true
             } =
               Enums.get_default_item(enums_table, "test_syst_enum_one",
                 functional_type_name: "enum_one_inactive"
               )
    end

    test "retrieve enum default for enum with functional types when no type specified" do
      enums_table = get_enums_table()

      assert %Msdata.SystEnumItems{
               internal_name: "enum_one_active",
               enum_default: true
             } = Enums.get_default_item(enums_table, "test_syst_enum_one", [])
    end
  end

  describe "get_functional_type_by_item_id/2 tests" do
    test "retrieve functional type name for item" do
      enums_table = get_enums_table()

      item = Enums.get_item_by_name(enums_table, "test_syst_enum_one", "enum_one_active")

      assert "enum_one_active" ===
               Enums.get_functional_type_by_item_id("test_syst_enum_one", item.id)
    end

    test "retrieve functional type for different items" do
      enums_table = get_enums_table()

      cancelled_item =
        Enums.get_item_by_name(enums_table, "test_syst_enum_one", "enum_one_cancelled")

      assert "enum_one_inactive" ===
               Enums.get_functional_type_by_item_id("test_syst_enum_one", cancelled_item.id)
    end
  end

  describe "create/2 tests" do
    test "create simple enum without functional types or items" do
      enums_table = get_enums_table()
      service = get_service()

      enum_params = %{
        internal_name: "unit_test_simple_enum_#{:rand.uniform(1_000_000)}",
        display_name: "Unit Test Simple Enum",
        user_description: "A simple test enum"
      }

      assert :ok = GenServer.call(service, {:create, enum_params})

      # Verify enum was created
      created_enum = Enums.get_values(enums_table, enum_params.internal_name)
      assert enum_params.internal_name == created_enum.internal_name
      assert "Unit Test Simple Enum" == created_enum.display_name
      assert false == created_enum.syst_defined
      assert true == created_enum.user_maintainable
    end

    test "create enum with functional types" do
      enums_table = get_enums_table()
      service = get_service()

      enum_params = %{
        internal_name: "unit_test_with_func_types_#{:rand.uniform(1_000_000)}",
        display_name: "Unit Test With Func Types",
        user_description: "Test enum with functional types",
        functional_types: [
          %{
            internal_name: "unit_ft_active",
            display_name: "Unit Test / Active",
            external_name: "Active",
            user_description: "Active functional type"
          },
          %{
            internal_name: "unit_ft_inactive",
            display_name: "Unit Test / Inactive",
            external_name: "Inactive",
            user_description: "Inactive functional type"
          }
        ]
      }

      assert :ok = GenServer.call(service, {:create, enum_params})

      # Verify functional types were created
      func_types = Enums.list_functional_types(enums_table, enum_params.internal_name)
      assert 2 == length(func_types)
      assert Enum.any?(func_types, &(&1.internal_name == "unit_ft_active"))
      assert Enum.any?(func_types, &(&1.internal_name == "unit_ft_inactive"))
    end

    test "create enum with functional types and items" do
      enums_table = get_enums_table()
      service = get_service()

      enum_params = %{
        internal_name: "unit_test_full_enum_#{:rand.uniform(1_000_000)}",
        display_name: "Unit Test Full Enum",
        user_description: "Test enum with everything",
        default_user_options: %{"test_option" => "value"},
        functional_types: [
          %{
            internal_name: "unit_full_active",
            display_name: "Unit Test Full / Active",
            external_name: "Active",
            user_description: "Active functional type"
          }
        ],
        enum_items: [
          %{
            internal_name: "unit_full_item_one",
            display_name: "Unit Test Full / Item One",
            external_name: "Item One",
            user_description: "First test item",
            functional_type_name: "unit_full_active",
            functional_type_default: true,
            enum_default: true,
            sort_order: 1
          },
          %{
            internal_name: "unit_full_item_two",
            display_name: "Unit Test Full / Item Two",
            external_name: "Item Two",
            user_description: "Second test item",
            functional_type_name: "unit_full_active",
            functional_type_default: false,
            enum_default: false,
            sort_order: 2
          }
        ]
      }

      assert :ok = GenServer.call(service, {:create, enum_params})

      # Verify items were created
      items = Enums.list_items(enums_table, enum_params.internal_name)
      assert 2 == length(items)

      # Verify sorting
      sorted_items = Enums.list_sorted_items(enums_table, enum_params.internal_name)
      assert "unit_full_item_one" == hd(sorted_items).internal_name
    end

    test "create enum without functional types but with items" do
      enums_table = get_enums_table()
      service = get_service()

      enum_params = %{
        internal_name: "unit_test_no_ft_#{:rand.uniform(1_000_000)}",
        display_name: "Unit Test No FT",
        user_description: "Test enum without functional types",
        enum_items: [
          %{
            internal_name: "unit_no_ft_item_one",
            display_name: "Unit Test No FT / Item One",
            external_name: "Item One",
            user_description: "Test item without functional type",
            enum_default: true,
            sort_order: 1
          }
        ]
      }

      assert :ok = GenServer.call(service, {:create, enum_params})

      # Verify item was created without functional type
      item = Enums.get_item_by_name(enums_table, enum_params.internal_name, "unit_no_ft_item_one")
      assert nil == item.functional_type_id
    end
  end

  describe "create_functional_type/3 tests" do
    test "add functional type to existing user enum" do
      enums_table = get_enums_table()
      service = get_service()

      # First create an enum
      enum_name = "unit_test_add_ft_#{:rand.uniform(1_000_000)}"

      enum_params = %{
        internal_name: enum_name,
        display_name: "Unit Test Add FT",
        user_description: "Test adding functional types"
      }

      assert :ok = GenServer.call(service, {:create, enum_params})

      # Now add a functional type
      ft_params = %{
        internal_name: "unit_added_ft",
        display_name: "Unit Test / Added FT",
        external_name: "Added",
        user_description: "Added functional type"
      }

      assert :ok = GenServer.call(service, {:create_functional_type, enum_name, ft_params})

      # Verify functional type was added
      func_types = Enums.list_functional_types(enums_table, enum_name)
      assert 1 == length(func_types)
      assert "unit_added_ft" == hd(func_types).internal_name
    end

    test "attempt to add functional type to system enum fails" do
      service = get_service()

      ft_params = %{
        internal_name: "should_fail_ft",
        display_name: "Should Fail",
        external_name: "Fail",
        user_description: "This should fail"
      }

      # test_syst_enum_one is system defined
      assert {:error, _} =
               GenServer.call(service, {:create_functional_type, "test_syst_enum_one", ft_params})
    end
  end

  describe "create_item/3 tests" do
    test "add item to user enum with functional types" do
      enums_table = get_enums_table()
      service = get_service()

      # Create enum with functional type
      enum_name = "unit_test_add_item_#{:rand.uniform(1_000_000)}"

      enum_params = %{
        internal_name: enum_name,
        display_name: "Unit Test Add Item",
        user_description: "Test adding items",
        functional_types: [
          %{
            internal_name: "unit_add_item_ft",
            display_name: "Unit Test / FT",
            external_name: "FT",
            user_description: "Functional type for item test"
          }
        ]
      }

      assert :ok = GenServer.call(service, {:create, enum_params})

      # Now add an item
      item_params = %{
        internal_name: "unit_added_item",
        display_name: "Unit Test / Added Item",
        external_name: "Added",
        user_description: "Added item",
        functional_type_name: "unit_add_item_ft",
        functional_type_default: true,
        enum_default: true,
        sort_order: 1
      }

      assert :ok = GenServer.call(service, {:create_item, enum_name, item_params})

      # Verify item was added
      item = Enums.get_item_by_name(enums_table, enum_name, "unit_added_item")
      assert "Unit Test / Added Item" == item.display_name
      assert true == item.enum_default
    end

    test "add item to user enum without functional types" do
      enums_table = get_enums_table()
      service = get_service()

      enum_name = "unit_test_add_item_no_ft_#{:rand.uniform(1_000_000)}"

      enum_params = %{
        internal_name: enum_name,
        display_name: "Unit Test Add Item No FT",
        user_description: "Test adding items without functional types"
      }

      assert :ok = GenServer.call(service, {:create, enum_params})

      item_params = %{
        internal_name: "unit_added_item_no_ft",
        display_name: "Unit Test / Added Item No FT",
        external_name: "Added",
        user_description: "Added item without functional type",
        enum_default: true,
        sort_order: 1
      }

      assert :ok = GenServer.call(service, {:create_item, enum_name, item_params})

      # Verify item was added
      item = Enums.get_item_by_name(enums_table, enum_name, "unit_added_item_no_ft")
      assert nil == item.functional_type_id
    end

    test "add item to system enum that is user maintainable" do
      enums_table = get_enums_table()
      service = get_service()

      item_params = %{
        internal_name: "unit_system_enum_item_#{:rand.uniform(1_000_000)}",
        display_name: "Unit Test / System Enum Item",
        external_name: "New",
        user_description: "Item added to system enum",
        enum_default: false,
        sort_order: 10
      }

      # test_syst_enum_two is user maintainable
      assert :ok = GenServer.call(service, {:create_item, "test_syst_enum_two", item_params})

      # Verify item was added
      item = Enums.get_item_by_name(enums_table, "test_syst_enum_two", item_params.internal_name)
      assert "Unit Test / System Enum Item" == item.display_name
    end
  end

  describe "set_values/3 tests" do
    test "update user enum display name and description" do
      enums_table = get_enums_table()
      service = get_service()

      # Create enum to update
      enum_name = "unit_test_update_enum_#{:rand.uniform(1_000_000)}"

      enum_params = %{
        internal_name: enum_name,
        display_name: "Original Name",
        user_description: "Original description"
      }

      assert :ok = GenServer.call(service, {:create, enum_params})

      # Update the enum
      update_params = %{
        display_name: "Updated Name",
        user_description: "Updated description",
        default_user_options: %{"new_option" => "value"}
      }

      assert :ok = GenServer.call(service, {:set_values, enum_name, update_params})

      # Verify updates
      updated = Enums.get_values(enums_table, enum_name)
      assert "Updated Name" == updated.display_name
      assert "Updated description" == updated.user_description
      assert %{"new_option" => "value"} == updated.default_user_options
    end

    test "update user enum internal name" do
      enums_table = get_enums_table()
      service = get_service()

      old_name = "unit_test_rename_old_#{:rand.uniform(1_000_000)}"
      new_name = "unit_test_rename_new_#{:rand.uniform(1_000_000)}"

      enum_params = %{
        internal_name: old_name,
        display_name: "To Be Renamed",
        user_description: "Test renaming"
      }

      assert :ok = GenServer.call(service, {:create, enum_params})

      # Rename the enum
      update_params = %{internal_name: new_name}
      assert :ok = GenServer.call(service, {:set_values, old_name, update_params})

      # Verify old name is gone and new name exists
      assert catch_error(Enums.get_values(enums_table, old_name))
      renamed = Enums.get_values(enums_table, new_name)
      assert new_name == renamed.internal_name
    end

    test "attempt to update system enum internal name fails" do
      service = get_service()

      # System enums cannot have their internal_name changed
      assert {:error, _} =
               GenServer.call(
                 service,
                 {:set_values, "test_syst_enum_one", %{internal_name: "new_name"}}
               )
    end

    test "update system enum display name succeeds" do
      enums_table = get_enums_table()
      service = get_service()

      # Save original value
      original = Enums.get_values(enums_table, "test_syst_enum_one")
      original_display = original.display_name

      # Update display name
      new_display = "Updated System Enum Display #{:rand.uniform(1_000)}"

      assert :ok =
               GenServer.call(
                 service,
                 {:set_values, "test_syst_enum_one", %{display_name: new_display}}
               )

      # Verify update
      updated = Enums.get_values(enums_table, "test_syst_enum_one")
      assert new_display == updated.display_name

      # Restore original for other tests
      assert :ok =
               GenServer.call(
                 service,
                 {:set_values, "test_syst_enum_one", %{display_name: original_display}}
               )
    end
  end

  describe "set_functional_type_values/4 tests" do
    test "update functional type display and external names" do
      enums_table = get_enums_table()
      service = get_service()

      # Create enum with functional type
      enum_name = "unit_test_update_ft_#{:rand.uniform(1_000_000)}"

      enum_params = %{
        internal_name: enum_name,
        display_name: "Unit Test Update FT",
        user_description: "Test updating functional types",
        functional_types: [
          %{
            internal_name: "unit_ft_to_update",
            display_name: "Original FT Name",
            external_name: "Original",
            user_description: "Original description"
          }
        ]
      }

      assert :ok = GenServer.call(service, {:create, enum_params})

      # Update functional type
      ft_update = %{
        display_name: "Updated FT Name",
        external_name: "Updated",
        user_description: "Updated description"
      }

      assert :ok =
               GenServer.call(
                 service,
                 {:set_functional_type_values, enum_name, "unit_ft_to_update", ft_update}
               )

      # Verify updates
      func_types = Enums.list_functional_types(enums_table, enum_name)
      updated_ft = Enum.find(func_types, &(&1.internal_name == "unit_ft_to_update"))
      assert "Updated FT Name" == updated_ft.display_name
      assert "Updated" == updated_ft.external_name
    end

    test "attempt to update system functional type internal name fails" do
      service = get_service()

      assert {:error, _} =
               GenServer.call(
                 service,
                 {:set_functional_type_values, "test_syst_enum_one", "enum_one_active",
                  %{internal_name: "new_name"}}
               )
    end
  end

  describe "set_item_values/4 tests" do
    test "update enum item display name and options" do
      enums_table = get_enums_table()
      service = get_service()

      # Create enum with item
      enum_name = "unit_test_update_item_#{:rand.uniform(1_000_000)}"

      enum_params = %{
        internal_name: enum_name,
        display_name: "Unit Test Update Item",
        user_description: "Test updating items",
        enum_items: [
          %{
            internal_name: "unit_item_to_update",
            display_name: "Original Item Name",
            external_name: "Original",
            user_description: "Original description",
            enum_default: true,
            sort_order: 1,
            user_options: %{"original" => "value"}
          }
        ]
      }

      assert :ok = GenServer.call(service, {:create, enum_params})

      # Update item
      item_update = %{
        display_name: "Updated Item Name",
        external_name: "Updated",
        user_description: "Updated description",
        sort_order: 5,
        user_options: %{"updated" => "new_value"}
      }

      assert :ok =
               GenServer.call(
                 service,
                 {:set_item_values, enum_name, "unit_item_to_update", item_update}
               )

      # Verify updates
      updated_item = Enums.get_item_by_name(enums_table, enum_name, "unit_item_to_update")
      assert "Updated Item Name" == updated_item.display_name
      assert "Updated" == updated_item.external_name
      assert 5 == updated_item.sort_order
    end

    test "update system enum item that is user maintainable" do
      enums_table = get_enums_table()
      service = get_service()

      # enum_one_cancelled is user maintainable
      item_update = %{
        display_name: "Updated Cancelled Display #{:rand.uniform(1_000)}"
      }

      assert :ok =
               GenServer.call(
                 service,
                 {:set_item_values, "test_syst_enum_one", "enum_one_cancelled", item_update}
               )

      # Verify update
      updated = Enums.get_item_by_name(enums_table, "test_syst_enum_one", "enum_one_cancelled")
      assert String.starts_with?(updated.display_name, "Updated Cancelled Display")

      # Restore original
      restore = %{display_name: "Enum One/Cancelled"}

      assert :ok =
               GenServer.call(
                 service,
                 {:set_item_values, "test_syst_enum_one", "enum_one_cancelled", restore}
               )
    end

    test "attempt to update system enum item internal name fails" do
      service = get_service()

      # enum_one_active is not user maintainable
      assert {:error, _} =
               GenServer.call(
                 service,
                 {:set_item_values, "test_syst_enum_one", "enum_one_active",
                  %{internal_name: "new_name"}}
               )
    end
  end

  describe "delete/2 tests" do
    test "delete user enum" do
      enums_table = get_enums_table()
      service = get_service()

      # Create enum to delete
      enum_name = "unit_test_delete_enum_#{:rand.uniform(1_000_000)}"

      enum_params = %{
        internal_name: enum_name,
        display_name: "To Be Deleted",
        user_description: "This enum will be deleted"
      }

      assert :ok = GenServer.call(service, {:create, enum_params})

      # Verify it exists
      assert %Msdata.SystEnums{} = Enums.get_values(enums_table, enum_name)

      # Delete it
      assert :ok = GenServer.call(service, {:delete, enum_name})

      # Verify it's gone
      assert catch_error(Enums.get_values(enums_table, enum_name))
    end

    test "delete user enum with functional types and items cascades" do
      enums_table = get_enums_table()
      service = get_service()

      enum_name = "unit_test_delete_cascade_#{:rand.uniform(1_000_000)}"

      enum_params = %{
        internal_name: enum_name,
        display_name: "Delete With Cascade",
        user_description: "Test cascading delete",
        functional_types: [
          %{
            internal_name: "unit_delete_ft",
            display_name: "Delete FT",
            external_name: "Delete",
            user_description: "Will be deleted"
          }
        ],
        enum_items: [
          %{
            internal_name: "unit_delete_item",
            display_name: "Delete Item",
            external_name: "Delete",
            user_description: "Will be deleted",
            functional_type_name: "unit_delete_ft",
            functional_type_default: true,
            enum_default: true
          }
        ]
      }

      assert :ok = GenServer.call(service, {:create, enum_params})

      # Verify everything exists
      assert %Msdata.SystEnums{} = Enums.get_values(enums_table, enum_name)
      assert 1 == length(Enums.list_functional_types(enums_table, enum_name))
      assert 1 == length(Enums.list_items(enums_table, enum_name))

      # Delete the enum
      assert :ok = GenServer.call(service, {:delete, enum_name})

      # Verify everything is gone
      assert catch_error(Enums.get_values(enums_table, enum_name))
    end

    test "attempt to delete system enum fails" do
      service = get_service()

      assert {:error, _} = GenServer.call(service, {:delete, "test_syst_enum_one"})
    end

    test "attempt to delete non-existent enum fails" do
      service = get_service()

      assert {:error, {:not_found, "non_existent_enum"}} =
               GenServer.call(service, {:delete, "non_existent_enum"})
    end
  end

  describe "delete_functional_type/3 tests" do
    test "delete functional type from user enum" do
      enums_table = get_enums_table()
      service = get_service()

      enum_name = "unit_test_delete_ft_#{:rand.uniform(1_000_000)}"

      enum_params = %{
        internal_name: enum_name,
        display_name: "Delete FT Test",
        user_description: "Test deleting functional types",
        functional_types: [
          %{
            internal_name: "unit_ft_to_delete",
            display_name: "To Be Deleted",
            external_name: "Delete",
            user_description: "Will be deleted"
          },
          %{
            internal_name: "unit_ft_to_keep",
            display_name: "To Be Kept",
            external_name: "Keep",
            user_description: "Will remain"
          }
        ]
      }

      assert :ok = GenServer.call(service, {:create, enum_params})

      # Verify both exist
      assert 2 == length(Enums.list_functional_types(enums_table, enum_name))

      # Delete one
      assert :ok =
               GenServer.call(service, {:delete_functional_type, enum_name, "unit_ft_to_delete"})

      # Verify only one remains
      func_types = Enums.list_functional_types(enums_table, enum_name)
      assert 1 == length(func_types)
      assert "unit_ft_to_keep" == hd(func_types).internal_name
    end

    test "attempt to delete system functional type fails" do
      service = get_service()

      assert {:error, _} =
               GenServer.call(
                 service,
                 {:delete_functional_type, "test_syst_enum_one", "enum_one_active"}
               )
    end
  end

  describe "delete_item/3 tests" do
    test "delete item from user enum" do
      enums_table = get_enums_table()
      service = get_service()

      enum_name = "unit_test_delete_item_#{:rand.uniform(1_000_000)}"

      enum_params = %{
        internal_name: enum_name,
        display_name: "Delete Item Test",
        user_description: "Test deleting items",
        enum_items: [
          %{
            internal_name: "unit_item_to_delete",
            display_name: "To Be Deleted",
            external_name: "Delete",
            user_description: "Will be deleted",
            enum_default: false,
            sort_order: 1
          },
          %{
            internal_name: "unit_item_to_keep",
            display_name: "To Be Kept",
            external_name: "Keep",
            user_description: "Will remain",
            enum_default: true,
            sort_order: 2
          }
        ]
      }

      assert :ok = GenServer.call(service, {:create, enum_params})

      # Verify both exist
      assert 2 == length(Enums.list_items(enums_table, enum_name))

      # Delete one
      assert :ok = GenServer.call(service, {:delete_item, enum_name, "unit_item_to_delete"})

      # Verify only one remains
      items = Enums.list_items(enums_table, enum_name)
      assert 1 == length(items)
      assert "unit_item_to_keep" == hd(items).internal_name
    end

    test "delete user-created item from system enum" do
      enums_table = get_enums_table()
      service = get_service()

      # Create an item to delete
      item_name = "unit_delete_sys_item_#{:rand.uniform(1_000_000)}"

      item_params = %{
        internal_name: item_name,
        display_name: "To Delete From System Enum",
        external_name: "Delete",
        user_description: "User item in system enum",
        enum_default: false,
        sort_order: 99
      }

      assert :ok = GenServer.call(service, {:create_item, "test_syst_enum_two", item_params})

      # Verify it exists
      assert %Msdata.SystEnumItems{} =
               Enums.get_item_by_name(enums_table, "test_syst_enum_two", item_name)

      # Delete it
      assert :ok = GenServer.call(service, {:delete_item, "test_syst_enum_two", item_name})

      # Verify it's gone
      assert nil == Enums.get_item_by_name(enums_table, "test_syst_enum_two", item_name)
    end

    test "attempt to delete system enum item fails" do
      service = get_service()

      # enum_one_active is system defined and not user maintainable
      assert {:error, _} =
               GenServer.call(service, {:delete_item, "test_syst_enum_one", "enum_one_active"})
    end
  end

  # Note: refresh_from_database/1 and refresh_enum_from_database/2 cannot be
  # directly tested in unit tests because they require ETS write access which
  # is only available to the GenServer process. These functions are tested
  # indirectly through the create/update/delete operations which all call
  # refresh functions internally.
end
