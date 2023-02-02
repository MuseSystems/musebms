# Source File: types.ex
# Location:    musebms/app_server/subsystems/mssub_mcp/lib/types.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MssubMcp.Types do
  @moduledoc """
  Defines data types used in operating the MCP Subsystem.
  """

  @type tenant_bootstrap_params() :: %{
          required(:owner) => MscmpSystInstance.Types.owner_params(),
          required(:access_account) => MscmpSystAuthn.Types.access_account_params(),
          required(:authenticator_type) => MscmpSystAuthn.Types.authenticator_types(),
          required(:account_identifier) => MscmpSystAuthn.Types.account_identifier(),
          required(:credential) => MscmpSystAuthn.Types.credential(),
          optional(:mfa_credential) => MscmpSystAuthn.Types.credential(),
          required(:application) =>
            MscmpSystInstance.Types.application_id()
            | MscmpSystInstance.Types.application_name()
            | :mcp
        }

  @type tenant_bootstrap_result() :: %{
          required(:owner_id) => MscmpSystInstance.Types.owner_id(),
          required(:access_account_id) => MscmpSystAuthn.Types.access_account_id(),
          optional(:instance_id) => MscmpSystInstance.Types.instance_id()
        }
end
