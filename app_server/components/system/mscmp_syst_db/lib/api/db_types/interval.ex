# Source File: interval.ex
# Location:    musebms/app_server/components/system/mscmp_syst_db/lib/api/db_types/interval.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystDb.DbTypes.Interval do
  @moduledoc """
  An Elixir representation of the PostgreSQL `interval` data type.

  Derived from the Postgrex.Interval data type.  For more information about this
  data type, see: [The PostgreSQL Documentation: Date/Time Types](https://www.postgresql.org/docs/current/datatype-datetime.html#DATATYPE-INTERVAL-INPUT)
  """
  use Ecto.Type

  alias MscmpSystDb.Impl.DbTypes.Interval
  alias MscmpSystDb.Types

  defstruct months: 0, days: 0, secs: 0, microsecs: 0

  @type t :: %__MODULE__{
          months: integer(),
          days: integer(),
          secs: integer(),
          microsecs: integer()
        }

  @spec type :: :interval
  @impl true
  @doc false
  def type, do: :interval

  @spec cast(any()) :: {:ok, t()} | :error
  @impl true
  @doc false
  def cast(%__MODULE__{} = value), do: {:ok, value}
  def cast(_), do: :error

  @spec load(any()) :: {:ok, t()} | :error
  @impl true
  @doc false
  def load(%Postgrex.Interval{months: months, days: days, secs: secs, microsecs: microsecs}) do
    {:ok, %__MODULE__{months: months, days: days, secs: secs, microsecs: microsecs}}
  end

  def load(_), do: :error

  @spec dump(t()) :: {:ok, Postgrex.Interval.t()} | :error
  @impl true
  @doc false
  def dump(%__MODULE__{months: months, days: days, secs: secs, microsecs: microsecs}) do
    {:ok, %Postgrex.Interval{months: months, days: days, secs: secs, microsecs: microsecs}}
  end

  def dump(_), do: :error

  @spec to_timex_shift_options(t()) :: Types.timex_shift_options()
  @doc """
  Converts an Interval into a form that can be used by the `Timex` library's
  `Timex.shift/2` function.

  ## Example

      iex> example_interval =
      ...>   %MscmpSystDb.DbTypes.Interval{months: 1, days: 1, secs: 1, microsecs: 1}
      iex> MscmpSystDb.DbTypes.Interval.to_timex_shift_options(example_interval)
      [months: 1, days: 1, seconds: 1, microseconds: 1]
  """
  defdelegate to_timex_shift_options(interval), to: Interval
end
