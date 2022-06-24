# Source File: syst_instances.ex
# Location:    components/system/msbms_syst_instance_mgr/lib/data/helpers/syst_instances.ex
# Project:     msbms
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https: //muse.systems

defmodule MsbmsSystInstanceMgr.Data.Helpers.SystInstances do
  import Ecto.Query

  alias MsbmsSystInstanceMgr.Data

  @moduledoc false

  def resolve_name_params(instance_params, operation) do
    instance_params
    |> resolve_application_id()
    |> resolve_instance_type_id(operation)
    |> resolve_instance_state_id(operation)
    |> resolve_owner_id()
    |> resolve_owning_instance_id()
  end

  def resolve_application_id(%{application_name: application_name} = instance_params)
      when is_binary(application_name) do
    from(a in Data.SystApplications, where: a.internal_name == ^application_name, select: a.id)
    |> MsbmsSystDatastore.one!()
    |> then(&Map.put(instance_params, :application_id, &1))
  end

  def resolve_application_id(instance_params), do: instance_params

  def resolve_instance_type_id(
        %{instance_type_name: instance_type_name} = instance_params,
        _operation
      )
      when is_binary(instance_type_name) do
    instance_type = MsbmsSystEnums.get_enum_item_by_name("instance_types", instance_type_name)
    Map.put(instance_params, :instance_type_id, instance_type.id)
  end

  def resolve_instance_type_id(
        %{instance_type_id: instance_type_id} = instance_params,
        _operation
      )
      when is_binary(instance_type_id) do
    instance_params
  end

  def resolve_instance_type_id(instance_params, :insert) do
    default_instance_type = MsbmsSystEnums.get_default_enum_item("instance_types")
    Map.put(instance_params, :instance_type_id, default_instance_type.id)
  end

  def resolve_instance_type_id(instance_params, _operation), do: instance_params

  def resolve_instance_state_id(
        %{instance_state_name: instance_state_name} = instance_params,
        _operation
      )
      when is_binary(instance_state_name) do
    instance_state = MsbmsSystEnums.get_enum_item_by_name("instance_states", instance_state_name)
    Map.put(instance_params, :instance_state_id, instance_state.id)
  end

  def resolve_instance_state_id(
        %{instance_state_id: instance_state_id} = instance_params,
        _operation
      )
      when is_binary(instance_state_id) do
    instance_params
  end

  def resolve_instance_state_id(instance_params, :insert) do
    default_instance_state =
      MsbmsSystEnums.get_default_enum_item("instance_states", "instance_states_uninitialized")

    Map.put(instance_params, :instance_state_id, default_instance_state.id)
  end

  def resolve_instance_state_id(instance_params, _operation), do: instance_params

  def resolve_owner_id(%{owner_name: owner_name} = instance_params)
      when is_binary(owner_name) do
    from(o in Data.SystOwners, where: o.internal_name == ^owner_name, select: o.id)
    |> MsbmsSystDatastore.one!()
    |> then(&Map.put(instance_params, :owner_id, &1))
  end

  def resolve_owner_id(instance_params), do: instance_params

  def resolve_owning_instance_id(
        %{
          owning_instance_name: owning_instance_name
        } = instance_params
      )
      when is_binary(owning_instance_name) do
    from(i in Data.SystInstances, where: i.internal_name == ^owning_instance_name, select: i.id)
    |> MsbmsSystDatastore.one!()
    |> then(&Map.put(instance_params, :owning_instance_id, &1))
  end

  def resolve_owning_instance_id(instance_params), do: instance_params
end
