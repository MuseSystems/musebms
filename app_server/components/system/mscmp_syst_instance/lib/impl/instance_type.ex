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

  ##############################################################################
  #
  # create_instance_type
  #
  #

  @spec create_instance_type(Types.instance_type_params()) ::
          {:ok, Msdata.SystEnumItems.t()} | {:error, term()}
  def create_instance_type(instance_type_params) do
    with :ok <- MscmpSystEnums.create_item("instance_types", instance_type_params) do
      case MscmpSystEnums.get_item_by_name("instance_types", instance_type_params.internal_name) do
        nil -> {:error, {:not_found, instance_type_params.internal_name}}
        instance_type -> {:ok, instance_type}
      end
    end
  end

  ##############################################################################
  #
  # get_instance_type_by_name
  #
  #

  @spec get_instance_type_by_name(Types.instance_type_name()) :: Msdata.SystEnumItems.t() | nil
  def get_instance_type_by_name(instance_type_name),
    do: MscmpSystEnums.get_item_by_name("instance_types", instance_type_name)

  ##############################################################################
  #
  # get_instance_type_default
  #
  #

  @spec get_instance_type_default :: Msdata.SystEnumItems.t()
  def get_instance_type_default, do: MscmpSystEnums.get_default_item("instance_types")

  ##############################################################################
  #
  # update_instance_type
  #
  #

  @spec update_instance_type(Types.instance_type_name(), Types.instance_type_params()) ::
          {:ok, Msdata.SystEnumItems.t()} | {:error, term()}
  def update_instance_type(instance_type_name, instance_type_params) do
    resolved_final_name = Map.get(instance_type_params, :internal_name, instance_type_name)

    with :ok <-
           MscmpSystEnums.set_item_values(
             "instance_types",
             instance_type_name,
             instance_type_params
           ) do
      case MscmpSystEnums.get_item_by_name("instance_types", resolved_final_name) do
        nil -> {:error, {:not_found, instance_type_name}}
        instance_type -> {:ok, instance_type}
      end
    end
  end

  ##############################################################################
  #
  # delete_instance_type
  #
  #

  @spec delete_instance_type(Types.instance_type_name()) :: :ok | {:error, term()}
  def delete_instance_type(instance_type_name),
    do: MscmpSystEnums.delete_item("instance_types", instance_type_name)
end
