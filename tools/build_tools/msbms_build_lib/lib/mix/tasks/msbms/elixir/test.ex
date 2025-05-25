# Source File: test.ex
# Location:    musebms/tools/build_tools/msbms_build_lib/lib/mix/tasks/msbms/elixir/test.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule Mix.Tasks.Msbms.Elixir.Test do
  @shortdoc "Runs various Elixir tests (unit, integration, doctest, credo, dialyzer)."

  @moduledoc """
  Runs various types of Elixir tests for MSBMS components.

  This task allows you to run:
  - Unit tests
  - Integration tests
  - Doctests
  - Credo tests (static code analysis)
  - Dialyzer tests (static type analysis)

  It calls functions from `MsbmsBuildLib` to perform the actual operations.

  ## Command line options

    * `--unit` - Runs unit tests.
    * `--integration` - Runs integration tests.
    * `--doctest` - Runs doctests.
    * `--credo` - Runs credo tests (static code analysis).
    * `--dialyzer` - Runs dialyzer tests (static type analysis).
    * `--all` - Runs all of the above test types.
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

      mix msbms.elixir.test --unit
      mix msbms.elixir.test --all --base-dir /path/to/project
      mix msbms.elixir.test --credo --dialyzer -c my_app1 -c my_app2
      mix msbms.elixir.test --integration --doctest
      mix msbms.elixir.test --all --component-file .ci/group-1.txt
      mix msbms.elixir.test --unit --component-file .ci/group-1.txt -c extra_component

  At least one of `--unit`, `--integration`, `--doctest`, `--credo`, `--dialyzer`, or `--all` must be specified.
  """

  use Mix.Task

  @options [
    unit: :boolean,
    integration: :boolean,
    doctest: :boolean,
    credo: :boolean,
    dialyzer: :boolean,
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

    test_opts = build_test_opts(opts)

    with :ok <- validate_test_opts(test_opts),
         {:ok, final_components} <- resolve_components(base_dir, components, opts),
         :ok <- run_tests_action(base_dir, final_components, test_opts) do
      Mix.shell().info("Successfully completed tests.")
    else
      {:error, reason} -> Mix.raise("Testing failed: #{reason}")
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

  defp build_test_opts(opts) do
    do_all = Keyword.get(opts, :all, false)

    [
      test_unit: do_all or Keyword.get(opts, :unit, false),
      test_integration: do_all or Keyword.get(opts, :integration, false),
      test_doctest: do_all or Keyword.get(opts, :doctest, false),
      run_credo: do_all or Keyword.get(opts, :credo, false),
      run_dialyzer: do_all or Keyword.get(opts, :dialyzer, false)
    ]
  end

  defp validate_test_opts(test_opts) do
    if Enum.any?(test_opts, fn {_key, value} -> value end) do
      :ok
    else
      {:error,
       "No action specified. Please use --unit, --integration, --doctest, --credo, --dialyzer, or --all. " <>
         "Run 'mix help elixir.test' for more information."}
    end
  end

  defp run_tests_action(base_dir, components, test_opts) do
    selected_tests =
      test_opts
      |> Enum.filter(fn {_key, value} -> value end)
      |> Enum.map_join(", ", fn {key, _value} -> format_test_name(key) end)

    Mix.shell().info(
      "Running tests (#{selected_tests}) in '#{base_dir}' for components: #{inspect(components)}..."
    )

    MsbmsBuildLib.run_tests(base_dir, components, test_opts)
  end

  defp format_test_name(:test_unit), do: "unit"
  defp format_test_name(:test_integration), do: "integration"
  defp format_test_name(:test_doctest), do: "doctest"
  defp format_test_name(:run_credo), do: "credo"
  defp format_test_name(:run_dialyzer), do: "dialyzer"
end
