# Source File: process_utils.ex
# Location:    musebms/app_server/components/system/mscmp_syst_settings/lib/runtime/process_utils.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystSettings.Runtime.ProcessUtils do
  @moduledoc false

  @spec get_settings_table() :: :ets.table() | nil
  def get_settings_table, do: Process.get(:"MscmpSystSettings.table_name")

  @spec put_settings_service(GenServer.name() | nil) :: GenServer.name() | nil
  def put_settings_service(nil) do
    _ = Process.put(:"MscmpSystSettings.table_name", nil)
    Process.put(:"MscmpSystSettings.service_name", nil)
  end

  def put_settings_service(settings_service_name) do
    settings_table = GenServer.call(settings_service_name, :get_settings_table)
    Process.put(:"MscmpSystSettings.table_name", settings_table)
    Process.put(:"MscmpSystSettings.service_name", settings_service_name)
  end

  @spec get_settings_service() :: GenServer.name() | nil
  def get_settings_service, do: Process.get(:"MscmpSystSettings.service_name")
end
