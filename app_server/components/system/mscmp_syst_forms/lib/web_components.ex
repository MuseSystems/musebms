# Source File: web_components.ex
# Location:    musebms/app_server/components/system/mscmp_syst_forms/lib/web_components.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystForms.WebComponents do
  alias MscmpSystForms.Impl.WebComponents

  defdelegate msbutton(assigns), to: WebComponents.Msbuttons
  defdelegate msvalidated_button(assigns), to: WebComponents.Msbuttons
  defdelegate mscontainer(assigns), to: WebComponents.Mscontainers
  defdelegate msdisplay(assigns), to: WebComponents.Msdisplays
  defdelegate msfield_errors(assigns), to: WebComponents.MsfieldErrors
  defdelegate msform(assigns), to: WebComponents.Msforms
  defdelegate msicon(assigns), to: WebComponents.Msicons
  defdelegate msinfo(assigns), to: WebComponents.Msinfo
  defdelegate msinput(assigns), to: WebComponents.Msinputs
  defdelegate mslist(assigns), to: WebComponents.Mslists
  defdelegate mslistitem(assigns), to: WebComponents.Mslists
  defdelegate msmodal(assigns), to: WebComponents.Msmodals
  defdelegate mssection(assigns), to: WebComponents.Mssections
end
