# Source File: enums.ex
# Location:    components/system/msbms_syst_enums/lib/impl/enums.ex
# Project:     msbms
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https: //muse.systems

defmodule MsbmsSystEnums.Impl.Enums do
  import Ecto.Query

  alias MsbmsSystEnums.Data
  alias MsbmsSystEnums.Runtime.ProcessUtils
  alias MsbmsSystEnums.Types

  require Logger

  @moduledoc false

  ######
  #
  # The application logic which is accessed via either the public API defined in
  # MsbmsSystEnums or which may be accessed via the
  # MsbmsSystEnums.Runtime.Server module.
  #
  ######

  # Note that all data changing functions must be called from the GenServer
  # since we need to change data in the ets tables which are owned by the
  # GenServer and are in "protected" mode.

  @spec refresh_from_database() :: :ok
  def refresh_from_database do
    ets_table_name = get_ets_table_from_service_name(ProcessUtils.get_enums_service())

    :ets.delete_all_objects(ets_table_name)

    from(e in Data.SystEnums,
      preload: [enum_items: [:functional_type], functional_types: []]
    )
    |> MsbmsSystDatastore.all()
    |> Enum.each(&:ets.insert(ets_table_name, {&1.internal_name, &1}))
  end

  # refresh_enum_from_database/2 is often called after changes to enum data is
  # persisted to the database in order to refresh the cached enum data.  Most of
  # those calls put the refresh step in the same try/rescue block as the main
  # database call.  The issue with this is if the database transaction succeeds
  # while the refresh call fails, the cache will be out of sync with the
  # database.  This scenario is fairly unlikely, but we should definitely
  # consider allowing an outright crash in this case since our state would be
  # invalid and perhaps not regularly recoverable.

  @spec refresh_enum_from_database(Types.enum_name()) :: :ok | {:error, MsbmsSystError.t()}
  def refresh_enum_from_database(enum_name) do
    ets_table_name = get_ets_table_from_service_name(ProcessUtils.get_enums_service())

    from(e in Data.SystEnums,
      preload: [enum_items: [:functional_type], functional_types: []],
      where: e.internal_name == ^enum_name
    )
    |> MsbmsSystDatastore.one!()
    |> then(&:ets.insert(ets_table_name, {&1.internal_name, &1}))

    :ok
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MsbmsSystError{
          code: :undefined_error,
          message: "Failure refreshing enumeration from database.",
          cause: error
        }
      }
  end

  @spec get_enum_values(Types.enum_name()) :: Data.SystEnums.t()
  def get_enum_values(enum_name) do
    ProcessUtils.get_enums_service()
    |> get_ets_table_from_service_name()
    |> :ets.lookup_element(enum_name, 2)
  end

  @spec list_all_enums() :: list(Data.SystEnums.t())
  def list_all_enums do
    # Select query :ets.fun2ms(fn {_, enum_values} -> enum_values end)
    ProcessUtils.get_enums_service()
    |> get_ets_table_from_service_name()
    |> :ets.select([{{:_, :"$1"}, [], [:"$1"]}])
  end

  @spec get_enum_syst_defined(Types.enum_name()) :: boolean()
  def get_enum_syst_defined(enum_name) do
    ProcessUtils.get_enums_service()
    |> get_ets_table_from_service_name()
    |> :ets.select([{{enum_name, %{syst_defined: :"$1"}}, [], [:"$1"]}])
    |> hd()
  end

  @spec get_enum_user_maintainable(Types.enum_name()) :: boolean()
  def get_enum_user_maintainable(enum_name) do
    ProcessUtils.get_enums_service()
    |> get_ets_table_from_service_name()
    |> :ets.select([{{enum_name, %{user_maintainable: :"$1"}}, [], [:"$1"]}])
    |> hd()
  end

  @spec list_enum_items(Types.enum_name()) :: list(Data.SystEnumItems.t())
  def list_enum_items(enum_name) do
    ProcessUtils.get_enums_service()
    |> get_ets_table_from_service_name()
    |> :ets.select([{{enum_name, %{enum_items: :"$1"}}, [], [:"$1"]}])
    |> hd()
  end

  @spec list_sorted_enum_items(Types.enum_name()) :: list(Data.SystEnumItems.t())
  def list_sorted_enum_items(enum_name) do
    Enum.sort(list_enum_items(enum_name), &(&1.sort_order < &2.sort_order))
  end

  @spec list_enum_functional_types(Types.enum_name()) :: list(Data.SystEnumFunctionalTypes.t())
  def list_enum_functional_types(enum_name) do
    ProcessUtils.get_enums_service()
    |> get_ets_table_from_service_name()
    |> :ets.select([{{enum_name, %{functional_types: :"$1"}}, [], [:"$1"]}])
    |> hd()
  end

  @spec get_enum_item_by_name(Types.enum_name(), Types.enum_item_name()) :: Data.SystEnumItems.t()
  def get_enum_item_by_name(enum_name, enum_item_name) do
    list_enum_items(enum_name)
    |> Enum.find(&(&1.internal_name == enum_item_name))
  end

  @spec get_enum_item_by_id(Types.enum_name(), Types.enum_item_id()) :: Data.SystEnumItems.t()
  def get_enum_item_by_id(enum_name, enum_item_id) do
    list_enum_items(enum_name)
    |> Enum.find(&(&1.id == enum_item_id))
  end

  @spec get_default_enum_item(
          Types.enum_name(),
          Keyword.t(functional_type_name: Types.enum_functional_type_name()) | []
        ) :: Data.SystEnumItems.t()
  def get_default_enum_item(enum_name, opts) do
    ProcessUtils.get_enums_service()
    |> get_ets_table_from_service_name()
    |> :ets.select([{{enum_name, %{enum_items: :"$1"}}, [], [:"$1"]}])
    |> hd()
    |> Enum.find(fn enum_item ->
      default_enum_item_found?(enum_item, opts[:functional_type_name])
    end)
  end

  defp default_enum_item_found?(enum_item, functional_type_name)
       when is_binary(functional_type_name) do
    enum_item.functional_type.internal_name == functional_type_name and
      enum_item.functional_type_default == true
  end

  defp default_enum_item_found?(enum_item, _functional_type_name) do
    enum_item.enum_default == true
  end

  @spec create_enum(Types.enum_params()) :: :ok | {:error, MsbmsSystError.t()}
  def create_enum(enum_params) do
    {:ok, _} =
      Ecto.Multi.new()
      |> Ecto.Multi.insert(:enum, Data.SystEnums.changeset(%Data.SystEnums{}, enum_params),
        returning: [:id]
      )
      |> Ecto.Multi.merge(fn %{enum: enum} ->
        Ecto.Multi.new()
        |> create_functional_types_for_enum(enum.id, enum_params)
      end)
      |> Ecto.Multi.merge(fn changes ->
        Ecto.Multi.new()
        |> create_enum_items_for_enum(changes, enum_params)
      end)
      |> MsbmsSystDatastore.transaction()

    refresh_enum_from_database(enum_params.internal_name)
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MsbmsSystError{
          code: :undefined_error,
          message: "Failure creating enumeration.",
          cause: error
        }
      }
  end

  defp create_functional_types_for_enum(multi, enum_id, %{functional_types: functional_types}) do
    Enum.reduce(functional_types, multi, fn functional_type, multi ->
      Ecto.Multi.insert(
        multi,
        {:functional_type, functional_type.internal_name},
        Data.SystEnumFunctionalTypes.changeset(
          %Data.SystEnumFunctionalTypes{},
          Map.put(functional_type, :enum_id, enum_id)
        ),
        returning: [:id]
      )
    end)
  end

  defp create_functional_types_for_enum(multi, _enum_id, _enum_params), do: multi

  defp create_enum_items_for_enum(multi, changes, %{enum_items: enum_items}) do
    Enum.reduce(enum_items, multi, fn enum_item, multi ->
      resolved_enum_item =
        if Map.has_key?(enum_item, :functional_type_name) do
          %{id: functional_type_id} =
            Map.get(changes, {:functional_type, enum_item.functional_type_name})

          Map.merge(enum_item, %{functional_type_id: functional_type_id, enum_id: changes.enum.id})
        else
          Map.merge(enum_item, %{enum_id: changes.enum.id})
        end

      Ecto.Multi.insert(
        multi,
        {:enum_item, enum_item.internal_name},
        Data.SystEnumItems.changeset(%Data.SystEnumItems{}, resolved_enum_item),
        returning: [:id]
      )
    end)
  end

  defp create_enum_items_for_enum(multi, _changes, _enum_params), do: multi

  @spec create_enum_functional_type(Types.enum_name(), Types.enum_functional_type_params()) ::
          :ok | {:error, MsbmsSystError.t()}
  def create_enum_functional_type(enum_name, functional_type_params) do
    %Data.SystEnums{id: enum_id} = get_enum_values(enum_name)

    resolved_functional_type = Map.put(functional_type_params, :enum_id, enum_id)

    %Data.SystEnumFunctionalTypes{}
    |> Data.SystEnumFunctionalTypes.changeset(resolved_functional_type)
    |> MsbmsSystDatastore.insert!()

    refresh_enum_from_database(enum_name)
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MsbmsSystError{
          code: :undefined_error,
          message: "Failure creating enumeration functional type.",
          cause: error
        }
      }
  end

  @spec create_enum_item(Types.enum_name(), Types.enum_item_params()) ::
          :ok | {:error, MsbmsSystError.t()}
  def create_enum_item(enum_name, enum_item_params) do
    %Data.SystEnums{id: enum_id, functional_types: functional_types} = get_enum_values(enum_name)

    functional_type_id =
      maybe_get_functional_type_id(
        functional_types,
        Map.get(enum_item_params, :functional_type_name)
      )

    resolved_enum_item_params =
      Map.merge(enum_item_params, %{enum_id: enum_id, functional_type_id: functional_type_id})

    %Data.SystEnumItems{}
    |> Data.SystEnumItems.changeset(resolved_enum_item_params)
    |> MsbmsSystDatastore.insert!()

    refresh_enum_from_database(enum_name)
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MsbmsSystError{
          code: :undefined_error,
          message: "Failure creating enumeration item.",
          cause: error
        }
      }
  end

  defp maybe_get_functional_type_id(functional_types, functional_type_name)
       when is_list(functional_types) and length(functional_types) > 0 and
              is_binary(functional_type_name) do
    Enum.find(functional_types, fn func_type ->
      func_type.internal_name == functional_type_name
    end)
    |> Map.get(:id)
    |> validated_functional_type_id!()
  end

  defp maybe_get_functional_type_id(functional_types, functional_type_name)
       when (is_nil(functional_types) or functional_types == []) and
              is_binary(functional_type_name) do
    raise MsbmsSystError,
      code: :undefined_error,
      message: "New enum item requests a functional type but the enumeration has none.",
      cause: %{
        functional_types: functional_types,
        functional_type_name: functional_type_name
      }
  end

  defp maybe_get_functional_type_id(functional_types, functional_type_name)
       when is_list(functional_types) and length(functional_types) > 0 and
              is_nil(functional_type_name) do
    raise MsbmsSystError,
      code: :undefined_error,
      message: "New enum item for this enumeration must identify a functional type.",
      cause: %{
        functional_types: functional_types,
        functional_type_name: functional_type_name
      }
  end

  defp maybe_get_functional_type_id(_functional_types, _functional_type_name), do: nil

  defp validated_functional_type_id!(functional_type_id) when is_binary(functional_type_id),
    do: functional_type_id

  defp validated_functional_type_id!(functional_type_id) do
    raise MsbmsSystError,
      code: :undefined_error,
      message: "Failed to resolve functional type ID.",
      cause: %{functional_type_id: functional_type_id}
  end

  @spec set_enum_values(Types.enum_name(), Types.enum_params()) ::
          :ok | {:error, MsbmsSystError.t()}
  def set_enum_values(enum_name, enum_params) do
    ets_table_name = get_ets_table_from_service_name(ProcessUtils.get_enums_service())

    resolved_internal_name = Map.get(enum_params, :internal_name, enum_name)

    :ets.lookup_element(ets_table_name, enum_name, 2)
    |> Data.SystEnums.changeset(enum_params)
    |> MsbmsSystDatastore.update!()

    if enum_name != resolved_internal_name, do: :ets.delete(ets_table_name, enum_name)

    refresh_enum_from_database(resolved_internal_name)
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MsbmsSystError{
          code: :undefined_error,
          message: "Failure setting enumeration values.",
          cause: error
        }
      }
  end

  @spec set_enum_functional_type_values(
          Types.enum_name(),
          Types.enum_functional_type_name(),
          Types.enum_functional_type_params()
        ) ::
          :ok | {:error, MsbmsSystError.t()}
  def set_enum_functional_type_values(
        enum_name,
        functional_type_name,
        functional_type_params
      ) do
    ets_table_name = get_ets_table_from_service_name(ProcessUtils.get_enums_service())

    %{functional_types: functional_types} = :ets.lookup_element(ets_table_name, enum_name, 2)

    Enum.find(functional_types, &(&1.internal_name == functional_type_name))
    |> Data.SystEnumFunctionalTypes.changeset(functional_type_params)
    |> MsbmsSystDatastore.update!()

    refresh_enum_from_database(enum_name)
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MsbmsSystError{
          code: :undefined_error,
          message: "Failure setting enumeration functional type values.",
          cause: error
        }
      }
  end

  @spec set_enum_item_values(Types.enum_name(), Types.enum_item_name(), Types.enum_item_params()) ::
          :ok | {:error, MsbmsSystError.t()}
  def set_enum_item_values(enum_name, enum_item_name, enum_item_params) do
    ets_table_name = get_ets_table_from_service_name(ProcessUtils.get_enums_service())

    %{enum_items: enum_items} = :ets.lookup_element(ets_table_name, enum_name, 2)

    Enum.find(enum_items, &(&1.internal_name == enum_item_name))
    |> Data.SystEnumItems.changeset(enum_item_params)
    |> MsbmsSystDatastore.update!()

    refresh_enum_from_database(enum_name)
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MsbmsSystError{
          code: :undefined_error,
          message: "Failure setting enumeration item values.",
          cause: error
        }
      }
  end

  @spec delete_enum(Types.enum_name()) :: :ok | {:error, MsbmsSystError.t()}
  def delete_enum(enum_name) do
    ets_table_name = get_ets_table_from_service_name(ProcessUtils.get_enums_service())

    delete_qry = from(e in Data.SystEnums, where: e.internal_name == ^enum_name)

    {1, _rows} = MsbmsSystDatastore.delete_all(delete_qry)

    true = :ets.delete(ets_table_name, enum_name)

    :ok
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MsbmsSystError{
          code: :undefined_error,
          message: "Failure deleting an enumeration.",
          cause: error
        }
      }
  end

  @spec delete_enum_functional_type(Types.enum_name(), Types.enum_functional_type_name()) ::
          :ok | {:error, MsbmsSystError.t()}
  def delete_enum_functional_type(enum_name, functional_type_name) do
    delete_qry =
      from(f in Data.SystEnumFunctionalTypes,
        where: f.internal_name == ^functional_type_name
      )

    {1, _rows} = MsbmsSystDatastore.delete_all(delete_qry)

    refresh_enum_from_database(enum_name)
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MsbmsSystError{
          code: :undefined_error,
          message: "Failure deleting an enumeration functional type.",
          cause: error
        }
      }
  end

  @spec delete_enum_item(Types.enum_name(), Types.enum_item_name()) ::
          :ok | {:error, MsbmsSystError.t()}
  def delete_enum_item(enum_name, enum_item_name) do
    delete_qry = from(f in Data.SystEnumItems, where: f.internal_name == ^enum_item_name)

    {1, _rows} = MsbmsSystDatastore.delete_all(delete_qry)

    refresh_enum_from_database(enum_name)
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MsbmsSystError{
          code: :undefined_error,
          message: "Failure deleting an enumeration item.",
          cause: error
        }
      }
  end

  @spec get_functional_type_by_enum_item_id(Types.enum_name(), Types.enum_item_id()) ::
          Types.enum_functional_type_name()
  def get_functional_type_by_enum_item_id(enum_name, enum_item_id) do
    enum_item = get_enum_item_by_id(enum_name, enum_item_id)
    enum_item.functional_type.internal_name
  end

  @spec get_ets_table_from_service_name(Types.service_name()) :: atom()
  def get_ets_table_from_service_name(service_name) when is_atom(service_name), do: service_name

  def get_ets_table_from_service_name({:via, _module, service_name})
      when is_atom(service_name),
      do: service_name

  def get_ets_table_from_service_name({:via, _module, {_reg, service_name}})
      when is_atom(service_name),
      do: service_name
end
