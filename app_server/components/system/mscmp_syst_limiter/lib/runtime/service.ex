# Source File: service.ex
# Location:    musebms/app_server/components/system/service/lib/runtime/mscmp_syst_limiter.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystLimiter.Runtime.Service do
  @moduledoc false

  use GenServer

  alias MscmpSystLimiter.Impl

  ######
  #
  # This module implements the mechanics of dealing with GenServer runtime
  # concerns.  Business logic should largely/entirely appear elsewhere.
  #
  ######

  ##############################################################################
  #
  # init
  #
  #

  @impl true
  @spec init(Keyword.t()) :: {:ok, map()} | {:stop, term()}
  def init(opts) do
    algorithms = opts[:algorithms]
    cleanup_interval = opts[:cleanup_interval]

    semaphore_table = maybe_start_limiter(:semaphore, algorithms)
    token_bucket_table = maybe_start_limiter(:token_bucket, algorithms)

    default_cleanup_interval = cleanup_interval[:all] || 60_000

    semaphore_cleanup_interval = cleanup_interval[:semaphore] || default_cleanup_interval
    token_bucket_cleanup_interval = cleanup_interval[:token_bucket] || default_cleanup_interval

    runtime_config =
      %{
        semaphore: {semaphore_table, semaphore_cleanup_interval},
        token_bucket: {token_bucket_table, token_bucket_cleanup_interval}
      }

    Enum.each(runtime_config, fn {algorithm, {ets_table, cleanup_interval}} ->
      cleanup_atom = get_algorithm_cleanup_atom(algorithm)

      if is_reference(ets_table) do
        Process.send_after(self(), cleanup_atom, cleanup_interval)
      end
    end)

    {:ok, runtime_config}
  end

  defp maybe_start_limiter(target_algorithm, algorithms) do
    if :all === algorithms or target_algorithm in algorithms do
      :ets.new(nil, [:set, :public])
    else
      nil
    end
  end

  defp get_algorithm_cleanup_atom(:semaphore), do: :cleanup_semaphore
  defp get_algorithm_cleanup_atom(:token_bucket), do: :cleanup_token_bucket

  ##############################################################################
  #
  # handle_call
  #
  #

  @impl true
  def handle_call(:get_runtime_config, _from, state), do: {:reply, state, state}

  ##############################################################################
  #
  # handle_info
  #
  #

  @impl true
  def handle_info(:cleanup_semaphore, state) do
    %{semaphore: {ets_table, cleanup_interval}} = state
    Impl.Semaphore.cleanup(ets_table)
    Process.send_after(self(), :cleanup_semaphore, cleanup_interval)
    {:noreply, state}
  end

  @impl true
  def handle_info(:cleanup_token_bucket, state) do
    %{token_bucket: {ets_table, cleanup_interval}} = state
    Impl.TokenBucket.cleanup(ets_table)
    Process.send_after(self(), :cleanup_token_bucket, cleanup_interval)
    {:noreply, state}
  end

  ##############################################################################
  #
  # terminate
  #
  #

  @impl true
  def terminate(_reason, state) do
    state
    |> Enum.each(fn {_algorithm, {ets_table, _cleanup_interval}} ->
      if is_reference(ets_table) do
        :ets.delete(ets_table)
      end
    end)

    :ok
  end
end
