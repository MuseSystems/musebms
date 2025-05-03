# Source File: deps_elixir.ex
# Location:    musebms/tools/build_tools/msbms_build_lib/lib/impl/deps_elixir.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MsbmsBuildLib.Impl.DepsElixir do
  @moduledoc false

  alias MsbmsBuildLib.Impl.Common
  alias MsbmsBuildLib.Types

  require Logger

  ##############################################################################
  #
  # install_elixir_deps
  #
  #

  @doc """
  Install Elixir dependencies for specified components.
  """
  @spec install_elixir_deps(Path.t(), Types.components()) :: :ok | {:error, message :: String.t()}
  def install_elixir_deps(base_dir, components) do
    Logger.notice("==msbms_build_lib==::deps_elixir::install_elixir_deps::START")

    build_result =
      case Common.resolve_component_paths(:elixir, base_dir, components) do
        {:ok, component_paths} ->
          process_elixir_deps(component_paths, :install)

        {:error, error_message} ->
          {:error, error_message}
      end

    case build_result do
      :ok ->
        Logger.notice("==msbms_build_lib==::deps_elixir::install_elixir_deps::DONE")
        :ok

      error ->
        Logger.error("==msbms_build_lib==::deps_elixir::install_elixir_deps::FAILED")
        error
    end
  end

  ##############################################################################
  #
  # update_elixir_deps
  #
  #

  @doc """
  Update Elixir dependencies for specified components.
  """
  @spec update_elixir_deps(Path.t(), Types.components()) :: :ok | {:error, message :: String.t()}
  def update_elixir_deps(base_dir, components) do
    Logger.notice("==msbms_build_lib==::deps_elixir::update_elixir_deps::START")

    build_result =
      case Common.resolve_component_paths(:elixir, base_dir, components) do
        {:ok, component_paths} ->
          process_elixir_deps(component_paths, :update)

        {:error, error_message} ->
          {:error, error_message}
      end

    case build_result do
      :ok ->
        Logger.notice("==msbms_build_lib==::deps_elixir::update_elixir_deps::DONE")
        :ok

      error ->
        Logger.error("==msbms_build_lib==::deps_elixir::update_elixir_deps::FAILED")
        error
    end
  end

  ##############################################################################
  #
  # Private Functions
  #
  #

  defp process_elixir_deps(component_paths, action) do
    Enum.reduce_while(component_paths, :ok, fn component_path, _acc ->
      component_name = Path.basename(component_path)

      Logger.info("::#{component_name}::processing Elixir deps: START")

      # Change to component directory and run mix command
      current_dir = File.cwd!()

      try do
        File.cd!(component_path)
        {output, status} = run_mix_command(action)
        Logger.debug(output)

        if status == 0 do
          Logger.info("::#{component_name}::processing Elixir deps: DONE")

          {:cont, :ok}
        else
          Logger.warning("::#{component_name}::processing Elixir deps: FAILED")
          {:halt, {:error, "Error processing dependencies for #{component_name}"}}
        end
      rescue
        e ->
          Logger.warning("::#{component_name}::processing Elixir deps: FAILED")
          {:halt, {:error, e}}
      after
        File.cd!(current_dir)
      end
    end)
  end

  defp run_mix_command(:install) do
    System.cmd("mix", ["deps.get"], stderr_to_stdout: true)
  end

  defp run_mix_command(:update) do
    System.cmd("mix", ["deps.update", "--all"], stderr_to_stdout: true)
  end
end
