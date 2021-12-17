# Source File: privileged.ex
# Location:    msbms/lib/msbms/system/data/privileged.ex
# Project:     msbms
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https: //muse.systems
defmodule Msbms.System.Data.Privileged do
  alias Msbms.System.Constants
  alias Msbms.System.Data.PrivilegedDatastore
  alias Msbms.System.Data.Utils
  alias Msbms.System.Types.DatastoreOptions
  alias Msbms.System.Types.DbServer

  @spec db_roles_exist?(pid(), list()) :: boolean()
  def db_roles_exist?(db_conn_pid, db_roles) when is_pid(db_conn_pid) and is_list(db_roles) do
    PrivilegedDatastore.put_dynamic_repo(db_conn_pid)

    role_qry_result =
      PrivilegedDatastore.query(
        """
        SELECT
          bool_and(myrole = coalesce(rolname, '***role not found***')) AS all_roles_found
        FROM unnest($1::text[]) myrole
          LEFT JOIN pg_catalog.pg_roles pr ON pr.rolname = myrole
        """,
        [db_roles]
      )

    case role_qry_result do
      {:ok, %{num_rows: 1, rows: [[final_result | _] | _]}} ->
        final_result

      {:ok, %{num_rows: row_count}} when row_count != 1 ->
        raise "Unexpected result testing if database roles exist: row count != 1 (#{row_count})"

      {:error, exception} ->
        raise "Unexpected result testing if database roles exist: #{exception.postgres.code}"
    end
  end

  @spec db_role_exists?(pid(), binary()) :: boolean()
  def db_role_exists?(db_conn_pid, rolename) when is_pid(db_conn_pid) and is_binary(rolename) do
    PrivilegedDatastore.put_dynamic_repo(db_conn_pid)

    role_qry_result =
      PrivilegedDatastore.query(
        """
        SELECT exists(
          SELECT true FROM pg_roles WHERE rolname = $1
        ) AS role_found
        """,
        [String.downcase(rolename)]
      )

    case role_qry_result do
      {:ok, %{num_rows: 1, rows: [[final_result | _] | _]}} ->
        final_result

      {:ok, %{num_rows: row_count}} when row_count != 1 ->
        raise "Unexpected result testing if a database role exists: row count != 1 (#{row_count})"

      {:error, exception} ->
        raise "Unexpected result testing if a database role exists: #{exception.postgres.code}"
    end
  end

  @spec create_datastore_roles(pid(), DbServer.t(), DatastoreOptions.t()) :: {:ok} | {:error, any}
  def create_datastore_roles(
        db_conn_pid,
        %DbServer{} = dbserver,
        %DatastoreOptions{} = datastore_options
      )
      when is_pid(db_conn_pid) do
    with(
      {:ok} <- create_datastore_owner_role(db_conn_pid, datastore_options),
      {:ok} <- create_datastore_login_roles(db_conn_pid, dbserver, datastore_options)
    ) do
      {:ok}
    else
      error -> error
    end
  end

  @spec create_datastore_login_roles(pid(), DbServer.t(), DatastoreOptions.t()) ::
          {:ok} | {:error, any}
  def create_datastore_login_roles(
        db_conn_pid,
        %DbServer{} = dbserver,
        %DatastoreOptions{} = datastore_options
      )
      when is_pid(db_conn_pid) do
    Enum.reduce(datastore_options.datastores, {:ok}, fn datastore, acc ->
      with {:ok} <- acc do
        rolename = Atom.to_string(elem(datastore, 1))

        case db_role_exists?(db_conn_pid, rolename) do
          false ->
            create_db_role(
              db_conn_pid,
              rolename,
              Utils.generate_password(
                datastore_options.instance_code,
                rolename,
                dbserver.server_salt
              )
            )

          true ->
            {:ok}
        end
      end
    end)
  end

  @spec(
    create_datastore_owner_role(pid(), DatastoreOptions.t()) :: {:ok},
    {:error, any}
  )
  def create_datastore_owner_role(
        db_conn_pid,
        %DatastoreOptions{} = datastore_options
      )
      when is_pid(db_conn_pid) do
    case db_role_exists?(db_conn_pid, datastore_options.database_owner) do
      false -> create_db_role(db_conn_pid, datastore_options.database_owner, :owner)
      true -> {:ok}
    end
  end

  @spec create_db_role(pid(), binary(), binary() | :owner) :: {:ok} | {:error, binary()}
  def create_db_role(db_conn_pid, rolename, password)
      when is_pid(db_conn_pid) and is_binary(rolename) do
    PrivilegedDatastore.put_dynamic_repo(db_conn_pid)

    create_role_result =
      cond do
        is_binary(password) ->
          PrivilegedDatastore.query(
            """
            CREATE ROLE #{rolename}
              WITH NOINHERIT LOGIN IN ROLE msbms_access PASSWORD '#{password}';
            """,
            []
          )

        :owner = password ->
          with(
            {:ok, _} <-
              PrivilegedDatastore.query(
                "CREATE ROLE #{rolename} WITH NOINHERIT NOLOGIN;",
                []
              ),
            {:ok, _} <-
              PrivilegedDatastore.query(
                "GRANT #{rolename} TO #{Constants.get(:global_db_login)};",
                []
              )
          ) do
            {:ok, nil}
          end
      end

    case create_role_result do
      {:ok, _} ->
        {:ok}

      {:error, exception} ->
        {:error, "Failed to create login role #{rolename}: #{exception.postgres.code}"}
    end
  end
end
