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
      ...>   MsbmsSystInstanceMgr.get_owner_by_name("owner_1")
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

      iex> {:ok, _instance_type} =
      ...>   MsbmsSystInstanceMgr.get_instance_by_name("test_instance_2")
  """
  @spec get_instance_by_name(Types.instance_name()) ::
          {:ok, Data.SystInstances.t()} | {:error, MsbmsSystError.t()}
  defdelegate get_instance_by_name(instance_name), to: Impl.Instances

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
      ...>   user_options: %{
      ...>     datastore_contexts: [
      ...>       %{
      ...>         id: :test_datastore_context_1,
      ...>         db_pool_size: 3
      ...>       },
      ...>       %{
      ...>         id: :test_datastore_context_1,
      ...>         db_pool_size: 3
      ...>       }
      ...>     ]
      ...>   }
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
      ...>   MsbmsSystInstanceMgr.get_instance_type_by_name("instance_types_big_instance")
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
      ...>     "instance_types_sml_instance",
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
  @spec set_instance_state_values(MsbmsSystEnums.Types.enum_item_name(), Types.instance_state()) ::
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
end
