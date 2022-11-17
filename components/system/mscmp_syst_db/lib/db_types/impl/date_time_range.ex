# Source File: date_time_range.ex
# Location:    musebms/components/system/mscmp_syst_db/lib/db_types/impl/date_time_range.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defimpl MscmpSystDb.DbTypes, for: MscmpSystDb.DbTypes.DateTimeRange do
  alias MscmpSystDb.DbTypes.Impl.DateTimeRange

  def compare(left, right), do: DateTimeRange.compare(left, right)

  def test_compare(left, right, operator), do: DateTimeRange.test_compare(left, right, operator)
end

defimpl MscmpSystDb.DbTypes.Range, for: MscmpSystDb.DbTypes.DateTimeRange do
  alias MscmpSystDb.DbTypes.Impl.DateTimeRange

  def bounds_compare(left, right), do: DateTimeRange.bounds_compare(left, right)
  def lower(range), do: DateTimeRange.lower(range)
  def upper(range), do: DateTimeRange.upper(range)
end

defmodule MscmpSystDb.DbTypes.Impl.DateTimeRange do
  alias MscmpSystDb.DbTypes

  @moduledoc false

  # TODO: These may be candidates to set up as constants.  Right now I'm hoping
  #       that most comparisons needing a date that is earlier/later than all
  #       other dates will only matter in these range comparison scenarios, but
  #       it's not clear really which way that will fall.

  @start_of_time ~U[0000-01-01 00:00:00Z]
  @end_of_time ~U[9999-12-31 23:59:59Z]

  def compare(left, right, range \\ :range_both), do: compare_start(left, right, range)

  # TODO: Not priority but think about an alternative implementation that
  #       doesn't chain each function directly into the next as a pipeline would
  #       be more flexible;  not worth re-engineering it just now.

  defp compare_start(%DbTypes.DateTimeRange{} = left, %DbTypes.DateTimeRange{} = right, range) do
    left_lower = calc_lower(left.lower, left.lower_inclusive)
    left_upper = calc_upper(left.upper, left.upper_inclusive)

    right_lower = calc_lower(right.lower, right.lower_inclusive)
    right_upper = calc_upper(right.upper, right.upper_inclusive)

    compare_coarse(left_lower, left_upper, right_lower, right_upper, range)
  end

  defp compare_start(%DbTypes.DateTimeRange{} = left, %DateTime{} = right, _range) do
    left_lower = calc_lower(left.lower, left.lower_inclusive)
    left_upper = calc_upper(left.upper, left.upper_inclusive)

    compare_coarse(left_lower, left_upper, right, right, :range_left)
  end

  def bounds_compare(%DbTypes.DateTimeRange{} = left, %DateTime{} = right) do
    right_range = %DbTypes.DateTimeRange{
      lower: right,
      upper: right,
      lower_inclusive: true,
      upper_inclusive: true
    }

    bounds_compare(left, right_range)
  end

  def bounds_compare(%DbTypes.DateTimeRange{} = left, %DbTypes.DateTimeRange{} = right) do
    left_lower = calc_lower(left.lower, left.lower_inclusive)
    left_upper = calc_upper(left.upper, left.upper_inclusive)

    right_lower = calc_lower(right.lower, right.lower_inclusive)
    right_upper = calc_upper(right.upper, right.upper_inclusive)

    lower_comparison = DateTime.compare(left_lower, right_lower)
    upper_comparison = DateTime.compare(left_upper, right_upper)

    %{lower_comparison: lower_comparison, upper_comparison: upper_comparison}
  end

  def lower(range), do: calc_lower(range.lower, range.lower_inclusive)
  def upper(range), do: calc_upper(range.upper, range.upper_inclusive)

  defp calc_lower(value, _inclusivity) when value in [:empty, :unbound], do: @start_of_time
  defp calc_lower(value, true = _inclusivity), do: value
  defp calc_lower(value, false = _inclusivity), do: DateTime.add(value, 1)

  defp calc_upper(value, _inclusivity) when value in [:empty, :unbound], do: @end_of_time
  defp calc_upper(value, true = _inclusivity), do: value
  defp calc_upper(value, false = _inclusivity), do: DateTime.add(value, -1)

  defp compare_coarse(left_lower, left_upper, right_lower, right_upper, range) do
    cond do
      DateTime.compare(left_lower, right_lower) == :eq and
          DateTime.compare(left_upper, right_upper) == :eq ->
        equality_kind(range)

      DateTime.compare(left_lower, right_upper) == :gt ->
        :gt

      DateTime.compare(left_upper, right_lower) == :lt ->
        :lt

      true ->
        lower_comparison = DateTime.compare(left_lower, right_lower)
        upper_comparison = DateTime.compare(left_upper, right_upper)

        compare_detail(lower_comparison, upper_comparison)
    end
  end

  defp equality_kind(:range_both = _range), do: :eq
  defp equality_kind(:range_left = _range), do: :lcr
  defp equality_kind(:range_right = _range), do: :rcl

  defp compare_detail(lower, upper) when lower in [:eq, :gt] and upper in [:eq, :lt], do: :rcl
  defp compare_detail(lower, upper) when lower in [:eq, :lt] and upper in [:eq, :gt], do: :lcr
  defp compare_detail(lower, upper) when lower in [:eq, :gt] and upper == :gt, do: :gto
  defp compare_detail(lower, upper) when lower == :lt and upper in [:eq, :lt], do: :lto

  def test_compare(%DbTypes.DateTimeRange{} = left, %DbTypes.DateTimeRange{} = right, operator)
      when operator in [:eq, :lt, :gt, :lcr, :rcl, :lto, :gto] do
    compare(left, right) == operator
  end

  def test_compare(%DbTypes.DateTimeRange{} = left, %DateTime{} = right, operator)
      when operator in [:lt, :gt, :lcr],
      do: compare(left, right) == operator
end