# Source File: tests_elixir.ex
# Location:    musebms/tools/build_tools/msbms_build_lib/lib/impl/tests_elixir.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MsbmsBuildLib.Impl.TestsElixir do
  @moduledoc false

  alias MsbmsBuildLib.Impl.Common
  alias MsbmsBuildLib.Types

  require Logger

  @spec run_tests(Path.t(), Types.components(), Keyword.t()) ::
          :ok | {:error, message :: String.t()}
  def run_tests(base_dir, components, opts \\ []) do
    Logger.notice("==msbms_build_lib==::tests_elixir::run_tests::START")

    tests = %{
      do_test_unit: Keyword.get(opts, :test_unit, false),
      do_test_integration: Keyword.get(opts, :test_integration, false),
      do_test_doctest: Keyword.get(opts, :test_doctest, false),
      do_credo: Keyword.get(opts, :run_credo, false),
      do_dialyzer: Keyword.get(opts, :run_dialyzer, false)
    }

    with {:ok, component_paths} <- Common.resolve_component_paths(:elixir, base_dir, components),
         :ok <- run_component_tests(tests, component_paths) do
      Logger.notice("==msbms_build_lib==::tests_elixir::run_tests::DONE")

      :ok
    else
      {:error, error_message} ->
        Logger.error("==msbms_build_lib==::tests_elixir::run_tests::FAILED")
        {:error, error_message}
    end
  end

  defp run_component_tests(tests, component_paths) do
    Enum.reduce_while(component_paths, :ok, fn component_path, _acc ->
      component_name = Path.basename(component_path)

      case process_component(tests, component_path) do
        :ok ->
          {:cont, :ok}

        {:error, message} ->
          Logger.warning("::#{component_name}::#{message}")
          {:halt, {:error, message}}
      end
    end)
  end

  defp process_component(tests, component_path) do
    component_name = Path.basename(component_path)

    Logger.info("::#{component_name}::COMPONENT TESTS START")

    with :ok <- maybe_run_unit_tests(tests, component_name, component_path),
         :ok <- maybe_run_integration_tests(tests, component_name, component_path),
         :ok <- maybe_run_doctests(tests, component_name, component_path),
         :ok <- maybe_run_credo(tests, component_name, component_path),
         :ok <- maybe_run_dialyzer(tests, component_name, component_path) do
      Logger.info("::#{component_name}::COMPONENT TESTS DONE")
      :ok
    else
      {:error, error_message} ->
        Logger.warning("::#{component_name}::COMPONENT TESTS FAILED")
        {:error, error_message}
    end
  end

  defp maybe_run_unit_tests(%{do_test_unit: true}, component_name, component_path) do
    Logger.info("::#{component_name}::running unit tests")

    {output, exit_code} = System.cmd("mix", ["test", "--only", "unit"], cd: component_path)
    Logger.debug(output)

    if exit_code == 0 do
      :ok
    else
      Logger.warning("::#{component_name}::unit tests failed")
      {:error, "unit tests failed for #{component_name}"}
    end
  end

  defp maybe_run_unit_tests(_tests, _component_name, _component_path), do: :ok

  defp maybe_run_integration_tests(%{do_test_integration: true}, component_name, component_path) do
    Logger.info("::#{component_name}::running integration tests")

    {output, exit_code} =
      System.cmd("mix", ["test", "--only", "integration"], cd: component_path)

    Logger.debug(output)

    if exit_code == 0 do
      :ok
    else
      Logger.warning("::#{component_name}::integration tests failed")
      {:error, "integration tests failed for #{component_name}"}
    end
  end

  defp maybe_run_integration_tests(_tests, _component_name, _component_path), do: :ok

  defp maybe_run_doctests(%{do_test_doctest: true}, component_name, component_path) do
    Logger.info("::#{component_name}::running doctests")

    {output, exit_code} = System.cmd("mix", ["test", "--only", "doctest"], cd: component_path)
    Logger.debug(output)

    if exit_code == 0 do
      :ok
    else
      Logger.warning("::#{component_name}::doctests failed")
      {:error, "doctests failed for #{component_name}"}
    end
  end

  defp maybe_run_doctests(_tests, _component_name, _component_path), do: :ok

  defp maybe_run_credo(%{do_credo: true}, component_name, component_path) do
    Logger.info("::#{component_name}::running credo")

    {output, exit_code} = System.cmd("mix", ["credo"], cd: component_path)
    Logger.debug(output)

    if exit_code == 0 do
      :ok
    else
      Logger.warning("::#{component_name}::credo found issues")
      {:error, "credo found issues in #{component_name}"}
    end
  end

  defp maybe_run_credo(_tests, _component_name, _component_path), do: :ok

  defp maybe_run_dialyzer(%{do_dialyzer: true}, component_name, component_path) do
    Logger.info("::#{component_name}::running dialyzer")

    # Create PLTs directory if it doesn't exist
    plts_dir = Path.join(component_path, "priv/plts")
    File.mkdir_p!(plts_dir)

    # Run Dialyzer
    {output, exit_code} = System.cmd("mix", ["dialyzer"], cd: component_path)
    Logger.debug(output)

    if exit_code == 0 do
      :ok
    else
      Logger.warning("::#{component_name}::dialyzer found issues")
      {:error, "dialyzer found issues in #{component_name}"}
    end
  end

  defp maybe_run_dialyzer(_tests, _component_name, _component_path), do: :ok
end
