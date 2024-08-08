# Source File: service.ex
# Location:    musebms/app_server/components/system/mscmp_syst_enums/lib/runtime/service.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystEnums.Runtime.Service do
  @moduledoc false

  use GenServer

  alias MscmpSystEnums.Impl
  alias MscmpSystEnums.Types

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
            message: "Enumeration Service start aborted.",
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
          message: "Failure starting Enumeration Service.",
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

    enums_table = :ets.new(nil, [:set, :protected])

    _ = MscmpSystDb.put_datastore_context(opts[:datastore_context_name])

    Impl.Enums.refresh_from_database(enums_table)

    {:ok,
     %{
       datastore_context_name: opts[:datastore_context_name],
       enums_table_tid: enums_table
     }}
  end

  @impl true
  def handle_call({:create_enum, creation_params}, _from, state) do
    {
      :reply,
      Impl.Enums.create_enum(state.enums_table_tid, creation_params),
      state
    }
  end

  @impl true
  def handle_call({:create_enum_functional_type, enum_name, creation_params}, _from, state) do
    {
      :reply,
      Impl.Enums.create_enum_functional_type(state.enums_table_tid, enum_name, creation_params),
      state
    }
  end

  @impl true
  def handle_call({:create_enum_item, enum_name, creation_params}, _from, state) do
    {
      :reply,
      Impl.Enums.create_enum_item(state.enums_table_tid, enum_name, creation_params),
      state
    }
  end

  @impl true
  def handle_call({:set_enum_values, enum_name, set_value_params}, _from, state) do
    {
      :reply,
      Impl.Enums.set_enum_values(state.enums_table_tid, enum_name, set_value_params),
      state
    }
  end

  @impl true
  def handle_call(
        {:set_enum_functional_type_values, enum_name, functional_type_name, set_value_params},
        _from,
        state
      ) do
    {
      :reply,
      Impl.Enums.set_enum_functional_type_values(
        state.enums_table_tid,
        enum_name,
        functional_type_name,
        set_value_params
      ),
      state
    }
  end

  @impl true
  def handle_call(
        {:set_enum_item_values, enum_name, enum_item_name, set_value_params},
        _from,
        state
      ) do
    {
      :reply,
      Impl.Enums.set_enum_item_values(
        state.enums_table_tid,
        enum_name,
        enum_item_name,
        set_value_params
      ),
      state
    }
  end

  @impl true
  def handle_call(
        {:delete_enum, enum_name},
        _from,
        state
      ) do
    {
      :reply,
      Impl.Enums.delete_enum(state.enums_table_tid, enum_name),
      state
    }
  end

  @impl true
  def handle_call(
        {:delete_enum_functional_type, enum_name, functional_type_name},
        _from,
        state
      ) do
    {
      :reply,
      Impl.Enums.delete_enum_functional_type(
        state.enums_table_tid,
        enum_name,
        functional_type_name
      ),
      state
    }
  end

  @impl true
  def handle_call(
        {:delete_enum_item, enum_name, enum_item_name},
        _from,
        state
      ) do
    {
      :reply,
      Impl.Enums.delete_enum_item(state.enums_table_tid, enum_name, enum_item_name),
      state
    }
  end

  @impl true
  def handle_call(:get_enums_table, _from, state),
    do: {:reply, state.enums_table_tid, state}

  @impl true
  def terminate(:normal, state) do
    :ets.delete(state.enums_table_tid)
    :ok
  end
end
