# Source File: types.ex
# Location:    musebms/components/system/mscmp_syst_db/lib/types.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystDb.Types do
  @moduledoc """
  Defines public types for use with the MscmpSystDb module.
  """

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

  These operators are used in conjunction with the `MscmpSystDb.DbTypes`
  and `MscmpSystDb.DbTypes.Range` protocols.

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
      ...>   %MscmpSystDb.DbTypes.IntegerRange{
      ...>     lower: 200,
      ...>     upper: 210
      ...>   }
      iex> right_range =
      ...>   %MscmpSystDb.DbTypes.IntegerRange{
      ...>     lower: 100,
      ...>     upper: 110
      ...>   }
      iex> MscmpSystDb.DbTypes.compare(left_range, right_range)
      :gt

  Less Than (`:lt`)

      iex> left_range =
      ...>   %MscmpSystDb.DbTypes.IntegerRange{
      ...>     lower: 100,
      ...>     upper: 110
      ...>   }
      iex> right_range =
      ...>   %MscmpSystDb.DbTypes.IntegerRange{
      ...>     lower: 200,
      ...>     upper: 210
      ...>   }
      iex> MscmpSystDb.DbTypes.compare(left_range, right_range)
      :lt

  Equal (`:eq`)

      iex> left_range =
      ...>   %MscmpSystDb.DbTypes.IntegerRange{
      ...>     lower: 100,
      ...>     upper: 110
      ...>   }
      iex> right_range =
      ...>   %MscmpSystDb.DbTypes.IntegerRange{
      ...>     lower: 100,
      ...>     upper: 110
      ...>   }
      iex> MscmpSystDb.DbTypes.compare(left_range, right_range)
      :eq

  Left Contains Right (`:lcr`)

      iex> left_range =
      ...>   %MscmpSystDb.DbTypes.IntegerRange{
      ...>     lower: 90,
      ...>     upper: 110
      ...>   }
      iex> right_range =
      ...>   %MscmpSystDb.DbTypes.IntegerRange{
      ...>     lower: 100,
      ...>     upper: 110
      ...>   }
      iex> MscmpSystDb.DbTypes.compare(left_range, right_range)
      :lcr

  Right Contains Left (`:rcl`)

      iex> left_range =
      ...>   %MscmpSystDb.DbTypes.IntegerRange{
      ...>     lower: 100,
      ...>     upper: 110
      ...>   }
      iex> right_range =
      ...>   %MscmpSystDb.DbTypes.IntegerRange{
      ...>     lower: 100,
      ...>     upper: 111
      ...>   }
      iex> MscmpSystDb.DbTypes.compare(left_range, right_range)
      :rcl


  Greater Than Overlapping (`:gto`)

      iex> left_range =
      ...>   %MscmpSystDb.DbTypes.IntegerRange{
      ...>     lower: 150,
      ...>     upper: 250
      ...>   }
      iex> right_range =
      ...>   %MscmpSystDb.DbTypes.IntegerRange{
      ...>     lower: 100,
      ...>     upper: 175
      ...>   }
      iex> MscmpSystDb.DbTypes.compare(left_range, right_range)
      :gto


  Less Than Overlapping (`:lto`)

      iex> left_range =
      ...>   %MscmpSystDb.DbTypes.IntegerRange{
      ...>     lower: 100,
      ...>     upper: 150
      ...>   }
      iex> right_range =
      ...>   %MscmpSystDb.DbTypes.IntegerRange{
      ...>     lower: 125,
      ...>     upper: 175
      ...>   }
      iex> MscmpSystDb.DbTypes.compare(left_range, right_range)
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
  Options which are expected by the `Timex` library.

  The `MscmpSystDb.DbTypes.Interval` struct can be converted into a form
  which can be consumed by `Timex.shift/2` and this type defines the possible
  return values.

  Note that this type should closely match the `t:Timex.shift_options` types
  except that we limit it to the types present in the
  `t:MscmpSystDb.DbTypes.Interval.t/0` data type.
  """
  @type timex_shift_options :: [
          microseconds: integer(),
          seconds: integer(),
          days: integer(),
          months: integer()
        ]
end

defmodule MscmpSystDb.Types.BoundsCompareResult do
  @moduledoc """
  The comparison operators for both the lower and upper bounds of a range type.
  """

  @enforce_keys [:lower_comparison, :upper_comparison]
  defstruct [:lower_comparison, :upper_comparison]

  @typedoc """
  The field type specification for the `McmpSystDb.Types.BoundsCompareResult`
  struct.

  There are cases where normal comparisons are too coarse-grained to provide a
  meaningful result when dealing with ranges.  In these cases you need the
  detailed lower/upper comparison results.
  """
  @type t :: %__MODULE__{
          lower_comparison: MscmpSystDb.Types.db_type_comparison_operators(),
          upper_comparison: MscmpSystDb.Types.db_type_comparison_operators()
        }
end

defmodule MscmpSystDb.Types.ContextState do
  @moduledoc """
  A struct for reporting the runtime state of Datastore Contexts.
  """

  @enforce_keys [:context, :state]
  defstruct [:context, :state]

  @typedoc """
  Describes the available fields of the `MscmpSystDb.Types.ContextState` struct.

    * `:context` - identifies the name of the Datastore Context for which
    runtime state is being reported.

    * `:state` - indicates the current runtime state of the named Datastore
    Context.  See `t:MscmpSystDb.Types.context_state_values/0` for more.
  """

  @type t :: %__MODULE__{
          context: MscmpSystDb.Types.context_name(),
          state: MscmpSystDb.Types.context_state_values()
        }
end

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
  Establishes `MscmpSystDb.Types.DatastoreContext` field data types.

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

defmodule MscmpSystDb.Types.DatastoreOptions do
  @moduledoc """
  A struct defining the connection parameters to use to connect to a Datastore
  backing database.
  """

  @enforce_keys [:database_name, :contexts, :db_server]
  defstruct [:database_name, :datastore_code, :datastore_name, :contexts, :db_server]

  @typedoc """
  Identifies the `MscmpSystDb.Types.DatastoreOptions` field data types.

    * `:database_name` - The name of the database in the database server to
      which the connection will be made.  Often times this value will be the
      same as the String.t() form of the `:datastore_name` value.

    * `:datastore_code` - Defines a Datastore specific salting value for use in
      certain security and cryptographic related functions.

    * `:datastore_name` - A name for use by the application to identify a given
      Datastore.  This value will often time be the same as the `:database_name`
      value, except as an atom() rather than a String.t().

    * `:contexts` - A list of available Datastore Context values defining which
      contexts are available for this Datastore.  See
      `t:MscmpSystDb.Types.DatastoreContext.t/0` for more information concerning
      the values of each entry in the list.

    * `:db_server` - The database server information for the server where the
      Datastore database resides.  See 't:MscmpSystDb.Types.DbServer.t/0' for
      additional details.
  """

  @type t :: %__MODULE__{
          database_name: String.t(),
          datastore_code: String.t() | nil,
          datastore_name: atom() | nil,
          contexts: [MscmpSystDb.Types.DatastoreContext.t()] | [],
          db_server: MscmpSystDb.Types.DbServer.t()
        }
end

defmodule MscmpSystDb.Types.DbServer do
  @moduledoc """
  An Elixir struct which describes the data representation of a database server.

  The data in the struct includes fields which uniquely identifies the server,
  provides information for where on the network the server can be found, and
  connection related parameters.  Also, the full administrative credentials are
  included.
  """

  defstruct [
    :server_name,
    :start_server_instances,
    :server_pools,
    :db_host,
    :db_port,
    :db_show_sensitive,
    :db_max_instances,
    :server_salt,
    :dbadmin_password,
    :dbadmin_pool_size
  ]

  @typedoc """
  Type description of each of the fields which make up the
  `MscmpSystDb.Types.DbServer` struct.

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

  * `:dbadmin_password` - The ms_syst_privileged role password for privileged
    operations such as creating a new database/Datastore or new database roles
    on the database server instance.

  * `:dbadmin_pool_size` - The pool size to use for creating connections for
    privileged operations using the ms_syst_privileged role.
  """

  @type t :: %__MODULE__{
          server_name: String.t() | nil,
          start_server_instances: boolean() | nil,
          server_pools: list(String.t()) | [] | nil,
          db_host: String.t() | nil,
          db_port: integer() | nil,
          db_show_sensitive: boolean() | nil,
          db_max_instances: integer() | nil,
          server_salt: String.t() | nil,
          dbadmin_password: String.t() | nil,
          dbadmin_pool_size: integer() | nil
        }
end
