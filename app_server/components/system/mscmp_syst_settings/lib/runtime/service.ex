# Source File: service.ex
# Location:    musebms/app_server/components/system/mscmp_syst_settings/lib/runtime/service.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystSettings.Runtime.Service do
  @moduledoc false

  use GenServer

  alias MscmpSystSettings.Impl
  alias MscmpSystSettings.Types

  require Logger

  ######
  #
  # This module implements the mechanics of dealing with GenServer runtime
  # concerns.  Business logic should largely/entirely appear elsewhere.
  #
  ######

  ##
  ## Client
  ##

  ##############################################################################
  #
  # child_spec
  #
  #

  @spec child_spec(Keyword.t()) :: Supervisor.child_spec()
  def child_spec(opts) do
    genserver_opts = Keyword.take(opts, [:debug, :timeout, :hibernate_after])

    %{
      id: __MODULE__,
      start:
        {MscmpSystSettings, :start_link,
         [opts[:service_name], opts[:datastore_context_name], genserver_opts]}
    }
  end

  ##############################################################################
  #
  # start_link
  #
  #

  @spec start_link(Types.service_name(), MscmpSystDb.Types.context_service_name(), Keyword.t()) ::
          {:ok, pid()} | {:error, MscmpSystError.t()}
  def start_link(service_name, datastore_context_name, opts) do
    opts = Keyword.put(opts, :name, service_name)

    init_opts = [datastore_context_name: datastore_context_name]

    case GenServer.start_link(__MODULE__, init_opts, opts) do
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

  ##############################################################################
  #
  # init
  #
  #

  @impl true
  @spec init(Keyword.t()) :: {:ok, map()} | {:stop, MscmpSystError.t()}
  def init(opts) do
    settings_table = :ets.new(nil, [:set, :protected])

    _ = MscmpSystDb.put_datastore_context(opts[:datastore_context_name])

    Impl.Settings.refresh_from_database(settings_table)

    {:ok,
     %{
       datastore_context_name: opts[:datastore_context_name],
       settings_table_tid: settings_table
     }}
  end

  ##############################################################################
  #
  # handle_call
  #
  #

  @impl true
  def handle_call(:refresh, _from, state) do
    {
      :reply,
      Impl.Settings.refresh_from_database(state.settings_table_tid),
      state
    }
  end

  @impl true
  def handle_call({:create, creation_params}, _from, state) do
    {
      :reply,
      Impl.Settings.create(state.settings_table_tid, creation_params),
      state
    }
  end

  @impl true
  def handle_call({:update, setting_name, update_params}, _from, state) do
    {
      :reply,
      Impl.Settings.update_setting(state.settings_table_tid, setting_name, update_params),
      state
    }
  end

  @impl true
  def handle_call({:delete, setting_name}, _from, state) do
    {
      :reply,
      Impl.Settings.delete(state.settings_table_tid, setting_name),
      state
    }
  end

  @impl true
  def handle_call(:get_settings_table, _from, state),
    do: {:reply, state.settings_table_tid, state}

  ##############################################################################
  #
  # terminate
  #
  #

  @impl true
  def terminate(:normal, state) do
    :ets.delete(state.settings_table_tid)
    :ok
  end
end
