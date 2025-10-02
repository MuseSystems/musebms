# Source File: integration_test.exs
# Location:    musebms/app_server/components/system/mscmp_syst_enums/test/integration_test.exs
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
  @moduledoc false

  use ExUnit.Case, async: false

  @moduletag :integration
  @moduletag :capture_log

  @svc_opt_service_name :enums_svc_01
  @svc_opt_datastore_context_name {:via, Registry,
                                   {MscmpSystEnums.TestRegistry,
                                    TestSupport.get_datastore_context_name()}}

  @tst_data_simple_enum %{
    internal_name: "int_test_simple_enum",
    display_name: "Integration Test Simple Enum",
    user_description: "A simple test enum without functional types or items"
  }

  @tst_data_complex_enum %{
    internal_name: "int_test_complex_enum",
    display_name: "Integration Test Complex Enum",
    user_description: "A complex test enum with functional types and items",
    default_user_options: %{"option1" => "value1", "option2" => 123},
    functional_types: [
      %{
        internal_name: "int_test_func_type_active",
        display_name: "Integration Test / Active",
        external_name: "Active",
        user_description: "Active functional type"
      },
      %{
        internal_name: "int_test_func_type_inactive",
        display_name: "Integration Test / Inactive",
        external_name: "Inactive",
        user_description: "Inactive functional type"
      }
    ],
    enum_items: [
      %{
        internal_name: "int_test_item_open",
        display_name: "Integration Test / Open",
        external_name: "Open",
        user_description: "Open status item",
        functional_type_name: "int_test_func_type_active",
        functional_type_default: true,
        enum_default: true,
        sort_order: 1,
        user_options: %{"status" => "open"}
      },
      %{
        internal_name: "int_test_item_closed",
        display_name: "Integration Test / Closed",
        external_name: "Closed",
        user_description: "Closed status item",
        functional_type_name: "int_test_func_type_inactive",
        functional_type_default: true,
        enum_default: false,
        sort_order: 2,
        user_options: %{"status" => "closed"}
      }
    ]
  }

  @tst_data_new_func_type %{
    internal_name: "int_test_func_type_pending",
    display_name: "Integration Test / Pending",
    external_name: "Pending",
    user_description: "Pending functional type"
  }

  @tst_data_new_item_user_enum %{
    internal_name: "int_test_item_pending",
    display_name: "Integration Test / Pending",
    external_name: "Pending",
    user_description: "Pending status item",
    functional_type_name: "int_test_func_type_pending",
    functional_type_default: true,
    enum_default: false,
    sort_order: 3,
    user_options: %{"status" => "pending"}
  }

  @tst_data_new_item_system_enum %{
    internal_name: "int_test_system_enum_item",
    display_name: "Test System Enum Two / New Item",
    external_name: "New Item",
    user_description: "New item for system enum",
    functional_type_name: "enum_two_active",
    functional_type_default: false,
    enum_default: false,
    sort_order: 10,
    user_options: %{"test" => "value"}
  }

  setup_all do
    # We're going to setup the datastore here since we're not really testing
    # `MscmpSystDb` and we don't want to have this as a question.  We don't use
    # EnumsTestCase because we want to manage our own `MscmpSystEnums` runtime
    # services as part of our integration testing.

    {:ok, MscmpSystDb.Runtime.Datastore} =
      MscmpSystDb.put_datastore_context(@svc_opt_datastore_context_name)

    :ok
  end

  describe "Phase 01 - Service Init & Startup" do
    test "Step 01.01 - Startup Enums Service" do
      assert child_spec =
               MscmpSystEnums.child_spec(
                 service_name: @svc_opt_service_name,
                 datastore_context_name: @svc_opt_datastore_context_name
               )

      assert %{id: MscmpSystEnums, start: {MscmpSystEnums, :start_link, [opts]}} =
               child_spec

      assert {:ok, :infinity} === Keyword.fetch(opts, :timeout)
      assert {:ok, @svc_opt_service_name} === Keyword.fetch(opts, :service_name)
      assert {:ok, datastore_context_name} = Keyword.fetch(opts, :datastore_context_name)
      assert @svc_opt_datastore_context_name === datastore_context_name

      assert {:ok, pid} =
               DynamicSupervisor.start_child(
                 :"MscmpSystEnums.TestSupportDynSupervisor",
                 child_spec
               )

      assert is_pid(pid)
    end

    test "Step 01.02 - Validate Enums Runtime Config" do
      assert nil === MscmpSystEnums.put_service(@svc_opt_service_name)
      assert @svc_opt_service_name === MscmpSystEnums.get_service()

      assert %{datastore_context_name: datastore_context_name, enums_table: enums_table} =
               MscmpSystEnums.get_runtime_config()

      assert is_reference(enums_table)
      assert @svc_opt_datastore_context_name === datastore_context_name

      assert @svc_opt_service_name === MscmpSystEnums.put_service(nil)
    end
  end

  describe "Phase 02 - Creating Enums" do
    test "Step 02.01 - Create Simple Enum" do
      assert nil === MscmpSystEnums.put_service(@svc_opt_service_name)

      assert :ok === MscmpSystEnums.create(@tst_data_simple_enum)

      # Verify the enum was created
      assert %Msdata.SystEnums{} = enum = MscmpSystEnums.get_values("int_test_simple_enum")
      assert "Integration Test Simple Enum" === enum.display_name
      assert false === enum.syst_defined
      assert true === enum.user_maintainable

      assert @svc_opt_service_name === MscmpSystEnums.put_service(nil)
    end

    test "Step 02.02 - Create Complex Enum with Functional Types and Items" do
      assert nil === MscmpSystEnums.put_service(@svc_opt_service_name)

      assert :ok === MscmpSystEnums.create(@tst_data_complex_enum)

      # Verify the enum was created
      assert %Msdata.SystEnums{} = enum = MscmpSystEnums.get_values("int_test_complex_enum")
      assert "Integration Test Complex Enum" === enum.display_name

      # Verify functional types were created
      func_types = MscmpSystEnums.list_functional_types("int_test_complex_enum")
      assert 2 === length(func_types)

      # Verify items were created
      items = MscmpSystEnums.list_items("int_test_complex_enum")
      assert 2 === length(items)

      assert @svc_opt_service_name === MscmpSystEnums.put_service(nil)
    end
  end

  describe "Phase 03 - Creating Enum Functional Types" do
    test "Step 03.01 - Create Functional Type on User Enum" do
      assert nil === MscmpSystEnums.put_service(@svc_opt_service_name)

      assert :ok ===
               MscmpSystEnums.create_functional_type(
                 "int_test_complex_enum",
                 @tst_data_new_func_type
               )

      # Verify the functional type was created
      func_types = MscmpSystEnums.list_functional_types("int_test_complex_enum")
      assert 3 === length(func_types)

      new_func_type = Enum.find(func_types, &(&1.internal_name == "int_test_func_type_pending"))
      assert "Integration Test / Pending" === new_func_type.display_name

      assert @svc_opt_service_name === MscmpSystEnums.put_service(nil)
    end

    test "Step 03.02 - Attempt to Create Functional Type on System Enum" do
      assert nil === MscmpSystEnums.put_service(@svc_opt_service_name)

      # This should fail because test_syst_enum_one is system defined
      assert {:error, %Mserror.EnumsError{}} =
               MscmpSystEnums.create_functional_type("test_syst_enum_one", %{
                 internal_name: "should_fail_func_type",
                 display_name: "Should Fail",
                 external_name: "Fail",
                 user_description: "This should fail"
               })

      assert @svc_opt_service_name === MscmpSystEnums.put_service(nil)
    end
  end

  describe "Phase 04 - Creating Enum Items" do
    test "Step 04.01 - Create Enum Item on User Enum" do
      assert nil === MscmpSystEnums.put_service(@svc_opt_service_name)

      assert :ok ===
               MscmpSystEnums.create_item(
                 "int_test_complex_enum",
                 @tst_data_new_item_user_enum
               )

      # Verify the item was created
      items = MscmpSystEnums.list_items("int_test_complex_enum")
      assert 3 === length(items)

      new_item =
        MscmpSystEnums.get_item_by_name("int_test_complex_enum", "int_test_item_pending")

      assert "Integration Test / Pending" === new_item.display_name
      assert "Pending" === new_item.external_name

      assert @svc_opt_service_name === MscmpSystEnums.put_service(nil)
    end

    test "Step 04.02 - Create Enum Item on System Enum (User Maintainable)" do
      assert nil === MscmpSystEnums.put_service(@svc_opt_service_name)

      # test_syst_enum_two is system defined but user maintainable for items
      assert :ok ===
               MscmpSystEnums.create_item(
                 "test_syst_enum_two",
                 @tst_data_new_item_system_enum
               )

      # Verify the item was created
      new_item =
        MscmpSystEnums.get_item_by_name("test_syst_enum_two", "int_test_system_enum_item")

      assert "Test System Enum Two / New Item" === new_item.display_name

      assert @svc_opt_service_name === MscmpSystEnums.put_service(nil)
    end
  end

  describe "Phase 05 - Using Enums" do
    test "Step 05.01 - Retrieve Enum Values" do
      assert nil === MscmpSystEnums.put_service(@svc_opt_service_name)

      assert %Msdata.SystEnums{} = enum = MscmpSystEnums.get_values("int_test_complex_enum")
      assert "int_test_complex_enum" === enum.internal_name
      assert "Integration Test Complex Enum" === enum.display_name
      assert "A complex test enum with functional types and items" === enum.user_description

      assert @svc_opt_service_name === MscmpSystEnums.put_service(nil)
    end

    test "Step 05.02 - List All Enums" do
      assert nil === MscmpSystEnums.put_service(@svc_opt_service_name)

      all_enums = MscmpSystEnums.list_all()
      assert is_list(all_enums)
      assert length(all_enums) > 0

      # Verify our test enums are in the list
      assert Enum.any?(all_enums, &(&1.internal_name == "int_test_simple_enum"))
      assert Enum.any?(all_enums, &(&1.internal_name == "int_test_complex_enum"))

      assert @svc_opt_service_name === MscmpSystEnums.put_service(nil)
    end

    test "Step 05.03 - Get Enum Items by Name and ID" do
      assert nil === MscmpSystEnums.put_service(@svc_opt_service_name)

      item_by_name =
        MscmpSystEnums.get_item_by_name("int_test_complex_enum", "int_test_item_open")

      assert "Integration Test / Open" === item_by_name.display_name

      # Get the same item by ID
      item_by_id = MscmpSystEnums.get_item_by_id("int_test_complex_enum", item_by_name.id)
      assert item_by_name.id === item_by_id.id
      assert item_by_name.internal_name === item_by_id.internal_name

      assert @svc_opt_service_name === MscmpSystEnums.put_service(nil)
    end

    test "Step 05.04 - List and Sort Enum Items" do
      assert nil === MscmpSystEnums.put_service(@svc_opt_service_name)

      items = MscmpSystEnums.list_items("int_test_complex_enum")
      assert 3 === length(items)

      sorted_items = MscmpSystEnums.list_sorted_items("int_test_complex_enum")
      assert 3 === length(sorted_items)

      # Verify sorting by checking order
      [first, second, third] = sorted_items
      assert first.sort_order <= second.sort_order
      assert second.sort_order <= third.sort_order

      assert @svc_opt_service_name === MscmpSystEnums.put_service(nil)
    end

    test "Step 05.05 - Get Default Enum Item" do
      assert nil === MscmpSystEnums.put_service(@svc_opt_service_name)

      # Get the default item for the enum
      default_item = MscmpSystEnums.get_default_item("int_test_complex_enum")
      assert "int_test_item_open" === default_item.internal_name
      assert true === default_item.enum_default

      # Get the default item for a specific functional type
      func_type_default =
        MscmpSystEnums.get_default_item("int_test_complex_enum",
          functional_type_name: "int_test_func_type_inactive"
        )

      assert "int_test_item_closed" === func_type_default.internal_name
      assert true === func_type_default.functional_type_default

      assert @svc_opt_service_name === MscmpSystEnums.put_service(nil)
    end

    test "Step 05.06 - List Functional Types" do
      assert nil === MscmpSystEnums.put_service(@svc_opt_service_name)

      func_types = MscmpSystEnums.list_functional_types("int_test_complex_enum")
      assert 3 === length(func_types)

      active_func_type =
        Enum.find(func_types, &(&1.internal_name == "int_test_func_type_active"))

      assert "Active" === active_func_type.external_name

      assert @svc_opt_service_name === MscmpSystEnums.put_service(nil)
    end

    test "Step 05.07 - Get Functional Type by Item ID" do
      assert nil === MscmpSystEnums.put_service(@svc_opt_service_name)

      item = MscmpSystEnums.get_item_by_name("int_test_complex_enum", "int_test_item_open")

      func_type_name =
        MscmpSystEnums.get_functional_type_by_item_id("int_test_complex_enum", item.id)

      assert "int_test_func_type_active" === func_type_name

      assert @svc_opt_service_name === MscmpSystEnums.put_service(nil)
    end

    test "Step 05.08 - Check System Defined and User Maintainable" do
      assert nil === MscmpSystEnums.put_service(@svc_opt_service_name)

      # User enum should not be system defined
      assert false === MscmpSystEnums.get_syst_defined("int_test_complex_enum")
      assert true === MscmpSystEnums.get_user_maintainable("int_test_complex_enum")

      # System enum
      assert true === MscmpSystEnums.get_syst_defined("test_syst_enum_one")
      assert false === MscmpSystEnums.get_user_maintainable("test_syst_enum_one")

      assert @svc_opt_service_name === MscmpSystEnums.put_service(nil)
    end
  end

  describe "Phase 06 - Updating Enum Items" do
    test "Step 06.01 - Update User Enum Item Values" do
      assert nil === MscmpSystEnums.put_service(@svc_opt_service_name)

      update_params = %{
        display_name: "Integration Test / Open (Updated)",
        external_name: "Open Updated",
        user_description: "Updated description for open item",
        user_options: %{"status" => "open_updated", "new_field" => "value"}
      }

      assert :ok ===
               MscmpSystEnums.set_item_values(
                 "int_test_complex_enum",
                 "int_test_item_open",
                 update_params
               )

      # Verify the updates
      updated_item =
        MscmpSystEnums.get_item_by_name("int_test_complex_enum", "int_test_item_open")

      assert "Integration Test / Open (Updated)" === updated_item.display_name
      assert "Open Updated" === updated_item.external_name
      assert "Updated description for open item" === updated_item.user_description

      assert @svc_opt_service_name === MscmpSystEnums.put_service(nil)
    end

    test "Step 06.02 - Update System Enum Item (User Maintainable)" do
      assert nil === MscmpSystEnums.put_service(@svc_opt_service_name)

      update_params = %{
        display_name: "Test System Enum One / New Item (Updated)",
        user_description: "Updated system enum item description"
      }

      assert :ok ===
               MscmpSystEnums.set_item_values(
                 "test_syst_enum_two",
                 "int_test_system_enum_item",
                 update_params
               )

      # Verify the updates
      updated_item =
        MscmpSystEnums.get_item_by_name("test_syst_enum_two", "int_test_system_enum_item")

      assert "Test System Enum One / New Item (Updated)" === updated_item.display_name

      assert @svc_opt_service_name === MscmpSystEnums.put_service(nil)
    end

    test "Step 06.03 - Attempt to Update System Defined Item Internal Name" do
      assert nil === MscmpSystEnums.put_service(@svc_opt_service_name)

      # Attempting to change internal_name of a system-defined item should fail
      assert {:error, %Mserror.EnumsError{}} =
               MscmpSystEnums.set_item_values(
                 "test_syst_enum_one",
                 "enum_one_active",
                 %{internal_name: "should_fail"}
               )

      assert @svc_opt_service_name === MscmpSystEnums.put_service(nil)
    end
  end

  describe "Phase 07 - Updating Enum Functional Types" do
    test "Step 07.01 - Update User Functional Type Values" do
      assert nil === MscmpSystEnums.put_service(@svc_opt_service_name)

      update_params = %{
        display_name: "Integration Test / Active (Updated)",
        external_name: "Active Updated",
        user_description: "Updated active functional type"
      }

      assert :ok ===
               MscmpSystEnums.set_functional_type_values(
                 "int_test_complex_enum",
                 "int_test_func_type_active",
                 update_params
               )

      # Verify the updates
      func_types = MscmpSystEnums.list_functional_types("int_test_complex_enum")

      updated_func_type =
        Enum.find(func_types, &(&1.internal_name == "int_test_func_type_active"))

      assert "Integration Test / Active (Updated)" === updated_func_type.display_name
      assert "Active Updated" === updated_func_type.external_name

      assert @svc_opt_service_name === MscmpSystEnums.put_service(nil)
    end

    test "Step 07.02 - Attempt to Update System Functional Type Internal Name" do
      assert nil === MscmpSystEnums.put_service(@svc_opt_service_name)

      # Attempting to change internal_name of a system-defined functional type should fail
      assert {:error, %Mserror.EnumsError{}} =
               MscmpSystEnums.set_functional_type_values(
                 "test_syst_enum_one",
                 "enum_one_active",
                 %{internal_name: "should_fail"}
               )

      assert @svc_opt_service_name === MscmpSystEnums.put_service(nil)
    end
  end

  describe "Phase 08 - Updating Enums" do
    test "Step 08.01 - Update User Enum Values" do
      assert nil === MscmpSystEnums.put_service(@svc_opt_service_name)

      update_params = %{
        display_name: "Integration Test Complex Enum (Updated)",
        user_description: "Updated description for complex enum",
        default_user_options: %{"option1" => "updated_value", "option3" => "new_option"}
      }

      assert :ok ===
               MscmpSystEnums.set_values("int_test_complex_enum", update_params)

      # Verify the updates
      updated_enum = MscmpSystEnums.get_values("int_test_complex_enum")
      assert "Integration Test Complex Enum (Updated)" === updated_enum.display_name
      assert "Updated description for complex enum" === updated_enum.user_description

      assert @svc_opt_service_name === MscmpSystEnums.put_service(nil)
    end

    test "Step 08.02 - Attempt to Update System Enum Internal Name" do
      assert nil === MscmpSystEnums.put_service(@svc_opt_service_name)

      # Attempting to change internal_name of a system-defined enum should fail
      assert {:error, %Mserror.EnumsError{}} =
               MscmpSystEnums.set_values("test_syst_enum_one", %{internal_name: "should_fail"})

      assert @svc_opt_service_name === MscmpSystEnums.put_service(nil)
    end
  end

  describe "Phase 09 - Deleting Enum Items" do
    test "Step 09.01 - Delete User Enum Item" do
      assert nil === MscmpSystEnums.put_service(@svc_opt_service_name)

      # Verify the item exists before deletion
      assert %Msdata.SystEnumItems{} =
               MscmpSystEnums.get_item_by_name("int_test_complex_enum", "int_test_item_pending")

      # Delete the item
      assert :ok ===
               MscmpSystEnums.delete_item("int_test_complex_enum", "int_test_item_pending")

      # Verify the item is gone
      items = MscmpSystEnums.list_items("int_test_complex_enum")
      refute Enum.any?(items, &(&1.internal_name == "int_test_item_pending"))

      assert @svc_opt_service_name === MscmpSystEnums.put_service(nil)
    end

    test "Step 09.02 - Delete Item from System Enum (User Created)" do
      assert nil === MscmpSystEnums.put_service(@svc_opt_service_name)

      # Verify the item exists
      assert %Msdata.SystEnumItems{} =
               MscmpSystEnums.get_item_by_name("test_syst_enum_two", "int_test_system_enum_item")

      # Delete the user-created item from system enum
      assert :ok ===
               MscmpSystEnums.delete_item("test_syst_enum_two", "int_test_system_enum_item")

      # Verify the item is gone
      items = MscmpSystEnums.list_items("test_syst_enum_two")
      refute Enum.any?(items, &(&1.internal_name == "int_test_system_enum_item"))

      assert @svc_opt_service_name === MscmpSystEnums.put_service(nil)
    end

    test "Step 09.03 - Attempt to Delete System Defined Item" do
      assert nil === MscmpSystEnums.put_service(@svc_opt_service_name)

      # Attempting to delete a system-defined item should fail
      assert {:error, %Mserror.EnumsError{}} =
               MscmpSystEnums.delete_item("test_syst_enum_one", "enum_one_active")

      # Verify the item still exists
      assert %Msdata.SystEnumItems{} =
               MscmpSystEnums.get_item_by_name("test_syst_enum_one", "enum_one_active")

      assert @svc_opt_service_name === MscmpSystEnums.put_service(nil)
    end
  end

  describe "Phase 10 - Deleting Enum Functional Types" do
    test "Step 10.01 - Delete User Functional Type" do
      assert nil === MscmpSystEnums.put_service(@svc_opt_service_name)

      # Verify the functional type exists
      func_types_before = MscmpSystEnums.list_functional_types("int_test_complex_enum")
      assert 3 === length(func_types_before)

      # Delete the functional type
      assert :ok ===
               MscmpSystEnums.delete_functional_type(
                 "int_test_complex_enum",
                 "int_test_func_type_pending"
               )

      # Verify the functional type is gone
      func_types_after = MscmpSystEnums.list_functional_types("int_test_complex_enum")
      assert 2 === length(func_types_after)
      refute Enum.any?(func_types_after, &(&1.internal_name == "int_test_func_type_pending"))

      assert @svc_opt_service_name === MscmpSystEnums.put_service(nil)
    end

    test "Step 10.02 - Attempt to Delete System Functional Type" do
      assert nil === MscmpSystEnums.put_service(@svc_opt_service_name)

      # Attempting to delete a system-defined functional type should fail
      assert {:error, %Mserror.EnumsError{}} =
               MscmpSystEnums.delete_functional_type("test_syst_enum_one", "enum_one_active")

      # Verify the functional type still exists
      func_types = MscmpSystEnums.list_functional_types("test_syst_enum_one")
      assert Enum.any?(func_types, &(&1.internal_name == "enum_one_active"))

      assert @svc_opt_service_name === MscmpSystEnums.put_service(nil)
    end
  end

  describe "Phase 11 - Deleting Enums" do
    test "Step 11.01 - Delete Simple User Enum" do
      assert nil === MscmpSystEnums.put_service(@svc_opt_service_name)

      # Verify the enum exists
      assert %Msdata.SystEnums{} = MscmpSystEnums.get_values("int_test_simple_enum")

      # Delete the enum
      assert :ok === MscmpSystEnums.delete("int_test_simple_enum")

      # Verify the enum is gone
      all_enums = MscmpSystEnums.list_all()
      refute Enum.any?(all_enums, &(&1.internal_name == "int_test_simple_enum"))

      assert @svc_opt_service_name === MscmpSystEnums.put_service(nil)
    end

    test "Step 11.02 - Delete Complex User Enum" do
      assert nil === MscmpSystEnums.put_service(@svc_opt_service_name)

      # Verify the enum exists
      assert %Msdata.SystEnums{} = MscmpSystEnums.get_values("int_test_complex_enum")

      # Delete the enum (should cascade to functional types and items)
      assert :ok === MscmpSystEnums.delete("int_test_complex_enum")

      # Verify the enum is gone
      all_enums = MscmpSystEnums.list_all()
      refute Enum.any?(all_enums, &(&1.internal_name == "int_test_complex_enum"))

      assert @svc_opt_service_name === MscmpSystEnums.put_service(nil)
    end
  end

  describe "Phase 12 - System Enums" do
    test "Step 12.01 - Attempt to Delete System Enum" do
      assert nil === MscmpSystEnums.put_service(@svc_opt_service_name)

      # Verify the system enum exists
      assert %Msdata.SystEnums{} = MscmpSystEnums.get_values("test_syst_enum_one")

      # Attempting to delete a system-defined enum should fail
      assert {:error, %Mserror.EnumsError{}} = MscmpSystEnums.delete("test_syst_enum_one")

      # Verify the enum still exists
      assert %Msdata.SystEnums{} = MscmpSystEnums.get_values("test_syst_enum_one")

      assert @svc_opt_service_name === MscmpSystEnums.put_service(nil)
    end

    test "Step 12.02 - Retrieve System Enum Data" do
      assert nil === MscmpSystEnums.put_service(@svc_opt_service_name)

      # Get the system enum
      assert %Msdata.SystEnums{} = enum = MscmpSystEnums.get_values("test_syst_enum_one")
      assert "test_syst_enum_one" === enum.internal_name
      assert "Test System Enum One" === enum.display_name
      assert true === enum.syst_defined
      assert false === enum.user_maintainable

      # Verify functional types
      func_types = MscmpSystEnums.list_functional_types("test_syst_enum_one")
      assert 2 === length(func_types)

      # Verify items
      items = MscmpSystEnums.list_items("test_syst_enum_one")
      assert 3 === length(items)

      assert @svc_opt_service_name === MscmpSystEnums.put_service(nil)
    end
  end

  describe "Phase 13 - Service Shutdown" do
    test "Step 13.01 - Shutdown Enums Service" do
      assert nil === MscmpSystEnums.put_service(@svc_opt_service_name)

      pid = Process.whereis(@svc_opt_service_name)
      assert is_pid(pid)

      # Gracefully terminate the service
      assert :ok === MscmpSystEnums.terminate_service()

      # Verify the process is no longer alive
      refute Process.alive?(pid)

      assert @svc_opt_service_name === MscmpSystEnums.put_service(nil)
    end
  end
end
