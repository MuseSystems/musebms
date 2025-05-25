# Source File: common.ex
# Location:    musebms/tools/build_tools/msbms_build_lib/lib/impl/common.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MsbmsBuildLib.Impl.Common do
  @moduledoc false

  alias MsbmsBuildLib.Types

  require Logger

  @project_directories [
    "database",
    "app_server",
    "documentation",
    "tools"
  ]

  @project_markers ["LICENSE.md"] ++ @project_directories

  @elixir_component_paths [
    "app_server/components/system",
    "app_server/components/application",
    "app_server/subsystems",
    "app_server/platform"
  ]

  @db_component_paths [
    "database/components/system",
    "database/components/application"
  ]

  # See `MsbmsBuildLib.Types.migration_target/0` for more information.
  @db_migration_targets [
    {"mssub_mcp", "mssub_mcp", "app_server/subsystems/mssub_mcp"},
    {"mssub_bms", "mssub_bms", "app_server/subsystems/mssub_bms"}
  ]

  @elixir_docs_root "documentation/technical/app_server"
  @db_docs_root "documentation/technical/database"

  @build_tools_path "tools/build_tools"
  @db_build_scripts_path "tools/database_scripts"

  ##############################################################################
  #
  # project_directories
  #
  #

  @doc """
  Get the list of project directories.

  Returns a list of directory names.
  """
  @spec project_directories() :: [Path.t(), ...]
  def project_directories, do: @project_directories

  ##############################################################################
  #
  # project_markers
  #
  #

  @doc """
  Get the list of project markers.

  Returns a list of marker file names.
  """
  @spec project_markers() :: [Path.t(), ...]
  def project_markers, do: @project_markers

  ##############################################################################
  #
  # elixir_component_paths
  #
  #

  @doc """
  Get the list of Elixir component paths.

  Returns a list of directory names.
  """
  @spec elixir_component_paths() :: [Path.t(), ...]
  def elixir_component_paths, do: @elixir_component_paths

  ##############################################################################
  #
  # db_component_paths
  #
  #

  @doc """
  Get the list of database component paths.

  Returns a list of directory names.
  """
  @spec db_component_paths() :: [Path.t(), ...]
  def db_component_paths, do: @db_component_paths

  ##############################################################################
  #
  # elixir_docs_root
  #
  #

  @doc """
  Get the root directory for Elixir documentation.

  Returns the path to the Elixir documentation root directory.
  """
  @spec elixir_docs_root() :: Path.t()
  def elixir_docs_root, do: @elixir_docs_root

  ##############################################################################
  #
  # db_docs_root
  #
  #

  @doc """
  Get the root directory for database documentation.

  Returns the path to the database documentation root directory.
  """
  @spec db_docs_root() :: Path.t()
  def db_docs_root, do: @db_docs_root

  ##############################################################################
  #
  # resolve_component_paths
  #
  #

  @doc """
  Resolve the paths for a given kind of component.

  Returns a tuple with either `{:ok, paths}` if the paths are successfully resolved,
  or `{:error, message}` if there is an error.
  """
  @spec resolve_component_paths(Types.kind(), Path.t(), Types.components() | nil) ::
          {:error, String.t()} | {:ok, Types.component_paths()}
  def resolve_component_paths(kind, base_dir, components)

  def resolve_component_paths(:elixir, base_dir, components)
      when is_nil(components) or components == [] do
    elixir_component_paths()
    |> find_components_in_paths(base_dir)
    |> handle_component_results(base_dir)
  end

  def resolve_component_paths(:elixir, base_dir, [_ | _] = components) do
    resolve_from_paths(base_dir, components, elixir_component_paths())
  end

  def resolve_component_paths(:db, base_dir, components)
      when is_nil(components) or components == [] do
    db_component_paths()
    |> find_components_in_paths(base_dir)
    |> handle_component_results(base_dir)
  end

  def resolve_component_paths(:db, base_dir, [_ | _] = components) do
    resolve_from_paths(base_dir, components, db_component_paths())
  end

  def resolve_component_paths(:elixir_docs, base_dir, components)
      when is_nil(components) or components == [] do
    docs_path = Path.join(base_dir, elixir_docs_root())
    find_docs_components(docs_path)
  end

  def resolve_component_paths(:elixir_docs, base_dir, [_ | _] = components) do
    docs_path = Path.join(base_dir, elixir_docs_root())
    resolve_from_single_path(docs_path, components)
  end

  def resolve_component_paths(:db_docs, base_dir, components)
      when is_nil(components) or components == [] do
    docs_path = Path.join(base_dir, db_docs_root())
    find_docs_components(docs_path)
  end

  def resolve_component_paths(:db_docs, base_dir, [_ | _] = components) do
    docs_path = Path.join(base_dir, db_docs_root())
    resolve_from_single_path(docs_path, components)
  end

  # Private functions specific to resolve_component_paths/:elixir_docs and :db_docs
  defp find_docs_components(docs_path) do
    if File.dir?(docs_path) do
      case list_directory_components(docs_path) do
        [] -> {:error, "No components found in #{docs_path}"}
        paths -> {:ok, paths}
      end
    else
      {:error, "Documentation directory not found: #{docs_path}"}
    end
  end

  defp list_directory_components(path) do
    File.ls!(path)
    |> Enum.filter(&File.dir?(Path.join(path, &1)))
    |> Enum.map(&Path.join(path, &1))
  end

  ##############################################################################
  #
  # build_tools_path
  #
  #

  @spec build_tools_path() :: Path.t()
  def build_tools_path, do: @build_tools_path

  ##############################################################################
  #
  # db_tool_build_scripts_path
  #
  #

  @spec db_build_scripts_path() :: Path.t()
  def db_build_scripts_path, do: @db_build_scripts_path

  ##############################################################################
  #
  # db_migration_targets
  #
  #

  @spec db_migration_targets() :: [Types.migration_target(), ...]
  def db_migration_targets, do: @db_migration_targets

  ##############################################################################
  #
  # set_log_level
  #
  #

  @doc """
  Set the Logger level for the current process.

  Raises `ArgumentError` if an invalid log level is provided.
  """
  @spec set_log_level(Logger.level()) :: :ok
  def set_log_level(level)
      when level in [
             :emergency,
             :alert,
             :critical,
             :error,
             :warning,
             :warn,
             :notice,
             :info,
             :debug
           ] do
    Logger.configure(level: level)
  end

  def set_log_level(level), do: raise(ArgumentError, "Invalid log level: #{inspect(level)}")

  ##############################################################################
  #
  # read_component_file
  #
  #

  @doc """
  Read the contents of a component file and parse it into a list of components.

  Returns a tuple with either `{:ok, components}` if the file is successfully read and parsed,
  or `{:error, message}` if there is an error.
  """
  @spec read_component_file(Path.t(), Path.t()) ::
          {:ok, Types.components()} | {:error, String.t()}
  def read_component_file(base_dir, file_path) do
    full_path = Path.join(base_dir, file_path)

    with {:exists, true} <- {:exists, File.exists?(full_path)},
         {:read, {:ok, content}} <- {:read, File.read(full_path)} do
      components = parse_component_file_content(content)
      {:ok, components}
    else
      {:exists, false} ->
        {:error, "Component file not found: #{full_path}"}

      {:read, {:error, reason}} ->
        {:error, "Failed to read component file #{full_path}: #{reason}"}
    end
  end

  ##############################################################################
  #
  # General Private Functions
  #
  #

  # Component file parsing helper
  defp parse_component_file_content(content) do
    content
    |> String.split("\n")
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(String.starts_with?(&1, "#") or &1 == "" or String.match?(&1, ~r/^\s*$/)))
  end

  # Shared helper functions used by multiple public functions
  defp resolve_from_single_path(parent_path, components) do
    with true <- File.dir?(parent_path),
         resolved_paths <- find_matching_components(parent_path, components),
         :ok <- log_missing_components(resolved_paths, components) do
      case resolved_paths do
        [_ | _] -> {:ok, resolved_paths}
        [] -> {:error, "No matching components found in #{parent_path}"}
      end
    else
      false -> {:error, "Directory not found: #{parent_path}"}
    end
  end

  defp find_matching_components(parent_path, components) do
    components
    |> Enum.filter(&component_exists?(parent_path, &1))
    |> Enum.map(&Path.join(parent_path, &1))
  end

  defp component_exists?(parent_path, component) do
    component_path = Path.join(parent_path, component)
    File.dir?(component_path)
  end

  defp log_missing_components(found_paths, requested_components) do
    found_components = found_paths |> Enum.map(&Path.basename/1) |> MapSet.new()
    missing = MapSet.difference(MapSet.new(requested_components), found_components)

    if not Enum.empty?(missing) do
      Logger.warning(
        "Warning: Could not find the following components: #{Enum.join(missing, ", ")}"
      )
    end

    :ok
  end

  defp resolve_from_paths(base_dir, components, parent_paths) do
    resolved_component_paths =
      parent_paths
      |> Enum.flat_map(&find_components_in_parent_path(base_dir, components, &1))
      |> Enum.reject(&is_nil/1)
      |> tap(&log_missing_path_components(&1, components))

    case resolved_component_paths do
      [_ | _] -> {:ok, resolved_component_paths}
      [] -> {:error, "No components found for the specified paths"}
    end
  end

  defp find_components_in_parent_path(base_dir, components, path) do
    full_path = Path.join(base_dir, path)

    if File.dir?(full_path) do
      components
      |> Enum.filter(&component_exists?(full_path, &1))
      |> Enum.map(&build_valid_component_path(full_path, &1))
    else
      []
    end
  end

  defp build_valid_component_path(full_path, component) do
    component_path = Path.join(full_path, component)
    if Enum.count(Path.split(component_path)) > 1, do: component_path
  end

  defp log_missing_path_components(found_paths, requested_components) do
    found_components = found_paths |> Enum.map(&Path.basename/1) |> MapSet.new()
    missing = MapSet.difference(MapSet.new(requested_components), found_components)

    if not Enum.empty?(missing) do
      Logger.warning(
        "Warning: Could not find the following components: #{Enum.join(missing, ", ")}"
      )
    end
  end

  defp find_components_in_paths(paths, base_dir) do
    paths
    |> Enum.flat_map(fn path ->
      full_path = Path.join(base_dir, path)
      find_components_in_directory(full_path)
    end)
  end

  defp find_components_in_directory(path) do
    if File.dir?(path) do
      File.ls!(path)
      |> Enum.filter(&File.dir?(Path.join(path, &1)))
      |> Enum.map(&build_component_path(path, &1))
      |> Enum.reject(&is_nil/1)
    else
      []
    end
  end

  defp build_component_path(base_path, component) do
    component_path = Path.join(base_path, component)
    if Enum.count(Path.split(component_path)) > 1, do: component_path
  end

  defp handle_component_results([], base_dir),
    do: {:error, "No components found in #{base_dir}"}

  defp handle_component_results(paths, _),
    do: {:ok, paths}
end
