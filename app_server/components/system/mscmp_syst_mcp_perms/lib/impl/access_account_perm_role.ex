# Source File: access_account_perm_role.ex
# Location:    musebms/app_server/components/system/mscmp_syst_mcp_perms/lib/impl/access_account_perm_role.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystMcpPerms.Impl.AccessAccountPermRole do
  @moduledoc false

  use Msutils.Guards

  import Ecto.Query

  alias MscmpSystError.Types, as: ErrorTypes
  alias MscmpSystMcpPerms.Types

  ##############################################################################
  #
  # get_effective_perm_grants
  #
  #

  @spec get_effective_perm_grants(Types.AccessAccountPermsSelector.t(), Keyword.t()) ::
          {:ok, MscmpSystPerms.Types.perm_grants()} | ErrorTypes.parsable_error()
  def get_effective_perm_grants(selector, opts) do
    role_query =
      from(aapra in Msdata.SystAccessAccountPermRoleAssigns,
        join: pr in assoc(aapra, :perm_role),
        join: pft in assoc(pr, :perm_functional_type),
        join: prg in assoc(pr, :perm_role_grants),
        join: p in assoc(prg, :perm),
        as: :perms,
        where:
          pft.internal_name == "mcp_access_accounts" and
            aapra.access_account_id == ^selector.access_account_id,
        select: %{
          perm_id: prg.perm_id,
          view_scope: prg.view_scope,
          maint_scope: prg.maint_scope,
          admin_scope: prg.admin_scope,
          ops_scope: prg.ops_scope
        }
      )
      |> maybe_filter_by_permissions(opts[:permissions])

    from(p in Msdata.SystPerms,
      as: :perms,
      join: pft in assoc(p, :perm_functional_type),
      left_join: q in subquery(role_query),
      on: q.perm_id == p.id,
      where: pft.internal_name == "mcp_access_accounts",
      group_by: [p.id, p.internal_name],
      select: %{
        perm_id: p.id,
        perm_name: p.internal_name,
        view_scope: fragment("ms_syst.get_greatest_rights_scope(array_agg(?))", q.view_scope),
        maint_scope: fragment("ms_syst.get_greatest_rights_scope(array_agg(?))", q.maint_scope),
        admin_scope: fragment("ms_syst.get_greatest_rights_scope(array_agg(?))", q.admin_scope),
        ops_scope: fragment("ms_syst.get_greatest_rights_scope(array_agg(?))", q.ops_scope)
      }
    )
    |> maybe_filter_by_permissions(opts[:permissions])
    |> MscmpSystDb.all()
    |> Enum.reduce(%{}, fn perm, perm_map ->
      Map.put_new(perm_map, perm.perm_name, %MscmpSystPerms.Types.PermGrantValue{
        view_scope: String.to_atom(perm.view_scope),
        maint_scope: String.to_atom(perm.maint_scope),
        admin_scope: String.to_atom(perm.admin_scope),
        ops_scope: String.to_atom(perm.ops_scope)
      })
    end)
    |> then(&{:ok, &1})
  rescue
    error in Postgrex.Error -> {:error, MscmpSystDb.get_pg_exception(error)}
    error -> reraise(error, __STACKTRACE__)
  end

  defp maybe_filter_by_permissions(query, :all), do: query

  defp maybe_filter_by_permissions(query, permission) when is_binary(permission),
    do: where(query, [perms: p], p.internal_name == ^permission)

  defp maybe_filter_by_permissions(query, [_ | _] = permissions),
    do: where(query, [perms: p], p.internal_name in ^permissions)

  ##############################################################################
  #
  # list_perm_grants
  #
  #

  @spec list_perm_grants(Types.AccessAccountPermsSelector.t(), Keyword.t()) ::
          {:ok, [Msdata.SystPermRoles.t()]} | ErrorTypes.parsable_error()
  def list_perm_grants(selector, opts) do
    from(pr in Msdata.SystPermRoles,
      as: :perm_roles,
      join: prg in assoc(pr, :perm_role_grants),
      as: :grants,
      join: aapra in Msdata.SystAccessAccountPermRoleAssigns,
      on: aapra.perm_role_id == pr.id,
      where: aapra.access_account_id == ^selector.access_account_id,
      preload: [perm_role_grants: prg],
      select: pr,
      order_by: pr.internal_name
    )
    |> maybe_preload_perms(opts[:preload_perms])
    |> MscmpSystDb.all()
    |> then(&{:ok, &1})
  rescue
    error in Postgrex.Error -> {:error, MscmpSystDb.get_pg_exception(error)}
    error -> reraise(error, __STACKTRACE__)
  end

  defp maybe_preload_perms(query, true) do
    query
    |> join(:inner, [grants: prg], p in assoc(prg, :perm), as: :permission)
    |> preload([grants: prg, permission: p], perm_role_grants: {prg, perm: p})
    |> order_by([permission: p], p.internal_name)
  end

  defp maybe_preload_perms(query, false), do: query

  ##############################################################################
  #
  # list_perm_denials
  #
  #

  @spec list_perm_denials(Types.AccessAccountPermsSelector.t(), Keyword.t()) ::
          {:ok, [Msdata.SystPerms.t()] | []} | ErrorTypes.parsable_error()
  def list_perm_denials(_selector, _opts), do: {:ok, []}

  @spec grant_perm_role(Types.AccessAccountPermsSelector.t(), MscmpSystPerms.Types.perm_role_id()) ::
          :ok | ErrorTypes.parsable_error()
  def grant_perm_role(selector, perm_role_id) do
    %{access_account_id: selector.access_account_id, perm_role_id: perm_role_id}
    |> Msdata.SystAccessAccountPermRoleAssigns.insert_changeset()
    |> MscmpSystDb.insert()
    |> case do
      {:ok, _record} -> :ok
      {:error, error} -> {:error, error}
    end
  rescue
    error in Postgrex.Error -> {:error, MscmpSystDb.get_pg_exception(error)}
    error -> reraise(error, __STACKTRACE__)
  end

  ##############################################################################
  #
  # revoke_perm_role
  #
  #

  @spec revoke_perm_role(
          Types.AccessAccountPermsSelector.t(),
          MscmpSystPerms.Types.perm_role_id()
        ) :: :ok | ErrorTypes.parsable_error()
  def revoke_perm_role(selector, perm_role_id) do
    from(aapra in Msdata.SystAccessAccountPermRoleAssigns,
      where:
        aapra.access_account_id == ^selector.access_account_id and
          aapra.perm_role_id == ^perm_role_id
    )
    |> MscmpSystDb.delete_all()
    |> case do
      {1, _} ->
        :ok

      {0, _} ->
        {:error, {:not_found, "The requested MscmpSystMcpPerms permission role was not found."}}
    end
  rescue
    error in Postgrex.Error -> {:error, MscmpSystDb.get_pg_exception(error)}
    error -> reraise(error, __STACKTRACE__)
  end
end
