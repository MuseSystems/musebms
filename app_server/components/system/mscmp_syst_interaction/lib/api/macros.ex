# Source File: macros.ex
# Location:    musebms/app_server/components/system/mscmp_syst_interaction/lib/api/macros.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystInteraction.Macros do
  @moduledoc false

  @spec __using__(term()) :: Macro.t()
  defmacro __using__(_opts) do
    quote do
      import MscmpSystInteraction.Macros
    end
  end

  @spec interaction_devsupport(:dev | :test) :: Macro.t()
  defmacro interaction_devsupport(support_type) do
    service_name =
      case support_type do
        :dev -> :"MscmpSystInteraction.DevSupportService"
        :test -> :"MscmpSystInteraction.TestSupportService"
      end

    quote do
      @interaction_service_name unquote(service_name)
    end
  end
end
