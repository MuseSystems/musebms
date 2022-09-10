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

defmodule DbTypesDateRangeDateTest do
  use ExUnit.Case, async: true

  alias MsbmsSystDatastore.DbTypes

  test "Can compute Date/Date result operators" do
    assert DbTypes.compare(~D[2022-01-01], ~D[2022-01-01]) == :eq
    assert DbTypes.compare(~D[2022-01-01], ~D[2022-01-02]) == :lt
    assert DbTypes.compare(~D[2022-01-02], ~D[2022-01-01]) == :gt

    assert DbTypes.test_compare(~D[2022-01-01], ~D[2022-01-01], :eq)
    assert DbTypes.test_compare(~D[2022-01-01], ~D[2022-01-02], :lt)
    assert DbTypes.test_compare(~D[2022-01-02], ~D[2022-01-01], :gt)
  end

  test "Can compute DateRange/Date inclusivity correctly" do
    li_ui = %DbTypes.DateRange{
      lower: ~D[2022-07-31],
      upper: ~D[2022-08-01],
      lower_inclusive: true,
      upper_inclusive: true
    }

    assert DbTypes.compare(li_ui, ~D[2022-07-31]) == :lcr
    assert DbTypes.compare(li_ui, ~D[2022-08-01]) == :lcr
    assert DbTypes.compare(~D[2022-07-31], li_ui) == :rcl
    assert DbTypes.compare(~D[2022-08-01], li_ui) == :rcl

    li_ue = %DbTypes.DateRange{
      lower: ~D[2022-07-31],
      upper: ~D[2022-08-01],
      lower_inclusive: true,
      upper_inclusive: false
    }

    assert DbTypes.compare(li_ue, ~D[2022-07-31]) == :lcr
    assert DbTypes.compare(li_ue, ~D[2022-08-01]) == :lt
    assert DbTypes.compare(~D[2022-07-31], li_ue) == :rcl
    assert DbTypes.compare(~D[2022-08-01], li_ue) == :gt

    le_ui = %DbTypes.DateRange{
      lower: ~D[2022-07-31],
      upper: ~D[2022-08-01],
      lower_inclusive: false,
      upper_inclusive: true
    }

    assert DbTypes.compare(le_ui, ~D[2022-07-31]) == :gt
    assert DbTypes.compare(le_ui, ~D[2022-08-01]) == :lcr
    assert DbTypes.compare(~D[2022-07-31], le_ui) == :lt
    assert DbTypes.compare(~D[2022-08-01], le_ui) == :rcl
  end

  test "Can compute DateRange/DateRange inclusivity correctly" do
    lower_control = %DbTypes.DateRange{
      lower: ~D[2022-06-01],
      upper: ~D[2022-07-31],
      lower_inclusive: true,
      upper_inclusive: true
    }

    upper_control = %DbTypes.DateRange{
      lower: ~D[2022-10-01],
      upper: ~D[2022-11-01],
      lower_inclusive: true,
      upper_inclusive: true
    }

    li_ui = %DbTypes.DateRange{
      lower: ~D[2022-07-31],
      upper: ~D[2022-10-01],
      lower_inclusive: true,
      upper_inclusive: true
    }

    assert DbTypes.compare(li_ui, lower_control) == :gto
    assert DbTypes.compare(li_ui, upper_control) == :lto
    assert DbTypes.compare(lower_control, li_ui) == :lto
    assert DbTypes.compare(upper_control, li_ui) == :gto

    li_ue = %DbTypes.DateRange{
      lower: ~D[2022-07-31],
      upper: ~D[2022-10-01],
      lower_inclusive: true,
      upper_inclusive: false
    }

    assert DbTypes.compare(li_ue, lower_control) == :gto
    assert DbTypes.compare(li_ue, upper_control) == :lt
    assert DbTypes.compare(lower_control, li_ue) == :lto
    assert DbTypes.compare(upper_control, li_ue) == :gt

    le_ui = %DbTypes.DateRange{
      lower: ~D[2022-07-31],
      upper: ~D[2022-10-01],
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
    lu_ub = %DbTypes.DateRange{
      lower: :empty,
      upper: ~D[2022-08-01],
      lower_inclusive: true,
      upper_inclusive: true
    }

    assert DbTypes.compare(lu_ub, ~D[1066-01-01]) == :lcr
    assert DbTypes.compare(lu_ub, ~D[2022-08-02]) == :lt
    assert DbTypes.compare(~D[2022-07-31], lu_ub) == :rcl
    assert DbTypes.compare(~D[2022-08-02], lu_ub) == :gt

    lb_uu = %DbTypes.DateRange{
      lower: ~D[2022-07-31],
      upper: :unbound,
      lower_inclusive: true,
      upper_inclusive: false
    }

    assert DbTypes.compare(lb_uu, ~D[1066-01-01]) == :gt
    assert DbTypes.compare(lb_uu, ~D[2022-08-01]) == :lcr
    assert DbTypes.compare(~D[2022-07-30], lb_uu) == :lt
    assert DbTypes.compare(~D[2022-08-01], lb_uu) == :rcl

    lu_uu = %DbTypes.DateRange{
      lower: :unbound,
      upper: :empty,
      lower_inclusive: false,
      upper_inclusive: false
    }

    assert DbTypes.compare(lu_uu, Date.add(Date.utc_today(), :rand.uniform(100_000) * -1)) == :lcr
    assert DbTypes.compare(Date.add(Date.utc_today(), :rand.uniform(1_000_000)), lu_uu) == :rcl
  end

  test "Can compute DateRange/DateRange bounding correctly" do
    # :empty and :unbound are synonyms, so mix them up across lower & upper.
    # Inclusivity doesn't matter for :unbound/:empty; they are always inclusive.

    control = %DbTypes.DateRange{
      lower: ~D[2022-01-01],
      upper: ~D[2022-07-01],
      lower_inclusive: true,
      upper_inclusive: true
    }

    lu_ub = %DbTypes.DateRange{
      lower: :empty,
      upper: ~D[2022-07-01],
      lower_inclusive: true,
      upper_inclusive: true
    }

    assert DbTypes.compare(lu_ub, control) == :lcr
    assert DbTypes.compare(control, lu_ub) == :rcl

    lb_uu = %DbTypes.DateRange{
      lower: ~D[2022-01-01],
      upper: :unbound,
      lower_inclusive: true,
      upper_inclusive: false
    }

    assert DbTypes.compare(lb_uu, control) == :lcr
    assert DbTypes.compare(control, lb_uu) == :rcl

    le_ui = %DbTypes.DateRange{
      lower: :unbound,
      upper: :empty,
      lower_inclusive: false,
      upper_inclusive: false
    }

    assert DbTypes.compare(le_ui, control) == :lcr
    assert DbTypes.compare(control, le_ui) == :rcl
  end

  test "Can compute DateRange/Date result operators" do
    control = %DbTypes.DateRange{
      lower: ~D[2022-01-01],
      upper: ~D[2022-07-01],
      lower_inclusive: true,
      upper_inclusive: false
    }

    # :lt

    assert DbTypes.compare(control, ~D[2022-07-01]) == :lt
    assert DbTypes.compare(control, ~D[2023-01-01]) == :lt

    assert DbTypes.compare(~D[2021-01-01], control) == :lt
    assert DbTypes.compare(~D[2021-12-31], control) == :lt

    # :gt
    assert DbTypes.compare(control, ~D[2021-07-01]) == :gt
    assert DbTypes.compare(control, ~D[2021-12-31]) == :gt

    assert DbTypes.compare(~D[2022-07-01], control) == :gt
    assert DbTypes.compare(~D[2025-07-01], control) == :gt

    # :lcr
    assert DbTypes.compare(control, ~D[2022-01-01]) == :lcr
    assert DbTypes.compare(control, ~D[2022-06-30]) == :lcr
    assert DbTypes.compare(control, ~D[2022-03-28]) == :lcr

    # :rcl
    assert DbTypes.compare(~D[2022-01-01], control) == :rcl
    assert DbTypes.compare(~D[2022-06-30], control) == :rcl
    assert DbTypes.compare(~D[2022-02-28], control) == :rcl
  end

  test "Can compute DateRange/DateRange result operators" do
    control = %DbTypes.DateRange{
      lower: ~D[2022-01-01],
      upper: ~D[2022-07-01],
      lower_inclusive: true,
      upper_inclusive: true
    }

    # :eq

    eq1 = %DbTypes.DateRange{
      lower: ~D[2022-01-01],
      upper: ~D[2022-07-02],
      lower_inclusive: true,
      upper_inclusive: false
    }

    eq2 = %DbTypes.DateRange{
      lower: ~D[2021-12-31],
      upper: ~D[2022-07-01],
      lower_inclusive: false,
      upper_inclusive: true
    }

    assert DbTypes.compare(control, eq1) == :eq
    assert DbTypes.compare(eq2, control) == :eq

    # :lt

    lt1 = %DbTypes.DateRange{
      lower: ~D[2022-07-02],
      upper: ~D[2022-12-31],
      lower_inclusive: true,
      upper_inclusive: true
    }

    lt2 = %DbTypes.DateRange{
      lower: ~D[2021-07-02],
      upper: ~D[2021-12-31],
      lower_inclusive: true,
      upper_inclusive: true
    }

    assert DbTypes.compare(control, lt1) == :lt
    assert DbTypes.compare(lt2, control) == :lt

    # :gt

    gt1 = %DbTypes.DateRange{
      lower: ~D[2021-07-01],
      upper: ~D[2021-12-31],
      lower_inclusive: true,
      upper_inclusive: true
    }

    gt2 = %DbTypes.DateRange{
      lower: ~D[2022-07-02],
      upper: ~D[2022-12-31],
      lower_inclusive: true,
      upper_inclusive: true
    }

    assert DbTypes.compare(control, gt1) == :gt
    assert DbTypes.compare(gt2, control) == :gt

    # :lcr

    lcr1 = %DbTypes.DateRange{
      lower: ~D[2022-01-02],
      upper: ~D[2022-07-01],
      lower_inclusive: true,
      upper_inclusive: true
    }

    lcr2 = %DbTypes.DateRange{
      lower: ~D[2022-01-01],
      upper: ~D[2022-07-02],
      lower_inclusive: true,
      upper_inclusive: true
    }

    assert DbTypes.compare(control, lcr1) == :lcr
    assert DbTypes.compare(lcr2, control) == :lcr

    # :rcl

    rcl1 = %DbTypes.DateRange{
      lower: ~D[2022-01-01],
      upper: ~D[2022-07-02],
      lower_inclusive: true,
      upper_inclusive: true
    }

    rcl2 = %DbTypes.DateRange{
      lower: ~D[2022-01-02],
      upper: ~D[2022-07-01],
      lower_inclusive: true,
      upper_inclusive: true
    }

    assert DbTypes.compare(control, rcl1) == :rcl
    assert DbTypes.compare(rcl2, control) == :rcl

    # :gto

    gto1 = %DbTypes.DateRange{
      lower: ~D[2021-08-01],
      upper: ~D[2022-01-01],
      lower_inclusive: true,
      upper_inclusive: true
    }

    gto2 = %DbTypes.DateRange{
      lower: ~D[2022-07-01],
      upper: ~D[2022-08-01],
      lower_inclusive: true,
      upper_inclusive: true
    }

    assert DbTypes.compare(control, gto1) == :gto
    assert DbTypes.compare(gto2, control) == :gto

    # :lto

    lto1 = %DbTypes.DateRange{
      lower: ~D[2022-07-01],
      upper: ~D[2022-10-01],
      lower_inclusive: true,
      upper_inclusive: true
    }

    lto2 = %DbTypes.DateRange{
      lower: ~D[2021-07-01],
      upper: ~D[2022-01-01],
      lower_inclusive: true,
      upper_inclusive: true
    }

    assert DbTypes.compare(control, lto1) == :lto
    assert DbTypes.compare(lto2, control) == :lto
  end

  test "Can compute Date/DateRange and DateRange/DateRange equality" do
    control = %DbTypes.DateRange{
      lower: ~D[2022-01-01],
      upper: ~D[2022-01-02],
      lower_inclusive: true,
      upper_inclusive: false
    }

    assert DbTypes.compare(control, control) == :eq
    assert DbTypes.compare(control, ~D[2022-01-01]) == :lcr
    assert DbTypes.compare(~D[2022-01-01], control) == :rcl
  end
end
