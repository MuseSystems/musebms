# Source File: db_types.ex
# Location:    musebms/components/system/mscmp_syst_db/lib/db_types.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defprotocol MscmpSystDb.DbTypes do
  @moduledoc """
  Defines the common functions which should be implemented for all custom
  DbTypes implemented in MscmpSystDb.
  """

  alias MscmpSystDb.Types

  @doc """
  Compares two values and returns the effective operating describing the
  relationship.

  # Parameters

    * `left` - a range type or base type for use in the comparison which would
    be the left side when used with an infix operator such as `>`.

    * `right` - a range type or base type for use in the comparison which would
    be the right side when used with an infix operator such as `>`.

  # Examples

  Comparing two ranges where the left and right overlap, but the left side is
  less than the right (returns "Less Than Overlapping").

      iex> left_range =
      ...>   %MscmpSystDb.DbTypes.IntegerRange{
      ...>     lower: 10,
      ...>     upper: 100
      ...>   }
      iex> right_range =
      ...>   %MscmpSystDb.DbTypes.IntegerRange{
      ...>     lower: 20,
      ...>     upper: 200
      ...>   }
      iex> MscmpSystDb.DbTypes.compare(left_range, right_range)
      :lto

  Comparing a range and a base type value where the range contains the base
  type value (returns "Left Contains Right").

      iex> left_range =
      ...>   %MscmpSystDb.DbTypes.IntegerRange{
      ...>     lower: 10,
      ...>     upper: 100
      ...>   }
      iex> MscmpSystDb.DbTypes.compare(left_range, 50)
      :lcr

  Comparing interval base types where the left is less than the right (returns
  "Less Than")

      iex> left_interval =
      ...>   %MscmpSystDb.DbTypes.Interval{
      ...>     days: 1
      ...>   }
      iex> right_interval =
      ...>   %MscmpSystDb.DbTypes.Interval{
      ...>     months: 1
      ...>   }
      iex> MscmpSystDb.DbTypes.compare(left_interval, right_interval)
      :lt
  """
  @spec compare(t, t) :: Types.db_type_comparison_operators()
  def(compare(left, right))

  @doc """
  Compares two values and tests the resulting effective operator against that
  supplied by the user returning `true` or `false`.

  # Parameters

    * `left` - a range type or base type for use in the comparison which would
    be the left side when used with an infix operator such as `>`.

    * `right` - a range type or base type for use in the comparison which would
    be the right side when used with an infix operator such as `>`.

    * `operator` - the desired operator to test.

  # Examples

  Comparing two ranges where the left and right overlap, but the left side is
  less than the right.  In this case we match the desired "Less Than
  Overlapping" operator resulting in a return value of `true`.

      iex> left_range =
      ...>   %MscmpSystDb.DbTypes.IntegerRange{
      ...>     lower: 10,
      ...>     upper: 100
      ...>   }
      iex> right_range =
      ...>   %MscmpSystDb.DbTypes.IntegerRange{
      ...>     lower: 20,
      ...>     upper: 200
      ...>   }
      iex> MscmpSystDb.DbTypes.test_compare(left_range, right_range, :lto)
      true


  Comparing a range and a base type value where the range contains the base
  type value, but the desired operator is "Greater Than" which does not match
  resulting in a return value of `false`.

      iex> left_range =
      ...>   %MscmpSystDb.DbTypes.IntegerRange{
      ...>     lower: 10,
      ...>     upper: 100
      ...>   }
      iex> MscmpSystDb.DbTypes.test_compare(left_range, 50, :gt)
      false

  Comparing interval base types where the intervals are equal and testing for
  equality resulting a `true` result.

      iex> left_interval =
      ...>   %MscmpSystDb.DbTypes.Interval{
      ...>     secs: 100
      ...>   }
      iex> right_interval =
      ...>   %MscmpSystDb.DbTypes.Interval{
      ...>     secs: 100
      ...>   }
      iex> MscmpSystDb.DbTypes.test_compare(left_interval, right_interval, :eq)
      true
  """
  @spec test_compare(t, t, Types.db_type_comparison_operators()) :: boolean()
  def(test_compare(left, right, operator))
end
