# Source File: instance_types.ex
# Location:    components/system/msbms_syst_instance_mgr/lib/impl/instance_types.ex
# Project:     msbms
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https: //muse.systems

defmodule MsbmsSystInstanceMgr.Impl.InstanceTypes do
  alias MsbmsSystInstanceMgr.Types

  require Logger

  @moduledoc false

  ######
  #
  # Logic for managing and accessing Instance Types enumeration data.
  #
  ######

  @spec list_instance_types() ::
          {:ok, list(MsbmsSystEnums.Data.SystEnumItems.t())} | {:error, MsbmsSystError.t()}
  def list_instance_types do
    {:ok, MsbmsSystEnums.get_sorted_enum_items("instance_types")}
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MsbmsSystError{
          code: :undefined_error,
          message: "Failure retrieving instance types list.",
          cause: error
        }
      }
  end

  @spec create_instance_type(Types.instance_type_params()) ::
          {:ok, MsbmsSystEnums.Data.SystEnumItems.t()} | {:error, MsbmsSystError.t()}
  def create_instance_type(instance_type_params) do
    :ok = MsbmsSystEnums.create_enum_item("instance_types", instance_type_params)

    get_instance_type_by_name(instance_type_params.internal_name)
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MsbmsSystError{
          code: :undefined_error,
          message: "Failure creating new instance type.",
          cause: error
        }
      }
  end

  @spec get_instance_type_by_name(MsbmsSystEnums.Types.enum_item_name()) ::
          {:ok, MsbmsSystEnums.Data.SystEnumItems.t()} | {:error, MsbmsSystError.t()}
  def get_instance_type_by_name(instance_type_name) do
    MsbmsSystEnums.get_enum_items("instance_types")
    |> Enum.find(&(&1.internal_name == instance_type_name))
    |> then(&{:ok, &1})
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MsbmsSystError{
          code: :undefined_error,
          message: "Failure retrieving instance type by name.",
          cause: error
        }
      }
  end

  @spec set_instance_type_values(
          MsbmsSystEnums.Types.enum_item_name(),
          Types.instance_type_params()
        ) ::
          {:ok, MsbmsSystEnums.Data.SystEnumItems.t()} | {:error, MsbmsSystError.t()}
  def set_instance_type_values(instance_type_name, instance_type_params) do
    :ok =
      MsbmsSystEnums.set_enum_item_values(
        "instance_types",
        instance_type_name,
        instance_type_params
      )

    get_instance_type_by_name(instance_type_params[:internal_name] || instance_type_name)
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MsbmsSystError{
          code: :undefined_error,
          message: "Failure setting instance type values.",
          cause: error
        }
      }
  end

  @spec delete_instance_type(MsbmsSystEnums.Types.enum_item_name()) ::
          :ok | {:error, MsbmsSystError.t()}
  def delete_instance_type(instance_type_name) do
    MsbmsSystEnums.delete_enum_item("instance_types", instance_type_name)
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MsbmsSystError{
          code: :undefined_error,
          message: "Failure deleting instance type.",
          cause: error
        }
      }
  end
end
