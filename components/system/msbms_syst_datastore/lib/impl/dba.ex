# Source File: dba.ex
# Location:    components/system/msbms_syst_datastore/lib/impl/dba.ex
# Project:     msbms
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https: //muse.systems

defmodule MsbmsSystDatastore.Impl.Dba do
  import MsbmsSystUtils

  alias MsbmsSystDatastore.Runtime.Datastore
  alias MsbmsSystDatastore.Types

  require Logger

  @moduledoc false

  ######
  #
  # DBA actions are those which require highly privileged access to the database
  # server (CREATEDB CREATEROLE).  DBA actions are executed while connected to
  # postgres database using designated DBA database role (see @dba_role_name).
  #
  # DBA level database connections should only be opened while work requiring
  # DBA access is required.  While a single DBA connection should be used across
  # multiple calls, a DBA connection should not be left waiting for work that
  # may or may not come.  Once all known work is completed, the DBA connection
  # should be stopped.
  #
  ######

  @dba_role_name "msbms_syst_dba"
  @dba_database_name "postgres"
  @dba_application_name "MSBMS System DBA Access"

  @default_db_shutdown_timeout 60_000

  @type database_role_state :: %{database_role: String.t(), state: Types.context_state_values()}

  @spec get_datastore_state(Types.datastore_options(), Keyword.t()) ::
          {:ok, Types.database_state_values(), list(Types.context_state())}
          | {:error, MsbmsSystError.t()}
  def get_datastore_state(datastore_options, opts \\ []) do
    opts = resolve_options(opts, db_shutdown_timeout: @default_db_shutdown_timeout)

    {:ok, dba_pid} = start_dba_connection(datastore_options)

    _ = Datastore.set_datastore_context(dba_pid)

    database_state = get_database_state(datastore_options)
    context_states = get_context_states(datastore_options.contexts)

    stop_dba_connection(opts[:db_shutdown_timeout])

    {:ok, database_state, context_states}
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MsbmsSystError{
          code: :database_error,
          message: "Failure retrieving Datastore State.",
          cause: error
        }
      }
  end

  @spec create_datastore(Types.datastore_options(), Keyword.t()) ::
          {:ok, Types.database_state_values(), list(Types.context_state())}
          | {:error, MsbmsSystError.t()}
  def create_datastore(datastore_options, opts \\ []) do
    opts = resolve_options(opts, db_shutdown_timeout: @default_db_shutdown_timeout)

    {:ok, dba_pid} = start_dba_connection(datastore_options)

    _ = Datastore.set_datastore_context(dba_pid)

    context_states = create_contexts(datastore_options.contexts)

    :ok = create_database(datastore_options)

    stop_dba_connection(opts[:db_shutdown_timeout])

    {:ok, :ready, context_states}
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MsbmsSystError{
          code: :database_error,
          message: "Failure creating datastore.",
          cause: error
        }
      }
  end

  @spec drop_datastore(Types.datastore_options(), Keyword.t()) ::
          :ok | {:error, MsbmsSystError.t()}
  def drop_datastore(datastore_options, opts \\ []) do
    opts = resolve_options(opts, db_shutdown_timeout: @default_db_shutdown_timeout)

    {:ok, dba_pid} = start_dba_connection(datastore_options)

    _ = Datastore.set_datastore_context(dba_pid)

    :ok = drop_database(datastore_options)

    :ok = drop_contexts(datastore_options.contexts)

    stop_dba_connection(opts[:db_shutdown_timeout])
  catch
    error ->
      {
        :error,
        %MsbmsSystError{
          code: :database_error,
          message: "Failure dropping datastore.",
          cause: error
        }
      }
  end

  @spec get_datastore_context_states(Types.datastore_options(), Keyword.t()) ::
          {:ok, nonempty_list(Types.context_state())} | {:error, MsbmsSystError.t()}
  def get_datastore_context_states(datastore_options, opts \\ []) do
    opts = resolve_options(opts, db_shutdown_timeout: @default_db_shutdown_timeout)

    {:ok, dba_pid} = start_dba_connection(datastore_options)

    _ = Datastore.set_datastore_context(dba_pid)

    state_result = get_context_states(datastore_options.contexts)

    stop_dba_connection(opts[:db_shutdown_timeout])

    {:ok, state_result}
  catch
    error ->
      {
        :error,
        %MsbmsSystError{
          code: :database_error,
          message: "Failure dropping datastore.",
          cause: error
        }
      }
  end

  @spec create_datastore_contexts(
          Types.datastore_options(),
          nonempty_list(Types.datastore_context()),
          Keyword.t()
        ) ::
          {:ok, nonempty_list(Types.context_state())} | {:error, MsbmsSystError.t()}
  def create_datastore_contexts(datastore_options, new_contexts, opts \\ []) do
    opts = resolve_options(opts, db_shutdown_timeout: @default_db_shutdown_timeout)

    {:ok, dba_pid} = start_dba_connection(datastore_options)
    _ = Datastore.set_datastore_context(dba_pid)

    context_states = create_contexts(new_contexts)

    stop_dba_connection(opts[:db_shutdown_timeout])

    {:ok, context_states}
  catch
    error ->
      {
        :error,
        %MsbmsSystError{
          code: :database_error,
          message: "Failure dropping datastore.",
          cause: error
        }
      }
  end

  @spec drop_datastore_contexts(
          Types.datastore_options(),
          nonempty_list(Types.datastore_context()),
          Keyword.t()
        ) ::
          :ok | {:error, MsbmsSystError.t()}
  def drop_datastore_contexts(datastore_options, delete_contexts, opts \\ []) do
    opts = resolve_options(opts, db_shutdown_timeout: @default_db_shutdown_timeout)

    {:ok, dba_pid} = start_dba_connection(datastore_options)

    _ = Datastore.set_datastore_context(dba_pid)

    :ok = drop_contexts(delete_contexts)

    :ok = stop_dba_connection(opts[:db_shutdown_timeout])

    :ok
  catch
    error ->
      {
        :error,
        %MsbmsSystError{
          code: :database_error,
          message: "Failure dropping datastore.",
          cause: error
        }
      }
  end

  defp get_dba_connection_options(db_server) when is_map(db_server) do
    %{
      database_name: @dba_database_name,
      contexts: [
        %{
          id: nil,
          description: @dba_application_name,
          database_role: @dba_role_name,
          database_password: db_server.dbadmin_password,
          starting_pool_size: db_server.dbadmin_pool_size,
          start_context: true
        }
      ],
      db_server: %{
        server_name: db_server.server_name,
        start_server_instances: true,
        server_pools: [],
        db_host: db_server.db_host,
        db_port: db_server.db_port,
        db_show_sensitive: db_server.db_show_sensitive,
        db_log_level: db_server.db_log_level,
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

    case Datastore.start_datastore_context(dba_options, dba_context) do
      {:ok, dba_pid} ->
        _ = Datastore.set_datastore_context(dba_pid)
        Datastore.query_for_none!("SET application_name = '#{dba_context.description}';")

        {:ok, dba_pid}

      error ->
        {
          :error,
          %MsbmsSystError{
            code: :database_error,
            message: "Failure starting dba dataastore.",
            cause: error
          }
        }
    end
  end

  defp stop_dba_connection(db_shutdown_timeout) do
    _context_action_result =
      Datastore.stop_datastore_context(Datastore.current_datastore_context(), db_shutdown_timeout)

    :ok
  end

  defp get_database_state(%{database_name: database_name})
       when is_binary(database_name) do
    {:ok, query_result} =
      Datastore.query_for_value(
        "SELECT exists(SELECT true FROM pg_database WHERE datname = $1) AS is_database_found;",
        [String.downcase(database_name)]
      )

    if query_result, do: :ready, else: :not_found
  end

  defp get_context_states(datastore_contexts) do
    query_db_roles_exist(datastore_contexts)
    |> parse_db_roles_exist_results()
    |> convert_roles_to_contexts(datastore_contexts)
    |> check_contexts_started()
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

  defp parse_db_roles_exist_results({_result_kind, result_value}) do
    raise MsbmsSystError,
      code: :database_error,
      message: "Failed to retrieve datastore context states.",
      cause: result_value
  end

  defp convert_roles_to_contexts(role_states, datastore_contexts) do
    map_func = fn role_state ->
      context =
        datastore_contexts
        |> Enum.find(&(&1.database_role == role_state.database_role))

      %{context: context.id, state: role_state.state}
    end

    role_states
    |> Enum.map(&map_func.(&1))
  end

  defp check_contexts_started(curr_context_states) when is_list(curr_context_states) do
    map_func = fn
      context_state = %{state: :not_found} ->
        context_state

      %{context: context_id, state: :ready} ->
        state_running =
          Ecto.Repo.all_running()
          |> Enum.member?(context_id)

        case state_running do
          true -> %{context: context_id, state: :started}
          false -> %{context: context_id, state: :ready}
        end
    end

    curr_context_states
    |> Enum.filter(&(&1.context != nil))
    |> Enum.map(&map_func.(&1))
  end

  defp create_contexts(contexts) do
    map_func = fn context ->
      context
      |> create_database_role()
      |> parse_create_database_role_result()

      %{context: context.id, state: :ready}
    end

    {:ok, result} = Datastore.transaction(fn -> contexts |> Enum.map(&map_func.(&1)) end)

    result
  end

  defp create_database_role(%{
         login_context: true,
         database_role: role_name,
         database_password: password,
         description: role_comment
       }) do
    Datastore.query("""
    DO
    $ROLESCRIPT$
      BEGIN
        CREATE ROLE #{role_name}
          WITH NOINHERIT LOGIN IN ROLE msbms_access PASSWORD '#{password}';

        COMMENT ON ROLE #{role_name} IS $DOC$#{role_comment}$DOC$;
      END;
    $ROLESCRIPT$;
    """)
  end

  defp create_database_role(%{
         login_context: false,
         database_role: role_name,
         description: role_comment
       }) do
    Datastore.query("""
    DO
    $ROLESCRIPT$
      BEGIN
        CREATE ROLE #{role_name} WITH NOINHERIT NOLOGIN;

        COMMENT ON ROLE #{role_name} IS $DOC$#{role_comment}$DOC$;

        GRANT #{role_name} TO #{@dba_role_name};
      END;
    $ROLESCRIPT$;
    """)
  end

  defp parse_create_database_role_result({:ok, _database_result}), do: :ok

  defp parse_create_database_role_result({:error, reason}) do
    raise MsbmsSystError,
      code: :database_error,
      message: "Failed to create database role for context.",
      cause: reason
  end

  defp create_database(datastore_options) do
    database_owner = Enum.find(datastore_options.contexts, &(&1[:database_owner_context] == true))

    :ok =
      Datastore.query_for_none!(
        "CREATE DATABASE #{datastore_options.database_name} OWNER #{database_owner.database_role};"
      )

    :ok =
      Datastore.query_for_none!(
        "REVOKE ALL ON DATABASE #{datastore_options.database_name} FROM public;"
      )
  end

  defp drop_database(datastore_options) do
    database_owner = Enum.find(datastore_options.contexts, &(&1[:database_owner_context] == true))

    with {:ok, _} <- Datastore.query("SET ROLE #{database_owner.database_role};"),
         {:ok, _} <-
           Datastore.query("DROP DATABASE IF EXISTS #{datastore_options.database_name};"),
         {:ok, _} <- Datastore.query("RESET ROLE;") do
      :ok
    else
      {:error, exception} ->
        raise MsbmsSystError,
          code: :database_error,
          message: "Failure dropping datastore database.",
          cause: exception

      other ->
        raise MsbmsSystError,
          code: :database_error,
          message: "Failure dropping datastore database.",
          cause: other
    end
  end

  defp drop_contexts(contexts) do
    each_func = fn context ->
      context
      |> drop_database_role()
      |> parse_drop_database_role_result()
    end

    {:ok, _value} = Datastore.transaction(fn -> contexts |> Enum.each(&each_func.(&1)) end)

    :ok
  end

  defp drop_database_role(%{database_role: role_name}) do
    Datastore.query("DROP ROLE #{role_name};")
  end

  defp parse_drop_database_role_result({:ok, _database_result}), do: :ok

  defp parse_drop_database_role_result({:error, reason}) do
    raise MsbmsSystError,
      code: :database_error,
      message: "Failed to drop database role for context.",
      cause: reason
  end
end
