# Source File: integration_test.exs
# Location:    musebms/app_server/components/system/mscmp_syst_settings/test/integration_test.exs
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

  alias MscmpSystDb.DbTypes.DateRange
  alias MscmpSystDb.DbTypes.DecimalRange

  @moduletag :integration
  @moduletag :capture_log

  @svc_opt_service_name :int_test_settings_svc_01
  @svc_opt_datastore_context_name {:via, Registry,
                                   {MscmpSystSettings.TestRegistry,
                                    TestSupport.get_datastore_context_name()}}

  @tst_data_complex_setting %{
    internal_name: "complex_test_setting",
    display_name: "Complex Test Setting",
    user_description: "A test setting with all value types populated",
    setting_text: "test string value",
    setting_integer: 12_345,
    setting_decimal: Decimal.new("123.45"),
    setting_flag: true,
    setting_date: ~D[2023-01-01],
    setting_date_range: %DateRange{
      lower: ~D[2023-01-01],
      upper: ~D[2023-12-31],
      lower_inclusive: true,
      upper_inclusive: true
    },
    setting_decimal_range: %DecimalRange{
      lower: Decimal.new("0.00"),
      upper: Decimal.new("999.99"),
      lower_inclusive: true,
      upper_inclusive: false
    }
  }

  @tst_data_simple_setting %{
    internal_name: "simple_test_setting",
    display_name: "Simple Test Setting",
    user_description: "A basic test setting with minimal fields"
  }

  setup_all do
    # We're going to setup the datastore here since we're not really testing
    # `MscmpSystDb` and we don't want to have this as a question.  We don't use
    # SettingsTestCase because we want to manage our own `MscmpSystSettings`
    # runtime services as part of our integration testing.

    {:ok, MscmpSystDb.Runtime.Datastore} =
      MscmpSystDb.put_datastore_context(@svc_opt_datastore_context_name)

    :ok
  end

  describe "Phase 01 - Service Init & Startup" do
    test "Step 01.01 - Startup Settings Service" do
      assert child_spec =
               MscmpSystSettings.child_spec(
                 service_name: @svc_opt_service_name,
                 datastore_context_name: @svc_opt_datastore_context_name
               )

      assert %{id: MscmpSystSettings, start: {MscmpSystSettings, :start_link, [opts]}} =
               child_spec

      assert {:ok, :infinity} === Keyword.fetch(opts, :timeout)
      assert {:ok, @svc_opt_service_name} === Keyword.fetch(opts, :service_name)
      assert {:ok, datastore_context_name} = Keyword.fetch(opts, :datastore_context_name)
      assert @svc_opt_datastore_context_name === datastore_context_name

      assert {:ok, pid} =
               DynamicSupervisor.start_child(
                 :"MscmpSystSettings.TestSupportDynSupervisor",
                 child_spec
               )

      assert is_pid(pid)
    end

    test "Step 01.02 - Validate Settings Runtime Config" do
      assert nil === MscmpSystSettings.put_service(@svc_opt_service_name)
      assert @svc_opt_service_name === MscmpSystSettings.get_service()

      assert %{datastore_context_name: datastore_context_name, settings_table: settings_table} =
               MscmpSystSettings.get_runtime_config()

      assert is_reference(settings_table)
      assert @svc_opt_datastore_context_name === datastore_context_name

      assert @svc_opt_service_name === MscmpSystSettings.put_service(nil)
    end
  end

  describe "Phase 02 - Creating Settings" do
    test "Step 02.01 - Create New Simple Settings" do
      assert nil === MscmpSystSettings.put_service(@svc_opt_service_name)

      assert :ok === MscmpSystSettings.create(@tst_data_simple_setting)

      assert @svc_opt_service_name === MscmpSystSettings.put_service(nil)
    end

    test "Step 02.02 - Create Complex/Full Settings" do
      assert nil === MscmpSystSettings.put_service(@svc_opt_service_name)

      assert :ok === MscmpSystSettings.create(@tst_data_complex_setting)

      assert @svc_opt_service_name === MscmpSystSettings.put_service(nil)
    end
  end

  describe "Phase 03 - Using Settings" do
    test "Step 03.01 - Retrieve Simple Settings / Single Value" do
      assert nil === MscmpSystSettings.put_service(@svc_opt_service_name)

      assert %Msdata.SystSettings{} =
               setting =
               MscmpSystSettings.get_values("simple_test_setting")

      assert "Simple Test Setting" === setting.display_name
      assert "A basic test setting with minimal fields" === setting.user_description

      assert @svc_opt_service_name === MscmpSystSettings.put_service(nil)
    end

    test "Step 03.02 - Update Simple Settings / Single Value" do
      assert nil === MscmpSystSettings.put_service(@svc_opt_service_name)

      assert :ok ===
               MscmpSystSettings.set_value(
                 "simple_test_setting",
                 :setting_integer,
                 999
               )

      assert 999 === MscmpSystSettings.get_value("simple_test_setting", :setting_integer)

      assert @svc_opt_service_name === MscmpSystSettings.put_service(nil)
    end

    test "Step 03.03 - Retrieve Complex Settings / All Values" do
      assert nil === MscmpSystSettings.put_service(@svc_opt_service_name)

      assert %Msdata.SystSettings{} =
               all_values =
               MscmpSystSettings.get_values("complex_test_setting")

      assert "complex_test_setting" === all_values.internal_name
      assert "Complex Test Setting" === all_values.display_name
      assert "A test setting with all value types populated" === all_values.user_description
      assert "test string value" === all_values.setting_text
      assert 12_345 === all_values.setting_integer
      assert Decimal.new("123.45") === all_values.setting_decimal
      assert true === all_values.setting_flag
      assert ~D[2023-01-01] === all_values.setting_date

      # Use semantic equality for date ranges
      assert MscmpSystDb.DbTypes.test_compare(
               %DateRange{
                 lower: ~D[2023-01-01],
                 upper: ~D[2023-12-31],
                 lower_inclusive: true,
                 upper_inclusive: true
               },
               all_values.setting_date_range,
               :eq
             )

      assert %DecimalRange{
               lower: Decimal.new("0.00"),
               upper: Decimal.new("999.99"),
               lower_inclusive: true,
               upper_inclusive: false
             } === all_values.setting_decimal_range

      assert @svc_opt_service_name === MscmpSystSettings.put_service(nil)
    end

    test "Step 03.04 - Retrieve Complex Settings / Individual Values" do
      assert nil === MscmpSystSettings.put_service(@svc_opt_service_name)

      assert "test string value" ===
               MscmpSystSettings.get_value("complex_test_setting", :setting_text)

      assert 12_345 === MscmpSystSettings.get_value("complex_test_setting", :setting_integer)

      assert Decimal.new("123.45") ===
               MscmpSystSettings.get_value("complex_test_setting", :setting_decimal)

      assert true === MscmpSystSettings.get_value("complex_test_setting", :setting_flag)

      assert ~D[2023-01-01] ===
               MscmpSystSettings.get_value("complex_test_setting", :setting_date)

      assert @svc_opt_service_name === MscmpSystSettings.put_service(nil)
    end

    test "Step 03.05 - Update Complex Settings / Single Value" do
      assert nil === MscmpSystSettings.put_service(@svc_opt_service_name)

      assert :ok ===
               MscmpSystSettings.set_value(
                 "complex_test_setting",
                 :setting_decimal,
                 Decimal.new("999.99")
               )

      assert Decimal.new("999.99") ===
               MscmpSystSettings.get_value("complex_test_setting", :setting_decimal)

      assert @svc_opt_service_name === MscmpSystSettings.put_service(nil)
    end

    test "Step 03.06 - Update Complex Settings / Multiple Values" do
      assert nil === MscmpSystSettings.put_service(@svc_opt_service_name)

      update_params = %{
        user_description: "Updated description for complex setting",
        setting_integer: 54_321,
        setting_flag: false,
        setting_date: ~D[2024-06-15],
        setting_date_range: %DateRange{
          lower: ~D[2024-01-01],
          upper: ~D[2024-12-31],
          lower_inclusive: false,
          upper_inclusive: false
        }
      }

      assert :ok === MscmpSystSettings.set_values("complex_test_setting", update_params)

      # Verify the updates using get_values for complete struct
      assert %Msdata.SystSettings{} =
               updated =
               MscmpSystSettings.get_values("complex_test_setting")

      assert "Updated description for complex setting" === updated.user_description
      assert 54_321 === updated.setting_integer
      assert false === updated.setting_flag
      assert ~D[2024-06-15] === updated.setting_date

      # Use semantic equality for date ranges
      assert MscmpSystDb.DbTypes.test_compare(
               %DateRange{
                 lower: ~D[2024-01-01],
                 upper: ~D[2024-12-31],
                 lower_inclusive: false,
                 upper_inclusive: false
               },
               updated.setting_date_range,
               :eq
             )

      assert @svc_opt_service_name === MscmpSystSettings.put_service(nil)
    end
  end

  describe "Phase 04 - Deleteing Settings" do
    test "Step 04.01 - Delete Simple Setting" do
      assert nil === MscmpSystSettings.put_service(@svc_opt_service_name)

      # Verify setting exists before deletion
      assert %Msdata.SystSettings{display_name: "Simple Test Setting"} =
               MscmpSystSettings.get_values("simple_test_setting")

      # Delete the setting
      assert :ok === MscmpSystSettings.delete("simple_test_setting")

      # Verify setting is no longer in the list
      all_settings = MscmpSystSettings.list_all()
      refute Enum.any?(all_settings, fn s -> s.internal_name === "simple_test_setting" end)

      assert @svc_opt_service_name === MscmpSystSettings.put_service(nil)
    end

    test "Step 04.02 - Delete Complex Setting" do
      assert nil === MscmpSystSettings.put_service(@svc_opt_service_name)

      # Verify setting exists before deletion
      assert %Msdata.SystSettings{display_name: "Complex Test Setting"} =
               MscmpSystSettings.get_values("complex_test_setting")

      # Delete the setting
      assert :ok === MscmpSystSettings.delete("complex_test_setting")

      # Verify setting is no longer in the list
      all_settings = MscmpSystSettings.list_all()
      refute Enum.any?(all_settings, fn s -> s.internal_name === "complex_test_setting" end)

      assert @svc_opt_service_name === MscmpSystSettings.put_service(nil)
    end
  end

  describe "Phase 05 - System Settings" do
    test "Step 05.01 - Attempt to Delete System Setting" do
      assert nil === MscmpSystSettings.put_service(@svc_opt_service_name)

      # Verify the system setting exists
      assert %Msdata.SystSettings{display_name: "Delete Test Setting"} =
               MscmpSystSettings.get_values("delete_test_setting")

      # Attempt to delete should fail for system-defined settings
      assert {:error, %Mserror.SettingsError{}} =
               MscmpSystSettings.delete("delete_test_setting")

      # Verify the setting still exists
      assert %Msdata.SystSettings{display_name: "Delete Test Setting"} =
               MscmpSystSettings.get_values("delete_test_setting")

      assert @svc_opt_service_name === MscmpSystSettings.put_service(nil)
    end
  end

  describe "Phase 06 - Service Shutdown" do
    test "Step 06.01 - Shutdown Settings Service" do
      assert nil === MscmpSystSettings.put_service(@svc_opt_service_name)

      pid = Process.whereis(@svc_opt_service_name)
      assert is_pid(pid)

      # Gracefully terminate the service
      assert :ok === MscmpSystSettings.terminate_service()

      # Verify the process is no longer alive
      refute Process.alive?(pid)

      assert @svc_opt_service_name === MscmpSystSettings.put_service(nil)
    end
  end
end
