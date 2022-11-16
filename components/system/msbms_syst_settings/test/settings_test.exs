# Source File: settings_test.exs
# Location:    musebms/components/system/msbms_syst_settings/test/settings_test.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule SettingsTest do
  use SettingsTestCase, async: true

  test "Create/Delete User Defined Settings" do
    success_setting = %{
      internal_name: "test_success_setting",
      display_name: "Test Success Setting",
      user_description: "An example of setting creation.",
      setting_integer: 9876
    }

    short_desc_setting = %{
      internal_name: "test_short_desc_setting",
      display_name: "Test Short Create Setting",
      user_description: "Short",
      setting_integer: 9876
    }

    long_desc_setting = %{
      internal_name: "test_long_desc_setting",
      display_name: "Test Long Create Setting",
      user_description: """
      Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc volutpat, sapien eu commodo
      varius, mauris neque sollicitudin ligula, ut volutpat elit elit quis eros. Vivamus gravida
      porta sollicitudin. Mauris nec facilisis nulla, id posuere justo. Cras vitae orci facilisis,
      ullamcorper tellus vitae, egestas metus. Sed volutpat ultrices lectus in mattis. Sed non
      lacus urna. In eleifend nulla eget mauris ultrices bibendum. Nunc sit amet ullamcorper urna.
      Mauris vehicula justo tortor, id faucibus lacus suscipit nec. Sed consectetur lacinia
      tincidunt. Integer sollicitudin ac justo nec laoreet. Mauris vulputate vestibulum risus, vel
      commodo nisi mattis sed. Aenean ac erat id orci luctus ullamcorper eu vel mi.

      Vestibulum euismod quis massa eu cursus. Cras pulvinar vitae velit scelerisque vestibulum.
      Cras in facilisis felis. Praesent enim ante, scelerisque id malesuada hendrerit, aliquam nec
      libero. Donec in risus libero. Cras tempor Cras tempor odio id volutpat volutpat. Duis
      sodales sapien-
      """,
      setting_integer: 9876
    }

    long_internal_name_setting = %{
      internal_name: "this_must_be_a_completely_out_of_all_question_too_long_of_a_name!",
      display_name: "Test Long Internal Name Setting",
      user_description: "A very long internal name.",
      setting_integer: 9876
    }

    short_internal_name_setting = %{
      internal_name: "short",
      display_name: "Test Short Internal Name Setting",
      user_description: "A rather short internal name.",
      setting_integer: 9876
    }

    long_display_name_setting = %{
      internal_name: "long_display_name_setting",
      display_name: "This must be a completely out of all question too long of a name!",
      user_description: "A very long display name",
      setting_integer: 9876
    }

    short_display_name_setting = %{
      internal_name: "short_display_name_setting",
      display_name: "Short",
      user_description: "A rather short display name.",
      setting_integer: 9876
    }

    assert :ok = MsbmsSystSettings.create_setting(success_setting)

    assert %MsbmsSystSettings.Data.SystSettings{internal_name: "test_success_setting"} =
             :ets.lookup_element(:settings_instance, "test_success_setting", 2)

    assert {:error, %MscmpSystError{}} = MsbmsSystSettings.create_setting(success_setting)

    assert :ok = MsbmsSystSettings.delete_setting(success_setting.internal_name)

    assert catch_error(:ets.lookup_element(:settings_instance, "test_success_setting", 2))

    assert {:error, %MscmpSystError{}} = MsbmsSystSettings.create_setting(short_desc_setting)

    assert {:error, %MscmpSystError{}} = MsbmsSystSettings.create_setting(long_desc_setting)

    assert {:error, %MscmpSystError{}} = MsbmsSystSettings.delete_setting("test_setting_one")

    assert {:error, %MscmpSystError{}} =
             MsbmsSystSettings.create_setting(short_internal_name_setting)

    assert {:error, %MscmpSystError{}} =
             MsbmsSystSettings.create_setting(long_internal_name_setting)

    assert {:error, %MscmpSystError{}} =
             MsbmsSystSettings.create_setting(short_display_name_setting)

    assert {:error, %MscmpSystError{}} =
             MsbmsSystSettings.create_setting(long_display_name_setting)
  end

  test "Set/Get display_name Setting" do
    good_change = %{display_name: "Updated Test Setting One"}

    long_change = %{
      display_name: "This must be a completely out of all question too long of a name!"
    }

    short_change = %{display_name: "Short"}

    assert %MsbmsSystSettings.Data.SystSettings{display_name: "Test Setting One"} =
             MsbmsSystSettings.get_setting_values("test_setting_one")

    assert :ok =
             MsbmsSystSettings.set_setting_values(
               "test_setting_one",
               good_change
             )

    assert %MsbmsSystSettings.Data.SystSettings{display_name: "Updated Test Setting One"} =
             MsbmsSystSettings.get_setting_values("test_setting_one")

    assert {:error, %MscmpSystError{}} =
             MsbmsSystSettings.set_setting_values(
               "test_setting_one",
               long_change
             )

    assert {:error, %MscmpSystError{}} =
             MsbmsSystSettings.set_setting_values(
               "test_setting_one",
               short_change
             )
  end

  test "Set/Get user_description Setting" do
    good_change = %{user_description: "Updated test one setting description."}

    nil_change = %{user_description: nil}

    long_change = %{
      user_description: """
      Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc volutpat, sapien eu commodo
      varius, mauris neque sollicitudin ligula, ut volutpat elit elit quis eros. Vivamus gravida
      porta sollicitudin. Mauris nec facilisis nulla, id posuere justo. Cras vitae orci facilisis,
      ullamcorper tellus vitae, egestas metus. Sed volutpat ultrices lectus in mattis. Sed non
      lacus urna. In eleifend nulla eget mauris ultrices bibendum. Nunc sit amet ullamcorper urna.
      Mauris vehicula justo tortor, id faucibus lacus suscipit nec. Sed consectetur lacinia
      tincidunt. Integer sollicitudin ac justo nec laoreet. Mauris vulputate vestibulum risus, vel
      commodo nisi mattis sed. Aenean ac erat id orci luctus ullamcorper eu vel mi.

      Vestibulum euismod quis massa eu cursus. Cras pulvinar vitae velit scelerisque vestibulum.
      Cras in facilisis felis. Praesent enim ante, scelerisque id malesuada hendrerit, aliquam nec
      libero. Donec in risus libero. Cras tempor Cras tempor odio id volutpat volutpat. Duis
      sodales sapien-
      """
    }

    short_change = %{user_description: "Short"}

    assert %MsbmsSystSettings.Data.SystSettings{
             user_description: "Test Setting One User Description"
           } = MsbmsSystSettings.get_setting_values("test_setting_one")

    assert :ok =
             MsbmsSystSettings.set_setting_values(
               "test_setting_one",
               good_change
             )

    assert %MsbmsSystSettings.Data.SystSettings{
             user_description: "Updated test one setting description."
           } = MsbmsSystSettings.get_setting_values("test_setting_one")

    assert :ok =
             MsbmsSystSettings.set_setting_values(
               "test_setting_one",
               nil_change
             )

    assert %MsbmsSystSettings.Data.SystSettings{
             user_description: nil
           } = MsbmsSystSettings.get_setting_values("test_setting_one")

    assert {:error, %MscmpSystError{}} =
             MsbmsSystSettings.set_setting_values(
               "test_setting_one",
               long_change
             )

    assert {:error, %MscmpSystError{}} =
             MsbmsSystSettings.set_setting_values(
               "test_setting_one",
               short_change
             )
  end

  test "Set/Get setting_flag Setting" do
    true_change = %{setting_flag: true}
    false_change = %{setting_flag: false}
    nil_change = %{setting_flag: nil}

    assert %MsbmsSystSettings.Data.SystSettings{setting_flag: true} =
             MsbmsSystSettings.get_setting_values("test_setting_one")

    assert true =
             MsbmsSystSettings.get_setting_value(
               "test_setting_one",
               :setting_flag
             )

    assert :ok =
             MsbmsSystSettings.set_setting_values(
               "test_setting_one",
               false_change
             )

    assert false ==
             MsbmsSystSettings.get_setting_value(
               "test_setting_one",
               :setting_flag
             )

    assert :ok =
             MsbmsSystSettings.set_setting_value(
               "test_setting_one",
               :setting_flag,
               true_change.setting_flag
             )

    assert true ==
             MsbmsSystSettings.get_setting_value(
               "test_setting_one",
               :setting_flag
             )

    assert :ok =
             MsbmsSystSettings.set_setting_value(
               "test_setting_one",
               :setting_flag,
               nil_change.setting_flag
             )

    assert nil ==
             MsbmsSystSettings.get_setting_value(
               "test_setting_one",
               :setting_flag
             )
  end

  test "Set/Get setting_integer Setting" do
    first_change = %{setting_integer: 1111}
    second_change = %{setting_integer: 2222}
    nil_change = %{setting_integer: nil}

    assert %MsbmsSystSettings.Data.SystSettings{setting_integer: 111} =
             MsbmsSystSettings.get_setting_values("test_setting_one")

    assert 111 =
             MsbmsSystSettings.get_setting_value(
               "test_setting_one",
               :setting_integer
             )

    assert :ok =
             MsbmsSystSettings.set_setting_values(
               "test_setting_one",
               second_change
             )

    assert second_change.setting_integer ==
             MsbmsSystSettings.get_setting_value(
               "test_setting_one",
               :setting_integer
             )

    assert :ok =
             MsbmsSystSettings.set_setting_value(
               "test_setting_one",
               :setting_integer,
               first_change.setting_integer
             )

    assert first_change.setting_integer ==
             MsbmsSystSettings.get_setting_value(
               "test_setting_one",
               :setting_integer
             )

    assert :ok =
             MsbmsSystSettings.set_setting_value(
               "test_setting_one",
               :setting_integer,
               nil_change.setting_integer
             )

    assert nil ==
             MsbmsSystSettings.get_setting_value(
               "test_setting_one",
               :setting_integer
             )
  end

  test "Set/Get setting_integer_range Setting" do
    # TODO: Note that the range types seem to munge around ranges not already set to be '[)' to be
    # '[)' via changing values if needed.  I guess this is OK for now, but may be worth revisiting.
    first_change = %{
      setting_integer_range: %MsbmsSystDatastore.DbTypes.IntegerRange{
        lower: 111,
        upper: 11_111,
        lower_inclusive: true,
        upper_inclusive: true
      }
    }

    second_change = %{
      setting_integer_range: %MsbmsSystDatastore.DbTypes.IntegerRange{
        lower: 222,
        upper: 22_222,
        lower_inclusive: false,
        upper_inclusive: true
      }
    }

    nil_change = %{setting_integer_range: nil}

    assert %MsbmsSystSettings.Data.SystSettings{
             setting_integer_range: %MsbmsSystDatastore.DbTypes.IntegerRange{
               lower: 1,
               upper: 11,
               lower_inclusive: true,
               upper_inclusive: false
             }
           } = MsbmsSystSettings.get_setting_values("test_setting_one")

    assert %MsbmsSystDatastore.DbTypes.IntegerRange{
             lower: 1,
             upper: 11,
             lower_inclusive: true,
             upper_inclusive: false
           } =
             MsbmsSystSettings.get_setting_value(
               "test_setting_one",
               :setting_integer_range
             )

    assert :ok =
             MsbmsSystSettings.set_setting_values(
               "test_setting_one",
               second_change
             )

    assert %MsbmsSystDatastore.DbTypes.IntegerRange{
             lower: 223,
             lower_inclusive: true,
             upper: 22_223,
             upper_inclusive: false
           } ==
             MsbmsSystSettings.get_setting_value(
               "test_setting_one",
               :setting_integer_range
             )

    assert :ok =
             MsbmsSystSettings.set_setting_value(
               "test_setting_one",
               :setting_integer_range,
               first_change.setting_integer_range
             )

    assert %MsbmsSystDatastore.DbTypes.IntegerRange{
             lower: 111,
             lower_inclusive: true,
             upper: 11_112,
             upper_inclusive: false
           } ==
             MsbmsSystSettings.get_setting_value(
               "test_setting_one",
               :setting_integer_range
             )

    assert :ok =
             MsbmsSystSettings.set_setting_value(
               "test_setting_one",
               :setting_integer_range,
               nil_change.setting_integer_range
             )

    assert nil ==
             MsbmsSystSettings.get_setting_value(
               "test_setting_one",
               :setting_integer_range
             )
  end

  test "Set/Get setting_decimal Setting" do
    first_change = %{setting_decimal: Decimal.new("1111.11")}
    second_change = %{setting_decimal: Decimal.new("2222.22")}
    nil_change = %{setting_decimal: nil}

    assert %MsbmsSystSettings.Data.SystSettings{setting_decimal: start_value} =
             MsbmsSystSettings.get_setting_values("test_setting_one")

    assert Decimal.eq?(Decimal.new("111.111"), start_value)

    assert Decimal.eq?(
             Decimal.new("111.111"),
             MsbmsSystSettings.get_setting_value(
               "test_setting_one",
               :setting_decimal
             )
           )

    assert :ok =
             MsbmsSystSettings.set_setting_values(
               "test_setting_one",
               second_change
             )

    assert Decimal.eq?(
             second_change.setting_decimal,
             MsbmsSystSettings.get_setting_value(
               "test_setting_one",
               :setting_decimal
             )
           )

    assert :ok =
             MsbmsSystSettings.set_setting_value(
               "test_setting_one",
               :setting_decimal,
               first_change.setting_decimal
             )

    assert Decimal.eq?(
             first_change.setting_decimal,
             MsbmsSystSettings.get_setting_value(
               "test_setting_one",
               :setting_decimal
             )
           )

    assert :ok =
             MsbmsSystSettings.set_setting_value(
               "test_setting_one",
               :setting_decimal,
               nil_change.setting_decimal
             )

    assert nil ==
             MsbmsSystSettings.get_setting_value(
               "test_setting_one",
               :setting_decimal
             )
  end

  test "Set/Get setting_decimal_range Setting" do
    # TODO: Note that the range types seem to munge around ranges not already set to be '[)' to be
    # '[)' via changing values if needed.  I guess this is OK for now, but may be worth revisiting.
    first_change = %{
      setting_decimal_range: %MsbmsSystDatastore.DbTypes.DecimalRange{
        lower: Decimal.new("111.999"),
        upper: Decimal.new("11111.999"),
        lower_inclusive: true,
        upper_inclusive: true
      }
    }

    second_change = %{
      setting_decimal_range: %MsbmsSystDatastore.DbTypes.DecimalRange{
        lower: Decimal.new("222.999"),
        upper: Decimal.new("22222.999"),
        lower_inclusive: false,
        upper_inclusive: true
      }
    }

    nil_change = %{setting_decimal_range: nil}

    starting_value = %MsbmsSystDatastore.DbTypes.DecimalRange{
      lower: Decimal.new("1.1"),
      upper: Decimal.new("11.11"),
      lower_inclusive: true,
      upper_inclusive: false
    }

    assert %MsbmsSystSettings.Data.SystSettings{setting_decimal_range: ^starting_value} =
             MsbmsSystSettings.get_setting_values("test_setting_one")

    assert ^starting_value =
             MsbmsSystSettings.get_setting_value(
               "test_setting_one",
               :setting_decimal_range
             )

    assert :ok =
             MsbmsSystSettings.set_setting_values(
               "test_setting_one",
               second_change
             )

    second_change_comparison = second_change.setting_decimal_range

    assert ^second_change_comparison =
             MsbmsSystSettings.get_setting_value(
               "test_setting_one",
               :setting_decimal_range
             )

    assert :ok =
             MsbmsSystSettings.set_setting_value(
               "test_setting_one",
               :setting_decimal_range,
               first_change.setting_decimal_range
             )

    first_change_comparison = first_change.setting_decimal_range

    assert ^first_change_comparison =
             MsbmsSystSettings.get_setting_value(
               "test_setting_one",
               :setting_decimal_range
             )

    assert :ok =
             MsbmsSystSettings.set_setting_value(
               "test_setting_one",
               :setting_decimal_range,
               nil_change.setting_decimal_range
             )

    assert nil ==
             MsbmsSystSettings.get_setting_value(
               "test_setting_one",
               :setting_decimal_range
             )
  end

  test "Set/Get setting_interval Setting" do
    first_change = %{
      setting_interval: %MsbmsSystDatastore.DbTypes.Interval{
        months: 1,
        days: 1,
        secs: 1,
        microsecs: 1
      }
    }

    second_change = %{
      setting_interval: %MsbmsSystDatastore.DbTypes.Interval{
        months: 2,
        days: 2,
        secs: 2,
        microsecs: 2
      }
    }

    nil_change = %{setting_interval: nil}

    assert %MsbmsSystSettings.Data.SystSettings{
             setting_interval: %MsbmsSystDatastore.DbTypes.Interval{
               months: 1,
               days: 0,
               secs: 0,
               microsecs: 0
             }
           } = MsbmsSystSettings.get_setting_values("test_setting_one")

    assert %MsbmsSystDatastore.DbTypes.Interval{
             months: 1,
             days: 0,
             secs: 0,
             microsecs: 0
           } =
             MsbmsSystSettings.get_setting_value(
               "test_setting_one",
               :setting_interval
             )

    assert :ok =
             MsbmsSystSettings.set_setting_values(
               "test_setting_one",
               second_change
             )

    second_change_comparison = second_change.setting_interval

    assert ^second_change_comparison =
             MsbmsSystSettings.get_setting_value(
               "test_setting_one",
               :setting_interval
             )

    assert :ok =
             MsbmsSystSettings.set_setting_value(
               "test_setting_one",
               :setting_interval,
               first_change.setting_interval
             )

    first_change_comparison = first_change.setting_interval

    assert ^first_change_comparison =
             MsbmsSystSettings.get_setting_value(
               "test_setting_one",
               :setting_interval
             )

    assert :ok =
             MsbmsSystSettings.set_setting_value(
               "test_setting_one",
               :setting_interval,
               nil_change.setting_interval
             )

    assert nil ==
             MsbmsSystSettings.get_setting_value(
               "test_setting_one",
               :setting_interval
             )
  end

  test "Set/Get setting_date Setting" do
    first_change = %{setting_date: ~D[2022-04-12]}
    second_change = %{setting_date: ~D[2022-04-13]}
    nil_change = %{setting_date: nil}

    assert %MsbmsSystSettings.Data.SystSettings{setting_date: ~D[2022-01-01]} =
             MsbmsSystSettings.get_setting_values("test_setting_one")

    assert ~D[2022-01-01] =
             MsbmsSystSettings.get_setting_value(
               "test_setting_one",
               :setting_date
             )

    assert :ok =
             MsbmsSystSettings.set_setting_values(
               "test_setting_one",
               second_change
             )

    assert second_change.setting_date ==
             MsbmsSystSettings.get_setting_value(
               "test_setting_one",
               :setting_date
             )

    assert :ok =
             MsbmsSystSettings.set_setting_value(
               "test_setting_one",
               :setting_date,
               first_change.setting_date
             )

    assert first_change.setting_date ==
             MsbmsSystSettings.get_setting_value(
               "test_setting_one",
               :setting_date
             )

    assert :ok =
             MsbmsSystSettings.set_setting_value(
               "test_setting_one",
               :setting_date,
               nil_change.setting_date
             )

    assert nil ==
             MsbmsSystSettings.get_setting_value(
               "test_setting_one",
               :setting_date
             )
  end

  test "Set/Get setting_date_range Setting" do
    first_change = %{
      setting_date_range: %MsbmsSystDatastore.DbTypes.DateRange{
        lower: ~D[2022-04-13],
        upper: ~D[2022-04-14],
        lower_inclusive: true,
        upper_inclusive: true
      }
    }

    second_change = %{
      setting_date_range: %MsbmsSystDatastore.DbTypes.DateRange{
        lower: ~D[2022-04-12],
        upper: ~D[2022-04-15],
        lower_inclusive: false,
        upper_inclusive: true
      }
    }

    nil_change = %{setting_date_range: nil}

    assert %MsbmsSystSettings.Data.SystSettings{
             setting_date_range: %MsbmsSystDatastore.DbTypes.DateRange{
               lower: ~D[2022-01-01],
               upper: ~D[2023-01-01],
               lower_inclusive: true,
               upper_inclusive: false
             }
           } = MsbmsSystSettings.get_setting_values("test_setting_one")

    assert %MsbmsSystDatastore.DbTypes.DateRange{
             lower: ~D[2022-01-01],
             upper: ~D[2023-01-01],
             lower_inclusive: true,
             upper_inclusive: false
           } =
             MsbmsSystSettings.get_setting_value(
               "test_setting_one",
               :setting_date_range
             )

    assert :ok =
             MsbmsSystSettings.set_setting_values(
               "test_setting_one",
               second_change
             )

    second_change_comparison = %MsbmsSystDatastore.DbTypes.DateRange{
      lower: ~D[2022-04-13],
      upper: ~D[2022-04-16],
      lower_inclusive: true,
      upper_inclusive: false
    }

    assert ^second_change_comparison =
             MsbmsSystSettings.get_setting_value(
               "test_setting_one",
               :setting_date_range
             )

    assert :ok =
             MsbmsSystSettings.set_setting_value(
               "test_setting_one",
               :setting_date_range,
               first_change.setting_date_range
             )

    first_change_comparison = %MsbmsSystDatastore.DbTypes.DateRange{
      lower: ~D[2022-04-13],
      upper: ~D[2022-04-15],
      lower_inclusive: true,
      upper_inclusive: false
    }

    assert ^first_change_comparison =
             MsbmsSystSettings.get_setting_value(
               "test_setting_one",
               :setting_date_range
             )

    assert :ok =
             MsbmsSystSettings.set_setting_value(
               "test_setting_one",
               :setting_date_range,
               nil_change.setting_date_range
             )

    assert nil ==
             MsbmsSystSettings.get_setting_value(
               "test_setting_one",
               :setting_date_range
             )
  end

  test "Set/Get setting_time Setting" do
    first_change = %{setting_time: ~T[13:00:00]}
    second_change = %{setting_time: ~T[14:00:00]}
    nil_change = %{setting_time: nil}

    assert %MsbmsSystSettings.Data.SystSettings{setting_time: ~T[01:00:00]} =
             MsbmsSystSettings.get_setting_values("test_setting_one")

    assert ~T[01:00:00] =
             MsbmsSystSettings.get_setting_value(
               "test_setting_one",
               :setting_time
             )

    assert :ok =
             MsbmsSystSettings.set_setting_values(
               "test_setting_one",
               second_change
             )

    assert second_change.setting_time ==
             MsbmsSystSettings.get_setting_value(
               "test_setting_one",
               :setting_time
             )

    assert :ok =
             MsbmsSystSettings.set_setting_value(
               "test_setting_one",
               :setting_time,
               first_change.setting_time
             )

    assert first_change.setting_time ==
             MsbmsSystSettings.get_setting_value(
               "test_setting_one",
               :setting_time
             )

    assert :ok =
             MsbmsSystSettings.set_setting_value(
               "test_setting_one",
               :setting_time,
               nil_change.setting_time
             )

    assert nil ==
             MsbmsSystSettings.get_setting_value(
               "test_setting_one",
               :setting_time
             )
  end

  test "Set/Get setting_timestamp Setting" do
    first_change = %{setting_timestamp: ~U[2022-04-12 13:00:00Z]}
    second_change = %{setting_timestamp: ~U[2022-04-13 14:00:00Z]}
    nil_change = %{setting_timestamp: nil}

    assert %MsbmsSystSettings.Data.SystSettings{setting_timestamp: ~U[2022-01-01 01:00:00Z]} =
             MsbmsSystSettings.get_setting_values("test_setting_one")

    assert ~U[2022-01-01 01:00:00Z] =
             MsbmsSystSettings.get_setting_value(
               "test_setting_one",
               :setting_timestamp
             )

    assert :ok =
             MsbmsSystSettings.set_setting_values(
               "test_setting_one",
               second_change
             )

    assert second_change.setting_timestamp ==
             MsbmsSystSettings.get_setting_value(
               "test_setting_one",
               :setting_timestamp
             )

    assert :ok =
             MsbmsSystSettings.set_setting_value(
               "test_setting_one",
               :setting_timestamp,
               first_change.setting_timestamp
             )

    assert first_change.setting_timestamp ==
             MsbmsSystSettings.get_setting_value(
               "test_setting_one",
               :setting_timestamp
             )

    assert :ok =
             MsbmsSystSettings.set_setting_value(
               "test_setting_one",
               :setting_timestamp,
               nil_change.setting_timestamp
             )

    assert nil ==
             MsbmsSystSettings.get_setting_value(
               "test_setting_one",
               :setting_timestamp
             )
  end

  test "Set/Get setting_timestamp_range Setting" do
    first_change = %{
      setting_timestamp_range: %MsbmsSystDatastore.DbTypes.DateTimeRange{
        lower: ~U[2022-04-13 01:00:00.000000Z],
        upper: ~U[2022-04-14 23:00:00.000000Z],
        lower_inclusive: true,
        upper_inclusive: true
      }
    }

    second_change = %{
      setting_timestamp_range: %MsbmsSystDatastore.DbTypes.DateTimeRange{
        lower: ~U[2022-04-12 01:30:00.000000Z],
        upper: ~U[2022-04-15 23:30:00.000000Z],
        lower_inclusive: false,
        upper_inclusive: true
      }
    }

    nil_change = %{setting_timestamp_range: nil}

    assert %MsbmsSystSettings.Data.SystSettings{
             setting_timestamp_range: %MsbmsSystDatastore.DbTypes.DateTimeRange{
               lower: ~U[2022-01-01 01:00:00.000000Z],
               upper: :inf,
               lower_inclusive: true,
               upper_inclusive: false
             }
           } = MsbmsSystSettings.get_setting_values("test_setting_one")

    assert %MsbmsSystDatastore.DbTypes.DateTimeRange{
             lower: ~U[2022-01-01 01:00:00.000000Z],
             upper: :inf,
             lower_inclusive: true,
             upper_inclusive: false
           } =
             MsbmsSystSettings.get_setting_value(
               "test_setting_one",
               :setting_timestamp_range
             )

    assert :ok =
             MsbmsSystSettings.set_setting_values(
               "test_setting_one",
               second_change
             )

    second_change_comparison = second_change.setting_timestamp_range

    assert ^second_change_comparison =
             MsbmsSystSettings.get_setting_value(
               "test_setting_one",
               :setting_timestamp_range
             )

    assert :ok =
             MsbmsSystSettings.set_setting_value(
               "test_setting_one",
               :setting_timestamp_range,
               first_change.setting_timestamp_range
             )

    first_change_comparison = first_change.setting_timestamp_range

    assert ^first_change_comparison =
             MsbmsSystSettings.get_setting_value(
               "test_setting_one",
               :setting_timestamp_range
             )

    assert :ok =
             MsbmsSystSettings.set_setting_value(
               "test_setting_one",
               :setting_timestamp_range,
               nil_change.setting_timestamp_range
             )

    assert nil ==
             MsbmsSystSettings.get_setting_value(
               "test_setting_one",
               :setting_timestamp_range
             )
  end

  test "Set/Get setting_json Setting" do
    first_change = %{setting_json: %{"First Test Set" => true}}
    second_change = %{setting_json: %{"Second Test Set" => %{"and_again" => 123}}}
    nil_change = %{setting_json: nil}

    assert %MsbmsSystSettings.Data.SystSettings{
             setting_json: %{
               "test_settings_one" => %{
                 "nested_test" => "nested_test_value"
               },
               "test_settings_one_number" => 1111,
               "test_settings_one_boolean" => true
             }
           } = MsbmsSystSettings.get_setting_values("test_setting_one")

    assert %{
             "test_settings_one" => %{
               "nested_test" => "nested_test_value"
             },
             "test_settings_one_number" => 1111,
             "test_settings_one_boolean" => true
           } =
             MsbmsSystSettings.get_setting_value(
               "test_setting_one",
               :setting_json
             )

    assert :ok =
             MsbmsSystSettings.set_setting_values(
               "test_setting_one",
               second_change
             )

    assert second_change.setting_json ==
             MsbmsSystSettings.get_setting_value(
               "test_setting_one",
               :setting_json
             )

    assert :ok =
             MsbmsSystSettings.set_setting_value(
               "test_setting_one",
               :setting_json,
               first_change.setting_json
             )

    assert first_change.setting_json ==
             MsbmsSystSettings.get_setting_value(
               "test_setting_one",
               :setting_json
             )

    assert :ok =
             MsbmsSystSettings.set_setting_value(
               "test_setting_one",
               :setting_json,
               nil_change.setting_json
             )

    assert nil ==
             MsbmsSystSettings.get_setting_value(
               "test_setting_one",
               :setting_json
             )
  end

  test "Set/Get setting_text Setting" do
    first_change = %{setting_text: "First Change Test"}
    second_change = %{setting_text: "Second Change Test"}
    nil_change = %{setting_text: nil}

    assert %MsbmsSystSettings.Data.SystSettings{setting_text: "Test Setting One Text"} =
             MsbmsSystSettings.get_setting_values("test_setting_one")

    assert "Test Setting One Text" =
             MsbmsSystSettings.get_setting_value(
               "test_setting_one",
               :setting_text
             )

    assert :ok =
             MsbmsSystSettings.set_setting_values(
               "test_setting_one",
               second_change
             )

    assert second_change.setting_text ==
             MsbmsSystSettings.get_setting_value(
               "test_setting_one",
               :setting_text
             )

    assert :ok =
             MsbmsSystSettings.set_setting_value(
               "test_setting_one",
               :setting_text,
               first_change.setting_text
             )

    assert first_change.setting_text ==
             MsbmsSystSettings.get_setting_value(
               "test_setting_one",
               :setting_text
             )

    assert :ok =
             MsbmsSystSettings.set_setting_value(
               "test_setting_one",
               :setting_text,
               nil_change.setting_text
             )

    assert nil ==
             MsbmsSystSettings.get_setting_value(
               "test_setting_one",
               :setting_text
             )
  end

  test "Set/Get setting_uuid Setting" do
    first_change = %{setting_uuid: "a7047c82-2759-48ff-a722-9b09e75d6b99"}
    second_change = %{setting_uuid: "5945ef31-5819-4780-9080-e7b4fe35fe4b"}
    nil_change = %{setting_uuid: nil}

    assert %MsbmsSystSettings.Data.SystSettings{
             setting_uuid: "bbd4d590-b2c7-11ec-a45c-00155d708817"
           } = MsbmsSystSettings.get_setting_values("test_setting_one")

    assert "bbd4d590-b2c7-11ec-a45c-00155d708817" =
             MsbmsSystSettings.get_setting_value(
               "test_setting_one",
               :setting_uuid
             )

    assert :ok =
             MsbmsSystSettings.set_setting_values(
               "test_setting_one",
               second_change
             )

    assert second_change.setting_uuid ==
             MsbmsSystSettings.get_setting_value(
               "test_setting_one",
               :setting_uuid
             )

    assert :ok =
             MsbmsSystSettings.set_setting_value(
               "test_setting_one",
               :setting_uuid,
               first_change.setting_uuid
             )

    assert first_change.setting_uuid ==
             MsbmsSystSettings.get_setting_value(
               "test_setting_one",
               :setting_uuid
             )

    assert :ok =
             MsbmsSystSettings.set_setting_value(
               "test_setting_one",
               :setting_uuid,
               nil_change.setting_uuid
             )

    assert nil ==
             MsbmsSystSettings.get_setting_value(
               "test_setting_one",
               :setting_uuid
             )
  end

  test "Set/Get setting_blob Setting" do
    first_change = %{setting_blob: "First Test Blob Value"}
    second_change = %{setting_blob: "Second Test Blob Value"}
    nil_change = %{setting_blob: nil}

    assert %MsbmsSystSettings.Data.SystSettings{
             setting_blob: "Test Setting One Bytea"
           } = MsbmsSystSettings.get_setting_values("test_setting_one")

    assert "Test Setting One Bytea" =
             MsbmsSystSettings.get_setting_value(
               "test_setting_one",
               :setting_blob
             )

    assert :ok =
             MsbmsSystSettings.set_setting_values(
               "test_setting_one",
               second_change
             )

    assert second_change.setting_blob ==
             MsbmsSystSettings.get_setting_value(
               "test_setting_one",
               :setting_blob
             )

    assert :ok =
             MsbmsSystSettings.set_setting_value(
               "test_setting_one",
               :setting_blob,
               first_change.setting_blob
             )

    assert first_change.setting_blob ==
             MsbmsSystSettings.get_setting_value(
               "test_setting_one",
               :setting_blob
             )

    assert :ok =
             MsbmsSystSettings.set_setting_value(
               "test_setting_one",
               :setting_blob,
               nil_change.setting_blob
             )

    assert nil ==
             MsbmsSystSettings.get_setting_value(
               "test_setting_one",
               :setting_blob
             )
  end

  test "Can List All Settings." do
    assert [_ | _] = MsbmsSystSettings.list_all_settings()
  end
end
