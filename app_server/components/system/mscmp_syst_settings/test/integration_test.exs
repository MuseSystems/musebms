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

  use SettingsTestCase, async: false

  alias MscmpSystDb.DbTypes.DateRange
  alias MscmpSystDb.DbTypes.DecimalRange

  @moduletag :integration
  @moduletag :capture_log

  # Note that with some record length tests that we have to +1 in our tests as
  # the test data from a migration includes a system-defined setting that is
  # used for testing delete functionality.

  # Create initial test settings that will be used throughout the test suite
  test "create initial test settings" do
    # Create a basic setting with just required fields
    basic_setting = %{
      internal_name: "basic_test_setting",
      display_name: "Basic Test Setting",
      user_description: "A basic test setting with minimal fields"
    }

    assert :ok = MscmpSystSettings.create(basic_setting)

    # Create a setting with all value types populated
    full_setting = %{
      internal_name: "full_test_setting",
      display_name: "Full Test Setting",
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

    assert :ok = MscmpSystSettings.create(full_setting)
  end

  test "retrieve setting values" do
    # Test get_value for individual fields
    assert "test string value" = MscmpSystSettings.get_value("full_test_setting", :setting_text)
    assert 12_345 = MscmpSystSettings.get_value("full_test_setting", :setting_integer)

    assert Decimal.new("123.45") ==
             MscmpSystSettings.get_value("full_test_setting", :setting_decimal)

    assert true = MscmpSystSettings.get_value("full_test_setting", :setting_flag)

    # Test get_values to retrieve all values for a setting
    full_values = MscmpSystSettings.get_values("full_test_setting")
    assert "Full Test Setting" = full_values.display_name
    assert ~D[2023-01-01] = full_values.setting_date

    # Test list_all to get all settings
    all_settings = MscmpSystSettings.list_all()
    assert length(all_settings) == 3
  end

  test "update setting values" do
    # Test updating a single value
    assert :ok =
             MscmpSystSettings.set_value(
               "basic_test_setting",
               :setting_text,
               "new string value"
             )

    assert "new string value" = MscmpSystSettings.get_value("basic_test_setting", :setting_text)

    # Test updating multiple values at once
    updates = %{
      display_name: "Updated Full Setting",
      setting_integer: 54_321,
      setting_decimal: Decimal.new("543.21")
    }

    assert :ok = MscmpSystSettings.set_values("full_test_setting", updates)

    updated_values = MscmpSystSettings.get_values("full_test_setting")
    assert "Updated Full Setting" = updated_values.display_name
    assert 54_321 = updated_values.setting_integer
    assert Decimal.new("543.21") == updated_values.setting_decimal
  end

  test "delete user-defined setting" do
    # Delete the basic test setting
    assert :ok = MscmpSystSettings.delete("basic_test_setting")

    # Verify it was deleted by checking all settings
    remaining_settings = MscmpSystSettings.list_all()
    assert length(remaining_settings) == 2
    remaining_names = Enum.map(remaining_settings, & &1.internal_name) |> Enum.sort()
    assert remaining_names == ["delete_test_setting", "full_test_setting"]
  end

  test "error cases" do
    # Test create with invalid params
    invalid_params = %{
      internal_name: "invalid_setting",
      display_name: "Invalid Setting"
      # Missing required user_description
    }

    assert {:error, %Mserror.SettingsError{}} = MscmpSystSettings.create(invalid_params)

    # Test set_value on non-existent setting
    assert {:error, %Mserror.SettingsError{}} =
             MscmpSystSettings.set_value(
               "nonexistent_setting",
               :setting_text,
               "some value"
             )

    # Test set_values on non-existent setting
    assert {:error, %Mserror.SettingsError{}} =
             MscmpSystSettings.set_values(
               "nonexistent_setting",
               %{setting_text: "some value"}
             )

    # Test delete on non-existent setting
    assert {:error, %Mserror.SettingsError{}} = MscmpSystSettings.delete("nonexistent_setting")

    # Test delete on system-defined setting (full_test_setting is system-defined)
    assert {:error, %Mserror.SettingsError{}} = MscmpSystSettings.delete("delete_test_setting")
  end
end
