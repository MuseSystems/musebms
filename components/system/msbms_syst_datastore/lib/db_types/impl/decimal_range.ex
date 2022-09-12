# Source File: decimal_range.ex
# Location:    musebms/components/system/msbms_syst_datastore/lib/db_types/impl/decimal_range.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defimpl MsbmsSystDatastore.DbTypes, for: MsbmsSystDatastore.DbTypes.DecimalRange do
  alias MsbmsSystDatastore.DbTypes.Impl.DecimalRange

  def compare(left, right), do: DecimalRange.compare(left, right)

  def test_compare(left, right, operator), do: DecimalRange.test_compare(left, right, operator)
end

defimpl MsbmsSystDatastore.DbTypes.Range, for: MsbmsSystDatastore.DbTypes.DecimalRange do
  alias MsbmsSystDatastore.DbTypes.Impl.DecimalRange

  def bounds_compare(left, right), do: DecimalRange.bounds_compare(left, right)
end

defmodule MsbmsSystDatastore.DbTypes.Impl.DecimalRange do
  alias MsbmsSystDatastore.DbTypes

  @moduledoc false

  def compare(left, right, range \\ :range_both), do: compare_start(left, right, range)

  # TODO: Not priority but think about an alternative implementation that
  #       doesn't chain each function directly into the next as a pipeline would
  #       be more flexible;  not worth re-engineering it just now.

  defp compare_start(%DbTypes.DecimalRange{} = left, %DbTypes.DecimalRange{} = right, range) do
    lower_max_exp = calc_max_exp(left.lower, right.lower)
    upper_max_exp = calc_max_exp(left.upper, right.upper)

    left_lower = calc_lower(left.lower, lower_max_exp, left.lower_inclusive)
    left_upper = calc_upper(left.upper, upper_max_exp, left.upper_inclusive)

    right_lower = calc_lower(right.lower, lower_max_exp, right.lower_inclusive)
    right_upper = calc_upper(right.upper, upper_max_exp, right.upper_inclusive)

    compare_coarse(left_lower, left_upper, right_lower, right_upper, range)
  end

  defp compare_start(%DbTypes.DecimalRange{} = left, %Decimal{} = right, _range) do
    lower_max_exp = calc_max_exp(left.lower, right)
    upper_max_exp = calc_max_exp(left.upper, right)

    left_lower = calc_lower(left.lower, lower_max_exp, left.lower_inclusive)
    left_upper = calc_upper(left.upper, upper_max_exp, left.upper_inclusive)

    compare_coarse(left_lower, left_upper, right, right, :range_left)
  end

  def bounds_compare(%DbTypes.DecimalRange{} = left, %Decimal{} = right) do
    right_range = %DbTypes.DecimalRange{
      lower: right,
      upper: right,
      lower_inclusive: true,
      upper_inclusive: true
    }

    bounds_compare(left, right_range)
  end

  def bounds_compare(%DbTypes.DecimalRange{} = left, %DbTypes.DecimalRange{} = right) do
    lower_max_exp = calc_max_exp(left.lower, right.lower)
    upper_max_exp = calc_max_exp(left.upper, right.upper)

    left_lower = calc_lower(left.lower, lower_max_exp, left.lower_inclusive)
    left_upper = calc_upper(left.upper, upper_max_exp, left.upper_inclusive)

    right_lower = calc_lower(right.lower, lower_max_exp, right.lower_inclusive)
    right_upper = calc_upper(right.upper, upper_max_exp, right.upper_inclusive)

    lower_comparison = Decimal.compare(left_lower, right_lower)
    upper_comparison = Decimal.compare(left_upper, right_upper)

    %{lower_comparison: lower_comparison, upper_comparison: upper_comparison}
  end

  defp calc_max_exp(left, right) when left in [:empty, :unbound] and right in [:empty, :unbound],
    do: 0

  defp calc_max_exp(left, %Decimal{} = right) when left in [:empty, :unbound], do: right.exp
  defp calc_max_exp(%Decimal{} = left, right) when right in [:empty, :unbound], do: left.exp
  defp calc_max_exp(%Decimal{} = left, %Decimal{} = right), do: max(left.exp, right.exp)

  defp calc_lower(value, _exp, _inclusivity) when value in [:empty, :unbound],
    do: Decimal.new(-1, :inf, 0)

  defp calc_lower(value, _exp, true = _inclusivity), do: value

  defp calc_lower(value, exp, false = _inclusivity),
    do: Decimal.add(value, Decimal.new(value.sign, 1, exp))

  defp calc_upper(value, _exp, _inclusivity) when value in [:empty, :unbound],
    do: Decimal.new(1, :inf, 0)

  defp calc_upper(value, _exp, true = _inclusivity), do: value

  defp calc_upper(value, exp, false = _inclusivity),
    do: Decimal.sub(value, Decimal.new(value.sign, 1, exp))

  defp compare_coarse(left_lower, left_upper, right_lower, right_upper, range) do
    cond do
      Decimal.eq?(left_lower, right_lower) and Decimal.eq?(left_upper, right_upper) ->
        equality_kind(range)

      Decimal.gt?(left_lower, right_upper) ->
        :gt

      Decimal.lt?(left_upper, right_lower) ->
        :lt

      true ->
        lower_comparison = Decimal.compare(left_lower, right_lower)
        upper_comparison = Decimal.compare(left_upper, right_upper)

        compare_detail(lower_comparison, upper_comparison)
    end
  end

  defp equality_kind(:range_both = _range), do: :eq
  defp equality_kind(:range_left = _range), do: :lcr
  defp equality_kind(:range_right = _range), do: :rcl

  defp compare_detail(lower, upper) when lower in [:eq, :gt] and upper in [:eq, :lt],
    do: :rcl

  defp compare_detail(lower, upper) when lower in [:eq, :lt] and upper in [:eq, :gt],
    do: :lcr

  defp compare_detail(lower, upper) when lower in [:eq, :gt] and upper == :gt, do: :gto
  defp compare_detail(lower, upper) when lower == :lt and upper in [:eq, :lt], do: :lto

  def test_compare(%DbTypes.DecimalRange{} = left, %DbTypes.DecimalRange{} = right, operator)
      when operator in [:eq, :lt, :gt, :lcr, :rcl, :lto, :gto] do
    compare(left, right) == operator
  end

  def test_compare(%DbTypes.DecimalRange{} = left, %Decimal{} = right, operator)
      when operator in [:lt, :gt, :lcr],
      do: compare(left, right) == operator
end
