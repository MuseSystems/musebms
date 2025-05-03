# Source File: build_db.ex
# Location:    musebms/tools/build_tools/msbms_build_lib/lib/impl/build_db.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MsbmsBuildLib.Impl.BuildDb do
  @moduledoc false

  alias MsbmsBuildLib.Impl.Common
  alias MsbmsBuildLib.Types

  require Logger

  @doc """
  Builds database migrations for components that are migration targets.

  ## Parameters

  * `base_dir` - The base directory of the project.

  * `components` - The list of components to build migrations for. If `nil` or empty,
    all migration targets will be processed.  Note that this will only build
    migrations for Components that define persistent, deployable database
    migrations.  Typically this will be the Subsystems.  Any Component that
    does not define database migrations will simply be ignored.

  ## Returns

  * `:ok` - The build process was successful.
  * `{:error, reason}` - An error occurred during the build process.
  """
  @spec build_migrations(Path.t(), Types.components() | nil) ::
          :ok | {:error, term()}
  def build_migrations(base_dir, components) do
    Logger.notice("==msbms_build_lib==::build_db::build_migrations::START")

    migration_targets = Common.db_migration_targets()

    filtered_targets =
      case components do
        nil -> migration_targets
        [] -> migration_targets
        comps -> Enum.filter(migration_targets, fn {name, _, _} -> name in comps end)
      end

    results =
      filtered_targets
      |> Enum.map(fn {name, db_type, component_path} ->
        build_migrations_for_target(base_dir, name, db_type, component_path)
      end)

    case Enum.filter(results, &match?({:error, _}, &1)) do
      [] ->
        Logger.notice("==msbms_build_lib==::build_db::build_migrations::DONE")
        :ok

      errors ->
        Logger.error("==msbms_build_lib==::build_db::build_migrations::FAILED")
        first_error = List.first(errors)
        {:error, first_error}
    end
  end

  defp build_migrations_for_target(base_dir, component_name, db_type, component_path) do
    full_component_path = Path.join(base_dir, component_path)
    source_dir = Path.join(base_dir, "database")

    if File.dir?(source_dir) do
      Logger.info("::#{component_name}::building migrations for type: #{db_type}")

      # Build migrations using mix builddb command
      try do
        args = [
          "builddb",
          "--type",
          db_type,
          "--source",
          source_dir
        ]

        {output, exit_code} =
          System.cmd("mix", args, cd: full_component_path, stderr_to_stdout: true)

        if exit_code == 0 do
          Logger.info("::#{component_name}::building migrations for type: #{db_type}: DONE.")
          Logger.debug(output)
          {:ok, component_name}
        else
          Logger.warning(
            "::#{component_name}::building migrations for type #{db_type} with exit code: #{exit_code}: FAILED."
          )

          Logger.warning("Output: #{output}")
          {:error, {component_name, "Migration build failed with exit code #{exit_code}"}}
        end
      rescue
        error ->
          Logger.warning("::#{component_name}::building migrations for type: #{db_type}: FAILED.")

          {:error, {component_name, error}}
      end
    else
      Logger.info("::#{component_name}::building migrations for type: #{db_type}: SKIPPED.")
      # Consider this a success since there's nothing to build
      {:ok, component_name}
    end
  end
end
