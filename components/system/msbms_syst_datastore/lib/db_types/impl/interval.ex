# Source File: interval.ex
# Location:    musebms/components/system/msbms_syst_datastore/lib/db_types/impl/interval.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defimpl MsbmsSystDatastore.DbTypes.Range, for: MsbmsSystDatastore.DbTypes.Interval do
  alias MsbmsSystDatastore.DbTypes.Impl.Interval

  def compare(left, right), do: Interval.compare(left, right)

  def test_compare(left, right, operator), do: Interval.test_compare(left, right, operator)
end

defmodule MsbmsSystDatastore.DbTypes.Impl.Interval do
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
end
