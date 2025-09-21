# Source File: semaphore.ex
# Location:    musebms/app_server/components/system/mscmp_syst_limiter/lib/impl/semaphore.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystLimiter.Impl.Semaphore do
  @moduledoc false

  alias MscmpSystError.Types, as: ErrorTypes
  alias MscmpSystLimiter.Impl.Common
  alias MscmpSystLimiter.Runtime.ProcessUtils
  alias MscmpSystLimiter.Types

  @atomics_current_permits 1
  @atomics_max_permits 2
  @atomics_expiry_time 3
  @atomics_ttl 4
  @atomics_time_scale_code 5

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
    request_time = System.system_time(:millisecond)
    limiter_id = {component, counter_type, counter_id}
    max_permits = Keyword.fetch!(opts, :max_permits)
    ttl = Keyword.fetch!(opts, :time_to_live)
    time_scale = Keyword.fetch!(opts, :time_scale)

    case get_ets_table() do
      {:ok, ets_table} ->
        maybe_create_limiter(ets_table, limiter_id, max_permits, ttl, time_scale, request_time)

      {:error, _} = error ->
        error
    end
  end

  defp maybe_create_limiter(ets_table, limiter_id, max_permits, ttl, time_scale, request_time) do
    case :ets.lookup(ets_table, limiter_id) do
      [{_id, atomics_ref}] ->
        maybe_recreate_limiter({:semaphore, limiter_id, atomics_ref}, request_time)

      [] ->
        create_limiter(ets_table, limiter_id, max_permits, ttl, time_scale, request_time)
    end
  end

  ##############################################################################
  #
  # use
  #
  #

  @spec use(limiter_instance :: Types.limiter_instance(), increment :: integer()) ::
          {:ok, Types.limiter_result()} | ErrorTypes.parsable_error()
  def use(limiter_instance, increment) when is_integer(increment) do
    request_time = System.system_time(:millisecond)

    with {:ok, refreshed_limiter} <- maybe_recreate_limiter(limiter_instance, request_time) do
      compute_and_apply(refreshed_limiter, increment)
      |> then(&{:ok, &1})
    end
  end

  defp compute_and_apply(limiter_instance, increment) do
    {:semaphore, _limiter_id, atomics_ref} = limiter_instance

    current_permits = :atomics.get(atomics_ref, @atomics_current_permits)
    max_permits = :atomics.get(atomics_ref, @atomics_max_permits)

    new_capacity = min(current_permits - increment, max_permits)

    if new_capacity >= 0 do
      :ok = :atomics.put(atomics_ref, @atomics_current_permits, new_capacity)
      {:allow, new_capacity, limiter_instance}
    else
      {:deny, -new_capacity, limiter_instance}
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

    with {:ok, refreshed_limiter} <- maybe_recreate_limiter(limiter_instance, request_time) do
      {:semaphore, _, atomics_ref} = refreshed_limiter
      current_permits = :atomics.get(atomics_ref, @atomics_current_permits)
      {:ok, {:allow, current_permits, refreshed_limiter}}
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
    new_capacity = opts[:current_permits]

    with {:ok, refreshed_limiter} <- maybe_recreate_limiter(limiter_instance, request_time) do
      process_capacity_update(refreshed_limiter, new_capacity)
    end
  end

  defp process_capacity_update(limiter_instance, new_permits) do
    {_, _, atomics_ref} = limiter_instance
    max_permits = :atomics.get(atomics_ref, @atomics_max_permits)

    cond do
      not is_integer(new_permits) or new_permits < 0 ->
        {:error,
         {:semaphore_bad_capacity,
          "Available permit values must be an integer between 0 and #{inspect(max_permits)}."}}

      new_permits <= max_permits ->
        :atomics.put(atomics_ref, @atomics_current_permits, new_permits)

        {:ok, {:allow, new_permits, limiter_instance}}

      true ->
        {:error,
         {:semaphore_bad_capacity,
          "Available permit values are only valid between 0 and #{inspect(max_permits)}."}}
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
    max_permits = :atomics.get(atomics_ref, @atomics_max_permits)
    set(limiter_instance, current_permits: max_permits)
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
        expiry_time = :atomics.get(atomics_ref, @atomics_expiry_time)

        if expiry_time < cleanup_time do
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

  defp get_ets_table do
    runtime_config = ProcessUtils.get_runtime_config()

    case runtime_config do
      %{semaphore: {ets_table, _}} when not is_nil(ets_table) ->
        {:ok, ets_table}

      %{semaphore: {ets_table, _}} when is_nil(ets_table) ->
        {:error,
         {:semaphore_bad_ets_table,
          "The current Semaphore algorithm hasn't started its counter registry."}}

      _ ->
        {:error,
         {:semaphore_bad_ets_table,
          "The limiter service is not correctly set. " <>
            "You must call `MscmpSystLimiter.put_service/1` " <>
            "in the process from which you wish to use the limiter."}}
    end
  end

  defp maybe_recreate_limiter(limiter_instance, request_time) do
    {:semaphore, limiter_id, atomics_ref} = limiter_instance

    expiry_time = :atomics.get(atomics_ref, @atomics_expiry_time)

    case request_time > expiry_time do
      true ->
        max_permits = :atomics.get(atomics_ref, @atomics_max_permits)
        ttl = :atomics.get(atomics_ref, @atomics_ttl)

        {:ok, time_scale} =
          :atomics.get(atomics_ref, @atomics_time_scale_code) |> Common.decode_time_scale()

        {:ok, ets_table} = get_ets_table()
        :ets.delete(ets_table, limiter_id)

        create_limiter(ets_table, limiter_id, max_permits, ttl, time_scale, request_time)

      false ->
        {:ok, limiter_instance}
    end
  end

  defp create_limiter(ets_table, limiter_id, max_permits, ttl, time_scale, request_time) do
    expiry_time = request_time + ttl * Common.time_scale_to_ms(time_scale)

    with {:ok, time_scale_code} <- Common.encode_time_scale(time_scale),
         atomics_ref = :atomics.new(5, [{:signed, false}]),
         :ok <- :atomics.put(atomics_ref, @atomics_current_permits, max_permits),
         :ok <- :atomics.put(atomics_ref, @atomics_max_permits, max_permits),
         :ok <- :atomics.put(atomics_ref, @atomics_expiry_time, expiry_time),
         :ok <- :atomics.put(atomics_ref, @atomics_ttl, ttl),
         :ok <- :atomics.put(atomics_ref, @atomics_time_scale_code, time_scale_code),
         true <- :ets.insert_new(ets_table, {limiter_id, atomics_ref}) do
      {:ok, {:semaphore, limiter_id, atomics_ref}}
    else
      false ->
        {:error,
         {:semaphore_bad_ets_insert, "The ETS insertion of the new limiter reference failed."}}

      error ->
        {:error, {:semaphore_creation_failure, "Failed creating limiter #{inspect(error)}."}}
    end
  end
end
