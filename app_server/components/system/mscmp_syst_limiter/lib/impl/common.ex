# Source File: common.ex
# Location:    musebms/app_server/components/system/mscmp_syst_limiter/lib/impl/common.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystLimiter.Impl.Common do
  @moduledoc false

  alias MscmpSystError.Types, as: ErrorTypes
  alias MscmpSystLimiter.Types

  @time_scale_codes %{
    1 => :millisecond,
    2 => :second,
    3 => :minute,
    4 => :hour,
    5 => :day
  }

  ##############################################################################
  #
  # time_scale_to_ms
  #
  #

  @spec time_scale_to_ms(time_scale :: Types.time_scale()) :: pos_integer()
  @spec time_scale_to_ms(time_scale :: Types.time_scale(), time_value :: pos_integer()) ::
          pos_integer()
  def time_scale_to_ms(time_scale, time_value \\ 1)

  def time_scale_to_ms(_, time_value) when time_value <= 0,
    do: raise(ArgumentError, "The time value must be greater than or equal to 1")

  def time_scale_to_ms(:day, time_value), do: time_value * (24 * 60 * 60 * 1000)
  def time_scale_to_ms(:hour, time_value), do: time_value * (60 * 60 * 1000)
  def time_scale_to_ms(:minute, time_value), do: time_value * (60 * 1000)
  def time_scale_to_ms(:second, time_value), do: time_value * 1000
  def time_scale_to_ms(:millisecond, time_value), do: time_value

  ##############################################################################
  #
  # decode_time_scale
  #
  #

  @spec decode_time_scale(code :: pos_integer()) ::
          {:ok, Types.time_scale()} | ErrorTypes.parsable_error()
  def decode_time_scale(code) when code in 1..5, do: {:ok, @time_scale_codes[code]}

  def decode_time_scale(code),
    do: {:error, {:time_scale_coding_error, "Invalid time scale code #{inspect(code)}."}}

  ##############################################################################
  #
  # encode_time_scale
  #
  #

  @spec encode_time_scale(time_scale :: Types.time_scale()) ::
          {:ok, pos_integer()} | ErrorTypes.parsable_error()
  def encode_time_scale(time_scale) do
    case Enum.find(@time_scale_codes, fn {_key, value} -> value === time_scale end) do
      {code, _time_scale} -> {:ok, code}
      _ -> {:error, {:time_scale_coding_error, "Invalid time_scale #{inspect(time_scale)}."}}
    end
  end
end
