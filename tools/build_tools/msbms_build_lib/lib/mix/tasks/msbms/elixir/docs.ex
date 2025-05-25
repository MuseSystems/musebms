# Source File: docs.ex
# Location:    musebms/tools/build_tools/msbms_build_lib/lib/mix/tasks/msbms/elixir/docs.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule Mix.Tasks.Msbms.Elixir.Docs do
  @shortdoc "Builds Elixir documentation."

  @moduledoc """
  Builds Elixir documentation for MSBMS components using ExDoc.

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

      mix msbms.elixir.docs
      mix msbms.elixir.docs --base-dir /path/to/project
      mix msbms.elixir.docs -c my_app1 -c my_app2
      mix msbms.elixir.docs --component-file .ci/group-1.txt
      mix msbms.elixir.docs --component-file .ci/group-1.txt -c extra_component
  """

  use Mix.Task

  @options [
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

    case resolve_components(base_dir, components, opts) do
      {:ok, final_components} ->
        build_elixir_docs_action(base_dir, final_components)

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

  defp build_elixir_docs_action(base_dir, components) do
    Mix.shell().info(
      "Building Elixir documentation in '#{base_dir}' for components: #{inspect(components)}..."
    )

    case MsbmsBuildLib.build_docs_elixir(base_dir, components) do
      :ok ->
        Mix.shell().info("Successfully built Elixir documentation.")

      {:error, reason} ->
        Mix.raise(
          "Documentation building failed: Failed to build Elixir documentation: #{reason}"
        )
    end
  end
end
