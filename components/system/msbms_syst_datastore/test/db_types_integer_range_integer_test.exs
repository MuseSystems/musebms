# Source File: db_types_integer_range_integer_test.exs
# Location:    musebms/components/system/msbms_syst_datastore/test/db_types_integer_range_integer_test.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule DbTypesIntegerRangeIntegerTest do
  use ExUnit.Case, async: true

  alias MsbmsSystDatastore.DbTypes

  test "Can compute Integer/Integer result operators" do
    assert DbTypes.compare(1, 1) == :eq
    assert DbTypes.compare(1, 2) == :lt
    assert DbTypes.compare(2, 1) == :gt

    assert DbTypes.test_compare(1, 1, :eq)
    assert DbTypes.test_compare(1, 2, :lt)
    assert DbTypes.test_compare(2, 1, :gt)
  end

  test "Can compute IntegerRange/Integer inclusivity correctly" do
    li_ui = %DbTypes.IntegerRange{
      lower: 10,
      upper: 20,
      lower_inclusive: true,
      upper_inclusive: true
    }

    assert DbTypes.compare(li_ui, 10) == :lcr
    assert DbTypes.compare(li_ui, 20) == :lcr
    assert DbTypes.compare(10, li_ui) == :rcl
    assert DbTypes.compare(20, li_ui) == :rcl

    li_ue = %DbTypes.IntegerRange{
      lower: 10,
      upper: 20,
      lower_inclusive: true,
      upper_inclusive: false
    }

    assert DbTypes.compare(li_ue, 10) == :lcr
    assert DbTypes.compare(li_ue, 20) == :lt
    assert DbTypes.compare(10, li_ue) == :rcl
    assert DbTypes.compare(20, li_ue) == :gt

    le_ui = %DbTypes.IntegerRange{
      lower: 10,
      upper: 20,
      lower_inclusive: false,
      upper_inclusive: true
    }

    assert DbTypes.compare(le_ui, 10) == :gt
    assert DbTypes.compare(le_ui, 20) == :lcr
    assert DbTypes.compare(10, le_ui) == :lt
    assert DbTypes.compare(20, le_ui) == :rcl
  end

  test "Can compute IntegerRange/IntegerRange inclusivity correctly" do
    li_ui = %DbTypes.IntegerRange{
      lower: 10,
      upper: 20,
      lower_inclusive: true,
      upper_inclusive: true
    }

    lower_control = %DbTypes.IntegerRange{
      lower: 1,
      upper: 10,
      lower_inclusive: true,
      upper_inclusive: true
    }

    upper_control = %DbTypes.IntegerRange{
      lower: 20,
      upper: 30,
      lower_inclusive: true,
      upper_inclusive: true
    }

    assert DbTypes.compare(li_ui, lower_control) == :gto
    assert DbTypes.compare(li_ui, upper_control) == :lto
    assert DbTypes.compare(lower_control, li_ui) == :lto
    assert DbTypes.compare(upper_control, li_ui) == :gto

    li_ue = %DbTypes.IntegerRange{
      lower: 10,
      upper: 20,
      lower_inclusive: true,
      upper_inclusive: false
    }

    assert DbTypes.compare(li_ue, lower_control) == :gto
    assert DbTypes.compare(li_ue, upper_control) == :lt
    assert DbTypes.compare(lower_control, li_ue) == :lto
    assert DbTypes.compare(upper_control, li_ue) == :gt

    le_ui = %DbTypes.IntegerRange{
      lower: 10,
      upper: 20,
      lower_inclusive: false,
      upper_inclusive: true
    }

    assert DbTypes.compare(le_ui, lower_control) == :gt
    assert DbTypes.compare(le_ui, upper_control) == :lto
    assert DbTypes.compare(lower_control, le_ui) == :lt
    assert DbTypes.compare(upper_control, le_ui) == :gto
  end

  test "Can compute IntegerRange/Integer bounding correctly" do
    # :empty and :unbound are synonyms, so mix them up across lower & upper.
    # Inclusivity doesn't matter for :unbound/:empty; they are always inclusive.
    lu_ub = %DbTypes.IntegerRange{
      lower: :empty,
      upper: 20,
      lower_inclusive: true,
      upper_inclusive: true
    }

    assert DbTypes.compare(lu_ub, -10) == :lcr
    assert DbTypes.compare(lu_ub, 21) == :lt
    assert DbTypes.compare(10, lu_ub) == :rcl
    assert DbTypes.compare(21, lu_ub) == :gt

    lb_uu = %DbTypes.IntegerRange{
      lower: 10,
      upper: :unbound,
      lower_inclusive: true,
      upper_inclusive: false
    }

    assert DbTypes.compare(lb_uu, -9) == :gt
    assert DbTypes.compare(lb_uu, 20) == :lcr
    assert DbTypes.compare(9, lb_uu) == :lt
    assert DbTypes.compare(20, lb_uu) == :rcl

    lu_uu = %DbTypes.IntegerRange{
      lower: :unbound,
      upper: :empty,
      lower_inclusive: false,
      upper_inclusive: false
    }

    assert DbTypes.compare(lu_uu, :rand.uniform(1_000_000_000) * -1) == :lcr
    assert DbTypes.compare(:rand.uniform(1_000_000_000), lu_uu) == :rcl
  end

  test "Can compute IntegerRange/IntegerRange bounding correctly" do
    # :empty and :unbound are synonyms, so mix them up across lower & upper.
    # Inclusivity doesn't matter for :unbound/:empty; they are always inclusive.

    control = %DbTypes.IntegerRange{
      lower: 10,
      upper: 100,
      lower_inclusive: true,
      upper_inclusive: true
    }

    lu_ub = %DbTypes.IntegerRange{
      lower: :empty,
      upper: 100,
      lower_inclusive: true,
      upper_inclusive: true
    }

    assert DbTypes.compare(lu_ub, control) == :lcr
    assert DbTypes.compare(control, lu_ub) == :rcl

    lb_uu = %DbTypes.IntegerRange{
      lower: 10,
      upper: :unbound,
      lower_inclusive: true,
      upper_inclusive: false
    }

    assert DbTypes.compare(lb_uu, control) == :lcr
    assert DbTypes.compare(control, lb_uu) == :rcl

    le_ui = %DbTypes.IntegerRange{
      lower: :unbound,
      upper: :empty,
      lower_inclusive: false,
      upper_inclusive: false
    }

    assert DbTypes.compare(le_ui, control) == :lcr
    assert DbTypes.compare(control, le_ui) == :rcl
  end

  test "Can compute IntegerRange/Integer result operators" do
    control = %DbTypes.IntegerRange{
      lower: 10,
      upper: 100,
      lower_inclusive: true,
      upper_inclusive: false
    }

    # :lt

    assert DbTypes.compare(control, 100) == :lt
    assert DbTypes.compare(control, 1000) == :lt

    assert DbTypes.compare(-100, control) == :lt
    assert DbTypes.compare(9, control) == :lt

    # :gt
    assert DbTypes.compare(control, -50) == :gt
    assert DbTypes.compare(control, 9) == :gt

    assert DbTypes.compare(100, control) == :gt
    assert DbTypes.compare(1500, control) == :gt

    # :lcr
    assert DbTypes.compare(control, 10) == :lcr
    assert DbTypes.compare(control, 99) == :lcr
    assert DbTypes.compare(control, 50) == :lcr

    # :rcl
    assert DbTypes.compare(10, control) == :rcl
    assert DbTypes.compare(99, control) == :rcl
    assert DbTypes.compare(24, control) == :rcl
  end

  test "Can compute IntegerRange/IntegerRange result operators" do
    control = %DbTypes.IntegerRange{
      lower: 10,
      upper: 100,
      lower_inclusive: true,
      upper_inclusive: true
    }

    # :eq

    eq1 = %DbTypes.IntegerRange{
      lower: 10,
      upper: 101,
      lower_inclusive: true,
      upper_inclusive: false
    }

    eq2 = %DbTypes.IntegerRange{
      lower: 9,
      upper: 100,
      lower_inclusive: false,
      upper_inclusive: true
    }

    assert DbTypes.compare(control, eq1) == :eq
    assert DbTypes.compare(eq2, control) == :eq

    # :lt

    lt1 = %DbTypes.IntegerRange{
      lower: 101,
      upper: 200,
      lower_inclusive: true,
      upper_inclusive: true
    }

    lt2 = %DbTypes.IntegerRange{
      lower: -10,
      upper: -1,
      lower_inclusive: true,
      upper_inclusive: true
    }

    assert DbTypes.compare(control, lt1) == :lt
    assert DbTypes.compare(lt2, control) == :lt

    # :gt

    gt1 = %DbTypes.IntegerRange{
      lower: 1,
      upper: 9,
      lower_inclusive: true,
      upper_inclusive: true
    }

    gt2 = %DbTypes.IntegerRange{
      lower: 101,
      upper: 200,
      lower_inclusive: true,
      upper_inclusive: true
    }

    assert DbTypes.compare(control, gt1) == :gt
    assert DbTypes.compare(gt2, control) == :gt

    # :lcr

    lcr1 = %DbTypes.IntegerRange{
      lower: 11,
      upper: 100,
      lower_inclusive: true,
      upper_inclusive: true
    }

    lcr2 = %DbTypes.IntegerRange{
      lower: 10,
      upper: 101,
      lower_inclusive: true,
      upper_inclusive: true
    }

    assert DbTypes.compare(control, lcr1) == :lcr
    assert DbTypes.compare(lcr2, control) == :lcr

    # :rcl

    rcl1 = %DbTypes.IntegerRange{
      lower: 10,
      upper: 101,
      lower_inclusive: true,
      upper_inclusive: true
    }

    rcl2 = %DbTypes.IntegerRange{
      lower: 11,
      upper: 100,
      lower_inclusive: true,
      upper_inclusive: true
    }

    assert DbTypes.compare(control, rcl1) == :rcl
    assert DbTypes.compare(rcl2, control) == :rcl

    # :gto

    gto1 = %DbTypes.IntegerRange{
      lower: 1,
      upper: 10,
      lower_inclusive: true,
      upper_inclusive: true
    }

    gto2 = %DbTypes.IntegerRange{
      lower: 100,
      upper: 200,
      lower_inclusive: true,
      upper_inclusive: true
    }

    assert DbTypes.compare(control, gto1) == :gto
    assert DbTypes.compare(gto2, control) == :gto

    # :lto

    lto1 = %DbTypes.IntegerRange{
      lower: 100,
      upper: 200,
      lower_inclusive: true,
      upper_inclusive: true
    }

    lto2 = %DbTypes.IntegerRange{
      lower: 1,
      upper: 10,
      lower_inclusive: true,
      upper_inclusive: true
    }

    assert DbTypes.compare(control, lto1) == :lto
    assert DbTypes.compare(lto2, control) == :lto
  end

  test "Can compute Integer/IntegerRange and IntegerRange/IntegerRange equality" do
    control = %DbTypes.IntegerRange{
      lower: 100,
      upper: 101,
      lower_inclusive: true,
      upper_inclusive: false
    }

    assert DbTypes.compare(control, control) == :eq
    assert DbTypes.compare(control, 100) == :lcr
    assert DbTypes.compare(100, control) == :rcl
  end
end
