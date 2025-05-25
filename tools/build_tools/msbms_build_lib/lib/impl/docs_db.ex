# Source File: docs_db.ex
# Location:    musebms/tools/build_tools/msbms_build_lib/lib/impl/docs_db.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MsbmsBuildLib.Impl.DocsDb do
  @moduledoc false

  alias MsbmsBuildLib.Impl.Common
  alias MsbmsBuildLib.Types

  require Logger

  ##############################################################################
  #
  # build_docs_db
  #
  #

  @spec build_docs_db(Path.t(), Types.components(), Keyword.t()) ::
          :ok | {:error, message :: String.t()}
  def build_docs_db(base_dir, components, db_opts) do
    Logger.notice("==msbms_build_lib==::docs_db::build_docs_db::START")

    # Validate required database options
    with {:ok, validated_opts} <- validate_db_opts(db_opts),
         {:ok, component_paths} <- Common.resolve_component_paths(:db, base_dir, components) do
      db_docs_path = Path.join(base_dir, Common.db_docs_root())
      # Ensure documentation directory exists
      File.mkdir_p!(db_docs_path)

      db_source_root = Path.join(base_dir, "database")

      result =
        process_db_docs(component_paths, db_docs_path, db_source_root, base_dir, validated_opts)

      case result do
        :ok ->
          Logger.notice("==msbms_build_lib==::docs_db::build_docs_db::DONE")
          :ok

        {:error, error_message} when is_binary(error_message) ->
          Logger.error("==msbms_build_lib==::docs_db::build_docs_db::FAILED")
          {:error, error_message}

        error ->
          Logger.error("==msbms_build_lib==::docs_db::build_docs_db::FAILED")

          error_message =
            case error do
              {:error, msg} when is_binary(msg) -> msg
              {:error, other} -> "Database documentation build failed: #{inspect(other)}"
              other -> "Database documentation build failed: #{inspect(other)}"
            end

          {:error, error_message}
      end
    else
      {:error, error_message} ->
        Logger.error("==msbms_build_lib==::docs_db::build_docs_db::FAILED")
        {:error, error_message}
    end
  end

  defp validate_db_opts(opts) do
    case Keyword.get(opts, :user) do
      nil -> {:error, "Database user is required"}
      user when is_binary(user) -> {:ok, opts}
      _ -> {:error, "Invalid database user format"}
    end
  end

  defp process_db_docs(component_paths, db_docs_path, db_source_root, base_dir, db_opts) do
    Enum.reduce_while(component_paths, :ok, fn component_path, _acc ->
      case process_single_component(
             component_path,
             db_docs_path,
             db_source_root,
             base_dir,
             db_opts
           ) do
        :ok -> {:cont, :ok}
        error -> {:halt, error}
      end
    end)
  end

  defp process_single_component(component_path, db_docs_path, db_source_root, base_dir, db_opts) do
    component_name = Path.basename(component_path)

    with {:ok, component_docs_path} <-
           prepare_component(component_name, db_docs_path, db_source_root),
         # Get corresponding Elixir component path
         elixir_component_path <- get_elixir_component_path(base_dir, component_name),
         :ok <-
           execute_db_operations(
             component_name,
             # Use Elixir component path instead
             elixir_component_path,
             component_docs_path,
             db_source_root,
             base_dir,
             db_opts
           ) do
      Logger.info("::#{component_name}::building DB docs: DONE")
      :ok
    else
      :skip -> :ok
      error -> error
    end
  end

  defp prepare_component(component_name, db_docs_path, db_source_root) do
    component_buildplan_name = "buildplans.#{component_name}_db_docs.toml"
    component_buildplan_path = Path.join(db_source_root, component_buildplan_name)

    # Check if buildplan exists
    if File.exists?(component_buildplan_path) do
      Logger.info("::#{component_name}::building DB docs: START")

      # Delete existing documentation if it exists
      component_docs_path = Path.join(db_docs_path, component_name)
      _ = if File.dir?(component_docs_path), do: File.rm_rf!(component_docs_path)

      {:ok, component_docs_path}
    else
      Logger.info("::#{component_name}::building DB docs: SKIPPED")

      :skip
    end
  end

  defp execute_db_operations(
         component_name,
         component_path,
         component_docs_path,
         db_source_root,
         base_dir,
         db_opts
       ) do
    current_dir = File.cwd!()

    try do
      File.cd!(component_path)

      with :ok <- build_component_db(component_name, db_source_root),
           :ok <- generate_schema_docs(component_name, component_docs_path, base_dir, db_opts) do
        case drop_component_db(component_name) do
          :ok -> :ok
          error -> error
        end
      end
    rescue
      e ->
        Logger.warning("::#{component_name}::building DB docs: FAILED")
        {:error, Exception.message(e)}
    after
      File.cd!(current_dir)
    end
  end

  defp build_component_db(component_name, db_source_root) do
    {output, status} =
      System.cmd(
        "mix",
        [
          "loaddb",
          "--build",
          "--clean",
          "--type",
          "#{component_name}_db_docs",
          "--db-name",
          component_name,
          "--source",
          db_source_root
        ],
        stderr_to_stdout: true
      )

    Logger.debug(output)

    if status == 0 do
      :ok
    else
      Logger.warning("::#{component_name}::loading DB docs database: FAILED")
      {:error, "Error loading DB docs database for #{component_name}"}
    end
  end

  defp generate_schema_docs(component_name, component_docs_path, base_dir, db_opts) do
    schemaspy_jar =
      Path.join([base_dir, "tools", "build_tools", "schemaspy", "schemaspy-6.2.4.jar"])

    postgresql_jar =
      Path.join([
        base_dir,
        "tools",
        "build_tools",
        "schemaspy",
        "postgresql-42.7.1.jar"
      ])

    {output, status} =
      System.cmd(
        "java",
        [
          "-jar",
          schemaspy_jar,
          "-t",
          "pgsql11",
          "-dp",
          postgresql_jar,
          "-db",
          component_name,
          "-host",
          Keyword.get(db_opts, :host, "127.0.0.1"),
          "-port",
          Integer.to_string(Keyword.get(db_opts, :port, 5432)),
          "-all",
          "-schemaSpec",
          "ms_.+",
          "-norows",
          "-imageformat",
          "svg",
          "-nopages",
          "-noimplied",
          "-u",
          Keyword.fetch!(db_opts, :user),
          "-o",
          component_docs_path
        ],
        stderr_to_stdout: true
      )

    Logger.debug(output)

    if status == 0 do
      :ok
    else
      Logger.warning("::#{component_name}::generating schema docs: FAILED")
      {:error, "Error generating schema docs for #{component_name}"}
    end
  end

  defp drop_component_db(component_name) do
    {output, status} =
      System.cmd(
        "mix",
        [
          "dropdb",
          "--clean",
          "--bypass-stop-datastore",
          "--type",
          "#{component_name}_db_docs",
          "--db-name",
          component_name
        ],
        stderr_to_stdout: true
      )

    Logger.debug(output)

    if status == 0 do
      :ok
    else
      Logger.warning("::#{component_name}::dropping database: FAILED")
      {:error, "Error dropping database for #{component_name}"}
    end
  end

  # Get corresponding Elixir component path for a database component
  defp get_elixir_component_path(base_dir, component_name) do
    Path.join([
      base_dir,
      "app_server",
      "components",
      get_component_group(component_name),
      component_name
    ])
  end

  # Extract component group from component name (e.g., "system" from "mscmp_syst_enums")
  defp get_component_group(component_name) do
    case Regex.run(~r/mscmp_([a-z]{4})_/, component_name) do
      [_, group_code] ->
        case group_code do
          "syst" -> "system"
          # Add other mappings as needed
          _ -> "unknown"
        end

      _ ->
        "unknown"
    end
  end
end
