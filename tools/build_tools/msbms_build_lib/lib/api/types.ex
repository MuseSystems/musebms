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

defmodule MsbmsBuildLib.Types do
  @moduledoc """
  Type definitions for the MsbmsBuildLib module.

  This module defines the core types used throughout the build library for
  representing components, paths, artifacts, and other build-related concepts.
  These types ensure consistency and type safety across the build system's API.

  ## Type Categories

  ### Component Types
  - `component_name/0` - Individual component identifiers
  - `components/0` - Collections of component names
  - `component_path/0` - File system paths to components
  - `component_paths/0` - Collections of component paths

  ### Artifact Types
  - `kind/0` - Different types of build artifacts (Elixir, DB, docs)

  ### Migration Types
  - `migration_target/0` - Database migration configuration tuples
  """

  @typedoc """
  A list of component names for batch operations.

  This type represents a collection of component names that can be processed
  together in build operations. An empty list typically indicates that all
  available components should be processed.

  ## Examples

      iex> components = ["mscmp_syst_enums", "mscmp_syst_utils"]
      iex> MsbmsBuildLib.clean_build(base_dir, components)

  """
  @type components() :: list(component_name())

  @typedoc """
  The name of a component in the project.

  Component names should match their representation in the file system exactly.
  This typically uses snake_case naming convention and corresponds to the
  directory name where the component is located.

  ## Naming Convention

  Component names should use the file system representation rather than the
  Elixir module representation:

  - ✅ Correct: `"mscmp_syst_enums"`
  - ❌ Incorrect: `"MscmpSystEnums"`

  ## Examples

      # Valid component names
      "mscmp_syst_enums"
      "mscmp_syst_utils"
      "msapp_mcp_web"
      "mssub_mcp"

  """
  @type component_name() :: String.t()

  @typedoc """
  A fully qualified file system path to a component in the project.

  This represents the absolute path to a component's root directory, where
  the component's source code, configuration files, and other artifacts
  are located. The path should be valid and accessible from the current
  working directory context.

  ## Path Format

  Paths are typically absolute and point to the component's root directory:

      "/full/path/to/project/components/mscmp_syst_enums"
      "/full/path/to/project/apps/msapp_mcp_web"

  ## Usage

  These paths are used internally by build functions to locate and operate
  on specific components within the project structure.
  """
  @type component_path() :: String.t()

  @typedoc """
  A list of fully qualified file system paths to components in the project.

  This collection type is used when build operations need to process multiple
  components by their full paths rather than just their names. It's typically
  used internally after component names have been resolved to their actual
  file system locations.

  ## Usage

  This type is commonly used in internal build pipeline functions where
  the system has already resolved component names to their full paths
  and needs to perform batch operations across multiple components.
  """
  @type component_paths() :: list(component_path())

  @typedoc """
  The different kinds of project artifacts that can be built or managed.

  This type categorizes the various types of build artifacts and outputs
  that the build system can create and manage. Each kind represents a
  different aspect of the project's deliverables.

  ## Artifact Types

  - `:elixir` - Compiled Elixir/Erlang code artifacts including BEAM files,
    applications, and releases. This includes the core application logic
    and libraries.

  - `:db` - Database artifacts including schemas, migrations, stored procedures,
    functions, and other database objects. These define the data layer of
    the application.

  - `:elixir_docs` - Generated documentation for Elixir code using ExDoc.
    This includes API documentation, guides, and module documentation
    extracted from the source code.

  - `:db_docs` - Generated documentation for database objects including
    schema documentation, table descriptions, and database design
    documentation extracted from database metadata and comments.

  ## Usage

  These kinds are used to categorize build operations and determine which
  specific build tools and processes should be applied to different parts
  of the project.
  """
  @type kind() :: :elixir | :db | :elixir_docs | :db_docs

  @typedoc """
  Configuration tuple for components that require persistent database migration management.

  This type associates database migration metadata with component locations,
  enabling the build system to properly manage database schema evolution
  for deployable components.

  ## Target Scope

  Migration targets typically focus on Subsystems, which represent the
  architectural level where complete, deployable databases are defined.
  While other components may create and use migrations during development
  and testing, these are usually transient and not deployed to production
  environments.

  ## Tuple Elements

  * `component_name` - The name of the component as it appears in the file system
    (e.g., `"mssub_mcp"` for the MCP subsystem)

  * `database_type` - A string reference to a specific database buildplan that
    defines the build process for this type of database. This determines which
    migration tools and processes are used (e.g., `"application_db"`,
    `"analytics_db"`)

  * `component_path` - The absolute file system path to the root directory of
    the component's Elixir project, where migration files and configuration
    are located

  ## Examples

      # MCP subsystem with application database
      {"mssub_mcp", "application_db", "/full/path/to/project/subsystems/mssub_mcp"}

      # Analytics subsystem with specialized database
      {"mssub_analytics", "analytics_db", "/full/path/to/project/subsystems/mssub_analytics"}

  ## Usage

  These tuples are used by the migration build system to locate migration
  files, determine the appropriate build process, and coordinate database
  schema updates across different deployment environments.
  """
  @type migration_target() ::
          {component_name :: component_name(), database_type :: String.t(),
           component_path :: Path.t()}
end
