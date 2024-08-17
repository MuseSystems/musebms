# Source File: macros.ex
# Location:    musebms/app_server/components/system/mscmp_syst_settings/lib/api/macros.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystSettings.Macros do
  @moduledoc false

  defmacro __using__(_opts) do
    quote do
      import MscmpSystSettings.Macros
    end
  end

  defmacro settings_devsupport do
    quote do
      @settings_service_name_dev :"MscmpSystSettings.DevSupportService"
      @settings_service_name_test :"MscmpSystSettings.TestSupportService"
    end
  end
end
