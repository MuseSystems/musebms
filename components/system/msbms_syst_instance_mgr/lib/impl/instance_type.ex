# Source File: instance_type.ex
# Location:    components/system/msbms_syst_instance_mgr/lib/impl/instance_type.ex
# Project:     msbms
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https: //muse.systems

defmodule MsbmsSystInstanceMgr.Impl.InstanceType do
  require Logger

  @moduledoc false

  # Creates an new Instance Type record in the MsbmsSystEnums module.

  def create_instance_type(instance_type_params) do
    create_enum_item_result =
      MsbmsSystEnums.create_enum_item("instance_types", instance_type_params)

    get_change_return_value(instance_type_params.internal_name, create_enum_item_result)
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MsbmsSystError{
          code: :undefined_error,
          message: "Failure creating Instance Type.",
          cause: error
        }
      }
  end

  def update_instance_type(instance_type_name, instance_type_params) do
    update_enum_item_result =
      MsbmsSystEnums.set_enum_item_values(
        "instance_types",
        instance_type_name,
        instance_type_params
      )

    instance_type_name = Map.get(instance_type_params, :internal_name, instance_type_name)

    get_change_return_value(instance_type_name, update_enum_item_result)
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MsbmsSystError{
          code: :undefined_error,
          message: "Failure updating Instance Type.",
          cause: error
        }
      }
  end

  defp get_change_return_value(instance_type_name, :ok) do
    instance_type = MsbmsSystEnums.get_enum_item_by_name("instance_types", instance_type_name)
    {:ok, instance_type}
  end

  defp get_change_return_value(_instance_type_name, result), do: result

  def delete_instance_type(instance_type_name) do
    MsbmsSystEnums.delete_enum_item("instance_types", instance_type_name)
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MsbmsSystError{
          code: :undefined_error,
          message: "Failure deleting Instance Type.",
          cause: error
        }
      }
  end
end
