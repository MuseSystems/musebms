# Source File: server.ex
# Location:    musebms/components/system/mscmp_syst_settings/lib/runtime/server.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystSettings.Runtime.Server do
  use GenServer
  require Logger

  alias MscmpSystSettings.Impl.Settings
  alias MscmpSystSettings.Runtime.ProcessUtils

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

  @spec start_link(MscmpSystSettings.Types.setting_service_params()) ::
          {:ok, pid()} | {:error, MscmpSystError.t()}
  def start_link({settings_service_name, _datastore_context_name} = params) do
    case GenServer.start_link(__MODULE__, params, name: settings_service_name) do
      {:ok, pid} ->
        {:ok, pid}

      abort_reason ->
        {
          :error,
          %MscmpSystError{
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
        %MscmpSystError{
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
  @spec init(MscmpSystSettings.Types.setting_service_params()) ::
          {:ok, map()} | {:stop, MscmpSystError.t()}
  def init({service_name, datastore_context_name}) do
    _ = ProcessUtils.put_settings_service(service_name)
    ets_table_name = Settings.get_ets_table_from_service_name(service_name)

    _ = :ets.new(ets_table_name, [:set, :protected, :named_table])

    _ = MscmpSystDb.put_datastore_context(datastore_context_name)

    Settings.refresh_from_database()

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
      Settings.refresh_from_database(),
      state
    }
  end

  @impl true
  def handle_call({:create, creation_params}, _from, state) do
    {
      :reply,
      Settings.create_setting(creation_params),
      state
    }
  end

  @impl true
  def handle_call({:update, setting_name, update_params}, _from, state) do
    {
      :reply,
      Settings.update_setting(setting_name, update_params),
      state
    }
  end

  @impl true
  def handle_call({:delete, setting_name}, _from, state) do
    {
      :reply,
      Settings.delete_setting(setting_name),
      state
    }
  end

  @impl true
  def terminate(:normal, state) do
    :ets.delete(state.ets_table_name)
    :ok
  end
end
