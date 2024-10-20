# Source File: syst_settings.ex
# Location:    musebms/app_server/components/system/mscmp_syst_settings/lib/api/msdata/syst_settings.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule Msdata.SystSettings do
  @moduledoc """
  The primary data structure for applications settings data.

  Defined in `MscmpSystSettings`.
  """

  use MscmpSystDb.Schema

  alias MscmpSystDb.DbTypes
  alias MscmpSystSettings.Impl.Msdata.SystSettings.Validators

  @type t() ::
          %__MODULE__{
            __meta__: Ecto.Schema.Metadata.t(),
            id: Ecto.UUID.t() | nil,
            internal_name: MscmpSystSettings.Types.setting_name() | nil,
            display_name: String.t() | nil,
            syst_defined: boolean() | nil,
            syst_description: String.t() | nil,
            user_description: String.t() | nil,
            setting_flag: boolean() | nil,
            setting_integer: integer() | nil,
            setting_integer_range: DbTypes.IntegerRange.t() | nil,
            setting_decimal: Decimal.t() | nil,
            setting_decimal_range: DbTypes.DecimalRange.t() | nil,
            setting_interval: DbTypes.Interval.t() | nil,
            setting_date: Date.t() | nil,
            setting_date_range: DbTypes.DateRange.t() | nil,
            setting_time: Time.t() | nil,
            setting_timestamp: DateTime.t() | nil,
            setting_timestamp_range: DbTypes.DateTimeRange.t() | nil,
            setting_json: map() | nil,
            setting_text: String.t() | nil,
            setting_uuid: Ecto.UUID.t() | nil,
            setting_blob: binary() | nil,
            diag_timestamp_created: DateTime.t() | nil,
            diag_role_created: String.t() | nil,
            diag_timestamp_modified: DateTime.t() | nil,
            diag_wallclock_modified: DateTime.t() | nil,
            diag_role_modified: String.t() | nil,
            diag_row_version: integer() | nil,
            diag_update_count: integer() | nil
          }

  @schema_prefix "ms_syst"

  schema "syst_settings" do
    field(:internal_name, :string)
    field(:display_name, :string)
    field(:syst_defined, :boolean)
    field(:syst_description, :string)
    field(:user_description, :string)
    field(:setting_flag, :boolean)
    field(:setting_integer, :integer)
    field(:setting_integer_range, DbTypes.IntegerRange)
    field(:setting_decimal, :decimal)
    field(:setting_decimal_range, DbTypes.DecimalRange)
    field(:setting_interval, DbTypes.Interval)
    field(:setting_date, :date)
    field(:setting_date_range, DbTypes.DateRange)
    field(:setting_time, :time)
    field(:setting_timestamp, :utc_datetime)
    field(:setting_timestamp_range, DbTypes.DateTimeRange)
    field(:setting_json, :map)
    field(:setting_text, :string)
    field(:setting_uuid, Ecto.UUID)
    field(:setting_blob, :binary)
    field(:diag_timestamp_created, :utc_datetime)
    field(:diag_role_created, :string, load_in_query: false)
    field(:diag_timestamp_modified, :utc_datetime)
    field(:diag_wallclock_modified, :utc_datetime, load_in_query: false)
    field(:diag_role_modified, :string, load_in_query: false)
    field(:diag_row_version, :integer)
    field(:diag_update_count, :integer, load_in_query: false)
  end

  @doc """
  Produces a changeset used to create or update a settings record.

  The `change_params` argument defines the attributes to be used in maintaining
  a settings record.  Of the allowed fields, the following are required for
  creation:

    * `internal_name` - A unique key which is intended for programmatic usage
      by the application and other applications which make use of the data.

    * `display_name` - A unique key for the purposes of presentation to users
      in user interfaces, reporting, etc.

    * `user_description` - A description of the setting including its use cases
      and any limits or restrictions.  This field must contain between 6 and
      1000 characters to be considered valid.

  The options define other attributes which can guide validation of
  `change_param` values:

    * `min_internal_name_length` - Sets a minimum length for `internal_name`
      values.  The default value is 6 Unicode graphemes.

    * `max_internal_name_length` - The maximum length allowed for the
      `internal_name` value.  The default is 64 Unicode graphemes.

    * `min_display_name_length` - Sets a minimum length for `display_name`
      values.  The default value is 6 Unicode graphemes.

    * `max_display_name_length` - The maximum length allowed for the
      `display_name` value.  The default is 64 Unicode graphemes.

    * `min_user_description_length` - Sets a minimum length for
      `user_description` values.  The default value is 6 Unicode graphemes.

    * `max_user_description_length` - The maximum length allowed for the
      `user_description` value.  The default is 1000 Unicode graphemes.
  """
  @spec changeset(t(), map(), Keyword.t()) :: Ecto.Changeset.t()
  defdelegate changeset(syst_settings, change_params \\ %{}, opts \\ []), to: Validators
end
