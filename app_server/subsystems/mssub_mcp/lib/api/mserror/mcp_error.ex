# Source File: mcp_error.ex
# Location:    musebms/app_server/subsystems/mssub_mcp/lib/api/mserror/mcp_error.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule Mserror.McpError do
  @moduledoc """
  Defines an `Mserror` compliant error module for the MssubMcp component.

  For more see the `MscmpSystError` Component documentation.
  """

  use MscmpSystError,
    component: MssubMcp,
    kinds: [
      application_services: "Failure performing an Application Service Management operation.",
      instance_services: "Failure performing an Instance Service Management operation."
    ]
end
