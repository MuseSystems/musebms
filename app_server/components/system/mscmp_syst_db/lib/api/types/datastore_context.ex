# Source File: datastore_context.ex
# Location:    musebms/app_server/components/system/mscmp_syst_db/lib/api/types/datastore_context.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystDb.Types.DatastoreContext do
  @moduledoc """
  A struct defining an application level security context which maps to a
  specific database role.

  Datastore contexts allow the application to access the database using database
  roles which are limited by their database security configuration.
  """

  defstruct [
    :context_name,
    :description,
    :database_role,
    :database_password,
    :starting_pool_size,
    :start_context,
    :login_context,
    :database_owner_context
  ]

  @typedoc """
  A struct defining an application level security context which maps to a
  specific database role.

  ## Attributes

    * `:context_name` - the application's identifier for a specific security context.
      This isn't specific to a particular database, but to the application
      overall.

    * `:description` - a user friendly description of the context.

    * `:database_role` - maps the application context to a specific database
      role.  When establishing a connection to a database, this is the database
      role name that will be used.

    * `:database_password` - the password used to connect the `:database_role`
      to the database server.

    * `:starting_pool_size` - the number of database connections to initially
      open for this context.

    * `:start_context` - when working with application database connections
      which are started and pooled at application start time, this value
      indicates whether or not the specific context should be started as normal.
      For normal startup to take place, both this value and the `:login_context`
      value must be true.  This setting is disregarded in operations involving
      database connections which are established on demand as needed, such as
      DBA related connections.

    * `:login_context` - if `true`, the context is a normal context associated
      with a database login role and will be used in establishing connections to
      the database.  If `false`, the context is an administrative context which
      is only used in security definitions within the database.  Database owner
      roles, roles which own all of the application database tables/functions
      would typically not be login roles, even though the are highly privileged
      when their context is active in a database session. (default: true)

    * `:database_owner_context` - if `true` the context represents the database
      owner role.  If `false` or not provided the database role is not used for
      this purpose.  Note that there should only be one context defined as the
      database owner for any Datastore.

  For more see `MscmpSystDb.Types.DatastoreContext`.
  """
  @type t :: %__MODULE__{
          context_name: MscmpSystDb.Types.context_name() | nil,
          description: String.t() | nil,
          database_role: MscmpSystDb.Types.context_role() | nil,
          database_password: String.t() | nil,
          starting_pool_size: integer() | nil,
          start_context: boolean() | nil,
          login_context: boolean() | nil,
          database_owner_context: boolean() | nil
        }
end
