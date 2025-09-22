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
  # start_link
  #
  #

  @spec start_link(Keyword.t()) :: {:ok, pid()} | :ignore | {:error, term()}
  def start_link(opts) do
    genserver_opts =
      [name: opts[:service_name]] ++
        Keyword.take(opts, [:debug, :timeout, :hibernate_after])

    init_opts = Keyword.take(opts, [:datastore_context_name])

    case GenServer.start_link(__MODULE__, init_opts, genserver_opts) do
      {:ok, pid} -> {:ok, pid}
      :ignore -> :ignore
      abort_reason -> {:error, {:start_link_error, abort_reason}}
    end
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
  @spec init(Keyword.t()) :: {:ok, map()} | {:stop, term()}
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

  @impl true
  def handle_call(:get_runtime_config, _from, state) do
    runtime_config = %{
      settings_table: state.settings_table_tid
    }

    {:reply, runtime_config, state}
  end

  ##############################################################################
  #
  # terminate
  #
  #

  @impl true
  def terminate(_reason, state) do
    :ets.delete(state.settings_table_tid)
    :ok
  end
end
