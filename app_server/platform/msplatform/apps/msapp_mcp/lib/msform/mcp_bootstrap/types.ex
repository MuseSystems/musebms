# Source File: types.ex
# Location:    musebms/app_server/platform/msplatform/apps/msapp_mcp/lib/msform/mcp_bootstrap/types.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule Msform.McpBootstrap.Types do
  @moduledoc false

  @type parameters() :: %{
          optional(:owner_name) => String.t() | nil,
          optional(:owner_display_name) => String.t() | nil,
          optional(:admin_display_name) => String.t() | nil,
          optional(:admin_identifier) => String.t() | nil,
          optional(:admin_credential) => String.t() | nil,
          optional(:admin_credential_verify) => String.t() | nil
        }
end
