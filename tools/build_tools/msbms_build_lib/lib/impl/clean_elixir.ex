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

defmodule MsbmsBuildLib.Impl.CleanElixir do
  @moduledoc false

  alias MsbmsBuildLib.Impl.Common
  alias MsbmsBuildLib.Types

  require Logger

  ##############################################################################
  #
  # clean_ls
  #
  #

  @spec clean_ls(Path.t(), Types.components()) :: :ok | {:error, message :: String.t()}
  def clean_ls(base_dir, components),
    do: clean(".elixir_ls", "Elixir Language Server", base_dir, components)

  ##############################################################################
  #
  # clean_plt
  #
  #

  @spec clean_plt(Path.t(), Types.components()) :: :ok | {:error, message :: String.t()}
  def clean_plt(base_dir, components),
    do: clean(Path.join(["priv", "plts"]), "PLT", base_dir, components)

  ##############################################################################
  #
  # clean_db_migrations
  #
  #

  @spec clean_db_migrations(Path.t(), Types.components()) :: :ok | {:error, message :: String.t()}
  def clean_db_migrations(base_dir, components),
    do: clean(Path.join(["priv", "database"]), "DB Migrations", base_dir, components)

  ##############################################################################
  #
  # clean_build
  #
  #

  @spec clean_build(Path.t(), Types.components()) ::
          :ok | {:error, message :: String.t()}
  def clean_build(base_dir, components),
    do: clean("_build", "Build", base_dir, components)

  ##############################################################################
  #
  # clean_deps
  #
  #

  @spec clean_deps(Path.t(), Types.components()) ::
          :ok | {:error, message :: String.t()}
  def clean_deps(base_dir, components),
    do: clean("deps", "Dependencies", base_dir, components)

  ##############################################################################
  #
  # General use private functions
  #
  #

  defp clean(clean_target, clean_target_description, base_dir, components) do
    Logger.notice("==msbms_build_lib==::clean_elixir::clean::#{clean_target_description}::START")

    try do
      case Common.resolve_component_paths(:elixir, base_dir, components) do
        {:ok, component_paths} ->
          Enum.each(component_paths, fn component_path ->
            target_dir = Path.join(component_path, clean_target)
            component_name = component_path |> Path.basename()

            if File.dir?(target_dir) do
              case File.rm_rf(target_dir) do
                {:ok, _} ->
                  Logger.info("::#{component_name}::cleaning #{clean_target_description}: DONE.")

                {:error, _error_message, _error_details} ->
                  throw(
                    {:error, "Failed to remove #{clean_target_description} :: #{component_name}."}
                  )
              end
            else
              Logger.info(
                "::#{component_name}::cleaning #{clean_target_description}: SKIPPED (does not exist)"
              )
            end
          end)

          Logger.notice(
            "==msbms_build_lib==::clean_elixir::clean::#{clean_target_description}::DONE"
          )

          :ok

        {:error, error_message} ->
          throw({:error, error_message})
      end
    catch
      {:error, error_message} ->
        Logger.error(
          "==msbms_build_lib==::clean_elixir::clean::#{clean_target_description}::FAILED"
        )

        {:error, error_message}
    end
  end
end
