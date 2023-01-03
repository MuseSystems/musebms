# Source File: mcp_perms_manager.ex
# Location:    musebms/app_server/subsystems/mssub_mcp/lib/runtime/mcp_perms_manager.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MssubMcp.Runtime.McpPermsManager do
  alias MscmpSystMcpPerms.Types, as: McpPermTypes
  alias MscmpSystPerms.Types, as: PermTypes

  @moduledoc false

  use MssubMcp.Macros

  mcp_constants()

  @spec compare_scopes(
          PermTypes.rights_scope() | String.t(),
          PermTypes.rights_scope() | String.t()
        ) ::
          :eq | :gt | :lt
  mcp_opfn compare_scopes(test_scope, standard_scope) do
    MscmpSystPerms.compare_scopes(test_scope, standard_scope)
  end

  @spec get_effective_perm_grants(McpPermTypes.AccessAccountPermsSelector.t(), Keyword.t()) ::
          {:ok, PermTypes.perm_grants()} | {:error, MscmpSystError.t()}
  mcp_opfn get_effective_perm_grants(selector, opts) do
    MscmpSystPerms.get_effective_perm_grants(selector, opts)
  end

  @spec list_perm_grants(McpPermTypes.AccessAccountPermsSelector.t(), Keyword.t()) ::
          {:ok, [Msdata.SystPermRoles.t()]} | {:error, MscmpSystError.t()}
  mcp_opfn list_perm_grants(selector, opts) do
    MscmpSystPerms.list_perm_grants(selector, opts)
  end

  @spec list_perm_denials(McpPermTypes.AccessAccountPermsSelector.t(), Keyword.t()) ::
          {:ok, [Msdata.SystPerms.t()] | []} | {:error, MscmpSystError.t()}
  mcp_opfn list_perm_denials(selector, opts) do
    MscmpSystPerms.list_perm_denials(selector, opts)
  end

  @spec grant_perm_role(McpPermTypes.AccessAccountPermsSelector.t(), PermTypes.perm_role_id()) ::
          :ok | {:error, MscmpSystError.t()}
  mcp_opfn grant_perm_role(selector, perm_role_id) do
    MscmpSystPerms.grant_perm_role(selector, perm_role_id)
  end

  @spec revoke_perm_role(McpPermTypes.AccessAccountPermsSelector.t(), PermTypes.perm_role_id()) ::
          {:ok, :deleted | :not_found} | {:error, MscmpSystError.t()}
  mcp_opfn revoke_perm_role(selector, perm_role_id) do
    MscmpSystPerms.revoke_perm_role(selector, perm_role_id)
  end
end
