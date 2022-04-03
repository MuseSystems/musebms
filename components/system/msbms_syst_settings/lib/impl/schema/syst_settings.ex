# Source File: syst_settings.ex
# Location:    /home/scb/source/products/musebms/components/system/msbms_syst_settings/lib/impl/schema/syst_settings.ex
# Project:     msbms
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https: //muse.systems

defmodule MsbmsSystSettings.Impl.Schema.SystSettings do
  use MsbmsSystSettings.Impl.Schema
  import Ecto.Changeset

  alias MsbmsSystDatastore.Impl.DbTypes

  @schema_prefix "msbms_syst_data"

  schema "syst_settings" do
    field(:internal_name, :string)
    field(:display_name, :string)
    field(:syst_defined, :boolean)
    field(:syst_description, :string)
    field(:user_description, :string)
    field(:config_flag, :boolean)
    field(:config_integer, :integer)
    field(:config_integer_range, DbTypes.IntegerRange)
    field(:config_decimal, :decimal)
    field(:config_decimal_range, DbTypes.DecimalRange)
    field(:config_interval, DbTypes.Interval)
    field(:config_date, :date)
    field(:config_date_range, DbTypes.DateRange)
    field(:config_time, :time)
    field(:config_timestamp, :utc_datetime)
    field(:config_timestamp_range, DbTypes.TimestampRange)
    field(:config_json, :map)
    field(:config_text, :string)
    field(:config_uuid, Ecto.UUID)
    field(:config_blob, :binary)
    field(:diag_timestamp_created, :utc_datetime)
    field(:diag_role_created, :string)
    field(:diag_timestamp_modified, :utc_datetime)
    field(:diag_wallclock_modified, :utc_datetime)
    field(:diag_role_modified, :string)
    field(:diag_row_version, :integer)
    field(:diag_update_count, :integer)
  end

  def changeset(syst_settings, params \\ %{}) do
    syst_settings
    |> cast(params, [:name, :email, :age])
    |> validate_required([:name, :email])
    |> validate_format(:email, ~r/@/)
    |> validate_inclusion(:age, 18..100)
    |> unique_constraint(:email)
  end
end
