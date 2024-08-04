# Source File: types.ex
# Location:    musebms/app_server/components/system/mscmp_syst_db/lib/api/types.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

# TODO:  Add the context_service_name and datastore_service_name types to the
#        appropriate typespecs.

defmodule MscmpSystDb.Types do
  @moduledoc """
  Defines public types for use with the MscmpSystDb module.
  """

  @typedoc """
  The value type for names which describe a specific instance of an
  Application's Datastore Context.

  A Context Name provides a reference to a specific Instance's database access
  in a way that decouples the application reference name from the database role
  which that name represents.

  This name will commonly be used as the registered name for the Datastore
  Context when registering the associated database repository `pid` value.
  """
  @type context_name() :: String.t() | atom()

  @typedoc """
  The extended naming value of a Datastore Context for use when starting a
  Datastore Context.

  This name can include process registry information and takes the same for as
  that allowed for `GenServer` naming.
  """
  @type context_service_name() :: GenServer.name() | nil

  @typedoc """
  The allowable Datastore Context name registration options.

  Values of this type describe the available options for registering a Datastore
  Context name.  The options are:

    * `:global` - the Datastore Context name is registered globally and can be
      using the Erlang `:global` registry.

    * `{:via, module()}` - the Datastore Context name is registered
      using the identified module which must implement the Registry behaviour.

    * `nil` - the Datastore Context name will be registered locally using the
      VM's built-in registration mechanisms.  In this case the Datastore Context
      name must be represented as an atom.
  """
  @type context_registry :: :global | :atom

  @typedoc """
  The database role name for the specific access context defined by the
  `context_name()`.
  """
  @type context_role :: String.t()

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
  Values indicating the state of the database which backs a given Datastore.

    * `:not_found` - The database for the Datastore does not exist on the
      database server.

    * `:ready` - The database is ready for further processing by the migrations
      subsystem.
  """
  @type database_state_values :: :not_found | :ready

  @typedoc """
  A type describing the allowed values for use in datastore_naming.
  """
  @type datastore_name :: String.t() | atom()

  @typedoc """
  The extended naming value of a Datastore for use when starting a Datastore.

  This name can include process registry information and takes the same for as
  that allowed for `GenServer` naming.
  """
  @type datastore_service_name() :: GenServer.name() | nil

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
