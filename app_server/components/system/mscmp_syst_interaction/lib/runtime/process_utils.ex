# Source File: process_utils.ex
# Location:    musebms/app_server/components/system/mscmp_syst_interaction/lib/runtime/process_utils.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystInteraction.Runtime.ProcessUtils do
  @moduledoc false

  alias MscmpSystInteraction.Types

  @spec get_context_table() :: :ets.table() | nil
  def get_context_table, do: Process.get(:"MscmpSystInteraction.table_name")

  @spec put_service(Types.service_name()) :: Types.service_name()
  def put_service(nil) do
    _ = Process.put(:"MscmpSystInteraction.table_name", nil)
    Process.put(:"MscmpSystInteraction.service_name", nil)
  end

  def put_service(service_name) do
    context_table = GenServer.call(service_name, :get_context_table)
    Process.put(:"MscmpSystInteraction.table_name", context_table)
    Process.put(:"MscmpSystInteraction.service_name", service_name)
  end

  @spec get_service() :: Types.service_name()
  def get_service, do: Process.get(:"MscmpSystInteraction.service_name")
end
