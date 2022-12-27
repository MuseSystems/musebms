# Source File: types.ex
# Location:    musebms/components/system/mscmp_syst_app_subsystem/lib/types.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystAppSubsystem.Types do
  @moduledoc """
  Types defined and used by the MscmpSystAppSubsystem component.
  """

  @typedoc """
  A type allowing Application Subsystems to describe the Datastore Contexts they
  define to exist in the system.

  All attributes are required.

  ## Attributes

    * `internal_name` - the Internal Name of the Application Context.  Note that
    this name is used in deriving Application Instance Contexts which describe
    actual database roles.  This value should be unique in both the defining
    Application Subsystem and across all subsystems generally.

    * `display_name` - an end user visible display name uniquely identifying the
    Application Context.  This value should be unique in both the defining
    Application Subsystem and across all subsystems generally.

    * `description` - a description of the Application Context and the function
    it serves in the Application.

    * `start_context` - if the Application Context represent a database
    connecting Context, this value establishes if, by default, a derived
    Instance Context should be started when Instance starting functions are
    called.  If the Context doesn't represent a Login Context, such as the
    Database Owner Context, this value should be false.

    * `login_context` - if the Application Context represents a database
    connecting Context, this value should be true.  If database connections
    should not be possible for derived Instance Contexts, such as the is the
    case for Database Owner Contexts, this value should be set false.

    * `database_owner_context` - if true, indicates that the Application Context
    represents the database owning/privileged role.  This role will not be
    allowed to be a login role so if this value is true, `start_context` and
    `login_context` should both be set `false`.  Not that there must be one
    and only one Database Owner Context for each Application Subsystem.
  """
  @type application_context() :: %{
          required(:internal_name) => String.t(),
          required(:display_name) => String.t(),
          required(:description) => String.t(),
          required(:start_context) => boolean(),
          required(:login_context) => boolean(),
          required(:database_owner_context) => boolean()
        }

  @typedoc """
  Describes the Application to the Application Platform and other subsystems
  needing the information.

  ## Attributes

    * `internal_name` - the Internal Name of the Application.  This value must
    be unique amongst all known Application Subsystems.

    * `display_name` - an end user visible name for the Application.  This value
    must be unique amongst all known Application Subsystems.

    * `syst_description` - an end user visible description for the Application.

    * `contexts` - the list of Datastore Contexts that the Application required.
    For more about Datastore Contexts see `MscmpSystDb`.

  """
  @type application() :: %{
          required(:internal_name) => String.t(),
          required(:display_name) => String.t(),
          required(:syst_description) => String.t(),
          required(:contexts) => list(application_context())
        }
end
