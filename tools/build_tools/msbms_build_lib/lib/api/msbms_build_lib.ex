# Source File: msbms_build_lib.ex
# Location:    musebms/tools/build_tools/msbms_build_lib/lib/api/msbms_build_lib.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MsbmsBuildLib do
  @external_resource "README.md"
  @moduledoc Path.join([__DIR__, "..", "..", "README.md"])
             |> File.read!()
             |> String.split("<!-- MDOC !-->")
             |> Enum.fetch!(1)

  alias MsbmsBuildLib.Impl
  alias MsbmsBuildLib.Types

  # ==============================================================================================
  # ==============================================================================================
  #
  # Constants Retrieval Functions
  #
  # ==============================================================================================
  # ==============================================================================================

  @doc """
  Get the project directories.

  Returns a list of standard project directory names used throughout the build system.

  ## Returns
    * List of project directory names as strings
  """
  @spec project_directories() :: [String.t(), ...]
  defdelegate project_directories(), to: Impl.Common

  @doc """
  Get the project markers.

  Returns a list of file markers that identify project boundaries or special locations.

  ## Returns
    * List of project marker file names as strings
  """
  @spec project_markers() :: [String.t(), ...]
  defdelegate project_markers(), to: Impl.Common

  @doc """
  Get the Elixir component paths.

  Returns a list of relative paths where Elixir components are located within the project.

  ## Returns
    * List of Elixir component paths as strings
  """
  @spec elixir_component_paths() :: [String.t(), ...]
  defdelegate elixir_component_paths(), to: Impl.Common

  @doc """
  Get the Elixir docs root.

  Returns the root directory path where Elixir documentation should be generated.

  ## Returns
    * Root path for Elixir documentation as a string
  """
  @spec elixir_docs_root() :: String.t()
  defdelegate elixir_docs_root(), to: Impl.Common

  @doc """
  Get the DB docs root.

  Returns the root directory path where database documentation should be generated.

  ## Returns
    * Root path for database documentation as a string
  """
  @spec db_docs_root() :: String.t()
  defdelegate db_docs_root(), to: Impl.Common

  @doc """
  Get the DB component paths.

  Returns a list of relative paths where database components are located within the project.

  ## Returns
    * List of database component paths as strings
  """
  @spec db_component_paths() :: [String.t(), ...]
  defdelegate db_component_paths(), to: Impl.Common

  # ==============================================================================================
  # ==============================================================================================
  #
  # Build Cleaning Functions
  #
  # ==============================================================================================
  # ==============================================================================================

  ##############################################################################
  #
  # clean_ls
  #
  #

  @doc """
  Cleans the Elixir Language Server in the given components.

  ## Parameters
    * `base_dir` - The base directory path
    * `components` - List of component names to clean

  ## Returns
    * `:ok` on successful cleanup
    * `{:error, message}` if cleanup fails
  """
  @spec clean_ls(Path.t(), Types.components()) :: :ok | {:error, message :: String.t()}
  defdelegate clean_ls(base_dir, components), to: Impl.CleanElixir

  ##############################################################################
  #
  # clean_plt
  #
  #

  @doc """
  Cleans the PLT (Persistent Lookup Table) in the given components.

  Removes Dialyzer PLT files that cache type information for faster subsequent analysis.

  ## Parameters
    * `base_dir` - The base directory path
    * `components` - List of component names to clean

  ## Returns
    * `:ok` on successful cleanup
    * `{:error, message}` if cleanup fails
  """
  @spec clean_plt(Path.t(), Types.components()) :: :ok | {:error, message :: String.t()}
  defdelegate clean_plt(base_dir, components), to: Impl.CleanElixir

  ##############################################################################
  #
  # clean_build
  #
  #

  @doc """
  Cleans the build artifacts in the given components.

  Removes compiled beam files, build directories, and other compilation artifacts.

  ## Parameters
    * `base_dir` - The base directory path
    * `components` - List of component names to clean

  ## Returns
    * `:ok` on successful cleanup
    * `{:error, message}` if cleanup fails
  """
  @spec clean_build(Path.t(), Types.components()) :: :ok | {:error, message :: String.t()}
  defdelegate clean_build(base_dir, components), to: Impl.CleanElixir

  ##############################################################################
  #
  # clean_deps
  #
  #

  @doc """
  Cleans the dependencies in the given components.

  Removes downloaded and compiled dependency files, forcing a fresh dependency resolution
  on the next build.

  ## Parameters
    * `base_dir` - The base directory path
    * `components` - List of component names to clean

  ## Returns
    * `:ok` on successful cleanup
    * `{:error, message}` if cleanup fails
  """
  @spec clean_deps(Path.t(), Types.components()) :: :ok | {:error, message :: String.t()}
  defdelegate clean_deps(base_dir, components), to: Impl.CleanElixir

  ##############################################################################
  #
  # clean_db
  #
  #

  @doc """
  Cleans the database for the given components.

  Drops and recreates database schemas, removing all data and schema objects
  for a fresh start. This is a destructive operation.

  ## Parameters
    * `base_dir` - The base directory path
    * `db_opts` - Keyword list of database connection options:
      * `:host` - Database host (default: "127.0.0.1")
      * `:port` - Database port (default: 5432)
      * `:user` - Database user (required)
      * `:password` - Database password (required)
      * `:database` - Database name (default: "postgres")
      * `:dbadmin_password` - Database admin password (default: "musesystems-insecure-publicly-known-password")

  ## Returns
    * `:ok` on successful database cleanup
    * `{:error, message}` if cleanup fails
  """
  @spec clean_db(Path.t(), Keyword.t()) ::
          :ok | {:error, message :: String.t()}
  defdelegate clean_db(base_dir, db_opts), to: Impl.CleanDb

  ##############################################################################
  #
  # clean_db_migrations
  #
  #

  @doc """
  Cleans the database migrations for the given components.

  Removes migration tracking state and history, allowing migrations to be re-run
  from scratch. Does not affect the actual database schema.

  ## Parameters
    * `base_dir` - The base directory path
    * `components` - List of component names to clean

  ## Returns
    * `:ok` on successful cleanup
    * `{:error, message}` if cleanup fails
  """
  @spec clean_db_migrations(Path.t(), Types.components()) :: :ok | {:error, message :: String.t()}
  defdelegate clean_db_migrations(base_dir, components), to: Impl.CleanElixir

  # ==============================================================================================
  # ==============================================================================================
  #
  # Build Documentation Functions
  #
  # ==============================================================================================
  # ==============================================================================================

  ##############################################################################
  #
  # build_docs_elixir
  #
  #

  @doc """
  Builds the Elixir documentation for the given components.

  Generates ExDoc documentation for the specified Elixir components using their respective
  documentation configurations.

  ## Parameters
    * `base_dir` - The base directory path where the project is located
    * `components` - List of component names to generate documentation for

  ## Returns
    * `:ok` on successful documentation generation
    * `{:error, message}` if documentation generation fails
  """
  @spec build_docs_elixir(Path.t(), Types.components()) :: :ok | {:error, message :: String.t()}
  defdelegate build_docs_elixir(base_dir, components), to: Impl.DocsElixir

  ##############################################################################
  #
  # build_docs_db
  #
  #

  @doc """
  Builds the DB documentation for the given components.

  Generates database documentation by extracting schema information and comments
  from the database and creating formatted documentation files.

  ## Parameters
    * `base_dir` - The base directory path where the project is located
    * `components` - List of component names to build documentation for
    * `db_opts` - Keyword list of database connection options:
      * `:host` - Database host (default: "127.0.0.1")
      * `:port` - Database port (default: 5432)
      * `:user` - Database user (required)
      * `:password` - Database password (required)
      * `:database` - Database name (default: "postgres")
      * `:dbadmin_password` - Database admin password (default: "musesystems-insecure-publicly-known-password")

  ## Returns
    * `:ok` on successful documentation generation
    * `{:error, message}` if documentation generation fails
  """
  @spec build_docs_db(Path.t(), Types.components(), Keyword.t()) ::
          :ok | {:error, message :: String.t()}
  defdelegate build_docs_db(base_dir, components, db_opts), to: Impl.DocsDb

  # ==============================================================================================
  # ==============================================================================================
  #
  # Dependency Management Functions
  #
  # ==============================================================================================
  # ==============================================================================================

  ##############################################################################
  #
  # install_elixir_deps
  #
  #

  @doc """
  Installs Elixir dependencies for the given components.

  Downloads and compiles all required dependencies for the specified components,
  ensuring they are available for compilation and runtime.

  ## Parameters
    * `base_dir` - The base directory path where the project is located
    * `components` - List of component names to install dependencies for

  ## Returns
    * `:ok` on successful dependency installation
    * `{:error, message}` if installation fails
  """
  @spec install_elixir_deps(Path.t(), Types.components()) :: :ok | {:error, message :: String.t()}
  defdelegate install_elixir_deps(base_dir, components), to: Impl.DepsElixir

  ##############################################################################
  #
  # update_elixir_deps
  #
  #

  @doc """
  Updates Elixir dependencies for the given components.

  Updates all dependencies to their latest compatible versions as specified
  in the dependency configuration files.

  ## Parameters
    * `base_dir` - The base directory path where the project is located
    * `components` - List of component names to update dependencies for

  ## Returns
    * `:ok` on successful dependency update
    * `{:error, message}` if update fails
  """
  @spec update_elixir_deps(Path.t(), Types.components()) :: :ok | {:error, message :: String.t()}
  defdelegate update_elixir_deps(base_dir, components), to: Impl.DepsElixir

  # ==============================================================================================
  # ==============================================================================================
  #
  # Test Execution Functions
  #
  # ==============================================================================================
  # ==============================================================================================

  ##############################################################################
  #
  # run_tests
  #
  #

  @doc """
  Runs tests for the given components.

  Executes various types of tests including unit tests, integration tests, doctests,
  code quality checks (Credo), and static analysis (Dialyzer) based on the provided options.

  ## Parameters
    * `base_dir` - The base directory path where the project is located
    * `components` - List of component names to test (empty list means all components)
    * `opts` - Keyword list of test options:
      * `:test_unit` - Whether to run unit tests (default: true)
      * `:test_integration` - Whether to run integration tests (default: true)
      * `:test_doctest` - Whether to run doctests (default: true)
      * `:run_credo` - Whether to run credo tests (default: true)
      * `:run_dialyzer` - Whether to run dialyzer tests (default: true)

  ## Returns
    * `:ok` if all specified tests pass
    * `{:error, message}` if any tests fail
  """
  @spec run_tests(Path.t(), Types.components(), Keyword.t()) ::
          :ok | {:error, message :: String.t()}
  defdelegate run_tests(base_dir, components, opts \\ []), to: Impl.TestsElixir

  # ==============================================================================================
  # ==============================================================================================
  #
  # Build Elixir Functions
  #
  # ==============================================================================================
  # ==============================================================================================

  ##############################################################################
  #
  # build_elixir
  #
  #

  @doc """
  Builds the Elixir project.

  Compiles the Elixir components for the specified environment, handling dependencies
  and compilation in the correct order.

  ## Parameters
    * `base_dir` - The base directory path where the project is located
    * `components` - List of component names to build
    * `elixir_env` - The Elixir environment to build for (e.g., "dev", "test", "prod")

  ## Returns
    * `:ok` on successful build completion
    * `{:error, message}` if the build fails
  """
  @spec build_elixir(Path.t(), Types.components(), String.t()) ::
          :ok | {:error, message :: String.t()}
  defdelegate build_elixir(base_dir, components, elixir_env), to: Impl.BuildElixir

  # ==============================================================================================
  # ==============================================================================================
  #
  # Build Migrations Functions
  #
  # ==============================================================================================
  # ==============================================================================================

  ##############################################################################
  #
  # build_migrations
  #
  #

  @doc """
  Builds the database migrations for the given components.

  Processes and prepares database migration files for the specified components,
  ensuring they are ready for execution against the target database.

  ## Parameters
    * `base_dir` - The base directory path where the project is located
    * `components` - List of component names to build migrations for

  ## Returns
    * `:ok` on successful migration build completion
    * `{:error, message}` if the migration build fails
  """
  @spec build_migrations(Path.t(), Types.components()) ::
          :ok | {:error, message :: String.t()}
  defdelegate build_migrations(base_dir, components), to: Impl.BuildDb

  # ==============================================================================================
  # ==============================================================================================
  #
  # Utility Functions
  #
  # ==============================================================================================
  # ==============================================================================================

  @doc """
  Sets the log level for the build system.

  Configures the logging level for all build operations, controlling the verbosity
  of output during build processes.

  ## Parameters
    * `level` - The desired log level (`:debug`, `:info`, `:warning`, `:error`)

  ## Returns
    * `:ok` - Always returns `:ok`
  """
  @spec set_log_level(Logger.level()) :: :ok
  defdelegate set_log_level(level), to: Impl.Common

  @doc """
  Reads and parses a component list file.

  The file format supports:
  - One component name per line
  - Comments starting with `#` are ignored
  - Empty lines are ignored
  - Leading/trailing whitespace is trimmed

  ## Parameters
    * `base_dir` - The base directory path where the project is located
    * `file_path` - Path to the component file (relative to base_dir)

  ## Returns
    * `{:ok, components}` - List of component names from the file
    * `{:error, reason}` - Error message if file cannot be read or parsed
  """
  @spec read_component_file(Path.t(), Path.t()) :: {:ok, [String.t()]} | {:error, String.t()}
  defdelegate read_component_file(base_dir, file_path), to: Impl.Common
end
