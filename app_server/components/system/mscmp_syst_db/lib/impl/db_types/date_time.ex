# Source File: date_time.ex
# Location:    musebms/app_server/components/system/mscmp_syst_db/lib/impl/db_types/date_time.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

# The implementation of MscmpSystDb.DbTypes for DateTime is being done to
# support mixed DateTime/Timestamp comparisons.  For completeness, we'll also
# implement compare and test_compare for DateTime/DateTime combinations as well, but the
# DateTime module functions handle these cases and so the functions defined here
# should only be used in very narrow/limited circumstances.

defimpl MscmpSystDb.DbTypes, for: DateTime do
  alias MscmpSystDb.Impl.DbTypes.DateTime

  def compare(left, right), do: DateTime.compare(left, right)

  def test_compare(left, right, operator), do: DateTime.test_compare(left, right, operator)
end

defimpl MscmpSystDb.DbTypes.Range, for: DateTime do
  alias MscmpSystDb.Impl.DbTypes.DateTime

  def bounds_compare(left, right), do: DateTime.bounds_compare(left, right)
  def upper(value), do: value
  def lower(value), do: value
end

defmodule MscmpSystDb.Impl.DbTypes.DateTime do
  @moduledoc false

  alias MscmpSystDb.DbTypes
  alias MscmpSystDb.Impl.DbTypes.DateTimeRange

  def compare(left, %DateTime{} = right), do: DateTime.compare(left, right)

  def compare(left, %DbTypes.DateTimeRange{} = right) do
    left_range = %DbTypes.DateTimeRange{
      lower: left,
      upper: left,
      lower_inclusive: true,
      upper_inclusive: true
    }

    DateTimeRange.compare(left_range, right, :range_right)
  end

  def bounds_compare(left, %DbTypes.DateTimeRange{} = right) do
    left_range = %DbTypes.DateTimeRange{
      lower: left,
      upper: left,
      lower_inclusive: true,
      upper_inclusive: true
    }

    DateTimeRange.bounds_compare(left_range, right)
  end

  def test_compare(left, %DateTime{} = right, operator) when operator in [:eq, :gt, :lt],
    do: compare(left, right) == operator

  def test_compare(left, %DbTypes.DateTimeRange{} = right, operator)
      when operator in [:lt, :gt, :rcl],
      do: compare(left, right) == operator
end
