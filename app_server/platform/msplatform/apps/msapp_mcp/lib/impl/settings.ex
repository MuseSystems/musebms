# Source File: settings.ex
# Location:    musebms/app_server/platform/msplatform/apps/msapp_mcp/lib/impl/settings.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MsappMcp.Impl.Settings do
  @moduledoc false

  use MssubMcp.Macros

  alias MsappMcp.Types

  mcp_constants()

  @spec launch_bootstrap?() :: boolean()
  def launch_bootstrap?, do: get_platform_state() == :platform_bootstrapping

  @spec get_platform_state :: Types.platform_states()
  mcp_opfn get_platform_state do
    "platform_state"
    |> MscmpSystSettings.get_setting_value(:setting_uuid)
    |> then(&MscmpSystEnums.get_enum_item_by_id("platform_states", &1))
    |> case do
      %Msdata.SystEnumItems{internal_name: "platform_states_sysdef_bootstrapping"} ->
        :platform_bootstrapping

      %Msdata.SystEnumItems{internal_name: "platform_states_sysdef_active"} ->
        :platform_active

      error ->
        raise MscmpSystError,
          code: :undefined_error,
          message: "Failed reading Platform State.",
          cause: error
    end
  end
end
