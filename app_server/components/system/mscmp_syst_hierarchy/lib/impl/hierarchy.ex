# Source File: hierarchy.ex
# Location:    musebms/app_server/components/system/mscmp_syst_hierarchy/lib/impl/hierarchy.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystHierarchy.Impl.Hierarchy do
  @moduledoc false

  import Ecto.Query

  alias MscmpSystHierarchy.Types

  require Logger

  ##############################################################################
  #
  # Options Definition
  #
  #

  option_defs = [
    sorted: [
      type: :boolean,
      default: true,
      doc: """
      When true, the hierarchy types will be returned in sorted order.
      """
    ]
  ]

  #
  # Hierarchy Type
  #

  ##############################################################################
  #
  # get_hierarchy_type_by_name
  #
  #

  @spec get_hierarchy_type_by_name(Types.hierarchy_type_name()) :: Msdata.SystEnumItems.t() | nil
  def get_hierarchy_type_by_name(type_name) when is_binary(type_name),
    do: MscmpSystEnums.get_enum_item_by_name("hierarchy_types", type_name)

  ##############################################################################
  #
  # get_hierarchy_type_id_by_name
  #
  #

  @spec get_hierarchy_type_id_by_name(Types.hierarchy_type_name()) ::
          Types.hierarchy_type_id() | nil
  def get_hierarchy_type_id_by_name(type_name) when is_binary(type_name) do
    case get_hierarchy_type_by_name(type_name) do
      %Msdata.SystEnumItems{id: type_id} -> type_id
      nil -> nil
    end
  end

  ##############################################################################
  #
  # list_hierarchy_types
  #
  #

  @list_hierarchy_types_opts NimbleOptions.new!(Keyword.take(option_defs, [:sorted]))

  @spec get_list_hierarchy_types_opts_docs() :: String.t()
  def get_list_hierarchy_types_opts_docs, do: NimbleOptions.docs(@list_hierarchy_types_opts)

  @spec list_hierarchy_types!(Keyword.t()) :: [Msdata.SystEnumItems.t()]
  def list_hierarchy_types!(opts) do
    opts = NimbleOptions.validate!(opts, @list_hierarchy_types_opts)

    if opts[:sorted],
      do: MscmpSystEnums.list_sorted_enum_items("hierarchy_types"),
      else: MscmpSystEnums.list_enum_items("hierarchy_types")
  end

  @spec list_hierarchy_types(Keyword.t()) ::
          {:ok, [Msdata.SystEnumItems.t()]} | {:error, MscmpSystError.t()}
  def list_hierarchy_types(opts) do
    {:ok, list_hierarchy_types!(opts)}
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {:error,
       %MscmpSystError{
         code: :undefined_error,
         message: "Failure retrieving Hierarchy Types List.",
         cause: error
       }}
  end

  #
  # Hierarchy State
  #

  ##############################################################################
  #
  # get_hierarchy_state_by_name
  #
  #

  @spec get_hierarchy_state_by_name(Types.hierarchy_state_name()) ::
          Msdata.SystEnumItems.t() | nil
  def get_hierarchy_state_by_name(state_name) when is_binary(state_name),
    do: MscmpSystEnums.get_enum_item_by_name("hierarchy_states", state_name)

  @spec get_hierarchy_state_id_by_name(Types.hierarchy_state_name()) ::
          Types.hierarchy_state_id() | nil
  def get_hierarchy_state_id_by_name(state_name) when is_binary(state_name) do
    case get_hierarchy_state_by_name(state_name) do
      %Msdata.SystEnumItems{id: state_id} -> state_id
      nil -> nil
    end
  end

  ##############################################################################
  #
  # get_hierarchy_state_default
  #
  #

  @spec get_hierarchy_state_default(Types.hierarchy_state_functional_types() | nil) ::
          Msdata.SystEnumItems.t()
  def get_hierarchy_state_default(nil),
    do: MscmpSystEnums.get_default_enum_item("hierarchy_states")

  def get_hierarchy_state_default(functional_type) when is_atom(functional_type) do
    MscmpSystEnums.get_default_enum_item("hierarchy_states",
      functional_type_name: Atom.to_string(functional_type)
    )
  end

  ##############################################################################
  #
  # get_hierarchy_state_default_id
  #
  #

  @spec get_hierarchy_state_default_id(Types.hierarchy_state_functional_types() | nil) ::
          Types.hierarchy_state_id()
  def get_hierarchy_state_default_id(functional_type)
      when is_atom(functional_type) or is_nil(functional_type) do
    %Msdata.SystEnumItems{id: state_id} = get_hierarchy_state_default(functional_type)
    state_id
  end

  #
  # Hierarchy
  #

  ##############################################################################
  #
  # get_hierarchy_id_by_name
  #
  #

  @spec get_hierarchy_id_by_name!(Types.hierarchy_name()) :: Types.hierarchy_id()
  def get_hierarchy_id_by_name!(hierarchy_name) do
    from(h in Msdata.SystHierarchies,
      select: h.id,
      where: h.internal_name == ^hierarchy_name
    )
    |> MscmpSystDb.one!()
  end

  @spec get_hierarchy_id_by_name(Types.hierarchy_name()) ::
          {:ok, Types.hierarchy_id()} | {:error, MscmpSystError.t()}
  def get_hierarchy_id_by_name(hierarchy_name) do
    {:ok, get_hierarchy_id_by_name!(hierarchy_name)}
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {:error,
       %MscmpSystError{
         code: :undefined_error,
         message: "Failure retrieving Hierarchy ID by internal name.",
         cause: error
       }}
  end
end
