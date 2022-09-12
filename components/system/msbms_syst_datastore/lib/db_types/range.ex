# Source File: range.ex
# Location:    musebms/components/system/msbms_syst_datastore/lib/db_types/range.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defprotocol MsbmsSystDatastore.DbTypes.Range do
  alias MsbmsSystDatastore.Types

  @moduledoc """
  Defines the common functions which should be implemented for all database
  range types.
  """

  @doc """
  Compares a range with either a range or related base type and returns a map
  indicating the applicable comparison operator for the lower and upper bound
  of the range.

  ## Examples

  Comparing two ranges where both the lower and upper values of the left range
  are less than the corresponding values of the right side.

      iex> left_range =
      ...>   %MsbmsSystDatastore.DbTypes.IntegerRange{
      ...>     lower: 10,
      ...>     upper: 100
      ...>   }
      iex> right_range =
      ...>   %MsbmsSystDatastore.DbTypes.IntegerRange{
      ...>     lower: 20,
      ...>     upper: 200
      ...>   }
      iex> MsbmsSystDatastore.DbTypes.Range.bounds_compare(left_range, right_range)
      %{lower_comparison: :lt, upper_comparison: :lt}


  Comparing a range value on the left side with a base value on the right. In
  this case the left side value is less than the right side value, but
  equal to the upper left side value.

      iex> left_range =
      ...>   %MsbmsSystDatastore.DbTypes.IntegerRange{
      ...>     lower: 10,
      ...>     upper: 100,
      ...>     upper_inclusive: false
      ...>   }
      iex> MsbmsSystDatastore.DbTypes.Range.bounds_compare(left_range, 99)
      %{lower_comparison: :lt, upper_comparison: :eq}

  Comparing two ranges where the right side range is contained by the left side
  range.  The left side lower bound is less than the right side lower bound and
  the left side upper bound is greater than the right side upper bound.

      iex> left_range =
      ...>   %MsbmsSystDatastore.DbTypes.IntegerRange{
      ...>     lower: 10,
      ...>     upper: 100,
      ...>     upper_inclusive: false
      ...>   }
      iex> right_range =
      ...>   %MsbmsSystDatastore.DbTypes.IntegerRange{
      ...>     lower: 20,
      ...>     upper: 50
      ...>   }
      iex> MsbmsSystDatastore.DbTypes.Range.bounds_compare(left_range, right_range)
      %{lower_comparison: :lt, upper_comparison: :gt}
  """
  @spec bounds_compare(any(), any()) :: Types.bounds_compare_result()
  def(bounds_compare(left, right))
end
