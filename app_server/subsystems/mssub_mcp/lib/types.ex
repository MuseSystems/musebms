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
          optional(:owner) => MscmpSystInstance.Types.owner_params(),
          optional(:access_account) => MscmpSystAuthn.Types.access_account_params(),
          optional(:authenticator_type) => MscmpSystAuthn.Types.authenticator_types(),
          optional(:account_identifier) => MscmpSystAuthn.Types.account_identifier(),
          optional(:credential) => MscmpSystAuthn.Types.credential(),
          optional(:mfa_credential) => MscmpSystAuthn.Types.credential() | nil,
          optional(:application) =>
            MscmpSystInstance.Types.application_id()
            | MscmpSystInstance.Types.application_name()
            | :mcp
        }

  @type tenant_bootstrap_result() :: %{
          required(:owner_id) => MscmpSystInstance.Types.owner_id(),
          required(:access_account_id) => MscmpSystAuthn.Types.access_account_id(),
          optional(:instance_id) => MscmpSystInstance.Types.instance_id()
        }

  @type session_name() :: MscmpSystSession.Types.session_name()
end
