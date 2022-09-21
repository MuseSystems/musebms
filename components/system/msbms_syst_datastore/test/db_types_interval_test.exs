# Source File: db_types_interval_test.exs
# Location:    musebms/components/system/msbms_syst_datastore/test/db_types_interval_test.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule DbTypesIntervalTest do
  use ExUnit.Case, async: true

  alias MsbmsSystDatastore.DbTypes

  test "Can compute Interval result operators" do
    control = %DbTypes.Interval{
      months: 1,
      days: 1,
      secs: 1,
      microsecs: 1
    }

    gt = %DbTypes.Interval{
      months: 1,
      days: 1,
      secs: 1,
      microsecs: 2
    }

    assert DbTypes.compare(gt, control) == :gt
    assert DbTypes.test_compare(gt, control, :gt)

    lt = %DbTypes.Interval{
      months: 1,
      days: 1,
      secs: 0,
      microsecs: 2
    }

    assert DbTypes.compare(lt, control) == :lt
    assert DbTypes.test_compare(lt, control, :lt)

    eq = %DbTypes.Interval{
      months: 1,
      days: 1,
      secs: 1,
      microsecs: 1
    }

    assert DbTypes.compare(eq, control) == :eq
    assert DbTypes.test_compare(eq, control, :eq)
  end

  test "Can convert Interval to Timex.shift_options" do
    months = :rand.uniform(100)
    days = :rand.uniform(100)
    secs = :rand.uniform(100)
    microsecs = :rand.uniform(100)

    test_interval = %DbTypes.Interval{
      months: months,
      days: days,
      secs: secs,
      microsecs: microsecs
    }

    result_list = DbTypes.Interval.to_timex_shift_options(test_interval)

    assert months == result_list[:months]
    assert days == result_list[:days]
    assert secs == result_list[:seconds]
    assert microsecs == result_list[:microseconds]
  end
end
