defmodule MsbmsSystDatastore do
  @moduledoc """
  The public API for database interactions.
  """

  alias MsbmsSystDatastore.Impl.Dba
  alias MsbmsSystDatastore.Impl.Privileged
  alias MsbmsSystDatastore.Runtime.Datastore
  alias MsbmsSystDatastore.Types

  @doc """
  Returns the state of the database and database roles which back the datastore
  and contexts, respectively, of the provided datastore options definition.
  """
  @spec get_datastore_state(Types.datastore_options(), Keyword.t()) ::
          {:ok, Types.database_state_values(), list(Types.context_state())}
          | {:error, MsbmsSystError.t()}
  defdelegate get_datastore_state(datastore_options, opts \\ []), to: Dba

  @doc """
  Creates a new datastore along with its contexts.

  The creation of a new datastore includes creating new database to back the
  datastore and database roles representing each of the datastore contexts.
  """
  @spec create_datastore(Types.datastore_options(), Keyword.t()) ::
          {:ok, Types.database_state_values(), list(Types.context_state())}
          | {:error, MsbmsSystError.t()}
  defdelegate create_datastore(datastore_options, opts \\ []), to: Dba

  @doc """
  Drops a datastore along with its contexts.

  Dropping a datastore will drop the database backing the datastore from the
  database server as well as all of the database roles associated defined by the
  provided database options.

  Prior to dropping the datastore, all active connections to the datastore
  should be terminated or the function call could fail.

  __Note that this is am irreversible, destructive action.  Any successful call
  will result in data loss.__
  """
  @spec drop_datastore(Types.datastore_options(), Keyword.t()) ::
          :ok | {:error, MsbmsSystError.t()}
  defdelegate drop_datastore(datastore_options, opts \\ []), to: Dba

  @doc """
  Returns the state of the requested contexts.

  This function will check for each given context that: it exist, whether or not
  database connections may be started for it, and whether or not database
  connections have been started.

  Note that only startable contexts are included in this list.  If the context
  is not startable or has `id: nil`, the context will be excluded from the
  results of this function.
  """
  @spec get_datastore_context_states(Types.datastore_options(), Keyword.t()) ::
          {:ok, nonempty_list(Types.context_state())} | {:error, MsbmsSystError.t()}
  defdelegate get_datastore_context_states(datastore_contexts, opts \\ []), to: Dba

  @doc """
  Creates database roles to back all requested datastore contexts.

  Usually datastore contexts are created in the `create_datastore/1` call, but
  over the course of time it is expected that applications may define new
  contexts as needs change.  This function allows applications to add new
  contexts to existing datastores.
  """
  @spec create_datastore_contexts(
          Types.datastore_options(),
          nonempty_list(Types.datastore_context()),
          Keyword.t()
        ) ::
          {:ok, nonempty_list(Types.context_state())} | {:error, MsbmsSystError.t()}
  defdelegate create_datastore_contexts(datastore_options, datastore_contexts, opts \\ []),
    to: Dba

  @doc """
  Drops the requested datastore contexts.

  This function will drop the database roles from the database server that
  correspond to the requested datastore contexts.  You should be sure that the
  requested datastore contexts do not have active database connections when
  calling this function as active connections are likely to result in an
  error condition.
  """
  @spec drop_datastore_contexts(
          Types.datastore_options(),
          nonempty_list(Types.datastore_context()),
          Keyword.t()
        ) ::
          :ok | {:error, MsbmsSystError.t()}
  defdelegate drop_datastore_contexts(datastore_options, datastore_contexts, opts \\ []), to: Dba

  @doc """
  Returns the most recently installed database migration version number.
  """
  @spec get_datastore_version(Types.datastore_options(), Keyword.t()) ::
          {:ok, String.t()} | {:error, MsbmsSystError.t()}
  defdelegate get_datastore_version(datastore_options, opts \\ []), to: Privileged

  @doc """
  Updates a datastore to the most current version of the given type of datastore.

  If a datastore is already up-to-date, this function is basically a "no-op"
  that returns the current version.  Otherwise, database migrations for the
  datastore type are applied until the datastore is fully upgraded to the most
  recent schema version.
  """
  @spec upgrade_datastore(
          Types.datastore_options(),
          String.t(),
          Keyword.t(),
          Keyword.t()
        ) ::
          {:ok, [String.t()]} | {:error, MsbmsSystError.t()}
  defdelegate upgrade_datastore(
                datastore_options,
                datastore_type,
                migration_bindings,
                opts \\ []
              ),
              to: Privileged

  @doc """
  Starts database connections for all of login contexts in the datastore options.
  """
  @spec start_datastore(Types.datastore_options(), Supervisor.supervisor() | nil) ::
          {:ok, :all_started | :some_started, list(Types.context_state_values())}
          | {:error, MsbmsSystError.t()}
  defdelegate start_datastore(datastore_options, supervisor_name \\ nil), to: Datastore

  @doc """
  Starts a database connection for the specific datastore context provided.
  """
  @spec start_datastore_context(Types.datastore_options(), atom() | Types.datastore_context()) ::
          {:ok, pid()} | {:error, MsbmsSystError.t()}
  defdelegate start_datastore_context(datastore_options, context), to: Datastore

  @doc """
  Disconnects the database connections for all of the login datastore option contexts.
  """
  @spec stop_datastore(
          Types.datastore_options()
          | list(Types.datastore_context())
          | list(%{context_name: Types.context_name()}),
          non_neg_integer()
        ) ::
          :ok | {:error, MsbmsSystError.t()}
  defdelegate stop_datastore(datastore_options_or_contexts, db_shutdown_timeout \\ 60_000),
    to: Datastore

  @doc """
  Disconnects the database connection for the specific datastore context provided.
  """
  @spec stop_datastore_context(pid() | atom() | Types.datastore_context(), non_neg_integer()) ::
          :ok
  defdelegate stop_datastore_context(context, db_shutdown_timeout \\ 60_000),
    to: Datastore

  @doc """
  Executes a database query but returns no results.
  """
  @spec query_for_none(iodata(), [term()], Keyword.t()) :: :ok | {:error, MsbmsSystError.t()}
  defdelegate query_for_none(query, query_params \\ [], opts \\ []), to: Datastore

  @doc """
  Executes a database query but returns no results.  Raises on error.

  """
  @spec query_for_none!(iodata(), [term()], Keyword.t()) :: :ok
  defdelegate query_for_none!(query, query_params \\ [], opts \\ []), to: Datastore

  @doc """
  Executes a database query returning a single value.
  """
  @spec query_for_value(iodata(), [term()], Keyword.t()) ::
          {:ok, any()} | {:error, MsbmsSystError.t()}
  defdelegate query_for_value(query, query_params \\ [], opts \\ []), to: Datastore

  @doc """
  Executes a database query returning a single value.  Raises on error.
  """
  @spec query_for_value!(iodata(), [term()], Keyword.t()) :: any()
  defdelegate query_for_value!(query, query_params \\ [], opts \\ []), to: Datastore

  @doc """
  Executes a database query and returns a single row.
  """
  @spec query_for_one(iodata(), [term()], Keyword.t()) ::
          {:ok, [any()]} | {:error, MsbmsSystError.t()}
  defdelegate query_for_one(query, query_params \\ [], opts \\ []), to: Datastore

  @doc """
  Executes a database query and returns a single row.  Raises on error.
  """
  @spec query_for_one!(iodata(), [term()], Keyword.t()) :: [any()]
  defdelegate query_for_one!(query, query_params \\ [], opts \\ []), to: Datastore

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
          | {:error, MsbmsSystError.t()}
  defdelegate query_for_many(query, query_params \\ [], opts \\ []), to: Datastore

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

  @spec set_datastore_context(pid() | Ecto.Repo.t() | Ecto.Adapter.adapter_meta()) ::
          atom() | pid()
  defdelegate set_datastore_context(context), to: Datastore

  @spec current_datastore_context :: atom() | pid()
  defdelegate current_datastore_context(), to: Datastore

  @spec transaction(fun | Ecto.Multi.t(), keyword) :: {:error, MsbmsSystError.t()} | {:ok, any}
  defdelegate transaction(job, opts \\ []), to: Datastore, as: :ecto_transaction

  defdelegate record_count(queryable, opts), to: Datastore, as: :record_count

  defdelegate aggregate(queryable, aggregate, field, opts \\ []), to: Datastore

  @spec all(Ecto.Queryable.t(), Keyword.t()) :: list(Ecto.Schema.t())
  defdelegate all(queryable, opts \\ []), to: Datastore

  defdelegate delete(struct_or_changeset, opts \\ []),
    to: Datastore

  defdelegate delete!(struct_or_changeset, opts \\ []),
    to: Datastore

  defdelegate delete_all(queryable, opts \\ []), to: Datastore
  defdelegate exists?(queryable, opts \\ []), to: Datastore
  defdelegate get(queryable, id, opts \\ []), to: Datastore
  defdelegate get!(queryable, id, opts \\ []), to: Datastore

  defdelegate get_by(queryable, clauses, opts \\ []),
    to: Datastore

  defdelegate get_by!(queryable, clauses, opts \\ []),
    to: Datastore

  defdelegate in_transaction?, to: Datastore

  defdelegate insert(struct_or_changeset, opts \\ []),
    to: Datastore

  defdelegate insert!(struct_or_changeset, opts \\ []),
    to: Datastore

  defdelegate insert_all(schema_or_source, entries_or_query, opts \\ []),
    to: Datastore

  defdelegate insert_or_update(changeset, opts \\ []),
    to: Datastore

  defdelegate insert_or_update!(changeset, opts \\ []),
    to: Datastore

  defdelegate load(module_or_map, data), to: Datastore
  defdelegate one(queryable, opts \\ []), to: Datastore
  defdelegate one!(queryable, opts \\ []), to: Datastore

  defdelegate preload(structs_or_struct_or_nil, preloads, opts \\ []),
    to: Datastore

  defdelegate prepare_query(operation, query, opts \\ []),
    to: Datastore

  defdelegate reload(struct_or_structs, opts \\ []), to: Datastore

  defdelegate reload!(struct_or_structs, opts \\ []),
    to: Datastore

  defdelegate rollback(value), to: Datastore
  defdelegate stream(queryable, opts \\ []), to: Datastore
  defdelegate update(changeset, opts \\ []), to: Datastore
  defdelegate update!(changeset, opts \\ []), to: Datastore

  defdelegate update_all(queryable, updates, opts \\ []),
    to: Datastore
end
