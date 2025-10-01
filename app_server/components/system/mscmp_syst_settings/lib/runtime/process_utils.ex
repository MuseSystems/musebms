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

  alias MscmpSystService.Types, as: ServiceTypes

  ##############################################################################
  #
  # get_settings_table
  #
  #

  @spec get_settings_table() :: :ets.table() | nil
  def get_settings_table do
    case Process.get(:"MscmpSystSettings.runtime_config") do
      %{settings_table: settings_table} -> settings_table
      _ -> nil
    end
  end

  ##############################################################################
  #
  # get_runtime_config
  #
  #

  @spec get_runtime_config() :: map() | nil
  def get_runtime_config, do: Process.get(:"MscmpSystSettings.runtime_config")

  ##############################################################################
  #
  # put_service
  #
  #

  @spec put_service(ServiceTypes.service_name()) :: ServiceTypes.service_name()
  def put_service(nil) do
    _ = Process.put(:"MscmpSystSettings.runtime_config", nil)
    Process.put(:"MscmpSystSettings.service_name", nil)
  end

  def put_service(settings_service_name) do
    runtime_config = GenServer.call(settings_service_name, :get_runtime_config)
    Process.put(:"MscmpSystSettings.runtime_config", runtime_config)
    Process.put(:"MscmpSystSettings.service_name", settings_service_name)
  end

  ##############################################################################
  #
  # get_service
  #
  #

  @spec get_service() :: ServiceTypes.service_name()
  def get_service, do: Process.get(:"MscmpSystSettings.service_name")
end
