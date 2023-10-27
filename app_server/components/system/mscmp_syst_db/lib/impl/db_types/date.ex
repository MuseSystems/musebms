# Source File: date.ex
# Location:    musebms/app_server/components/system/mscmp_syst_db/lib/impl/db_types/date.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

# The implementation of MscmpSystDb.DbTypes for Date is being done to
# support mixed Date/DateRange comparisons.  For completeness, we'll also
# implement compare and test_compare for Date/Date combinations as well, but the
# Date module functions handle these cases and so the functions defined here
# should only be used in very narrow/limited circumstances.

defimpl MscmpSystDb.DbTypes, for: Date do
  alias MscmpSystDb.Impl.DbTypes.Date

  def compare(left, right), do: Date.compare(left, right)

  def test_compare(left, right, operator), do: Date.test_compare(left, right, operator)
end

defimpl MscmpSystDb.DbTypes.Range, for: Date do
  alias MscmpSystDb.Impl.DbTypes.Date

  def bounds_compare(left, right), do: Date.bounds_compare(left, right)
  def upper(value), do: value
  def lower(value), do: value
end

defmodule MscmpSystDb.Impl.DbTypes.Date do
  @moduledoc false

  alias MscmpSystDb.DbTypes
  alias MscmpSystDb.Impl.DbTypes.DateRange

  def compare(left, %Date{} = right), do: Date.compare(left, right)

  def compare(left, %DbTypes.DateRange{} = right) do
    left_range = %DbTypes.DateRange{
      lower: left,
      upper: left,
      lower_inclusive: true,
      upper_inclusive: true
    }

    DateRange.compare(left_range, right, :range_right)
  end

  def bounds_compare(left, %DbTypes.DateRange{} = right) do
    left_range = %DbTypes.DateRange{
      lower: left,
      upper: left,
      lower_inclusive: true,
      upper_inclusive: true
    }

    DateRange.bounds_compare(left_range, right)
  end

  def test_compare(left, %Date{} = right, operator) when operator in [:eq, :gt, :lt],
    do: compare(left, right) == operator

  def test_compare(left, %DbTypes.DateRange{} = right, operator)
      when operator in [:lt, :gt, :rcl],
      do: compare(left, right) == operator
end
