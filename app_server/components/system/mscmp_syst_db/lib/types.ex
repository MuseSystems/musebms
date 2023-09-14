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
