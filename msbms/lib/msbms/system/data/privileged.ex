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

  @spec db_exists?(pid(), DatastoreOptions.t()) :: boolean()
  def db_exists?(db_conn_pid, %DatastoreOptions{database_name: database_name})
      when is_pid(db_conn_pid) do
    PrivilegedDatastore.put_dynamic_repo(db_conn_pid)

    role_qry_result =
      PrivilegedDatastore.query(
        """
        SELECT exists(
          SELECT true FROM pg_database WHERE datname = $1
        ) AS database_found
        """,
        [String.downcase(database_name)]
      )

    case role_qry_result do
      {:ok, %{num_rows: 1, rows: [[final_result | _] | _]}} ->
        final_result

      {:ok, %{num_rows: row_count}} when row_count != 1 ->
        raise "Unexpected result testing if a database exists: row count != 1 (#{row_count})"

      {:error, exception} ->
        raise "Unexpected result testing if a database exists: #{exception.postgres.code}"
    end
  end

  @spec create_db(pid(), DatastoreOptions.t()) :: {:ok} | {:error, any}
  def create_db(
        db_conn_pid,
        %DatastoreOptions{
          database_name: database_name,
          database_owner: database_owner
        } = datastore_options
      )
      when is_pid(db_conn_pid) do
    PrivilegedDatastore.put_dynamic_repo(db_conn_pid)

    create_db_result =
      case db_exists?(db_conn_pid, datastore_options) do
        false ->
          PrivilegedDatastore.query("CREATE DATABASE #{database_name} OWNER #{database_owner};")

        true ->
          {:ok, nil}
      end

    case create_db_result do
      {:ok, _} ->
        {:ok}

      {:error, exception} ->
        {:error,
         "Failed to create database #{database_name} with owner #{database_owner}: #{exception.postgres.code}"}
    end
  end

  @spec get_last_applied_migration_version(pid) :: binary()
  def get_last_applied_migration_version(db_conn_pid) do
    PrivilegedDatastore.put_dynamic_repo(db_conn_pid)

    case db_migrations_table_exists?(db_conn_pid) do
      false ->
        "00.00.000.000000.000"

      true ->
        with(
          {:ok, %{num_rows: 1, rows: [[migration_version | _] | _]}} <-
            PrivilegedDatastore.query("""
            SELECT
              coalesce(
                (SELECT max(migration_version) FROM msbms_syst_data.database_migrations),
                 '00.00.000.000000.000') AS max_migration_version;
            """)
        ) do
          migration_version
        end
    end
  end

  @spec db_migrations_table_exists?(pid()) :: boolean()
  def db_migrations_table_exists?(db_conn_pid) when is_pid(db_conn_pid) do
    PrivilegedDatastore.put_dynamic_repo(db_conn_pid)

    migrations_table_result =
      PrivilegedDatastore.query(
        """
        SELECT exists(
          SELECT true
          FROM   pg_tables
          WHERE  schemaname = 'msbms_syst_data' AND
                 tablename = 'database_migrations'
        ) AS migrations_found
        """,
        []
      )

    case migrations_table_result do
      {:ok, %{num_rows: 1, rows: [[final_result | _] | _]}} ->
        final_result

      {:ok, %{num_rows: row_count}} when row_count != 1 ->
        raise "Unexpected result testing if the migrations table exists: row count != 1 (#{row_count})"

      {:error, exception} ->
        raise "Unexpected result testing if the migrations table exists: #{exception.postgres.code}"
    end
  end

  @spec get_available_migrations(:global | :instance | binary()) :: list() | {:error, atom()}
  def get_available_migrations(:global) do
    get_available_migrations("global")
  end

  def get_available_migrations(:instance) do
    get_available_migrations("instance")
  end

  def get_available_migrations(target_type) when is_binary(target_type) do
    with(
      migrations_path <- Path.join(["priv", "database", target_type]),
      {:ok, migrations_list} <- File.ls(migrations_path)
    ) do
      Enum.sort(migrations_list)
      |> Enum.map(fn migration ->
        {:ok, migration_data} = Utils.deconstruct_migration_filename(migration)
        migration_data
      end)
    end
  end

  @spec apply_migration(pid, Msbms.System.Types.DatastoreOptions.t(), %{
          :migration_version => binary(),
          :migration_path => binary(),
          :release => integer(),
          :version => integer(),
          :update => integer(),
          :sponsor => integer(),
          :sponsor_modification => integer()
        }) :: {:ok, binary()} | {:error, any()}
  def apply_migration(
        db_conn_pid,
        %DatastoreOptions{database_owner: database_owner} = datastore_options,
        migration
      )
      when is_pid(db_conn_pid) and is_map(migration) do
    PrivilegedDatastore.put_dynamic_repo(db_conn_pid)

    migration_bindings = [
      msbms_owner: database_owner,
      msbms_appusr: datastore_options.datastores |> Keyword.get(:appusr) |> Atom.to_string(),
      msbms_appadm: datastore_options.datastores |> Keyword.get(:appadm) |> Atom.to_string(),
      msbms_apiusr: datastore_options.datastores |> Keyword.get(:apiusr) |> Atom.to_string(),
      msbms_apiadm: datastore_options.datastores |> Keyword.get(:apiadm) |> Atom.to_string(),
      msbms_migration_version: migration.migration_version
    ]

    migration_text = EEx.eval_file(migration.migration_path, migration_bindings)

    PrivilegedDatastore.transaction(fn ->
      PrivilegedDatastore.query(migration_text)

      migration_table_result =
        PrivilegedDatastore.query(
          """
          INSERT INTO msbms_syst_data.database_migrations
            (release, version, update, sponsor, sponsor_modification, migration_version)
          VALUES
            ($1, $2, $3, $4, $5, $6)
          RETURNING id;
          """,
          [
            migration.release,
            migration.version,
            migration.update,
            migration.sponsor,
            migration.sponsor_modification,
            migration.migration_version
          ]
        )

      {:ok, %{num_rows: 1, rows: [[migration_id | _] | _]}} = migration_table_result

      {:ok, migration_id}
    end)
  end

  @spec apply_outstanding_migrations(
          pid,
          Msbms.System.Types.DatastoreOptions.t(),
          list()
        ) :: {:ok} | {:error, any()}
  def apply_outstanding_migrations(
        db_conn_pid,
        %DatastoreOptions{} = datastore_options,
        migrations
      )
      when is_pid(db_conn_pid) and is_list(migrations) do
    PrivilegedDatastore.put_dynamic_repo(db_conn_pid)

    PrivilegedDatastore.query("SET ROLE #{datastore_options.database_owner};")

    apply_result =
      Enum.reduce(migrations, {:ok}, fn migration, acc ->
        cond do
          :error == elem(acc, 0) ->
            acc

          migration.migration_version > get_last_applied_migration_version(db_conn_pid) ->
            apply_migration(db_conn_pid, datastore_options, migration)

          true ->
            {:ok}
        end
      end)

    PrivilegedDatastore.query("RESET ROLE;")

    case apply_result do
      {:ok, _} -> {:ok}
      _ -> apply_result
    end
  end
end
