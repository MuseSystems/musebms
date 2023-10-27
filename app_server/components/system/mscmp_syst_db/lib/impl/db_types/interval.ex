# Source File: interval.ex
# Location:    musebms/app_server/components/system/mscmp_syst_db/lib/impl/db_types/interval.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defimpl MscmpSystDb.DbTypes, for: MscmpSystDb.DbTypes.Interval do
  alias MscmpSystDb.Impl.DbTypes.Interval

  def compare(left, right), do: Interval.compare(left, right)

  def test_compare(left, right, operator), do: Interval.test_compare(left, right, operator)
end

defimpl String.Chars, for: MscmpSystDb.DbTypes.Interval do
  alias MscmpSystDb.Impl.DbTypes.Interval

  def to_string(interval), do: Interval.to_string(interval)
end

defmodule MscmpSystDb.Impl.DbTypes.Interval do
  @moduledoc false

  alias MscmpSystDb.DbTypes
  alias MscmpSystDb.Types

  def compare(left, right) do
    postgrex_left =
      left
      |> Map.from_struct()
      |> then(&struct(Postgrex.Interval, &1))

    postgrex_right =
      right
      |> Map.from_struct()
      |> then(&struct(Postgrex.Interval, &1))

    Postgrex.Interval.compare(postgrex_left, postgrex_right)
  end

  def test_compare(left, right, operator) when operator in [:eq, :lt, :gt] do
    compare(left, right) == operator
  end

  def to_string(interval) do
    interval
    |> Map.filter(fn {_key, value} ->
      if is_integer(value) and value > 0, do: true, else: false
    end)
    |> build_interval_string()
    |> Enum.join(", ")
  end

  defp build_interval_string(stripped_interval) do
    []
    |> maybe_add_microsecs(stripped_interval)
    |> maybe_add_secs(stripped_interval)
    |> maybe_add_days(stripped_interval)
    |> maybe_add_months(stripped_interval)
    |> maybe_add_instantaneous()
  end

  defp maybe_add_months(string_list, %{months: 1}), do: ["1 month" | string_list]
  defp maybe_add_months(string_list, %{months: months}), do: ["#{months} months" | string_list]
  defp maybe_add_months(string_list, _), do: string_list

  defp maybe_add_days(string_list, %{days: 1}), do: ["1 day" | string_list]
  defp maybe_add_days(string_list, %{days: days}), do: ["#{days} days" | string_list]
  defp maybe_add_days(string_list, _), do: string_list

  defp maybe_add_secs(string_list, %{secs: 1}), do: ["1 second" | string_list]
  defp maybe_add_secs(string_list, %{secs: secs}), do: ["#{secs} seconds" | string_list]
  defp maybe_add_secs(string_list, _), do: string_list

  defp maybe_add_microsecs(string_list, %{microsecs: 1}), do: ["1 microsecond" | string_list]

  defp maybe_add_microsecs(string_list, %{microsecs: microsecs}),
    do: ["#{microsecs} microseconds" | string_list]

  defp maybe_add_microsecs(string_list, _), do: string_list

  defp maybe_add_instantaneous([]), do: ["instantaneous"]
  defp maybe_add_instantaneous(string_list), do: string_list

  @spec to_timex_shift_options(DbTypes.Interval.t()) :: Types.timex_shift_options()
  def to_timex_shift_options(%DbTypes.Interval{} = interval) do
    [
      months: interval.months,
      days: interval.days,
      seconds: interval.secs,
      microseconds: interval.microsecs
    ]
    |> Keyword.filter(fn {_key, value} -> value != 0 end)
  end
end
