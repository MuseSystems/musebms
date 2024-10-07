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
             | {:error, Mserror.LimiterError.t()})
  def get_check_rate_function(counter_type, scale_ms, limit) do
    fn counter_id ->
      check_rate(counter_type, counter_id, scale_ms, limit)
    end
  end

  ##############################################################################
  #
  # check_rate
  #
  #

  @spec check_rate(Types.counter_type(), Types.counter_id(), integer(), integer()) ::
          {:allow, count :: integer()}
          | {:deny, limit :: integer()}
          | {:error, Mserror.LimiterError.t()}
  def check_rate(counter_type, counter_id, scale_ms, limit) do
    with counter_name <- get_counter_name(counter_type, counter_id),
         {result, value} when result in [:allow, :deny] <-
           Hammer.check_rate(counter_name, scale_ms, limit) do
      {result, value}
    else
      {:error, _} = error ->
        {:error,
         Mserror.LimiterError.new(:check_counter, "Failure checking the counter.",
           cause: error,
           context: %MscmpSystError.Types.Context{
             origin: {__MODULE__, :check_rate, 4},
             parameters: %{
               counter_type: counter_type,
               counter_id: counter_id,
               scale_ms: scale_ms,
               limit: limit
             }
           }
         )}
    end
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
          {:allow, count :: integer()}
          | {:deny, limit :: integer()}
          | {:error, Mserror.LimiterError.t()}
  def check_rate_with_increment(counter_type, counter_id, scale_ms, limit, increment) do
    with counter_name <- get_counter_name(counter_type, counter_id),
         {result, value} when result in [:allow, :deny] <-
           Hammer.check_rate_inc(counter_name, scale_ms, limit, increment) do
      {result, value}
    else
      {:error, _} = error ->
        {:error,
         Mserror.LimiterError.new(:check_counter, "Failure checking the counter with increment.",
           cause: error,
           context: %MscmpSystError.Types.Context{
             origin: {__MODULE__, :check_rate_with_increment, 5},
             parameters: %{
               counter_type: counter_type,
               counter_id: counter_id,
               scale_ms: scale_ms,
               limit: limit,
               increment: increment
             }
           }
         )}
    end
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
          | {:error, Mserror.LimiterError.t()}
  def inspect_counter(counter_type, counter_id, scale_ms, limit) do
    with counter_name <- get_counter_name(counter_type, counter_id),
         {:ok, result} <- Hammer.inspect_bucket(counter_name, scale_ms, limit) do
      {:ok, result}
    else
      {:error, _} = error ->
        {:error,
         Mserror.LimiterError.new(:inspect_counter, "Failure inspecting the counter.",
           cause: error,
           context: %MscmpSystError.Types.Context{
             origin: {__MODULE__, :inspect_counter, 4},
             parameters: %{
               counter_type: counter_type,
               counter_id: counter_id,
               scale_ms: scale_ms,
               limit: limit
             }
           }
         )}
    end
  end

  @spec delete_counters(Types.counter_type(), Types.counter_id()) ::
          {:ok, integer()} | {:error, Mserror.LimiterError.t()}
  def delete_counters(counter_type, counter_id) do
    with counter_name <- get_counter_name(counter_type, counter_id),
         {:ok, result} <- Hammer.delete_buckets(counter_name) do
      {:ok, result}
    else
      {:error, _} = error ->
        {:error,
         Mserror.LimiterError.new(:delete_counter, "Failure deleting the counter.",
           cause: error,
           context: %MscmpSystError.Types.Context{
             origin: {__MODULE__, :delete_counters, 2},
             parameters: %{
               counter_type: counter_type,
               counter_id: counter_id
             }
           }
         )}
    end
  end
end
