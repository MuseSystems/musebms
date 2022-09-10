# Source File: db_types_date_range_date_test.exs
# Location:    musebms/components/system/msbms_syst_datastore/test/db_types_date_range_date_test.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule DbTypesTimestampRangeDateTimeTest do
  use ExUnit.Case, async: true

  alias MsbmsSystDatastore.DbTypes

  test "Can compute Date/Date result operators" do
    assert DbTypes.compare(~U[2022-01-01 00:00:00Z], ~U[2022-01-01 00:00:00Z]) == :eq
    assert DbTypes.compare(~U[2022-01-01 00:00:00Z], ~U[2022-01-02 00:00:00Z]) == :lt
    assert DbTypes.compare(~U[2022-01-02 00:00:00Z], ~U[2022-01-01 00:00:00Z]) == :gt

    assert DbTypes.test_compare(~U[2022-01-01 00:00:00Z], ~U[2022-01-01 00:00:00Z], :eq)
    assert DbTypes.test_compare(~U[2022-01-01 00:00:00Z], ~U[2022-01-02 00:00:00Z], :lt)
    assert DbTypes.test_compare(~U[2022-01-02 00:00:00Z], ~U[2022-01-01 00:00:00Z], :gt)
  end

  test "Can compute DateRange/Date inclusivity correctly" do
    li_ui = %DbTypes.TimestampRange{
      lower: ~U[2022-07-31 00:00:00Z],
      upper: ~U[2022-08-01 00:00:00Z],
      lower_inclusive: true,
      upper_inclusive: true
    }

    assert DbTypes.compare(li_ui, ~U[2022-07-31 00:00:00Z]) == :lcr
    assert DbTypes.compare(li_ui, ~U[2022-08-01 00:00:00Z]) == :lcr
    assert DbTypes.compare(~U[2022-07-31 00:00:00Z], li_ui) == :rcl
    assert DbTypes.compare(~U[2022-08-01 00:00:00Z], li_ui) == :rcl

    li_ue = %DbTypes.TimestampRange{
      lower: ~U[2022-07-31 00:00:00Z],
      upper: ~U[2022-08-01 00:00:00Z],
      lower_inclusive: true,
      upper_inclusive: false
    }

    assert DbTypes.compare(li_ue, ~U[2022-07-31 00:00:00Z]) == :lcr
    assert DbTypes.compare(li_ue, ~U[2022-08-01 00:00:00Z]) == :lt
    assert DbTypes.compare(~U[2022-07-31 00:00:00Z], li_ue) == :rcl
    assert DbTypes.compare(~U[2022-08-01 00:00:00Z], li_ue) == :gt

    le_ui = %DbTypes.TimestampRange{
      lower: ~U[2022-07-31 00:00:00Z],
      upper: ~U[2022-08-01 00:00:00Z],
      lower_inclusive: false,
      upper_inclusive: true
    }

    assert DbTypes.compare(le_ui, ~U[2022-07-31 00:00:00Z]) == :gt
    assert DbTypes.compare(le_ui, ~U[2022-08-01 00:00:00Z]) == :lcr
    assert DbTypes.compare(~U[2022-07-31 00:00:00Z], le_ui) == :lt
    assert DbTypes.compare(~U[2022-08-01 00:00:00Z], le_ui) == :rcl
  end

  test "Can compute DateRange/DateRange inclusivity correctly" do
    lower_control = %DbTypes.TimestampRange{
      lower: ~U[2022-06-01 00:00:00Z],
      upper: ~U[2022-07-31 00:00:00Z],
      lower_inclusive: true,
      upper_inclusive: true
    }

    upper_control = %DbTypes.TimestampRange{
      lower: ~U[2022-10-01 00:00:00Z],
      upper: ~U[2022-11-01 00:00:00Z],
      lower_inclusive: true,
      upper_inclusive: true
    }

    li_ui = %DbTypes.TimestampRange{
      lower: ~U[2022-07-31 00:00:00Z],
      upper: ~U[2022-10-01 00:00:00Z],
      lower_inclusive: true,
      upper_inclusive: true
    }

    assert DbTypes.compare(li_ui, lower_control) == :gto
    assert DbTypes.compare(li_ui, upper_control) == :lto
    assert DbTypes.compare(lower_control, li_ui) == :lto
    assert DbTypes.compare(upper_control, li_ui) == :gto

    li_ue = %DbTypes.TimestampRange{
      lower: ~U[2022-07-31 00:00:00Z],
      upper: ~U[2022-10-01 00:00:00Z],
      lower_inclusive: true,
      upper_inclusive: false
    }

    assert DbTypes.compare(li_ue, lower_control) == :gto
    assert DbTypes.compare(li_ue, upper_control) == :lt
    assert DbTypes.compare(lower_control, li_ue) == :lto
    assert DbTypes.compare(upper_control, li_ue) == :gt

    le_ui = %DbTypes.TimestampRange{
      lower: ~U[2022-07-31 00:00:00Z],
      upper: ~U[2022-10-01 00:00:00Z],
      lower_inclusive: false,
      upper_inclusive: true
    }

    assert DbTypes.compare(le_ui, lower_control) == :gt
    assert DbTypes.compare(le_ui, upper_control) == :lto
    assert DbTypes.compare(lower_control, le_ui) == :lt
    assert DbTypes.compare(upper_control, le_ui) == :gto
  end

  test "Can compute DateRange/Date bounding correctly" do
    # :empty and :unbound are synonyms, so mix them up across lower & upper.
    # Inclusivity doesn't matter for :unbound/:empty; they are always inclusive.
    lu_ub = %DbTypes.TimestampRange{
      lower: :empty,
      upper: ~U[2022-08-01 00:00:00Z],
      lower_inclusive: true,
      upper_inclusive: true
    }

    assert DbTypes.compare(lu_ub, ~U[1066-01-01 00:00:00Z]) == :lcr
    assert DbTypes.compare(lu_ub, ~U[2022-08-02 00:00:00Z]) == :lt
    assert DbTypes.compare(~U[2022-07-31 00:00:00Z], lu_ub) == :rcl
    assert DbTypes.compare(~U[2022-08-02 00:00:00Z], lu_ub) == :gt

    lb_uu = %DbTypes.TimestampRange{
      lower: ~U[2022-07-31 00:00:00Z],
      upper: :unbound,
      lower_inclusive: true,
      upper_inclusive: false
    }

    assert DbTypes.compare(lb_uu, ~U[1066-01-01 00:00:00Z]) == :gt
    assert DbTypes.compare(lb_uu, ~U[2022-08-01 00:00:00Z]) == :lcr
    assert DbTypes.compare(~U[2022-07-30 00:00:00Z], lb_uu) == :lt
    assert DbTypes.compare(~U[2022-08-01 00:00:00Z], lb_uu) == :rcl

    lu_uu = %DbTypes.TimestampRange{
      lower: :unbound,
      upper: :empty,
      lower_inclusive: false,
      upper_inclusive: false
    }

    assert DbTypes.compare(lu_uu, DateTime.add(DateTime.utc_now(), :rand.uniform(100_000) * -1)) ==
             :lcr

    assert DbTypes.compare(DateTime.add(DateTime.utc_now(), :rand.uniform(1_000_000)), lu_uu) ==
             :rcl
  end

  test "Can compute DateRange/DateRange bounding correctly" do
    # :empty and :unbound are synonyms, so mix them up across lower & upper.
    # Inclusivity doesn't matter for :unbound/:empty; they are always inclusive.

    control = %DbTypes.TimestampRange{
      lower: ~U[2022-01-01 00:00:00Z],
      upper: ~U[2022-07-01 00:00:00Z],
      lower_inclusive: true,
      upper_inclusive: true
    }

    lu_ub = %DbTypes.TimestampRange{
      lower: :empty,
      upper: ~U[2022-07-01 00:00:00Z],
      lower_inclusive: true,
      upper_inclusive: true
    }

    assert DbTypes.compare(lu_ub, control) == :lcr
    assert DbTypes.compare(control, lu_ub) == :rcl

    lb_uu = %DbTypes.TimestampRange{
      lower: ~U[2022-01-01 00:00:00Z],
      upper: :unbound,
      lower_inclusive: true,
      upper_inclusive: false
    }

    assert DbTypes.compare(lb_uu, control) == :lcr
    assert DbTypes.compare(control, lb_uu) == :rcl

    le_ui = %DbTypes.TimestampRange{
      lower: :unbound,
      upper: :empty,
      lower_inclusive: false,
      upper_inclusive: false
    }

    assert DbTypes.compare(le_ui, control) == :lcr
    assert DbTypes.compare(control, le_ui) == :rcl
  end

  test "Can compute DateRange/Date result operators" do
    control = %DbTypes.TimestampRange{
      lower: ~U[2022-01-01 00:00:00Z],
      upper: ~U[2022-07-01 00:00:00Z],
      lower_inclusive: true,
      upper_inclusive: false
    }

    # :lt

    assert DbTypes.compare(control, ~U[2022-07-01 00:00:00Z]) == :lt
    assert DbTypes.compare(control, ~U[2023-01-01 00:00:00Z]) == :lt

    assert DbTypes.compare(~U[2021-01-01 00:00:00Z], control) == :lt
    assert DbTypes.compare(~U[2021-12-31 00:00:00Z], control) == :lt

    # :gt
    assert DbTypes.compare(control, ~U[2021-07-01 00:00:00Z]) == :gt
    assert DbTypes.compare(control, ~U[2021-12-31 00:00:00Z]) == :gt

    assert DbTypes.compare(~U[2022-07-01 00:00:00Z], control) == :gt
    assert DbTypes.compare(~U[2025-07-01 00:00:00Z], control) == :gt

    # :lcr
    assert DbTypes.compare(control, ~U[2022-01-01 00:00:00Z]) == :lcr
    assert DbTypes.compare(control, ~U[2022-06-30 00:00:00Z]) == :lcr
    assert DbTypes.compare(control, ~U[2022-03-28 00:00:00Z]) == :lcr

    # :rcl
    assert DbTypes.compare(~U[2022-01-01 00:00:00Z], control) == :rcl
    assert DbTypes.compare(~U[2022-06-30 00:00:00Z], control) == :rcl
    assert DbTypes.compare(~U[2022-02-28 00:00:00Z], control) == :rcl
  end

  test "Can compute DateRange/DateRange result operators" do
    control = %DbTypes.TimestampRange{
      lower: ~U[2022-01-01 00:00:00Z],
      upper: ~U[2022-07-01 00:00:00Z],
      lower_inclusive: true,
      upper_inclusive: true
    }

    # :eq

    eq1 = %DbTypes.TimestampRange{
      lower: ~U[2022-01-01 00:00:00Z],
      upper: ~U[2022-07-01 00:00:01Z],
      lower_inclusive: true,
      upper_inclusive: false
    }

    eq2 = %DbTypes.TimestampRange{
      lower: ~U[2021-12-31 23:59:59Z],
      upper: ~U[2022-07-01 00:00:00Z],
      lower_inclusive: false,
      upper_inclusive: true
    }

    assert DbTypes.compare(control, eq1) == :eq
    assert DbTypes.compare(eq2, control) == :eq

    # :lt

    lt1 = %DbTypes.TimestampRange{
      lower: ~U[2022-07-02 00:00:00Z],
      upper: ~U[2022-12-31 00:00:00Z],
      lower_inclusive: true,
      upper_inclusive: true
    }

    lt2 = %DbTypes.TimestampRange{
      lower: ~U[2021-07-02 00:00:00Z],
      upper: ~U[2021-12-31 00:00:00Z],
      lower_inclusive: true,
      upper_inclusive: true
    }

    assert DbTypes.compare(control, lt1) == :lt
    assert DbTypes.compare(lt2, control) == :lt

    # :gt

    gt1 = %DbTypes.TimestampRange{
      lower: ~U[2021-07-01 00:00:00Z],
      upper: ~U[2021-12-31 00:00:00Z],
      lower_inclusive: true,
      upper_inclusive: true
    }

    gt2 = %DbTypes.TimestampRange{
      lower: ~U[2022-07-02 00:00:00Z],
      upper: ~U[2022-12-31 00:00:00Z],
      lower_inclusive: true,
      upper_inclusive: true
    }

    assert DbTypes.compare(control, gt1) == :gt
    assert DbTypes.compare(gt2, control) == :gt

    # :lcr

    lcr1 = %DbTypes.TimestampRange{
      lower: ~U[2022-01-02 00:00:00Z],
      upper: ~U[2022-07-01 00:00:00Z],
      lower_inclusive: true,
      upper_inclusive: true
    }

    lcr2 = %DbTypes.TimestampRange{
      lower: ~U[2022-01-01 00:00:00Z],
      upper: ~U[2022-07-02 00:00:00Z],
      lower_inclusive: true,
      upper_inclusive: true
    }

    assert DbTypes.compare(control, lcr1) == :lcr
    assert DbTypes.compare(lcr2, control) == :lcr

    # :rcl

    rcl1 = %DbTypes.TimestampRange{
      lower: ~U[2022-01-01 00:00:00Z],
      upper: ~U[2022-07-02 00:00:00Z],
      lower_inclusive: true,
      upper_inclusive: true
    }

    rcl2 = %DbTypes.TimestampRange{
      lower: ~U[2022-01-02 00:00:00Z],
      upper: ~U[2022-07-01 00:00:00Z],
      lower_inclusive: true,
      upper_inclusive: true
    }

    assert DbTypes.compare(control, rcl1) == :rcl
    assert DbTypes.compare(rcl2, control) == :rcl

    # :gto

    gto1 = %DbTypes.TimestampRange{
      lower: ~U[2021-08-01 00:00:00Z],
      upper: ~U[2022-01-01 00:00:00Z],
      lower_inclusive: true,
      upper_inclusive: true
    }

    gto2 = %DbTypes.TimestampRange{
      lower: ~U[2022-07-01 00:00:00Z],
      upper: ~U[2022-08-01 00:00:00Z],
      lower_inclusive: true,
      upper_inclusive: true
    }

    assert DbTypes.compare(control, gto1) == :gto
    assert DbTypes.compare(gto2, control) == :gto

    # :lto

    lto1 = %DbTypes.TimestampRange{
      lower: ~U[2022-07-01 00:00:00Z],
      upper: ~U[2022-10-01 00:00:00Z],
      lower_inclusive: true,
      upper_inclusive: true
    }

    lto2 = %DbTypes.TimestampRange{
      lower: ~U[2021-07-01 00:00:00Z],
      upper: ~U[2022-01-01 00:00:00Z],
      lower_inclusive: true,
      upper_inclusive: true
    }

    assert DbTypes.compare(control, lto1) == :lto
    assert DbTypes.compare(lto2, control) == :lto
  end

  test "Can compute Date/DateRange and DateRange/DateRange equality" do
    control = %DbTypes.TimestampRange{
      lower: ~U[2022-01-01 00:00:00Z],
      upper: ~U[2022-01-01 00:00:01Z],
      lower_inclusive: true,
      upper_inclusive: false
    }

    assert DbTypes.compare(control, control) == :eq
    assert DbTypes.compare(control, ~U[2022-01-01 00:00:00Z]) == :lcr
    assert DbTypes.compare(~U[2022-01-01 00:00:00Z], control) == :rcl
  end
end
