# Source File: types.ex
# Location:    musebms/app_server/platform/msplatform/apps/msapp_mcp/lib/msform/auth_password_reset/types.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule Msform.AuthPasswordReset.Types do
  @type parameters() :: %{
          optional(:identifier) => String.t() | nil,
          optional(:credential) => String.t() | nil,
          optional(:new_credential) => String.t() | nil,
          optional(:verify_credential) => String.t() | nil
        }
end
