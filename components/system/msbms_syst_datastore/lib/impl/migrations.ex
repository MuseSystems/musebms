# Source File: migrations.ex
# Location:    components/system/msbms_syst_datastore/lib/impl/migrations.ex
# Project:     msbms
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https: //muse.systems

defmodule MsbmsSystDatastore.Impl.Migrations do
  @moduledoc false

  require Logger

  alias MsbmsSystDatastore.Runtime.Datastore

  @default_source_root_dir "database"

  @default_migrations_schema "msbms_syst_datastore"
  @default_migrations_table "migrations"
  @default_migrations_root_dir "priv/database"

  @migration_schema_sql_file "migrations_schema/migration_schema_initialization.eex.sql"

  @spec build_migrations(String.t(), Keyword.t()) ::
          {:ok, list(Path.t())} | {:error, MsbmsSystError.t()}
  def build_migrations(datastore_type, opts \\ []) do
    opts_default = [
      source_root_dir: @default_source_root_dir,
      migrations_root_dir: @default_migrations_root_dir,
      clean_migrations: false
    ]

    opts_final = Keyword.merge(opts, opts_default, fn _k, v1, _v2 -> v1 end)

    migrations_path = Path.join([opts_final[:migrations_root_dir], datastore_type])

    :ok = maybe_clean_migrations(migrations_path, opts_final[:clean_migrations])

    existing_migrations = get_existing_migrations_list(migrations_path)

    reducer_func = fn plan, acc ->
      plan
      |> maybe_create_migration(
        datastore_type,
        opts_final[:source_root_dir],
        migrations_path,
        existing_migrations
      )
      |> case do
        migration_filename when is_binary(migration_filename) -> [migration_filename | acc]
        nil -> acc
      end
    end

    newly_built_migrations =
      get_build_plans(opts_final[:source_root_dir], datastore_type)
      |> Enum.reduce([], &reducer_func.(&1, &2))

    {:ok, newly_built_migrations}
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MsbmsSystError{
          code: :file_error,
          message: "Failure building migrations.",
          cause: error
        }
      }
  end

  defp maybe_clean_migrations(dest_path, true), do: clean_migrations(dest_path)
  defp maybe_clean_migrations(_dest_path, _), do: :ok

  defp get_build_plans(source_root, datastore_type) do
    [source_root, "buildplans." <> datastore_type <> ".toml"]
    |> Path.join()
    |> File.stream!()
    |> Toml.decode_stream!()
    |> Map.get("build_plan")
  end

  defp get_existing_migrations_list(dest_path) do
    dest_path
    |> File.ls!()
  end

  defp get_migration_filename(build_plan, datastore_type) do
    datastore_type <>
      "." <>
      String.pad_leading(Integer.to_string(build_plan["release"], 36), 2, "0") <>
      "." <>
      String.pad_leading(Integer.to_string(build_plan["version"], 36), 2, "0") <>
      "." <>
      String.pad_leading(Integer.to_string(build_plan["update"], 36), 3, "0") <>
      "." <>
      String.pad_leading(Integer.to_string(build_plan["sponsor"], 36), 6, "0") <>
      "." <>
      String.pad_leading(Integer.to_string(build_plan["sponsor_modification"], 36), 3, "0") <>
      ".eex.sql"
  end

  defp maybe_create_migration(
         build_plan,
         datastore_type,
         source_root,
         dest_path,
         existing_migrations
       ) do
    migration_filename = get_migration_filename(build_plan, datastore_type)

    if Enum.member?(existing_migrations, migration_filename) do
      nil
    else
      create_migration(build_plan, source_root, Path.join([dest_path, migration_filename]))
      migration_filename
    end
  end

  defp create_migration(build_plan, source_root, migration_path) do
    target = File.open!(migration_path, [:exclusive, {:delayed_write, 1024, 20}])

    try do
      with :ok <-
             IO.binwrite(target, """
             -- Migration: #{migration_path}
             -- Built on:  #{DateTime.utc_now()}

             DO
             $MIGRATION$
             BEGIN
             """),
           :ok <-
             build_plan["load_files"]
             |> Enum.each(fn file ->
               sql = File.read!(Path.join([source_root, file]))
               IO.binwrite(target, sql)
             end),
           :ok <-
             IO.binwrite(
               target,
               """
               END;
               $MIGRATION$;
               """
             ) do
        :ok
      else
        error ->
          raise MsbmsSystError,
            code: :file_error,
            message: "Failure creating database migrations.",
            cause: error
      end
    after
      :ok = File.close(target)
    end
  end

  @spec(clean_existing_migrations(String.t(), Keyword.t()) :: :ok, {:error, MsbmsSystError.t()})
  def clean_existing_migrations(datastore_type, opts \\ []) do
    opts_default = [migrations_root_dir: @default_migrations_root_dir]
    opts_final = Keyword.merge(opts, opts_default, fn _k, v1, _v2 -> v1 end)

    :ok =
      [opts_final[:migrations_root_dir], datastore_type]
      |> Path.join()
      |> clean_migrations()
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

  defp clean_migrations(dest_path) do
    _deleted = File.rm_rf!(dest_path)
    File.mkdir_p!(dest_path)
    :ok
  end

  @spec get_datastore_version(pid() | atom(), Keyword.t()) ::
          {:ok, String.t()} | {:error, MsbmsSystError.t()}
  def get_datastore_version(priv_db_conn, opts \\ []) do
    opts_default = [
      migrations_schema: @default_migrations_schema,
      migrations_table: @default_migrations_table
    ]

    opts_final = Keyword.merge(opts, opts_default, fn _k, v1, _v2 -> v1 end)

    migration_table_exists? =
      query_table_exists(
        priv_db_conn,
        opts_final[:migrations_schema],
        opts_final[:migrations_table]
      )

    if migration_table_exists? do
      {:ok,
       query_datastore_version(
         priv_db_conn,
         opts_final[:migrations_schema],
         opts_final[:migrations_table]
       )}
    else
      {:ok, "00.00.000.000000.000"}
    end
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MsbmsSystError{
          code: :database_error,
          message: "Failure retrieving datastore version.",
          cause: error
        }
      }
  end

  defp query_table_exists(priv_db_conn, migrations_schema, migrations_table) do
    Datastore.query_for_value!(
      priv_db_conn,
      """
      SELECT exists(
        SELECT true
        FROM   pg_tables
        WHERE  schemaname = '#{migrations_schema}' AND
               tablename = '#{migrations_table}'
      ) AS migrations_found
      """
    )
  end

  defp query_datastore_version(priv_db_conn, migrations_schema, migrations_table) do
    Datastore.query_for_value!(
      priv_db_conn,
      """
      SELECT
        coalesce(
          (SELECT max(migration_version) FROM #{migrations_schema}.#{migrations_table}),
          '00.00.000.000000.000') AS max_migration_version;
      """
    )
    |> String.upcase()
  end

  defp get_available_migrations(dest_path) do
    dest_path
    |> File.ls!()
    |> Enum.sort()
  end

  @spec initialize_datastore(pid() | atom(), String.t(), Keyword.t()) ::
          :ok | {:error, MsbmsSystError.t()}
  def initialize_datastore(priv_db_conn, datastore_owner, opts \\ []) do
    opts_default = [
      migrations_schema: @default_migrations_schema,
      migrations_table: @default_migrations_table
    ]

    opts_final = Keyword.merge(opts, opts_default, fn _k, v1, _v2 -> v1 end)

    bindings = [
      msbms_owner: datastore_owner,
      migrations_schema: opts_final[:migrations_schema],
      migrations_table: opts_final[:migrations_table]
    ]

    migration_schema_sql =
      EEx.eval_file(
        Path.join([:code.priv_dir(:msbms_syst_datastore), @migration_schema_sql_file]),
        bindings
      )

    Datastore.query_for_none!(priv_db_conn, migration_schema_sql)

    :ok
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MsbmsSystError{
          code: :database_error,
          message: "Failure creating migrations management schema.",
          cause: error
        }
      }
  end

  @spec apply_outstanding_migrations(pid() | atom(), String.t(), Keyword.t(), Keyword.t()) ::
          {:error, MsbmsSystError.t()} | {:ok, list}
  def apply_outstanding_migrations(
        priv_db_conn,
        datastore_type,
        migration_bindings,
        opts \\ []
      ) do
    opts_default = [
      migrations_root_dir: @default_migrations_root_dir,
      migrations_schema: @default_migrations_schema,
      migrations_table: @default_migrations_table
    ]

    opts_final = Keyword.merge(opts, opts_default, fn _k, v1, _v2 -> v1 end)

    available_migrations =
      [opts_final[:migrations_root_dir], datastore_type]
      |> Path.join()
      |> get_available_migrations()

    {:ok, current_version} =
      get_datastore_version(
        priv_db_conn,
        migrations_schema: opts_final[:migrations_schema],
        migrations_table: opts_final[:migrations_table]
      )

    migrations_result =
      Enum.reduce(
        available_migrations,
        %{
          db_conn: priv_db_conn,
          current_version: current_version,
          migrations_root_dir: opts_final[:migrations_root_dir],
          datastore_type: datastore_type,
          migrations_schema: opts_final[:migrations_schema],
          migrations_table: opts_final[:migrations_table],
          migration_bindings: migration_bindings,
          applied_migrations: []
        },
        &maybe_apply_migration/2
      )

    {:ok, Enum.reverse(migrations_result.applied_migrations)}
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MsbmsSystError{
          code: :database_error,
          message: "Failure retrieving datastore version.",
          cause: error
        }
      }
  end

  defp maybe_apply_migration(candidate_migration_filename, migration_params) do
    candidate_metadata =
      deconstruct_migration_filename(candidate_migration_filename, migration_params)

    if candidate_metadata.migration_version > migration_params.current_version do
      {:ok, _result} =
        apply_migration(candidate_migration_filename, candidate_metadata, migration_params)

      {:ok, current_version} =
        get_datastore_version(
          migration_params.db_conn,
          migrations_schema: migration_params.migrations_schema,
          migrations_table: migration_params.migrations_table
        )

      migration_params
      |> Map.replace!(:current_version, current_version)
      |> Map.update!(:applied_migrations, &[candidate_migration_filename | &1])
    else
      migration_params
    end
  end

  defp apply_migration(candidate_migration_filename, migration_metadata, migration_params) do
    migration_sql =
      [
        migration_params.migrations_root_dir,
        migration_params.datastore_type,
        candidate_migration_filename
      ]
      |> Path.join()
      |> EEx.eval_file(migration_params.migration_bindings)

    trans_func = fn ->
      {:ok, _result} = Datastore.query(migration_sql)

      {:ok, _result} =
        Datastore.query(
          """
          INSERT INTO #{migration_params.migrations_schema}.#{migration_params.migrations_table}
            (release, version, update, sponsor, sponsor_modification, migration_version)
          VALUES
            ($1, $2, $3, $4, $5, $6)
          RETURNING id;
          """,
          [
            migration_metadata.release,
            migration_metadata.version,
            migration_metadata.update,
            migration_metadata.sponsor,
            migration_metadata.sponsor_modification,
            migration_metadata.migration_version
          ]
        )
    end

    Datastore.db_transaction(migration_params.db_conn, trans_func)
  end

  defp deconstruct_migration_filename(filename, migration_params) when is_binary(filename) do
    case Regex.run(
           ~r/^(?<type>(#{migration_params.datastore_type}))\.(?<version>..\...\....\.......\....)\.eex\.sql$/,
           filename,
           capture: ["type", "version"]
         ) do
      [type | [version | _]] ->
        %{
          migration_type: type,
          migration_version: version |> String.upcase(),
          migration_path: Path.join([migration_params.migrations_root_dir, type, filename]),
          release: String.slice(version, 0..1) |> String.to_integer(36),
          version: String.slice(version, 3..4) |> String.to_integer(36),
          update: String.slice(version, 6..8) |> String.to_integer(36),
          sponsor: String.slice(version, 10..15) |> String.to_integer(36),
          sponsor_modification: String.slice(version, 17..19) |> String.to_integer(36)
        }

      error ->
        raise MsbmsSystError,
          code: :file_error,
          message: "Failed to parse migration version information from #{filename}",
          cause: error
    end
  end
end
