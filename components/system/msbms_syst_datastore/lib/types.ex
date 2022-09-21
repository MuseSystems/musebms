# Source File: types.ex
# Location:    musebms/components/system/msbms_syst_datastore/lib/types.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

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
    can be started and made available as application Datastores.

  * `:server_pools` - The server pools in which the database server
    participates.

  * `:db_host` - The hostname or IP address of the database server on the
    network.

  * `:db_port` - The TCP port on which the database server is listening for
    connections.

  * `:db_show_sensitive` - If true, various logging events may show
    unredacted "sensitive" database connectivity information.  Note that even
    when false, the application still log sensitive application data.


  * `:db_max_instances` - The total number of databases allowed to be
    established for the db_server instance.

  * `:server_salt` - For certain cryptographic operations, such as password
    derivation, allows for the assignment of specific salting value for that is
    specific to a given database server.  This value must be at least 32 bytes
    long and should be a random string.

  * `:dbadmin_password` - The msbms_syst_dba role password for privileged
    operations such as creating a new database/Datastore or new database roles
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
          required(:db_max_instances) => integer(),
          required(:server_salt) => String.t(),
          required(:dbadmin_password) => String.t(),
          required(:dbadmin_pool_size) => integer()
        }

  @typedoc """
  An application wide designation for application defined datastore access
  accounts.
  """
  @type context_name() :: atom() | nil

  @typedoc """
  The database role name for the specific access context defined by the
  `context_name()`.
  """
  @type context_role :: String.t()

  @typedoc """
  Defines an application level security context which maps to a specific
  database role.

  Datastore contexts allow the application to access the database using database
  roles which are limited by their database security configuration.


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
  """
  @type datastore_context :: %{
          optional(:context_name) => context_name(),
          optional(:description) => String.t(),
          optional(:database_role) => context_role(),
          optional(:database_password) => String.t() | nil,
          optional(:starting_pool_size) => integer(),
          optional(:start_context) => boolean(),
          optional(:login_context) => boolean(),
          optional(:database_owner_context) => boolean()
        }

  @typedoc """
  Defines the options required for establishing the database connections which
  make up a Datastore.

    * `:database_name` - The name of the database in the database server to
      which the connection will be made.  Often times this value will be the
      same as the String.t() form of the `:datastore_name` value.

    * `:datastore_code` - Defines a Datastore specific salting value for use in
      certain security and cryptographic related functions.

    * `:datastore_name` - A name for use by the application to identify a given
      datastore.  This value will often time be the same as the `:database_name`
      value, except as an atom() rather than a String.t().

    * `:contexts` - A list of available Datastore Context values defining which
      contexts are available for this Datastore.  See `datastore_context()` for
      more information concerning the values of each entry in the list.

    * `:db_server` - The database server information for the server where the
      Datastore database resides.  See `db_server()` for additional details.
  """
  @type datastore_options :: %{
          required(:database_name) => String.t(),
          optional(:datastore_code) => String.t(),
          optional(:datastore_name) => atom(),
          required(:contexts) => [datastore_context()] | [],
          required(:db_server) => db_server()
        }

  @typedoc """
  Values indicating the state of the database which backs a given Datastore.

    * `:not_found` - The database for the Datastore does not exist on the
      database server.

    * `:ready` - The database is ready for further processing by the migrations
      subsystem.
  """
  @type database_state_values :: :not_found | :ready

  @typedoc """
  Defines the available states in which a context may exist.

    * `:not_found` - The database role backing the context was not found on the
      Datastore database server.

    * `:not_ready` - The database role backing the context exists, but is not
      completely set up yet.  This is an interim stage that usually has to cross
      transaction boundaries.

    * `:not_started` - When starting contexts the system doesn't check for the
       existence of each context which in turn means that a start failure could
       be indicative of either non-existence or some other problem.  In these
       start-up scenarios the state would be `:not_started`.

    * `:ready` - The context was found and may be connected to the database, but
      the database connections for the context have not been started yet.

    * `:started` - The context was found and database connections for the
      context have already been started.
  """
  @type context_state_values :: :not_found | :not_ready | :ready | :not_started | :started

  @typedoc """

  """
  @type context_state :: %{context: context_name(), state: context_state_values()}

  @typedoc """
  Defines the available states in which a Datastore might exist in relation to
  its schema migrations.

    * `:not_initialized` - The Datastore does not have the table which manages
      the migrations installed.  This is also the value reported when the
      `database_state_values()` value for the Datastore is `:not_found`.

    * `:not_updated` - The Datastore database exists and has been initialized,
      but does not have the most recent migrations available applied per the
      migrations management table.

    * `:ready` - The migrations are fully up-to-date and the Datastore is ready
      to serve the application as needed.
  """
  @type migration_state_values :: :not_initialized | :not_updated | :ready

  @typedoc """
  Defines operators for use in comparison functions.

  These operators are used in conjunction with the `MsbmsSystDatastore.DbTypes`
  and `MsbmsSystDatastore.DbTypes.Range` protocols.

  The range related operator values are generally the same as those defined by
  the PostgreSQL database range types, but there are some small differences.

    * `:gt` - left is greater than right.

    * `:lt` - left is less than right.

    * `:eq` - the values are equal.

    * `:lcr` - left contains right.

    * `:rcl` - right contains left.

    * `:gto` - greater than overlapping.

    * `:lto` - less than overlapping.

  # Examples

  Greater Than (`:gt`)

      iex> left_range =
      ...>   %MsbmsSystDatastore.DbTypes.IntegerRange{
      ...>     lower: 200,
      ...>     upper: 210
      ...>   }
      iex> right_range =
      ...>   %MsbmsSystDatastore.DbTypes.IntegerRange{
      ...>     lower: 100,
      ...>     upper: 110
      ...>   }
      iex> MsbmsSystDatastore.DbTypes.compare(left_range, right_range)
      :gt

  Less Than (`:lt`)

      iex> left_range =
      ...>   %MsbmsSystDatastore.DbTypes.IntegerRange{
      ...>     lower: 100,
      ...>     upper: 110
      ...>   }
      iex> right_range =
      ...>   %MsbmsSystDatastore.DbTypes.IntegerRange{
      ...>     lower: 200,
      ...>     upper: 210
      ...>   }
      iex> MsbmsSystDatastore.DbTypes.compare(left_range, right_range)
      :lt

  Equal (`:eq`)

      iex> left_range =
      ...>   %MsbmsSystDatastore.DbTypes.IntegerRange{
      ...>     lower: 100,
      ...>     upper: 110
      ...>   }
      iex> right_range =
      ...>   %MsbmsSystDatastore.DbTypes.IntegerRange{
      ...>     lower: 100,
      ...>     upper: 110
      ...>   }
      iex> MsbmsSystDatastore.DbTypes.compare(left_range, right_range)
      :eq

  Left Contains Right (`:lcr`)

      iex> left_range =
      ...>   %MsbmsSystDatastore.DbTypes.IntegerRange{
      ...>     lower: 90,
      ...>     upper: 110
      ...>   }
      iex> right_range =
      ...>   %MsbmsSystDatastore.DbTypes.IntegerRange{
      ...>     lower: 100,
      ...>     upper: 110
      ...>   }
      iex> MsbmsSystDatastore.DbTypes.compare(left_range, right_range)
      :lcr

  Right Contains Left (`:rcl`)

      iex> left_range =
      ...>   %MsbmsSystDatastore.DbTypes.IntegerRange{
      ...>     lower: 100,
      ...>     upper: 110
      ...>   }
      iex> right_range =
      ...>   %MsbmsSystDatastore.DbTypes.IntegerRange{
      ...>     lower: 100,
      ...>     upper: 111
      ...>   }
      iex> MsbmsSystDatastore.DbTypes.compare(left_range, right_range)
      :rcl


  Greater Than Overlapping (`:gto`)

      iex> left_range =
      ...>   %MsbmsSystDatastore.DbTypes.IntegerRange{
      ...>     lower: 150,
      ...>     upper: 250
      ...>   }
      iex> right_range =
      ...>   %MsbmsSystDatastore.DbTypes.IntegerRange{
      ...>     lower: 100,
      ...>     upper: 175
      ...>   }
      iex> MsbmsSystDatastore.DbTypes.compare(left_range, right_range)
      :gto


  Less Than Overlapping (`:lto`)

      iex> left_range =
      ...>   %MsbmsSystDatastore.DbTypes.IntegerRange{
      ...>     lower: 100,
      ...>     upper: 150
      ...>   }
      iex> right_range =
      ...>   %MsbmsSystDatastore.DbTypes.IntegerRange{
      ...>     lower: 125,
      ...>     upper: 175
      ...>   }
      iex> MsbmsSystDatastore.DbTypes.compare(left_range, right_range)
      :lto
  """
  @type db_type_comparison_operators ::
          :gt
          | :lt
          | :eq
          | :lcr
          | :rcl
          | :gto
          | :lto

  @typedoc """
  The comparison operators for both the lower and upper bounds of a range type.

  There are cases where normal comparisons are too coarse-grained to provide a
  meaningful result when dealing with ranges.  In these cases you need the
  detailed lower/upper comparison results.
  """
  @type bounds_compare_result :: %{
          lower_comparison: db_type_comparison_operators(),
          upper_comparison: db_type_comparison_operators()
        }

  @typedoc """
  Options which are expected by the `Timex` library.

  The `MsbmsSystDatastore.DbTypes.Interval` struct can be converted into a form
  which can be consumed by `Timex.shift/2` and this type defines the possible
  return values.

  Note that this type should closely match the `t:Timex.shift_options` types
  except that we limit it to the types present in the
  `t:MsbmsSystDatastore.DbTypes.Interval.t` data type.
  """
  @type timex_shift_options :: [
          microseconds: integer(),
          seconds: integer(),
          days: integer(),
          months: integer()
        ]
end
