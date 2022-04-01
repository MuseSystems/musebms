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

  alias MsbmsSystDatastore.Impl.DbTypes

  schema "syst_settings" do
    field(:internal_name, :string)
    field(:display_name, :string)
    field(:syst_description, :string)
    field(:user_description, :string)
    field(:config_flag, :boolean)
    field(:config_integer, :integer)
    field(:config_decimal, :decimal)
    field(:config_interval, DbTypes.Interval)
    field(:config_date, :date)
    field(:config_time, :time)
    field(:config_timestamp, :utc_datetime)
    field(:config_json, :map)
    field(:config_text, :string)
    field(:config_uuid, Ecto.UUID)
    field(:config_blob, :binary)
  end
end
