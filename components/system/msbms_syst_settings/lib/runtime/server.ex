# Source File: server.ex
# Location:    components/system/msbms_syst_settings/lib/runtime/server.ex
# Project:     msbms
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https: //muse.systems

defmodule MsbmsSystSettings.Runtime.Server do
  use GenServer
  require Logger

  alias MsbmsSystSettings.Impl.Settings

  @moduledoc false

  ######
  #
  # This module implements the mechanics of dealing with GenServer runtime
  # concerns.  Business logic should largely/entirely appear elsewhere.
  #
  ######

  ##
  ## Client
  ##

  @spec start_link(MsbmsSystSettings.Types.setting_service_params()) ::
          :ok | {:error, MsbmsSystError.t()}
  def start_link({settings_service_name, _datastore_context_name} = params) do
    case GenServer.start_link(__MODULE__, params, name: settings_service_name) do
      {:ok, pid} ->
        {:ok, pid}

      abort_reason ->
        {
          :error,
          %MsbmsSystError{
            code: :process_error,
            message: "Settings Service start aborted.",
            cause: abort_reason
          }
        }
    end
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MsbmsSystError{
          code: :process_error,
          message: "Failure starting Settings Service.",
          cause: error
        }
      }
  end

  ##
  ## Server
  ##

  @impl true
  @spec init(MsbmsSystSettings.Types.setting_service_params()) ::
          {:ok, map()} | {:stop, MsbmsSystError.t()}
  def init({service_name, datastore_context_name}) do
    ets_table_name = Settings.get_ets_table_from_service_name(service_name)

    :ets.new(ets_table_name, [:set, :protected, :named_table])

    MsbmsSystDatastore.set_datastore_context(datastore_context_name)

    Settings.refresh_from_database(service_name)

    {:ok,
     %{
       service_name: service_name,
       datastore_context_name: datastore_context_name,
       ets_table_name: ets_table_name
     }}
  end

  @impl true
  def handle_call(:refresh, _from, state) do
    {
      :reply,
      Settings.refresh_from_database(state.service_name),
      state
    }
  end

  @impl true
  def handle_call({:create, creation_params}, _from, state) do
    {
      :reply,
      Settings.create_setting(state.service_name, creation_params),
      state
    }
  end

  @impl true
  def handle_call({:update, setting_name, update_params}, _from, state) do
    {
      :reply,
      Settings.update_setting(state.service_name, setting_name, update_params),
      state
    }
  end

  @impl true
  def handle_call({:delete, setting_name}, _from, state) do
    {
      :reply,
      Settings.delete_setting(state.service_name, setting_name),
      state
    }
  end

  @impl true
  def terminate(:normal, state) do
    :ets.delete(state.ets_table_name)
    :ok
  end
end
