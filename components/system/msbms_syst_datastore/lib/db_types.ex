# Source File: db_types.ex
# Location:    components/system/msbms_syst_datastore/lib/db_types.ex
# Project:     msbms
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https: //muse.systems

Postgrex.Types.define(MsbmsSystDatastore.DbTypes.PostgrexTypes, [],
  allow_infinite_timestamps: true
)

defmodule MsbmsSystDatastore.DbTypes.Interval do
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

defmodule MsbmsSystDatastore.DbTypes.IntegerRange do
  use Ecto.Type

  @type t :: %__MODULE__{
          lower: integer() | :empty | :unbound,
          upper: integer() | :empty | :unbound,
          lower_inclusive: boolean,
          upper_inclusive: boolean
        }

  defstruct lower: :empty, upper: :empty, lower_inclusive: true, upper_inclusive: false

  @spec type :: :integerrange
  @impl true
  def type, do: :integerrange

  @spec cast(any()) :: {:ok, t()} | :error
  @impl true
  def cast(%__MODULE__{} = value), do: {:ok, value}
  def cast(_), do: :error

  @spec load(any()) :: {:ok, t()} | :error
  @impl true
  def load(%Postgrex.Range{
        lower: lower,
        upper: upper,
        lower_inclusive: low_inclusive,
        upper_inclusive: upper_inclusive
      }) do
    {:ok,
     %__MODULE__{
       lower: lower,
       upper: upper,
       lower_inclusive: low_inclusive,
       upper_inclusive: upper_inclusive
     }}
  end

  def load(_), do: :error

  @spec dump(t()) :: {:ok, Postgrex.Range.t()} | :error
  @impl true
  def dump(%__MODULE__{
        lower: lower,
        upper: upper,
        lower_inclusive: low_inclusive,
        upper_inclusive: upper_inclusive
      }) do
    {:ok,
     %Postgrex.Range{
       lower: lower,
       upper: upper,
       lower_inclusive: low_inclusive,
       upper_inclusive: upper_inclusive
     }}
  end

  def dump(_), do: :error
end

defmodule MsbmsSystDatastore.DbTypes.DecimalRange do
  use Ecto.Type

  @type t :: %__MODULE__{
          lower: Decimal.t() | :empty | :unbound,
          upper: Decimal.t() | :empty | :unbound,
          lower_inclusive: boolean,
          upper_inclusive: boolean
        }

  defstruct lower: :empty, upper: :empty, lower_inclusive: true, upper_inclusive: false

  @spec type :: :decimalrange
  @impl true
  def type, do: :decimalrange

  @spec cast(any()) :: {:ok, t()} | :error
  @impl true
  def cast(%__MODULE__{} = value), do: {:ok, value}
  def cast(_), do: :error

  @spec load(any()) :: {:ok, t()} | :error
  @impl true
  def load(%Postgrex.Range{
        lower: lower,
        upper: upper,
        lower_inclusive: low_inclusive,
        upper_inclusive: upper_inclusive
      }) do
    {:ok,
     %__MODULE__{
       lower: lower,
       upper: upper,
       lower_inclusive: low_inclusive,
       upper_inclusive: upper_inclusive
     }}
  end

  def load(_), do: :error

  @spec dump(t()) :: {:ok, Postgrex.Range.t()} | :error
  @impl true
  def dump(%__MODULE__{
        lower: lower,
        upper: upper,
        lower_inclusive: low_inclusive,
        upper_inclusive: upper_inclusive
      }) do
    {:ok,
     %Postgrex.Range{
       lower: lower,
       upper: upper,
       lower_inclusive: low_inclusive,
       upper_inclusive: upper_inclusive
     }}
  end

  def dump(_), do: :error
end

defmodule MsbmsSystDatastore.DbTypes.DateRange do
  use Ecto.Type

  @type t :: %__MODULE__{
          lower: Date.t() | :empty | :unbound,
          upper: Date.t() | :empty | :unbound,
          lower_inclusive: boolean,
          upper_inclusive: boolean
        }

  defstruct lower: :empty, upper: :empty, lower_inclusive: true, upper_inclusive: false

  @spec type :: :daterange
  @impl true
  def type, do: :daterange

  @spec cast(any()) :: {:ok, t()} | :error
  @impl true
  def cast(%__MODULE__{} = value), do: {:ok, value}
  def cast(_), do: :error

  @spec load(any()) :: {:ok, t()} | :error
  @impl true
  def load(%Postgrex.Range{
        lower: lower,
        upper: upper,
        lower_inclusive: low_inclusive,
        upper_inclusive: upper_inclusive
      }) do
    {:ok,
     %__MODULE__{
       lower: lower,
       upper: upper,
       lower_inclusive: low_inclusive,
       upper_inclusive: upper_inclusive
     }}
  end

  def load(_), do: :error

  @spec dump(t()) :: {:ok, Postgrex.Range.t()} | :error
  @impl true
  def dump(%__MODULE__{
        lower: lower,
        upper: upper,
        lower_inclusive: low_inclusive,
        upper_inclusive: upper_inclusive
      }) do
    {:ok,
     %Postgrex.Range{
       lower: lower,
       upper: upper,
       lower_inclusive: low_inclusive,
       upper_inclusive: upper_inclusive
     }}
  end

  def dump(_), do: :error
end

defmodule MsbmsSystDatastore.DbTypes.TimestampRange do
  use Ecto.Type

  @type t :: %__MODULE__{
          lower: DateTime.t() | :empty | :unbound,
          upper: DateTime.t() | :empty | :unbound,
          lower_inclusive: boolean,
          upper_inclusive: boolean
        }

  defstruct lower: :empty, upper: :empty, lower_inclusive: true, upper_inclusive: false

  @spec type :: :timestamprange
  @impl true
  def type, do: :timestamprange

  @spec cast(any()) :: {:ok, t()} | :error
  @impl true
  def cast(%__MODULE__{} = value), do: {:ok, value}
  def cast(_), do: :error

  @spec load(any()) :: {:ok, t()} | :error
  @impl true
  def load(%Postgrex.Range{
        lower: lower,
        upper: upper,
        lower_inclusive: low_inclusive,
        upper_inclusive: upper_inclusive
      }) do
    {:ok,
     %__MODULE__{
       lower: lower,
       upper: upper,
       lower_inclusive: low_inclusive,
       upper_inclusive: upper_inclusive
     }}
  end

  def load(_), do: :error

  @spec dump(t()) :: {:ok, Postgrex.Range.t()} | :error
  @impl true
  def dump(%__MODULE__{
        lower: lower,
        upper: upper,
        lower_inclusive: low_inclusive,
        upper_inclusive: upper_inclusive
      }) do
    {:ok,
     %Postgrex.Range{
       lower: lower,
       upper: upper,
       lower_inclusive: low_inclusive,
       upper_inclusive: upper_inclusive
     }}
  end

  def dump(_), do: :error
end
