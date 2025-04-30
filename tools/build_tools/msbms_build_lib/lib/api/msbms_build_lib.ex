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
  """
  @spec project_directories() :: [String.t(), ...]
  defdelegate project_directories(), to: Impl.Common

  @doc """
  Get the project markers.
  """
  @spec project_markers() :: [String.t(), ...]
  defdelegate project_markers(), to: Impl.Common

  @doc """
  Get the Elixir component paths.
  """
  @spec elixir_component_paths() :: [String.t(), ...]
  defdelegate elixir_component_paths(), to: Impl.Common

  @doc """
  Get the Elixir docs root.
  """
  @spec elixir_docs_root() :: String.t()
  defdelegate elixir_docs_root(), to: Impl.Common

  @doc """
  Get the DB docs root.
  """
  @spec db_docs_root() :: String.t()
  defdelegate db_docs_root(), to: Impl.Common

  @doc """
  Get the DB component paths.
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
  """
  @spec clean_ls(Path.t(), Types.components()) :: :ok | {:error, message :: String.t()}
  defdelegate clean_ls(base_dir, components), to: Impl.CleanElixir

  ##############################################################################
  #
  # clean_plt
  #
  #

  @doc """
  Cleans the PLT in the given components.

  ## Parameters
    * `base_dir` - The base directory path
    * `components` - List of component names to clean
  """
  @spec clean_plt(Path.t(), Types.components()) :: :ok | {:error, message :: String.t()}
  defdelegate clean_plt(base_dir, components), to: Impl.CleanElixir

  ##############################################################################
  #
  # clean_build
  #
  #

  @doc """
  Cleans the build in the given components.

  ## Parameters
    * `base_dir` - The base directory path
    * `components` - List of component names to clean
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

  ## Parameters
    * `base_dir` - The base directory path
    * `components` - List of component names to clean
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

  ## Parameters
    * `base_dir` - The base directory path
    * `db_opts` - Keyword list of database connection options:
      * `:host` - Database host (default: "127.0.0.1")
      * `:port` - Database port (default: 5432)
      * `:user` - Database user (required)
      * `:password` - Database password (required)
      * `:database` - Database name (default: "postgres")
      * `:dbadmin_password` - Database admin password (default: "musesystems-insecure-publicly-known-password")
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

  ## Parameters
    * `base_dir` - The base directory path
    * `components` - List of component names to clean
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

  ## Parameters
    * `base_dir` - The base directory path
    * `components` - List of component names to clean
    * `db_opts` - Keyword list of database connection options:
      * `:host` - Database host (default: "127.0.0.1")
      * `:port` - Database port (default: 5432)
      * `:user` - Database user (required)
      * `:password` - Database password (required)
      * `:database` - Database name (default: "postgres")
      * `:dbadmin_password` - Database admin password (default: "musesystems-insecure-publicly-known-password")
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

  ## Parameters
    * `base_dir` - The base directory path
    * `components` - List of component names to install dependencies for
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

  ## Parameters
    * `base_dir` - The base directory path
    * `components` - List of component names to update dependencies for
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

  ## Parameters
    * `base_dir` - The base directory path
    * `components` - List of component names to test (empty list means all components)
    * `opts` - Keyword list of test options:
      * `:test_unit` - Whether to run unit tests
      * `:test_integration` - Whether to run integration tests
      * `:test_doctest` - Whether to run doctests
      * `:run_credo` - Whether to run credo tests
      * `:run_dialyzer` - Whether to run dialyzer tests
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
  """
  @spec set_log_level(Logger.level()) :: :ok
  defdelegate set_log_level(level), to: Impl.Common
end
