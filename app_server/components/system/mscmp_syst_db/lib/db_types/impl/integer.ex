# Source File: integer.ex
# Location:    musebms/components/system/mscmp_syst_db/lib/db_types/impl/integer.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

# The implementation of MscmpSystDb.DbTypes for Integer is being done to
# support mixed Integer/IntegerRange comparisons.  For completeness, we'll also
# implement compare and test_compare for Integer/Integer combinations as well,
# but the normal operators handle these cases and should only be used in very
# narrow/limited circumstances.

defimpl MscmpSystDb.DbTypes, for: Integer do
  alias MscmpSystDb.DbTypes.Impl

  def compare(left, right), do: Impl.Integer.compare(left, right)

  def test_compare(left, right, operator), do: Impl.Integer.test_compare(left, right, operator)
end

defimpl MscmpSystDb.DbTypes.Range, for: Integer do
  alias MscmpSystDb.DbTypes.Impl

  def bounds_compare(left, right), do: Impl.Integer.bounds_compare(left, right)
  def upper(value), do: value
  def lower(value), do: value
end

defmodule MscmpSystDb.DbTypes.Impl.Integer do
  @moduledoc false

  alias MscmpSystDb.DbTypes
  alias MscmpSystDb.DbTypes.Impl.IntegerRange

  def compare(left, right) when is_integer(left) and is_integer(right) and left == right, do: :eq
  def compare(left, right) when is_integer(left) and is_integer(right) and left > right, do: :gt
  def compare(left, right) when is_integer(left) and is_integer(right) and left < right, do: :lt

  def compare(left, %DbTypes.IntegerRange{} = right) when is_integer(left) do
    left_range = %DbTypes.IntegerRange{
      lower: left,
      upper: left,
      lower_inclusive: true,
      upper_inclusive: true
    }

    IntegerRange.compare(left_range, right, :range_right)
  end

  def bounds_compare(left, %DbTypes.IntegerRange{} = right) when is_integer(left) do
    left_range = %DbTypes.IntegerRange{
      lower: left,
      upper: left,
      lower_inclusive: true,
      upper_inclusive: true
    }

    IntegerRange.bounds_compare(left_range, right)
  end

  def test_compare(left, right, operator)
      when is_integer(left) and is_integer(right) and operator in [:eq, :gt, :lt],
      do: compare(left, right) == operator

  def test_compare(left, %DbTypes.IntegerRange{} = right, operator)
      when is_integer(left) and operator in [:lt, :gt, :rcl],
      do: compare(left, right) == operator
end
