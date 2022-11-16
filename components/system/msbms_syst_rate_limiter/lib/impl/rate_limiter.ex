# Source File: rate_limiter.ex
# Location:    musebms/components/system/msbms_syst_rate_limiter/lib/impl/rate_limiter.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MsbmsSystRateLimiter.Impl.RateLimiter do
  alias MsbmsSystRateLimiter.Types

  require Logger

  @moduledoc false

  @spec get_counter_name(Types.counter_type(), Types.counter_id()) :: Types.counter_name()
  def get_counter_name(counter_type, counter_id),
    do: Atom.to_string(counter_type) <> "_" <> counter_id

  @spec get_check_rate_function(Types.counter_type(), integer(), integer()) ::
          (counter_id :: Types.counter_id() ->
             {:allow, count :: integer()}
             | {:deny, limit :: integer()}
             | {:error, MscmpSystError.t()})
  def get_check_rate_function(counter_type, scale_ms, limit) do
    fn counter_id ->
      check_rate(counter_type, counter_id, scale_ms, limit)
    end
  end

  @spec check_rate(Types.counter_type(), Types.counter_id(), integer(), integer()) ::
          {:allow, count :: integer()}
          | {:deny, limit :: integer()}
          | {:error, MscmpSystError.t()}
  def check_rate(counter_type, counter_id, scale_ms, limit) do
    get_counter_name(counter_type, counter_id)
    |> Hammer.check_rate(scale_ms, limit)
    |> process_hammer_check_rate_result()
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {:error,
       %MscmpSystError{
         code: :undefined_error,
         message: "Failure checking rate limit counter.",
         cause: error
       }}
  end

  @spec check_rate_with_increment(
          Types.counter_type(),
          Types.counter_id(),
          integer(),
          integer(),
          integer()
        ) ::
          {:allow, count :: integer()}
          | {:deny, limit :: integer()}
          | {:error, MscmpSystError.t()}
  def check_rate_with_increment(counter_type, counter_id, scale_ms, limit, increment) do
    get_counter_name(counter_type, counter_id)
    |> Hammer.check_rate_inc(scale_ms, limit, increment)
    |> process_hammer_check_rate_result()
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {:error,
       %MscmpSystError{
         code: :undefined_error,
         message: "Failure checking rate limit counter with increment.",
         cause: error
       }}
  end

  defp process_hammer_check_rate_result({:error, reason}) do
    raise MscmpSystError,
      code: :undefined_error,
      message: "Internal error checking rate limit counter.",
      cause: reason
  end

  defp process_hammer_check_rate_result(result), do: result

  @spec inspect_counter(Types.counter_type(), Types.counter_id(), integer(), integer()) ::
          {:ok,
           {
             count :: integer(),
             count_remaining :: integer(),
             ms_to_next_counter :: integer(),
             created_at :: integer() | nil,
             updated_at :: integer() | nil
           }}
          | {:error, MscmpSystError.t()}
  def inspect_counter(counter_type, counter_id, scale_ms, limit) do
    get_counter_name(counter_type, counter_id)
    |> Hammer.inspect_bucket(scale_ms, limit)
    |> process_hammer_inspect_bucket_result()
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {:error,
       %MscmpSystError{
         code: :undefined_error,
         message: "Failure inspecting rate limit counter.",
         cause: error
       }}
  end

  defp process_hammer_inspect_bucket_result({:error, reason}) do
    raise MscmpSystError,
      code: :undefined_error,
      message: "Internal error inspecting rate limit counter.",
      cause: reason
  end

  defp process_hammer_inspect_bucket_result(result), do: result

  @spec delete_counters(Types.counter_type(), Types.counter_id()) ::
          {:ok, integer()} | {:error, MscmpSystError.t()}
  def delete_counters(counter_type, counter_id) do
    get_counter_name(counter_type, counter_id)
    |> Hammer.delete_buckets()
    |> process_hammer_delete_result()
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {:error,
       %MscmpSystError{
         code: :undefined_error,
         message: "Failure deleting rate counters.",
         cause: error
       }}
  end

  defp process_hammer_delete_result({:error, reason}) do
    raise MscmpSystError,
      code: :undefined_error,
      message: "Internal error deleting rate counters.",
      cause: reason
  end

  defp process_hammer_delete_result(result), do: result
end
