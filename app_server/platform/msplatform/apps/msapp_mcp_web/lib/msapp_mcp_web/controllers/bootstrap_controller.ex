# Source File: bootstrap_controller.ex
# Location:    musebms/app_server/platform/msplatform/apps/msapp_mcp_web/lib/msapp_mcp_web/controllers/bootstrap_controller.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MsappMcpWeb.BootstrapController do
  use MsappMcpWeb, :controller

  def home(conn, _params) do
    render(conn, :home, layout: false)
  end
end
