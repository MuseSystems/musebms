# Source File: db_types.ex
# Location:    components/system/msbms_syst_datastore/lib/impl/db_types.ex
# Project:     msbms
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https: //muse.systems

defmodule MsbmsSystDatastore.Impl.DbTypes.Interval do
  use Ecto.Type

  @moduledoc """
  Provides application types which map to specific database types.
  """

  @type t :: %__MODULE__{
          months: integer(),
          days: integer(),
          seconds: integer(),
          microseconds: integer()
        }

  defstruct months: 0, days: 0, seconds: 0, microseconds: 0

  @spec type :: :interval
  @impl true
  def type, do: :interval

  @spec cast(any()) :: {:ok, t()} | :error
  @impl true
  def cast(%__MODULE__{} = value), do: {:ok, value}
  def cast(_), do: :error

  @spec load(any()) :: {:ok, t()} | :error
  @impl true
  def load(%Postgrex.Interval{months: months, days: days, secs: secs, microsecs: microsecs}) do
    {:ok, %__MODULE__{months: months, days: days, seconds: secs, microseconds: microsecs}}
  end

  def load(_), do: :error

  @spec dump(t()) :: {:ok, Postgrex.Interval.t()} | :error
  @impl true
  def dump(%__MODULE__{months: months, days: days, seconds: seconds, microseconds: microseconds}) do
    {:ok, %Postgrex.Interval{months: months, days: days, secs: seconds, microsecs: microseconds}}
  end

  def dump(_), do: :error
end
