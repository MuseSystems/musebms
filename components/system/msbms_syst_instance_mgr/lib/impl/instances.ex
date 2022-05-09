# Source File: instances.ex
# Location:    components/system/msbms_syst_instance_mgr/lib/impl/instances.ex
# Project:     msbms
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https: //muse.systems

defmodule MsbmsSystInstanceMgr.Impl.Instances do
  import Ecto.Query

  alias MsbmsSystInstanceMgr.Data
  alias MsbmsSystInstanceMgr.Types

  require Logger

  @moduledoc false

  ######
  #
  # Logic for managing and accessing SystInstances data and supporting data.
  #
  ######

  @spec list_instances(
          Keyword.t(
            instance_types: list(Types.instance_type_name()) | [],
            instance_state_functional_types: list(Types.instance_state_functional_types()) | [],
            owner_id: Ecto.UUID.t() | nil,
            owner_state_functional_types: list(Types.owner_state_functional_types()) | [],
            applications: list(Types.application_name()) | [],
            sort: list(:application | :owner | :instance)
          )
        ) ::
          {:ok, list(Types.instances_list_item())} | {:error, MsbmsSystError.t()}
  def list_instances(opts_given) do
    opts_default = [
      instance_types: [],
      instance_state_functional_types: [],
      owner_id: nil,
      owner_state_functional_types: [],
      applications: [],
      sort: []
    ]

    opts = Keyword.merge(opts_given, opts_default, fn _k, v1, _v2 -> v1 end)

    from(i in Data.SystInstances,
      join: it in assoc(i, :instance_type),
      as: :instance_type,
      join: is in assoc(i, :instance_state),
      as: :instance_state,
      join: isft in assoc(is, :functional_type),
      as: :instance_state_functional_type,
      join: o in assoc(i, :owner),
      as: :owner,
      join: os in assoc(o, :owner_state),
      as: :owner_state,
      join: oft in assoc(os, :functional_type),
      as: :owner_state_functional_type,
      join: a in assoc(i, :application),
      as: :application,
      select: %{
        instance_id: i.id,
        instance_internal_name: i.internal_name,
        instance_display_name: i.display_name,
        instance_owning_instance_id: i.owning_instance_id,
        instance_options: i.instance_options,
        instance_type_id: it.id,
        instance_type_display_name: it.display_name,
        instance_type_external_name: it.external_name,
        instance_state_id: is.id,
        instance_state_display_name: is.display_name,
        instance_state_external_name: is.external_name,
        instance_state_functional_type_id: isft.id,
        instance_state_functional_type_name: isft.internal_name,
        owner_id: o.id,
        owner_display_name: o.display_name,
        owner_state_display_name: os.display_name,
        owner_state_functional_type_name: oft.internal_name,
        owner_state_functional_type_display_name: oft.display_name,
        application_id: a.id,
        application_display_name: a.display_name,
        application_syst_description: a.syst_description
      }
    )
    |> maybe_add_instance_type_filter(opts[:instance_types])
    |> maybe_add_instance_state_filter(opts[:instance_state_functional_types])
    |> maybe_add_owner_state_filter(opts[:owner_state_functional_types])
    |> maybe_add_owner_filter(opts[:owner_id])
    |> maybe_add_application_filter(opts[:applications])
    |> maybe_add_instance_display_name_sorts(opts[:sort])
    |> MsbmsSystDatastore.all()
    |> then(&{:ok, &1})
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MsbmsSystError{
          code: :undefined_error,
          message: "Failure retrieving instances list.",
          cause: error
        }
      }
  end

  defp maybe_add_instance_type_filter(query, [_ | _] = instance_types) do
    from([instance_type: f] in query, where: f.internal_name in ^instance_types)
  end

  defp maybe_add_instance_type_filter(query, _instance_types), do: query

  defp maybe_add_instance_state_filter(query, [_ | _] = functional_types) do
    functional_types
    |> Enum.map(&Atom.to_string/1)
    |> then(&from([instance_type: f] in query, where: f.internal_name in ^&1))
  end

  defp maybe_add_instance_state_filter(query, _functional_types), do: query

  defp maybe_add_owner_filter(query, owner_id) when is_binary(owner_id) do
    from([owner: o] in query, where: o.id == ^owner_id)
  end

  defp maybe_add_owner_filter(query, _owner_id), do: query

  defp maybe_add_owner_state_filter(query, [_ | _] = functional_types) do
    functional_types
    |> Enum.map(&Atom.to_string/1)
    |> then(&from([owner_state_functional_type: f] in query, where: f.internal_name in ^&1))
  end

  defp maybe_add_owner_state_filter(query, _functional_types), do: query

  defp maybe_add_application_filter(query, [_ | _] = applications) do
    from([application: a] in query, where: a.internal_name in ^applications)
  end

  defp maybe_add_application_filter(query, _applications), do: query

  defp maybe_add_instance_display_name_sorts(query, sorts) do
    Enum.reduce(sorts, query, fn sort, qry -> add_instance_sort(qry, sort) end)
  end

  defp add_instance_sort(query, :application) do
    from([application: a] in query, order_by: a.display_name)
  end

  defp add_instance_sort(query, :owner) do
    from([owner: o] in query, order_by: o.display_name)
  end

  defp add_instance_sort(query, :instance) do
    from([i] in query, order_by: i.display_name)
  end

  @spec get_instance_by_name(Types.instance_name()) ::
          {:ok, Data.SystInstances.t()} | {:error, MsbmsSystError.t()}
  def get_instance_by_name(instance_internal_name) do
    child_instance_qry =
      from(i in Data.SystInstances,
        join: ia in assoc(i, :application),
        join: it in assoc(i, :instance_type),
        join: is in assoc(i, :instance_state),
        join: isft in assoc(is, :functional_type),
        preload: [
          application: ia,
          instance_type: it,
          instance_state: {is, functional_type: isft}
        ]
      )

    from(i in Data.SystInstances,
      join: ia in assoc(i, :application),
      join: it in assoc(i, :instance_type),
      join: is in assoc(i, :instance_state),
      join: isft in assoc(is, :functional_type),
      join: io in assoc(i, :owner),
      left_join: oi in assoc(i, :owning_instance),
      where: i.internal_name == ^instance_internal_name,
      preload: [
        application: ia,
        instance_type: it,
        instance_state: {is, functional_type: isft},
        owner: io,
        owning_instance: oi,
        owned_instances: ^child_instance_qry
      ]
    )
    |> MsbmsSystDatastore.one!()
    |> then(&{:ok, &1})
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MsbmsSystError{
          code: :undefined_error,
          message: "Failure retrieving instance record.",
          cause: error
        }
      }
  end

  @spec list_instance_types(MsbmsSystEnums.Types.service_name()) ::
          {:ok, list(MsbmsSystEnums.Data.SystEnumItems.t())} | {:error, MsbmsSystError.t()}
  def list_instance_types(enums_service_name) do
    {:ok, MsbmsSystEnums.get_sorted_enum_items(enums_service_name, "instance_types")}
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

  @spec create_instance_type(
          MsbmsSystEnums.Types.service_name(),
          Types.instance_type()
        ) :: {:ok, MsbmsSystEnums.Data.SystEnumItems.t()} | {:error, MsbmsSystError.t()}
  def create_instance_type(service_name, instance_type_params) do
    :ok = MsbmsSystEnums.create_enum_item(service_name, "instance_types", instance_type_params)

    get_instance_type_by_name(service_name, instance_type_params.internal_name)
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

  @spec get_instance_type_by_name(
          MsbmsSystEnums.Types.service_name(),
          MsbmsSystEnums.Types.enum_item_name()
        ) :: {:ok, MsbmsSystEnums.Data.SystEnumItems.t()} | {:error, MsbmsSystError.t()}
  def get_instance_type_by_name(service_name, instance_type_name) do
    MsbmsSystEnums.get_enum_items(service_name, "instance_types")
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
          MsbmsSystEnums.Types.service_name(),
          MsbmsSystEnums.Types.enum_item_name(),
          Types.instance_type()
        ) :: {:ok, MsbmsSystEnums.Data.SystEnumItems.t()} | {:error, MsbmsSystError.t()}
  def set_instance_type_values(service_name, instance_type_name, instance_type_params) do
    :ok =
      MsbmsSystEnums.set_enum_item_values(
        service_name,
        "instance_types",
        instance_type_name,
        instance_type_params
      )

    get_instance_type_by_name(service_name, instance_type_name)
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

  @spec(
    delete_instance_type(
      MsbmsSystEnums.Types.service_name(),
      MsbmsSystEnums.Types.enum_item_name()
    ) :: :ok,
    {:error, MsbmsSystError.t()}
  )
  def delete_instance_type(service_name, instance_type_name) do
    MsbmsSystEnums.delete_enum_item(service_name, "instance_types", instance_type_name)
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
