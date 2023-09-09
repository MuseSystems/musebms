defmodule MscmpSystDb do
  @external_resource "README.md"
  @moduledoc File.read!(Path.join([__DIR__, "..", "README.md"]))

  alias MscmpSystDb.Impl.Dba
  alias MscmpSystDb.Impl.Privileged
  alias MscmpSystDb.Runtime.Datastore
  alias MscmpSystDb.Types
  alias MscmpSystDb.Types.{ContextState, DatastoreContext, DatastoreOptions}

  @doc section: :datastore_management
  @doc """
  Returns the state of the database and database roles which back the Datastore
  and contexts, respectively, of the provided Datastore options definition.
  """
  @spec get_datastore_state(DatastoreOptions.t(), Keyword.t()) ::
          {:ok, Types.database_state_values(), list(ContextState.t())}
          | {:error, MscmpSystError.t()}
  defdelegate get_datastore_state(datastore_options, opts \\ []), to: Dba

  @doc section: :datastore_management
  @doc """
  Creates a new Datastore along with its contexts.

  The creation of a new Datastore includes creating new database to back the
  Datastore and database roles representing each of the Datastore contexts.
  """
  @spec create_datastore(DatastoreOptions.t(), Keyword.t()) ::
          {:ok, Types.database_state_values(), list(ContextState.t())}
          | {:error, MscmpSystError.t()}
  defdelegate create_datastore(datastore_options, opts \\ []), to: Dba

  @doc section: :datastore_management
  @doc """
  Drops a Datastore along with its contexts.

  Dropping a Datastore will drop the database backing the Datastore from the
  database server as well as all of the database roles associated defined by the
  provided database options.

  Prior to dropping the Datastore, all active connections to the Datastore
  should be terminated or the function call could fail.

  __Note that this is am irreversible, destructive action.  Any successful call
  will result in data loss.__
  """
  @spec drop_datastore(DatastoreOptions.t(), Keyword.t()) :: :ok | {:error, MscmpSystError.t()}
  defdelegate drop_datastore(datastore_options, opts \\ []), to: Dba

  @doc section: :datastore_management
  @doc """
  Returns the state of the requested contexts.

  This function will check for each given context that: it exist, whether or not
  database connections may be started for it, and whether or not database
  connections have been started.

  Note that only startable contexts are included in this list.  If the context
  is not startable or has `id: nil`, the context will be excluded from the
  results of this function.
  """
  @spec get_datastore_context_states(DatastoreOptions.t(), Keyword.t()) ::
          {:ok, nonempty_list(ContextState.t())} | {:error, MscmpSystError.t()}
  defdelegate get_datastore_context_states(datastore_contexts, opts \\ []), to: Dba

  @doc section: :datastore_management
  @doc """
  Creates database roles to back all requested Datastore contexts.

  Usually Datastore contexts are created in the `create_datastore/1` call, but
  over the course of time it is expected that applications may define new
  contexts as needs change.  This function allows applications to add new
  contexts to existing Datastores.
  """
  @spec create_datastore_contexts(
          DatastoreOptions.t(),
          nonempty_list(DatastoreContext.t()),
          Keyword.t()
        ) ::
          {:ok, nonempty_list(ContextState.t())} | {:error, MscmpSystError.t()}
  defdelegate create_datastore_contexts(datastore_options, datastore_contexts, opts \\ []),
    to: Dba

  @doc section: :datastore_management
  @doc """
  Drops the requested Datastore contexts.

  This function will drop the database roles from the database server that
  correspond to the requested Datastore contexts.  You should be sure that the
  requested Datastore contexts do not have active database connections when
  calling this function as active connections are likely to result in an
  error condition.
  """
  @spec drop_datastore_contexts(
          DatastoreOptions.t(),
          nonempty_list(DatastoreContext.t()),
          Keyword.t()
        ) ::
          :ok | {:error, MscmpSystError.t()}
  defdelegate drop_datastore_contexts(datastore_options, datastore_contexts, opts \\ []), to: Dba

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

  """
  @spec get_datastore_version(DatastoreOptions.t(), Keyword.t()) ::
          {:ok, String.t()} | {:error, MscmpSystError.t()}
  defdelegate get_datastore_version(datastore_options, opts \\ []), to: Privileged

  @doc section: :datastore_migrations
  @doc """
  Updates a Datastore to the most current version of the given type of Datastore.

  If a Datastore is already up-to-date, this function is basically a "no-op"
  that returns the current version.  Otherwise, database migrations for the
  Datastore type are applied until the Datastore is fully upgraded to the most
  recent schema version.
  """
  @spec upgrade_datastore(
          DatastoreOptions.t(),
          String.t(),
          Keyword.t(),
          Keyword.t()
        ) ::
          {:ok, [String.t()]} | {:error, MscmpSystError.t()}
  defdelegate upgrade_datastore(
                datastore_options,
                datastore_type,
                migration_bindings,
                opts \\ []
              ),
              to: Privileged

  @doc section: :service_management
  @doc """
  Starts database connections for all of login contexts in the Datastore options.
  """
  @spec start_datastore(DatastoreOptions.t(), Supervisor.supervisor() | nil) ::
          {:ok, :all_started | :some_started, list(Types.context_state_values())}
          | {:error, MscmpSystError.t()}
  defdelegate start_datastore(datastore_options, supervisor_name \\ nil), to: Datastore

  @doc section: :service_management
  @doc """
  Starts a database connection for the specific Datastore context provided.
  """
  @spec start_datastore_context(DatastoreOptions.t(), atom() | DatastoreContext.t()) ::
          {:ok, pid()} | {:error, MscmpSystError.t()}
  defdelegate start_datastore_context(datastore_options, context), to: Datastore

  @doc section: :service_management
  @doc """
  Disconnects the database connections for all of the login Datastore option contexts.
  """
  @spec stop_datastore(
          DatastoreOptions.t()
          | list(DatastoreContext.t())
          | list(%{context_name: Types.context_name()}),
          non_neg_integer()
        ) ::
          :ok | {:error, MscmpSystError.t()}
  defdelegate stop_datastore(datastore_options_or_contexts, db_shutdown_timeout \\ 60_000),
    to: Datastore

  @doc section: :service_management
  @doc """
  Disconnects the database connection for the specific Datastore context provided.
  """
  @spec stop_datastore_context(pid() | atom() | DatastoreContext.t(), non_neg_integer()) :: :ok
  defdelegate stop_datastore_context(context, db_shutdown_timeout \\ 60_000),
    to: Datastore

  @doc section: :query
  @doc """
  Executes a database query but returns no results.
  """
  @spec query_for_none(iodata(), [term()], Keyword.t()) :: :ok | {:error, MscmpSystError.t()}
  defdelegate query_for_none(query, query_params \\ [], opts \\ []), to: Datastore

  @doc section: :query
  @doc """
  Executes a database query but returns no results.  Raises on error.

  """
  @spec query_for_none!(iodata(), [term()], Keyword.t()) :: :ok
  defdelegate query_for_none!(query, query_params \\ [], opts \\ []), to: Datastore

  @doc section: :query
  @doc """
  Executes a database query returning a single value.
  """
  @spec query_for_value(iodata(), [term()], Keyword.t()) ::
          {:ok, any()} | {:error, MscmpSystError.t()}
  defdelegate query_for_value(query, query_params \\ [], opts \\ []), to: Datastore

  @doc section: :query
  @doc """
  Executes a database query returning a single value.  Raises on error.
  """
  @spec query_for_value!(iodata(), [term()], Keyword.t()) :: any()
  defdelegate query_for_value!(query, query_params \\ [], opts \\ []), to: Datastore

  @doc section: :query
  @doc """
  Executes a database query and returns a single row.
  """
  @spec query_for_one(iodata(), [term()], Keyword.t()) ::
          {:ok, [any()]} | {:error, MscmpSystError.t()}
  defdelegate query_for_one(query, query_params \\ [], opts \\ []), to: Datastore

  @doc section: :query
  @doc """
  Executes a database query and returns a single row.  Raises on error.
  """
  @spec query_for_one!(iodata(), [term()], Keyword.t()) :: [any()]
  defdelegate query_for_one!(query, query_params \\ [], opts \\ []), to: Datastore

  @doc section: :query
  @doc """
  Executes a database query and returns all rows.
  """
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

  @doc section: :service_management
  @doc """
  Establishes the Datastore Context to use for Datastore interactions in the
  Elixir process where this function is called.

  Using this function will set the given Datastore Context in the Process
  Dictionary of the process from which the function call is made.
  """
  @spec put_datastore_context(pid() | Ecto.Repo.t() | Ecto.Adapter.adapter_meta()) ::
          atom() | pid()
  defdelegate put_datastore_context(context), to: Datastore

  @doc section: :service_management
  @doc """
  Retrieves either atom name or `t:pid/0` of the currently established Datastore
  context, unless no context has been established.
  """
  @spec current_datastore_context :: atom() | pid()
  defdelegate current_datastore_context(), to: Datastore

  @doc section: :query
  @doc """
  A convenience function that currently wraps the `c:Ecto.Repo.transaction/2`
  function.
  """
  @spec transaction(fun | Ecto.Multi.t(), keyword) :: {:error, MscmpSystError.t()} | {:ok, any}
  defdelegate transaction(job, opts \\ []), to: Datastore, as: :ecto_transaction

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
