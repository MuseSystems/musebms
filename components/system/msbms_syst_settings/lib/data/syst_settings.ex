# Source File: syst_settings.ex
# Location:    components/system/msbms_syst_settings/lib/data/syst_settings.ex
# Project:     msbms
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https: //muse.systems

defmodule MsbmsSystSettings.Data.SystSettings do
  use MsbmsSystDatastore.Schema
  import Ecto.Changeset

  alias MsbmsSystDatastore.DbTypes

  @min_internal_name 6
  @max_internal_name 64

  @min_display_name 6
  @max_display_name 64

  @min_user_description_length 6
  @max_user_description_length 1_000

  @moduledoc """
  Defines the primary representation of settings related data.

  The SystSettings struct and related functions define the primary data
  structure for application settings data.
  """

  @type t() ::
          %__MODULE__{
            __meta__: Ecto.Schema.Metadata.t(),
            id: Ecto.UUID.t(),
            internal_name: MsbmsSystSettings.Types.setting_name(),
            display_name: String.t(),
            syst_defined: boolean(),
            syst_description: String.t(),
            user_description: String.t(),
            setting_flag: boolean(),
            setting_integer: integer(),
            setting_integer_range: DbTypes.IntegerRange.t(),
            setting_decimal: Decimal.t(),
            setting_decimal_range: DbTypes.DecimalRange.t(),
            setting_interval: DbTypes.Interval.t(),
            setting_date: Date.t(),
            setting_date_range: DbTypes.DateRange.t(),
            setting_time: Time.t(),
            setting_timestamp: DateTime.t(),
            setting_timestamp_range: DbTypes.TimestampRange.t(),
            setting_json: map(),
            setting_text: String.t(),
            setting_uuid: Ecto.UUID.t(),
            setting_blob: binary(),
            diag_timestamp_created: DateTime.t(),
            diag_role_created: String.t(),
            diag_timestamp_modified: DateTime.t(),
            diag_wallclock_modified: DateTime.t(),
            diag_role_modified: String.t(),
            diag_row_version: integer(),
            diag_update_count: integer()
          }

  @schema_prefix "msbms_syst"

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
    field(:setting_timestamp_range, DbTypes.TimestampRange)
    field(:setting_json, :map)
    field(:setting_text, :string)
    field(:setting_uuid, Ecto.UUID)
    field(:setting_blob, :binary)
    field(:diag_timestamp_created, :utc_datetime)
    field(:diag_role_created, :string)
    field(:diag_timestamp_modified, :utc_datetime)
    field(:diag_wallclock_modified, :utc_datetime)
    field(:diag_role_modified, :string)
    field(:diag_row_version, :integer)
    field(:diag_update_count, :integer)
  end

  @doc """
  Produces a changeset to be used to create a new user defined setting.

  The `create_params` argument defines the attributes to be used in creating a new
  user defined setting.  Of the allowed fields, the following are required for
  creation:

    * `internal_name` - A unique key which is intended for programmatic usage
      by the application and other applications which make use of the data.

    * `display_name` - A unique key for the purposes of presentation to users
      in user interfaces, reporting, etc.

    * `user_description` - A description of the setting including its use cases
      and any limits or restrictions.  This field must contain between 6 and
      1000 characters to be considered valid.
  """
  @spec create_changeset(map()) :: Ecto.Changeset.t()
  def create_changeset(create_params \\ %{}) do
    %__MODULE__{}
    |> cast(create_params, [
      :internal_name,
      :display_name,
      :user_description,
      :setting_flag,
      :setting_integer,
      :setting_integer_range,
      :setting_decimal,
      :setting_decimal_range,
      :setting_interval,
      :setting_date,
      :setting_date_range,
      :setting_time,
      :setting_timestamp,
      :setting_timestamp_range,
      :setting_json,
      :setting_text,
      :setting_uuid,
      :setting_blob
    ])
    |> validate_required([:internal_name, :display_name, :user_description])
    |> put_change(:syst_defined, false)
    |> validate_length(:internal_name, min: @min_internal_name, max: @max_internal_name)
    |> validate_length(:display_name, min: @min_display_name, max: @max_display_name)
    |> validate_length(:user_description,
      min: @min_user_description_length,
      max: @max_user_description_length
    )
    |> unique_constraint(:internal_name)
    |> unique_constraint(:display_name)
  end

  @doc """
  Produces a changeset for the purposes of updating an existing setting record.

  Updates may be made to any setting record, system or user defined.  There are
  no required values for changing a setting
  """
  @spec update_changeset(t(), map()) :: Ecto.Changeset.t()
  def update_changeset(syst_settings, update_params \\ %{}) do
    syst_settings
    |> cast(update_params, [
      :display_name,
      :user_description,
      :setting_flag,
      :setting_integer,
      :setting_integer_range,
      :setting_decimal,
      :setting_decimal_range,
      :setting_interval,
      :setting_date,
      :setting_date_range,
      :setting_time,
      :setting_timestamp,
      :setting_timestamp_range,
      :setting_json,
      :setting_text,
      :setting_uuid,
      :setting_blob
    ])
    |> validate_length(:display_name, min: @min_display_name, max: @max_display_name)
    |> maybe_validate_user_description()
    |> unique_constraint(:display_name)
  end

  defp maybe_validate_user_description(changeset) do
    (!get_field(changeset, :syst_defined) or !is_nil(get_field(changeset, :user_description, nil)))
    |> maybe_validate_user_description(changeset)
  end

  defp maybe_validate_user_description(true, changeset),
    do:
      validate_length(changeset, :user_description,
        min: @min_user_description_length,
        max: @max_user_description_length
      )

  defp maybe_validate_user_description(false, changeset), do: changeset
end
