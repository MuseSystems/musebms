defmodule MsbmsSystEnums do
  alias MsbmsSystEnums.Impl.Enums

  @moduledoc """
  Documentation for `MsbmsSystEnums`.
  """

  @doc """
  Starts an instance of the Enumerations Service.

  Starting the service establishes the required processes and pre-populates the
  service cache with data from the database.  Most other functions in this
  module require that the service is started prior to use and will fail if the
  service is not started.

  The `service_name` argument provides a unique name under which the service can
  be found.  This argument is a subset of those that allowed for registering
  GenServers; the allowed forms for service name are simple atoms for basic
  local name registry or a "via tuple", such as might be used with the
  `Registry` module.

  The `datastore_context_name` is an atom which represents a started
  `MsbmsSystDatastore` context.  This context will be used for accessing and
  modifying database data.
  """
  @spec start_link({MsbmsSystEnums.Types.service_name(), MsbmsSystDatastore.Types.context_id()}) ::
          {:ok, pid()} | {:error, MsbmsSystError.t()}
  defdelegate start_link(params), to: MsbmsSystEnums.Runtime.Server

  @doc """
  Retrieves all values associated with the requested enumeration.

  The `service_name` argument identifies which enumerations service instance
  should be used by the function.  See `start_link/1` and type documentation
  for `t:MsbmsSystEnums.Types.service_name/0` for more.

  The `enum_name` argument indicates the name of the enumeration for which to
  retrieve values.

  The successful return of this function is an instance of the
  `MsbmsSystSettings.Data.SystEnums` struct containing the values requested,
  including the `enum_items` association populated as well as each item's
  `functional_type` association populated.

  ## Examples

      iex> MsbmsSystEnums.get_enum_values(
      ...>   :enums_instance,
      ...>   "example_enumeration")
  """
  @spec get_enum_values(MsbmsSystEnums.Types.service_name(), MsbmsSystEnums.Types.enum_name()) ::
          MsbmsSystEnums.Data.SystEnums.t()
  defdelegate get_enum_values(service_name, enum_name), to: Enums

  @doc """
  Retrieves all values for all enumerations.

  This function returns all other enumeration metadata, such as the records' IDs,
  descriptions, etc.  Also included is association data for the `enum_items`
  field and the `functional_type` association of each item.

  The `service_name` argument identifies which enumerations service instance
  should be used by the function.  See `start_link/1` and type documentation
  for `t:MsbmsSystEnums.Types.service_name/0` for more.

  ## Examples

    iex> MsbmsSystEnums.get_all_enum_values(:enums_instance)
  """
  @spec get_all_enum_values(MsbmsSystEnums.Types.service_name()) ::
          list(MsbmsSystEnums.Data.SystEnums.t())
  defdelegate get_all_enum_values(service_name), to: Enums

  @doc """
  Returns true if the requested enumeration is system defined, false otherwise.

  The `service_name` argument identifies which enumerations service instance
  should be used by the function.  See `start_link/1` and type documentation
  for `t:MsbmsSystEnums.Types.service_name/0` for more.

  The `enum_name` argument indicates the name of the enumeration to test as
  being system defined.

  ## Examples

      iex> MsbmsSystEnums.get_enum_syst_defined(:enums_instance, "example_enumeration")
      false
  """
  @spec get_enum_syst_defined(
          MsbmsSystEnums.Types.service_name(),
          MsbmsSystEnums.Types.enum_name()
        ) :: boolean()
  defdelegate get_enum_syst_defined(service_name, enum_name), to: Enums

  @doc """
  Returns true if the requested enumeration is user maintainable, false otherwise.

  The `service_name` argument identifies which enumerations service instance
  should be used by the function.  See `start_link/1` and type documentation
  for `t:MsbmsSystEnums.Types.service_name/0` for more.

  The `enum_name` argument indicates the name of the enumeration to test as
  being user maintainable.

  ## Examples

      iex> MsbmsSystEnums.get_enum_user_maintainable(:enums_instance, "example_enumeration")
      true
  """
  @spec get_enum_user_maintainable(
          MsbmsSystEnums.Types.service_name(),
          MsbmsSystEnums.Types.enum_name()
        ) :: boolean()
  defdelegate get_enum_user_maintainable(service_name, enum_name), to: Enums

  @doc """
  Returns the list of Enumeration Items associated with the requested
  enumeration.

  The `service_name` argument identifies which enumerations service instance
  should be used by the function.  See `start_link/1` and type documentation
  for `t:MsbmsSystEnums.Types.service_name/0` for more.

  The `enum_name` argument indicates the name of the enumeration for which to
  retrieve the list of enumeration items.
  """
  @spec get_enum_items(MsbmsSystEnums.Types.service_name(), MsbmsSystEnums.Types.enum_name()) ::
          list(MsbmsSystEnums.Data.SystEnumItems.t())
  defdelegate get_enum_items(service_name, enum_name), to: Enums

  @doc """
  Returns the list of Enumeration Items associated with the requested
  enumeration sorted by their sort_order value.

  In all other regards this function works the same
  `MsbmsSystEnums.get_enum_items/2`.
  """
  @spec get_sorted_enum_items(
          MsbmsSystEnums.Types.service_name(),
          MsbmsSystEnums.Types.enum_name()
        ) ::
          list(MsbmsSystEnums.Data.SystEnumItems.t())
  defdelegate get_sorted_enum_items(service_name, enum_name), to: Enums

  @doc """
  Returns the list of Enumeration Functional Types associated with the requested
  enumeration.

  The `service_name` argument identifies which enumerations service instance
  should be used by the function.  See `start_link/1` and type documentation
  for `t:MsbmsSystEnums.Types.service_name/0` for more.

  The `enum_name` argument indicates the name of the enumeration for which to
  retrieve the list of enumeration functional types.
  """
  @spec get_enum_functional_types(
          MsbmsSystEnums.Types.service_name(),
          MsbmsSystEnums.Types.enum_name()
        ) ::
          list(MsbmsSystEnums.Data.SystEnumFunctionalTypes.t())
  defdelegate get_enum_functional_types(service_name, enum_name), to: Enums

  @doc """
  Create a new user defined enumeration, optionally including functional type
  and enumeration item definitions.

  The `service_name` argument identifies which enumerations service instance
  should be used by the function.  See `start_link/1` and type documentation
  for `t:MsbmsSystEnums.Types.service_name/0` for more.

  The `enum_params` argument is a map containing the enumeration field values
  used in creating the user defined enumerations.  If the enumeration's
  functional types and enumeration items are known at enumeration creation time,
  it is recommended to nest values for those records under the
  `functional_types` and `enum_items` attributes as appropriate.  See the
  documentation for `t:MsbmsSystEnums.Types.enum_params/0`,
  `t:MsbmsSystEnums.Types.enum_functional_type_params/0`, and
  `t:MsbmsSystEnums.Types.enum_item_params/0` for more information about the
  available and required attributes.

  ## Examples

      iex> example_enumeration =
      ...>   %{
      ...>      internal_name: "example_create_enum",
      ...>      display_name: "Create Example Enum",
      ...>      user_description: "Demonstrate enumeration creation.",
      ...>      functional_types: [
      ...>        %{
      ...>          internal_name: "example_create_enum_functional_type",
      ...>          display_name: "Create Example Enum / Functional Type",
      ...>          external_name: "Functional Type",
      ...>          user_description: "Demonstrate Functional Type Creation"
      ...>        }
      ...>      ],
      ...>      enum_items: [
      ...>        %{
      ...>          internal_name: "example_create_enum_item",
      ...>          display_name: "Create Example Enum / Enum Item",
      ...>          external_name: "Enum Item",
      ...>          user_description: "Demonstration of enumeration item creation.",
      ...>          enum_default: true,
      ...>          functional_type_default: false,
      ...>          functional_type_internal_name: "example_create_enum_functional_type"
      ...>        }
      ...>      ]
      ...>    }
      iex> MsbmsSystEnums.create_enum(:enums_instance, example_enumeration)
      :ok
  """
  @spec create_enum(MsbmsSystEnums.Types.service_name(), MsbmsSystEnums.Types.enum_params()) ::
          :ok | {:error, MsbmsSystError.t()}
  def create_enum(service_name, enum_params) do
    GenServer.call(service_name, {:create_enum, enum_params})
  end

  @doc """
  Creates a new user defined functional type.

  User defined functional types may only be added to user defined enumerations.

  The `service_name` argument identifies which enumerations service instance
  should be used by the function.  See `start_link/1` and type documentation
  for `t:MsbmsSystEnums.Types.service_name/0` for more.

  The `enum_name` argument indicates to which enumeration the new functional
  type will be a child.

  `functional_type_params` is a map of type
  `t:MsbmsSystEnums.Types.enum_functional_type_params/0` which establishes the
  data values for the new functional type.

  """
  @spec create_enum_functional_type(
          MsbmsSystEnums.Types.service_name(),
          MsbmsSystEnums.Types.enum_name(),
          MsbmsSystEnums.Types.enum_functional_type_params()
        ) :: :ok | {:error, MsbmsSystError.t()}
  def create_enum_functional_type(service_name, enum_name, functional_type_params) do
    GenServer.call(
      service_name,
      {:create_enum_functional_type, enum_name, functional_type_params}
    )
  end

  @doc """
  Creates a new user defined enumeration item.

  User defined enumeration items may be added to either user defined
  enumerations or system defined enumerations which are also marked user
  maintainable.

  The `service_name` argument identifies which enumerations service instance
  should be used by the function.  See `start_link/1` and type documentation
  for `t:MsbmsSystEnums.Types.service_name/0` for more.

  The `enum_name` argument indicates to which enumeration the new enumeration
  item will be a child.

  `enum_item_params` is a map of type
  `t:MsbmsSystEnums.Types.enum_item_params/0` which establishes the data values
  for the new enumeration item.
  """
  @spec create_enum_item(
          MsbmsSystEnums.Types.service_name(),
          MsbmsSystEnums.Types.enum_name(),
          MsbmsSystEnums.Types.enum_item_params()
        ) :: :ok | {:error, MsbmsSystError.t()}
  def create_enum_item(service_name, enum_name, enum_item_params) do
    GenServer.call(
      service_name,
      {:create_enum_item, enum_name, enum_item_params}
    )
  end

  @doc """
  Changes the values of an existing enumeration.

  You can change the following fields using the this function:

    * `internal_name` - Note that you cannot change the internal name of a
      system defined enumeration.

    * `display_name`

    * `user_description`

    * `default_user_options`

  Other fields of the MsbmsSystEnums.Data.SystEnums data type may not be
  modified via this module.  Also note that only the enumeration value itself
  can be modified.  Changes to functional type or enumeration item records must
  be addressed individually.

  The `service_name` argument identifies which enumerations service instance
  should be used by the function.  See `start_link/1` and type documentation
  for `t:MsbmsSystEnums.Types.service_name/0` for more.

  The `enum_name` argument specifies the enumeration which is being modified.

  `enum_params` is a map of type `t:MsbmsSystEnums.Types.enum_params/0` which
  establishes the data values which are to be changed.

  """
  @spec set_enum_values(
          MsbmsSystEnums.Types.service_name(),
          MsbmsSystEnums.Types.enum_name(),
          MsbmsSystEnums.Types.enum_params()
        ) ::
          :ok | {:error, MsbmsSystError.t()}
  def set_enum_values(service_name, enum_name, enum_params) do
    GenServer.call(
      service_name,
      {:set_enum_values, enum_name, enum_params}
    )
  end

  @doc """
  Change the values of an existing enumeration functional type record.

  The following fields may be changed using this function:

    * `internal_name` - Note that you cannot change the internal name of a
      system defined functional type.

    * `display_name`

    * `external_name`

    * `user_description`

  Other fields of the MsbmsSystEnums.Data.SystEnumFunctionalTypes data type may
  not be modified via this module.

  The `service_name` argument identifies which enumerations service instance
  should be used by the function.  See `start_link/1` and type documentation
  for `t:MsbmsSystEnums.Types.service_name/0` for more.

  The `enum_name` argument specifies the enumeration which is parent to the
  functional type being modified.

  Attribute `functional_type_name` identifies the specific functional type which
  will be updated.

  `functional_type_params` is a map of type
  `t:MsbmsSystEnums.Types.enum_functional_type_params/0` which establishes the
  data values which are to be changed.

  """
  @spec set_enum_functional_type_values(
          MsbmsSystEnums.Types.service_name(),
          MsbmsSystEnums.Types.enum_name(),
          MsbmsSystEnums.Types.enum_functional_type_name(),
          MsbmsSystEnums.Types.enum_functional_type_params()
        ) ::
          :ok | {:error, MsbmsSystError.t()}
  def set_enum_functional_type_values(
        service_name,
        enum_name,
        functional_type_name,
        functional_type_params
      ) do
    GenServer.call(
      service_name,
      {:set_enum_functional_type_values, enum_name, functional_type_name, functional_type_params}
    )
  end

  @doc """
  Change the values of an existing enumeration item record.

  The following fields may be changed using this function:

    * `internal_name` - Note that you cannot change the internal name of a
      system defined enumeration item.

    * `display_name`

    * `external_name`

    * `user_description`

    * `enum_default`

    * `functional_type_default`

    * `sort_order`

    * `user_options`

  Other fields of the MsbmsSystEnums.Data.SystEnumItems data type may not be
  modified via this module.

  The `service_name` argument identifies which enumerations service instance
  should be used by the function.  See `start_link/1` and type documentation
  for `t:MsbmsSystEnums.Types.service_name/0` for more.

  The `enum_name` argument specifies the enumeration which is parent to the
  enumeration item.

  Attribute `enum_item_name` identifies the specific enumeration item which
  will be updated.

  `enum_item_params` is a map of type
  `t:MsbmsSystEnums.Types.enum_item_params/0` which establishes the data values
  which are to be changed.
  """
  @spec set_enum_item_values(
          MsbmsSystEnums.Types.service_name(),
          MsbmsSystEnums.Types.enum_name(),
          MsbmsSystEnums.Types.enum_item_name(),
          MsbmsSystEnums.Types.enum_item_params()
        ) ::
          :ok | {:error, MsbmsSystError.t()}
  def set_enum_item_values(
        service_name,
        enum_name,
        enum_item_name,
        enum_item_params
      ) do
    GenServer.call(
      service_name,
      {:set_enum_item_values, enum_name, enum_item_name, enum_item_params}
    )
  end

  @doc """
  Deletes a user defined enumeration and its child functional type and
  enumeration item records.

  You cannot delete a system defined enumeration nor can you delete an
  enumeration that has been referenced in other application data records.

  The `service_name` argument identifies which enumerations service instance
  should be used by the function.  See `start_link/1` and type documentation
  for `t:MsbmsSystEnums.Types.service_name/0` for more.

  The `enum_name` argument specifies the enumeration which is to be deleted by
  the function.
  """
  @spec delete_enum(MsbmsSystEnums.Types.service_name(), MsbmsSystEnums.Types.enum_name()) ::
          :ok | {:error, MsbmsSystError.t()}
  def delete_enum(service_name, enum_name) do
    GenServer.call(service_name, {:delete_enum, enum_name})
  end

  @doc """
  Deletes a user defined enumeration functional type record.

  You cannot delete a system defined functional type nor can you delete a
  functional type which is still referenced by enumeration item records.

  The `service_name` argument identifies which enumerations service instance
  should be used by the function.  See `start_link/1` and type documentation
  for `t:MsbmsSystEnums.Types.service_name/0` for more.

  The `enum_name` argument specifies the enumeration which is is the parent of
  the functional type to be deleted.

  Argument `enum_functional_type_name` identifies the target functional type of
  the delete operation.
  """
  @spec delete_enum_functional_type(
          MsbmsSystEnums.Types.service_name(),
          MsbmsSystEnums.Types.enum_name(),
          MsbmsSystEnums.Types.enum_functional_type_name()
        ) ::
          :ok | {:error, MsbmsSystError.t()}
  def delete_enum_functional_type(service_name, enum_name, functional_type_name) do
    GenServer.call(service_name, {:delete_enum_functional_type, enum_name, functional_type_name})
  end

  @doc """
  Deletes a user defined enumeration item record.

  You cannot delete a system defined enumeration item nor can you delete an
  an enumeration item record which has been referenced in application data.

  The `service_name` argument identifies which enumerations service instance
  should be used by the function.  See `start_link/1` and type documentation
  for `t:MsbmsSystEnums.Types.service_name/0` for more.

  The `enum_name` argument specifies the enumeration which is is the parent of
  the enumeration item to be deleted.

  Argument `enum_item_name` identifies the target functional type of
  the delete operation.
  """
  @spec delete_enum_item(
          MsbmsSystEnums.Types.service_name(),
          MsbmsSystEnums.Types.enum_name(),
          MsbmsSystEnums.Types.enum_item_name()
        ) ::
          :ok | {:error, MsbmsSystError.t()}
  def delete_enum_item(service_name, enum_name, enum_item_name) do
    GenServer.call(service_name, {:delete_enum_item, enum_name, enum_item_name})
  end
end
