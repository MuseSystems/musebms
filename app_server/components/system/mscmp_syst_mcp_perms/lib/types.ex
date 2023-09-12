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

defmodule MscmpSystMcpPerms.Types.AccessAccountPermsSelector do
  @moduledoc """
  Defines the Access Account selector for globally applicable MCP permissions.
  """

  alias MscmpSystMcpPerms.Impl

  @enforce_keys [:access_account_id]
  defstruct access_account_id: nil

  @typedoc """
  Defines the Access Account selector for globally applicable MCP permissions.

  ## Attributes

    * `access_account_id` - the record ID of the Access Account which is the
    subject of Permissions related actions.
  """
  @type t() :: %__MODULE__{
          access_account_id: MscmpSystAuthn.Types.access_account_id()
        }

  defimpl MscmpSystPerms.Protocol do
    @spec get_effective_perm_grants(
            MscmpSystMcpPerms.Types.AccessAccountPermsSelector.t(),
            Keyword.t()
          ) ::
            {:ok, MscmpSystPerms.Types.perm_grants()} | {:error, MscmpSystError.t()}
    def get_effective_perm_grants(selector, opts \\ []),
      do: Impl.AccessAccountPermRole.get_effective_perm_grants(selector, opts)

    @spec list_perm_grants(MscmpSystMcpPerms.Types.AccessAccountPermsSelector.t(), Keyword.t()) ::
            {:ok, [Msdata.SystPermRoles.t()]} | {:error, MscmpSystError.t()}
    def list_perm_grants(selector, opts \\ []),
      do: Impl.AccessAccountPermRole.list_perm_grants(selector, opts)

    @spec list_perm_denials(
            MscmpSystMcpPerms.Types.AccessAccountPermsSelector.t(),
            Keyword.t()
          ) ::
            {:ok, [Msdata.SystPerms.t()] | []} | {:error, MscmpSystError.t()}
    def list_perm_denials(selector, opts \\ []),
      do: Impl.AccessAccountPermRole.list_perm_denials(selector, opts)

    @spec grant_perm_role(
            MscmpSystMcpPerms.Types.AccessAccountPermsSelector.t(),
            MscmpSystPerms.Types.perm_role_id()
          ) ::
            :ok | {:error, MscmpSystError.t()}
    def grant_perm_role(selector, perm_role_id),
      do: Impl.AccessAccountPermRole.grant_perm_role(selector, perm_role_id)

    @spec revoke_perm_role(
            MscmpSystMcpPerms.Types.AccessAccountPermsSelector.t(),
            MscmpSystPerms.Types.perm_role_id()
          ) ::
            {:ok, :deleted | :not_found} | {:error, MscmpSystError.t()}
    def revoke_perm_role(selector, perm_role_id),
      do: Impl.AccessAccountPermRole.revoke_perm_role(selector, perm_role_id)
  end
end
