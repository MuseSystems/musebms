# Source File: db_types_decimal_range_decimal_test.exs
# Location:    musebms/components/system/msbms_syst_datastore/test/db_types_decimal_range_decimal_test.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule DbTypesDecimalRangeDecimalTest do
  use ExUnit.Case, async: true

  alias MsbmsSystDatastore.DbTypes

  test "Can compute Decimal/Decimal result operators" do
    assert DbTypes.Range.compare(Decimal.new("1.1"), Decimal.new("1.1")) == :eq
    assert DbTypes.Range.compare(Decimal.new("1.1"), Decimal.new("1.2")) == :lt
    assert DbTypes.Range.compare(Decimal.new("1.2"), Decimal.new("1.1")) == :gt

    assert DbTypes.Range.test_compare(Decimal.new("1.1"), Decimal.new("1.1"), :eq)
    assert DbTypes.Range.test_compare(Decimal.new("1.1"), Decimal.new("1.2"), :lt)
    assert DbTypes.Range.test_compare(Decimal.new("1.2"), Decimal.new("1.1"), :gt)
  end

  test "Can compute DecimalRange/Decimal inclusivity correctly" do
    li_ui = %DbTypes.DecimalRange{
      lower: Decimal.new("10"),
      upper: Decimal.new("20"),
      lower_inclusive: true,
      upper_inclusive: true
    }

    assert DbTypes.Range.compare(li_ui, Decimal.new("10")) == :lcr
    assert DbTypes.Range.compare(li_ui, Decimal.new("20")) == :lcr
    assert DbTypes.Range.compare(Decimal.new("10"), li_ui) == :rcl
    assert DbTypes.Range.compare(Decimal.new("20"), li_ui) == :rcl

    li_ue = %DbTypes.DecimalRange{
      lower: Decimal.new("10"),
      upper: Decimal.new("20"),
      lower_inclusive: true,
      upper_inclusive: false
    }

    assert DbTypes.Range.compare(li_ue, Decimal.new("10")) == :lcr
    assert DbTypes.Range.compare(li_ue, Decimal.new("20")) == :lt
    assert DbTypes.Range.compare(Decimal.new("10"), li_ue) == :rcl
    assert DbTypes.Range.compare(Decimal.new("20"), li_ue) == :gt

    le_ui = %DbTypes.DecimalRange{
      lower: Decimal.new("10"),
      upper: Decimal.new("20"),
      lower_inclusive: false,
      upper_inclusive: true
    }

    assert DbTypes.Range.compare(le_ui, Decimal.new("10")) == :gt
    assert DbTypes.Range.compare(le_ui, Decimal.new("20")) == :lcr
    assert DbTypes.Range.compare(Decimal.new("10"), le_ui) == :lt
    assert DbTypes.Range.compare(Decimal.new("20"), le_ui) == :rcl
  end

  test "Can compute DecimalRange/DecimalRange inclusivity correctly" do
    lower_control = %DbTypes.DecimalRange{
      lower: Decimal.new("1"),
      upper: Decimal.new("10"),
      lower_inclusive: true,
      upper_inclusive: true
    }

    upper_control = %DbTypes.DecimalRange{
      lower: Decimal.new("20"),
      upper: Decimal.new("30"),
      lower_inclusive: true,
      upper_inclusive: true
    }

    li_ui = %DbTypes.DecimalRange{
      lower: Decimal.new("10"),
      upper: Decimal.new("20"),
      lower_inclusive: true,
      upper_inclusive: true
    }

    assert DbTypes.Range.compare(li_ui, lower_control) == :gto
    assert DbTypes.Range.compare(li_ui, upper_control) == :lto
    assert DbTypes.Range.compare(lower_control, li_ui) == :lto
    assert DbTypes.Range.compare(upper_control, li_ui) == :gto

    li_ue = %DbTypes.DecimalRange{
      lower: Decimal.new("10"),
      upper: Decimal.new("20"),
      lower_inclusive: true,
      upper_inclusive: false
    }

    assert DbTypes.Range.compare(li_ue, lower_control) == :gto
    assert DbTypes.Range.compare(li_ue, upper_control) == :lt
    assert DbTypes.Range.compare(lower_control, li_ue) == :lto
    assert DbTypes.Range.compare(upper_control, li_ue) == :gt

    le_ui = %DbTypes.DecimalRange{
      lower: Decimal.new("10"),
      upper: Decimal.new("20"),
      lower_inclusive: false,
      upper_inclusive: true
    }

    assert DbTypes.Range.compare(le_ui, lower_control) == :gt
    assert DbTypes.Range.compare(le_ui, upper_control) == :lto
    assert DbTypes.Range.compare(lower_control, le_ui) == :lt
    assert DbTypes.Range.compare(upper_control, le_ui) == :gto
  end

  test "Can compute DecimalRange/Decimal bounding correctly" do
    # :empty and :unbound are synonyms, so mix them up across lower & upper.
    # Inclusivity doesn't matter for :unbound/:empty; they are always inclusive.
    lu_ub = %DbTypes.DecimalRange{
      lower: :empty,
      upper: Decimal.new("20"),
      lower_inclusive: true,
      upper_inclusive: true
    }

    assert DbTypes.Range.compare(lu_ub, Decimal.new("-10")) == :lcr
    assert DbTypes.Range.compare(lu_ub, Decimal.new("21")) == :lt
    assert DbTypes.Range.compare(Decimal.new("10"), lu_ub) == :rcl
    assert DbTypes.Range.compare(Decimal.new("21"), lu_ub) == :gt

    lb_uu = %DbTypes.DecimalRange{
      lower: Decimal.new("10"),
      upper: :unbound,
      lower_inclusive: true,
      upper_inclusive: false
    }

    assert DbTypes.Range.compare(lb_uu, Decimal.new("-9")) == :gt
    assert DbTypes.Range.compare(lb_uu, Decimal.new("20")) == :lcr
    assert DbTypes.Range.compare(Decimal.new("9"), lb_uu) == :lt
    assert DbTypes.Range.compare(Decimal.new("20"), lb_uu) == :rcl

    lu_uu = %DbTypes.DecimalRange{
      lower: :unbound,
      upper: :empty,
      lower_inclusive: false,
      upper_inclusive: false
    }

    assert DbTypes.Range.compare(lu_uu, Decimal.new(-1, :rand.uniform(1_000_000_000), 3)) == :lcr
    assert DbTypes.Range.compare(Decimal.new(1, :rand.uniform(1_000_000_000), -3), lu_uu) == :rcl
  end

  test "Can compute DecimalRange/DecimalRange bounding correctly" do
    # :empty and :unbound are synonyms, so mix them up across lower & upper.
    # Inclusivity doesn't matter for :unbound/:empty; they are always inclusive.

    control = %DbTypes.DecimalRange{
      lower: Decimal.new("10"),
      upper: Decimal.new("100"),
      lower_inclusive: true,
      upper_inclusive: true
    }

    lu_ub = %DbTypes.DecimalRange{
      lower: :empty,
      upper: Decimal.new("100"),
      lower_inclusive: true,
      upper_inclusive: true
    }

    assert DbTypes.Range.compare(lu_ub, control) == :lcr
    assert DbTypes.Range.compare(control, lu_ub) == :rcl

    lb_uu = %DbTypes.DecimalRange{
      lower: Decimal.new("10"),
      upper: :unbound,
      lower_inclusive: true,
      upper_inclusive: false
    }

    assert DbTypes.Range.compare(lb_uu, control) == :lcr
    assert DbTypes.Range.compare(control, lb_uu) == :rcl

    le_ui = %DbTypes.DecimalRange{
      lower: :unbound,
      upper: :empty,
      lower_inclusive: false,
      upper_inclusive: false
    }

    assert DbTypes.Range.compare(le_ui, control) == :lcr
    assert DbTypes.Range.compare(control, le_ui) == :rcl
  end

  test "Can compute DecimalRange/Decimal result operators" do
    control = %DbTypes.DecimalRange{
      lower: Decimal.new("10"),
      upper: Decimal.new("100"),
      lower_inclusive: true,
      upper_inclusive: false
    }

    # :lt

    assert DbTypes.Range.compare(control, Decimal.new("100")) == :lt
    assert DbTypes.Range.compare(control, Decimal.new("1000")) == :lt

    assert DbTypes.Range.compare(Decimal.new("-100"), control) == :lt
    assert DbTypes.Range.compare(Decimal.new("9"), control) == :lt

    # :gt
    assert DbTypes.Range.compare(control, Decimal.new("-50")) == :gt
    assert DbTypes.Range.compare(control, Decimal.new("9")) == :gt

    assert DbTypes.Range.compare(Decimal.new("100"), control) == :gt
    assert DbTypes.Range.compare(Decimal.new("1500"), control) == :gt

    # :lcr
    assert DbTypes.Range.compare(control, Decimal.new("10")) == :lcr
    assert DbTypes.Range.compare(control, Decimal.new("99")) == :lcr
    assert DbTypes.Range.compare(control, Decimal.new("50")) == :lcr

    # :rcl
    assert DbTypes.Range.compare(Decimal.new("10"), control) == :rcl
    assert DbTypes.Range.compare(Decimal.new("99"), control) == :rcl
    assert DbTypes.Range.compare(Decimal.new("24"), control) == :rcl
  end

  test "Can compute DecimalRange/DecimalRange result operators" do
    control = %DbTypes.DecimalRange{
      lower: Decimal.new("10"),
      upper: Decimal.new("100"),
      lower_inclusive: true,
      upper_inclusive: true
    }

    # :eq

    eq1 = %DbTypes.DecimalRange{
      lower: Decimal.new("10"),
      upper: Decimal.new("101"),
      lower_inclusive: true,
      upper_inclusive: false
    }

    eq2 = %DbTypes.DecimalRange{
      lower: Decimal.new("9"),
      upper: Decimal.new("100"),
      lower_inclusive: false,
      upper_inclusive: true
    }

    assert DbTypes.Range.compare(control, eq1) == :eq
    assert DbTypes.Range.compare(eq2, control) == :eq

    # :lt

    lt1 = %DbTypes.DecimalRange{
      lower: Decimal.new("101"),
      upper: Decimal.new("200"),
      lower_inclusive: true,
      upper_inclusive: true
    }

    lt2 = %DbTypes.DecimalRange{
      lower: Decimal.new("-10"),
      upper: Decimal.new("-1"),
      lower_inclusive: true,
      upper_inclusive: true
    }

    assert DbTypes.Range.compare(control, lt1) == :lt
    assert DbTypes.Range.compare(lt2, control) == :lt

    # :gt

    gt1 = %DbTypes.DecimalRange{
      lower: Decimal.new("1"),
      upper: Decimal.new("9"),
      lower_inclusive: true,
      upper_inclusive: true
    }

    gt2 = %DbTypes.DecimalRange{
      lower: Decimal.new("101"),
      upper: Decimal.new("200"),
      lower_inclusive: true,
      upper_inclusive: true
    }

    assert DbTypes.Range.compare(control, gt1) == :gt
    assert DbTypes.Range.compare(gt2, control) == :gt

    # :lcr

    lcr1 = %DbTypes.DecimalRange{
      lower: Decimal.new("11"),
      upper: Decimal.new("100"),
      lower_inclusive: true,
      upper_inclusive: true
    }

    lcr2 = %DbTypes.DecimalRange{
      lower: Decimal.new("10"),
      upper: Decimal.new("101"),
      lower_inclusive: true,
      upper_inclusive: true
    }

    assert DbTypes.Range.compare(control, lcr1) == :lcr
    assert DbTypes.Range.compare(lcr2, control) == :lcr

    # :rcl

    rcl1 = %DbTypes.DecimalRange{
      lower: Decimal.new("10"),
      upper: Decimal.new("101"),
      lower_inclusive: true,
      upper_inclusive: true
    }

    rcl2 = %DbTypes.DecimalRange{
      lower: Decimal.new("11"),
      upper: Decimal.new("100"),
      lower_inclusive: true,
      upper_inclusive: true
    }

    assert DbTypes.Range.compare(control, rcl1) == :rcl
    assert DbTypes.Range.compare(rcl2, control) == :rcl

    # :gto

    gto1 = %DbTypes.DecimalRange{
      lower: Decimal.new("1"),
      upper: Decimal.new("10"),
      lower_inclusive: true,
      upper_inclusive: true
    }

    gto2 = %DbTypes.DecimalRange{
      lower: Decimal.new("100"),
      upper: Decimal.new("200"),
      lower_inclusive: true,
      upper_inclusive: true
    }

    assert DbTypes.Range.compare(control, gto1) == :gto
    assert DbTypes.Range.compare(gto2, control) == :gto

    # :lto

    lto1 = %DbTypes.DecimalRange{
      lower: Decimal.new("100"),
      upper: Decimal.new("200"),
      lower_inclusive: true,
      upper_inclusive: true
    }

    lto2 = %DbTypes.DecimalRange{
      lower: Decimal.new("1"),
      upper: Decimal.new("10"),
      lower_inclusive: true,
      upper_inclusive: true
    }

    assert DbTypes.Range.compare(control, lto1) == :lto
    assert DbTypes.Range.compare(lto2, control) == :lto
  end

  test "Can compute Decimal/DecimalRange and DecimalRange/DecimalRange equality" do
    control = %DbTypes.DecimalRange{
      lower: Decimal.new("100"),
      upper: Decimal.new("101"),
      lower_inclusive: true,
      upper_inclusive: false
    }

    assert DbTypes.Range.compare(control, control) == :eq
    assert DbTypes.Range.compare(control, Decimal.new("100")) == :lcr
    assert DbTypes.Range.compare(Decimal.new("100"), control) == :rcl
  end
end
