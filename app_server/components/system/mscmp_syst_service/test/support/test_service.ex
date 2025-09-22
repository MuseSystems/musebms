# Source File: test_service.ex
# Location:    musebms/app_server/components/system/mscmp_syst_service/test/support/test_service.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule TestService do
  @moduledoc """
  A minimal test implementation of MscmpSystService for testing purposes.

  This module implements all required callbacks to verify that the behaviour
  contract works correctly and can be properly implemented.
  """

  use MscmpSystService
  use GenServer

  # Public API - MscmpSystService callbacks

  @impl MscmpSystService
  def child_spec(opts) do
    service_name = Keyword.get(opts, :service_name, __MODULE__)

    %{
      id: service_name,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :permanent,
      shutdown: 5000
    }
  end

  @impl MscmpSystService
  def start_link(opts) do
    service_name = Keyword.get(opts, :service_name)

    init_state = %{
      opts: opts,
      service_name: service_name,
      runtime_config: %{
        started_at: DateTime.utc_now(),
        test_mode: true,
        pid: nil
      }
    }

    case service_name do
      nil ->
        GenServer.start_link(__MODULE__, init_state)

      name ->
        GenServer.start_link(__MODULE__, init_state, name: name)
    end
  end

  @impl MscmpSystService
  def put_service(service_name) do
    previous = Process.get(:current_service_name)
    Process.put(:current_service_name, service_name)
    previous
  end

  @impl MscmpSystService
  def get_service do
    Process.get(:current_service_name)
  end

  @impl MscmpSystService
  def get_runtime_config do
    case get_service() do
      nil ->
        %{}

      service_name ->
        try do
          GenServer.call(service_name, :get_runtime_config)
        catch
          :exit, _ -> %{}
        end
    end
  end

  # Public API - Additional test helpers

  @doc """
  Sets a value in the service state for testing purposes.
  """
  def set_test_value(service_name, key, value) do
    GenServer.call(service_name, {:set_test_value, key, value})
  end

  @doc """
  Gets a value from the service state for testing purposes.
  """
  def get_test_value(service_name, key) do
    GenServer.call(service_name, {:get_test_value, key})
  end

  @doc """
  Stops the service gracefully.
  """
  def stop(service_name) do
    GenServer.stop(service_name)
  end

  # GenServer callbacks

  @impl GenServer
  def init(state) do
    # Update runtime config with actual PID
    runtime_config = Map.put(state.runtime_config, :pid, self())
    state = Map.put(state, :runtime_config, runtime_config)

    {:ok, state}
  end

  @impl GenServer
  def handle_call(:get_runtime_config, _from, state) do
    {:reply, state.runtime_config, state}
  end

  @impl GenServer
  def handle_call({:set_test_value, key, value}, _from, state) do
    runtime_config = Map.put(state.runtime_config, key, value)
    state = Map.put(state, :runtime_config, runtime_config)
    {:reply, :ok, state}
  end

  @impl GenServer
  def handle_call({:get_test_value, key}, _from, state) do
    value = Map.get(state.runtime_config, key)
    {:reply, value, state}
  end

  @impl GenServer
  def handle_call(_request, _from, state) do
    {:reply, :unknown_call, state}
  end

  @impl GenServer
  def handle_cast(_request, state) do
    {:noreply, state}
  end

  @impl GenServer
  def handle_info(_msg, state) do
    {:noreply, state}
  end
end
