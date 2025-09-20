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

    sliding_window_table = maybe_start_limiter(:sliding_window, algorithms)
    fixed_window_table = maybe_start_limiter(:fixed_window, algorithms)
    token_bucket_table = maybe_start_limiter(:token_bucket, algorithms)

    default_cleanup_interval = cleanup_interval[:all] || 60_000

    sliding_window_cleanup_interval =
      cleanup_interval[:sliding_window] || default_cleanup_interval

    fixed_window_cleanup_interval = cleanup_interval[:fixed_window] || default_cleanup_interval
    token_bucket_cleanup_interval = cleanup_interval[:token_bucket] || default_cleanup_interval

    runtime_config =
      %{
        sliding_window: {sliding_window_table, sliding_window_cleanup_interval},
        fixed_window: {fixed_window_table, fixed_window_cleanup_interval},
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

  defp get_algorithm_cleanup_atom(:sliding_window), do: :cleanup_sliding_window
  defp get_algorithm_cleanup_atom(:fixed_window), do: :cleanup_fixed_window
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
  def handle_info(:cleanup_sliding_window, state) do
    {:noreply, state}
  end

  @impl true
  def handle_info(:cleanup_fixed_window, state) do
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
