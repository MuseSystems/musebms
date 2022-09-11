# Source File: integer_range.ex
# Location:    musebms/components/system/msbms_syst_datastore/lib/db_types/impl/integer_range.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defimpl MsbmsSystDatastore.DbTypes.Range, for: MsbmsSystDatastore.DbTypes.IntegerRange do
  alias MsbmsSystDatastore.DbTypes.Impl.IntegerRange

  def compare(left, right), do: IntegerRange.compare(left, right)

  def test_compare(left, right, operator), do: IntegerRange.test_compare(left, right, operator)
end

defmodule MsbmsSystDatastore.DbTypes.Impl.IntegerRange do
  alias MsbmsSystDatastore.DbTypes

  def compare(left, right, range \\ :range_both), do: compare_start(left, right, range)

  # TODO: Not priority but think about an alternative implementation that
  #       doesn't chain each function directly into the next as a pipeline would
  #       be more flexible;  not worth re-engineering it just now.

  defp compare_start(%DbTypes.IntegerRange{} = left, %DbTypes.IntegerRange{} = right, range) do
    left_lower = calc_lower(left.lower, left.lower_inclusive)
    left_upper = calc_upper(left.upper, left.upper_inclusive)

    right_lower = calc_lower(right.lower, right.lower_inclusive)
    right_upper = calc_upper(right.upper, right.upper_inclusive)

    compare_coarse(left_lower, left_upper, right_lower, right_upper, range)
  end

  defp compare_start(%DbTypes.IntegerRange{} = left, right, _range) when is_integer(right) do
    left_lower = calc_lower(left.lower, left.lower_inclusive)
    left_upper = calc_upper(left.upper, left.upper_inclusive)

    compare_coarse(left_lower, left_upper, right, right, :range_left)
  end

  defp calc_lower(value, _inclusivity) when value in [:empty, :unbound], do: :unbound
  defp calc_lower(value, true = _inclusivity), do: value
  defp calc_lower(value, false = _inclusivity), do: value + 1

  defp calc_upper(value, _inclusivity) when value in [:empty, :unbound], do: :unbound
  defp calc_upper(value, true = _inclusivity), do: value
  defp calc_upper(value, false = _inclusivity), do: value - 1

  defp compare_coarse(left_lower, left_upper, right_lower, right_upper, range)
       when left_lower == right_lower and left_upper == right_upper,
       do: equality_kind(range)

  defp compare_coarse(left_lower, _left_upper, _right_lower, right_upper, _range)
       when is_integer(left_lower) and is_integer(right_upper) and left_lower > right_upper,
       do: :gt

  defp compare_coarse(_left_lower, left_upper, right_lower, _right_upper, _range)
       when is_integer(left_upper) and is_integer(right_lower) and left_upper < right_lower,
       do: :lt

  defp compare_coarse(left_lower, left_upper, right_lower, right_upper, _range) do
    lower_comparison = compare_lower(left_lower, right_lower)
    upper_comparison = compare_upper(left_upper, right_upper)

    compare_detail(lower_comparison, upper_comparison)
  end

  defp equality_kind(:range_both = _range), do: :eq
  defp equality_kind(:range_left = _range), do: :lcr
  defp equality_kind(:range_right = _range), do: :rcl

  defp compare_lower(left, right) when left == right, do: :eq

  defp compare_lower(left, right) when left == :unbound or (is_integer(right) and left < right),
    do: :lt

  defp compare_lower(left, right) when right == :unbound or (is_integer(left) and left > right),
    do: :gt

  defp compare_upper(left, right) when left == right, do: :eq

  defp compare_upper(left, right) when left == :unbound or (is_integer(right) and left > right),
    do: :gt

  defp compare_upper(left, right) when right == :unbound or (is_integer(left) and left < right),
    do: :lt

  defp compare_detail(lower, upper) when lower in [:eq, :gt] and upper in [:eq, :lt],
    do: :rcl

  defp compare_detail(lower, upper) when lower in [:eq, :lt] and upper in [:eq, :gt],
    do: :lcr

  defp compare_detail(lower, upper) when lower in [:eq, :gt] and upper == :gt, do: :gto
  defp compare_detail(lower, upper) when lower == :lt and upper in [:eq, :lt], do: :lto

  def test_compare(%DbTypes.IntegerRange{} = left, %DbTypes.IntegerRange{} = right, operator)
      when operator in [:eq, :lt, :gt, :lcr, :rcl, :lto, :gto] do
    compare(left, right) == operator
  end

  def test_compare(%DbTypes.IntegerRange{} = left, right, operator)
      when is_integer(right) and operator in [:lt, :gt, :lcr],
      do: compare(left, right) == operator
end
