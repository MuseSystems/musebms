# Source File: rate_limiter.ex
# Location:    musebms/components/system/mscmp_syst_limiter/lib/impl/rate_limiter.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystLimiter.Impl.RateLimiter do
  @moduledoc false

  alias MscmpSystLimiter.Types

  require Logger

  ##############################################################################
  #
  # get_counter_name
  #
  #

  @spec get_counter_name(Types.counter_type(), Types.counter_id()) :: Types.counter_name()
  def get_counter_name(counter_type, counter_id),
    do: Atom.to_string(counter_type) <> "_" <> counter_id

  ##############################################################################
  #
  # get_check_rate_function
  #
  #

  @spec get_check_rate_function(Types.counter_type(), integer(), integer()) ::
          (counter_id :: Types.counter_id() ->
             {:allow, count :: integer()}
             | {:deny, limit :: integer()}
             | {:error, reason :: any()})
  def get_check_rate_function(counter_type, scale_ms, limit) do
    fn counter_id ->
      MscmpSystLimiter.check_rate(counter_type, counter_id, scale_ms, limit)
    end
  end

  ##############################################################################
  #
  # check_rate
  #
  #

  @spec check_rate(Types.counter_type(), Types.counter_id(), integer(), integer()) ::
          {:allow, count :: integer()} | {:deny, limit :: integer()} | {:error, reason :: any()}
  def check_rate(counter_type, counter_id, scale_ms, limit) do
    counter_name = get_counter_name(counter_type, counter_id)
    Hammer.check_rate(counter_name, scale_ms, limit)
  end

  ##############################################################################
  #
  # check_rate_with_increment
  #
  #

  @spec check_rate_with_increment(
          Types.counter_type(),
          Types.counter_id(),
          integer(),
          integer(),
          integer()
        ) ::
          {:allow, count :: integer()} | {:deny, limit :: integer()} | {:error, reason :: any()}
  def check_rate_with_increment(counter_type, counter_id, scale_ms, limit, increment) do
    counter_name = get_counter_name(counter_type, counter_id)
    Hammer.check_rate_inc(counter_name, scale_ms, limit, increment)
  end

  ##############################################################################
  #
  # inspect_counter
  #
  #

  @spec inspect_counter(Types.counter_type(), Types.counter_id(), integer(), integer()) ::
          {:ok,
           {
             count :: integer(),
             count_remaining :: integer(),
             ms_to_next_counter :: integer(),
             created_at :: integer() | nil,
             updated_at :: integer() | nil
           }}
          | {:error, reason :: any()}
  def inspect_counter(counter_type, counter_id, scale_ms, limit) do
    counter_name = get_counter_name(counter_type, counter_id)
    Hammer.inspect_bucket(counter_name, scale_ms, limit)
  end

  @spec delete_counters(Types.counter_type(), Types.counter_id()) ::
          {:ok, integer()} | {:error, reason :: any()}
  def delete_counters(counter_type, counter_id) do
    counter_name = get_counter_name(counter_type, counter_id)
    Hammer.delete_buckets(counter_name)
  end
end
