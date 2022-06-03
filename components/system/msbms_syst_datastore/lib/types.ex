# Source File: types.ex
# Location:    components/system/msbms_syst_datastore/lib/types.ex
# Project:     msbms
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https: //muse.systems

defmodule MsbmsSystDatastore.Types do
  @moduledoc """
  Defines public types for use with the MsbmsSystDatastore module.
  """

  @typedoc """
  Represents a specific database server.

  The data in the map includes fields which uniquely identifies the server,
  provides information for where on the network the server can be found, and
  connection related parameters.  Also, the full administrative credentials are
  included.

  * `:server_name` - Provides a unique identifier for a database server
    instance.

  * `:start_server_instances` - If true, indicates that databases on the server
    can be started and made available as application datastores.

  * `:

  * `:db_host` - The hostname or IP address of the database server on the
    network.

  * `:db_port` - The TCP port on which the database server is listening for
    connections.

  * `:db_show_sensitive` - If true, various logging events may show
    unredacted "sensitive" database connectivity information.  Note that even
    when false, the application still log sensitive application data.

  * `:db_log_level` - Sets the `Logger` module log level for the database
    connection to the server.  (default `:debug`)

  * `:db_max_instances` - The total number of databases allowed to be
    established for the db_server instance.

  * `:server_salt` - For certain cryptographic operations, such as password
    derivation, allows for the assignment of specific salting value for that is
    specific to a given database server.  This value must be at least 32 bytes
    long and should be a random string.

  * `:dbadmin_password` - The msbms_syst_dba role password for privileged
    operations such as creating a new database/datastore or new database roles
    on the database server instance.

  * `:dbadmin_pool_size` - The pool size to use for creating connections for
    privileged operations using the msbms_syst_dba role.

  """

  @type db_server :: %{
          required(:server_name) => String.t(),
          required(:start_server_instances) => boolean(),
          required(:server_pools) => list(String.t()) | [],
          required(:db_host) => String.t(),
          required(:db_port) => integer(),
          required(:db_show_sensitive) => boolean(),
          required(:db_log_level) => Logger.level(),
          required(:db_max_instances) => integer(),
          required(:server_salt) => String.t(),
          required(:dbadmin_password) => String.t(),
          required(:dbadmin_pool_size) => integer()
        }

  @typedoc """
  An application wide designation for application defined datastore access
  accounts.
  """
  @type context_id :: atom() | nil

  @typedoc """
  The database role name for the specific access context defined by the
  `context_id()`.
  """
  @type context_role :: String.t()

  @typedoc """
  Defines an application level security context which maps to a specific
  database role.

  Datastore contexts allow the application to access the database using database
  roles which are limited by their database security configuration.


    * `:id` - The application's identifier for a specific security context.
      This isn't specific to a particular database, but to the application
      overall.

    * `:description` - A user friendly description of the context.

    * `:database_role` - Maps the application context to a specific database
      role.  When establishing a connection to a database, this is the database
      role name that will be used.

    * `:database_password` - The password used to connect the `:database_role`
      to the database server.

    * `:starting_pool_size` - The number of database connections to initially
      open for this context.

    * `:start_context` - When working with application database connections
      which are started and pooled at application start time, this value
      indicates whether or not the specific context should be started as normal.
      For normal startup to take place, both this value and the `:login_context`
      value must be true.  This setting is disregarded in operations involving
      database connections which are established on demand as needed, such as
      DBA related connections.

    * `:login_context` - If `true`, the context is a normal context associated
      with a database login role and will be used in establishing connections to
      the database.  If `false`, the context is an administrative context which
      is only used in security definitions within the database.  Database owner
      roles, roles which own all of the application database tables/functions
      would typically not be login roles, even though the are highly privileged
      when their context is active in a database session. (default: true)
  """
  @type datastore_context :: %{
          optional(:id) => context_id(),
          required(:description) => String.t(),
          required(:database_role) => context_role(),
          optional(:database_password) => String.t() | nil,
          required(:starting_pool_size) => integer(),
          required(:start_context) => boolean(),
          optional(:login_context) => boolean()
        }

  @typedoc """
  Defines the options required for establishing the database connections which
  make up a datastore.

    * `:database_name` - The name of the database in the database server to
      which the connection will be made.  Often times this value will be the
      same as the String.t() form of the `:datastore_name` value.

    * `:database_owner` - The database role which owns the database and its
      objects.  This is typically not a login account, but is used during
      database creation or updating functions.

    * `:datastore_code` - Defines a datastore specific salting value for use in
      certain security and cryptographic related functions.

    * `:datastore_name` - A name for use by the application to identify a given
      datastore.  This value will often time be the same as the `:database_name`
      value, except as an atom() rather than a String.t().

    * `:contexts` - A list of available datastore context values defining which
      contexts are available for this datastore.  See `datastore_context()` for
      more information concerning the values of each entry in the list.

    * `:db_server` - The database server information for the server where the
      datastore database resides.  See `db_server()` for additional details.
  """
  @type datastore_options :: %{
          required(:database_name) => String.t(),
          optional(:database_owner) => String.t(),
          optional(:datastore_code) => String.t(),
          optional(:datastore_name) => atom(),
          required(:contexts) => [datastore_context()] | [],
          required(:db_server) => db_server()
        }

  @typedoc """
  Values indicating the state of the database which backs a given datastore.

    * `:not_found` - The database for the datastore does not exist on the
      database server.

    * `:ready` - The database is ready for further processing by the migrations
      subsystem.
  """
  @type database_state_values :: :not_found | :ready

  @typedoc """
  Defines the available states in which a context may exist.

    * `:not_found` - The database role backing the context was not found on the
      datastore database server.

    * `:not_started` - When starting contexts the system doesn't check for the
       existence of each context which in turn means that a start failure could
       be indicative of either non-existence or some other problem.  In these
       start-up scenarios the state would be `:not_started`.

    * `:ready` - The context was found and may be connected to the database, but
      the database connections for the context have not been started yet.

    * `:started` - The context was found and database connections for the
      context have already been started.
  """
  @type context_state_values :: :not_found | :ready | :not_started | :started

  @typedoc """

  """
  @type context_state :: %{context: context_id(), state: context_state_values()}

  @typedoc """
  Defines the available states in which a datastore might exist in relation to
  its schema migrations.

    * `:not_initialized` - The datastore does not have the table which manages
      the migrations installed.  This is also the value reported when the
      `database_state_values()` value for the datastore is `:not_found`.

    * `:not_updated` - The datastore database exists and has been initialized,
      but does not have the most recent migrations available applied per the
      migrations management table.

    * `:ready` - The migrations are fully up-to-date and the datastore is ready
      to serve the application as needed.
  """
  @type migration_state_values :: :not_initialized | :not_updated | :ready
end
