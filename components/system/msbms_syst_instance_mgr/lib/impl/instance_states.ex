# Source File: instance_states.ex
# Location:    components/system/msbms_syst_instance_mgr/lib/impl/instance_states.ex
# Project:     msbms
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https: //muse.systems

defmodule MsbmsSystInstanceMgr.Impl.InstanceStates do
  alias MsbmsSystInstanceMgr.Types

  require Logger

  @moduledoc false

  ######
  #
  # Logic for managing and accessing Instance States enumeration data.
  #
  ######

  @spec list_instance_states() ::
          {:ok, list(MsbmsSystEnums.Data.SystEnumItems.t())} | {:error, MsbmsSystError.t()}
  def list_instance_states do
    {:ok, MsbmsSystEnums.get_sorted_enum_items("instance_states")}
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MsbmsSystError{
          code: :undefined_error,
          message: "Failure retrieving instance states list.",
          cause: error
        }
      }
  end

  @spec create_instance_state(Types.instance_state_params()) ::
          {:ok, MsbmsSystEnums.Data.SystEnumItems.t()} | {:error, MsbmsSystError.t()}
  def create_instance_state(instance_state_params) do
    :ok = MsbmsSystEnums.create_enum_item("instance_states", instance_state_params)

    get_instance_state_by_name(instance_state_params.internal_name)
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MsbmsSystError{
          code: :undefined_error,
          message: "Failure creating new instance state.",
          cause: error
        }
      }
  end

  @spec get_instance_state_by_name(MsbmsSystEnums.Types.enum_item_name()) ::
          {:ok, MsbmsSystEnums.Data.SystEnumItems.t()} | {:error, MsbmsSystError.t()}
  def get_instance_state_by_name(instance_state_name) do
    MsbmsSystEnums.get_enum_items("instance_states")
    |> Enum.find(&(&1.internal_name == instance_state_name))
    |> then(&{:ok, &1})
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MsbmsSystError{
          code: :undefined_error,
          message: "Failure retrieving instance state by name.",
          cause: error
        }
      }
  end

  @spec set_instance_state_values(
          MsbmsSystEnums.Types.enum_item_name(),
          Types.instance_state_params()
        ) ::
          {:ok, MsbmsSystEnums.Data.SystEnumItems.t()} | {:error, MsbmsSystError.t()}
  def set_instance_state_values(instance_state_name, instance_state_params) do
    :ok =
      MsbmsSystEnums.set_enum_item_values(
        "instance_states",
        instance_state_name,
        instance_state_params
      )

    get_instance_state_by_name(instance_state_params[:internal_name] || instance_state_name)
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MsbmsSystError{
          code: :undefined_error,
          message: "Failure setting instance state values.",
          cause: error
        }
      }
  end

  @spec delete_instance_state(MsbmsSystEnums.Types.enum_item_name()) ::
          :ok | {:error, MsbmsSystError.t()}

  def delete_instance_state(instance_state_name) do
    MsbmsSystEnums.delete_enum_item("instance_states", instance_state_name)
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MsbmsSystError{
          code: :undefined_error,
          message: "Failure deleting instance state.",
          cause: error
        }
      }
  end
end
