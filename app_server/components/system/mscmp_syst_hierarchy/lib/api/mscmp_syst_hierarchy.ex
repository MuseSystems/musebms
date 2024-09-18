# Source File: mscmp_syst_hierarchy.ex
# Location:    musebms/app_server/components/system/mscmp_syst_hierarchy/lib/api/mscmp_syst_hierarchy.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystHierarchy do
  @external_resource "README.md"
  @moduledoc Path.join([__DIR__, "..", "..", "README.md"])
             |> File.read!()
             |> String.split("<!-- MDOC !-->")
             |> Enum.fetch!(1)

  alias MscmpSystHierarchy.Impl
  alias MscmpSystHierarchy.Types

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

  # ==============================================================================================
  # ==============================================================================================
  #
  # Enumerations Data
  #
  # ==============================================================================================
  # ==============================================================================================

  ##############################################################################
  #
  # get_hierarchy_type_by_name
  #
  #

  @doc section: :enumerations_data
  @doc """
  Returns the Hierarchy Type record for the given Hierarchy Type Internal Name.

  If the requested Hierarchy Type record does not exist `nil` is returned
  instead.  Any errors cause an exception to be raised.

  Hierarchy Types are currently implemented using the `MscmpSystEnums`
  Component.

  ## Parameters

    * `type_name` - the Internal Name of the desired Hierarchy Type to retrieve.
    This parameter is required.

  ## Examples

  Requesting an existing Hierarchy Type:

      iex> %Msdata.SystEnumItems{} =
      ...>   MscmpSystHierarchy.get_hierarchy_type_by_name("hierarchy_type_example")

  Requesting a non-existent Hierarchy Type:

      iex> MscmpSystHierarchy.get_hierarchy_type_by_name("nonexistent_type")
      nil
  """
  @spec get_hierarchy_type_by_name(Types.hierarchy_type_name()) :: Msdata.SystEnumItems.t() | nil
  defdelegate get_hierarchy_type_by_name(type_name), to: Impl.Hierarchy

  ##############################################################################
  #
  # get_hierarchy_type_id_by_name
  #
  #

  @doc section: :enumerations_data
  @doc """
  Returns the ID value of a Hierarchy Type record as identified by the Hierarchy
  Type's Internal Name.

  If the requested Hierarchy Type record does not exist `nil` is returned
  instead.  Any errors cause an exception to be raised.

  Hierarchy Types are currently implemented using the `MscmpSystEnums`
  Component.

  ## Parameters

    * `type_name` - the Internal Name of the desired Hierarchy Type ID to
    retrieve.  This parameter is required.

  ## Examples

  Requesting an existing Hierarchy Type:

      iex> id_value =
      ...>   MscmpSystHierarchy.get_hierarchy_type_id_by_name("hierarchy_type_example")
      iex> is_binary(id_value)
      true

  Requesting a non-existent Hierarchy Type:

      iex> MscmpSystHierarchy.get_hierarchy_type_id_by_name("nonexistent_type")
      nil
  """
  @spec get_hierarchy_type_id_by_name(Types.hierarchy_type_name()) ::
          Types.hierarchy_type_id() | nil
  defdelegate get_hierarchy_type_id_by_name(type_name), to: Impl.Hierarchy

  ##############################################################################
  #
  # list_hierarchy_types
  #
  #

  @list_hierarchy_types_opts NimbleOptions.new!(Keyword.take(option_defs, [:sorted]))

  @doc section: :enumerations_data
  @doc """
  Lists the available Hierarchy Types, optionally sorted by the predefined sort
  order.

  Returns a list of Hierarchy Type records.  Raises an exception on errors.
  Other than the return behavior, this is the same as `list_hierarchy_types/1`.

  ## Parameters

    * `opts` - A Keyword List of optional parameters.

  ## Options

    #{NimbleOptions.docs(@list_hierarchy_types_opts)}

  ## Examples

  Retrieving the list of Hierarchy Types using the default options.  Note that
  in the example there is only one available Hierarchy Type defined in the
  system.

      iex> [%Msdata.SystEnumItems{internal_name: "hierarchy_type_example"}] =
      ...>   MscmpSystHierarchy.list_hierarchy_types!()
  """
  @spec list_hierarchy_types!() :: [Msdata.SystEnumItems.t()]
  @spec list_hierarchy_types!(Keyword.t()) :: [Msdata.SystEnumItems.t()]
  def list_hierarchy_types!(opts \\ []) do
    opts = NimbleOptions.validate!(opts, @list_hierarchy_types_opts)
    Impl.Hierarchy.list_hierarchy_types!(opts)
  end

  @doc section: :enumerations_data
  @doc """
  Lists the available Hierarchy Types, optionally sorted by the predefined sort
  order; doesn't raise exceptions on error.

  Returns a list of Hierarchy Type records using a result tuple. If the request
  runs without error, a success tuple in the form of `{:ok, <list>}` is returned
  while an error condition will return an error tuple in the form of
  `{:error, <error>}`.

  ## Parameters

    * `opts` - A Keyword List of optional parameters.

  ## Options

    #{NimbleOptions.docs(@list_hierarchy_types_opts)}

  ## Examples

  Retrieving the list of Hierarchy Types using the default options.  Note that
  in the example there is only one available Hierarchy Type defined in the
  system.

      iex> {:ok, [%Msdata.SystEnumItems{internal_name: "hierarchy_type_example"}]} =
      ...>   MscmpSystHierarchy.list_hierarchy_types()
  """
  @spec list_hierarchy_types() :: {:ok, [Msdata.SystEnumItems.t()]} | {:error, MscmpSystError.t()}
  @spec list_hierarchy_types(Keyword.t()) ::
          {:ok, [Msdata.SystEnumItems.t()]} | {:error, MscmpSystError.t()}
  def list_hierarchy_types(opts \\ []) do
    opts = NimbleOptions.validate!(opts, @list_hierarchy_types_opts)
    Impl.Hierarchy.list_hierarchy_types(opts)
  end

  ##############################################################################
  #
  # get_hierarchy_state_by_name
  #
  #

  @doc section: :enumerations_data
  @doc """
  Returns the Hierarchy State record for the given Hierarchy State Internal
  Name.

  If the requested Hierarchy State record does not exist `nil` is returned
  instead.  Any errors cause an exception to be raised.

  Hierarchy States are currently implemented using the `MscmpSystEnums`
  Component.

  ## Parameters

    * `state_name` - the Internal Name of the desired Hierarchy State to
    retrieve.  This parameter is required.

  ## Examples

  Requesting an existing Hierarchy State:

      iex> %Msdata.SystEnumItems{} =
      ...>   MscmpSystHierarchy.get_hierarchy_state_by_name("hierarchy_states_sysdef_active")

  Requesting a non-existent Hierarchy State:

      iex> MscmpSystHierarchy.get_hierarchy_state_by_name("nonexistent_state")
      nil
  """
  @spec get_hierarchy_state_by_name(Types.hierarchy_state_name()) ::
          Msdata.SystEnumItems.t() | nil
  defdelegate get_hierarchy_state_by_name(state_name), to: Impl.Hierarchy

  ##############################################################################
  #
  # get_hierarchy_state_id_by_name
  #
  #

  @doc section: :enumerations_data
  @doc """
  Returns the Hierarchy State ID for the given Hierarchy State Internal Name.

  If the requested Hierarchy State record does not exist `nil` is returned
  instead.  Any errors cause an exception to be raised.

  Hierarchy States are currently implemented using the `MscmpSystEnums`
  Component.

  ## Parameters

    * `state_name` - the Internal Name of the desired Hierarchy State ID to
    retrieve.  This parameter is required.

  ## Examples

  Requesting an existing Hierarchy State:

      iex> state_id =
      ...>   MscmpSystHierarchy.get_hierarchy_state_id_by_name("hierarchy_states_sysdef_inactive")
      iex> is_binary(state_id)

  Requesting a non-existent Hierarchy State:

      iex> MscmpSystHierarchy.get_hierarchy_state_id_by_name("nonexistent_state")
      nil
  """
  @spec get_hierarchy_state_id_by_name(Types.hierarchy_state_name()) ::
          Types.hierarchy_state_id() | nil
  defdelegate get_hierarchy_state_id_by_name(state_name), to: Impl.Hierarchy

  ##############################################################################
  #
  # get_hierarchy_state_default
  #
  #

  @doc section: :enumerations_data
  @doc """
  Returns the default Hierarchy State record.

  Optionally, this function can also return the default Hierarchy State for a
  specified Hierarchy State Functional Type.

  Any errors encountered will cause an exception to be raised.

  ## Parameters

    * `functional_type` - an optional parameter specifying which Hierarchy State
    Functional Type's default record should be returned.  If this parameter is
    `nil` (the parameter default), the default Hierarchy State overall will be
    returned.

  ## Examples

  Return the overall default Hierarchy State.

      iex> %Msdata.SystEnumItems{internal_name: "hierarchy_states_sysdef_inactive"} =
      ...>   MscmpSystHierarchy.get_hierarchy_state_default()

  Return the default Hierarchy State for the "active" Functional Type.

      iex> %Msdata.SystEnumItems{internal_name: "hierarchy_states_sysdef_active"} =
      ...>   MscmpSystHierarchy.get_hierarchy_state_default(:hierarchy_states_active)
  """
  @spec get_hierarchy_state_default() :: Msdata.SystEnumItems.t()
  @spec get_hierarchy_state_default(Types.hierarchy_state_functional_types() | nil) ::
          Msdata.SystEnumItems.t()
  defdelegate get_hierarchy_state_default(functional_type \\ nil), to: Impl.Hierarchy

  ##############################################################################
  #
  # get_hierarchy_state_default_id
  #
  #

  @doc section: :enumerations_data
  @doc """
  Returns the default Hierarchy State record ID value.

  Optionally, this function can also return the ID value of the default
  Hierarchy State for a specified Hierarchy State Functional Type.

  Any errors encountered will cause an exception to be raised.

  ## Parameters

    * `functional_type` - an optional parameter specifying which Hierarchy State
    Functional Type's default record ID should be returned.  If this parameter
    is `nil` (the parameter default), the default Hierarchy State overall will
    be returned.

  ## Examples

  Return the overall default Hierarchy State.

      iex> state_id = MscmpSystHierarchy.get_hierarchy_state_default_id()
      iex> is_binary(state_id)
      true

  Return the default Hierarchy State for the "active" Functional Type.

      iex> state_id = MscmpSystHierarchy.get_hierarchy_state_default_id(:hierarchy_states_active)
      iex> is_binary(state_id)
      true
  """
  @spec get_hierarchy_state_default_id() :: Types.hierarchy_state_id()
  @spec get_hierarchy_state_default_id(Types.hierarchy_state_functional_types() | nil) ::
          Types.hierarchy_state_id()
  defdelegate get_hierarchy_state_default_id(functional_type \\ nil), to: Impl.Hierarchy

  # ==============================================================================================
  # ==============================================================================================
  #
  # Hierarchy Data
  #
  # ==============================================================================================
  # ==============================================================================================

  ##############################################################################
  #
  # get_hierarchy_id_by_name
  #
  #

  @doc section: :hierarchy_data
  @doc """
  Returns the record ID of the Hierarchy as identified by its Internal Name,
  raising exceptions on error.

  If the Hierarchy is not found or if some other error is encountered an
  exception is raised.  This is same as `get_hierarchy_id_by_name/1` with the
  exception of the error handling.

  ## Parameters

    * `hierarchy_name` - the Internal Name of the desired Hierarchy record.

  ## Examples

  Normal call successfully returning a Hierarchy record ID value.

      iex> hierarchy_id =
      ...>   MscmpSystHierarchy.get_hierarchy_id_by_name!("hierarchy_example")
      iex> is_binary(hierarchy_id)
      true
  """
  @spec get_hierarchy_id_by_name!(Types.hierarchy_name()) :: Types.hierarchy_id()
  defdelegate get_hierarchy_id_by_name!(hierarchy_name), to: Impl.Hierarchy

  @doc section: :hierarchy_data
  @doc """
  Returns the record ID of the Hierarchy as identified by its Internal Name.

  On successful execution the Hierarchy record ID value is returned via a
  success tuple in the form `{:ok, <Hierarchy ID>}`.  If an error is encountered
  or the requested record does not exist an error tuple in the form
  `{:error, %MscmpSystError{}}` is returned instead.

  ## Parameters

    * `hierarchy_name` - the Internal Name of the desired Hierarchy record.

  ## Examples

  Normal call successfully returning a Hierarchy record ID value.

      iex> {:ok, hierarchy_id} =
      ...>   MscmpSystHierarchy.get_hierarchy_id_by_name("hierarchy_example")
      iex> is_binary(hierarchy_id)
      true

  A failing call due to requesting a non-existent Hierarchy record.

      iex> {:error, %MscmpSystError{}} =
      ...>   MscmpSystHierarchy.get_hierarchy_id_by_name("nonexistent_hierarchy")
  """
  @spec get_hierarchy_id_by_name(Types.hierarchy_name()) ::
          {:ok, Types.hierarchy_id()} | {:error, MscmpSystError.t()}
  defdelegate get_hierarchy_id_by_name(hierarchy_name), to: Impl.Hierarchy
end
