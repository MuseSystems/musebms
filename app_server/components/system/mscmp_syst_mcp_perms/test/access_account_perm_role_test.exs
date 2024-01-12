# Source File: access_account_perm_role_test.exs
# Location:    musebms/app_server/components/system/mscmp_syst_mcp_perms/test/access_account_perm_role_test.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule AccessAccountPermRoleTest do
  use McpPermsTestCase, async: true

  import Ecto.Query

  alias MscmpSystMcpPerms.Impl

  @moduletag :unit
  @moduletag :capture_log

  test "Grant Access Account Permission Role" do
    selector =
      from(aa in Msdata.SystAccessAccounts,
        where: aa.internal_name == "owned_all_access",
        select: aa.id
      )
      |> MscmpSystDb.one!()
      |> then(&%MscmpSystMcpPerms.Types.AccessAccountPermsSelector{access_account_id: &1})

    perm_role_id =
      from(pr in Msdata.SystPermRoles, where: pr.internal_name == "global_login", select: pr.id)
      |> MscmpSystDb.one!()

    assert :ok = Impl.AccessAccountPermRole.grant_perm_role(selector, perm_role_id)

    assert {:error, _} = Impl.AccessAccountPermRole.grant_perm_role(selector, perm_role_id)
  end

  test "Revoke Access Account Permission Role" do
    selector =
      from(aa in Msdata.SystAccessAccounts,
        where: aa.internal_name == "owned_all_access",
        select: aa.id
      )
      |> MscmpSystDb.one!()
      |> then(&%MscmpSystMcpPerms.Types.AccessAccountPermsSelector{access_account_id: &1})

    perm_role_id =
      from(pr in Msdata.SystPermRoles, where: pr.internal_name == "mcp_login", select: pr.id)
      |> MscmpSystDb.one!()

    assert {:ok, :deleted} = Impl.AccessAccountPermRole.revoke_perm_role(selector, perm_role_id)
    assert {:ok, :not_found} = Impl.AccessAccountPermRole.revoke_perm_role(selector, perm_role_id)
  end

  test "List Access Account Permission Denial" do
    selector =
      from(aa in Msdata.SystAccessAccounts,
        where: aa.internal_name == "unowned_all_access",
        select: aa.id
      )
      |> MscmpSystDb.one!()
      |> then(&%MscmpSystMcpPerms.Types.AccessAccountPermsSelector{access_account_id: &1})

    # Right now this is effectively a no-op since no explicit permission
    # denial process exists for Access Accounts
    assert {:ok, []} = Impl.AccessAccountPermRole.list_perm_denials(selector, [])
  end

  test "List Access Account Permission Role Grants" do
    selector =
      from(aa in Msdata.SystAccessAccounts,
        where: aa.internal_name == "unowned_all_access",
        select: aa.id
      )
      |> MscmpSystDb.one!()
      |> then(&%MscmpSystMcpPerms.Types.AccessAccountPermsSelector{access_account_id: &1})

    assert {:ok, perm_roles} = Impl.AccessAccountPermRole.list_perm_grants(selector, [])

    assert 2 == length(perm_roles)

    assert %Msdata.SystPermRoles{internal_name: "mcp_login"} =
             Enum.find(perm_roles, &(&1.internal_name == "mcp_login"))

    assert %Msdata.SystPermRoles{internal_name: "global_login"} =
             Enum.find(perm_roles, &(&1.internal_name == "global_login"))

    assert {:ok, perm_roles} =
             Impl.AccessAccountPermRole.list_perm_grants(selector, include_perms: true)

    assert 2 == length(perm_roles)

    assert %Msdata.SystPermRoles{internal_name: "mcp_login"} =
             mcp_login = Enum.find(perm_roles, &(&1.internal_name == "mcp_login"))

    assert %Msdata.SystPermRoleGrants{perm: %Msdata.SystPerms{}} =
             Enum.find(mcp_login.perm_role_grants, &(&1.perm.internal_name == "mcp_login"))

    assert %Msdata.SystPermRoles{internal_name: "global_login"} =
             global_login = Enum.find(perm_roles, &(&1.internal_name == "global_login"))

    assert %Msdata.SystPermRoleGrants{perm: %Msdata.SystPerms{}} =
             Enum.find(global_login.perm_role_grants, &(&1.perm.internal_name == "global_login"))
  end

  test "Get Effective Permission Grants for Access Account" do
    selector =
      from(aa in Msdata.SystAccessAccounts,
        where: aa.internal_name == "unowned_all_access",
        select: aa.id
      )
      |> MscmpSystDb.one!()
      |> then(&%MscmpSystMcpPerms.Types.AccessAccountPermsSelector{access_account_id: &1})

    assert {:ok, %{} = all_grants} =
             Impl.AccessAccountPermRole.get_effective_perm_grants(selector, [])

    assert {
             "mcp_login",
             %{
               view_scope: :unused,
               maint_scope: :unused,
               admin_scope: :unused,
               ops_scope: :all
             }
           } =
             Enum.find(all_grants, fn curr_grant ->
               case curr_grant do
                 {"mcp_login", _} -> true
                 _ -> false
               end
             end)

    assert {
             "global_login",
             %{
               view_scope: :unused,
               maint_scope: :unused,
               admin_scope: :unused,
               ops_scope: :all
             }
           } =
             Enum.find(all_grants, fn curr_grant ->
               case curr_grant do
                 {"global_login", _} -> true
                 _ -> false
               end
             end)

    assert {:ok, %{} = filtered1_grants} =
             Impl.AccessAccountPermRole.get_effective_perm_grants(selector,
               permissions: ["mcp_login"]
             )

    assert {
             "mcp_login",
             %{
               view_scope: :unused,
               maint_scope: :unused,
               admin_scope: :unused,
               ops_scope: :all
             }
           } =
             Enum.find(filtered1_grants, fn curr_grant ->
               case curr_grant do
                 {"mcp_login", _} -> true
                 _ -> false
               end
             end)

    assert nil ==
             Enum.find(filtered1_grants, fn curr_grant ->
               case curr_grant do
                 {"global_login", _} -> true
                 _ -> false
               end
             end)

    assert {:ok, %{} = filtered2_grants} =
             Impl.AccessAccountPermRole.get_effective_perm_grants(selector,
               permissions: "global_login"
             )

    assert {
             "global_login",
             %{
               view_scope: :unused,
               maint_scope: :unused,
               admin_scope: :unused,
               ops_scope: :all
             }
           } =
             Enum.find(filtered2_grants, fn curr_grant ->
               case curr_grant do
                 {"global_login", _} -> true
                 _ -> false
               end
             end)

    assert nil ==
             Enum.find(filtered2_grants, fn curr_grant ->
               case curr_grant do
                 {"mcp_login", _} -> true
                 _ -> false
               end
             end)
  end
end
