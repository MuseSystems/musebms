# Source File: process_utils.ex
# Location:    musebms/app_server/components/system/mscmp_syst_enums/lib/runtime/process_utils.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystEnums.Runtime.ProcessUtils do
  @moduledoc false

  alias MscmpSystService.Types, as: ServiceTypes

  @spec get_enums_table() :: :ets.table() | nil
  def get_enums_table, do: Process.get(:"MscmpSystEnums.table_name")

  @spec get_runtime_config() :: map() | nil
  def get_runtime_config, do: Process.get(:"MscmpSystEnums.runtime_config")

  @spec put_service(ServiceTypes.service_name()) :: ServiceTypes.service_name()
  def put_service(nil) do
    _ = Process.put(:"MscmpSystEnums.table_name", nil)
    _ = Process.put(:"MscmpSystEnums.runtime_config", nil)
    Process.put(:"MscmpSystEnums.service_name", nil)
  end

  def put_service(enums_service_name) do
    enums_table = GenServer.call(enums_service_name, :get_enums_table)
    runtime_config = GenServer.call(enums_service_name, :get_runtime_config)
    Process.put(:"MscmpSystEnums.table_name", enums_table)
    Process.put(:"MscmpSystEnums.runtime_config", runtime_config)
    Process.put(:"MscmpSystEnums.service_name", enums_service_name)
  end

  @spec get_service() :: ServiceTypes.service_name()
  def get_service, do: Process.get(:"MscmpSystEnums.service_name")
end
