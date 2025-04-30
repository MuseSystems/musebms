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
  Types used by the MsbmsBuildLib module.
  """

  @typedoc """
  A list of component names.
  """
  @type components() :: list(component_name())

  @typedoc """
  The name of a component in the project.

  The name of the component should be as represented in the file system.  For
  example `mscmp_syst_enums` rather than `MscmpSystEnums` as might appear in
  Elixir code.
  """
  @type component_name() :: String.t()

  @typedoc """
  A fully qualified path to a component in the project.
  """
  @type component_path() :: String.t()

  @typedoc """
  A list of fully qualified paths to components in the project.
  """
  @type component_paths() :: list(component_path())

  @typedoc """
  The kinds of project artifacts that exist.
  """
  @type kind() :: :elixir | :db | :elixir_docs | :db_docs

  @typedoc """
  For Components which require persistent migration management, this type
  associates the type of database with the root path of the Component.

  Typically this will only target Subsystems as they are the level at which
  fully realized and deployable databases are defined; other Components may
  create and use migrations transiently during development and testing
  processes, but typically these are not deployed outside of those purposes.

  ## Tuple Elements

  * `component_name`: The name of the Component.

  * `database_type`: A reference to specific database `buildplan` which defines
    how to build database migrations for the type of database required.

  * `component_path`: The path to the root of the Component Elixir project.
  """
  @type migration_target() ::
          {component_name :: component_name(), database_type :: String.t(),
           component_path :: Path.t()}
end
