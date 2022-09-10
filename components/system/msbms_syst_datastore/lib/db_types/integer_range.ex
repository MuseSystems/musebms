# Source File: integer_range.ex
# Location:    musebms/components/system/msbms_syst_datastore/lib/db_types/integer_range.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MsbmsSystDatastore.DbTypes.IntegerRange do
  use Ecto.Type

  @moduledoc """
  An Elixir representation of the PostgreSQL `int8range` data type.

  Derived from the Postgrex.Range data type.  For more information about this
  data type, see: [The PostgreSQL Documentation: Range Types](https://www.postgresql.org/docs/current/rangetypes.html)
  """

  @type t :: %__MODULE__{
          lower: integer() | :empty | :unbound,
          upper: integer() | :empty | :unbound,
          lower_inclusive: boolean,
          upper_inclusive: boolean
        }

  defstruct lower: :empty, upper: :empty, lower_inclusive: true, upper_inclusive: false

  @spec type :: :integerrange
  @impl true
  @doc false
  def type, do: :integerrange

  @spec cast(any()) :: {:ok, t()} | :error
  @impl true
  @doc false
  def cast(%__MODULE__{} = value), do: {:ok, value}
  def cast(_), do: :error

  @spec load(any()) :: {:ok, t()} | :error
  @impl true
  @doc false
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
  @doc false
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
