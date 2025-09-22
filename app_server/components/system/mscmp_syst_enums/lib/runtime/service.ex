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

  @impl true
  def handle_call(:get_runtime_config, _from, state) do
    runtime_config = %{
      enums_table: state.enums_table_tid
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
    :ets.delete(state.enums_table_tid)
    :ok
  end
end
