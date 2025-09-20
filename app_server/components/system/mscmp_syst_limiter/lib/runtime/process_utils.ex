# Source File: process_utils.ex
# Location:    musebms/app_server/components/system/mscmp_syst_limiter/lib/runtime/process_utils.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystLimiter.Runtime.ProcessUtils do
  @moduledoc false

  alias MscmpSystService.Types, as: ServiceTypes

  @spec get_runtime_config() :: map() | nil
  def get_runtime_config, do: Process.get(:"MscmpSystLimiter.runtime_config")

  @spec put_service(ServiceTypes.service_name()) :: ServiceTypes.service_name()
  def put_service(nil) do
    _ = Process.put(:"MscmpSystLimiter.runtime_config", nil)
    Process.put(:"MscmpSystLimiter.service_name", nil)
  end

  def put_service(limiter) do
    config = GenServer.call(limiter, :get_runtime_config)
    Process.put(:"MscmpSystLimiter.runtime_config", config)
    Process.put(:"MscmpSystLimiter.service_name", limiter)
  end

  @spec get_service() :: ServiceTypes.service_name()
  def get_service, do: Process.get(:"MscmpSystLimiter.service_name")
end
