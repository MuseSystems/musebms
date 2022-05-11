# Source File: owner_states.ex
# Location:    components/system/msbms_syst_instance_mgr/lib/impl/owner_states.ex
# Project:     msbms
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https: //muse.systems

defmodule MsbmsSystInstanceMgr.Impl.OwnerStates do
  alias MsbmsSystInstanceMgr.Types

  require Logger

  @moduledoc false

  ######
  #
  # Logic for managing and accessing Owner States enumeration data.
  #
  ######

  @spec list_owner_states() ::
          {:ok, list(MsbmsSystEnums.Data.SystEnumItems.t())} | {:error, MsbmsSystError.t()}
  def list_owner_states do
    {:ok, MsbmsSystEnums.get_sorted_enum_items("owner_states")}
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MsbmsSystError{
          code: :undefined_error,
          message: "Failure retrieving owner states list.",
          cause: error
        }
      }
  end

  @spec create_owner_state(Types.owner_state()) ::
          {:ok, MsbmsSystEnums.Data.SystEnumItems.t()} | {:error, MsbmsSystError.t()}
  def create_owner_state(owner_state_params) do
    :ok = MsbmsSystEnums.create_enum_item("owner_states", owner_state_params)

    get_owner_state_by_name(owner_state_params.internal_name)
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MsbmsSystError{
          code: :undefined_error,
          message: "Failure creating new owner state.",
          cause: error
        }
      }
  end

  @spec get_owner_state_by_name(MsbmsSystEnums.Types.enum_item_name()) ::
          {:ok, MsbmsSystEnums.Data.SystEnumItems.t()} | {:error, MsbmsSystError.t()}
  def get_owner_state_by_name(owner_state_name) do
    MsbmsSystEnums.get_enum_items("owner_states")
    |> Enum.find(&(&1.internal_name == owner_state_name))
    |> then(&{:ok, &1})
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MsbmsSystError{
          code: :undefined_error,
          message: "Failure retrieving owner state by name.",
          cause: error
        }
      }
  end

  @spec set_owner_state_values(MsbmsSystEnums.Types.enum_item_name(), Types.owner_state()) ::
          {:ok, MsbmsSystEnums.Data.SystEnumItems.t()} | {:error, MsbmsSystError.t()}
  def set_owner_state_values(owner_state_name, owner_state_params) do
    :ok =
      MsbmsSystEnums.set_enum_item_values(
        "owner_states",
        owner_state_name,
        owner_state_params
      )

    get_owner_state_by_name(owner_state_params[:internal_name] || owner_state_name)
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MsbmsSystError{
          code: :undefined_error,
          message: "Failure setting owner state values.",
          cause: error
        }
      }
  end

  @spec delete_owner_state(MsbmsSystEnums.Types.enum_item_name()) ::
          :ok | {:error, MsbmsSystError.t()}

  def delete_owner_state(owner_state_name) do
    MsbmsSystEnums.delete_enum_item("owner_states", owner_state_name)
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MsbmsSystError{
          code: :undefined_error,
          message: "Failure deleting owner state.",
          cause: error
        }
      }
  end
end
