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
        {MscmpSystEnums, :start_link,
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
  #

  @impl true
  @spec init(Keyword.t()) :: {:ok, map()} | {:stop, MscmpSystError.t()}
  def init(opts) do
    enums_table = :ets.new(nil, [:set, :protected])

    _ = MscmpSystDb.put_datastore_context(opts[:datastore_context_name])

    Impl.Enums.refresh_from_database(enums_table)

    {:ok,
     %{
       datastore_context_name: opts[:datastore_context_name],
       enums_table_tid: enums_table
     }}
  end

  ##############################################################################
  #
  # handle_call
  #
  #

  @impl true
  def handle_call({:create, creation_params}, _from, state) do
    {
      :reply,
      Impl.Enums.create(state.enums_table_tid, creation_params),
      state
    }
  end

  @impl true
  def handle_call({:create_functional_type, enum_name, creation_params}, _from, state) do
    {
      :reply,
      Impl.Enums.create_functional_type(state.enums_table_tid, enum_name, creation_params),
      state
    }
  end

  @impl true
  def handle_call({:create_item, enum_name, creation_params}, _from, state) do
    {
      :reply,
      Impl.Enums.create_item(state.enums_table_tid, enum_name, creation_params),
      state
    }
  end

  @impl true
  def handle_call({:set_values, enum_name, set_value_params}, _from, state) do
    {
      :reply,
      Impl.Enums.set_values(state.enums_table_tid, enum_name, set_value_params),
      state
    }
  end

  @impl true
  def handle_call(
        {:set_functional_type_values, enum_name, functional_type_name, set_value_params},
        _from,
        state
      ) do
    {
      :reply,
      Impl.Enums.set_functional_type_values(
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
        {:set_item_values, enum_name, enum_item_name, set_value_params},
        _from,
        state
      ) do
    {
      :reply,
      Impl.Enums.set_item_values(
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
        {:delete, enum_name},
        _from,
        state
      ) do
    {
      :reply,
      Impl.Enums.delete(state.enums_table_tid, enum_name),
      state
    }
  end

  @impl true
  def handle_call(
        {:delete_functional_type, enum_name, functional_type_name},
        _from,
        state
      ) do
    {
      :reply,
      Impl.Enums.delete_functional_type(
        state.enums_table_tid,
        enum_name,
        functional_type_name
      ),
      state
    }
  end

  @impl true
  def handle_call(
        {:delete_item, enum_name, enum_item_name},
        _from,
        state
      ) do
    {
      :reply,
      Impl.Enums.delete_item(state.enums_table_tid, enum_name, enum_item_name),
      state
    }
  end

  @impl true
  def handle_call(:get_enums_table, _from, state),
    do: {:reply, state.enums_table_tid, state}

  ##############################################################################
  #
  # terminate
  #
  #

  @impl true
  def terminate(:normal, state) do
    :ets.delete(state.enums_table_tid)
    :ok
  end
end
