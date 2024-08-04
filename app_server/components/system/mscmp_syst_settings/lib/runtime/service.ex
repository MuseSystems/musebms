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

  option_defs = [
    debug: [
      type: :boolean,
      doc: """
      If true, the GenServer backing the Settings Service will be started in
      debug mode.
      """
    ],
    timeout: [
      type: :timeout,
      default: :infinity,
      doc: "Timeout value for the start_link call."
    ],
    hibernate_after: [
      type: :timeout,
      doc: """
      If present, the GenServer process awaits any message for the specified
      time before hibernating.  The timeout value is expressed in Milliseconds.
      """
    ],
    datastore_context_name: [
      type:
        {:or,
         [nil, :atom, {:tuple, [{:in, [:via]}, :atom, :any]}, {:tuple, [{:in, [:global]}, :any]}]},
      type_doc: "`t:GenServer.name/0 or `nil`",
      doc: """
      Specifies the name of the Datastore Context to be used by the Settings
      Service.
      """
    ]
  ]

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

  def child_spec(init_arg) do
    %{
      id: __MODULE__,
      start: {MscmpSystSettings, :start_link, init_arg}
    }
  end

  ##############################################################################
  #
  # start_link
  #

  @start_link_opts NimbleOptions.new!(
                     Keyword.take(option_defs, [:debug, :timeout, :hibernate_after])
                   )

  @spec get_start_link_opts_docs() :: String.t()
  def get_start_link_opts_docs, do: NimbleOptions.docs(@start_link_opts)

  @spec start_link(Types.service_name(), MscmpSystDb.Types.context_service_name(), Keyword.t()) ::
          {:ok, pid()} | {:error, MscmpSystError.t()}
  def start_link(service_name, datastore_context_name, opts) do
    opts =
      opts
      |> NimbleOptions.validate!(@start_link_opts)
      |> Keyword.put(:name, service_name)

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

  @init_opts NimbleOptions.new!(Keyword.take(option_defs, [:datastore_context_name]))

  @spec get_init_opts_docs() :: String.t()
  def get_init_opts_docs, do: NimbleOptions.docs(@init_opts)

  @impl true
  @spec init(Keyword.t()) :: {:ok, map()} | {:stop, MscmpSystError.t()}
  def init(opts) do
    opts = NimbleOptions.validate!(opts, @init_opts)

    settings_table = :ets.new(nil, [:set, :protected])

    _ = MscmpSystDb.put_datastore_context(opts[:datastore_context_name])

    Impl.Settings.refresh_from_database(settings_table)

    {:ok,
     %{
       datastore_context_name: opts[:datastore_context_name],
       settings_table_tid: settings_table
     }}
  end

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
      Impl.Settings.create_setting(state.settings_table_tid, creation_params),
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
      Impl.Settings.delete_setting(state.settings_table_tid, setting_name),
      state
    }
  end

  @impl true
  def handle_call(:get_settings_table, _from, state),
    do: {:reply, state.settings_table_tid, state}

  @impl true
  def terminate(:normal, state) do
    :ets.delete(state.settings_table_tid)
    :ok
  end
end
