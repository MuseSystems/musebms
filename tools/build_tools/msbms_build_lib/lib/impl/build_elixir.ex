# Source File: clean_elixir.ex
# Location:    musebms/tools/build_tools/msbms_build_lib/lib/impl/clean_elixir.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MsbmsBuildLib.Impl.BuildElixir do
  @moduledoc false

  alias MsbmsBuildLib.Impl.Common
  alias MsbmsBuildLib.Types

  require Logger

  ##############################################################################
  #
  # build_elixir
  #
  #

  @doc """
  Build Elixir components and refresh Dialyzer PLT for specified components.
  """
  @spec build_elixir(Path.t(), Types.components(), String.t()) ::
          :ok | {:error, message :: String.t()}
  def build_elixir(base_dir, components, elixir_env) do
    Logger.notice("==msbms_build_lib==::build_elixir::build_elixir::START")

    build_result =
      case Common.resolve_component_paths(:elixir, base_dir, components) do
        {:ok, component_paths} -> process_elixir_build(component_paths, elixir_env)
        {:error, error_message} -> {:error, error_message}
      end

    case build_result do
      :ok ->
        Logger.notice("==msbms_build_lib==::build_elixir::build_elixir::DONE")
        :ok

      {:error, error_message} when is_binary(error_message) ->
        Logger.error("==msbms_build_lib==::build_elixir::build_elixir::FAILED")
        {:error, error_message}

      error ->
        Logger.error("==msbms_build_lib==::build_elixir::build_elixir::FAILED")

        error_message =
          case error do
            {:error, msg} when is_binary(msg) -> msg
            {:error, other} -> "Elixir build failed: #{inspect(other)}"
            other -> "Elixir build failed: #{inspect(other)}"
          end

        {:error, error_message}
    end
  end

  ##############################################################################
  #
  # Private Functions
  #
  #

  defp process_elixir_build(component_paths, elixir_env) do
    Enum.reduce_while(component_paths, :ok, fn component_path, _acc ->
      component_name = Path.basename(component_path)

      Logger.info("::#{component_name}::building Elixir component")

      current_dir = File.cwd!()

      try do
        File.cd!(component_path)

        env = [{"MIX_ENV", elixir_env}]

        {compile_output, compile_status} =
          System.cmd("mix", ["compile"], stderr_to_stdout: true, env: env)

        Logger.debug(compile_output)

        if compile_status == 0 do
          {plt_output, plt_status} =
            System.cmd("mix", ["dialyzer", "--plt"], stderr_to_stdout: true, env: env)

          Logger.debug(plt_output)

          if plt_status == 0 do
            Logger.info("::#{component_name}::building Elixir component: DONE")

            {:cont, :ok}
          else
            Logger.warning("::#{component_name}::building Dialyzer PLT: FAILED")
            {:halt, {:error, "Error building Dialyzer PLT for #{component_name}"}}
          end
        else
          Logger.warning("::#{component_name}::compiling Elixir component: FAILED")
          {:halt, {:error, "Error compiling #{component_name}"}}
        end
      rescue
        e ->
          Logger.warning("::#{component_name}::building Elixir component: FAILED")
          {:halt, {:error, Exception.message(e)}}
      after
        File.cd!(current_dir)
      end
    end)
  end
end
