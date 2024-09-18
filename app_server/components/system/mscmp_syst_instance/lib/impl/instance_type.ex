# Source File: instance_type.ex
# Location:    musebms/components/system/mscmp_syst_instance/lib/impl/instance_type.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystInstance.Impl.InstanceType do
  @moduledoc false

  alias MscmpSystInstance.Types

  require Logger

  ##############################################################################
  #
  # create_instance_type
  #
  #

  @spec create_instance_type(Types.instance_type_params()) ::
          {:ok, Msdata.SystEnumItems.t()} | {:error, MscmpSystError.t()}
  def create_instance_type(instance_type_params) do
    create_enum_item_result =
      MscmpSystEnums.create_enum_item("instance_types", instance_type_params)

    get_change_return_value(instance_type_params.internal_name, create_enum_item_result)
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {:error,
       %MscmpSystError{
         code: :undefined_error,
         message: "Failure creating Instance Type.",
         cause: error
       }}
  end

  ##############################################################################
  #
  # get_instance_type_by_name
  #
  #

  @spec get_instance_type_by_name(Types.instance_type_name()) :: Msdata.SystEnumItems.t() | nil
  def get_instance_type_by_name(instance_type_name),
    do: MscmpSystEnums.get_enum_item_by_name("instance_types", instance_type_name)

  @spec get_instance_type_default :: Msdata.SystEnumItems.t()
  def get_instance_type_default, do: MscmpSystEnums.get_default_enum_item("instance_types")

  @spec update_instance_type(Types.instance_type_name(), Types.instance_type_params()) ::
          {:ok, Msdata.SystEnumItems.t()} | {:error, MscmpSystError.t()}
  def update_instance_type(instance_type_name, instance_type_params) do
    update_enum_item_result =
      MscmpSystEnums.set_enum_item_values(
        "instance_types",
        instance_type_name,
        instance_type_params
      )

    instance_type_name = Map.get(instance_type_params, :internal_name, instance_type_name)

    get_change_return_value(instance_type_name, update_enum_item_result)
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {:error,
       %MscmpSystError{
         code: :undefined_error,
         message: "Failure updating Instance Type.",
         cause: error
       }}
  end

  defp get_change_return_value(instance_type_name, :ok) do
    instance_type = MscmpSystEnums.get_enum_item_by_name("instance_types", instance_type_name)
    {:ok, instance_type}
  end

  defp get_change_return_value(_instance_type_name, result), do: result

  ##############################################################################
  #
  # delete_instance_type
  #
  #

  @spec delete_instance_type(Types.instance_type_name()) :: :ok | {:error, MscmpSystError.t()}
  def delete_instance_type(instance_type_name) do
    MscmpSystEnums.delete_enum_item("instance_types", instance_type_name)
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {:error,
       %MscmpSystError{
         code: :undefined_error,
         message: "Failure deleting Instance Type.",
         cause: error
       }}
  end
end
