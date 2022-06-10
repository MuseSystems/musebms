defmodule MsbmsSystInstanceMgr do
  alias MsbmsSystInstanceMgr.Data
  alias MsbmsSystInstanceMgr.Impl
  alias MsbmsSystInstanceMgr.Types

  @moduledoc """
  Functionality allowing for the management of application Instances.

  "Instances" are instances of running application environments.  Instances are
  established to host the application for different purposes, such as for
  running the application for production, training, and testing purposes; or as
  a means to implement multi-tenancy where each tenant application environment
  is an Instance.
  """

  @doc """
  Returns a simple list of applications sorted according to the database
  collation.

  ## Examples

      iex> {:ok, _apps} = MsbmsSystInstanceMgr.list_applications()
  """
  @spec list_applications() :: {:ok, list()} | {:error, MsbmsSystError.t()}
  defdelegate list_applications, to: Impl.Applications

  @doc """
  Returns a simple list of owners with optional filtering by owner status and
  sorting.

  ## Options

    * `owner_state_functional_types` - a list of one or more owner state
    functional types with which to filter the list of returned SystOwners
    records.  If this parameter is not provided, then all owners defined in
    the system will be returned.

    * `sort` - A boolean value that, if true, will cause the list of SystOwner
    records to be sorted by the record's Display Name field.  Sorting is done
    by the database and will follow database collation rules for the sort.

  ## Examples

      iex> {:ok, [_ | _]} = MsbmsSystInstanceMgr.list_owners()

      iex> {:ok, [_ | _]} =
      ...>   MsbmsSystInstanceMgr.list_owners(
      ...>     owner_state_functional_types: [:owner_states_active]
      ...>   )
  """
  @spec list_owners(
          Keyword.t(
            owner_state_functional_types: list(Types.owner_state_functional_types()) | [],
            sort: boolean()
          )
          | []
        ) ::
          {:ok, list(Data.SystOwners.t())} | {:error, MsbmsSystError.t()}
  defdelegate list_owners(opts \\ []),
    to: Impl.Owners

  @doc """
  Creates a new `MsbmsSystInstanceMgr.Data.SystOwners` record in the system.

  ## Parameters

    * `owner_name` - a unique key used in programmatic contexts to identify the
    owner record.

    * `owner_display_name` - sets the name of the SystOwners record for the
    purposes of display to users in UIs and reporting.  This value is required
    to be unique across all SystOwners records.

    * `owner_state_id` - sets initial life-cycle state of the SystOwners record.
    This value must be that of an existing
    `t:MsbmsSystEnums.Data.SystEnumItems/0` record.

  ## Examples

      iex> new_owner_state =
      ...>   MsbmsSystEnums.get_default_enum_item("owner_states")
      iex> {:ok, _new_owner} =
      ...>   MsbmsSystInstanceMgr.create_owner(
      ...>     "owner_example_1",
      ...>     "Owner Example Creation",
      ...>     new_owner_state.id
      ...>   )
  """
  @spec create_owner(Types.owner_name(), String.t(), Ecto.UUID.t()) ::
          {:ok, Data.SystOwners.t()} | {:error, MsbmsSystError.t()}
  defdelegate create_owner(owner_name, owner_display_name, owner_state_id),
    to: Impl.Owners

  @doc """
  Retrieves a full `MsbmsSystInstanceMgr.Data.SystOwners` record by its
  internal_name.

  ## Parameters

    * `owner_name` - The internal name of the owner to retrieve.

  ## Examples

      iex> {:ok, _owner} =
      ...>   MsbmsSystInstanceMgr.get_owner_by_name("owner1")
  """
  @spec get_owner_by_name(Types.owner_name()) ::
          {:ok, Data.SystOwners.t()} | {:error, MsbmsSystError.t()}
  defdelegate get_owner_by_name(owner_name), to: Impl.Owners

  @doc """
  Updates an existing `MsbmsSystInstanceMgr.Data.SystOwners` record.

  ## Parameters

    * `owner_name` - the internal name of an existing SystOwners record.

    * `owner_params` - a map where the keys are a subset of the fields
    defined by `t:MsbmsSystInstanceMgr.Data.SystOwners.t/0`.  Only those keys
    representing values that are actually changing need be included in the map.
    The fields available for updating using this function are:

      * `internal_name` - a unique identifier for use in programmatic contexts.
      While this value may be changed after SystOwners creation, typically it
      will remain the same for the life of the record.  It is recommended to
      only allow changes when circumstances warrant a significant change to
      record identification.

      * `display_name` - a unique identifier used in UI and reporting end user
      displays.  This value is expected to be changed when convenient.

      * `owner_state_id` - The id of an existing
      `t:MsbmsSystEnums.Data.SystEnumItems/0` record which represents the new
      state of the SystOwners record.

  ## Examples
      iex> {:ok, _updated_owner} =
      ...>   MsbmsSystInstanceMgr.set_owner_values(
      ...>     "set_owner_example",
      ...>     %{
      ...>       internal_name: "set_owner_example_updated",
      ...>       display_name: "Updated Owner Display Name"
      ...>      }
      ...>   )
  """
  @spec set_owner_values(Types.owner_name(), Types.owner_params()) ::
          {:ok, Data.SystOwners.t()} | {:error, MsbmsSystError.t()}
  defdelegate set_owner_values(owner_name, owner_params), to: Impl.Owners

  @doc """
  Deletes a single `MsbmsSystInstanceMgr.Data.SystOwners` record from the system.

  > #### Note {: .neutral}
  >
  > You can only purge SystOwners records when their Owner State is one that is
  > in the `owner_states` functional type `owner_states_purge_eligible`.  If the
  > SystOwners is in a state with a different functional type, an error tuple
  > will be returned.

  ## Parameters

    * `owner_name` - The internal name of the SystOwners record to purge.
    The identified SystOwners record must exist or an error tuple will be
    returned.

  ## Examples

  An owner in a state with functional type `owner_states_purge_eligible` will be
  purged by the function.

      iex> owner_state =
      ...>   MsbmsSystEnums.get_default_enum_item(
      ...>     "owner_states",
      ...>     functional_type_name: "owner_states_purge_eligible"
      ...>   )
      iex> { :ok, _owner} =
      ...>   MsbmsSystInstanceMgr.create_owner(
      ...>     "example_purge",
      ...>     "Purge Example",
      ...>     owner_state.id
      ...>   )
      iex> {:ok, {1, _recs}} = MsbmsSystInstanceMgr.purge_owner("example_purge")

  However calling the function for an owner in a state of some other functional
  type results in an error result being returned.

      iex> owner_state =
      ...>   MsbmsSystEnums.get_default_enum_item(
      ...>     "owner_states",
      ...>     functional_type_name: "owner_states_active"
      ...>   )
      iex> { :ok, _owner} =
      ...>   MsbmsSystInstanceMgr.create_owner(
      ...>     "purge_failure_example",
      ...>     "Purge Failure Example",
      ...>     owner_state.id
      ...>   )
      iex> {:error, _reason} = MsbmsSystInstanceMgr.purge_owner("purge_failure_example")
  """
  @spec purge_owner(Types.owner_name()) ::
          {:ok, {non_neg_integer(), nil | [term()]}} | {:error, MsbmsSystError.t()}
  defdelegate purge_owner(owner_name), to: Impl.Owners

  @doc """
  Deletes all `MsbmsSystInstanceMgr.Data.SystOwners` records that are in a purge
  eligible owner state.

  Unlike the `MsbmsInstanceMgr.purge_owner/1`, this function will not return an
  `:error` tuple if there are no eligible records to purge.  In that case the
  deleted records count returned in the `:ok` tuple will simply be 0.
  """
  @spec purge_all_eligible_owners() ::
          {:ok, {non_neg_integer(), nil | [term()]}} | {:error, MsbmsSystError.t()}
  defdelegate purge_all_eligible_owners(), to: Impl.Owners

  @doc """
  Retrieves the list of available Owner States configured in the system.

  ## Examples

      iex> {:ok, [_ | _]} = MsbmsSystInstanceMgr.list_owner_states()

  """
  @spec list_owner_states() ::
          {:ok, list(MsbmsSystEnums.Data.SystEnumItems.t())} | {:error, MsbmsSystError.t()}
  defdelegate list_owner_states, to: Impl.OwnerStates

  @doc """
  Creates a new Owner State base on the provided parameters.

  Owner States describe each available stage in the Owners record life-cycle.
  This may include defining if the record is active, inactive, or eligible for
  purging from the system.

  ## Parameters

    * `owner_state_params` - A map of field names and their values to use in
    creating the new Owner State.  The available fields are:

      * `internal_name` - identifies a record using a known reference suitable
      for use in programmatic contexts.  Owner States are system enumerations
      and the internal_name must be unique across all enumeration items setup
      in the system.  This field is required.

      * `display_name` - a user visible, but unique, name for the Owner State
      that can be used to distinguish specific Owner States in user
      interfaces.  Because these names are unique, they may be longer than
      desired for some use cases.  This field is required.

      * `external_name` - a name which is used in user interface displays, but
      in contexts where visually apparent uniqueness is less important than
      brevity.  This field is required.

      * `functional_type_name` - The functional type determines the system
      functionality that may be applied when an Owner is in a given state.
      For more see
      `t:MsbmsSystInstanceMgr.Types.owner_state_functional_types/0`.  This
      field is required.

      * `user_description` - a brief description of the Owner State informing
      application users of the purpose and use of the Owner State.  This
      field is required.

      * `enum_default` - establishes whether or not this Owner State is the
      default Owner State in the system.  This field is not required and
      defaults to false if not provided.

      * `functional_type_default` - if true then the new Owner State will be
      the default state for a given functional type.  This field is not required
      and defaults to false if not provided.

  ## Examples

      iex> owner_state_params = %{
      ...>   internal_name: "owner_state_create_example",
      ...>   display_name: "Owner State / Create Example",
      ...>   external_name: "Create Owner Example",
      ...>   user_description: "An example of Owner State creation.",
      ...>   functional_type_name: "owner_states_active"
      ...> }
      iex> {:ok, _new_owner_state} =
      ...>   MsbmsSystInstanceMgr.create_owner_state(owner_state_params)

  """
  @spec create_owner_state(Types.owner_state_params()) ::
          {:ok, MsbmsSystEnums.Data.SystEnumItems.t()} | {:error, MsbmsSystError.t()}
  defdelegate create_owner_state(owner_state_params), to: Impl.OwnerStates

  @doc """
  Retrieve an Owner State by its internal name.

  ## Parameters

    * `owner_state_name` - the internal name of the Owner State record to
    retrieve.

  ## Examples

      iex> {:ok, _owner_state} =
      ...>   MsbmsSystInstanceMgr.get_owner_state_by_name("owner_states_active")
  """
  @spec get_owner_state_by_name(MsbmsSystEnums.Types.enum_item_name()) ::
          {:ok, MsbmsSystEnums.Data.SystEnumItems.t()} | {:error, MsbmsSystError.t()}
  defdelegate get_owner_state_by_name(owner_state_name), to: Impl.OwnerStates

  @doc """
  Change one or more of the attributes of an existing Owner State record.

  ## Parameters

    * `owner_state_name` - the internal name of an existing Owner State record.

    * `owner_state_params` - A map of field names and their values to use in
    changing the new Owner State.  The available fields are:

      * `internal_name` - identifies a record using a known reference suitable
      for use in programmatic contexts.  Owner States are system enumerations
      and the internal_name must be unique across all enumeration items setup
      in the system.

      * `display_name` - a user visible, but unique, name for the Owner State
      that can be used to distinguish specific Owner States in user
      interfaces.  Because these names are unique, they may be longer than
      desired for some use cases.

      * `external_name` - a name which is used in user interface displays, but
      in contexts where visually apparent uniqueness is less important than
      brevity.

      * `user_description` - a brief description of the Owner State informing
      application users of the purpose and use of the Owner State.

      * `enum_default` - establishes whether or not this Owner State is the
      default Owner State in the system.

      * `functional_type_default` - if true then the new Owner State will be
      the default state for a given functional type.

    > #### Note {: .neutral}
    >
    > Note that the functional type of an Owner State record may not be changed
    > after the record is created.  The reason for this is that any Owner records
    > that may already be in the Owner State being updated would silently assume
    > a new functional type, one that might require some process on entry, etc.
  """
  @spec set_owner_state_values(MsbmsSystEnums.Types.enum_item_name(), Types.owner_state_params()) ::
          {:ok, MsbmsSystEnums.Data.SystEnumItems.t()} | {:error, MsbmsSystError.t()}
  defdelegate set_owner_state_values(owner_state_name, owner_state_params),
    to: Impl.OwnerStates

  @doc """
  Deletes an Owner State record which is identified by its internal name.

  ## Parameters

    * `owner_state_name` - the internal name of an existing Owner State record
    to delete from the system.

  ## Examples

      iex> :ok = MsbmsSystInstanceMgr.delete_owner_state("owner_state_delete_example")
  """
  @spec delete_owner_state(MsbmsSystEnums.Types.enum_item_name()) ::
          :ok | {:error, MsbmsSystError.t()}
  defdelegate delete_owner_state(owner_state_name), to: Impl.OwnerStates

  @doc """
  Retrieves a list of `MsbmsSystInstanceMgr.Data.SystInstances` records set up
  in the system.

  The returned list is not the full data of the records, but a map of the most
  essential data defined by
  `t:MsbmsSystInstanceMgr.Types.instances_list_item/0`.

  ## Parameters

    * `opts` - an optional keyword list containing one or more of the available
    options.

  ## Options

    * `instance_types` - A list of one or more values from the
    `t:MsbmsSystInstanceMgr.Types.instance_type_name/0` type to include in the
    results.

    * `instance_state_functional_types` - A list of one or more values from the
    `t:MsbmsSystInstanceMgr.Types.instance_state_functional_types/0` type to
    include in the results.

    * `owner_id` - The id value of an `MsbmsSystInstanceMgr.Data.SystOwners`
    record to which to restrict the results returned.

    * `owner_state_functional_types` - A list of
    `t:MsbmsSystInstanceMgr.Types.owner_state_functional_types/0` which filters
    the Instances list based on the state of their Owners.

    * `applications` - A list of applications to filter the Instances list with.

    * `sort` - A list of one or more of three possible values:

      * `:owner` - the returned list will be sorted by Owner display names.

      * `:application` - the returned list will be sorted by Application display
      names.

      * `:instance` - the returned list will be sorted by the Instance display
      names.

    the order that each of the three sort options are provided is the order in
    which they are applied to the result.

  ## Examples

  Without parameters the entire list is returned.

      iex> {:ok, [_ | _]} = MsbmsSystInstanceMgr.list_instances()

  However, filters and sorts can be added as via the `opts` parameter.

      iex> {:ok, [_ | _]} =
      ...>   MsbmsSystInstanceMgr.list_instances(
      ...>     instance_state_functional_type: [:instance_states_active],
      ...>     sort: [:owner, :application, :instance]
      ...>   )
  """
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
  defdelegate list_instances(opts \\ []), to: Impl.Instances

  @doc """
  Returns a specific `MsbmsSystInstanceMgr.Data.SystInstances` record for the
  given internal name of the record.

  The data returned includes data for the Instance's application, type, state,
  owner, the data of the "owner instance" if the requested instance is a child
  of a parent instance, and the children instance records if the requested
  instance is a parent to other instances.
  ## Parameters

    * `instance_name` - the internal name of the instance to retrieve.

  ## Examples

      iex> {:ok, _instance} =
      ...>   MsbmsSystInstanceMgr.get_instance_by_name("app1_owner1_instance_types_big")
  """
  @spec get_instance_by_name(Types.instance_name()) ::
          {:ok, Data.SystInstances.t()} | {:error, MsbmsSystError.t()}
  defdelegate get_instance_by_name(instance_name), to: Impl.Instances

  @doc """
  Creates a new Instance record based on the provided parameters.

  ## Parameters

    * `instance_params` - the parameters with which to create the new instance.
    The available attributes which are expected are:

      * `internal_name` - the unique identifier for the instance which is used
      in programmatic contexts.  This field is required.

      * `display_name` - a user facing unique identifier for the instance as
      used in user interfaces.  This field is required.

      * `application_id` - the unique database identifier of the application for
      which this instance provides services.  This field is required if the
      `application_name` field is not provided.

      * `application_name` - the unique identifier of the application for which
      this instance provides services.  This field is required if the
      `application_id` field is not provided.

      * `instance_type_id` - the unique database identifier of the Instance
      Type of the instance.  Instance types determine which database servers are
      available to service the Instance and other similar runtime
      categorization.  This field is optional and the default Instance Type
      will be used if no Instance Type is identified.  Alternatively, the
      `instance_type_name` parameter may be used to select the Instance Type.

      * `instance_type_name` - the unique identifier of the Instance Type of the
      Instance.  This field is optional and the default Instance Type will be
      used if no Instance Type is identified.  Alternatively, the
      `instance_type_id` parameter may be used to select the Instance Type.

      * `instance_state_id` - the unique database identifier of the Instance
      State of the Instance.  The Instance State defines the current life-
      cycle state of the Instance which can influence system behavior in regard
      to the Instance, such as if the Instance should be started or not or even
      if it is eligible for purging.  This field is optional and the default
      Instance State will be used if no Instance State is identified.
      Alternatively, the `instance_state_name` parameter may be used to to
      select the Instance State.

      * `instance_state_name` - the unique identifier of the Instance State of
      the Instance.  This field is optional and the default Instance State will
      be used if no Instance State is identified.  Alternatively, the
      `instance_state_id` parameter may be used to select the Instance State.

      * `owner_id` - the unique database identifier of the Owner of the
      Instance.  The Owner is a reference to the entity which is served by the
      application.  This field is required unless the `owner_name` field is
      provided instead.

      * `owner_name` - the unique identifier of the Owner of the Instance.  This
      field is required unless the `owner_id` field has been provided instead.

      * `owning_instance_id` - the unique database identifier of the Owning
      Instance.  An Owning Instance is an regular Instance which acts as a
      parent to its Owned Instances. For example, a parent production Instance
      may be parent to a duplicate Instance used for training.  This field is
      optional.  An Owning Instance may alternatively be identified by the
      `owning_instance_name` field.

      * `owning_instance_name` - the unique identifier of the Owning Instance.
      This field is optional.  An Owning Instance may alternatively be
      identified by the `owning_instance_id` field.

      * `instance_options` - a map of options which determine how the Instance
      connects to its host database server.  See
      `t:MsbmsSystInstanceMgr.Types.instance_options/0` for more.

  ## Examples

      iex> new_instance_params = %{
      ...>   internal_name: "create_example_instance",
      ...>   display_name: "Create Example Instance",
      ...>   application_name: "test_app_1",
      ...>   owner_name: "owner_1"
      ...> }
      iex> {:ok, _new_instance} = MsbmsSystInstanceMgr.create_instance(new_instance_params)

  """
  @spec create_instance(Types.instance_params()) ::
          {:ok, Data.SystInstances.t()} | {:error, MsbmsSystError.t()}
  defdelegate create_instance(instance_params), to: Impl.Instances

  @doc """
  Returns a list of the configured Instance Types to which an Instance may be
  assigned.

  ## Examples

      iex> {:ok, [_ | _]} = MsbmsSystInstanceMgr.list_instance_types()
  """
  @spec list_instance_types() ::
          {:ok, list(MsbmsSystEnums.Data.SystEnumItems.t())} | {:error, MsbmsSystError.t()}
  defdelegate list_instance_types, to: Impl.InstanceTypes

  @doc """
  Creates an new Instance Type in the system.

  Instance Types are used to categorize Instances based on their operational
  characteristics.  This includes information such as the default database
  connection pool sizes for each of the datastore contexts and classes of usage
  such as production systems vs. training environments.

  ## Parameters

    * `instance_type_params` - A map of field names and their values to use in
    creating the new Instance Type.  The available fields are:

      * `internal_name` - identifies a record using a known reference suitable
      for use in programmatic contexts.  Instance Types are system enumerations
      and the internal_name must be unique across all enumeration items setup
      in the system.  This field is required.

      * `display_name` - a user visible, but unique, name for the Instance Type
      that can be used to distinguish specific Instance Types in user
      interfaces.  Because these names are unique, they may be longer than
      desired for some use cases.  This field is required.

      * `external_name` - a name which is used in user interface displays, but
      in contexts where visually apparent uniqueness is less important than
      brevity.  This field is required.

      * `functional_type_name` - establishes the class of the instance type and
      is used in matching instance types to the database servers which can
      support them. For more see
      `t:MsbmsSystInstanceMgr.Types.instance_type_functional_types/0`.  This
      field is required.

      * `user_description` - a brief description of the Instance Type informing
      application users of the purpose and use of the Instance Type.  This field
      is required.

      * `user_options` - for Instance Types, this value should be a map
      which minimally defines the default database connection pool sizes for
      each type of Instance.  Other defaults may be included depending on the
      application needs.  See
      `t:MsbmsSystInstanceMgr.Types.instance_type_default_options/0` for more
      information.  This field is required.

      * `enum_default` - establishes whether or not this Instance Type is the
      default Instance Type in the system.  This field is not required and
      defaults to false if not provided.

  ## Examples

      iex> instance_type_params = %{
      ...>   internal_name: "instance_types_new_example",
      ...>   display_name: "Instance Types / New Example",
      ...>   external_name: "New Example",
      ...>   enum_default: false,
      ...>   user_description: "An example of creating an instance type.",
      ...>   user_options: %{"allowed_server_pools" => ["primary", "sandbox"] }
      ...> }
      iex> {:ok, _new_instance_type} =
      ...>   MsbmsSystInstanceMgr.create_instance_type(instance_type_params)

  """
  @spec create_instance_type(Types.instance_type_params()) ::
          {:ok, MsbmsSystEnums.Data.SystEnumItems.t()} | {:error, MsbmsSystError.t()}
  defdelegate create_instance_type(instance_type_params), to: Impl.InstanceTypes

  @doc """
  Retrieves and Instance Type record as found by its internal name.

  ## Parameters

    * `instance_type_name` - the internal name of the Instance Type to retrieve.

  ## Examples

      iex> {:ok, _instance_type} =
      ...>   MsbmsSystInstanceMgr.get_instance_type_by_name("instance_types_big")
  """
  @spec get_instance_type_by_name(MsbmsSystEnums.Types.enum_item_name()) ::
          {:ok, MsbmsSystEnums.Data.SystEnumItems.t()} | {:error, MsbmsSystError.t()}
  defdelegate get_instance_type_by_name(instance_type_name), to: Impl.InstanceTypes

  @doc """
  Changes the values of an existing Instance Type.

  ## Parameters

    * `instance_type_name` - The internal name of the instance type to update.

    * `instance_type_params` - A map of field names and their values to use in
    creating the new Instance Type.  The available fields are:

      * `internal_name` - identifies a record using a known reference suitable
      for use in programmatic contexts.  Instance Types are system enumerations
      and the internal_name must be unique across all enumeration items setup
      in the system.

      * `display_name` - a user visible, but unique, name for the Instance Type
      that can be used to distinguish specific Instance Types in user
      interfaces.  Because these names are unique, they may be longer than
      desired for some use cases.

      * `external_name` - a name which is used in user interface displays, but
      in contexts where visually apparent uniqueness is less important than
      brevity.

      * `functional_type_name` - establishes the class of the instance type and
      is used in matching instance types to the database servers which can
      support them. For more see
      `t:MsbmsSystInstanceMgr.Types.instance_type_functional_types/0`.

      * `user_description` - a brief description of the Instance Type informing
      application users of the purpose and use of the Instance Type.

      * `user_options` - for Instance Types, this value should be a map
      which minimally defines the default database connection pool sizes for
      each type of Instance.  Other defaults may be included depending on the
      application needs.  See
      `t:MsbmsSystInstanceMgr.Types.instance_type_default_options/0` for more
      information.

      * `enum_default` - establishes whether or not this Instance Type is the
      default Instance Type in the system.

  ## Examples

      iex> instance_type_updates = %{
      ...>   external_name: "Small Instance (Updated)"
      ...> }
      iex> { :ok,
      ...>   %MsbmsSystEnums.Data.SystEnumItems{
      ...>     external_name: "Small Instance (Updated)"
      ...>     }
      ...> } =
      ...>   MsbmsSystInstanceMgr.set_instance_type_values(
      ...>     "instance_types_sml",
      ...>     instance_type_updates
      ...>   )
  """
  @spec set_instance_type_values(
          MsbmsSystEnums.Types.enum_item_name(),
          Types.instance_type_params()
        ) :: {:ok, MsbmsSystEnums.Data.SystEnumItems.t()} | {:error, MsbmsSystError.t()}
  defdelegate set_instance_type_values(instance_type_name, instance_type_params),
    to: Impl.InstanceTypes

  @doc """
  Deletes an Instance Type as identified by its internal name.

  Note that if the Instance Type is still in use by any Instance records an
  error result will be produced.

  ## Parameters

    * `instance_type_name` - the internal name of the Instance Type to delete.

  ## Examples

    iex> :ok = MsbmsSystInstanceMgr.delete_instance_type("instance_type_delete_example")
  """
  @spec delete_instance_type(MsbmsSystEnums.Types.enum_item_name()) ::
          :ok | {:error, MsbmsSystError.t()}
  defdelegate delete_instance_type(instance_type_name), to: Impl.InstanceTypes

  @doc """
  Retrieves the list of Instance States available in the system.

  ## Examples

      iex> {:ok, [_ | _]} = MsbmsSystInstanceMgr.list_instance_states()
  """
  @spec list_instance_states() ::
          {:ok, list(MsbmsSystEnums.Data.SystEnumItems.t())} | {:error, MsbmsSystError.t()}
  defdelegate list_instance_states, to: Impl.InstanceStates

  @doc """
  Creates a new Instance State record.

  Instance States describe the life-cycle of instances.  These states include
  such ideas as the instance being initialized for use, useable, suspended, or
  eligible for purging from the system.

  ## Parameters

    * `instance_state_params` - A map of field names and their values to use in
    creating the new Instance State.  The available fields are:

      * `internal_name` - identifies a record using a known reference suitable
      for use in programmatic contexts.  Instance States are system enumerations
      and the internal_name must be unique across all enumeration items setup
      in the system.  This field is required.

      * `display_name` - a user visible, but unique, name for the Instance State
      that can be used to distinguish specific Instance States in user
      interfaces.  Because these names are unique, they may be longer than
      desired for some use cases.  This field is required.

      * `external_name` - a name which is used in user interface displays, but
      in contexts where visually apparent uniqueness is less important than
      brevity.  This field is required.

      * `functional_type_name` - The functional type determines the system
      functionality that may be applied when an Instance is in a given state.
      For more see
      `t:MsbmsSystInstanceMgr.Types.instance_state_functional_types/0`.  This
      field is required.

      * `user_description` - a brief description of the Instance State informing
      application users of the purpose and use of the Instance State.  This
      field is required.

      * `enum_default` - establishes whether or not this Instance State is the
      default Instance State in the system.  This field is not required and
      defaults to false if not provided.

      * `functional_type_default` - if true then the new Instance State will be
      the default state for a given functional type.  This field is not required
      and defaults to false if not provided.

  ## Examples

  iex> instance_state_params = %{
  ...>   internal_name: "instance_state_create_state_example",
  ...>   display_name: "Instance State / Create State Example",
  ...>   external_name: "Create Instance State Example",
  ...>   user_description: "An example of instance state creation.",
  ...>   functional_type_name: "instance_states_active"
  ...> }
  iex> {:ok, _new_instance_state} =
  ...>   MsbmsSystInstanceMgr.create_instance_state(instance_state_params)

  """
  @spec create_instance_state(Types.instance_state_params()) ::
          {:ok, MsbmsSystEnums.Data.SystEnumItems.t()} | {:error, MsbmsSystError.t()}
  defdelegate create_instance_state(instance_state_params), to: Impl.InstanceStates

  @doc """
  Retrieves the Instance State record associated with the given Instance State
  name.

  ## Parameters

    * `instance_state_name` - the internal name of the Instance State to
    retrieve.

  ## Examples

    iex> {:ok, _instance_state} =
    ...>   MsbmsSystInstanceMgr.get_instance_state_by_name(
    ...>     "instance_states_sysdef_active"
    ...>   )
  """
  @spec get_instance_state_by_name(MsbmsSystEnums.Types.enum_item_name()) ::
          {:ok, MsbmsSystEnums.Data.SystEnumItems.t()} | {:error, MsbmsSystError.t()}
  defdelegate get_instance_state_by_name(instance_state_name), to: Impl.InstanceStates

  @doc """
  Changes the values of an existing Instance State record.

  ## Parameters

    * `instance_state_name` - the internal name of the Instance State to update.

    * `instance_state_params` - A map of field names and their values to use in
    changing the new Instance State.  The available fields are:

      * `internal_name` - identifies a record using a known reference suitable
      for use in programmatic contexts.  Instance States are system enumerations
      and the internal_name must be unique across all enumeration items setup
      in the system.

      * `display_name` - a user visible, but unique, name for the Instance State
      that can be used to distinguish specific Instance States in user
      interfaces.  Because these names are unique, they may be longer than
      desired for some use cases.

      * `external_name` - a name which is used in user interface displays, but
      in contexts where visually apparent uniqueness is less important than
      brevity.

      * `user_description` - a brief description of the Instance State informing
      application users of the purpose and use of the Instance State.

      * `enum_default` - establishes whether or not this Instance State is the
      default Instance State in the system.

      * `functional_type_default` - if true then the new Instance State will be
      the default state for a given functional type.

    > #### Note {: .neutral}
    >
    > Note that the functional type of an Instance State record may not be
    > changed after the record is created.  The reason for this is that any
    > Instance records that may already be in the Instance State being updated
    > would silently assume a new functional type, one that might require some
    > process on entry, etc.

  ## Examples

      iex> changes = %{external_name: "Inactive (Updated)"}
      iex> {:ok, _updated_instance_state} =
      ...>   MsbmsSystInstanceMgr.set_instance_state_values(
      ...>     "instance_states_sysdef_inactive",
      ...>     changes
      ...>   )
  """
  @spec set_instance_state_values(
          MsbmsSystEnums.Types.enum_item_name(),
          Types.instance_state_params()
        ) ::
          {:ok, MsbmsSystEnums.Data.SystEnumItems.t()} | {:error, MsbmsSystError.t()}
  defdelegate set_instance_state_values(instance_state_name, instance_state_params),
    to: Impl.InstanceStates

  @doc """
  Deletes an Instance State as identified by its internal name.

  Note that if the Instance State is still in use by any Instance records an
  error result will be produced.

  ## Parameters

    * `instance_state_name` - the internal name of the Instance State to delete.

  ## Examples

      iex> :ok =
      ...>   MsbmsSystInstanceMgr.delete_instance_state("instance_state_delete_example")
  """
  @spec delete_instance_state(MsbmsSystEnums.Types.enum_item_name()) ::
          :ok | {:error, MsbmsSystError.t()}
  defdelegate delete_instance_state(instance_state_name), to: Impl.InstanceStates

  @doc """
  Returns the Application Context ID for a given Application Context Name.

  ## Parameters

    * `application_context_name` - The internal name value of the desired
    Application Context.

  ## Examples

      iex> _application_context_id =
      ...>    MsbmsSystInstanceMgr.get_application_context_id_by_name("app1_appusr")
  """
  @spec get_application_context_id_by_name(Types.application_context_name()) ::
          Types.application_context_id()
  defdelegate get_application_context_id_by_name(application_context_name),
    to: Impl.ApplicationContexts

  @doc """
  Returns an optionally filtered list of Application Context records.

  If no filtering condition is applied, all known Application Context records
  are returned.

  ## Parameters

    * `opts` - a Keyword List defining optional filters to restrict the result.
    Possible filters are:

      * `application_name` - the internal name of an Application for which to
      return Application Context records.

      * `application_id` - the ID of an Application for which to return
      Application Context records.

      * `start_context` - a boolean value which if true returns only Application
      Context records which are marked as start_context = true; if false, only
      those records marked false are returned.  A nil value is treated as not
      filtering by this attribute.

      * `login_context` - a boolean value which if true returns only Application
      Context records which are designated as login contexts; if this value is
      false, then only those Application Contexts which are not login contexts
      are returned.  A nil value will simply not filter by login_context at all.

  ## Examples

      iex> {:ok, [_ | _]} =
      ...>   MsbmsSystInstanceMgr.get_application_contexts(
      ...>     application_name: "app1", login_context: false
      ...>   )
  """
  @spec get_application_contexts(
          Keyword.t(
            application_name: Types.application_name() | nil,
            application_id: Ecto.UUID.t() | nil,
            start_context: boolean() | nil,
            login_context: boolean() | nil
          )
        ) ::
          {:ok, [Data.SystApplicationContexts.t()]} | {:error, MsbmsSystError.t()}
  defdelegate get_application_contexts(opts \\ []), to: Impl.ApplicationContexts

  @doc """
  Returns an Application Context record as identified by its internal name.

  ## Parameters

    * `application_context_name` - the internal name of the Application Context
    record to return.

  ## Examples

      iex> {:ok, %MsbmsSystInstanceMgr.Data.SystApplicationContexts{}} =
      ...>   MsbmsSystInstanceMgr.get_application_context_by_name("app1_appusr")
  """
  @spec get_application_context_by_name(Types.application_context_name()) ::
          {:ok, Data.SystApplicationContexts.t()} | {:error, MsbmsSystError.t()}
  defdelegate get_application_context_by_name(application_context_name),
    to: Impl.ApplicationContexts

  @doc """
  Returns an Application Context record as identified by its record ID.

  ## Parameters

    * `application_context_id` - the internal name of the Application Context
    record to return.

  ## Examples

      iex> application_context_id =
      ...>    MsbmsSystInstanceMgr.get_application_context_id_by_name("app1_appusr")
      iex> {:ok, %MsbmsSystInstanceMgr.Data.SystApplicationContexts{}} =
      ...>   MsbmsSystInstanceMgr.get_application_context_by_id(application_context_id)
  """
  @spec get_application_context_by_id(Types.application_context_id()) ::
          {:ok, Data.SystApplicationContexts.t()} | {:error, MsbmsSystError.t()}
  defdelegate get_application_context_by_id(application_context_id), to: Impl.ApplicationContexts

  @doc """
  Updates the start_context value of the requested Application Context.

  The only maintainable attribute of an Application Context is the start_context
  value.  When this value is true, the application will start any associated
  Instance Contexts so long as they are not disabled.  Only login contexts are
  allowed to be marked as start_context = true.

  ## Parameters

    * `application_context_id` - the record ID of the Application Context which
    to update.

    * `start_context` - the value to set on the Application Context.  True means
    that any associated Instance Context records will be started at system start
    so long as they haven't been individually disabled.  False will bypass the
    starting of associated Instance Contexts regardless of their individual
    status.
  """
  @spec set_application_context_start_context(Types.application_context_id(), boolean()) ::
          {:ok, Data.SystApplicationContexts.t()}
          | {:error, MsbmsSystError.t()}
  defdelegate set_application_context_start_context(application_context_id, start_context),
    to: Impl.ApplicationContexts

  @doc """
  Retrieves Instance Type Context records.

  The records returned are optionally filtered by identifying a specific
  Instance Type of interest.  The default behavior of the function is to return
  all defined Instance Type Context records.

  ## Parameters

    * `instance_type_name` - the internal name of an Instance Type for which to
    return Instance Type Contexts.

    * `instance_type_id` - the record ID of an Instance Type for which to return
    Instance Type Contexts.

  ## Examples

    iex> {:ok, [_ | _]} =
    ...>   MsbmsSystInstanceMgr.get_instance_type_contexts(
    ...>     instance_type_name: "instance_types_std"
    ...>   )
  """
  @spec get_instance_type_contexts(
          Keyword.t(
            instance_type_name: Types.instance_type_name() | nil,
            instance_type_id: Ecto.UUID.t() | nil
          )
        ) ::
          {:ok, [Data.SystInstanceTypeContexts.t()]} | {:error, MsbmsSystError.t()}
  defdelegate get_instance_type_contexts(opts \\ []), to: Impl.InstanceTypeContexts

  @doc """
  Sets the default database pool size for Instance Type Contexts.

  Instance Type Contexts define a default database connection pool size which is
  then applied to Instance Context records and defines how many database
  connections to open at start time.  Instance Contexts may override this value
  for their own needs, but in the typical case the default defined here for the
  Instance Type Context will be the value used at runtime.

  As of this writing, default database pool size is the only maintainable value
  of the Instance Type Context record.

  ## Parameters

    * `instance_type_context_id` - the record ID of the Instance Type Context
    record to update.

    * `default_db_pool_size` - the default database connection pool size to set
    for associated Instance Context records.
  """
  @spec set_instance_type_context_db_pool_size(
          Types.instance_type_context_id(),
          non_neg_integer()
        ) ::
          {:ok, Data.SystInstanceTypeContexts.t()} | {:error, MsbmsSystError.t()}
  defdelegate set_instance_type_context_db_pool_size(
                instance_type_context_id,
                default_db_pool_size
              ),
              to: Impl.InstanceTypeContexts

  @doc """
  Retrieve an Instance Type Context record by its record ID.

  ## Parameters

    * `instance_type_context_id` - the record ID of the Instance Type Context
    record which to retrieve.

  """
  @spec get_instance_type_context_by_id(Types.instance_type_context_id()) ::
          {:ok, Data.SystApplicationContexts.t()} | {:error, MsbmsSystError.t()}
  defdelegate get_instance_type_context_by_id(instance_type_context_id),
    to: Impl.InstanceTypeContexts
  @doc """
  A list of Instance Context records configured in the system.

  The behavior of this function is to return all configured Instance Context
  records unless one or more of the optional filtering options is provided.

  ## Parameters

    * `opts` - a Keyword list of filter parameters which determine which
    Instance Context records to return.  Available filters are:

      * `instance_id` - The record ID of an Instance record for which to
      retrieve Instance Context records.

      * `instance_name` - the internal name identity of an Instance record for
      which to retrieve Instance Context records.

      * `owner_id` - an Owner record ID for which to retrieve Instance Context
      records.

      * `owner_name` - an Owner record internal name value with which to filter
      the returned Instance Context records.

      * `application_id` - the Application record ID for which to retrieve
      Instance Context records.

      * `application_name` - the internal name of an Application for which to
      return Instance Context records.

      * `start_context` - filters the returned Instance Context record according
      to whether or not they are flagged as start enabled.

      * `database_owner_context` - if true, returns those Instance Context
      records representing database owner contexts; if false, all other Instance
      Context records are returned.

      * `login_context` - if true, returns those Instance Context records which
      are configured as being database login roles.

  ## Examples

  Retrieving an unfiltered list of Instance Context records:

      iex> {:ok, _instance_contexts} = MsbmsSystInstanceMgr.get_instance_contexts()

  Filtering the returned Instance Context list:

      iex> {:ok, _filtered_instance_contexts} =
      ...>   MsbmsSystInstanceMgr.get_instance_contexts(
      ...>     application_name: "app1",
      ...>     start_context: true
      ...>   )

  """
  @spec get_instance_contexts(
          Keyword.t(
            instance_id: Types.instance_id() | nil,
            instance_name: Types.instance_name() | nil,
            owner_id: Types.owner_id() | nil,
            owner_name: Types.owner_name() | nil,
            application_id: Types.application_id() | nil,
            application_name: Types.application_name() | nil,
            start_context: boolean() | nil,
            database_owner_context: boolean() | nil,
            login_context: boolean() | nil
          )
        ) ::
          {:ok, [Data.SystInstanceContexts.t()]} | {:error, MsbmsSystError.t()}
  defdelegate get_instance_contexts(opts \\ []), to: Impl.InstanceContexts

  @spec set_instance_context_values(Types.instance_context_id(), Types.instance_context_params()) ::
          {:ok, Data.SystInstanceContexts.t()} | {:error, MsbmsSystError.t()}
  defdelegate set_instance_context_values(instance_context_id, instance_context_params),
    to: Impl.InstanceContexts
end
