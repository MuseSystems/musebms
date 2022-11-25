defmodule MscmpSystInstance do
  alias MscmpSystInstance.Impl
  alias MscmpSystInstance.Runtime
  alias MscmpSystInstance.Types

  @moduledoc """
  API allowing for the management of application Instances.

  "Instances" are instances of running application environments.  Instances are
  established to host the application for different purposes, such as for
  running the application for production, training, and testing purposes; or as
  a means to implement multi-tenancy where each tenant application environment
  is an Instance.

  Each Instance also requires supporting data in order to facilitate runtime
  actions, such as defining database roles with which to access database data.
  Such supporting information is also managed via this component.

  ## Concepts

  Instances are organized into a framework of other data types which allows us
  to better analyze and manage them and provides supplemental information
  required for Instance operation.

  #### Datastores & Datastore Contexts

  Each Instance is associated with a single Datastore.  A Datastore is the
  database created to store the Instance's application data.  Datastore Contexts
  are the database roles with which the Instance will access the database; this
  allows for application database connections secured to an appropriate range
  of actions and limited to an appropriate number of concurrent database
  connections.  Or to put it another way, Datastore Contexts can be thought of
  as "Database Access Contexts".

  Datastore and Datastore Context management is provided by the
  `MscmpSystDb` component.

  #### Owners

  Owners represent the known tenants of the system.  An Owner will own Instances
  of Applications.  Owners have states which determine if they are active, not
  active, or even if they may be purged from the system.

  #### Applications

  Each Instance is an operational instance of a specific Application.  An
  Application is simply what an end user would understand to be application:
  computer software which solves some problem for them better than could be
  solved without such software.

  Applications in this component are added and maintained directly via database
  migrations therefore there is no API provided to manage applications and there
  are no user maintainable Application attributes.

  #### Application Contexts

  Application Context records define the expected Datastore Context records that
  must be created for each Instance.  Each Application Context will be
  represent data ownership, data access restriction, and/or connection pool
  resource constraint.  When created Instances will have its own database roles
  created for each of the defined Application Contexts.

  #### Instance Types

  Instance Type records are used to define the default resource utilization
  classes that are available for creating new Instances.  These defaults include
  such starting values as the number of database connections to use for each
  Application Context and which server pools may host the Instance.

  After Instance creation, the Instance Type serves no further role for the
  Instance.

  Note that Instance Type records are a special case of the
  `Msdata.SystEnumItems` record.  The Enum Name for Instance Type
  is, unsurprisingly, `instance_types`.

  #### Instance Type Applications

  Establishes that a given Instance Type will support a particular Application.

  #### Instance Type Contexts

  Defines defaults used in creating Instance Context records at Instance
  creation time.

  When an association is made between an Instance Type and an Application via
  a Instance Type Application association, a new Instance Type Context record is
  created for the combination of the Instance Type and each of the Application's
  defined Application Contexts.

  At Instance creation time, the Instance Type Context defaults are copied
  into Instance specific Instance Context records to define the actual database
  roles which the instance will use to interact with the database.

  Note that Instance Type Context records are automatically created and
  destroyed via the creation of Instance Type Application records by way of
  database triggers; therefore the only application API related to these
  records is for updating them.

  #### Instances

  An Instance represents the single environment of a specific Application and a
  specific Owner.  Instance records are used to know which database server to
  connect to, what Instance Context records are used for connecting to the
  database, and the current state of the Instance including whether or not it's
  been updated with the Application database definition, is in a usable state,
  or can be purged from the system.

  #### Instance Contexts

  An Instance's Instance Context records define specifically how an Instance
  will connect to its Datastore including such information as how many
  connections should be opened to the database.

  Database triggers are responsible for creating and destroying Instance Context
  records.  On creation, the Instance Context is created with default values
  defined by Instance Type Context records for the type of Instance being
  created.  The default values set on Instance Context creation may be
  overridden via this API as desired.

  ## Special Notes

  This component requires that an instance of the `MscmpSystEnums` service has
  been configured and started.  Many of the API calls in this component will
  fail if the `MscmpSystEnums` services are not available.

  """

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
  Starts all Applications and each Application's child Instances.

  This function calls the `start_application/3` function for each Application
  configured in the system.  See the documentation for `start_application/3`
  for more information about this function and the available parameters.
  """
  @spec start_all_applications(map(), Keyword.t()) :: :ok | {:error, MscmpSystError.t()}
  defdelegate start_all_applications(startup_options, opts \\ []), to: Runtime.Application

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
  """
  @spec start_application(
          Types.application_id() | Msdata.SystApplications.t(),
          map(),
          Keyword.t()
        ) ::
          :ok | {:error, MscmpSystError.t()}
  defdelegate start_application(application, startup_options, opts \\ []), to: Runtime.Application

  @doc section: :service_management
  @doc """
  Stops all Applications, Application Supervisors, and their child Instances.

  This function will call `stop_application/2` for each Application configured
  in the system.  For more information about the available options and behaviors
  of Application shutdown, please see the documentation for
  `stop_application/2`.
  """
  @spec stop_all_applications(Keyword.t()) :: :ok | {:error, MscmpSystError.t()}
  defdelegate stop_all_applications(opts \\ []), to: Runtime.Application

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
  defdelegate stop_application(application, opts \\ []), to: Runtime.Application

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
  """
  @spec start_instance(Types.instance_id() | Msdata.SystInstances.t(), map(), Keyword.t()) ::
          :ok | {:error, MscmpSystError.t()}
  defdelegate start_instance(instance, startup_options, opts \\ []), to: Runtime.Application

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
  """
  @spec stop_instance(Types.instance_id() | Msdata.SystInstances.t(), Keyword.t()) ::
          :ok | {:error, MscmpSystError.t()}
  defdelegate stop_instance(instance, opts \\ []), to: Runtime.Application
end
