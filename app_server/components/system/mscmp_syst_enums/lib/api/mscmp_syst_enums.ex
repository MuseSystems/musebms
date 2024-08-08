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
  alias MscmpSystEnums.Runtime.DevSupport
  alias MscmpSystEnums.Runtime.ProcessUtils
  alias MscmpSystEnums.Types

  @doc section: :service_management
  @doc """
  Starts an instance of the Enumerations Service.

  Starting the service establishes the required processes and pre-populates the
  service cache with data from the database.  Most other functions in this
  module require that the service is started prior to use and will fail if the
  service is not started.

  ## Parameters

  #{Runtime.Service.get_start_link_opts_docs()}
  """
  @spec start_link(Types.service_name(), MscmpSystDb.Types.context_service_name()) ::
          {:ok, pid()} | {:error, MscmpSystError.t()}
  @spec start_link(Types.service_name(), MscmpSystDb.Types.context_service_name(), Keyword.t()) ::
          {:ok, pid()} | {:error, MscmpSystError.t()}
  defdelegate start_link(service_name, datastore_context_name, opts \\ []), to: Runtime.Service

  @doc section: :service_management
  @doc """
  An optional method for establishing a specific, named Enumerations Service to
  access by the current process.

  In some cases it may be desirable to establish an instance of the Enumerations
  Service outside of the constraints the "Instance Name" as defined by
  `MscmpSystUtils`. In such cases, this function can be used to set a current
  Enumerations Service instance for the current process which will access the named
  Enumerations Service directly rather than the Enumerations Service associated with the
  prevailing named Instance.  See `MscmpSystUtils` for more about establishing
  an instance identity with a given process.

  > #### Limited Use Cases {: .tip}
  >
  > Under most circumstances the correct Enumerations Service instance to access
  > will be determined by the prevailing Instance Name as managed by calls to
  > `MscmpSystUtils.put_instance_name/1` and `MscmpSystUtils.get_instance_name/0`,
  > meaning that typically calls to `put_enums_service/1` are not necessary.
  >
  > The only time this function is required is when an alternative Enumerations
  > Service should be accessed or there is no Instance Name to set for the
  > process using `MscmpSystUtils.put_instance_name/1`.

  ## Parameters

    * `enums_service_name` - the canonical name of the specific Enumerations
    Service to access.  When this function is called with a non-nil argument,
    calls to Enumerations related functions will make use of the Enumerations Service
    specified here, overriding any Enumerations Service which may be started derived
    from the Instance Name.  Setting this value to `nil` will clear the special
    Enumerations Service name and revert to using the Enumerations Service associated
    with the Instance Name, if one has been set.

  ## Examples

    Setting a specific Enumerations Service name:

      iex> MscmpSystEnums.put_enums_service(:"MscmpSystEnums.TestSupportService")
      ...> MscmpSystEnums.get_enums_service()
      :"MscmpSystEnums.TestSupportService"

    Clearing a previously set specific Service Name:

      iex> MscmpSystEnums.put_enums_service(nil)
      ...> MscmpSystEnums.get_enums_service()
      nil
  """
  @spec put_enums_service(Types.service_name()) :: Types.service_name()
  defdelegate put_enums_service(enums_service_name), to: ProcessUtils

  @doc section: :service_management
  @doc """
  Retrieve the current specific Enumerations Service name in effect for the process.

  This function returns the name of the Enumerations Service that has been using the
  `put_enums_service/1` function to override the default Enumerations Service
  associated with the Instance Name. If no specific Enumerations Service name has
  been set, this function will return `nil`.

  ## Examples

    Retrieving a specific Enumerations Service name:

      iex> MscmpSystEnums.put_enums_service(:"MscmpSystEnums.TestSupportService")
      ...> MscmpSystEnums.get_enums_service()
      :"MscmpSystEnums.TestSupportService"

    Retrieving a specific Enumerations Service name when no value is currently set
    for the process:

      iex> MscmpSystEnums.put_enums_service(nil)
      ...> MscmpSystEnums.get_enums_service()
      nil
  """
  @spec get_enums_service() :: Types.service_name()
  defdelegate get_enums_service(), to: ProcessUtils

  @doc section: :enum_data
  @doc """
  Retrieves all values associated with the requested enumeration.

  ## Parameters

    * `enum_name` - the name of the enumeration for which to retrieve values.

  The successful return of this function is an instance of the
  `Msdata.SystEnums` struct containing the values requested.

  ## Examples

      iex> MscmpSystEnums.get_enum_values("example_enumeration")
  """
  @spec get_enum_values(Types.enum_name()) :: Msdata.SystEnums.t()
  defdelegate get_enum_values(enum_name), to: Impl.Enums

  @doc section: :enum_data
  @doc """
  Retrieves all values for all enumerations.

  This function returns all other enumeration metadata, such as the records' IDs,
  descriptions, etc.  Also included is association data for the `enum_items`
  field and the `functional_type` association of each item.

  ## Examples

    iex> MscmpSystEnums.list_all_enums()
  """
  @spec list_all_enums() :: list(Msdata.SystEnums.t())
  defdelegate list_all_enums(), to: Impl.Enums

  @doc section: :enum_data
  @doc """
  Returns true if the requested enumeration is system defined, false otherwise.

  ## Parameters

    * `enum_name` - the name of the enumeration to test as being system defined.

  ## Examples

      iex> MscmpSystEnums.get_enum_syst_defined("example_enumeration")
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

      iex> MscmpSystEnums.get_enum_user_maintainable( "example_enumeration")
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
  @spec list_enum_items(Types.enum_name()) :: list(Msdata.SystEnumItems.t())
  defdelegate list_enum_items(enum_name), to: Impl.Enums

  @doc section: :enum_item_data
  @doc """
  Returns the list of Enumeration Items associated with the requested
  enumeration sorted by their sort_order value.

  In all other regards this function works the same
  `MscmpSystEnums.list_enum_items/1`.
  """
  @spec list_sorted_enum_items(Types.enum_name()) :: list(Msdata.SystEnumItems.t())
  defdelegate list_sorted_enum_items(enum_name), to: Impl.Enums

  @doc section: :enum_functional_type_data
  @doc """
  Returns the list of Enumeration Functional Types associated with the requested
  enumeration.

  ## Parameters

    * `enum_name` - the name of the enumeration for which to retrieve the list
      of enumeration functional types.
  """
  @spec list_enum_functional_types(Types.enum_name()) :: list(Msdata.SystEnumFunctionalTypes.t())
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

      iex> %Msdata.SystEnumItems{
      ...>   internal_name: "example_enum_item_one"
      ...> } =
      ...>   MscmpSystEnums.get_enum_item_by_name(
      ...>     "example_enumeration",
      ...>     "example_enum_item_one"
      ...>   )
  """
  @spec get_enum_item_by_name(Types.enum_name(), Types.enum_item_name()) ::
          Msdata.SystEnumItems.t() | nil
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
  @spec get_enum_item_by_id(Types.enum_name(), Ecto.UUID.t()) :: Msdata.SystEnumItems.t() | nil
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
      iex> example_enum_item = MscmpSystEnums.get_enum_item_by_name(
      ...>   "example_enumeration",
      ...>   "example_enum_item_one")
      iex> MscmpSystEnums.get_functional_type_by_enum_item_id(
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
      iex> %Msdata.SystEnumItems{
      ...>   internal_name: "example_enum_item_two"
      ...> } =
      ...>   MscmpSystEnums.get_default_enum_item("example_enumeration")

      iex> %Msdata.SystEnumItems{
      ...>   internal_name: "example_enum_item_one"
      ...> } =
      ...>   MscmpSystEnums.get_default_enum_item(
      ...>     "example_enumeration",
      ...>     [functional_type_name: "example_enum_func_type_1"]
      ...>   )
  """
  @spec get_default_enum_item(Types.enum_name(), Keyword.t() | []) :: Msdata.SystEnumItems.t()
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
      documentation for `t:MscmpSystEnums.Types.enum_params/0`,
      `t:MscmpSystEnums.Types.enum_functional_type_params/0`, and
      `t:MscmpSystEnums.Types.enum_item_params/0` for more information about the
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
      iex> MscmpSystEnums.create_enum(example_enumeration)
      :ok
  """
  @spec create_enum(Types.enum_params()) :: :ok | {:error, MscmpSystError.t()}
  def create_enum(enum_params),
    do: ProcessUtils.get_enums_service() |> GenServer.call({:create_enum, enum_params})

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
    ProcessUtils.get_enums_service()
    |> GenServer.call({:create_enum_functional_type, enum_name, functional_type_params})
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
      `t:MscmpSystEnums.Types.enum_item_params/0` which establishes the data
      values for the new enumeration item.
  """
  @spec create_enum_item(Types.enum_name(), Types.enum_item_params()) ::
          :ok | {:error, MscmpSystError.t()}
  def create_enum_item(enum_name, enum_item_params) do
    ProcessUtils.get_enums_service()
    |> GenServer.call({:create_enum_item, enum_name, enum_item_params})
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

  Other fields of the `Msdata.SystEnums` data type may not be
  modified via this module.  Also note that only the enumeration value itself
  can be modified.  Changes to functional type or enumeration item records must
  be addressed individually.

  ## Parameters

    * `enum_name` - the enumeration which is being modified.

    * `enum_params` - a map of type `t:MscmpSystEnums.Types.enum_params/0` which
      establishes the data values which are to be changed.

  """
  @spec set_enum_values(Types.enum_name(), Types.enum_params()) ::
          :ok | {:error, MscmpSystError.t()}
  def set_enum_values(enum_name, enum_params) do
    ProcessUtils.get_enums_service()
    |> GenServer.call({:set_enum_values, enum_name, enum_params})
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
    ProcessUtils.get_enums_service()
    |> GenServer.call(
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

  Other fields of the Msdata.SystEnumItems data type may not be
  modified via this module.

  ## Parameters

    * `enum_name` - the enumeration which is parent to the enumeration item.

    * `enum_item_name` - the specific enumeration item which will be updated.

    * `enum_item_params` - a map of type
      `t:MscmpSystEnums.Types.enum_item_params/0` which establishes the data values
      which are to be changed.
  """
  @spec set_enum_item_values(Types.enum_name(), Types.enum_item_name(), Types.enum_item_params()) ::
          :ok | {:error, MscmpSystError.t()}
  def set_enum_item_values(
        enum_name,
        enum_item_name,
        enum_item_params
      ) do
    ProcessUtils.get_enums_service()
    |> GenServer.call({:set_enum_item_values, enum_name, enum_item_name, enum_item_params})
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
    ProcessUtils.get_enums_service()
    |> GenServer.call({:delete_enum, enum_name})
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
    ProcessUtils.get_enums_service()
    |> GenServer.call({:delete_enum_functional_type, enum_name, functional_type_name})
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
    ProcessUtils.get_enums_service()
    |> GenServer.call({:delete_enum_item, enum_name, enum_item_name})
  end

  @doc section: :development_support
  @doc """
  Starts a Enumerations Service instance for the purposes of supporting interactive
  development or testing activities.

  >#### Not for Production {: .warning}
  >
  > This operation is specifically intended to support development and testing
  > activities and should not be used by code which runs in production
  > environments.

  ## Parameters

    * `opts` - a `t:Keyword.t/0` list of optional parameters which can override
      default values for service parameters.

  ## Options

    #{Runtime.DevSupport.get_devsupport_opts_docs()}
  """
  @spec start_support_services() :: :ok
  @spec start_support_services(keyword()) :: :ok
  defdelegate start_support_services(opts \\ []), to: DevSupport

  @doc section: :development_support
  @doc """
  Starts a Enumerations Service instance for the purposes of supporting
  interactive development activities.

  >#### Not for Production {: .warning}
  >
  > This operation is specifically intended to support development and should
  > not be used by code which runs in production environments.

  Currently this function simply redirects to `start_support_services/1`.

  ## Parameters

    * `opts` - a `t:Keyword.t/0` list of optional parameters which can override
      default values for service parameters.

  ## Options

    #{Runtime.DevSupport.get_devsupport_opts_docs()}
  """
  @spec start_devsupport_services() :: :ok
  @spec start_devsupport_services(keyword()) :: :ok
  defdelegate start_devsupport_services(opts \\ []), to: DevSupport, as: :start_support_services

  @doc section: :development_support
  @doc """
  Starts a Enumerations Service instance for the purposes of supporting testing
  activities.

  >#### Not for Production {: .warning}
  >
  > This operation is specifically intended to support testing activities and
  > should not be used by code which runs in production environments.

  ## Parameters

    * `opts` - a `t:Keyword.t/0` list of optional parameters which can override
      default values for service parameters.

  ## Options

    #{Runtime.DevSupport.get_testsupport_opts_docs()}
  """
  @spec start_testsupport_services() :: :ok
  @spec start_testsupport_services(keyword()) :: :ok
  defdelegate start_testsupport_services(opts \\ []), to: DevSupport

  @doc section: :development_support
  @doc """
  Stops previously started Enumerations support services.

  ## Parameters

    * `opts` - a `t:Keyword.t/0` list of optional parameters.

  ## Options

    #{Runtime.DevSupport.get_devsupport_stop_opts_docs()}
  """
  @spec stop_support_services() :: :ok
  @spec stop_support_services(keyword()) :: :ok
  defdelegate stop_support_services(opts \\ []), to: Runtime.DevSupport

  @doc section: :development_support
  @doc """
  Stops previously started Enumerations development support services.

  ## Parameters

    * `opts` - a `t:Keyword.t/0` list of optional parameters.  See `Options` for
      details.

  ## Options

    #{Runtime.DevSupport.get_devsupport_stop_opts_docs()}
  """
  @spec stop_devsupport_services() :: :ok
  @spec stop_devsupport_services(keyword()) :: :ok
  defdelegate stop_devsupport_services(opts \\ []),
    to: Runtime.DevSupport,
    as: :stop_support_services

  @doc section: :development_support
  @doc """
  Stops previously started Enumerations testing support services.

  ## Parameters

    * `opts` - a `t:Keyword.t/0` list of optional parameters.

  ## Options

    #{Runtime.DevSupport.get_testsupport_stop_opts_docs()}
  """
  @spec stop_testsupport_services() :: :ok
  @spec stop_testsupport_services(keyword()) :: :ok
  defdelegate stop_testsupport_services(opts \\ []),
    to: Runtime.DevSupport

  @doc section: :development_support
  @doc """
  Returns the name of the development support service.
  """
  @spec get_devsupport_service_name() :: atom()
  defdelegate get_devsupport_service_name, to: Runtime.DevSupport

  @doc section: :development_support
  @doc """
  Returns the name of the test support service.
  """
  @spec get_testsupport_service_name() :: atom()
  defdelegate get_testsupport_service_name, to: Runtime.DevSupport
end
