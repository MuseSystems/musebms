# Source File: mscmp_syst_db.ex
# Location:    musebms/app_server/components/system/mscmp_syst_db/lib/api/mscmp_syst_db.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystDb do
  @external_resource "README.md"
  @moduledoc Path.join([__DIR__, "..", "..", "README.md"])
             |> File.read!()
             |> String.split("<!-- MDOC !-->")
             |> Enum.fetch!(1)

  alias MscmpSystDb.Impl.Dba
  alias MscmpSystDb.Impl.Privileged
  alias MscmpSystDb.Runtime.Datastore
  alias MscmpSystDb.Types
  alias MscmpSystDb.Types.{ContextState, DatastoreContext, DatastoreOptions}

  ##############################################################################
  #
  # Options Definition
  #
  #

  option_defs = [
    db_shutdown_timeout: [
      type: :timeout,
      default: 60_000,
      doc: """
      The timeout in milliseconds to wait for the database to shutdown prior to
      raising an error.
      """
    ],
    context_registry: [
      type: {:or, [{:in, [:global]}, :atom]},
      type_doc: "`:global` or `t:module/0`",
      doc: """
      Identifies a process registry which is used to register Datastore
      Context (`Ecto.Repo`) instances. A valid value for this option can be
      either `:global` to use the Erlang `:global` module or any other module
      which implements a :global compatible API.
      """
    ],
    migrations_schema: [
      type: :string,
      default: "ms_syst_db",
      doc: """
      The database maintenance schema used to host the migrations state table.
      """
    ],
    migrations_table: [
      type: :string,
      default: "migrations",
      doc: """
      The name of the table used to store database migration state data.
      """
    ],
    migrations_root_dir: [
      type: :string,
      default: "priv/database",
      doc: """
      The directory relative to the project directory where the database
      migration files are located.
      """
    ],
    datastore_name: [
      type:
        {:or,
         [nil, :atom, {:tuple, [{:in, [:via]}, :atom, :any]}, {:tuple, [{:in, [:global]}, :any]}]},
      type_doc: "`t:GenServer.name/0` or `nil`",
      doc: """
      Specifies the name for the Datastore Supervisor. If this option is not
      provided, the `datastore_options.datastore_name` value will be used as
      the default name for the Datastore Supervisor.  If this value identifies a
      process registry (e.g. `{:via, Registry, {MyApp.Registry, :my_registry}}`),
      this registry will become the default registry for all Datastore Contexts;
      a valid `context_registry` value overrides this default.
      """
    ]
  ]

  ##############################################################################
  #
  # get_datastore_state
  #
  #

  @get_datastore_state_opts NimbleOptions.new!(
                              Keyword.take(option_defs, [:db_shutdown_timeout, :context_registry])
                            )

  @doc section: :datastore_management
  @doc """
  Returns the state of the Datastore and its contexts based on the provided
  Datastore Options.

  This function performs the following checks:

    1. Verifies the existence of the database backing the Datastore.
    2. Checks the state of each database role representing the Datastore
       Contexts.
    3. Determines if database connections for the Datastore Contexts have been
      started.

  ## Parameters

    * `datastore_options` - A `DatastoreOptions` struct defining the Datastore
      and its contexts.

    * `opts` - a Keyword List of additional key/value call configurations.  See
      the "Options" section for details.

  ## Options

  #{NimbleOptions.docs(@get_datastore_state_opts)}

  ## Returns

    * `{:ok, database_state, context_states}` - if successful, where:
      - `database_state` is the state of the Datastore database (`:ready` or
        `:not_found`)
      - `context_states` is a list of `ContextState` structs for each context

    * `{:error, MscmpSystError.t()}` - if there's an error retrieving the
      Datastore state.

  ## Errors

  The function may return an error with code `:database_error` if there's a failure
  in retrieving the Datastore state.

  """
  @spec get_datastore_state(DatastoreOptions.t()) ::
          {:ok, Types.database_state_values(), list(ContextState.t())}
          | {:error, MscmpSystError.t()}
  @spec get_datastore_state(DatastoreOptions.t(), Keyword.t()) ::
          {:ok, Types.database_state_values(), list(ContextState.t())}
          | {:error, MscmpSystError.t()}
  def get_datastore_state(datastore_options, opts \\ []) do
    case NimbleOptions.validate(opts, @get_datastore_state_opts) do
      {:ok, validated_opts} ->
        Dba.get_datastore_state(datastore_options, validated_opts)

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
  # create_datastore
  #
  #

  @create_datastore_opts NimbleOptions.new!(
                           Keyword.take(option_defs, [
                             :db_shutdown_timeout,
                             :migrations_schema,
                             :migrations_table
                           ])
                         )

  @doc section: :datastore_management
  @doc """
  Creates a new Datastore along with its contexts.

  The creation of a new Datastore includes the following steps:

    1. Creating database roles representing each of the Datastore contexts.
    2. Creating a new database to back the Datastore.
    3. Applying database connection privileges to the context roles.
    4. Initializing the Datastore with necessary structures and data.

  ## Parameters

    * `datastore_options` - A `DatastoreOptions` struct defining the Datastore
      and its contexts.

    * `opts` - a Keyword List of additional key/value call configurations.  See
      the "Options" section for details.

  ## Options

  #{NimbleOptions.docs(@create_datastore_opts)}

  ## Returns

    * `{:ok, :ready, list(ContextState.t())}` - if the Datastore is successfully
      created.

    * `{:error, MscmpSystError.t()}` - if there's an error during the creation
      process.

  ## Errors

  The function may return an error with code `:database_error` if there's a
  failure in any step of the Datastore creation process.
  """
  @spec create_datastore(DatastoreOptions.t()) ::
          {:ok, Types.database_state_values(), list(ContextState.t())}
          | {:error, MscmpSystError.t()}
  @spec create_datastore(DatastoreOptions.t(), Keyword.t()) ::
          {:ok, Types.database_state_values(), list(ContextState.t())}
          | {:error, MscmpSystError.t()}
  def create_datastore(datastore_options, opts \\ []) do
    case NimbleOptions.validate(opts, @create_datastore_opts) do
      {:ok, validated_opts} ->
        Dba.create_datastore(datastore_options, validated_opts)

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
  # drop_datastore
  #
  #

  @drop_datastore_opts NimbleOptions.new!(Keyword.take(option_defs, [:db_shutdown_timeout]))

  @doc section: :datastore_management
  @doc """
  Drops a Datastore along with its contexts.

  Dropping a Datastore will drop the database backing the Datastore from the
  database server as well as all of the database roles associated with the
  Datastore as defined by the provided database options.

  Prior to dropping the Datastore, all active connections to the Datastore
  should be terminated, or the function call could fail.

  > #### Warning! {: .warning}
  >
  > This is an irreversible, destructive action. Any successful call will result
  > in permanent data loss.

  ## Parameters

    * `datastore_options` - A `DatastoreOptions` struct defining the Datastore
      and its contexts.

    * `opts` - a Keyword List of additional key/value call configurations.  See
      the "Options" section for details.

  ## Options

  #{NimbleOptions.docs(@drop_datastore_opts)}

  ## Returns

    * `:ok` if the Datastore is successfully dropped.
    * `{:error, MscmpSystError.t()}` if there's an error during the drop process.

  ## Errors

  The function may return an error with code `:database_error` if there's a failure
  in any step of the Datastore drop process, such as being unable to drop the
  database or roles due to active connections.

  """
  @spec drop_datastore(DatastoreOptions.t()) :: :ok | {:error, MscmpSystError.t()}
  @spec drop_datastore(DatastoreOptions.t(), Keyword.t()) :: :ok | {:error, MscmpSystError.t()}
  def drop_datastore(datastore_options, opts \\ []) do
    case NimbleOptions.validate(opts, @drop_datastore_opts) do
      {:ok, validated_opts} ->
        Dba.drop_datastore(datastore_options, validated_opts)

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
  # get_datastore_context_states
  #
  #

  @get_datastore_context_states_opts NimbleOptions.new!(
                                       Keyword.take(option_defs, [
                                         :db_shutdown_timeout,
                                         :context_registry
                                       ])
                                     )

  @doc section: :datastore_management
  @doc """
  Returns the state of the requested Datastore contexts.

  This function will check for each given context that: it exists, whether or not
  database connections may be started for it, and whether or not database
  connections have been started.

  Note that only startable contexts are included in this list.  If the context
  is not startable or has `id: nil`, the context will be excluded from the
  results of this function.

  ## Parameters

    * `datastore_options` - A `DatastoreOptions` struct defining the Datastore
      and its contexts.

    * `opts` - a Keyword List of additional key/value call configurations.  See
      the "Options" section for details..

  ## Options

  #{NimbleOptions.docs(@get_datastore_context_states_opts)}

  ## Returns

    * `{:ok, list(ContextState.t())}` if successful, where
      `list(ContextState.t())` is a list of `ContextState` structs for each
      context.

    * `{:error, MscmpSystError.t()}` if there's an error retrieving the context
      states.

  ## Errors

    The function may return an error with code `:database_error` if there's a
    failure in retrieving the context states.
  """
  @spec get_datastore_context_states(DatastoreOptions.t()) ::
          {:ok, nonempty_list(ContextState.t())} | {:error, MscmpSystError.t()}
  @spec get_datastore_context_states(DatastoreOptions.t(), Keyword.t()) ::
          {:ok, nonempty_list(ContextState.t())} | {:error, MscmpSystError.t()}
  def get_datastore_context_states(datastore_options, opts \\ []) do
    case NimbleOptions.validate(opts, @get_datastore_context_states_opts) do
      {:ok, validated_opts} ->
        Dba.get_datastore_context_states(datastore_options, validated_opts)

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
  # create_datastore_contexts
  #
  #

  @create_datastore_contexts_opts NimbleOptions.new!(
                                    Keyword.take(option_defs, [:db_shutdown_timeout])
                                  )

  @doc section: :datastore_management
  @doc """
  Creates database roles to back all requested Datastore contexts.

  Usually Datastore contexts are created in the `create_datastore/1` call, but
  over the course of time it is expected that applications may define new
  contexts as needs change.  This function allows applications to add new
  contexts to existing Datastores.

  ## Parameters

    * `datastore_options` - The Datastore configuration struct to use for the
      operation.

    * `datastore_contexts` - A nonempty list of Datastore contexts to create.

    * `opts` - a Keyword List of additional key/value call configurations.  See
      the "Options" section for details..

  ## Options

  #{NimbleOptions.docs(@create_datastore_contexts_opts)}

  ## Returns

    * `{:ok, nonempty_list(ContextState.t())}` if successful, where
      `nonempty_list(ContextState.t())` is a list of `ContextState` structs
      representing the state of each created context.

    * `{:error, MscmpSystError.t()}` if there is an error creating the contexts.

  """
  @spec create_datastore_contexts(DatastoreOptions.t(), nonempty_list(DatastoreContext.t())) ::
          {:ok, nonempty_list(ContextState.t())} | {:error, MscmpSystError.t()}
  @spec create_datastore_contexts(
          DatastoreOptions.t(),
          nonempty_list(DatastoreContext.t()),
          Keyword.t()
        ) :: {:ok, nonempty_list(ContextState.t())} | {:error, MscmpSystError.t()}
  def create_datastore_contexts(datastore_options, datastore_contexts, opts \\ []) do
    case NimbleOptions.validate(opts, @create_datastore_contexts_opts) do
      {:ok, validated_opts} ->
        Dba.create_datastore_contexts(datastore_options, datastore_contexts, validated_opts)

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
  # drop_datastore_contexts
  #
  #

  @drop_datastore_contexts_opts NimbleOptions.new!(
                                  Keyword.take(option_defs, [:db_shutdown_timeout])
                                )

  @doc section: :datastore_management
  @doc """
  Drops the requested Datastore contexts.

  This function will drop the database roles from the database server that
  correspond to the requested Datastore contexts.  You should be sure that the
  requested Datastore contexts do not have active database connections when
  calling this function as active connections are likely to result in an
  error condition.

  ## Parameters

    * `datastore_options` - The Datastore configuration struct to use for the
      operation.

    * `datastore_contexts` - A nonempty list of Datastore contexts to drop.

    * `opts` - a Keyword List of additional key/value call configurations.  See
      the "Options" section for details..

  ## Options

  #{NimbleOptions.docs(@drop_datastore_contexts_opts)}


  ## Returns

    * `:ok` on success

    * `{:error, reason}` on failure.
  """
  @spec drop_datastore_contexts(DatastoreOptions.t(), nonempty_list(DatastoreContext.t())) ::
          :ok | {:error, MscmpSystError.t()}
  @spec drop_datastore_contexts(
          DatastoreOptions.t(),
          nonempty_list(DatastoreContext.t()),
          Keyword.t()
        ) ::
          :ok | {:error, MscmpSystError.t()}
  def drop_datastore_contexts(datastore_options, datastore_contexts, opts \\ []) do
    case NimbleOptions.validate(opts, @drop_datastore_contexts_opts) do
      {:ok, validated_opts} ->
        Dba.drop_datastore_contexts(datastore_options, datastore_contexts, validated_opts)

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
  # get_datastore_version
  #
  #

  @get_datastore_version_opts NimbleOptions.new!(
                                Keyword.take(option_defs, [:db_shutdown_timeout])
                              )

  @doc section: :datastore_migrations
  @doc """
  Returns the most recently installed database migration version number.

  The version is returned as the string representation of our segmented version
  number in the format `RR.VV.UUU.SSSSSS.MMM` where each segment represents a
  Base 36 number for specific versioning purposes.  The segments are defined as:

    * `RR` - The major feature release number in the decimal range of 0 - 1,295.

    * `VV` - The minor feature version within the release in the decimal range
      of 0 - 1,295.

    * `UUU` - The update patch number of the specified release/version in the
      decimal range of 0 - 46,655.

    * `SSSSSS` - Sponsor or client number for whom the specific migration or
      version is being produced for in the decimal range of 0 - 2,176,782,335.

    * `MMM` - Sponsor modification number in the decimal range of 0 - 46,655.

  See `mix builddb` for further explanation version number segment meanings.

  ## Parameters

    * `datastore_options` - The Datastore configuration struct to use for the
      operation.

    * `opts` - a Keyword List of additional key/value call configurations.  See
      the "Options" section for details..

  ## Options

    #{NimbleOptions.docs(@get_datastore_version_opts)}

  ## Returns

    * `{:ok, version}` - The current version of the Datastore as a string.

    * `{:error, reason}` - An error occurred.

  """
  @spec get_datastore_version(DatastoreOptions.t()) ::
          {:ok, String.t()} | {:error, MscmpSystError.t()}
  @spec get_datastore_version(DatastoreOptions.t(), Keyword.t()) ::
          {:ok, String.t()} | {:error, MscmpSystError.t()}
  def get_datastore_version(datastore_options, opts \\ []) do
    case NimbleOptions.validate(opts, @get_datastore_version_opts) do
      {:ok, validated_opts} ->
        Privileged.get_datastore_version(datastore_options, validated_opts)

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
  # upgrade_datastore
  #
  #

  @upgrade_datastore_opts NimbleOptions.new!(
                            Keyword.take(option_defs, [
                              :db_shutdown_timeout,
                              :migrations_root_dir,
                              :migrations_schema,
                              :migrations_table
                            ])
                          )

  @doc section: :datastore_migrations
  @doc """
  Updates a Datastore to the most current version of the given type of Datastore.

  If a Datastore is already up-to-date, this function is basically a "no-op"
  that returns the current version.  Otherwise, database migrations for the
  Datastore type are applied until the Datastore is fully upgraded to the most
  recent schema version.

  ## Parameters:
    * `datastore_options` - The `DatastoreOptions` struct containing the
      Datastore configuration.

    * `datastore_type` - A string representing the type of the Datastore which
      determines which migrations are applied.

    * `migration_bindings` - A keyword list of bindings to be used in the
      migration scripts.

    * `opts` - a Keyword List of additional key/value call configurations.  See
      the "Options" section for details.

  ## Options:

    #{NimbleOptions.docs(@upgrade_datastore_opts)}

  ## Returns:

    * `{:ok, [String.t()]}` - A tuple containing `:ok` and a list of migration
      scripts that were applied.

    * `{:error, MscmpSystError.t()}` - A tuple containing `:error` and an
      `MscmpSystError` struct representing the error that occurred.

  """
  @spec upgrade_datastore(DatastoreOptions.t(), String.t(), Keyword.t()) ::
          {:error, MscmpSystError.t()} | {:ok, [binary()]}
  @spec upgrade_datastore(DatastoreOptions.t(), String.t(), Keyword.t(), Keyword.t()) ::
          {:ok, [String.t()]} | {:error, MscmpSystError.t()}
  def upgrade_datastore(datastore_options, datastore_type, migration_bindings, opts \\ []) do
    case NimbleOptions.validate(opts, @upgrade_datastore_opts) do
      {:ok, validated_opts} ->
        Privileged.upgrade_datastore(
          datastore_options,
          datastore_type,
          migration_bindings,
          validated_opts
        )

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
  # start_datastore
  #
  #

  @start_datastore_opts NimbleOptions.new!(
                          Keyword.take(option_defs, [:datastore_name, :context_registry])
                        )

  @doc section: :service_management
  @doc """
  Starts database connections for all of login contexts in the Datastore options.

  ## Parameters:

    * `datastore_options` - A `DatastoreOptions` struct containing the login
      contexts.

    * `opts` - a Keyword List of additional key/value call configurations.  See
      the "Options" section for details.

  ## Options:

    #{NimbleOptions.docs(@start_datastore_opts)}

  ## Returns:

    * `{:ok, :all_started | :some_started, list(Types.ContextState.t())}` -
      Returns `:ok` with either `:all_started` or `:some_started` atom
      indicating if all or some of the contexts were started successfully, along
      with a list of `Types.ContextState` structs representing the state of each
      context.

    * `{:error, MscmpSystError.t()}` - Returns an error tuple with a
      `MscmpSystError` struct if there was an error starting the database
      connections.
  """
  @spec start_datastore(DatastoreOptions.t()) ::
          {:ok, :all_started | :some_started, list(Types.ContextState.t())}
          | {:error, MscmpSystError.t()}
  @spec start_datastore(DatastoreOptions.t(), Keyword.t()) ::
          {:ok, :all_started | :some_started, list(Types.ContextState.t())}
          | {:error, MscmpSystError.t()}
  def start_datastore(datastore_options, opts \\ []) do
    case NimbleOptions.validate(opts, @start_datastore_opts) do
      {:ok, validated_opts} ->
        Datastore.start_datastore(datastore_options, validated_opts)

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
  # start_datastore_context
  #
  #

  @start_datastore_context_opts NimbleOptions.new!(Keyword.take(option_defs, [:context_registry]))

  @doc section: :service_management
  @doc """
  Starts a database connection for the specific Datastore context provided.

  ## Parameters:
    * `datastore_options` - The `t:MscmpSystDb.DatastoreOptions.t/0` struct
      containing the Datastore options.

    * `context` - The `t:MscmpSystDb.Types.context_name/0` atom or
      `t:DatastoreContext.t/0` struct representing the Datastore
      context.

    * `opts` - a Keyword List of additional key/value call configurations.  See
      the "Options" section for details.

  ## Options:

    #{NimbleOptions.docs(@start_datastore_context_opts)}

  ## Returns:

    * `{:ok, pid()}` on success, where `pid()` is the process ID of the
      Datastore context.

    * `{:error, reason}` on failure, where `reason` is a
      `t:MscmpSystDb.MscmpSystError.t/0` struct.

  """
  @spec start_datastore_context(
          DatastoreOptions.t(),
          Types.context_name() | DatastoreContext.t()
        ) :: {:ok, pid()} | {:error, MscmpSystError.t()}
  @spec start_datastore_context(
          DatastoreOptions.t(),
          Types.context_name() | DatastoreContext.t(),
          Keyword.t()
        ) ::
          {:ok, pid()} | {:error, MscmpSystError.t()}
  def start_datastore_context(datastore_options, context, opts \\ []) do
    case NimbleOptions.validate(opts, @start_datastore_context_opts) do
      {:ok, validated_opts} ->
        Datastore.start_datastore_context(datastore_options, context, validated_opts)

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
  # stop_datastore
  #
  #

  @stop_datastore_opts NimbleOptions.new!(
                         Keyword.take(option_defs, [:context_registry, :db_shutdown_timeout])
                       )

  @doc section: :service_management
  @doc """
  Disconnects the database connections for all of the login Datastore option
  contexts.

  ## Parameters

    * `datastore_options_or_contexts` - A `DatastoreOptions` struct, a list of
      `DatastoreContext` structs, or a list of maps with `:context_name` keys.

    * `opts` - a Keyword List of additional key/value call configurations.  See
      the "Options" section for details.

  ## Options

    #{NimbleOptions.docs(@stop_datastore_opts)}

  ## Returns

    * `:ok` if the connections were successfully stopped.

    * `{:error, reason}` if there was an error stopping the connections.
  """
  @spec stop_datastore(
          DatastoreOptions.t()
          | list(DatastoreContext.t())
          | list(%{context_name: Types.context_name()})
        ) ::
          :ok | {:error, MscmpSystError.t()}
  @spec stop_datastore(
          DatastoreOptions.t()
          | list(DatastoreContext.t())
          | list(%{context_name: Types.context_name()}),
          Keyword.t()
        ) ::
          :ok | {:error, MscmpSystError.t()}
  def stop_datastore(datastore_options_or_contexts, opts \\ []) do
    case NimbleOptions.validate(opts, @stop_datastore_opts) do
      {:ok, validated_opts} ->
        Datastore.stop_datastore(datastore_options_or_contexts, validated_opts)

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
  # stop_datastore_context
  #
  #

  @stop_datastore_context_opts NimbleOptions.new!(
                                 Keyword.take(option_defs, [
                                   :context_registry,
                                   :db_shutdown_timeout
                                 ])
                               )

  @doc section: :service_management
  @doc """
  Disconnects the database connection for the specific Datastore context provided.

  ## Parameters

    * `context` - The Datastore context to disconnect. This can be a `pid()`,
      `atom()`, or `DatastoreContext` struct.

    * `opts` - a Keyword List of additional key/value call configurations.  See
      the "Options" section for details.

  ## Options

    #{NimbleOptions.docs(@stop_datastore_context_opts)}

  ## Returns

    * `:ok` - On successful stopping of the requested Datastore Context.
  """
  @spec stop_datastore_context(pid() | atom() | DatastoreContext.t()) :: :ok
  @spec stop_datastore_context(pid() | atom() | DatastoreContext.t(), Keyword.t()) :: :ok
  def stop_datastore_context(context, opts \\ []) do
    opts = NimbleOptions.validate!(opts, @stop_datastore_context_opts)
    Datastore.stop_datastore_context(context, opts)
  end

  ##############################################################################
  #
  # put_datastore_context
  #
  #

  @doc section: :service_management
  @doc """
  Establishes the Datastore Context to use for Datastore interactions in the
  Elixir process where this function is called.

  Using this function will set the given Datastore Context in the Process
  Dictionary of the process from which the function call is made.

  This version of the function uses normal Ecto dynamic repository naming
  conventions.

  ## Parameters

    * `context` - The Datastore Context to use for Datastore interactions in the
      Elixir process where this function is called.

  ## Returns

    * `atom()` - The previously set Datastore Context value, if one was
      previously set.

    * `nil` - If no Datastore Context was previously set.
  """
  @spec put_datastore_context(
          pid()
          | Ecto.Repo.t()
          | Ecto.Adapter.adapter_meta()
          | GenServer.name()
        ) ::
          atom() | pid()
  defdelegate put_datastore_context(context), to: Datastore

  @doc section: :service_management
  @doc """
  Establishes the Datastore Context to use for Datastore interactions in the
  Elixir process where this function is called.

  Using this function will set the given Datastore Context in the Process
  Dictionary of the process from which the function call is made.

  This version of the function allows you identify a Datastore Context using a
  string based name registered in the provided registry.  Naturally, the
  Datastore Context must have been started using a string based name for this
  method to be applicable.

  ## Parameters

    * `context` - The Datastore Context to use for Datastore interactions in the
      Elixir process where this function is called.

  ## Returns

    * `atom()` - The previously set Datastore Context value, if one was
      previously set.

    * `nil` - If no Datastore Context was previously set.
  """
  @spec put_datastore_context(Types.context_registry(), Types.context_name()) ::
          atom() | pid()
  defdelegate put_datastore_context(context_registry, context), to: Datastore

  ##############################################################################
  #
  # current_datastore_context
  #
  #

  @doc section: :service_management
  @doc """
  Retrieves either atom name or `t:pid/0` of the currently established Datastore
  context, unless no context has been established.

  ## Returns

    * `atom()` - The currently established Datastore Context atom name, if the
      Datastore Context was named and established for the session using the
      standard Ecto dynamic repository naming conventions.

    * `pid()` - The currently established Datastore Context pid, if the current
      Datastore Context was set using a pid.  This will be the case when string
      based Datastore Context names were used.

    * `nil` - If no Datastore Context was established for the session.

  """
  @spec current_datastore_context :: atom() | pid() | nil
  defdelegate current_datastore_context(), to: Datastore

  ##############################################################################
  #
  # query_for_none
  #
  #

  @doc section: :query
  @doc """
  Executes a database query but returns no results.
  """
  @spec query_for_none(iodata()) :: :ok | {:error, MscmpSystError.t()}
  @spec query_for_none(iodata(), [term()]) :: :ok | {:error, MscmpSystError.t()}
  @spec query_for_none(iodata(), [term()], Keyword.t()) :: :ok | {:error, MscmpSystError.t()}
  defdelegate query_for_none(query, query_params \\ [], opts \\ []), to: Datastore

  @doc section: :query
  @doc """
  Executes a database query but returns no results.  Raises on error.

  """
  @spec query_for_none!(iodata()) :: :ok
  @spec query_for_none!(iodata(), [term()]) :: :ok
  @spec query_for_none!(iodata(), [term()], Keyword.t()) :: :ok
  defdelegate query_for_none!(query, query_params \\ [], opts \\ []), to: Datastore

  ##############################################################################
  #
  # query_for_value
  #
  #

  @doc section: :query
  @doc """
  Executes a database query returning a single value.
  """
  @spec query_for_value(iodata()) ::
          {:ok, any()} | {:error, MscmpSystError.t()}
  @spec query_for_value(iodata(), [term()]) ::
          {:ok, any()} | {:error, MscmpSystError.t()}
  @spec query_for_value(iodata(), [term()], Keyword.t()) ::
          {:ok, any()} | {:error, MscmpSystError.t()}
  defdelegate query_for_value(query, query_params \\ [], opts \\ []), to: Datastore

  @doc section: :query
  @doc """
  Executes a database query returning a single value.  Raises on error.
  """
  @spec query_for_value!(iodata()) :: any()
  @spec query_for_value!(iodata(), [term()]) :: any()
  @spec query_for_value!(iodata(), [term()], Keyword.t()) :: any()
  defdelegate query_for_value!(query, query_params \\ [], opts \\ []), to: Datastore

  ##############################################################################
  #
  # query_for_one
  #
  #

  @doc section: :query
  @doc """
  Executes a database query and returns a single row.
  """
  @spec query_for_one(iodata()) ::
          {:ok, [any()]} | {:error, MscmpSystError.t()}
  @spec query_for_one(iodata(), [term()]) ::
          {:ok, [any()]} | {:error, MscmpSystError.t()}
  @spec query_for_one(iodata(), [term()], Keyword.t()) ::
          {:ok, [any()]} | {:error, MscmpSystError.t()}
  defdelegate query_for_one(query, query_params \\ [], opts \\ []), to: Datastore

  @doc section: :query
  @doc """
  Executes a database query and returns a single row.  Raises on error.
  """
  @spec query_for_one!(iodata()) :: [any()]
  @spec query_for_one!(iodata(), [term()]) :: [any()]
  @spec query_for_one!(iodata(), [term()], Keyword.t()) :: [any()]
  defdelegate query_for_one!(query, query_params \\ [], opts \\ []), to: Datastore

  ##############################################################################
  #
  # query_for_many
  #
  #

  @doc section: :query
  @doc """
  Executes a database query and returns all rows.
  """
  @spec query_for_many(iodata()) ::
          {:ok,
           %{
             :rows => nil | [[term()] | binary()],
             :num_rows => non_neg_integer(),
             optional(atom()) => any()
           }}
          | {:error, MscmpSystError.t()}
  @spec query_for_many(iodata(), [term()]) ::
          {:ok,
           %{
             :rows => nil | [[term()] | binary()],
             :num_rows => non_neg_integer(),
             optional(atom()) => any()
           }}
          | {:error, MscmpSystError.t()}
  @spec query_for_many(iodata(), [term()], Keyword.t()) ::
          {:ok,
           %{
             :rows => nil | [[term()] | binary()],
             :num_rows => non_neg_integer(),
             optional(atom()) => any()
           }}
          | {:error, MscmpSystError.t()}
  defdelegate query_for_many(query, query_params \\ [], opts \\ []), to: Datastore

  @doc section: :query
  @doc """
  Executes a database query and returns all rows.  Raises on error.
  """
  @spec query_for_many!(iodata()) :: %{
          :rows => nil | [[term()] | binary()],
          :num_rows => non_neg_integer(),
          optional(atom()) => any()
        }
  @spec query_for_many!(iodata(), [term()]) :: %{
          :rows => nil | [[term()] | binary()],
          :num_rows => non_neg_integer(),
          optional(atom()) => any()
        }
  @spec query_for_many!(iodata(), [term()], Keyword.t()) :: %{
          :rows => nil | [[term()] | binary()],
          :num_rows => non_neg_integer(),
          optional(atom()) => any()
        }
  defdelegate query_for_many!(query, query_params \\ [], opts \\ []), to: Datastore

  # The API below largely duplicates the Ecto.Repo Queryable API and currently
  # wraps it.  The expectation is whether or not we continue to use Ecto, we'd
  # want our basic data access API to look really close to it since it would be
  # reasonably familiar to other developers.

  ##############################################################################
  #
  # transaction
  #
  #

  @doc section: :query
  @doc """
  A convenience function that currently wraps the `c:Ecto.Repo.transaction/2`
  function.
  """
  @spec transaction(fun | Ecto.Multi.t()) :: {:error, MscmpSystError.t()} | {:ok, any}
  @spec transaction(fun | Ecto.Multi.t(), Keyword.t()) ::
          {:error, MscmpSystError.t()} | {:ok, any}
  defdelegate transaction(job, opts \\ []), to: Datastore, as: :ecto_transaction

  ##############################################################################
  #
  # record_count
  #
  #

  @doc section: :query
  @doc """
  Returns the record count of the given queryable argument.
  """
  defdelegate record_count(queryable, opts), to: Datastore, as: :record_count

  @doc section: :query
  @doc """
  A convenience function that currently wraps the `c:Ecto.Repo.aggregate/4`
  function.
  """
  defdelegate aggregate(queryable, aggregate, field, opts \\ []), to: Datastore

  @doc section: :query
  @doc """
  A convenience function that currently wraps the `c:Ecto.Repo.all/2` function.
  """
  @spec all(Ecto.Queryable.t(), Keyword.t()) :: list(Ecto.Schema.t())
  defdelegate all(queryable, opts \\ []), to: Datastore

  @doc section: :query
  @doc """
  A convenience function that currently wraps the `c:Ecto.Repo.delete/2`
  function.
  """
  defdelegate delete(struct_or_changeset, opts \\ []),
    to: Datastore

  @doc section: :query
  @doc """
  A convenience function that currently wraps the `c:Ecto.Repo.delete!/2`
  function.
  """
  defdelegate delete!(struct_or_changeset, opts \\ []),
    to: Datastore

  @doc section: :query
  @doc """
  A convenience function that currently wraps the `c:Ecto.Repo.delete_all/2`
  function.
  """
  defdelegate delete_all(queryable, opts \\ []), to: Datastore

  @doc section: :query
  @doc """
  A convenience function that currently wraps the `c:Ecto.Repo.exists?/2`
  function.
  """
  defdelegate exists?(queryable, opts \\ []), to: Datastore

  @doc section: :query
  @doc """
  A convenience function that currently wraps the `c:Ecto.Repo.get/3`
  function.
  """
  defdelegate get(queryable, id, opts \\ []), to: Datastore

  @doc section: :query
  @doc """
  A convenience function that currently wraps the `c:Ecto.Repo.get!/3`
  function.
  """
  defdelegate get!(queryable, id, opts \\ []), to: Datastore

  @doc section: :query
  @doc """
  A convenience function that currently wraps the `c:Ecto.Repo.get_by/3`
  function.
  """
  defdelegate get_by(queryable, clauses, opts \\ []),
    to: Datastore

  @doc section: :query
  @doc """
  A convenience function that currently wraps the `c:Ecto.Repo.get_by!/3`
  function.
  """
  defdelegate get_by!(queryable, clauses, opts \\ []),
    to: Datastore

  @doc section: :query
  @doc """
  A convenience function that currently wraps the `c:Ecto.Repo.in_transaction?/0`
  function.
  """
  defdelegate in_transaction?, to: Datastore

  @doc section: :query
  @doc """
  A convenience function that currently wraps the `c:Ecto.Repo.insert/2`
  function.
  """
  defdelegate insert(struct_or_changeset, opts \\ []),
    to: Datastore

  @doc section: :query
  @doc """
  A convenience function that currently wraps the `c:Ecto.Repo.insert!/2`
  function.
  """
  defdelegate insert!(struct_or_changeset, opts \\ []),
    to: Datastore

  @doc section: :query
  @doc """
  A convenience function that currently wraps the `c:Ecto.Repo.insert_all/3`
  function.
  """
  defdelegate insert_all(schema_or_source, entries_or_query, opts \\ []),
    to: Datastore

  @doc section: :query
  @doc """
  A convenience function that currently wraps the `c:Ecto.Repo.insert_or_update/2`
  function.
  """
  defdelegate insert_or_update(changeset, opts \\ []),
    to: Datastore

  @doc section: :query
  @doc """
  A convenience function that currently wraps the `c:Ecto.Repo.insert_or_update!/2`
  function.
  """
  defdelegate insert_or_update!(changeset, opts \\ []),
    to: Datastore

  @doc section: :query
  @doc """
  A convenience function that currently wraps the `c:Ecto.Repo.load/2`
  function.
  """
  defdelegate load(module_or_map, data), to: Datastore

  @doc section: :query
  @doc """
  A convenience function that currently wraps the `c:Ecto.Repo.one/2`
  function.
  """
  defdelegate one(queryable, opts \\ []), to: Datastore

  @doc section: :query
  @doc """
  A convenience function that currently wraps the `c:Ecto.Repo.one!/2`
  function.
  """
  defdelegate one!(queryable, opts \\ []), to: Datastore

  @doc section: :query
  @doc """
  A convenience function that currently wraps the `c:Ecto.Repo.preload/3`
  function.
  """
  defdelegate preload(structs_or_struct_or_nil, preloads, opts \\ []),
    to: Datastore

  @doc section: :query
  @doc """
  A convenience function that currently wraps the `c:Ecto.Repo.prepare_query/3`
  function.
  """
  defdelegate prepare_query(operation, query, opts \\ []),
    to: Datastore

  @doc section: :query
  @doc """
  A convenience function that currently wraps the `c:Ecto.Repo.reload/2`
  function.
  """
  defdelegate reload(struct_or_structs, opts \\ []), to: Datastore

  @doc section: :query
  @doc """
  A convenience function that currently wraps the `c:Ecto.Repo.reload!/2`
  function.
  """
  defdelegate reload!(struct_or_structs, opts \\ []),
    to: Datastore

  @doc section: :query
  @doc """
  A convenience function that currently wraps the `c:Ecto.Repo.rollback/1`
  function.
  """
  defdelegate rollback(value), to: Datastore

  @doc section: :query
  @doc """
  A convenience function that currently wraps the `c:Ecto.Repo.stream/2`
  function.
  """
  defdelegate stream(queryable, opts \\ []), to: Datastore

  @doc section: :query
  @doc """
  A convenience function that currently wraps the `c:Ecto.Repo.update/2`
  function.
  """
  defdelegate update(changeset, opts \\ []), to: Datastore

  @doc section: :query
  @doc """
  A convenience function that currently wraps the `c:Ecto.Repo.update!/2`
  function.
  """
  defdelegate update!(changeset, opts \\ []), to: Datastore

  @doc section: :query
  @doc """
  A convenience function that currently wraps the `c:Ecto.Repo.update_all/3`
  function.
  """
  defdelegate update_all(queryable, updates, opts \\ []),
    to: Datastore
end
