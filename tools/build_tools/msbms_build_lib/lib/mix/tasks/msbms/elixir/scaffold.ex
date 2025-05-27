# Source File: scaffold.ex
# Location:    musebms/tools/build_tools/msbms_build_lib/lib/mix/tasks/msbms/elixir/scaffold.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule Mix.Tasks.Msbms.Elixir.Scaffold do
  @shortdoc "Scaffolds a new Elixir component from templates."

  @moduledoc """
  Scaffolds a new Elixir component for MSBMS projects.

  This task creates a new Elixir component project structure based on the standard
  templates, with all files properly configured for the new component.

  ## Command line options

    * `--name NAME` - The name of the component (e.g., "mscmp_new_feature"). Required.
    * `--path PATH` - The relative path where the component should be created.
      Defaults to "app_server/components/system".
    * `--display-name NAME` - Human-friendly name for the component.
      Defaults to a capitalized version of the component name.
    * `--description DESC` - Brief description of the component.
      Defaults to a generic description.
    * `--section SECTION` - Documentation section atom.
      Defaults to derived from component name.
    * `--comp-short-name NAME` - Override the derived short component name.
      Defaults to removing categorizing prefix (e.g., "mscmp_syst_" → "").
    * `--module-name NAME` - Override the derived module name.
      Defaults to PascalCase of full component name.
    * `--module-short-name NAME` - Override the derived short module name.
      Defaults to PascalCase of short component name.
    * `--base-dir PATH` - Specifies the base directory of the MSBMS project.
      Defaults to the current working directory.
    * `--log-level LEVEL` - Sets the logging level (e.g., debug, info, warn, error).
      Defaults to "info".

  ## Examples

      # Create a new system component
      mix msbms.elixir.scaffold --name mscmp_new_feature

      # Create a new application component with custom details
      mix msbms.elixir.scaffold --name msapp_new_app \\
        --path app_server/components/application \\
        --display-name "New Application" \\
        --description "Provides new application functionality."

      # Create a subsystem component
      mix msbms.elixir.scaffold --name mssub_new_subsystem \\
        --path app_server/subsystems \\
        --display-name "New Subsystem"

      # Override derived names for edge cases
      mix msbms.elixir.scaffold --name legacy_system_component \\
        --comp-short-name legacy \\
        --module-short-name Legacy

  The `--name` option is required.
  """

  use Mix.Task

  @options [
    name: :string,
    path: :string,
    display_name: :string,
    description: :string,
    section: :string,
    comp_short_name: :string,
    module_name: :string,
    module_short_name: :string,
    base_dir: :string,
    log_level: :string
  ]

  def run(args) do
    {opts, _parsed_args, _invalid_opts} =
      OptionParser.parse(args, strict: @options)

    # Set log level early
    log_level_str = Keyword.get(opts, :log_level, "info")
    :ok = MsbmsBuildLib.set_log_level(String.to_atom(log_level_str))

    component_name = Keyword.get(opts, :name)

    if is_nil(component_name) do
      Mix.raise(
        "Component name is required. Please use --name COMPONENT_NAME. " <>
          "Run 'mix help msbms.elixir.scaffold' for more information."
      )
    end

    base_dir = Keyword.get(opts, :base_dir, File.cwd!())
    target_path = Keyword.get(opts, :path, "app_server/components/system")

    scaffold_opts = build_scaffold_opts(opts)

    Mix.shell().info(
      "Scaffolding Elixir component '#{component_name}' in '#{Path.join(base_dir, target_path)}'..."
    )

    case MsbmsBuildLib.scaffold_elixir_component(
           base_dir,
           component_name,
           target_path,
           scaffold_opts
         ) do
      :ok ->
        Mix.shell().info("Successfully scaffolded component '#{component_name}'.")
        Mix.shell().info("")
        Mix.shell().info("Next steps:")
        Mix.shell().info("  1. Review and customize the generated files")
        Mix.shell().info("  2. Update the README.md with specific component documentation")
        Mix.shell().info("  3. Implement business logic in lib/impl/ directory")
        Mix.shell().info("  4. Add public API functions in lib/api/#{component_name}.ex")

        Mix.shell().info(
          "     (API functions should focus on validation, type checking, and standardized returns)"
        )

        Mix.shell().info("  5. Add any necessary types to lib/api/types.ex")

        Mix.shell().info(
          "  6. Add runtime components (GenServers, etc.) in lib/runtime/ if needed"
        )

        Mix.shell().info("  7. Add public Mix tasks in lib/mix/ if needed")
        Mix.shell().info("  8. Write tests in the test/ directory")

      {:error, reason} ->
        Mix.raise("Failed to scaffold component '#{component_name}': #{reason}")
    end
  end

  defp build_scaffold_opts(opts) do
    []
    |> maybe_add_opt(:component_display_name, Keyword.get(opts, :display_name))
    |> maybe_add_opt(:component_description, Keyword.get(opts, :description))
    |> maybe_add_opt(:component_section, parse_section(Keyword.get(opts, :section)))
    |> maybe_add_opt(:comp_short_name, Keyword.get(opts, :comp_short_name))
    |> maybe_add_opt(:module_name, Keyword.get(opts, :module_name))
    |> maybe_add_opt(:module_short_name, Keyword.get(opts, :module_short_name))
  end

  defp maybe_add_opt(opts, _key, nil), do: opts
  defp maybe_add_opt(opts, key, value), do: Keyword.put(opts, key, value)

  defp parse_section(nil), do: nil

  defp parse_section(section_str) when is_binary(section_str) do
    String.to_atom(section_str)
  end
end
