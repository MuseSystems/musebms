# Source File: settings.ex
# Location:    musebms/app_server/subsystems/mssub_mcp/lib/runtime/settings.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MssubMcp.Runtime.Settings do
  @moduledoc false

  use MssubMcp.Macros

  mcp_constants()

  mcp_opfn get_value(setting_name, setting_type) do
    MscmpSystSettings.get_value(setting_name, setting_type)
  end

  mcp_opfn get_values(setting_name) do
    MscmpSystSettings.get_values(setting_name)
  end

  mcp_opfn list_all() do
    MscmpSystSettings.list_all()
  end

  @spec set_value(
          MscmpSystSettings.Types.setting_name(),
          MscmpSystSettings.Types.setting_types(),
          any()
        ) :: :ok | {:error, MscmpSystError.t()}
  mcp_opfn set_value(setting_name, setting_type, setting_value) do
    MscmpSystSettings.set_value(setting_name, setting_type, setting_value)
  end

  @spec set_values(
          MscmpSystSettings.Types.setting_name(),
          MscmpSystSettings.Types.setting_service_params()
        ) :: :ok | {:error, MscmpSystError.t()}
  mcp_opfn set_values(setting_name, update_params) do
    MscmpSystSettings.set_values(setting_name, update_params)
  end
end
