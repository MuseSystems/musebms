# Source File: deps.ex
# Location:    musebms/tools/build_tools/msbms_build_lib/lib/mix/tasks/msbms/elixir/deps.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule Mix.Tasks.Msbms.Elixir.Deps do
  @shortdoc "Manages Elixir application dependencies (install, update, clean)."

  @moduledoc """
  Manages Elixir application dependencies.

  This task allows you to clean, install, or update dependencies for
  Elixir components within a MSBMS project structure. It calls functions
  from `MsbmsBuildLib` to perform the actual operations.

  ## Command line options

    * `--clean` - Cleans dependency files (`deps` directory and `mix.lock`).
    * `--install` - Installs dependencies (equivalent to `mix deps.get`).
    * `--update` - Updates dependencies (equivalent to `mix deps.update --all`).
    * `--base-dir PATH` - Specifies the base directory of the MSBMS project.
      Defaults to the current working directory.
    * `-c NAME`, `--component NAME` - Specifies a component to operate on.
      Can be provided multiple times. If not specified, operations may apply
      to all discoverable components or the root project, depending on the
      underlying `MsbmsBuildLib` logic.
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

      mix msbms.elixir.deps --install
      mix msbms.elixir.deps --update --base-dir /path/to/project
      mix msbms.elixir.deps --clean -c my_app1 -c my_app2
      mix msbms.elixir.deps --clean --install -c my_app
      mix msbms.elixir.deps --install --component-file .ci/group-1.txt
      mix msbms.elixir.deps --update --component-file .ci/group-1.txt -c extra_component

  At least one of `--clean`, `--install`, or `--update` must be specified.
  If multiple actions are specified, they are performed in the order: clean, install, update.
  """

  use Mix.Task

  @options [
    clean: :boolean,
    install: :boolean,
    update: :boolean,
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

    clean? = Keyword.get(opts, :clean, false)
    install? = Keyword.get(opts, :install, false)
    update? = Keyword.get(opts, :update, false)

    if not (clean? or install? or update?) do
      Mix.raise(
        "No action specified. Please use --clean, --install, or --update. " <>
          "Run 'mix help elixir.deps' for more information."
      )
    end

    case resolve_components(base_dir, components, opts) do
      {:ok, final_components} ->
        if clean?, do: do_clean_action(base_dir, final_components)
        if install?, do: do_install_action(base_dir, final_components)
        if update?, do: do_update_action(base_dir, final_components)

      {:error, reason} ->
        Mix.raise("Dependency management failed: #{reason}")
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

  defp do_clean_action(base_dir, components) do
    handle_action("Cleaning", base_dir, components, &MsbmsBuildLib.clean_deps/2)
  end

  defp do_install_action(base_dir, components) do
    handle_action("Installing", base_dir, components, &MsbmsBuildLib.install_elixir_deps/2)
  end

  defp do_update_action(base_dir, components) do
    handle_action("Updating", base_dir, components, &MsbmsBuildLib.update_elixir_deps/2)
  end

  defp handle_action(action_verb, base_dir, components, func) do
    Mix.shell().info(
      "#{action_verb} Elixir dependencies in '#{base_dir}' for components: #{inspect(components)}..."
    )

    case func.(base_dir, components) do
      :ok ->
        Mix.shell().info("Successfully #{String.downcase(action_verb)} Elixir dependencies.")

      {:error, reason} ->
        Mix.raise("Failed to #{String.downcase(action_verb)} Elixir dependencies: #{reason}")
    end
  end
end
