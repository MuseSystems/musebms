defmodule MscmpSystInstance do
  alias MscmpSystInstance.Impl
  alias MscmpSystInstance.Runtime
  alias MscmpSystInstance.Types

  @external_resource "README.md"

  @moduledoc File.read!(Path.join([__DIR__, "..", "README.md"]))

  #
  #  Applications
  #

  @doc section: :application_data
  @doc """
  Returns the Application record ID for the requested Application Internal Name;
  raises on error.

  On successful execution the record ID of the requested Application is
  returned.  If the requested Application Internal Name is not found `nil` is
  returned.

  ## Parameters

    * `applicaton_name` - the internal name of the desired Application record.

  ## Examples

    Finding an application returns its ID value.

      iex> application_id = MscmpSystInstance.get_application_id_by_name("app1")
      iex> is_binary(application_id)
      true

    Asking for a non-existent application returns `nil`.

      iex>  MscmpSystInstance.get_application_id_by_name("nonexistent_application")
      nil
  """
  @spec get_application_id_by_name(Types.application_name()) :: Types.application_id() | nil
  defdelegate get_application_id_by_name(application_name), to: Impl.Application

  #
  #  Instance Types
  #

  @doc section: :instance_type_data
  @doc """
  Creates a new Instance Type record via the `MscmpSystEnums` service.

  ## Parameters

    * `instance_type_params` - the parameters to use when creating the new
    Instance Type.  The attributes `internal_name`, `display_name`,
    `external_name`, `user_description`, and `user_options` fields are required
    for Instance Type creation.
  """
  @spec create_instance_type(Types.instance_type_params()) ::
          {:ok, Msdata.SystEnumItems.t()} | {:error, MscmpSystError.t()}
  defdelegate create_instance_type(instance_type_params), to: Impl.InstanceType

  @doc section: :instance_type_data
  @doc """
  Returns the Instance Type record for the given Internal Name; raises on error.

  On successful execution either the requested Instance Type Enumeration record
  is returned or `nil` if the record does not exist.

  ## Parameters

    * `instance_type_name` - the Internal Name of the desire Instance Type
    record to return.

  ## Examples

  Finding a Instance Type record by Internal Name.

      iex> %Msdata.SystEnumItems{} =
      ...>   MscmpSystInstance.get_instance_type_by_name("instance_types_big")

  Looking for a non-existent record.

      iex> MscmpSystInstance.get_instance_type_by_name("nonexistent_type")
      nil
  """
  @spec get_instance_type_by_name(Types.instance_type_name()) :: Msdata.SystEnumItems.t() | nil
  defdelegate get_instance_type_by_name(instance_type_name), to: Impl.InstanceType

  @doc section: :instance_type_data
  @doc """
  Returns the Instance Type record which is configured as the system default
  Instance Type.

  If no system default has not been defined `nil` is returned.

  ## Examples

      iex> %Msdata.SystEnumItems{} = MscmpSystInstance.get_instance_type_default()
  """
  @spec get_instance_type_default :: Msdata.SystEnumItems.t()
  defdelegate get_instance_type_default, to: Impl.InstanceType

  @doc section: :instance_type_data
  @doc """
  Updates an existing Instance Type record via the `MscmpSystEnums` service.

  ## Parameters

    * `instance_type_name` - the internal name of the Instance Type to target
    for updating.

    * `instance_type_params` - the parameters to use when creating the new
    Instance Type.  All attributes in the parameter map are optional in updating
    contexts.
  """
  @spec update_instance_type(Types.instance_type_name(), Types.instance_type_params() | %{}) ::
          {:ok, Msdata.SystEnumItems.t()} | {:error, MscmpSystError.t()}
  defdelegate update_instance_type(instance_type_name, instance_type_params \\ %{}),
    to: Impl.InstanceType

  @doc section: :instance_type_data
  @doc """
  Deletes an Instance Type from the `MscmpSystEnums` service.

  Note that an attempt to delete an in-use Instance Type will result in a
  constraint error.

  ## Parameters

    * `instance_type_name` - the internal name of an Instance Type to delete
    from the system.
  """
  @spec delete_instance_type(Types.instance_type_name()) ::
          :ok | {:error, MscmpSystError.t()}
  defdelegate delete_instance_type(instance_type_name), to: Impl.InstanceType

  #
  # Instance Type Applications
  #

  @doc section: :instance_type_data
  @doc """
  Creates an Instance Type/Application association.

  Associating an Instance Type with an Application expresses that the Instance
  Type can support Instances of the given application.

  ## Parameters

    * `instance_type_id` - the ID value of the Instance Type which will support
    Application Instances.

    * `application_id` - the ID value which identifies the Application to be
    supported.
  """
  @spec create_instance_type_application(
          Types.instance_type_id(),
          Types.application_id()
        ) :: {:ok, Msdata.SystInstanceTypeApplications.t()} | {:error, MscmpSystError.t()}
  defdelegate create_instance_type_application(instance_type_id, application_id),
    to: Impl.InstanceTypeApplication

  @doc section: :instance_type_data
  @doc """
  Disassociates the Instance Type/Application support relationship.

  Note that this will only prevent the creation of new Instances of the Instance
  Type for the Application.  Existing Instances that were created when the
  relationship was valid will continue to exist.

  ## Parameters

    * `instance_type_application` - This value can be either the ID value of the
    Instance Type Application record or a
    `Msdata.SystInstanceTypeApplications` struct with at
    least the `id` field defined.
  """
  @spec delete_instance_type_application(
          Types.instance_type_application_id()
          | Msdata.SystInstanceTypeApplications.t()
        ) ::
          :ok | {:error, MscmpSystError.t()}
  defdelegate delete_instance_type_application(instance_type_application),
    to: Impl.InstanceTypeApplication

  #
  # Instance Type Contexts
  #

  @doc section: :instance_type_data
  @doc """
  Updates Instance Type Context default values which are applied to new Instance
  Contexts.

  ## Parameters

    * `instance_type_context` - this value may either be the record ID of the
    target Instance Type Context record or a copy of the current
    `Msdata.SystInstanceTypeContexts` struct representing the
    target record.

    * `instance_type_context_params` - a map containing those attributes to be
    updated with their new values.

      * `instance_type_id` - the ID value of the owning Instance Type record.
      This value is required unless the `instance_type_name` attribute is
      provided.

      * `instance_type_name` - the internal name value of the owning Instance
      Type record.  This value required unless the `instance_type_id` value is
      provided instead.

      * `application_context_id` - the record ID value of the Application
      Context with which this record is associated.  This value is required
      unless the `application_context_name` value is provided instead.

      * `application_context_name` -  the internal name value of the Application
      Context with which this record is associated.  This value is required
      unless the `application_context_id` value is provided instead.

      * `default_db_pool_size` - the default size of the database connection
      pool to use for Instances Contexts created for Instances of this Instance
      Type.  This field defaults to 0 on Instance Type Context creation.
  """
  @spec update_instance_type_context(
          Types.instance_type_context_id()
          | Msdata.SystInstanceTypeContexts.t(),
          Types.instance_type_context_params() | %{}
        ) :: {:ok, Msdata.SystInstanceTypeContexts.t()} | {:error, MscmpSystError.t()}
  defdelegate update_instance_type_context(
                instance_type_context,
                instance_type_context_params \\ %{}
              ),
              to: Impl.InstanceTypeContext

  #
  # Owners
  #

  @doc section: :owner_data
  @doc """
  Returns the Owner State Enumeration record for the given Internal Name argument.

  If the requested Internal Name does not match an existing Owner State
  Enumeration record `nil` is returned.

  ## Parameters

    * `owner_state_name` - the internal name of the Owner State to retrieve.

  ## Examples

  Retrieving an Owner State Enumeration record.

      iex> %Msdata.SystEnumItems{internal_name: "owner_states_sysdef_active"} =
      ...>   MscmpSystInstance.get_owner_state_by_name("owner_states_sysdef_active")

  Trying to retrieve a non-existent Owner State.

      iex> MscmpSystInstance.get_owner_state_by_name("nonexistent_state")
      nil
  """
  @spec get_owner_state_by_name(MscmpSystEnums.Types.enum_item_name()) ::
          Msdata.SystEnumItems.t() | nil
  defdelegate get_owner_state_by_name(owner_state_name), to: Impl.Owner

  @doc section: :owner_data
  @doc """
  Returns the Owner State Enumeration record which is configured as being
  default.

  If no Owner State record is configured as default, then `nil` is returned.

  ## Parameters

    * `functional_type` - an optional parameter which, if provided and not
    `nil`, will return the default Owner State record configured for the
    requested functional type rather than the system default Owner State.  The
    default for this parameter is to treat the parameter as not provided
    (`nil`).

  ## Examples

  Requesting the system default Owner State.

      iex> %Msdata.SystEnumItems{internal_name: "owner_states_sysdef_active"} =
      ...>   MscmpSystInstance.get_owner_state_default()

  Requesting the default Owner State for a specific functional type.

      iex> %Msdata.SystEnumItems{internal_name: "owner_states_sysdef_inactive"} =
      ...>   MscmpSystInstance.get_owner_state_default(:owner_states_inactive)
  """
  @spec get_owner_state_default(Types.owner_state_functional_types() | nil) ::
          Msdata.SystEnumItems.t()
  defdelegate get_owner_state_default(functional_type \\ nil), to: Impl.Owner

  @doc section: :owner_data
  @doc """
  Creates a new Owner record.

  ## Parameters

    * `owner_params` - a map of Owner record attributes to use when creating a
    new record.

      * `internal_name` - a predetermined unique identifier for the Owner
      record for use in programmatic contexts.  This attribute is required and
      must be unique in the system.

      * `display_name` - a unique, friendly name identifying the owner and for
      use in user interfaces.  This attribute is required and must be unique in
      the system.

      * `owner_state_id` - the Owner State value with which to create the new
      Owner record.  If not provided in the function call, this attribute will
      be defaulted to the configured Owner State default value for the
      enumeration.

  """
  @spec create_owner(Types.owner_params()) ::
          {:ok, Msdata.SystOwners.t()} | {:error, MscmpSystError.t()}
  defdelegate create_owner(owner_params), to: Impl.Owner

  @doc section: :owner_data
  @doc """
  Updates an Owner record.

  ## Parameters

    * `owner` - This value must either by the record ID of an existing Owner
    record or the `Msdata.SystOwners` struct representing an
    existing owner.

    * `update_params` - a map of Owner record attributes to be updated.  For
    update operations only those attributes to be updates must be provided.

      * `internal_name` - a predetermined unique identifier for the Owner
      record for use in programmatic contexts.  This attribute must be unique in
      the system and may not be nil.

      * `display_name` - a unique, friendly name identifying the owner and for
      use in user interfaces.  This attribute must be unique in the system and
      may not be nil.

      * `owner_state_id` - the record ID value of the new Owner State of the
      Owner record.  Note that if this attribute is provided, but is set nil,
      an error will result.
  """
  @spec update_owner(Types.owner_id() | Msdata.SystOwners.t(), Types.owner_params()) ::
          {:ok, Msdata.SystOwners.t()} | {:error, MscmpSystError.t()}
  defdelegate update_owner(owner, update_params), to: Impl.Owner

  @doc section: :owner_data
  @doc """
  Retrieves an Owner record by its internal name.

  This retrieval operation will also populate the associated records of Owner
  State and the Owner State Functional Type.

  ## Examples

    iex> {:ok, %Msdata.SystOwners{internal_name: "owner1"}} =
    ...>   MscmpSystInstance.get_owner_by_name("owner1")
  """
  @spec get_owner_by_name(Types.owner_name()) ::
          {:ok, Msdata.SystOwners.t()} | {:error, MscmpSystError.t()}
  defdelegate get_owner_by_name(owner_name), to: Impl.Owner

  @doc section: :owner_data
  @doc """
  Retrieves the Owner record ID by Owner internal name.

  ## Examples

    iex> {:ok, owner_id} = MscmpSystInstance.get_owner_id_by_name("owner1")
    iex> is_binary(owner_id)
    true
  """
  @spec get_owner_id_by_name(Types.owner_name()) ::
          {:ok, Types.owner_id()} | {:error, MscmpSystError.t()}
  defdelegate get_owner_id_by_name(owner_name), to: Impl.Owner

  @doc section: :owner_data
  @doc """
  Removes an Owner record from the system.

  Note that only Owner records in an Owner State of functional type
  `owner_states_purge_eligible` may be purged from the system.

  ## Parameters

    * `owner` - either the record ID of an Owner record to delete or the
    `Msdata.SystOwners` struct representing the Owner to
    purge.
  """
  @spec purge_owner(Types.owner_id() | Msdata.SystOwners.t()) ::
          :ok | {:error, MscmpSystError.t()}
  defdelegate purge_owner(owner), to: Impl.Owner

  #
  # Instances
  #

  @doc section: :instance_data
  @doc """
  Retrieves the Instance State Enumeration record identified by the provided
  Internal Name.

  If the requested Internal Name does not match an existing Instance State
  Enumeration record `nil` is returned.

  ## Parameters

    * `instance_state_name` - the internal name of the Instance State to retrieve.

  ## Examples

  Retrieving an Instance State Enumeration record.

      iex> %Msdata.SystEnumItems{internal_name: "instance_states_sysdef_active"} =
      ...>   MscmpSystInstance.get_instance_state_by_name("instance_states_sysdef_active")

  Trying to retrieve a non-existent Instance State.

      iex> MscmpSystInstance.get_instance_state_by_name("nonexistent_state")
      nil
  """
  @spec get_instance_state_by_name(Types.instance_state_name()) :: Msdata.SystEnumItems.t() | nil
  defdelegate get_instance_state_by_name(instance_state_name), to: Impl.InstanceState

  @doc section: :instance_data
  @doc """
  Returns the Instance State Enumeration record which is configured as being
  default.

  If no Instance State record is configured as default, then `nil` is returned.

  ## Parameters

    * `functional_type` - an optional parameter which, if provided and not
    `nil`, will return the default Instance State record configured for the
    requested functional type rather than the system default Instance State.
    The default for this parameter is to treat the parameter as not provided
    (`nil`).

  ## Examples

  Requesting the system default Instance State.

      iex> %Msdata.SystEnumItems{internal_name: "instance_states_sysdef_uninitialized"} =
      ...>   MscmpSystInstance.get_instance_state_default()

  Requesting the default Instance State for a specific functional type.

      iex> %Msdata.SystEnumItems{internal_name: "instance_states_sysdef_active"} =
      ...>   MscmpSystInstance.get_instance_state_default(:instance_states_active)
  """
  @spec get_instance_state_default(Types.instance_state_functional_types() | nil) ::
          Msdata.SystEnumItems.t()
  defdelegate get_instance_state_default(functional_type \\ nil), to: Impl.InstanceState

  @doc section: :instance_data
  @doc """
  Creates a new Instance record.

  Creating a new Instance record will also create new Instance Context records
  based on the defaults defined in the Instance Type Context records associated
  with the Instance Type and Application of the new Instance.  This is
  accomplished with database triggers.

  ## Parameters

    * `instance_params` - A map of attributes to use in creating the new
    Instance record in the system.

      * `internal_name` - a pre-generated identifier for Instance record for use
      in programmatic contexts.  This value is required and must be unique in
      the system.

      * `display_name` - a friendly name which identifies the record for use in
      user interfaces.  This value is required and must be unique in the system.

      * `dbserver_name` - the name of the database server where the Instance
      Datastore exists.  This value is required.  Note that invalid values here
      may not be detected until such time as the Instance Datastore use is
      attempted.

      * `application_id` - the record ID of the Application for which this
      Instance is being created.  This value is required unless the
      `application_name` attribute has been provided instead.

      * `application_name` - the internal name of the Application for which this
      Instance is being created.  This value is requires unless the
      `application_id` attribute has been provided instead.

      * `instance_code` - A value used in constructing the Instance Context
      credentials.  This value should be a randomly generated series of between
      8 and 64 bytes.

      * `instance_type_id` - the record ID of the Instance Type of the new
      Instance record.  This attribute is required unless the
      `instance_type_name` attribute is provided instead.

      * `instance_type_name` - the internal name of the Instance Type of the new
      Instance record.  This attribute is requires unless the `instance_type_id`
      attribute is provided instead.

      * `instance_state_id` - the record ID of the Instance State in which to
      create the new Instance record.  This value may be omitted and allowed to
      default based on the configured default Instance State.  Optionally the
      Instance State may also be identified by the `instance_state_name`
      attribute.

      * `instance_state_name` - the internal name of the Instance State in which
      to create the new Instance record.  This value may be omitted and allowed
      to default based on the configured default Instance State.  Optionally the
      Instance State may also be identified by the `instance_state_id`
      attribute.

      * `owner_id` - the record ID of the Owner of the Instance.  This
      attribute is required unless the `owner_name` attribute is provided.

      * `owner_name` - th internal name of the Owner of the Instance.  This
      attribute is required unless the `owner_id` attribute is provided.

      * `owning_instance_id` - if the Instance is associated with a parent
      instance, such as a sandbox Instance being created for a parent production
      Instance, the parent/child relationship may be expressed by assigning this
      attribute to the record ID of the parent.  This attribute is not required
      and the parent Instance may be identified by the `owning_instance_name`
      attribute instead.

      * `owning_instance_name` - an alternate identification method for
      identifying a parent Instance when creating a child Instance.  This
      attribute is optional and may used in lieu of using the
      `owning_instance_id` attribute to establish the parent/child relationship
      of the new Instance.

  """
  @spec create_instance(Types.instance_params()) ::
          {:ok, Msdata.SystInstances.t()} | {:error, MscmpSystError.t()}
  defdelegate create_instance(instance_params), to: Impl.Instance

  @doc section: :instance_data
  @doc """
  Retrieves the Datastore Options based on the Instance database record and the
  provided Startup Options.

  ## Parameters

    * `instance` - the instance parameter is either the record ID value of the
    Instance record desired or the `Msdata.SystInstances`
    struct for the target Instance.

    * `startup_options` - a map of values containing the Startup Options
    obtained from the `MscmpSystOptions` component.
  """
  @spec get_instance_datastore_options(Types.instance_id() | Msdata.SystInstances.t(), map()) ::
          MscmpSystDb.Types.datastore_options()
  defdelegate get_instance_datastore_options(instance, startup_options), to: Impl.Instance

  @doc section: :instance_data
  @doc """
  Initializes an uninitialized Instance.

  When a new Instance is created in the database, the record is giving an
  Instance State with a functional type of `instance_states_uninitialized`
  meaning that the Instance record has been created in the database, but the
  Instance's own database and associated database roles have not yet been set
  up.

  Initializing an Instance creates its database and its database roles
  ("Datastore" and "Datastore Contexts"). Once initialized, the Instance record
  is given an Instance State of functional type `instance_states_initialized`.

  Initialized Instances may be started and have their Datastores migrated to the
  current version of the Instance's database.

  ## Parameters

    * `instance_id` - the record ID of the Instance to initialize.

    * `startup_options` - a map of values containing the Startup Options
    obtained from the `MscmpSystOptions` component.

    * `opts` - a Keyword List of optional values used during the initialization
    process.  The available options include:

      * `initializing_state_id` - the record ID value of the Instance State to
      use to indicate that the record is being initialized.  If this value is
      not provided the configured default Instance State for the functional type
      `instance_states_initializing` will be used.

      * `initialized_state_id` - the record ID value of the Instance State to
      use to indicate that the record has successfully been initialized.  If
      this value is not provided the configured default Instance State for the
      functional type `instance_states_initialized` will be used.

      * `failed_state_id` - the record ID value of the Instance State to
      use to indicate that the record has failed to be initialized.  If this
      value is not provided the default configured Instance State for the
      functional type `instance_states_failure` will be used.

      * `db_shutdown_timeout` - a timeout value used to limit the time allowed
      for a clean shutdown of the DBA and Privileged database connections used
      for initialization of the Datastore.  See the documentation for
      `MscmpSystDb.create_datastore/2` for more information.
  """
  @spec initialize_instance(Types.instance_id(), map(), Keyword.t()) ::
          {:ok, Msdata.SystInstances.t()} | {:error, MscmpSystError.t()}
  defdelegate initialize_instance(instance_id, startup_options, opts \\ []), to: Impl.Instance

  @doc section: :instance_data
  @doc """
  Sets the Instance State of an Instance.

  ## Parameters

    * `instance` - the current `Msdata.SystInstances` struct
    representing the Instance to be updated.

    * `instance_state_id` - The record ID of the new Instance State value into
    which to place the Instance record.
  """
  @spec set_instance_state(Msdata.SystInstances.t(), Types.instance_state_id()) ::
          {:ok, Msdata.SystInstances.t()} | {:error, MscmpSystError.t()}
  defdelegate set_instance_state(instance, instance_state_id), to: Impl.Instance

  @doc section: :instance_data
  @doc """
  Returns a Keyword List of the default values for each Instance State's
  functional type.

  Instance updating functions that change the Instance State value of the
  Instance will default to the appropriate Instance State if a specific Instance
  State value is not provided by the caller.
  """
  @spec get_default_instance_state_ids() :: Keyword.t()
  defdelegate get_default_instance_state_ids, to: Impl.Instance

  @doc section: :instance_data
  @doc """
  Returns the SystInstances record identified by its internal name.

  ## Parameters

    * `instance_name` - the internal name of the Instance record to return.

  ## Example

      iex> {:ok, %Msdata.SystInstances{}} =
      ...>   MscmpSystInstance.get_instance_by_name("app1_owner1_instance_types_sml")
  """
  @spec get_instance_by_name(Types.instance_name()) ::
          {:ok, Msdata.SystInstances.t()} | {:error, MscmpSystError.t()}
  defdelegate get_instance_by_name(instance_name), to: Impl.Instance

  @doc section: :instance_data
  @doc """
  Returns the ID of the Instance record as identified by its internal name.

  ## Parameters

    * `instance_name` - the internal name of the Instance record to reference.

  ## Example

      iex> {:ok, instance_id} =
      ...>   MscmpSystInstance.get_instance_id_by_name("app1_owner1_instance_types_sml")
      iex> is_binary(instance_id)
      true
  """
  @spec get_instance_id_by_name(Types.instance_name()) ::
          {:ok, Types.instance_id()} | {:error, MscmpSystError.t()}
  defdelegate get_instance_id_by_name(instance_name), to: Impl.Instance

  @doc section: :instance_data
  @doc """
  Purges an eligible Instance from the system.

  Purging an Instance drops its associated Datastore and its defining
  `Msdata.SystInstances` records from the database.

  In order for the purge to be successful, the Instance must be in an Instance
  State of functional type `instance_states_purge_eligible`.

  > #### Warning {: .warning}
  > Naturally, great care must be taken in the lead up to calling this function
  > as purging an Instance leads to the irreversible loss of the Instance's data
  > (absent externally managed backups of some sort).

  ## Parameters

    * `instance` - either the record ID or the
    `Msdata.SystInstances` struct of the Instance to purge.

    * `startup_options` - a map of values containing the Startup Options
    obtained from the `MscmpSystOptions` component.
  """
  @spec purge_instance(Types.instance_id() | Msdata.SystInstances.t(), map()) ::
          :ok | {:error, MscmpSystError.t()}
  defdelegate purge_instance(instance, startup_options), to: Impl.Instance

  #
  # Service Management
  #

  @doc section: :service_management
  @doc """
  Starts the MscmpSystInstance services and supervisors.

  In an application context, MscmpSystInstances sets up a supervisory tree and
  a process registry so that Application and Instance supervisors may be found
  for later use.  At the top level, an Application Supervisor for each known
  Application is created and below that are Instance Supervisors for each
  Instance of the Application.  Finally, child services such as processes for
  Datastores and other processes and supervisors as appropriate and specific to
  a given Instance are started under each Instance Supervisor.

  This function allows the client application to link the MscmpSystInstance
  services to where it wishes within its own supervision tree using the normal
  `Supervisor` and `DynamicSupervisor` calls for starting children.

  ## Parameters:

    * `opts` - A Keyword List of optional settings which override the
    established default values.  The available options are:

      * `supervisor_name` - the name of the MscmpSystInstance root Supervisor to
      which other MscmpSystInstance processes and supervisors are bound.  The
      default value is `MscmpSystInstance.Supervisor`.

      * `registry_name` - the name of the Registry service used to resolve the
      supervisors dynamically created by MscmpSystInstance. The default value
      is `MscmpSystInstance.Registry`.

      * `instance_supervisor_name` - the name of the supervisor to which all
      individual, dynamically created instance supervisors are children.  The
      default value is `MscmpSystInstance.InstanceSupervisor`.

      * `task_supervisor_name` - on Instance startup, MscmpSystInstance will
      process Instance Datastore startup and migration application via
      concurrently `Task` processes.  This option establishes the name of the
      supervisor under which these `Task` processes are started.  The default
      value is `MscmpSystInstance.TaskSupervisor`.
  """
  @spec start_link(Keyword.t()) :: Supervisor.on_start_child()
  defdelegate start_link(opts \\ []), to: Runtime.Services

  @doc section: :service_management
  @doc """
  Starts all Applications and each Application's child Instances.

  This function calls the `start_application/3` function for each Application
  configured in the system.  See the documentation for `start_application/3`
  for more information about this function and the available parameters.
  """
  @spec start_all_applications(map(), Keyword.t()) :: :ok | {:error, MscmpSystError.t()}
  defdelegate start_all_applications(startup_options, opts \\ []), to: Runtime.Services

  @doc section: :service_management
  @doc """
  Starts the requested Application and its child Instances.

  For the requested Application, start a DynamicSupervisor under which to
  supervise all of the services related to that Application including its child
  Instances.

  Once the Application supervisor is started any child Instances which are in a
  start-eligible status are started under the Application supervisor.  The
  Instance startup process starts each Instance asynchronously and concurrently.
  The instance startup process will also upgrade each Instance datastore to the
  current version of the application, if required.  As such, you should be
  prepared for Application startup to be long running.

  ## Parameters

    * `application` - either the record ID or the
    `Msdata.SystApplications` struct representing the
    Application to start.

    * `startup_options` - a map of values containing the Startup Options
    obtained from the `MscmpSystOptions` component.

    * `opts` - a Keyword List of optional values used during the initialization
    process.  The available options include:

      * `max_concurrency` - the maximum number of Instances to start
      concurrently.  This defaults to the greater of 1 or one quarter of the
      value returned by `System.schedulers_online/0` floored.

      * other available options are passed to `start_instance/3`.  See the
      documentation for `start_instance/3` for the options it is able to accept.

      * `registry_name` - the name of the Registry service used to resolve the
      supervisors dynamically created by MscmpSystInstance. The default value
      is `MscmpSystInstance.Registry`.

      * `instance_supervisor_name` - the name of the supervisor to which all
      individual, dynamically created instance supervisors are children.  The
      default value is `MscmpSystInstance.InstanceSupervisor`.

      * `task_supervisor_name` - on Instance startup, MscmpSystInstance will
      process Instance Datastore startup and migration application via
      concurrently `Task` processes.  This option establishes the name of the
      supervisor under which these `Task` processes are started.  The default
      value is `MscmpSystInstance.TaskSupervisor`.
  """
  @spec start_application(
          Types.application_id() | Msdata.SystApplications.t(),
          map(),
          Keyword.t()
        ) ::
          :ok | {:error, MscmpSystError.t()}
  defdelegate start_application(application, startup_options, opts \\ []), to: Runtime.Services

  @doc section: :service_management
  @doc """
  Stops all Applications, Application Supervisors, and their child Instances.

  This function will call `stop_application/2` for each Application configured
  in the system.  For more information about the available options and behaviors
  of Application shutdown, please see the documentation for
  `stop_application/2`.
  """
  @spec stop_all_applications(Keyword.t()) :: :ok | {:error, MscmpSystError.t()}
  defdelegate stop_all_applications(opts \\ []), to: Runtime.Services

  @doc section: :service_management
  @doc """
  Shuts down the Supervisor process of the requested Application and all of its
  child processes, including Instances.

  ## Parameters

    * `application` - either the record ID or the
    `Msdata.SystApplications` struct representing the
    Application to stop.

    * `opts` - a Keyword List of optional values used during the initialization
    process.  The available options include:

      * `supervisor_shutdown_timeout` - a timeout value used to allow processes
      supervised by the Application supervisor to shut down cleanly.  By
      default, this value is set to 60,000ms.

      * Other options available are defined by and passed to the
      `stop_instance/2` function for Instance shutdown.  See the
      `stop_instance/2` for full information of the available options.
  """
  @spec stop_application(Types.application_id() | Msdata.SystApplications.t(), Keyword.t()) ::
          :ok | {:error, MscmpSystError.t()}
  defdelegate stop_application(application, opts \\ []), to: Runtime.Services

  @doc section: :service_management
  @doc """
  Starts an Instance and places it under the appropriate Application's
  supervisor.

  An Instance is essentially a tenant environment running a specific
  Application.  Each environment's runtime characteristics are independent of
  other environments configured to run in the same system.

  To be started the Instance must be in an Instance State of either functional
  type `instance_states_initialized` or `instance_states_active`.  Trying to
  start an Instance in other Instance States will result in an error.

  Note that we assume that the Application supervisor is already started and is
  ready to start child processes.

  ## Parameters

    * `instance` - either the record ID or the
    `Msdata.SystInstances` struct of the Instance to start.

    * `startup_options` - a map of values containing the Startup Options
    obtained from the `MscmpSystOptions` component.

    * `opts` - a Keyword List of optional values used during the initialization
    process.  The available options include:

      * `migrating_state_id` - the record ID of the Instance State to use while
      the starting Instance is being updated to the most current database
      definition of the application.  If not provided the currently configured
      default Instance State for functional type `instance_states_migrating`
      will be used.

      * `active_state_id` - the record ID of the Instance State to use
      indicating that the Instance is ready to accept user workloads.  If not
      provided the currently configured default Instance State for functional
      type `instance_states_active` will be used.

      * `failure_state_id` - the record ID of the Instance State to use
      indicating that the Instance startup process has failed and that the
      Instance is in an inconsistent state.  If not provided the currently
      configured default Instance State for functional type
      `instance_states_failure` will be used.

      * `migration_bindings` - this a Keyword List containing values that will
      be substituted into the migration SQL files used to update a Datastore
      to the current version of the Application.  Usually, there is no need to
      provide this option as the most common migration bindings are
      automatically generated from Instance record data.

      * `registry_name` - the name of the Registry service used to resolve the
      supervisors dynamically created by MscmpSystInstance. The default value
      is `MscmpSystInstance.Registry`.

      * `instance_supervisor_name` - the name of the supervisor to which all
      individual, dynamically created instance supervisors are children.  The
      default value is `MscmpSystInstance.InstanceSupervisor`.
  """
  @spec start_instance(Types.instance_id() | Msdata.SystInstances.t(), map(), Keyword.t()) ::
          :ok | {:error, MscmpSystError.t()}
  defdelegate start_instance(instance, startup_options, opts \\ []), to: Runtime.Services

  @doc section: :service_management
  @doc """
  Stops an Instance.

  Stopping an Instance shuts down its supervisor and any monitored processes.

  ## Parameters

    * `instance` - either the record ID or the
    `Msdata.SystInstances` struct of the Instance to stop.

    * `opts` - a Keyword List of optional values used during the initialization
    process.  The available options include:

      * `supervisor_shutdown_timeout` - a timeout value used to allow processes
      supervised by the Instance supervisor to shut down cleanly.  By default,
      this value is set to 60,000ms.

      * `db_shutdown_timeout` - a timeout value used to limit the time allowed
      for a clean shutdown of the database connections used for operating
      Datastore.  See the documentation for
      `MscmpSystDb.stop_datastore/2` for more information.

      * `registry_name` - the name of the Registry service used to resolve the
      supervisors dynamically created by MscmpSystInstance. The default value
      is `MscmpSystInstance.Registry`.
  """
  @spec stop_instance(Types.instance_id() | Msdata.SystInstances.t(), Keyword.t()) ::
          :ok | {:error, MscmpSystError.t()}
  defdelegate stop_instance(instance, opts \\ []), to: Runtime.Services
end
