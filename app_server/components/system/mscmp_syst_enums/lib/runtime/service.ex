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
       enums_table: enums_table
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
      Impl.Enums.create(state.enums_table, creation_params),
      state
    }
  end

  @impl true
  def handle_call({:create_functional_type, enum_name, creation_params}, _from, state) do
    {
      :reply,
      Impl.Enums.create_functional_type(state.enums_table, enum_name, creation_params),
      state
    }
  end

  @impl true
  def handle_call({:create_item, enum_name, creation_params}, _from, state) do
    {
      :reply,
      Impl.Enums.create_item(state.enums_table, enum_name, creation_params),
      state
    }
  end

  @impl true
  def handle_call({:set_values, enum_name, set_value_params}, _from, state) do
    {
      :reply,
      Impl.Enums.set_values(state.enums_table, enum_name, set_value_params),
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
        state.enums_table,
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
        state.enums_table,
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
      Impl.Enums.delete(state.enums_table, enum_name),
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
        state.enums_table,
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
      Impl.Enums.delete_item(state.enums_table, enum_name, enum_item_name),
      state
    }
  end

  @impl true
  def handle_call(:get_enums_table, _from, state),
    do: {:reply, state.enums_table, state}

  @impl true
  def handle_call(:get_runtime_config, _from, state), do: {:reply, state, state}

  ##############################################################################
  #
  # terminate
  #
  #

  @impl true
  def terminate(_reason, state) do
    :ets.delete(state.enums_table)
    :ok
  end
end
