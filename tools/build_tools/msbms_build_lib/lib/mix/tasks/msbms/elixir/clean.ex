# Source File: clean.ex
# Location:    musebms/tools/build_tools/msbms_build_lib/lib/mix/tasks/msbms/elixir/clean.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule Mix.Tasks.Msbms.Elixir.Clean do
  @shortdoc "Cleans various Elixir-related artifacts (LS, PLT, build, deps)."

  @moduledoc """
  Cleans various Elixir-related artifacts for MSBMS components.

  This task allows you to clean:
  - Elixir Language Server (.elixir_ls) files
  - Dialyzer PLT files
  - Build artifacts (_build directory)
  - Dependency files (deps directory and mix.lock)
  - Database migration files (considered a sensitive operation)

  It calls functions from `MsbmsBuildLib` to perform the actual operations.

  ## Command line options

    * `--ls` - Cleans Elixir Language Server files.
    * `--plt` - Cleans Dialyzer PLT files.
    * `--build` - Cleans build artifacts.
    * `--deps` - Cleans dependency files.
    * `--migrations` - Removes database migration files. This is considered
      a sensitive operation when dealing with subsystems as migrations in
      those contexts aren't meant to be regularly rebuilt.
    * `--all` - Cleans all of the above Elixir-related artifacts (but NOT
      migrations, due to their sensitive nature).
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

      mix msbms.elixir.clean --ls
      mix msbms.elixir.clean --all --base-dir /path/to/project
      mix msbms.elixir.clean --plt --build -c my_app1 -c my_app2
      mix msbms.elixir.clean --deps
      mix msbms.elixir.clean --migrations -c my_app1
      mix msbms.elixir.clean --all --component-file .ci/group-1.txt
      mix msbms.elixir.clean --plt --component-file .ci/group-1.txt -c extra_component

  At least one of `--ls`, `--plt`, `--build`, `--deps`, `--migrations`, or `--all` must be specified.
  Note: `--migrations` must be explicitly requested and is not included in `--all`.
  """

  use Mix.Task

  @options [
    ls: :boolean,
    plt: :boolean,
    build: :boolean,
    deps: :boolean,
    migrations: :boolean,
    all: :boolean,
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

    do_all = Keyword.get(opts, :all, false)
    do_ls = do_all or Keyword.get(opts, :ls, false)
    do_plt = do_all or Keyword.get(opts, :plt, false)
    do_build = do_all or Keyword.get(opts, :build, false)
    do_deps = do_all or Keyword.get(opts, :deps, false)
    do_migrations = Keyword.get(opts, :migrations, false)

    with :ok <- check_parameter_validity(do_ls, do_plt, do_build, do_deps, do_migrations),
         {:ok, final_components} <- resolve_components(base_dir, components, opts),
         :ok <- maybe_clean_ls_action(do_ls, base_dir, final_components),
         :ok <- maybe_clean_plt_action(do_plt, base_dir, final_components),
         :ok <- maybe_clean_build_action(do_build, base_dir, final_components),
         :ok <- maybe_clean_deps_action(do_deps, base_dir, final_components),
         :ok <- maybe_clean_migrations_action(do_migrations, base_dir, final_components) do
      Mix.shell().info("Successfully cleaned Elixir-related artifacts.")
    else
      {:error, reason} -> Mix.raise("Cleaning failed: #{reason}")
    end
  end

  defp check_parameter_validity(do_ls, do_plt, do_build, do_deps, do_migrations) do
    if do_ls or do_plt or do_build or do_deps or do_migrations do
      :ok
    else
      {:error,
       "No action specified. Please use --ls, --plt, --build, --deps, --migrations, or --all. " <>
         "Run 'mix help msbms.elixir.clean' for more information."}
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

  defp maybe_clean_ls_action(true, base_dir, components) do
    handle_clean_action(
      "Elixir Language Server files",
      base_dir,
      components,
      &MsbmsBuildLib.clean_ls/2
    )
  end

  defp maybe_clean_ls_action(false, _base_dir, _components), do: :ok

  defp maybe_clean_plt_action(true, base_dir, components) do
    handle_clean_action("Dialyzer PLT files", base_dir, components, &MsbmsBuildLib.clean_plt/2)
  end

  defp maybe_clean_plt_action(false, _base_dir, _components), do: :ok

  defp maybe_clean_build_action(true, base_dir, components) do
    handle_clean_action(
      "Elixir build artifacts",
      base_dir,
      components,
      &MsbmsBuildLib.clean_build/2
    )
  end

  defp maybe_clean_build_action(false, _base_dir, _components), do: :ok

  defp maybe_clean_deps_action(true, base_dir, components) do
    handle_clean_action("Elixir dependencies", base_dir, components, &MsbmsBuildLib.clean_deps/2)
  end

  defp maybe_clean_deps_action(false, _base_dir, _components), do: :ok

  defp maybe_clean_migrations_action(true, base_dir, components) do
    handle_clean_action(
      "database migrations",
      base_dir,
      components,
      &MsbmsBuildLib.clean_db_migrations/2
    )
  end

  defp maybe_clean_migrations_action(false, _base_dir, _components), do: :ok

  defp handle_clean_action(item_name, base_dir, components, func) do
    Mix.shell().info(
      "Cleaning #{item_name} in '#{base_dir}' for components: #{inspect(components)}..."
    )

    case func.(base_dir, components) do
      :ok ->
        Mix.shell().info("Successfully cleaned #{item_name}.")
        :ok

      {:error, reason} ->
        {:error, "Failed to clean #{item_name}: #{reason}"}
    end
  end
end
