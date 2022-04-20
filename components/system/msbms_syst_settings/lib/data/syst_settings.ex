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
  The primary data structure for applications settings data.
  """

  @type t() ::
          %__MODULE__{
            __meta__: Ecto.Schema.Metadata.t(),
            id: Ecto.UUID.t() | nil,
            internal_name: MsbmsSystSettings.Types.setting_name() | nil,
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
            setting_timestamp_range: DbTypes.TimestampRange.t() | nil,
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
  Produces a changeset used to create or update a settings record.

  The `change_params` argument defines the attributes to be used in creating a new
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
  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(syst_settings, change_params \\ %{}) do
    syst_settings
    |> cast(change_params, [
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
    |> validate_required([:internal_name, :display_name])
    |> validate_length(:display_name, min: @min_display_name, max: @max_display_name)
    |> validate_internal_name()
    |> validate_user_description()
    |> maybe_put_syst_defined()
    |> unique_constraint(:display_name)
  end

  # System defined settings are allowed to have a nil user descriptions, but all
  # other user description values must meet min/max length requirements.
  defp validate_user_description(changeset) do
    (!get_field(changeset, :syst_defined) or !is_nil(get_field(changeset, :user_description, nil)))
    |> validate_user_description(changeset)
  end

  defp validate_user_description(true, changeset) do
    changeset
    |> validate_required(:user_description)
    |> validate_length(:user_description,
      min: @min_user_description_length,
      max: @max_user_description_length
    )
  end

  defp validate_user_description(false, changeset), do: changeset

  defp validate_internal_name(changeset) do
    validation_func = fn :internal_name, _internal_name ->
      if get_field(changeset, :syst_defined, false) do
        [:internal_name, "System defined settings may not have their internal names changed."]
      else
        []
      end
    end

    changeset
    |> validate_change(:internal_name, :validate_internal_name, &validation_func.(&1, &2))
    |> validate_length(:internal_name, min: @min_internal_name, max: @max_internal_name)
    |> unique_constraint(:internal_name)
  end

  defp maybe_put_syst_defined(changeset) do
    changeset
    |> get_field(:id, nil)
    |> is_nil()
    |> maybe_put_syst_defined(changeset)
  end

  defp maybe_put_syst_defined(true, changeset), do: put_change(changeset, :syst_defined, false)
  defp maybe_put_syst_defined(false, changeset), do: changeset
end
