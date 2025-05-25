# Source File: docs_elixir.ex
# Location:    musebms/tools/build_tools/msbms_build_lib/lib/impl/docs_elixir.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MsbmsBuildLib.Impl.DocsElixir do
  @moduledoc false

  alias MsbmsBuildLib.Impl.Common
  alias MsbmsBuildLib.Types

  require Logger

  ##############################################################################
  #
  # build_docs_elixir
  #
  #

  @doc """
  Generate Elixir documentation for specified components.
  """
  @spec build_docs_elixir(Path.t(), Types.components()) :: :ok | {:error, message :: String.t()}
  def build_docs_elixir(base_dir, components) do
    Logger.notice("==msbms_build_lib==::docs_elixir::build_docs_elixir::START")

    build_result =
      case Common.resolve_component_paths(:elixir, base_dir, components) do
        {:ok, component_paths} ->
          elixir_docs_path = Path.join(base_dir, Common.elixir_docs_root())
          # Ensure documentation directory exists
          File.mkdir_p!(elixir_docs_path)

          process_elixir_docs(component_paths, elixir_docs_path)

        {:error, error_message} ->
          {:error, error_message}
      end

    case build_result do
      :ok ->
        Logger.notice("==msbms_build_lib==::docs_elixir::build_docs_elixir::DONE")
        :ok

      error ->
        Logger.error("==msbms_build_lib==::docs_elixir::build_docs_elixir::FAILED")
        error
    end
  end

  defp process_elixir_docs(component_paths, elixir_docs_path) do
    Enum.reduce_while(component_paths, :ok, fn component_path, _acc ->
      component_name = Path.basename(component_path)

      Logger.info("::#{component_name}::building Elixir docs: START")

      # Delete existing documentation if it exists
      component_docs_path = Path.join(elixir_docs_path, component_name)
      _ = if File.dir?(component_docs_path), do: File.rm_rf!(component_docs_path)

      # Change to component directory and run mix docs
      current_dir = File.cwd!()

      try do
        File.cd!(component_path)
        {output, status} = System.cmd("mix", ["docs"], stderr_to_stdout: true)
        Logger.debug(output)

        if status == 0 do
          Logger.info("::#{component_name}::building Elixir docs: DONE")

          {:cont, :ok}
        else
          Logger.warning("::#{component_name}::building Elixir docs: FAILED")
          {:halt, {:error, "Error generating documentation for #{component_name}"}}
        end
      rescue
        e ->
          Logger.warning("::#{component_name}::building Elixir docs: FAILED")
          {:halt, {:error, Exception.message(e)}}
      after
        File.cd!(current_dir)
      end
    end)
  end
end
