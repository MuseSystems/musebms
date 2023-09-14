# Source File: types.ex
# Location:    musebms/app_server/components/system/mscmp_syst_mcp_perms/lib/types.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystMcpPerms.Types do
  @moduledoc """
  Types used by the MCP Perms component.
  """

  @typedoc """
  A map defining the data elements required for creating Access Account
  Permission Role Assigns records.

  ## Attributes

    * `access_account_id` - the record ID of the Access Account record being
    granted a Permission Role.

    * `perm_role_id` - the record ID of the Permission Role which is to be
    granted to the identified Access Account.
  """
  @type access_account_perm_role_params() :: %{
          required(:access_account_id) => MscmpSystAuthn.Types.access_account_id(),
          required(:perm_role_id) => MscmpSystPerms.Types.perm_role_id()
        }
end
