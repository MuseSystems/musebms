# Source File: enums.ex
# Location:    musebms/app_server/components/system/mscmp_syst_enums/lib/impl/enums.ex
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

  @spec refresh_enum_from_database(Types.enum_name()) :: :ok | {:error, term()}
  def refresh_enum_from_database(enum_name),
    do: ProcessUtils.get_enums_table() |> refresh_enum_from_database(enum_name)

  @spec refresh_enum_from_database(:ets.table(), Types.enum_name()) ::
          :ok | {:error, term()}
  def refresh_enum_from_database(enums_table, enum_name)
      when is_atom(enums_table) or is_reference(enums_table) do
    enum_qry =
      from(e in Msdata.SystEnums,
        preload: [enum_items: [:functional_type], functional_types: []],
        where: e.internal_name == ^enum_name
      )

    case MscmpSystDb.one(enum_qry) do
      nil -> {:error, {:not_found, enum_name}}
      result -> Msutils.Data.ets_insert(enums_table, {result.internal_name, result})
    end
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
    |> case do
      enum_item when not is_nil(enum_item) -> enum_item
      _ -> raise "No default enum item found for #{inspect(enum_name)}"
    end
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

  @spec create(Types.enum_params()) :: :ok | {:error, term()}
  def create(enum_params),
    do: ProcessUtils.get_enums_table() |> create(enum_params)

  # TODO: Dialyzer check removed due to Elixir 1.19/OTP 28 issue
  #       If that ever gets correcly addressed, we should remove
  #       this bypass.
  @dialyzer {:no_opaque, create: 2}
  @spec create(:ets.table(), Types.enum_params()) :: :ok | {:error, term()}
  def create(enums_table, enum_params)
      when is_atom(enums_table) or is_reference(enums_table) do
    with {:ok, _result} <-
           Ecto.Multi.new()
           |> Ecto.Multi.insert(
             :enum,
             Msdata.SystEnums.changeset(%Msdata.SystEnums{}, enum_params),
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
           |> MscmpSystDb.transaction() do
      refresh_enum_from_database(enums_table, enum_params.internal_name)
    end
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
          :ok | {:error, term()}
  def create_functional_type(enum_name, functional_type_params),
    do:
      ProcessUtils.get_enums_table()
      |> create_functional_type(enum_name, functional_type_params)

  @spec create_functional_type(
          :ets.table(),
          Types.enum_name(),
          Types.enum_functional_type_params()
        ) ::
          :ok | {:error, term()}
  def create_functional_type(enums_table, enum_name, functional_type_params)
      when is_atom(enums_table) or is_reference(enums_table) do
    %Msdata.SystEnums{id: enum_id} = get_values(enums_table, enum_name)

    resolved_functional_type = Map.put(functional_type_params, :enum_id, enum_id)

    with {:ok, _} <-
           %Msdata.SystEnumFunctionalTypes{}
           |> Msdata.SystEnumFunctionalTypes.changeset(resolved_functional_type)
           |> db_insert() do
      refresh_enum_from_database(enums_table, enum_name)
    end
  end

  ##############################################################################
  #
  # create_item
  #
  #

  @spec create_item(Types.enum_name(), Types.enum_item_params()) ::
          :ok | {:error, term()}
  def create_item(enum_name, enum_item_params),
    do: ProcessUtils.get_enums_table() |> create_item(enum_name, enum_item_params)

  @spec create_item(:ets.table(), Types.enum_name(), Types.enum_item_params()) ::
          :ok | {:error, term()}
  def create_item(enums_table, enum_name, enum_item_params)
      when is_atom(enums_table) or is_reference(enums_table) do
    %Msdata.SystEnums{id: enum_id, functional_types: functional_types} =
      get_values(enums_table, enum_name)

    with {:ok, functional_type_id} <-
           maybe_get_functional_type_id(
             functional_types,
             Map.get(enum_item_params, :functional_type_name)
           ),
         resolved_enum_item_params =
           Map.merge(enum_item_params, %{
             enum_id: enum_id,
             functional_type_id: functional_type_id
           }),
         {:ok, _} <-
           %Msdata.SystEnumItems{}
           |> Msdata.SystEnumItems.changeset(resolved_enum_item_params)
           |> db_insert() do
      refresh_enum_from_database(enums_table, enum_name)
    end
  end

  defp maybe_get_functional_type_id(functional_types, functional_type_name)
       when is_list(functional_types) and functional_types != [] and
              is_binary(functional_type_name) do
    case Enum.find(functional_types, fn func_type ->
           func_type.internal_name == functional_type_name
         end) do
      %{id: id} when not is_nil(id) -> {:ok, id}
      _ -> {:error, {:validation_error, :functional_type_not_found}}
    end
  end

  defp maybe_get_functional_type_id(functional_types, functional_type_name)
       when (is_nil(functional_types) or functional_types == []) and
              is_binary(functional_type_name) do
    {:error, {:validation_error, :no_functional_types_defined}}
  end

  defp maybe_get_functional_type_id(functional_types, functional_type_name)
       when is_list(functional_types) and functional_types != [] and
              is_nil(functional_type_name) do
    {:error, {:validation_error, :functional_type_required}}
  end

  defp maybe_get_functional_type_id(_functional_types, _functional_type_name), do: {:ok, nil}

  ##############################################################################
  #
  # set_values
  #
  #

  @spec set_values(Types.enum_name(), Types.enum_params()) ::
          :ok | {:error, term()}
  def set_values(enum_name, enum_params),
    do: ProcessUtils.get_enums_table() |> set_values(enum_name, enum_params)

  @spec set_values(:ets.table(), Types.enum_name(), Types.enum_params()) ::
          :ok | {:error, term()}
  def set_values(enums_table, enum_name, enum_params)
      when is_atom(enums_table) or is_reference(enums_table) do
    resolved_internal_name = Map.get(enum_params, :internal_name, enum_name)

    with {:ok, current_enum} <- Msutils.Data.ets_lookup_element(enums_table, enum_name, 2),
         changeset <- Msdata.SystEnums.changeset(current_enum, enum_params),
         {:ok, _} <- db_update(changeset),
         :ok <- maybe_delete_enum(enums_table, enum_name, resolved_internal_name) do
      refresh_enum_from_database(enums_table, resolved_internal_name)
    end
  end

  defp maybe_delete_enum(enums_table, enum_name, resolved_internal_name)
       when enum_name != resolved_internal_name,
       do: Msutils.Data.ets_delete(enums_table, enum_name)

  defp maybe_delete_enum(_enums_table, _enum_name, _resolved_internal_name), do: :ok

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
          :ok | {:error, term()}
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
          :ok | {:error, term()}
  def set_functional_type_values(
        enums_table,
        enum_name,
        functional_type_name,
        functional_type_params
      )
      when is_atom(enums_table) or is_reference(enums_table) do
    with {:ok, %{functional_types: functional_types}} <-
           Msutils.Data.ets_lookup_element(enums_table, enum_name, 2),
         functional_type when not is_nil(functional_type) <-
           Enum.find(functional_types, &(&1.internal_name == functional_type_name)),
         {:ok, _} <-
           functional_type
           |> Msdata.SystEnumFunctionalTypes.changeset(functional_type_params)
           |> db_update() do
      refresh_enum_from_database(enums_table, enum_name)
    else
      {:error, _} = error -> error
      nil -> {:error, {:not_found, functional_type_name}}
    end
  end

  ##############################################################################
  #
  # set_item_values
  #
  #

  @spec set_item_values(Types.enum_name(), Types.enum_item_name(), Types.enum_item_params()) ::
          :ok | {:error, term()}
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
          :ok | {:error, term()}
  def set_item_values(enums_table, enum_name, enum_item_name, enum_item_params)
      when is_atom(enums_table) or is_reference(enums_table) do
    with {:ok, %{enum_items: enum_items}} <-
           Msutils.Data.ets_lookup_element(enums_table, enum_name, 2),
         enum_item when not is_nil(enum_item) <-
           Enum.find(enum_items, &(&1.internal_name == enum_item_name)),
         {:ok, _} <-
           enum_item
           |> Msdata.SystEnumItems.changeset(enum_item_params)
           |> db_update() do
      refresh_enum_from_database(enums_table, enum_name)
    else
      {:error, _} = error -> error
      nil -> {:error, {:not_found, enum_item_name}}
    end
  end

  ##############################################################################
  #
  # delete
  #
  #

  @spec delete(Types.enum_name()) :: :ok | {:error, term()}
  def delete(enum_name), do: ProcessUtils.get_enums_table() |> delete(enum_name)

  @spec delete(:ets.table(), Types.enum_name()) :: :ok | {:error, term()}
  def delete(enums_table, enum_name)
      when is_atom(enums_table) or is_reference(enums_table) do
    delete_qry = from(s in Msdata.SystEnums, where: s.internal_name == ^enum_name)

    try do
      case MscmpSystDb.delete_all(delete_qry) do
        {1, _rows} -> Msutils.Data.ets_delete(enums_table, enum_name)
        {0, _} -> {:error, {:not_found, enum_name}}
      end
    rescue
      error -> {:error, {:database_error, error}}
    end
  end

  ##############################################################################
  #
  # delete_functional_type
  #
  #

  @spec delete_functional_type(Types.enum_name(), Types.enum_functional_type_name()) ::
          :ok | {:error, term()}
  def delete_functional_type(enum_name, functional_type_name),
    do:
      ProcessUtils.get_enums_table()
      |> delete_functional_type(enum_name, functional_type_name)

  @spec delete_functional_type(
          :ets.table(),
          Types.enum_name(),
          Types.enum_functional_type_name()
        ) ::
          :ok | {:error, term()}
  def delete_functional_type(enums_table, enum_name, functional_type_name)
      when is_atom(enums_table) or is_reference(enums_table) do
    delete_qry =
      from(f in Msdata.SystEnumFunctionalTypes, where: f.internal_name == ^functional_type_name)

    try do
      case MscmpSystDb.delete_all(delete_qry) do
        {1, _rows} -> refresh_enum_from_database(enums_table, enum_name)
        {0, _} -> {:error, {:not_found, functional_type_name}}
      end
    rescue
      error -> {:error, {:database_error, error}}
    end
  end

  ##############################################################################
  #
  # delete_item
  #
  #

  @spec delete_item(Types.enum_name(), Types.enum_item_name()) ::
          :ok | {:error, term()}
  def delete_item(enum_name, enum_item_name),
    do: ProcessUtils.get_enums_table() |> delete_item(enum_name, enum_item_name)

  @spec delete_item(:ets.table(), Types.enum_name(), Types.enum_item_name()) ::
          :ok | {:error, term()}
  def delete_item(enums_table, enum_name, enum_item_name)
      when is_atom(enums_table) or is_reference(enums_table) do
    delete_qry = from(f in Msdata.SystEnumItems, where: f.internal_name == ^enum_item_name)

    try do
      case MscmpSystDb.delete_all(delete_qry) do
        {1, _rows} -> refresh_enum_from_database(enums_table, enum_name)
        {0, _} -> {:error, {:not_found, enum_item_name}}
      end
    rescue
      error -> {:error, {:database_error, error}}
    end
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

  ##############################################################################
  #
  # shared private functions
  #
  #

  # We need to wrap the database insert and update calls in a rescue because the
  # database may return an error if the record being updated is a system defined
  # record and the change is found invalid at the database.  In these cases, the
  # database triggers will raise an exception which becomes a hard error in Ecto.

  defp db_insert(changeset) do
    MscmpSystDb.insert(changeset)
  rescue
    error -> {:error, {:database_error, error}}
  end

  defp db_update(changeset) do
    MscmpSystDb.update(changeset)
  rescue
    error -> {:error, {:database_error, error}}
  end
end
