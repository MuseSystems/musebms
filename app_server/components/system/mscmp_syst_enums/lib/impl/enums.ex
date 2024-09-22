# Source File: enums.ex
# Location:    musebms/components/system/mscmp_syst_enums/lib/impl/enums.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystEnums.Impl.Enums do
  @moduledoc false

  import Ecto.Query

  alias MscmpSystEnums.Runtime.ProcessUtils
  alias MscmpSystEnums.Types

  require Logger

  ######
  #
  # The application logic which is accessed via either the public API defined in
  # MscmpSystEnums or which may be accessed via the
  # MscmpSystEnums.Runtime.Server module.
  #
  ######

  # Note that all data changing functions must be called from the GenServer
  # since we need to change data in the ets tables which are owned by the
  # GenServer and are in "protected" mode.

  ##############################################################################
  #
  # refresh_from_database
  #
  #

  @spec refresh_from_database() :: :ok
  def refresh_from_database, do: ProcessUtils.get_enums_table() |> refresh_from_database()

  @spec refresh_from_database(:ets.table()) :: :ok
  def refresh_from_database(enums_table) when is_atom(enums_table) or is_reference(enums_table) do
    :ets.delete_all_objects(enums_table)

    from(e in Msdata.SystEnums, preload: [enum_items: [:functional_type], functional_types: []])
    |> MscmpSystDb.all()
    |> Enum.each(&:ets.insert(enums_table, {&1.internal_name, &1}))
  end

  ##############################################################################
  #
  # refresh_enum_from_database
  #
  #

  # refresh_enum_from_database/2 is often called after changes to enum data is
  # persisted to the database in order to refresh the cached enum data.  Most of
  # those calls put the refresh step in the same try/rescue block as the main
  # database call.  The issue with this is if the database transaction succeeds
  # while the refresh call fails, the cache will be out of sync with the
  # database.  This scenario is fairly unlikely, but we should definitely
  # consider allowing an outright crash in this case since our state would be
  # invalid and perhaps not regularly recoverable.

  @spec refresh_enum_from_database(Types.enum_name()) :: :ok | {:error, MscmpSystError.t()}
  def refresh_enum_from_database(enum_name),
    do: ProcessUtils.get_enums_table() |> refresh_enum_from_database(enum_name)

  @spec refresh_enum_from_database(:ets.table(), Types.enum_name()) ::
          :ok | {:error, MscmpSystError.t()}
  def refresh_enum_from_database(enums_table, enum_name)
      when is_atom(enums_table) or is_reference(enums_table) do
    from(e in Msdata.SystEnums,
      preload: [enum_items: [:functional_type], functional_types: []],
      where: e.internal_name == ^enum_name
    )
    |> MscmpSystDb.one!()
    |> then(&:ets.insert(enums_table, {&1.internal_name, &1}))

    :ok
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MscmpSystError{
          code: :undefined_error,
          message: "Failure refreshing enumeration from database.",
          cause: error
        }
      }
  end

  ##############################################################################
  #
  # get_values
  #
  #

  @spec get_values(Types.enum_name()) :: Msdata.SystEnums.t()
  def get_values(enum_name),
    do: ProcessUtils.get_enums_table() |> get_values(enum_name)

  @spec get_values(:ets.table(), Types.enum_name()) :: Msdata.SystEnums.t()
  def get_values(enums_table, enum_name)
      when is_atom(enums_table) or is_reference(enums_table) do
    :ets.lookup_element(enums_table, enum_name, 2)
  end

  ##############################################################################
  #
  # list_all
  #
  #

  @spec list_all() :: list(Msdata.SystEnums.t())
  def list_all, do: ProcessUtils.get_enums_table() |> list_all()

  @spec list_all(:ets.table()) :: list(Msdata.SystEnums.t())
  def list_all(enums_table) when is_atom(enums_table) or is_reference(enums_table) do
    # Select query :ets.fun2ms(fn {_, enum_values} -> enum_values end)
    :ets.select(enums_table, [{{:_, :"$1"}, [], [:"$1"]}])
  end

  ##############################################################################
  #
  # get_syst_defined
  #
  #

  @spec get_syst_defined(Types.enum_name()) :: boolean()
  def get_syst_defined(enum_name),
    do: ProcessUtils.get_enums_table() |> get_syst_defined(enum_name)

  @spec get_syst_defined(:ets.table(), Types.enum_name()) :: boolean()
  def get_syst_defined(enums_table, enum_name)
      when is_atom(enums_table) or is_reference(enums_table) do
    :ets.select(enums_table, [{{enum_name, %{syst_defined: :"$1"}}, [], [:"$1"]}])
    |> hd()
  end

  ##############################################################################
  #
  # get_user_maintainable
  #
  #

  @spec get_user_maintainable(Types.enum_name()) :: boolean()
  def get_user_maintainable(enum_name),
    do: ProcessUtils.get_enums_table() |> get_user_maintainable(enum_name)

  @spec get_user_maintainable(:ets.table(), Types.enum_name()) :: boolean()
  def get_user_maintainable(enums_table, enum_name)
      when is_atom(enums_table) or is_reference(enums_table) do
    :ets.select(enums_table, [{{enum_name, %{user_maintainable: :"$1"}}, [], [:"$1"]}])
    |> hd()
  end

  ##############################################################################
  #
  # list_items
  #
  #

  @spec list_items(Types.enum_name()) :: list(Msdata.SystEnumItems.t())
  def list_items(enum_name),
    do: ProcessUtils.get_enums_table() |> list_items(enum_name)

  @spec list_items(:ets.table(), Types.enum_name()) :: list(Msdata.SystEnumItems.t())
  def list_items(enums_table, enum_name)
      when is_atom(enums_table) or is_reference(enums_table) do
    :ets.select(enums_table, [{{enum_name, %{enum_items: :"$1"}}, [], [:"$1"]}])
    |> hd()
  end

  ##############################################################################
  #
  # list_sorted_items
  #
  #

  @spec list_sorted_items(Types.enum_name()) :: list(Msdata.SystEnumItems.t())
  def list_sorted_items(enum_name),
    do: ProcessUtils.get_enums_table() |> list_sorted_items(enum_name)

  @spec list_sorted_items(:ets.table(), Types.enum_name()) :: list(Msdata.SystEnumItems.t())
  def list_sorted_items(enums_table, enum_name)
      when is_atom(enums_table) or is_reference(enums_table) do
    Enum.sort(list_items(enums_table, enum_name), &(&1.sort_order < &2.sort_order))
  end

  ##############################################################################
  #
  # list_functional_types
  #
  #

  @spec list_functional_types(Types.enum_name()) :: list(Msdata.SystEnumFunctionalTypes.t())
  def list_functional_types(enum_name),
    do: ProcessUtils.get_enums_table() |> list_functional_types(enum_name)

  @spec list_functional_types(:ets.table(), Types.enum_name()) ::
          list(Msdata.SystEnumFunctionalTypes.t())
  def list_functional_types(enums_table, enum_name)
      when is_atom(enums_table) or is_reference(enums_table) do
    :ets.select(enums_table, [{{enum_name, %{functional_types: :"$1"}}, [], [:"$1"]}])
    |> hd()
  end

  ##############################################################################
  #
  # get_item_by_name
  #
  #

  @spec get_item_by_name(Types.enum_name(), Types.enum_item_name()) ::
          Msdata.SystEnumItems.t() | nil
  def get_item_by_name(enum_name, enum_item_name),
    do: ProcessUtils.get_enums_table() |> get_item_by_name(enum_name, enum_item_name)

  @spec get_item_by_name(:ets.table(), Types.enum_name(), Types.enum_item_name()) ::
          Msdata.SystEnumItems.t() | nil
  def get_item_by_name(enums_table, enum_name, enum_item_name)
      when is_atom(enums_table) or is_reference(enums_table) do
    list_items(enums_table, enum_name)
    |> Enum.find(&(&1.internal_name == enum_item_name))
  end

  ##############################################################################
  #
  # get_item_by_id
  #
  #

  @spec get_item_by_id(Types.enum_name(), Types.enum_item_id()) ::
          Msdata.SystEnumItems.t() | nil
  def get_item_by_id(enum_name, enum_item_id),
    do: ProcessUtils.get_enums_table() |> get_item_by_id(enum_name, enum_item_id)

  @spec get_item_by_id(:ets.table(), Types.enum_name(), Types.enum_item_id()) ::
          Msdata.SystEnumItems.t() | nil
  def get_item_by_id(enums_table, enum_name, enum_item_id)
      when is_atom(enums_table) or is_reference(enums_table) do
    list_items(enums_table, enum_name)
    |> Enum.find(&(&1.id == enum_item_id))
  end

  ##############################################################################
  #
  # get_default_item
  #
  #

  @spec get_default_item(Types.enum_name(), Keyword.t()) :: Msdata.SystEnumItems.t()
  def get_default_item(enum_name, opts),
    do: ProcessUtils.get_enums_table() |> get_default_item(enum_name, opts)

  @spec get_default_item(:ets.table(), Types.enum_name(), Keyword.t()) ::
          Msdata.SystEnumItems.t()
  def get_default_item(enums_table, enum_name, opts)
      when is_atom(enums_table) or is_reference(enums_table) do
    enums_table
    |> :ets.select([{{enum_name, %{enum_items: :"$1"}}, [], [:"$1"]}])
    |> hd()
    |> Enum.find(fn enum_item ->
      default_enum_item_found?(enum_item, opts[:functional_type_name])
    end)
  end

  ##############################################################################
  #
  # default_enum_item_found?
  #
  #

  defp default_enum_item_found?(enum_item, functional_type_name)
       when is_binary(functional_type_name) do
    enum_item.functional_type.internal_name == functional_type_name and
      enum_item.functional_type_default == true
  end

  defp default_enum_item_found?(enum_item, _functional_type_name) do
    enum_item.enum_default == true
  end

  ##############################################################################
  #
  # create
  #
  #

  @spec create(Types.enum_params()) :: :ok | {:error, MscmpSystError.t()}
  def create(enum_params),
    do: ProcessUtils.get_enums_table() |> create(enum_params)

  @spec create(:ets.table(), Types.enum_params()) :: :ok | {:error, MscmpSystError.t()}
  def create(enums_table, enum_params)
      when is_atom(enums_table) or is_reference(enums_table) do
    {:ok, _} =
      Ecto.Multi.new()
      |> Ecto.Multi.insert(:enum, Msdata.SystEnums.changeset(%Msdata.SystEnums{}, enum_params),
        returning: [:id]
      )
      |> Ecto.Multi.merge(fn %{enum: enum} ->
        Ecto.Multi.new()
        |> create_functional_types_for_enum(enum.id, enum_params)
      end)
      |> Ecto.Multi.merge(fn changes ->
        Ecto.Multi.new()
        |> create_items_for_enum(changes, enum_params)
      end)
      |> MscmpSystDb.transaction()

    refresh_enum_from_database(enums_table, enum_params.internal_name)
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MscmpSystError{
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
        Msdata.SystEnumFunctionalTypes.changeset(
          %Msdata.SystEnumFunctionalTypes{},
          Map.put(functional_type, :enum_id, enum_id)
        ),
        returning: [:id]
      )
    end)
  end

  defp create_functional_types_for_enum(multi, _enum_id, _enum_params), do: multi

  defp create_items_for_enum(multi, changes, %{enum_items: enum_items}) do
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
        Msdata.SystEnumItems.changeset(%Msdata.SystEnumItems{}, resolved_enum_item),
        returning: [:id]
      )
    end)
  end

  defp create_items_for_enum(multi, _changes, _enum_params), do: multi

  ##############################################################################
  #
  # create_functional_type
  #
  #

  @spec create_functional_type(
          Types.enum_name(),
          Types.enum_functional_type_params()
        ) ::
          :ok | {:error, MscmpSystError.t()}
  def create_functional_type(enum_name, functional_type_params),
    do:
      ProcessUtils.get_enums_table()
      |> create_functional_type(enum_name, functional_type_params)

  @spec create_functional_type(
          :ets.table(),
          Types.enum_name(),
          Types.enum_functional_type_params()
        ) ::
          :ok | {:error, MscmpSystError.t()}
  def create_functional_type(enums_table, enum_name, functional_type_params)
      when is_atom(enums_table) or is_reference(enums_table) do
    %Msdata.SystEnums{id: enum_id} = get_values(enums_table, enum_name)

    resolved_functional_type = Map.put(functional_type_params, :enum_id, enum_id)

    %Msdata.SystEnumFunctionalTypes{}
    |> Msdata.SystEnumFunctionalTypes.changeset(resolved_functional_type)
    |> MscmpSystDb.insert!()

    refresh_enum_from_database(enums_table, enum_name)
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MscmpSystError{
          code: :undefined_error,
          message: "Failure creating enumeration functional type.",
          cause: error
        }
      }
  end

  ##############################################################################
  #
  # create_item
  #
  #

  @spec create_item(Types.enum_name(), Types.enum_item_params()) ::
          :ok | {:error, MscmpSystError.t()}
  def create_item(enum_name, enum_item_params),
    do: ProcessUtils.get_enums_table() |> create_item(enum_name, enum_item_params)

  @spec create_item(:ets.table(), Types.enum_name(), Types.enum_item_params()) ::
          :ok | {:error, MscmpSystError.t()}
  def create_item(enums_table, enum_name, enum_item_params)
      when is_atom(enums_table) or is_reference(enums_table) do
    %Msdata.SystEnums{id: enum_id, functional_types: functional_types} =
      get_values(enums_table, enum_name)

    functional_type_id =
      maybe_get_functional_type_id(
        functional_types,
        Map.get(enum_item_params, :functional_type_name)
      )

    resolved_enum_item_params =
      Map.merge(enum_item_params, %{enum_id: enum_id, functional_type_id: functional_type_id})

    %Msdata.SystEnumItems{}
    |> Msdata.SystEnumItems.changeset(resolved_enum_item_params)
    |> MscmpSystDb.insert!()

    refresh_enum_from_database(enums_table, enum_name)
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MscmpSystError{
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
    raise MscmpSystError,
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
    raise MscmpSystError,
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
    raise MscmpSystError,
      code: :undefined_error,
      message: "Failed to resolve functional type ID.",
      cause: %{functional_type_id: functional_type_id}
  end

  ##############################################################################
  #
  # set_values
  #
  #

  @spec set_values(Types.enum_name(), Types.enum_params()) ::
          :ok | {:error, MscmpSystError.t()}
  def set_values(enum_name, enum_params),
    do: ProcessUtils.get_enums_table() |> set_values(enum_name, enum_params)

  @spec set_values(:ets.table(), Types.enum_name(), Types.enum_params()) ::
          :ok | {:error, MscmpSystError.t()}
  def set_values(enums_table, enum_name, enum_params)
      when is_atom(enums_table) or is_reference(enums_table) do
    resolved_internal_name = Map.get(enum_params, :internal_name, enum_name)

    :ets.lookup_element(enums_table, enum_name, 2)
    |> Msdata.SystEnums.changeset(enum_params)
    |> MscmpSystDb.update!()

    if enum_name != resolved_internal_name, do: :ets.delete(enums_table, enum_name)

    refresh_enum_from_database(enums_table, resolved_internal_name)
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MscmpSystError{
          code: :undefined_error,
          message: "Failure setting enumeration values.",
          cause: error
        }
      }
  end

  ##############################################################################
  #
  # set_functional_type_values
  #
  #

  @spec set_functional_type_values(
          Types.enum_name(),
          Types.enum_functional_type_name(),
          Types.enum_functional_type_params()
        ) ::
          :ok | {:error, MscmpSystError.t()}
  def set_functional_type_values(enum_name, functional_type_name, functional_type_params) do
    ProcessUtils.get_enums_table()
    |> set_functional_type_values(enum_name, functional_type_name, functional_type_params)
  end

  @spec set_functional_type_values(
          :ets.table(),
          Types.enum_name(),
          Types.enum_functional_type_name(),
          Types.enum_functional_type_params()
        ) ::
          :ok | {:error, MscmpSystError.t()}
  def set_functional_type_values(
        enums_table,
        enum_name,
        functional_type_name,
        functional_type_params
      )
      when is_atom(enums_table) or is_reference(enums_table) do
    %{functional_types: functional_types} = :ets.lookup_element(enums_table, enum_name, 2)

    Enum.find(functional_types, &(&1.internal_name == functional_type_name))
    |> Msdata.SystEnumFunctionalTypes.changeset(functional_type_params)
    |> MscmpSystDb.update!()

    refresh_enum_from_database(enums_table, enum_name)
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MscmpSystError{
          code: :undefined_error,
          message: "Failure setting enumeration functional type values.",
          cause: error
        }
      }
  end

  ##############################################################################
  #
  # set_item_values
  #
  #

  @spec set_item_values(Types.enum_name(), Types.enum_item_name(), Types.enum_item_params()) ::
          :ok | {:error, MscmpSystError.t()}
  def set_item_values(enum_name, enum_item_name, enum_item_params) do
    ProcessUtils.get_enums_table()
    |> set_item_values(enum_name, enum_item_name, enum_item_params)
  end

  @spec set_item_values(
          :ets.table(),
          Types.enum_name(),
          Types.enum_item_name(),
          Types.enum_item_params()
        ) ::
          :ok | {:error, MscmpSystError.t()}
  def set_item_values(enums_table, enum_name, enum_item_name, enum_item_params)
      when is_atom(enums_table) or is_reference(enums_table) do
    %{enum_items: enum_items} = :ets.lookup_element(enums_table, enum_name, 2)

    Enum.find(enum_items, &(&1.internal_name == enum_item_name))
    |> Msdata.SystEnumItems.changeset(enum_item_params)
    |> MscmpSystDb.update!()

    refresh_enum_from_database(enums_table, enum_name)
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MscmpSystError{
          code: :undefined_error,
          message: "Failure setting enumeration item values.",
          cause: error
        }
      }
  end

  ##############################################################################
  #
  # delete
  #
  #

  @spec delete(Types.enum_name()) :: :ok | {:error, MscmpSystError.t()}
  def delete(enum_name), do: ProcessUtils.get_enums_table() |> delete(enum_name)

  @spec delete(:ets.table(), Types.enum_name()) :: :ok | {:error, MscmpSystError.t()}
  def delete(enums_table, enum_name)
      when is_atom(enums_table) or is_reference(enums_table) do
    delete_qry = from(e in Msdata.SystEnums, where: e.internal_name == ^enum_name)

    {1, _rows} = MscmpSystDb.delete_all(delete_qry)

    true = :ets.delete(enums_table, enum_name)

    :ok
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MscmpSystError{
          code: :undefined_error,
          message: "Failure deleting an enumeration.",
          cause: error
        }
      }
  end

  ##############################################################################
  #
  # delete_functional_type
  #
  #

  @spec delete_functional_type(Types.enum_name(), Types.enum_functional_type_name()) ::
          :ok | {:error, MscmpSystError.t()}
  def delete_functional_type(enum_name, functional_type_name),
    do:
      ProcessUtils.get_enums_table()
      |> delete_functional_type(enum_name, functional_type_name)

  @spec delete_functional_type(
          :ets.table(),
          Types.enum_name(),
          Types.enum_functional_type_name()
        ) ::
          :ok | {:error, MscmpSystError.t()}
  def delete_functional_type(enums_table, enum_name, functional_type_name)
      when is_atom(enums_table) or is_reference(enums_table) do
    delete_qry =
      from(f in Msdata.SystEnumFunctionalTypes, where: f.internal_name == ^functional_type_name)

    {1, _rows} = MscmpSystDb.delete_all(delete_qry)

    refresh_enum_from_database(enums_table, enum_name)
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MscmpSystError{
          code: :undefined_error,
          message: "Failure deleting an enumeration functional type.",
          cause: error
        }
      }
  end

  ##############################################################################
  #
  # delete_item
  #
  #

  @spec delete_item(Types.enum_name(), Types.enum_item_name()) ::
          :ok | {:error, MscmpSystError.t()}
  def delete_item(enum_name, enum_item_name),
    do: ProcessUtils.get_enums_table() |> delete_item(enum_name, enum_item_name)

  @spec delete_item(:ets.table(), Types.enum_name(), Types.enum_item_name()) ::
          :ok | {:error, MscmpSystError.t()}
  def delete_item(enums_table, enum_name, enum_item_name)
      when is_atom(enums_table) or is_reference(enums_table) do
    delete_qry = from(f in Msdata.SystEnumItems, where: f.internal_name == ^enum_item_name)

    {1, _rows} = MscmpSystDb.delete_all(delete_qry)

    refresh_enum_from_database(enums_table, enum_name)
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MscmpSystError{
          code: :undefined_error,
          message: "Failure deleting an enumeration item.",
          cause: error
        }
      }
  end

  ##############################################################################
  #
  # get_functional_type_by_item_id
  #
  #

  @spec get_functional_type_by_item_id(Types.enum_name(), Types.enum_item_id()) ::
          Types.enum_functional_type_name()
  def get_functional_type_by_item_id(enum_name, enum_item_id) do
    enum_item = get_item_by_id(enum_name, enum_item_id)
    enum_item.functional_type.internal_name
  end
end
