# Source File: access_account_perms_selector.ex
# Location:    musebms/app_server/components/system/mscmp_syst_mcp_perms/lib/types/access_account_perms_selector.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystMcpPerms.Types.AccessAccountPermsSelector do
  @moduledoc """
  Defines the Access Account selector for globally applicable MCP permissions.
  """

  alias MscmpSystError.Types, as: ErrorTypes
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
    # Note that we don't do option validation or defaulting at this level since
    # we presume that we're really going to access the functionality here using
    # the functions in `MscmpSystPerms`.

    ##############################################################################
    #
    # get_effective_perm_grants
    #
    #

    @spec get_effective_perm_grants(
            MscmpSystMcpPerms.Types.AccessAccountPermsSelector.t(),
            Keyword.t()
          ) ::
            {:ok, MscmpSystPerms.Types.perm_grants()} | ErrorTypes.parsable_error()
    def get_effective_perm_grants(selector, opts),
      do: Impl.AccessAccountPermRole.get_effective_perm_grants(selector, opts)

    ##############################################################################
    #
    # list_perm_grants
    #
    #

    @spec list_perm_grants(MscmpSystMcpPerms.Types.AccessAccountPermsSelector.t(), Keyword.t()) ::
            {:ok, [Msdata.SystPermRoles.t()]} | ErrorTypes.parsable_error()
    def list_perm_grants(selector, opts),
      do: Impl.AccessAccountPermRole.list_perm_grants(selector, opts)

    ##############################################################################
    #
    # list_perm_denials
    #
    #

    @spec list_perm_denials(
            MscmpSystMcpPerms.Types.AccessAccountPermsSelector.t(),
            Keyword.t()
          ) ::
            {:ok, [Msdata.SystPerms.t()] | []} | ErrorTypes.parsable_error()
    def list_perm_denials(selector, opts),
      do: Impl.AccessAccountPermRole.list_perm_denials(selector, opts)

    ##############################################################################
    #
    # grant_perm_role
    #
    #

    @spec grant_perm_role(
            MscmpSystMcpPerms.Types.AccessAccountPermsSelector.t(),
            MscmpSystPerms.Types.perm_role_id()
          ) ::
            :ok | ErrorTypes.parsable_error()
    def grant_perm_role(selector, perm_role_id),
      do: Impl.AccessAccountPermRole.grant_perm_role(selector, perm_role_id)

    ##############################################################################
    #
    # revoke_perm_role
    #
    #

    @spec revoke_perm_role(
            MscmpSystMcpPerms.Types.AccessAccountPermsSelector.t(),
            MscmpSystPerms.Types.perm_role_id()
          ) ::
            :ok | ErrorTypes.parsable_error()
    def revoke_perm_role(selector, perm_role_id),
      do: Impl.AccessAccountPermRole.revoke_perm_role(selector, perm_role_id)
  end
end
