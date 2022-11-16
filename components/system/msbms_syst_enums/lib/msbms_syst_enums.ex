defmodule MsbmsSystEnums do
  alias MsbmsSystEnums.Data
  alias MsbmsSystEnums.Impl
  alias MsbmsSystEnums.Runtime
  alias MsbmsSystEnums.Types

  @moduledoc """
  Documentation for `MsbmsSystEnums`.
  """

  @doc section: :service_management
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
  `MscmpSystDb` context.  This context will be used for accessing and
  modifying database data.
  """
  @spec start_link({Types.service_name(), MscmpSystDb.Types.context_name()}) ::
          {:ok, pid()} | {:error, MscmpSystError.t()}
  defdelegate start_link(params), to: Runtime.Server

  @doc section: :service_management
  @doc """
  Establishes the current Enumerations Service instance for the process.

  A running system is likely to have more than one instance of the Enums
  Service running.  For example, in multi-tenant applications each tenant may
  have its own instance of the Enumerations Service, caching data unique to the
  tenant.

  Calling `MsbmsSystEnums.put_enums_service/1` will set the reference to
  the desired Enumerations Service instance for any subsequent MsbmsSystEnums
  calls.  The service name is set in the Process Dictionary of the process from
  which the calls are being made.  As such, you must call put_enums_service at
  least once for any process from which you wish to access the Enumerations
  Service.

  Because we're just thinly wrapping `Process.put/2` here, the return value will
  be the previous value set here, or nil if no previous value was set.

  ## Parameters
    * `service_name` - The name of the service which is to be set as servicing
      the process.

  ## Examples

      iex> MsbmsSystEnums.put_enums_service(:enums_instance)
  """
  @spec put_enums_service(Types.service_name() | nil) :: Types.service_name() | nil
  defdelegate put_enums_service(service_name), to: Runtime.ProcessUtils

  @doc section: :service_management
  @doc """
  Retrieves the currently set Enumerations Service name or `nil` if none has
  been set.

  ## Examples
      iex> MsbmsSystEnums.get_enums_service()
      :enums_instance
  """
  @spec get_enums_service() :: Types.service_name() | nil
  defdelegate get_enums_service(), to: Runtime.ProcessUtils

  @doc section: :enum_data
  @doc """
  Retrieves all values associated with the requested enumeration.

  ## Parameters
    * `enum_name` - indicates the name of the enumeration for which to retrieve values.

  The successful return of this function is an instance of the
  `MsbmsSystEnums.Data.SystEnums` struct containing the values requested,
  including the `enum_items` association populated as well as each item's
  `functional_type` association populated.

  ## Examples

      iex> MsbmsSystEnums.get_enum_values("example_enumeration")
  """
  @spec get_enum_values(Types.enum_name()) :: Data.SystEnums.t()
  defdelegate get_enum_values(enum_name), to: Impl.Enums

  @doc section: :enum_data
  @doc """
  Retrieves all values for all enumerations.

  This function returns all other enumeration metadata, such as the records' IDs,
  descriptions, etc.  Also included is association data for the `enum_items`
  field and the `functional_type` association of each item.

  ## Examples

    iex> MsbmsSystEnums.list_all_enums()
  """
  @spec list_all_enums() :: list(Data.SystEnums.t())
  defdelegate list_all_enums(), to: Impl.Enums

  @doc section: :enum_data
  @doc """
  Returns true if the requested enumeration is system defined, false otherwise.

  ## Parameters

    * `enum_name` - the name of the enumeration to test as being system defined.

  ## Examples

      iex> MsbmsSystEnums.get_enum_syst_defined("example_enumeration")
      false
  """
  @spec get_enum_syst_defined(Types.enum_name()) :: boolean()
  defdelegate get_enum_syst_defined(enum_name), to: Impl.Enums

  @doc section: :enum_data
  @doc """
  Returns true if the requested enumeration is user maintainable, false
  otherwise.

  ## Parameters
    * `enum_name` - the name of the enumeration to test as being user
      maintainable.

  ## Examples

      iex> MsbmsSystEnums.get_enum_user_maintainable( "example_enumeration")
      true
  """
  @spec get_enum_user_maintainable(Types.enum_name()) :: boolean()
  defdelegate get_enum_user_maintainable(enum_name), to: Impl.Enums

  @doc section: :enum_item_data
  @doc """
  Returns the list of Enumeration Items associated with the requested
  enumeration.

  ## Parameters

    * `enum_name`- the name of the enumeration for which to retrieve the list of
      enumeration items.
  """
  @spec list_enum_items(Types.enum_name()) :: list(Data.SystEnumItems.t())
  defdelegate list_enum_items(enum_name), to: Impl.Enums

  @doc section: :enum_item_data
  @doc """
  Returns the list of Enumeration Items associated with the requested
  enumeration sorted by their sort_order value.

  In all other regards this function works the same
  `MsbmsSystEnums.list_enum_items/1`.
  """
  @spec list_sorted_enum_items(Types.enum_name()) :: list(Data.SystEnumItems.t())
  defdelegate list_sorted_enum_items(enum_name), to: Impl.Enums

  @doc section: :enum_functional_type_data
  @doc """
  Returns the list of Enumeration Functional Types associated with the requested
  enumeration.

  ## Parameters

    * `enum_name` - the name of the enumeration for which to retrieve the list
      of enumeration functional types.
  """
  @spec list_enum_functional_types(Types.enum_name()) :: list(Data.SystEnumFunctionalTypes.t())
  defdelegate list_enum_functional_types(enum_name), to: Impl.Enums

  @doc section: :enum_item_data
  @doc """
  Returns an Enumeration Item record from the named Enumeration as identified by
  its name.

  ## Parameters

    * `enum_name` - the name of the Enumeration that is parent to the target
    Enumeration Item record.

    * `enum_item_name` - the name of the Enumeration Item record to return.

  ## Examples

      iex> %MsbmsSystEnums.Data.SystEnumItems{
      ...>   internal_name: "example_enum_item_one"
      ...> } =
      ...>   MsbmsSystEnums.get_enum_item_by_name(
      ...>     "example_enumeration",
      ...>     "example_enum_item_one"
      ...>   )
  """
  @spec get_enum_item_by_name(Types.enum_name(), Types.enum_item_name()) :: Data.SystEnumItems.t()
  defdelegate get_enum_item_by_name(enum_name, enum_item_name), to: Impl.Enums

  @doc section: :enum_item_data
  @doc """
  Returns an Enumeration Item record from the named Enumeration as identified by
  its id value.

  Other than using a different identifier to locate the enumeration item record,
  this function behaves the same as `get_enum_by_name/2`.

  ## Parameters

    * `enum_name` - the name of the Enumeration that is parent to the target
    Enumeration Item record.

    * `enum_item_id` - the id value of the Enumeration Item record to return.

  """
  @spec get_enum_item_by_id(Types.enum_name(), Ecto.UUID.t()) :: Data.SystEnumItems.t()
  defdelegate get_enum_item_by_id(enum_name, enum_item_id), to: Impl.Enums

  @doc section: :enum_functional_type_data
  @doc """
  Returns the internal name of the functional type to which the given Enum Item
  record belongs.

  ## Parameters

    * `enum_name` - the name of the enumeration to which the Enum Item ID
    belongs.

    * `enum_item_id` - the record ID of the Enum Item record of interest.

  ## Example
      iex> example_enum_item = MsbmsSystEnums.get_enum_item_by_name(
      ...>   "example_enumeration",
      ...>   "example_enum_item_one")
      iex> MsbmsSystEnums.get_functional_type_by_enum_item_id(
      ...>   "example_enumeration",
      ...>   example_enum_item.id)
      "example_enum_func_type_1"
  """
  @spec get_functional_type_by_enum_item_id(Types.enum_name(), Types.enum_item_id()) ::
          Types.enum_functional_type_name()
  defdelegate get_functional_type_by_enum_item_id(enum_name, enum_item_id), to: Impl.Enums

  @doc section: :enum_item_data
  @doc """
  Finds the default enumeration item for the requested enumeration or for the
  enumeration functional type.

  When no qualifying options are specified, this function will return the
  enumeration item record which is marked as being default for the enumeration.
  If the `functional_type_name` option is used, then the function returns the
  record which is marked as default for the functional type.

  ## Parameters

    * `enum_name`- the name of the enumeration for which to retrieve the default
      enumeration item.

    * `opts` - a keyword list which takes one of the following optional values:

      * `functional_type_name` - If the enumeration uses functional types, this
        option allows you to find the default for the functional type rather
        than the entire enumeration.

  ## Examples
      iex> %MsbmsSystEnums.Data.SystEnumItems{
      ...>   internal_name: "example_enum_item_two"
      ...> } =
      ...>   MsbmsSystEnums.get_default_enum_item("example_enumeration")

      iex> %MsbmsSystEnums.Data.SystEnumItems{
      ...>   internal_name: "example_enum_item_one"
      ...> } =
      ...>   MsbmsSystEnums.get_default_enum_item(
      ...>     "example_enumeration",
      ...>     [functional_type_name: "example_enum_func_type_1"]
      ...>   )
  """
  @spec get_default_enum_item(Types.enum_name(), Keyword.t() | []) :: Data.SystEnumItems.t()
  defdelegate get_default_enum_item(enum_name, opts \\ []), to: Impl.Enums

  @doc section: :enum_data
  @doc """
  Create a new user defined enumeration, optionally including functional type
  and enumeration item definitions.

  ## Parameters

    * `enum_params` - a map containing the enumeration field values used in
      creating the user defined enumerations.  If the enumeration's functional
      types and enumeration items are known at enumeration creation time,
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
      ...>          functional_type_name: "example_create_enum_functional_type"
      ...>        }
      ...>      ]
      ...>    }
      iex> MsbmsSystEnums.create_enum(example_enumeration)
      :ok
  """
  @spec create_enum(Types.enum_params()) :: :ok | {:error, MscmpSystError.t()}
  def create_enum(enum_params) do
    GenServer.call(Runtime.ProcessUtils.get_enums_service(), {:create_enum, enum_params})
  end

  @doc section: :enum_functional_type_data
  @doc """
  Creates a new user defined functional type.

  User defined functional types may only be added to user defined enumerations.

  ## Parameters
    * `enum_name` - the Enumeration to which the new functional type will be a
      child.

    * `functional_type_params` - a map of type
      `t:Types.enum_functional_type_params/0` which establishes
      the data values for the new functional type.

  """
  @spec create_enum_functional_type(Types.enum_name(), Types.enum_functional_type_params()) ::
          :ok | {:error, MscmpSystError.t()}
  def create_enum_functional_type(enum_name, functional_type_params) do
    GenServer.call(
      Runtime.ProcessUtils.get_enums_service(),
      {:create_enum_functional_type, enum_name, functional_type_params}
    )
  end

  @doc section: :enum_item_data
  @doc """
  Creates a new user defined enumeration item.

  User defined enumeration items may be added to either user defined
  enumerations or system defined enumerations which are also marked user
  maintainable.

  ## Parameters

    * `enum_name` -the  enumeration to which the new enumeration item will be a
      child.

    * `enum_item_params` - a map of type
      `t:MsbmsSystEnums.Types.enum_item_params/0` which establishes the data
      values for the new enumeration item.
  """
  @spec create_enum_item(Types.enum_name(), Types.enum_item_params()) ::
          :ok | {:error, MscmpSystError.t()}
  def create_enum_item(enum_name, enum_item_params) do
    GenServer.call(
      Runtime.ProcessUtils.get_enums_service(),
      {:create_enum_item, enum_name, enum_item_params}
    )
  end

  @doc section: :enum_data
  @doc """
  Changes the values of an existing enumeration.

  You can change the following fields using the this function:

    * `internal_name` - Note that you cannot change the internal name of a
      system defined enumeration.

    * `display_name`

    * `user_description`

    * `default_user_options`

  Other fields of the `MsbmsSystEnums.Data.SystEnums` data type may not be
  modified via this module.  Also note that only the enumeration value itself
  can be modified.  Changes to functional type or enumeration item records must
  be addressed individually.

  ## Parameters

    * `enum_name` - the enumeration which is being modified.

    * `enum_params` - a map of type `t:MsbmsSystEnums.Types.enum_params/0` which
      establishes the data values which are to be changed.

  """
  @spec set_enum_values(Types.enum_name(), Types.enum_params()) ::
          :ok | {:error, MscmpSystError.t()}
  def set_enum_values(enum_name, enum_params) do
    GenServer.call(
      Runtime.ProcessUtils.get_enums_service(),
      {:set_enum_values, enum_name, enum_params}
    )
  end

  @doc section: :enum_functional_type_data
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

  ## Parameters

    * `enum_name`- the enumeration which is parent to the functional type being
      modified.

    * `functional_type_name` - the specific functional type which will be
      updated.

    * `functional_type_params` - a map of type
      `t:MsbmsSystEnums.Types.enum_functional_type_params/0` which establishes
      the data values which are to be changed.

  """
  @spec set_enum_functional_type_values(
          Types.enum_name(),
          Types.enum_functional_type_name(),
          Types.enum_functional_type_params()
        ) :: :ok | {:error, MscmpSystError.t()}
  def set_enum_functional_type_values(
        enum_name,
        functional_type_name,
        functional_type_params
      ) do
    GenServer.call(
      Runtime.ProcessUtils.get_enums_service(),
      {:set_enum_functional_type_values, enum_name, functional_type_name, functional_type_params}
    )
  end

  @doc section: :enum_item_data
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

  ## Parameters

    * `enum_name` - the enumeration which is parent to the enumeration item.

    * `enum_item_name` - the specific enumeration item which will be updated.

    * `enum_item_params` - a map of type
      `t:MsbmsSystEnums.Types.enum_item_params/0` which establishes the data values
      which are to be changed.
  """
  @spec set_enum_item_values(Types.enum_name(), Types.enum_item_name(), Types.enum_item_params()) ::
          :ok | {:error, MscmpSystError.t()}
  def set_enum_item_values(
        enum_name,
        enum_item_name,
        enum_item_params
      ) do
    GenServer.call(
      Runtime.ProcessUtils.get_enums_service(),
      {:set_enum_item_values, enum_name, enum_item_name, enum_item_params}
    )
  end

  @doc section: :enum_data
  @doc """
  Deletes a user defined enumeration and its child functional type and
  enumeration item records.

  You cannot delete a system defined enumeration nor can you delete an
  enumeration that has been referenced in other application data records.

  ## Parameters

    * `enum_name` - the enumeration which is to be deleted by the function.
  """
  @spec delete_enum(Types.enum_name()) :: :ok | {:error, MscmpSystError.t()}
  def delete_enum(enum_name) do
    GenServer.call(Runtime.ProcessUtils.get_enums_service(), {:delete_enum, enum_name})
  end

  @doc section: :enum_functional_type_data
  @doc """
  Deletes a user defined enumeration functional type record.

  You cannot delete a system defined functional type nor can you delete a
  functional type which is still referenced by enumeration item records.

  ## Parameters

    * `enum_name` - the enumeration which is is the parent of the functional
      type to be deleted.

    * `enum_functional_type_name`- the target functional type of the delete
      operation.
  """
  @spec delete_enum_functional_type(Types.enum_name(), Types.enum_functional_type_name()) ::
          :ok | {:error, MscmpSystError.t()}
  def delete_enum_functional_type(enum_name, functional_type_name) do
    GenServer.call(
      Runtime.ProcessUtils.get_enums_service(),
      {:delete_enum_functional_type, enum_name, functional_type_name}
    )
  end

  @doc section: :enum_item_data
  @doc """
  Deletes a user defined enumeration item record.

  You cannot delete a system defined enumeration item nor can you delete an
  an enumeration item record which has been referenced in application data.

  ## Parameters

    * `enum_name` - the enumeration which is is the parent of the enumeration
      item to be deleted.

    * `enum_item_name` - the target functional type of the delete operation.
  """
  @spec delete_enum_item(Types.enum_name(), Types.enum_item_name()) ::
          :ok | {:error, MscmpSystError.t()}
  def delete_enum_item(enum_name, enum_item_name) do
    GenServer.call(
      Runtime.ProcessUtils.get_enums_service(),
      {:delete_enum_item, enum_name, enum_item_name}
    )
  end
end
