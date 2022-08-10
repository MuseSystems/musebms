# Source File: msbms_syst_rate_limiter.ex
# Location:    musebms/components/system/msbms_syst_rate_limiter/lib/msbms_syst_rate_limiter.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MsbmsSystRateLimiter do
  alias MsbmsSystRateLimiter.Impl
  alias MsbmsSystRateLimiter.Types

  @spec get_counter_name(Types.counter_type(), Types.counter_id()) :: Types.counter_name()
  defdelegate get_counter_name(counter_type, counter_id), to: Impl.RateLimiter

  @spec get_check_rate_function(Types.counter_type(), integer(), integer()) ::
          (counter_id :: Types.counter_id() ->
             {:allow, count :: integer()}
             | {:deny, limit :: integer()}
             | {:error, MsbmsSystError.t()})
  defdelegate get_check_rate_function(counter_type, scale_ms, limit), to: Impl.RateLimiter

  @spec check_rate(Types.counter_type(), Types.counter_id(), integer(), integer()) ::
          {:allow, count :: integer()}
          | {:deny, limit :: integer()}
          | {:error, MsbmsSystError.t()}
  defdelegate check_rate(counter_type, counter_id, scale_ms, limit), to: Impl.RateLimiter

  @spec check_rate_with_increment(
          Types.counter_type(),
          Types.counter_id(),
          integer(),
          integer(),
          integer()
        ) ::
          {:allow, count :: integer()}
          | {:deny, limit :: integer()}
          | {:error, MsbmsSystError.t()}
  defdelegate check_rate_with_increment(counter_type, counter_id, scale_ms, limit, increment),
    to: Impl.RateLimiter

  @spec inspect_counter(Types.counter_type(), Types.counter_id(), integer(), integer()) ::
          {:ok,
           {
             count :: integer(),
             count_remaining :: integer(),
             ms_to_next_counter :: integer(),
             created_at :: integer() | nil,
             updated_at :: integer() | nil
           }}
          | {:error, MsbmsSystError.t()}
  defdelegate inspect_counter(counter_type, counter_id, scale_ms, limit), to: Impl.RateLimiter

  @spec delete_counters(Types.counter_type(), Types.counter_id()) ::
          {:ok, integer()} | {:error, MsbmsSystError.t()}
  defdelegate delete_counters(counter_type, counter_id), to: Impl.RateLimiter
end
