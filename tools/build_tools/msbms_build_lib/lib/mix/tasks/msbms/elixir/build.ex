# Source File: build.ex
# Location:    musebms/tools/build_tools/msbms_build_lib/lib/mix/tasks/msbms/elixir/build.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule Mix.Tasks.Msbms.Elixir.Build do
  @shortdoc "Builds Elixir components and database migrations."

  @moduledoc """
  Builds Elixir components and database migrations for MSBMS projects.

  This task allows you to build:
  - Elixir components (compiles code and refreshes Dialyzer PLT files)
  - Database migrations

  It calls functions from `MsbmsBuildLib` to perform the actual operations.

  ## Command line options

    * `--elixir` - Builds Elixir components.
    * `--db-migrations` - Builds database migrations.
    * `--all` - Builds all of the above.
    * `--elixir-env ENV` - Specifies the Elixir environment (e.g., dev, test, prod).
      Defaults to "dev".
    * `--base-dir PATH` - Specifies the base directory of the MSBMS project.
      Defaults to the current working directory.
    * `-c NAME`, `--component NAME` - Specifies a component to operate on.
      Can be provided multiple times.
    * `--component-file PATH` - Specifies a file containing component names
      (one per line, # for comments). Can be combined with `-c` options.
    * `--log-level LEVEL` - Sets the logging level (e.g., debug, info, warn, error).
      Defaults to "info".

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

  ## Examples

      mix msbms.elixir.build --elixir
      mix msbms.elixir.build --all --elixir-env prod
      mix msbms.elixir.build --db-migrations -c my_app1 -c my_app2
      mix msbms.elixir.build --elixir --base-dir /path/to/project
      mix msbms.elixir.build --all --component-file .ci/group-1.txt
      mix msbms.elixir.build --elixir --component-file .ci/group-1.txt -c extra_component

  At least one of `--elixir`, `--db-migrations`, or `--all` must be specified.
  """

  use Mix.Task

  @options [
    elixir: :boolean,
    db_migrations: :boolean,
    all: :boolean,
    elixir_env: :string,
    base_dir: :string,
    component: :keep,
    component_file: :string,
    log_level: :string
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
    elixir_env = Keyword.get(opts, :elixir_env, "dev")

    do_all = Keyword.get(opts, :all, false)
    do_elixir = do_all or Keyword.get(opts, :elixir, false)
    do_db_migrations = do_all or Keyword.get(opts, :db_migrations, false)

    if not (do_elixir or do_db_migrations) do
      Mix.raise(
        "No action specified. Please use --elixir, --db-migrations, or --all. " <>
          "Run 'mix help elixir.build' for more information."
      )
    end

    case resolve_components(base_dir, components, opts) do
      {:ok, final_components} ->
        if do_elixir, do: do_build_elixir_action(base_dir, final_components, elixir_env)
        if do_db_migrations, do: do_build_db_migrations_action(base_dir, final_components)

      {:error, reason} ->
        Mix.raise("Build failed: #{reason}")
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

  defp do_build_elixir_action(base_dir, components, elixir_env) do
    handle_build_action(
      "Elixir components",
      base_dir,
      components,
      fn base_dir, components -> MsbmsBuildLib.build_elixir(base_dir, components, elixir_env) end
    )
  end

  defp do_build_db_migrations_action(base_dir, components) do
    handle_build_action(
      "database migrations",
      base_dir,
      components,
      &MsbmsBuildLib.build_migrations/2
    )
  end

  defp handle_build_action(item_name, base_dir, components, func) do
    Mix.shell().info(
      "Building #{item_name} in '#{base_dir}' for components: #{inspect(components)}..."
    )

    case func.(base_dir, components) do
      :ok ->
        Mix.shell().info("Successfully built #{item_name}.")

      {:error, reason} ->
        Mix.raise("Failed to build #{item_name}: #{reason}")
    end
  end
end
