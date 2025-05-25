# Source File: docs.ex
# Location:    musebms/tools/build_tools/msbms_build_lib/lib/mix/tasks/msbms/db/docs.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule Mix.Tasks.Msbms.Db.Docs do
  @shortdoc "Builds database documentation."

  @moduledoc """
  Builds database documentation for MSBMS components.

  This task generates documentation from the database schema and requires
  an active database connection. The database role used must be a member
  of the `ms_syst_documentation` group role prior to using this task.

  It calls functions from `MsbmsBuildLib` to perform the actual operations.

  ## Command line options

    * `--base-dir PATH` - Specifies the base directory of the MSBMS project.
      Defaults to the current working directory.
    * `-c NAME`, `--component NAME` - Specifies a component to operate on.
      Can be provided multiple times.
    * `--component-file PATH` - Specifies a file containing component names
      (one per line, # for comments). Can be combined with `-c` options.
    * `--log-level LEVEL` - Sets the logging level (e.g., debug, info, warn, error).
      Defaults to "info".
    * `--db-host HOST` - Database host (default: localhost).
    * `--db-port PORT` - Database port (default: 5432).
    * `--db-user USER` - Database user (required for DB documentation).
    * `--db-name DATABASE` - Database name (default: postgres).

  ## Component File Format

  Component files support:
  - One component name per line
  - Comments starting with `#` are ignored
  - Empty lines are ignored
  - Leading/trailing whitespace is trimmed

  Example component file:
      # Core components
      mssub_mcp_common
      mssub_mcp_types

      # Optional component
      ms_logger

  ## Database Credentials

  For security reasons, database passwords are not accepted as command line
  arguments. Instead, use either a correctly configured `.pgpass` file or
  environment variables to pass credentials. See the PostgreSQL documentation
  for more information on either configuration option.

  ## Examples

      mix msbms.db.docs --db-user postgres
      mix msbms.db.docs --db-host localhost --db-user myuser
      mix msbms.db.docs --base-dir /path/to/project --db-user postgres -c my_app1
      mix msbms.db.docs --db-user postgres --component-file .ci/group-1.txt
      mix msbms.db.docs --db-user postgres --component-file .ci/group-1.txt -c extra_component
  """

  use Mix.Task

  @options [
    base_dir: :string,
    component: :keep,
    component_file: :string,
    log_level: :string,
    db_host: :string,
    db_port: :integer,
    db_user: :string,
    db_name: :string
  ]

  @aliases [
    c: :component
  ]

  def run(args) do
    {opts, _parsed_args, _invalid_opts} =
      OptionParser.parse(args, strict: @options, aliases: @aliases)

    # Set log level early
    log_level_str = Keyword.get(opts, :log_level, "info")
    :ok = MsbmsBuildLib.set_log_level(String.to_atom(log_level_str))

    base_dir = Keyword.get(opts, :base_dir, File.cwd!())
    components = Keyword.get_values(opts, :component)
    db_opts = build_db_opts(opts)

    case resolve_components(base_dir, components, opts) do
      {:ok, final_components} ->
        build_db_docs_action(base_dir, final_components, db_opts)

      {:error, reason} ->
        Mix.raise("Documentation building failed: #{reason}")
    end
  end

  defp resolve_components(base_dir, cli_components, opts) do
    case Keyword.get(opts, :component_file) do
      nil ->
        {:ok, cli_components}

      file_path ->
        case MsbmsBuildLib.read_component_file(base_dir, file_path) do
          {:ok, file_components} ->
            final_components = file_components ++ cli_components

            Mix.shell().info(
              "Loaded #{length(file_components)} components from file, #{length(cli_components)} from CLI"
            )

            {:ok, final_components}

          {:error, reason} ->
            {:error, reason}
        end
    end
  end

  defp build_db_opts(opts) do
    [
      host: Keyword.get(opts, :db_host, "localhost"),
      port: Keyword.get(opts, :db_port, 5432),
      user: Keyword.get(opts, :db_user, "postgres"),
      database: Keyword.get(opts, :db_name, "postgres")
    ]
  end

  defp build_db_docs_action(base_dir, components, db_opts) do
    Mix.shell().info(
      "Building database documentation in '#{base_dir}' for components: #{inspect(components)}..."
    )

    case MsbmsBuildLib.build_docs_db(base_dir, components, db_opts) do
      :ok ->
        Mix.shell().info("Successfully built database documentation.")

      {:error, reason} ->
        Mix.raise(
          "Documentation building failed: Failed to build database documentation: #{reason}"
        )
    end
  end
end
