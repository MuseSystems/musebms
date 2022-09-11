# Source File: date_time.ex
# Location:    musebms/components/system/msbms_syst_datastore/lib/db_types/impl/date_time.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

# The implementation of MsbmsSystDatastore.DbTypes for DateTime is being done to
# support mixed DateTime/Timestamp comparisons.  For completeness, we'll also
# implement compare and test_compare for DateTime/DateTime combinations as well, but the
# DateTime module functions handle these cases and so the functions defined here
# should only be used in very narrow/limited circumstances.

defimpl MsbmsSystDatastore.DbTypes.Range, for: DateTime do
  alias MsbmsSystDatastore.DbTypes.Impl

  def compare(left, right), do: Impl.DateTime.compare(left, right)

  def test_compare(left, right, operator),
    do: Impl.DateTime.test_compare(left, right, operator)
end

defmodule MsbmsSystDatastore.DbTypes.Impl.DateTime do
  alias MsbmsSystDatastore.DbTypes
  alias MsbmsSystDatastore.DbTypes.Impl.DateTimeRange

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

  def test_compare(left, %DateTime{} = right, operator) when operator in [:eq, :gt, :lt],
    do: compare(left, right) == operator

  def test_compare(left, %DbTypes.DateTimeRange{} = right, operator)
      when operator in [:lt, :gt, :rcl],
      do: compare(left, right) == operator
end
