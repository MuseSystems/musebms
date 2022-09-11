# Source File: date.ex
# Location:    musebms/components/system/msbms_syst_datastore/lib/db_types/impl/date.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

# The implementation of MsbmsSystDatastore.DbTypes for Date is being done to
# support mixed Date/DateRange comparisons.  For completeness, we'll also
# implement compare and test_compare for Date/Date combinations as well, but the
# Date module functions handle these cases and so the functions defined here
# should only be used in very narrow/limited circumstances.

defimpl MsbmsSystDatastore.DbTypes.Range, for: Date do
  alias MsbmsSystDatastore.DbTypes.Impl

  def compare(left, right), do: Impl.Date.compare(left, right)

  def test_compare(left, right, operator), do: Impl.Date.test_compare(left, right, operator)
end

defmodule MsbmsSystDatastore.DbTypes.Impl.Date do
  alias MsbmsSystDatastore.DbTypes
  alias MsbmsSystDatastore.DbTypes.Impl.DateRange

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

  def test_compare(left, %Date{} = right, operator) when operator in [:eq, :gt, :lt],
    do: compare(left, right) == operator

  def test_compare(left, %DbTypes.DateRange{} = right, operator)
      when operator in [:lt, :gt, :rcl],
      do: compare(left, right) == operator
end
