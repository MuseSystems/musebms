# Source File: server.ex
# Location:    components/system/msbms_syst_enums/lib/runtime/server.ex
# Project:     msbms
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https: //muse.systems
defmodule MsbmsSystEnums.Runtime.Server do
  use GenServer
  require Logger

  alias MsbmsSystEnums.Impl.Enums
  alias MsbmsSystEnums.Runtime.ProcessUtils

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

  @spec start_link(MsbmsSystEnums.Types.enum_service_params()) ::
          {:ok, pid()} | {:error, MsbmsSystError.t()}
  def start_link({enums_service_name, _datastore_context_name} = params) do
    case GenServer.start_link(__MODULE__, params, name: enums_service_name) do
      {:ok, pid} ->
        {:ok, pid}

      abort_reason ->
        {
          :error,
          %MsbmsSystError{
            code: :process_error,
            message: "Enumerations Service start aborted.",
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
          message: "Failure starting Enumerations Service.",
          cause: error
        }
      }
  end

  ##
  ## Server
  ##

  @impl true
  @spec init(MsbmsSystEnums.Types.enum_service_params()) ::
          {:ok, map()} | {:stop, MsbmsSystError.t()}
  def init({service_name, datastore_context_name}) do
    _ = ProcessUtils.put_enums_service(service_name)

    ets_table_name = Enums.get_ets_table_from_service_name(service_name)

    _ = :ets.new(ets_table_name, [:set, :protected, :named_table])

    _ = MsbmsSystDatastore.set_datastore_context(datastore_context_name)

    Enums.refresh_from_database()

    {:ok,
     %{
       service_name: service_name,
       datastore_context_name: datastore_context_name,
       ets_table_name: ets_table_name
     }}
  end

  @impl true
  def handle_call({:create_enum, creation_params}, _from, state) do
    {
      :reply,
      Enums.create_enum(creation_params),
      state
    }
  end

  @impl true
  def handle_call({:create_enum_functional_type, enum_name, creation_params}, _from, state) do
    {
      :reply,
      Enums.create_enum_functional_type(enum_name, creation_params),
      state
    }
  end

  @impl true
  def handle_call({:create_enum_item, enum_name, creation_params}, _from, state) do
    {
      :reply,
      Enums.create_enum_item(enum_name, creation_params),
      state
    }
  end

  @impl true
  def handle_call({:set_enum_values, enum_name, set_value_params}, _from, state) do
    {
      :reply,
      Enums.set_enum_values(enum_name, set_value_params),
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
      Enums.set_enum_functional_type_values(
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
      Enums.set_enum_item_values(
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
      Enums.delete_enum(enum_name),
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
      Enums.delete_enum_functional_type(enum_name, functional_type_name),
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
      Enums.delete_enum_item(enum_name, enum_item_name),
      state
    }
  end
end
