# Source File: dba.ex
# Location:    musebms/components/system/mscmp_syst_db/lib/impl/dba.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystDb.Impl.Dba do
  @moduledoc false

  import Msutils.Guards

  alias MscmpSystDb.Impl.Privileged
  alias MscmpSystDb.Runtime.Datastore
  alias MscmpSystDb.Types
  alias MscmpSystDb.Types.{ContextState, DatastoreContext, DatastoreOptions, DbServer}

  require Logger

  ######
  #
  # DBA actions are those which require highly privileged access to the database
  # server (CREATEDB).  DBA actions are executed while connected to postgres
  # database using designated DBA database role (see @dba_role_name).
  #
  # DBA level database connections should only be opened while work requiring
  # DBA access is required.  While a single DBA connection should be used across
  # multiple calls, a DBA connection should not be left waiting for work that
  # may or may not come.  Once all known work is completed, the DBA connection
  # should be stopped.
  #
  ######

  @dba_role_name "ms_syst_privileged"
  @dba_database_name "postgres"
  @dba_application_name "MscmpSystDb System DBA Access"

  ##############################################################################
  #
  # get_datastore_state
  #
  #

  @spec get_datastore_state(DatastoreOptions.t(), Keyword.t()) ::
          {:ok, Types.database_state_values(), list(ContextState.t())}
          | {:error, reason :: term()}
  def get_datastore_state(datastore_options, opts) do
    starting_datastore_context = Datastore.current_datastore_context()

    result =
      with {:ok, dba_pid} <- start_dba_connection(datastore_options),
           {:ok, _} <- Datastore.put_datastore_context(dba_pid),
           {:ok, database_state} <- get_database_state(datastore_options),
           {:ok, context_states} <-
             get_context_states(datastore_options.contexts, opts[:context_registry]),
           :ok <- stop_dba_connection(opts[:db_shutdown_timeout]) do
        {:ok, database_state, context_states}
      else
        error ->
          {:error, {:datastore_state_error, error}}
      end

    {:ok, _} = Datastore.put_datastore_context(starting_datastore_context)

    result
  end

  ##############################################################################
  #
  # create_datastore
  #

  @spec create_datastore(DatastoreOptions.t(), Keyword.t()) ::
          {:ok, {Types.database_state_values(), list(ContextState.t())}}
          | {:error, reason :: term()}

  def create_datastore(datastore_options, opts) do
    starting_datastore_context = Datastore.current_datastore_context()

    result =
      with {:ok, dba_pid} <- start_dba_connection(datastore_options),
           {:ok, _} <- Datastore.put_datastore_context(dba_pid),
           {:ok, _} <- create_contexts(datastore_options.contexts),
           :ok <- create_database(datastore_options),
           {:ok, context_states} <-
             apply_db_connect_privs(datastore_options.contexts, datastore_options.database_name),
           :ok <- stop_dba_connection(opts[:db_shutdown_timeout]),
           :ok <- Privileged.initialize_datastore(datastore_options, opts) do
        {:ok, {:ready, context_states}}
      else
        error ->
          {:error, {:create_datastore_error, error}}
      end

    {:ok, _} = Datastore.put_datastore_context(starting_datastore_context)

    result
  end

  ##############################################################################
  #
  # drop_datastore
  #
  #

  @spec drop_datastore(DatastoreOptions.t(), Keyword.t()) :: :ok
  def drop_datastore(datastore_options, opts) do
    starting_datastore_context = Datastore.current_datastore_context()

    result =
      with {:ok, dba_pid} <- start_dba_connection(datastore_options),
           {:ok, _} <- Datastore.put_datastore_context(dba_pid),
           :ok <-
             revoke_db_connect_privs(datastore_options.contexts, datastore_options.database_name),
           :ok <- drop_database(datastore_options),
           :ok <- drop_contexts(datastore_options.contexts) do
        stop_dba_connection(opts[:db_shutdown_timeout])
      else
        error ->
          stop_dba_connection(opts[:db_shutdown_timeout])
          raise "Failed to drop Datastore: #{inspect(error)}."
      end

    {:ok, _} = Datastore.put_datastore_context(starting_datastore_context)

    result
  end

  ##############################################################################
  #
  # get_datastore_context_states
  #
  #

  @spec get_datastore_context_states(DatastoreOptions.t(), Keyword.t()) ::
          {:ok, nonempty_list(ContextState.t())} | {:error, term()}
  def get_datastore_context_states(datastore_options, opts) do
    starting_datastore_context = Datastore.current_datastore_context()

    result =
      with {:ok, dba_pid} <- start_dba_connection(datastore_options),
           {:ok, _} <- Datastore.put_datastore_context(dba_pid),
           {:ok, state_result} <-
             get_context_states(datastore_options.contexts, opts[:context_registry]),
           :ok <- stop_dba_connection(opts[:db_shutdown_timeout]) do
        {:ok, state_result}
      end

    {:ok, _} = Datastore.put_datastore_context(starting_datastore_context)

    result
  end

  ##############################################################################
  #
  # create_datastore_contexts
  #
  #

  @spec create_datastore_contexts(
          DatastoreOptions.t(),
          nonempty_list(DatastoreContext.t())
        ) :: {:ok, nonempty_list(ContextState.t())} | {:error, term()}
  @spec create_datastore_contexts(
          DatastoreOptions.t(),
          nonempty_list(DatastoreContext.t()),
          Keyword.t()
        ) :: {:ok, nonempty_list(ContextState.t())} | {:error, term()}
  def create_datastore_contexts(datastore_options, new_contexts, opts \\ []) do
    starting_datastore_context = Datastore.current_datastore_context()

    result =
      with {:ok, dba_pid} <- start_dba_connection(datastore_options),
           {:ok, _} <- Datastore.put_datastore_context(dba_pid),
           {:ok, _} <- create_contexts(new_contexts),
           {:ok, context_states} <-
             apply_db_connect_privs(new_contexts, datastore_options.database_name),
           :ok <- stop_dba_connection(opts[:db_shutdown_timeout]) do
        {:ok, context_states}
      end

    {:ok, _} = Datastore.put_datastore_context(starting_datastore_context)

    result
  end

  ##############################################################################
  #
  # drop_datastore_contexts
  #
  #

  @spec drop_datastore_contexts(
          DatastoreOptions.t(),
          nonempty_list(DatastoreContext.t())
        ) :: :ok | {:error, term()}
  @spec drop_datastore_contexts(
          DatastoreOptions.t(),
          nonempty_list(DatastoreContext.t()),
          Keyword.t()
        ) :: :ok | {:error, term()}
  def drop_datastore_contexts(datastore_options, delete_contexts, opts \\ []) do
    starting_datastore_context = Datastore.current_datastore_context()

    result =
      with {:ok, dba_pid} <- start_dba_connection(datastore_options),
           {:ok, _} <- Datastore.put_datastore_context(dba_pid),
           :ok <- revoke_db_connect_privs(delete_contexts, datastore_options.database_name),
           :ok <- drop_contexts(delete_contexts) do
        stop_dba_connection(opts[:db_shutdown_timeout])
      end

    {:ok, _} = Datastore.put_datastore_context(starting_datastore_context)

    result
  end

  defp get_dba_connection_options(db_server) when is_map(db_server) do
    %DatastoreOptions{
      database_name: @dba_database_name,
      contexts: [
        %DatastoreContext{
          context_name: nil,
          description: @dba_application_name,
          database_role: @dba_role_name,
          database_password: db_server.dbadmin_password,
          starting_pool_size: db_server.dbadmin_pool_size,
          start_context: true
        }
      ],
      db_server: %DbServer{
        server_name: db_server.server_name,
        start_server_instances: true,
        server_pools: [],
        db_host: db_server.db_host,
        db_port: db_server.db_port,
        db_show_sensitive: db_server.db_show_sensitive,
        db_max_instances: db_server.db_max_instances,
        server_salt: db_server.server_salt,
        dbadmin_password: db_server.dbadmin_password,
        dbadmin_pool_size: db_server.dbadmin_pool_size
      }
    }
  end

  defp start_dba_connection(datastore_options) do
    dba_options = get_dba_connection_options(datastore_options.db_server)
    dba_context = hd(dba_options.contexts)

    app_qry = "SET application_name = '#{dba_context.description}';"

    with {:ok, dba_pid} <- Datastore.start_datastore_context(dba_options, dba_context, []),
         {:ok, _} <- Datastore.put_datastore_context(dba_pid),
         :ok <- Datastore.query_for_none(app_qry, [], []) do
      {:ok, dba_pid}
    end
  end

  defp stop_dba_connection(db_shutdown_timeout) do
    Datastore.stop_datastore_context(Datastore.current_datastore_context(),
      db_shutdown_timeout: db_shutdown_timeout
    )
  end

  defp get_database_state(%DatastoreOptions{database_name: database_name})
       when is_binary(database_name) do
    result =
      Datastore.query_for_value(
        "SELECT exists(SELECT true FROM pg_database WHERE datname = $1) AS is_database_found;",
        [String.downcase(database_name)],
        []
      )

    case result do
      {:ok, nil} -> {:ok, :not_found}
      {:ok, _} -> {:ok, :ready}
      {:error, _} = error -> error
    end
  end

  defp get_context_states(datastore_contexts, context_registry) do
    query_db_roles_exist(datastore_contexts)
    |> parse_db_roles_exist_results()
    |> convert_roles_to_contexts(datastore_contexts)
    |> check_contexts_started(context_registry)
  end

  defp query_db_roles_exist(context_states) do
    database_roles =
      context_states
      |> Enum.map(& &1.database_role)

    Datastore.query(
      """
      SELECT
         database_role
        ,database_role = coalesce(rolname, '***role not found***') AS database_role_exists
      FROM unnest($1::text[]) database_role
        LEFT JOIN pg_catalog.pg_roles pr ON pr.rolname = database_role
      """,
      [database_roles]
    )
  end

  defp parse_db_roles_exist_results({:ok, %{num_rows: num_rows, rows: rows}}) when num_rows > 0 do
    state_func = fn [role_name, exists | _] ->
      state = if exists, do: :ready, else: :not_found
      %{database_role: role_name, state: state}
    end

    result_list =
      rows
      |> Enum.map(&state_func.(&1))

    result_list
  end

  defp parse_db_roles_exist_results(error), do: {:error, error}

  defp convert_roles_to_contexts(role_states, datastore_contexts) do
    map_func = fn role_state ->
      context =
        datastore_contexts
        |> Enum.find(&(&1.database_role == role_state.database_role))

      %ContextState{context: context.context_name, state: role_state.state}
    end

    role_states
    |> Enum.map(&map_func.(&1))
  end

  defp check_contexts_started(curr_context_states, context_registry)
       when is_list(curr_context_states) do
    map_func = fn
      context_state = %ContextState{state: :not_found} ->
        context_state

      %ContextState{context: context_name, state: :ready} ->
        resolved_context = Datastore.lookup_context_pid(context_registry, context_name)

        resolved_pid =
          case resolved_context do
            {:ok, pid_or_atom} when is_pid(pid_or_atom) or is_reg_atom(pid_or_atom) ->
              pid_or_atom

            {:ok, nil} ->
              nil

            {:error, {:not_found, _}} ->
              nil
          end

        state_running =
          Ecto.Repo.all_running()
          |> Enum.member?(resolved_context)

        case state_running do
          true -> %ContextState{context: context_name, pid: resolved_pid, state: :started}
          false -> %ContextState{context: context_name, state: :ready}
        end
    end

    result =
      curr_context_states
      |> Enum.filter(&(&1.context != nil))
      |> Enum.map(&map_func.(&1))

    {:ok, result}
  end

  defp create_contexts(contexts) do
    map_func = fn context ->
      case create_database_role(context) do
        {:ok, _} ->
          %ContextState{context: context.context_name, state: :not_ready}

        error ->
          raise "Failed to create database role for context '#{context.context_name}': #{inspect(error)}."
      end
    end

    try do
      Datastore.transaction(fn -> contexts |> Enum.map(&map_func.(&1)) end)
    catch
      error_kind, error_value ->
        {:error, {:database_transaction_error, error_kind, error_value}}
    end
  end

  defp create_database_role(%DatastoreContext{
         login_context: true,
         database_role: role_name,
         database_password: password,
         description: role_comment
       }) do
    Datastore.query(
      "SELECT ms_syst.create_login_role(p_role_name => $1, p_credential => $2, p_comment => $3);",
      [role_name, password, role_comment]
    )
  end

  defp create_database_role(%DatastoreContext{
         login_context: false,
         database_role: role_name,
         description: role_comment
       }) do
    Datastore.query(
      "SELECT ms_syst.create_nonlogin_role(p_role_name => $1, p_comment => $2);",
      [role_name, role_comment]
    )
  end

  defp create_database(datastore_options) do
    database_owner = Enum.find(datastore_options.contexts, &(&1.database_owner_context == true))

    create_query =
      ~s(CREATE DATABASE #{datastore_options.database_name} OWNER #{database_owner.database_role};)

    revoke_query = ~s(REVOKE ALL ON DATABASE #{datastore_options.database_name} FROM public;)

    with :ok <- Datastore.query_for_none(create_query, [], []) do
      Datastore.query_for_none(revoke_query, [], [])
    end
  end

  defp apply_db_connect_privs(contexts, database_name) do
    map_func = fn context ->
      case maybe_apply_context_connect_priv(context, database_name) do
        :ok ->
          %ContextState{context: context.context_name, state: :ready}

        error ->
          raise "Failed to apply database connect privileges for context '#{context.context_name}': #{inspect(error)}."
      end
    end

    try do
      Datastore.transaction(fn -> contexts |> Enum.map(&map_func.(&1)) end)
    catch
      error_kind, error_value ->
        {:error, {:database_transaction_error, error_kind, error_value}}
    end
  end

  defp maybe_apply_context_connect_priv(
         %DatastoreContext{login_context: true, database_role: role_name},
         database_name
       ) do
    ~s(GRANT CONNECT ON DATABASE #{database_name} TO #{role_name};)
    |> Datastore.query_for_none([], [])
  end

  defp maybe_apply_context_connect_priv(%DatastoreContext{login_context: false}, _database_name),
    do: :ok

  defp drop_database(datastore_options) do
    database_owner = Enum.find(datastore_options.contexts, &(&1.database_owner_context == true))

    with {:ok, _} <- Datastore.query("SET ROLE \"#{database_owner.database_role}\";"),
         {:ok, _} <-
           Datastore.query("DROP DATABASE IF EXISTS \"#{datastore_options.database_name}\";"),
         {:ok, _} <- Datastore.query("RESET ROLE;") do
      :ok
    end
  end

  defp drop_contexts(contexts) do
    each_func = fn context ->
      context
      |> drop_database_role()
      |> parse_drop_database_role_result()
    end

    case Datastore.transaction(fn -> contexts |> Enum.each(&each_func.(&1)) end) do
      {:ok, _} -> :ok
      error -> {:error, {:database_transaction_error, error}}
    end
  end

  defp drop_database_role(%DatastoreContext{database_role: role_name}) do
    Datastore.query("SELECT ms_syst.drop_role(p_role_name => $1);", [role_name])
  end

  defp parse_drop_database_role_result({:ok, _database_result}), do: :ok

  defp parse_drop_database_role_result({:error, _} = error), do: error

  defp revoke_db_connect_privs(contexts, database_name) do
    each_func = fn context ->
      case maybe_revoke_context_connect_priv(context, database_name) do
        :ok ->
          :ok

        error ->
          raise "Failed to revoke database connect privileges for context '#{context.context_name}': #{inspect(error)}."
      end
    end

    case Datastore.transaction(fn -> contexts |> Enum.each(&each_func.(&1)) end) do
      {:ok, _} -> :ok
      error -> {:error, {:database_transaction_error, error}}
    end
  end

  defp maybe_revoke_context_connect_priv(
         %DatastoreContext{login_context: true, database_role: role_name},
         database_name
       ) do
    ~s(REVOKE CONNECT ON DATABASE #{database_name} FROM #{role_name};)
    |> Datastore.query_for_none([], [])
  end

  defp maybe_revoke_context_connect_priv(%DatastoreContext{login_context: false}, _database_name),
    do: :ok
end
