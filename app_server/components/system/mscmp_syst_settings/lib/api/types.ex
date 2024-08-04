# Source File: types.ex
# Location:    musebms/app_server/components/system/mscmp_syst_settings/lib/api/types.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystSettings.Types do
  @moduledoc """
  Types used by Settings service module.
  """

  @typedoc """
  The valid forms of service name acceptable to identify the Settings service.

  When the service name is an atom, it is assumed to be a registered name using
  the default Elixir name registration process.  When the service name is a
  String, you must also identify a valid registry with which the name will be
  registered.  Finally, if the value is `nil`, the service will be started
  without a name and you are responsible for using the returned PID for later
  accesses of the service.
  """
  @type service_name() :: GenServer.name() | nil

  @typedoc """
  Identification of each unique Setting managed by the Settings Service instance.
  """
  @type setting_name() :: String.t()

  @typedoc """
  Data types of values accepted by any individual setting record.  Note that any
  one setting record may set values for one or more of these types concurrently.
  """
  @type setting_types() ::
          :setting_flag
          | :setting_integer
          | :setting_integer_range
          | :setting_decimal
          | :setting_decimal_range
          | :setting_interval
          | :setting_date
          | :setting_date_range
          | :setting_time
          | :setting_timestamp
          | :setting_timestamp_range
          | :setting_json
          | :setting_text
          | :setting_uuid
          | :setting_blob

  @typedoc """
  A map definition describing what specific key/value pairs are available for
  passing as SystSettings changeset parameters.
  """
  @type setting_params() :: %{
          optional(:internal_name) => setting_name(),
          optional(:display_name) => String.t(),
          optional(:user_description) => String.t(),
          optional(:setting_flag) => boolean(),
          optional(:setting_integer) => integer(),
          optional(:setting_integer_range) => MscmpSystDb.DbTypes.IntegerRange.t(),
          optional(:setting_decimal) => Decimal.t(),
          optional(:setting_decimal_range) => MscmpSystDb.DbTypes.DecimalRange.t(),
          optional(:setting_interval) => MscmpSystDb.DbTypes.Interval.t(),
          optional(:setting_date) => Date.t(),
          optional(:setting_date_range) => MscmpSystDb.DbTypes.DateRange.t(),
          optional(:setting_time) => Time.t(),
          optional(:setting_timestamp) => DateTime.t(),
          optional(:setting_timestamp_range) => MscmpSystDb.DbTypes.DateTimeRange.t(),
          optional(:setting_json) => map(),
          optional(:setting_text) => String.t(),
          optional(:setting_uuid) => Ecto.UUID.t(),
          optional(:setting_blob) => binary()
        }
end
