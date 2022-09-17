# Source File: decimal.ex
# Location:    musebms/components/system/msbms_syst_datastore/lib/db_types/impl/decimal.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

# The implementation of MsbmsSystDatastore.DbTypes for Decimal is being done to
# support mixed Decimal/DecimalRange comparisons.  For completeness, we'll also
# implement compare and test_compare for Decimal/Decimal combinations as well,
# but the Decimal module functions handle these cases and so the functions
# defined here should only be used in very narrow/limited circumstances.

defimpl MsbmsSystDatastore.DbTypes, for: Decimal do
  alias MsbmsSystDatastore.DbTypes.Impl

  def compare(left, right), do: Impl.Decimal.compare(left, right)

  def test_compare(left, right, operator), do: Impl.Decimal.test_compare(left, right, operator)
end

defimpl MsbmsSystDatastore.DbTypes.Range, for: Decimal do
  alias MsbmsSystDatastore.DbTypes.Impl

  def bounds_compare(left, right), do: Impl.Decimal.bounds_compare(left, right)
  def upper(value), do: value
  def lower(value), do: value
end

defmodule MsbmsSystDatastore.DbTypes.Impl.Decimal do
  alias MsbmsSystDatastore.DbTypes
  alias MsbmsSystDatastore.DbTypes.Impl.DecimalRange

  @moduledoc false

  def compare(left, %Decimal{} = right), do: Decimal.compare(left, right)

  def compare(left, %DbTypes.DecimalRange{} = right) do
    left_range = %DbTypes.DecimalRange{
      lower: left,
      upper: left,
      lower_inclusive: true,
      upper_inclusive: true
    }

    DecimalRange.compare(left_range, right, :range_right)
  end

  def bounds_compare(left, %DbTypes.DecimalRange{} = right) do
    left_range = %DbTypes.DecimalRange{
      lower: left,
      upper: left,
      lower_inclusive: true,
      upper_inclusive: true
    }

    DecimalRange.bounds_compare(left_range, right)
  end

  def test_compare(left, %Decimal{} = right, operator) when operator in [:eq, :gt, :lt],
    do: compare(left, right) == operator

  def test_compare(left, %DbTypes.DecimalRange{} = right, operator)
      when operator in [:lt, :gt, :rcl],
      do: compare(left, right) == operator
end
