# Source File: mscmp_syst_enums.ex
# Location:    musebms/app_server/components/system/mscmp_syst_enums/lib/api/mscmp_syst_enums.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystEnums do
  @external_resource "README.md"
  @moduledoc Path.join([__DIR__, "..", "..", "README.md"])
             |> File.read!()
             |> String.split("<!-- MDOC !-->")
             |> Enum.fetch!(1)

  alias MscmpSystEnums.Impl
  alias MscmpSystEnums.Runtime
  alias MscmpSystEnums.Runtime.ProcessUtils
  alias MscmpSystEnums.Types

  ##############################################################################
  #
  # Options Definition
  #
  #

  option_defs = [
    debug: [
      type: :boolean,
      doc: """
      If true, the GenServer backing the Settings Service will be started in
      debug mode.
      """
    ],
    timeout: [
      type: :timeout,
      default: :infinity,
      doc: "Timeout value for the start_link call."
    ],
    hibernate_after: [
      type: :timeout,
      doc: """
      If present, the GenServer process awaits any message for the specified
      time before hibernating.  The timeout value is expressed in Milliseconds.
      """
    ],
    datastore_context_name: [
      type:
        {:or,
         [nil, :atom, {:tuple, [{:in, [:via]}, :atom, :any]}, {:tuple, [{:in, [:global]}, :any]}]},
      type_doc: "`t:GenServer.name/0 or `nil`",
      doc: """
      Specifies the name of the Datastore Context to be used by the Enumerations
      Service.
      """
    ],
    service_name: [
      type:
        {:or,
         [nil, :atom, {:tuple, [{:in, [:via]}, :atom, :any]}, {:tuple, [{:in, [:global]}, :any]}]},
      type_doc: "`t:GenServer.name/0 or `nil`",
      doc: """
      The name to use for the GenServer backing this specific Enumerations
      Service instance.
      """
    ],
    functional_type_name: [
      type: :string,
      doc: """
      The Internal Name of the Enumeration's Functional Type.
      """
    ]
  ]

  ##############################################################################
  #
  # child_spec
  #
  #

  @child_spec_opts NimbleOptions.new!(
                     Keyword.take(option_defs, [
                       :service_name,
                       :datastore_context_name,
                       :debug,
                       :timeout,
                       :hibernate_after
                     ])
                   )

  @doc section: :service_management
  @doc """
  Returns a child specification for the Enumerations Service.

  ## Parameters

    * `opts` - A keyword list of options.

  ## Options

    #{NimbleOptions.docs(@child_spec_opts)}

  ## Examples

      iex> MscmpSystEnums.child_spec(
      ...>   service_name: MyApp.EnumsService,
      ...>   datastore_context_name: MyApp.DatastoreContext)
      %{
        id: MscmpSystEnums.Runtime.Service,
        start:
          {MscmpSystEnums,
           :start_link,
           [MyApp.EnumsService, MyApp.DatastoreContext, [timeout: :infinity]]},
      }

  """
  @spec child_spec(Keyword.t()) :: Supervisor.child_spec()
  def child_spec(opts) do
    opts = NimbleOptions.validate!(opts, @child_spec_opts)
    Runtime.Service.child_spec(opts)
  end

  ##############################################################################
  #
  # start_link
  #
  #

  @start_link_opts NimbleOptions.new!(
                     Keyword.take(option_defs, [:debug, :timeout, :hibernate_after])
                   )

  @doc section: :service_management
  @doc """
  Starts an instance of the Enumerations Service.

  Starting the service establishes the required processes and pre-populates the
  service cache with data from the database.  Most other functions in this
  module require that the service is started prior to use and will fail if the
  service is not started.

  ## Parameters

    * `service_name` - The name to use for the GenServer backing this specific
      Enumerations Service instance.

    * `datastore_context_name` - The name of the Datastore Context to be used
      by the Enumerations Service.

    * `opts` - A keyword list of options.

  ## Options

    #{NimbleOptions.docs(@start_link_opts)}
  """
  @spec start_link(Types.service_name(), MscmpSystDb.Types.context_service_name()) ::
          {:ok, pid()} | {:error, MscmpSystError.t()}
  @spec start_link(Types.service_name(), MscmpSystDb.Types.context_service_name(), Keyword.t()) ::
          {:ok, pid()} | {:error, MscmpSystError.t()}
  def start_link(service_name, datastore_context_name, opts \\ []) do
    case NimbleOptions.validate(opts, @start_link_opts) do
      {:ok, validated_opts} ->
        Runtime.Service.start_link(service_name, datastore_context_name, validated_opts)

      {:error, error} ->
        {:error,
         %MscmpSystError{
           code: :parameter_error,
           message: "Option validation error",
           cause: error
         }}
    end
  end

  ##############################################################################
  #
  # put_service
  #
  #

  @doc section: :service_management
  @doc """
  Sets the specific Enumeration Service instance which the current process
  should use.


  ## Parameters

    * `enums_service_name` - the name under which the Enumerations Service is
      started and by which it may be referenced.  This is any name that may be
      used to reference a GenServer process.  Additionally, this value may be
      set `nil` to clear the currently set Enumerations Service name.

  ## Returns

  Returns the name of the previously set Enumerations Service name or `nil` if
  no Enumerations Service name had been previously set.

  ## Examples

    Setting a specific Enumerations Service name:

      iex> MscmpSystEnums.put_service(:"MscmpSystEnums.TestSupportService")
      ...> MscmpSystEnums.get_service()
      :"MscmpSystEnums.TestSupportService"

    Clearing a previously set specific Service Name:

      iex> MscmpSystEnums.put_service(nil)
      ...> MscmpSystEnums.get_service()
      nil
  """
  @spec put_service(Types.service_name()) :: Types.service_name()
  defdelegate put_service(enums_service_name), to: ProcessUtils

  ##############################################################################
  #
  # get_service
  #
  #

  @doc section: :service_management
  @doc """
  Retrieves the name of the currently set Enumerations Service instance.

  See `put_service/1` for more information about setting an active Enumeration
  Service name.

  ## Returns

  Returns the name of the currently set Enumerations Service name or `nil` if
  no Enumerations Service name has been set.

  ## Examples

    Retrieving a specific Enumerations Service name:

      iex> MscmpSystEnums.put_service(:"MscmpSystEnums.TestSupportService")
      ...> MscmpSystEnums.get_service()
      :"MscmpSystEnums.TestSupportService"

    Retrieving a specific Enumerations Service name when no value is currently
    set for the process:

      iex> MscmpSystEnums.put_service(nil)
      ...> MscmpSystEnums.get_service()
      nil
  """
  @spec get_service() :: Types.service_name()
  defdelegate get_service(), to: ProcessUtils

  ##############################################################################
  #
  # get_values
  #
  #

  @doc section: :enum_data
  @doc """
  Retrieves all values associated with the requested enumeration.

  ## Parameters

    * `enum_name` - the name of the enumeration for which to retrieve values.

  The successful return of this function is an instance of the
  `Msdata.SystEnums` struct containing the values requested.

  ## Examples

      iex> MscmpSystEnums.get_values("example_enumeration")
  """
  @spec get_values(Types.enum_name()) :: Msdata.SystEnums.t()
  defdelegate get_values(enum_name), to: Impl.Enums

  ##############################################################################
  #
  # list_all
  #
  #

  @doc section: :enum_data
  @doc """
  Retrieves all values for all enumerations.

  This function returns all other enumeration metadata, such as the records' IDs,
  descriptions, etc.  Also included is association data for the `enum_items`
  field and the `functional_type` association of each item.

  ## Examples

    iex> MscmpSystEnums.list_all()
  """
  @spec list_all() :: list(Msdata.SystEnums.t())
  defdelegate list_all(), to: Impl.Enums

  ##############################################################################
  #
  # get_syst_defined
  #
  #

  @doc section: :enum_data
  @doc """
  Returns true if the requested enumeration is system defined, false otherwise.

  ## Parameters

    * `enum_name` - the name of the enumeration to test as being system defined.

  ## Examples

      iex> MscmpSystEnums.get_syst_defined("example_enumeration")
      false
  """
  @spec get_syst_defined(Types.enum_name()) :: boolean()
  defdelegate get_syst_defined(enum_name), to: Impl.Enums

  ##############################################################################
  #
  # get_user_maintainable
  #
  #

  @doc section: :enum_data
  @doc """
  Returns true if the requested enumeration is user maintainable, false
  otherwise.

  ## Parameters
    * `enum_name` - the name of the enumeration to test as being user
      maintainable.

  ## Examples

      iex> MscmpSystEnums.get_user_maintainable( "example_enumeration")
      true
  """
  @spec get_user_maintainable(Types.enum_name()) :: boolean()
  defdelegate get_user_maintainable(enum_name), to: Impl.Enums

  ##############################################################################
  #
  # list_items
  #
  #

  @doc section: :enum_item_data
  @doc """
  Returns the list of Enumeration Items associated with the requested
  enumeration.

  ## Parameters

    * `enum_name`- the name of the enumeration for which to retrieve the list of
      enumeration items.
  """
  @spec list_items(Types.enum_name()) :: list(Msdata.SystEnumItems.t())
  defdelegate list_items(enum_name), to: Impl.Enums

  ##############################################################################
  #
  # list_sorted_items
  #
  #

  @doc section: :enum_item_data
  @doc """
  Returns the list of Enumeration Items associated with the requested
  enumeration sorted by their sort_order value.

  In all other regards this function works the same
  `MscmpSystEnums.list_items/1`.
  """
  @spec list_sorted_items(Types.enum_name()) :: list(Msdata.SystEnumItems.t())
  defdelegate list_sorted_items(enum_name), to: Impl.Enums

  ##############################################################################
  #
  # list_functional_types
  #
  #

  @doc section: :enum_functional_type_data
  @doc """
  Returns the list of Enumeration Functional Types associated with the requested
  enumeration.

  ## Parameters

    * `enum_name` - the name of the enumeration for which to retrieve the list
      of enumeration functional types.
  """
  @spec list_functional_types(Types.enum_name()) :: list(Msdata.SystEnumFunctionalTypes.t())
  defdelegate list_functional_types(enum_name), to: Impl.Enums

  ##############################################################################
  #
  # get_item_by_name
  #
  #

  @doc section: :enum_item_data
  @doc """
  Returns an Enumeration Item record from the named Enumeration as identified by
  its name.

  ## Parameters

    * `enum_name` - the name of the Enumeration that is parent to the target
    Enumeration Item record.

    * `enum_item_name` - the name of the Enumeration Item record to return.

  ## Examples

      iex> %Msdata.SystEnumItems{
      ...>   internal_name: "example_enum_item_one"
      ...> } =
      ...>   MscmpSystEnums.get_item_by_name(
      ...>     "example_enumeration",
      ...>     "example_enum_item_one"
      ...>   )
  """
  @spec get_item_by_name(Types.enum_name(), Types.enum_item_name()) ::
          Msdata.SystEnumItems.t() | nil
  defdelegate get_item_by_name(enum_name, enum_item_name), to: Impl.Enums

  ##############################################################################
  #
  # get_item_by_id
  #
  #

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
  @spec get_item_by_id(Types.enum_name(), Ecto.UUID.t()) :: Msdata.SystEnumItems.t() | nil
  defdelegate get_item_by_id(enum_name, enum_item_id), to: Impl.Enums

  ##############################################################################
  #
  # get_functional_type_by_item_id
  #
  #

  @doc section: :enum_functional_type_data
  @doc """
  Returns the internal name of the functional type to which the given Enum Item
  record belongs.

  ## Parameters

    * `enum_name` - the name of the enumeration to which the Enum Item ID
    belongs.

    * `enum_item_id` - the record ID of the Enum Item record of interest.

  ## Example
      iex> example_enum_item = MscmpSystEnums.get_item_by_name(
      ...>   "example_enumeration",
      ...>   "example_enum_item_one")
      iex> MscmpSystEnums.get_functional_type_by_item_id(
      ...>   "example_enumeration",
      ...>   example_enum_item.id)
      "example_enum_func_type_1"
  """
  @spec get_functional_type_by_item_id(Types.enum_name(), Types.enum_item_id()) ::
          Types.enum_functional_type_name()
  defdelegate get_functional_type_by_item_id(enum_name, enum_item_id), to: Impl.Enums

  ##############################################################################
  #
  # get_default_item
  #
  #

  @get_default_item_opts NimbleOptions.new!(Keyword.take(option_defs, [:functional_type_name]))

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

    * `opts` - a keyword list of optional values.

  ## Options

    #{NimbleOptions.docs(@get_default_item_opts)}

  ## Examples
      iex> %Msdata.SystEnumItems{
      ...>   internal_name: "example_enum_item_two"
      ...> } =
      ...>   MscmpSystEnums.get_default_item("example_enumeration")

      iex> %Msdata.SystEnumItems{
      ...>   internal_name: "example_enum_item_one"
      ...> } =
      ...>   MscmpSystEnums.get_default_item(
      ...>     "example_enumeration",
      ...>     [functional_type_name: "example_enum_func_type_1"]
      ...>   )
  """
  @spec get_default_item(Types.enum_name()) :: Msdata.SystEnumItems.t()
  @spec get_default_item(Types.enum_name(), Keyword.t()) :: Msdata.SystEnumItems.t()
  def get_default_item(enum_name, opts \\ []) do
    opts = NimbleOptions.validate!(opts, @get_default_item_opts)
    Impl.Enums.get_default_item(enum_name, opts)
  end

  ##############################################################################
  #
  # create
  #
  #

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
      documentation for `t:MscmpSystEnums.Types.enum_params/0`,
      `t:MscmpSystEnums.Types.enum_functional_type_params/0`, and
      `t:MscmpSystEnums.Types.enum_item_params/0` for more information about the
      available and required attributes.

  ## Examples

      iex> example_enumeration =
      ...>   %{
      ...>      internal_name: "example_create",
      ...>      display_name: "Create Example Enum",
      ...>      user_description: "Demonstrate enumeration creation.",
      ...>      functional_types: [
      ...>        %{
      ...>          internal_name: "example_create_functional_type",
      ...>          display_name: "Create Example Enum / Functional Type",
      ...>          external_name: "Functional Type",
      ...>          user_description: "Demonstrate Functional Type Creation"
      ...>        }
      ...>      ],
      ...>      enum_items: [
      ...>        %{
      ...>          internal_name: "example_create_item",
      ...>          display_name: "Create Example Enum / Enum Item",
      ...>          external_name: "Enum Item",
      ...>          user_description: "Demonstration of enumeration item creation.",
      ...>          enum_default: true,
      ...>          functional_type_default: false,
      ...>          functional_type_name: "example_create_functional_type"
      ...>        }
      ...>      ]
      ...>    }
      iex> MscmpSystEnums.create(example_enumeration)
      :ok
  """
  @spec create(Types.enum_params()) :: :ok | {:error, MscmpSystError.t()}
  def create(enum_params),
    do: ProcessUtils.get_service() |> GenServer.call({:create, enum_params})

  ##############################################################################
  #
  # create_functional_type
  #
  #

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
  @spec create_functional_type(Types.enum_name(), Types.enum_functional_type_params()) ::
          :ok | {:error, MscmpSystError.t()}
  def create_functional_type(enum_name, functional_type_params) do
    ProcessUtils.get_service()
    |> GenServer.call({:create_functional_type, enum_name, functional_type_params})
  end

  ##############################################################################
  #
  # create_item
  #
  #

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
      `t:MscmpSystEnums.Types.enum_item_params/0` which establishes the data
      values for the new enumeration item.
  """
  @spec create_item(Types.enum_name(), Types.enum_item_params()) ::
          :ok | {:error, MscmpSystError.t()}
  def create_item(enum_name, enum_item_params) do
    ProcessUtils.get_service()
    |> GenServer.call({:create_item, enum_name, enum_item_params})
  end

  ##############################################################################
  #
  # set_values
  #
  #

  @doc section: :enum_data
  @doc """
  Changes the values of an existing enumeration.

  You can change the following fields using the this function:

    * `internal_name` - Note that you cannot change the internal name of a
      system defined enumeration.

    * `display_name`

    * `user_description`

    * `default_user_options`

  Other fields of the `Msdata.SystEnums` data type may not be
  modified via this module.  Also note that only the enumeration value itself
  can be modified.  Changes to functional type or enumeration item records must
  be addressed individually.

  ## Parameters

    * `enum_name` - the enumeration which is being modified.

    * `enum_params` - a map of type `t:MscmpSystEnums.Types.enum_params/0` which
      establishes the data values which are to be changed.

  """
  @spec set_values(Types.enum_name(), Types.enum_params()) ::
          :ok | {:error, MscmpSystError.t()}
  def set_values(enum_name, enum_params) do
    ProcessUtils.get_service()
    |> GenServer.call({:set_values, enum_name, enum_params})
  end

  ##############################################################################
  #
  # set_functional_type_values
  #
  #

  @doc section: :enum_functional_type_data
  @doc """
  Change the values of an existing enumeration functional type record.

  The following fields may be changed using this function:

    * `internal_name` - Note that you cannot change the internal name of a
      system defined functional type.

    * `display_name`

    * `external_name`

    * `user_description`

  Other fields of the Msdata.SystEnumFunctionalTypes data type may
  not be modified via this module.

  ## Parameters

    * `enum_name`- the enumeration which is parent to the functional type being
      modified.

    * `functional_type_name` - the specific functional type which will be
      updated.

    * `functional_type_params` - a map of type
      `t:MscmpSystEnums.Types.enum_functional_type_params/0` which establishes
      the data values which are to be changed.

  """
  @spec set_functional_type_values(
          Types.enum_name(),
          Types.enum_functional_type_name(),
          Types.enum_functional_type_params()
        ) :: :ok | {:error, MscmpSystError.t()}
  def set_functional_type_values(
        enum_name,
        functional_type_name,
        functional_type_params
      ) do
    ProcessUtils.get_service()
    |> GenServer.call(
      {:set_functional_type_values, enum_name, functional_type_name, functional_type_params}
    )
  end

  ##############################################################################
  #
  # set_item_values
  #
  #

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

  Other fields of the Msdata.SystEnumItems data type may not be
  modified via this module.

  ## Parameters

    * `enum_name` - the enumeration which is parent to the enumeration item.

    * `enum_item_name` - the specific enumeration item which will be updated.

    * `enum_item_params` - a map of type
      `t:MscmpSystEnums.Types.enum_item_params/0` which establishes the data values
      which are to be changed.
  """
  @spec set_item_values(Types.enum_name(), Types.enum_item_name(), Types.enum_item_params()) ::
          :ok | {:error, MscmpSystError.t()}
  def set_item_values(
        enum_name,
        enum_item_name,
        enum_item_params
      ) do
    ProcessUtils.get_service()
    |> GenServer.call({:set_item_values, enum_name, enum_item_name, enum_item_params})
  end

  ##############################################################################
  #
  # delete
  #
  #

  @doc section: :enum_data
  @doc """
  Deletes a user defined enumeration and its child functional type and
  enumeration item records.

  You cannot delete a system defined enumeration nor can you delete an
  enumeration that has been referenced in other application data records.

  ## Parameters

    * `enum_name` - the enumeration which is to be deleted by the function.
  """
  @spec delete(Types.enum_name()) :: :ok | {:error, MscmpSystError.t()}
  def delete(enum_name) do
    ProcessUtils.get_service()
    |> GenServer.call({:delete, enum_name})
  end

  ##############################################################################
  #
  # delete_functional_type
  #
  #

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
  @spec delete_functional_type(Types.enum_name(), Types.enum_functional_type_name()) ::
          :ok | {:error, MscmpSystError.t()}
  def delete_functional_type(enum_name, functional_type_name) do
    ProcessUtils.get_service()
    |> GenServer.call({:delete_functional_type, enum_name, functional_type_name})
  end

  ##############################################################################
  #
  # delete_item
  #
  #

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
  @spec delete_item(Types.enum_name(), Types.enum_item_name()) ::
          :ok | {:error, MscmpSystError.t()}
  def delete_item(enum_name, enum_item_name) do
    ProcessUtils.get_service()
    |> GenServer.call({:delete_item, enum_name, enum_item_name})
  end
end
