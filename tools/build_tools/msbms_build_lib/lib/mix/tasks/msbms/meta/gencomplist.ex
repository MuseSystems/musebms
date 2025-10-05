# Source File: gencomplist.ex
# Location:    musebms/tools/build_tools/msbms_build_lib/lib/mix/tasks/msbms/meta/gencomplist.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule Mix.Tasks.Msbms.Meta.Gencomplist do
  @shortdoc "Generates system components list documentation."

  @moduledoc """
  Generates the system components list documentation file for MSBMS.

  This task scans all components in the project, extracts metadata from their
  `mix.exs` and `README.md` files, and generates a formatted markdown file
  suitable for Hugo/Docsy static site generation.

  The generated documentation includes:
  - Component categorization (Platform, Subsystems, Components)
  - Component descriptions from README files
  - First-party (MSBMS) dependencies
  - Third-party dependencies (runtime only)
  - Links to API and database documentation

  It calls functions from `MsbmsBuildLib` to perform the actual operations.

  ## Command line options

    * `--base-dir PATH` - Specifies the base directory of the MSBMS project.
      Defaults to the current working directory.
    * `--output PATH` - Specifies the output file path relative to base-dir.
      Defaults to "documentation/book/content/en/technical/system-components-list.md".
    * `--log-level LEVEL` - Sets the logging level (e.g., debug, info, warn, error).
      Defaults to "info".
    * `--dry-run` - Shows what would be generated without writing the file.

  ## Component Discovery

  The task automatically discovers components by:
  - Scanning standard component paths (app_server/components/*, app_server/subsystems/*, etc.)
  - Categorizing by naming convention:
    * `mscmp_*` → Components
    * `mssub_*` → Subsystems
    * `msplatform` → Platform
    * `msapp_*` → Applications

  ## Description Extraction

  Component descriptions are extracted from `README.md` files:
  - Text after `<!-- MDOC !-->` marker
  - Stops at `<!-- MDESC !-->` marker (if present) or first `##` heading (fallback)
  - Falls back to first paragraph after title if no MDOC marker found

  To control the description length, add a `<!-- MDESC !-->` marker in your README.md
  after the description text you want included in the component listing.

  ## Dependency Filtering

  Third-party dependencies are filtered to exclude development/test-only dependencies
  (those specified with `:only` option in mix.exs).

  ## Examples

      # Generate with defaults
      mix msbms.meta.gencomplist

      # Generate with custom output path
      mix msbms.meta.gencomplist --output docs/my-components.md

      # Preview without writing
      mix msbms.meta.gencomplist --dry-run

      # Generate with debug logging
      mix msbms.meta.gencomplist --log-level debug

      # Generate from specific project directory
      mix msbms.meta.gencomplist --base-dir /path/to/musebms
  """

  use Mix.Task

  @options [
    base_dir: :string,
    output: :string,
    log_level: :string,
    dry_run: :boolean
  ]

  def run(args) do
    {opts, _parsed_args, _invalid_opts} = OptionParser.parse(args, strict: @options)

    # Set log level early
    log_level_str = Keyword.get(opts, :log_level, "info")
    :ok = MsbmsBuildLib.set_log_level(String.to_atom(log_level_str))

    base_dir = Keyword.get(opts, :base_dir, File.cwd!())
    output_path = Keyword.get(opts, :output)
    dry_run = Keyword.get(opts, :dry_run, false)

    # Build options for the library function
    lib_opts =
      if output_path do
        [output_path: output_path]
      else
        []
      end

    if dry_run do
      generate_dry_run(base_dir, lib_opts)
    else
      generate_component_list_action(base_dir, lib_opts)
    end
  end

  defp generate_dry_run(base_dir, opts) do
    Mix.shell().info("DRY RUN: Generating component list documentation (not writing to file)...")
    Mix.shell().info("Base directory: #{base_dir}")

    output_path =
      Keyword.get(
        opts,
        :output_path,
        "documentation/book/content/en/technical/system-components-list.md"
      )

    full_output_path = Path.join(base_dir, output_path)
    Mix.shell().info("Would write to: #{full_output_path}")
    Mix.shell().info("")

    # Generate content without writing file
    opts_with_dry_run = Keyword.put(opts, :dry_run, true)

    case MsbmsBuildLib.generate_component_list_doc(base_dir, opts_with_dry_run) do
      {:ok, content} ->
        Mix.shell().info("DRY RUN: Preview of generated content:\n")
        Mix.shell().info("=" |> String.duplicate(80))

        # Show first 50 lines as preview
        lines = String.split(content, "\n")
        preview_lines = Enum.take(lines, 50)
        IO.puts(Enum.join(preview_lines, "\n"))

        if length(lines) > 50 do
          Mix.shell().info("\n... (#{length(lines) - 50} more lines)")
        end

        Mix.shell().info("\n" <> String.duplicate("=", 80))
        Mix.shell().info("\nDRY RUN: Content generated successfully (#{length(lines)} lines)")
        Mix.shell().info("DRY RUN: No file was written. Remove --dry-run flag to write the file.")

      {:error, reason} ->
        Mix.raise("Component list generation failed: #{reason}")
    end
  end

  defp generate_component_list_action(base_dir, opts) do
    output_path =
      Keyword.get(
        opts,
        :output_path,
        "documentation/book/content/en/technical/system-components-list.md"
      )

    Mix.shell().info("Generating component list documentation...")
    Mix.shell().info("Base directory: #{base_dir}")
    Mix.shell().info("Output path: #{output_path}")

    case MsbmsBuildLib.generate_component_list_doc(base_dir, opts) do
      {:ok, generated_path} ->
        Mix.shell().info("Successfully generated component list at: #{generated_path}")

      {:error, reason} ->
        Mix.raise("Component list generation failed: #{reason}")
    end
  end
end
