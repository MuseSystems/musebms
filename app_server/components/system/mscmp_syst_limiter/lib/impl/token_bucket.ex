# Source File: token_bucket.ex
# Location:    musebms/app_server/components/system/mscmp_syst_limiter/lib/impl/token_bucket.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystLimiter.Impl.TokenBucket do
  @moduledoc false

  alias MscmpSystError.Types, as: ErrorTypes
  alias MscmpSystLimiter.Impl.Common
  alias MscmpSystLimiter.Runtime.ProcessUtils
  alias MscmpSystLimiter.Types

  @atomics_current_fill 1
  @atomics_request_time 2
  @atomics_ttl 3
  @atomics_bucket_size 4
  @atomics_refill_rate 5
  @atomics_refill_per_code 6

  ##############################################################################
  #
  # new
  #
  #

  @spec new(
          component :: module(),
          counter_type :: Types.counter_type(),
          counter_id :: Types.counter_id(),
          opts :: Keyword.t()
        ) ::
          {:ok, Types.limiter_instance()} | ErrorTypes.parsable_error()
  def new(component, counter_type, counter_id, opts) do
    limiter_id = {component, counter_type, counter_id}

    bucket_size = Keyword.fetch!(opts, :bucket_size)
    refill_rate = Keyword.fetch!(opts, :refill_rate)
    refill_per = Keyword.fetch!(opts, :refill_per)

    with {:ok, ets_table} <- get_ets_table(),
         {:ok, atomics_ref} <-
           ensure_atomics_ref(
             ets_table,
             limiter_id,
             bucket_size,
             refill_rate,
             refill_per
           ) do
      {:ok, {:token_bucket, {component, counter_type, counter_id}, atomics_ref}}
    end
  end

  defp ensure_atomics_ref(
         ets_table,
         limiter_id,
         bucket_size,
         refill_rate,
         refill_per
       ) do
    request_time = System.system_time(:millisecond)

    case :ets.lookup(ets_table, limiter_id) do
      [{_id, atomics_ref}] ->
        :ok =
          {:token_bucket, limiter_id, atomics_ref}
          |> compute(0, request_time)
          |> refresh_limit()

        {:ok, atomics_ref}

      [] ->
        create_atomics_ref(
          ets_table,
          limiter_id,
          bucket_size,
          refill_rate,
          refill_per,
          request_time
        )
    end
  end

  defp create_atomics_ref(
         ets_table,
         limiter_id,
         bucket_size,
         refill_rate,
         refill_per,
         request_time
       ) do
    atomics_ref = :atomics.new(6, [{:signed, false}])

    with {:ok, time_to_live} <- calculate_ttl(bucket_size, refill_rate, refill_per),
         {:ok, refill_per_code} <- Common.encode_time_scale(refill_per) do
      :ok = :atomics.put(atomics_ref, @atomics_current_fill, bucket_size)
      :ok = :atomics.put(atomics_ref, @atomics_request_time, request_time)
      :ok = :atomics.put(atomics_ref, @atomics_ttl, time_to_live)
      :ok = :atomics.put(atomics_ref, @atomics_bucket_size, bucket_size)
      :ok = :atomics.put(atomics_ref, @atomics_refill_rate, refill_rate)
      :ok = :atomics.put(atomics_ref, @atomics_refill_per_code, refill_per_code)

      true = :ets.insert_new(ets_table, {limiter_id, atomics_ref})

      {:ok, atomics_ref}
    end
  end

  defp refresh_limit({used_fill, _refill_rate_ms, request_time, limiter_instance}) do
    {:token_bucket, _, atomics_ref} = limiter_instance
    :ok = :atomics.put(atomics_ref, @atomics_current_fill, used_fill)
    :ok = :atomics.put(atomics_ref, @atomics_request_time, request_time)
  end

  ##############################################################################
  #
  # use
  #
  #

  @spec use(limiter_instance :: Types.limiter_instance(), increment :: pos_integer()) ::
          {:ok, Types.limiter_result()} | ErrorTypes.parsable_error()
  def use(limiter_instance, increment) when is_integer(increment) and increment > 0 do
    request_time = System.system_time(:millisecond)

    with {:ok, refreshed_limiter_instance} <- maybe_renew_limiter(limiter_instance, request_time) do
      compute(refreshed_limiter_instance, increment, request_time)
      |> use_limit()
      |> then(&{:ok, &1})
    end
  end

  def use(_limiter_instance, _increment) do
    {:error, {:token_bucket_bad_increment, "Increment must be an integer greater than 0."}}
  end

  defp use_limit({used_fill, ms_per_token, request_time, limiter_instance}) do
    {:token_bucket, _limiter_id, atomics_ref} = limiter_instance

    # My LLM code review indicated that there is a race condition possible here
    # where concurrent access to the counter could result in a dirty write
    # unless we use `:atomics.compare_exchange/4`.  The LLM isn't wrong, but I
    # think the risk is relatively low and all things considered, it's unclear
    # that there's a good resolution which isn't complex.  The cure may be worse
    # than the disease.  We'll keep it simple for now and not lose sight of the
    # issue once we get closer to a real product.
    #
    # TODO: consider making this update more consistent in the face of
    #       concurrent accesses to a single counter.

    case used_fill >= 0 do
      true ->
        :ok = :atomics.put(atomics_ref, @atomics_current_fill, used_fill)
        :ok = :atomics.put(atomics_ref, @atomics_request_time, request_time)

        {:allow, used_fill, limiter_instance}

      false ->
        missing_tokens = -used_fill
        ms_to_retry = missing_tokens * ms_per_token
        {:deny, ms_to_retry, limiter_instance}
    end
  end

  ##############################################################################
  #
  # get
  #
  #
  @spec get(limiter_instance :: Types.limiter_instance()) ::
          {:ok, Types.limiter_result()} | ErrorTypes.parsable_error()
  def get(limiter_instance) do
    request_time = System.system_time(:millisecond)

    with {:ok, refreshed_limiter_instance} <- maybe_renew_limiter(limiter_instance, request_time) do
      compute(refreshed_limiter_instance, 0, request_time)
      |> get_limit()
      |> then(&{:ok, &1})
    end
  end

  defp get_limit({used_fill, ms_per_token, _request_time, limiter_instance}) do
    case used_fill >= 0 do
      true ->
        {:allow, used_fill, limiter_instance}

      false ->
        missing_tokens = -used_fill
        ms_to_retry = missing_tokens * ms_per_token
        {:deny, ms_to_retry, limiter_instance}
    end
  end

  ##############################################################################
  #
  # set
  #
  #
  @spec set(limiter_instance :: Types.limiter_instance(), opts :: Keyword.t()) ::
          {:ok, Types.limiter_result()} | ErrorTypes.parsable_error()
  def set(limiter_instance, opts) when is_list(opts) do
    request_time = System.system_time(:millisecond)
    new_current_fill = opts[:current_fill]

    with {:ok, renewed_limiter_instance} <- maybe_renew_limiter(limiter_instance, request_time) do
      process_counter_update(renewed_limiter_instance, new_current_fill, request_time)
    end
  end

  defp process_counter_update(limiter_instance, current_fill, request_time) do
    {_, _, atomics_ref} = limiter_instance

    bucket_size = :atomics.get(atomics_ref, @atomics_bucket_size)
    refill_rate = :atomics.get(atomics_ref, @atomics_refill_rate)

    {:ok, refill_per} =
      Common.decode_time_scale(:atomics.get(atomics_ref, @atomics_refill_per_code))

    ms_per_token = div(Common.time_scale_to_ms(refill_per) + refill_rate - 1, refill_rate)

    cond do
      not is_integer(current_fill) or current_fill < 0 ->
        {:error,
         {:token_bucket_bad_current_fill,
          "Current fill values must be an integer between 0 and #{inspect(bucket_size)}."}}

      current_fill < bucket_size ->
        :atomics.put(atomics_ref, @atomics_current_fill, current_fill)
        :atomics.put(atomics_ref, @atomics_request_time, request_time)

        return_value =
          if current_fill > 0 do
            {:allow, current_fill, limiter_instance}
          else
            {:deny, ms_per_token, limiter_instance}
          end

        {:ok, return_value}

      current_fill == bucket_size ->
        :atomics.put(atomics_ref, @atomics_current_fill, current_fill)
        :atomics.put(atomics_ref, @atomics_request_time, request_time)

        {:ok, {:allow, current_fill, limiter_instance}}

      true ->
        {:error,
         {:token_bucket_bad_current_fill,
          "Current fill values are only valid between 0 and #{inspect(bucket_size)}."}}
    end
  end

  ##############################################################################
  #
  # reset
  #
  #

  @spec reset(limiter_instance :: Types.limiter_instance()) ::
          {:ok, Types.limiter_result()} | ErrorTypes.parsable_error()
  def reset(limiter_instance) do
    {_, _, atomics_ref} = limiter_instance
    bucket_size = :atomics.get(atomics_ref, @atomics_bucket_size)
    set(limiter_instance, current_fill: bucket_size)
  end

  ##############################################################################
  #
  # cleanup
  #
  #

  @spec cleanup(ets_table :: :ets.table()) :: non_neg_integer()
  def cleanup(ets_table) do
    cleanup_time = System.system_time(:millisecond)

    :ets.foldl(
      fn limiter, deleted ->
        {_limiter_id, atomics_ref} = limiter
        request_time = :atomics.get(atomics_ref, @atomics_request_time)
        ttl = :atomics.get(atomics_ref, @atomics_ttl)

        if request_time + ttl < cleanup_time do
          :ets.delete_object(ets_table, limiter)
          deleted + 1
        else
          deleted
        end
      end,
      0,
      ets_table
    )
  end

  ##############################################################################
  #
  # General Private Functions
  #
  #

  defp calculate_ttl(bucket_size, refill_rate, refill_per) do
    with {:ok, cleanup_interval} <- get_cleanup_interval() do
      {:ok,
       div(bucket_size, refill_rate) * Common.time_scale_to_ms(refill_per) + cleanup_interval}
    end
  end

  defp compute(limiter_instance, increment, request_time) do
    {:token_bucket, _limiter_id, atomics_ref} = limiter_instance

    current_fill = :atomics.get(atomics_ref, @atomics_current_fill)
    last_request_time = :atomics.get(atomics_ref, @atomics_request_time)
    bucket_size = :atomics.get(atomics_ref, @atomics_bucket_size)
    refill_rate = :atomics.get(atomics_ref, @atomics_refill_rate)

    {:ok, refill_per} =
      Common.decode_time_scale(:atomics.get(atomics_ref, @atomics_refill_per_code))

    ms_per_token = div(Common.time_scale_to_ms(refill_per) + refill_rate - 1, refill_rate)

    elapsed_ms = request_time - last_request_time
    new_tokens = div(elapsed_ms, ms_per_token)
    eval_fill = min(current_fill + new_tokens, bucket_size)
    used_fill = eval_fill - increment

    {used_fill, ms_per_token, request_time, limiter_instance}
  end

  defp get_cleanup_interval do
    runtime_config = ProcessUtils.get_runtime_config()

    case runtime_config do
      %{token_bucket: {_, cleanup_interval}}
      when is_integer(cleanup_interval) and cleanup_interval > 0 ->
        {:ok, cleanup_interval}

      _ ->
        {:error,
         {:token_bucket_bad_cleanup_interval,
          "The cleanup interval of the Token Bucket algorithm has not been set correctly."}}
    end
  end

  defp get_ets_table do
    runtime_config = ProcessUtils.get_runtime_config()

    case runtime_config do
      %{token_bucket: {ets_table, _}} when not is_nil(ets_table) ->
        {:ok, ets_table}

      %{token_bucket: {ets_table, _}} when is_nil(ets_table) ->
        {:error,
         {:token_bucket_bad_ets_table,
          "The current Token Bucket algorithm hasn't started its counter registry."}}

      _ ->
        {:error,
         {:token_bucket_bad_ets_table,
          "The limiter service is not correctly set. " <>
            "You must call `MscmpSystLimiter.put_service/1` " <>
            "in the process from which you wish to use the limiter."}}
    end
  end

  defp maybe_renew_limiter(limiter_instance, request_time) do
    {:token_bucket, limiter_id, atomics_ref} = limiter_instance
    {component, counter_type, counter_id} = limiter_id

    last_request_time = :atomics.get(atomics_ref, @atomics_request_time)
    time_to_live_ms = :atomics.get(atomics_ref, @atomics_ttl)
    bucket_size = :atomics.get(atomics_ref, @atomics_bucket_size)
    refill_rate = :atomics.get(atomics_ref, @atomics_refill_rate)

    {:ok, refill_per} =
      Common.decode_time_scale(:atomics.get(atomics_ref, @atomics_refill_per_code))

    case last_request_time + time_to_live_ms < request_time do
      true ->
        new(component, counter_type, counter_id,
          bucket_size: bucket_size,
          refill_rate: refill_rate,
          refill_per: refill_per
        )

      false ->
        {:ok, limiter_instance}
    end
  end
end
