# Source File: perm_role_grant.ex
# Location:    musebms/components/system/mscmp_syst_perms/lib/impl/perm_role_grant.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystPerms.Impl.PermRoleGrant do
  @moduledoc false

  use Msutils.Guards

  import Ecto.Query

  alias MscmpSystError.Types, as: ErrorTypes
  alias MscmpSystPerms.Types

  @scopes ["unused", "deny", "same_user", "same_group", "all"]

  ##############################################################################
  #
  # create_perm_role_grant
  #
  #

  @spec create_perm_role_grant(Types.perm_role_grant_params()) ::
          {:ok, Msdata.SystPermRoleGrants.t()} | ErrorTypes.parsable_error()
  def create_perm_role_grant(perm_role_grant_params) do
    perm_role_grant_params
    |> Msdata.SystPermRoleGrants.insert_changeset()
    |> MscmpSystDb.insert(returning: true)
    |> case do
      {:ok, perm} -> {:ok, perm}
      error -> {:error, error}
    end
  rescue
    error in Postgrex.Error -> {:error, MscmpSystDb.get_pg_exception(error)}
    error -> reraise(error, __STACKTRACE__)
  end

  ##############################################################################
  #
  # update_perm_role_grant
  #
  #

  @spec update_perm_role_grant(
          Types.perm_role_grant_id() | Msdata.SystPermRoleGrants.t(),
          Types.perm_role_grant_params()
        ) ::
          {:ok, Msdata.SystPermRoleGrants.t()} | ErrorTypes.parsable_error()
  def update_perm_role_grant(perm_role_grant_id, perm_role_grant_params)
      when is_uuid(perm_role_grant_id) do
    case MscmpSystDb.get(Msdata.SystPermRoleGrants, perm_role_grant_id) do
      %Msdata.SystPermRoleGrants{} = perm_role_grant ->
        update_perm_role_grant(perm_role_grant, perm_role_grant_params)

      nil ->
        {:error,
         {:not_found, "The requested perm role grant was not found and could not be updated."}}

      error ->
        {:error, error}
    end
  rescue
    error in Postgrex.Error -> {:error, MscmpSystDb.get_pg_exception(error)}
    error -> reraise(error, __STACKTRACE__)
  end

  def update_perm_role_grant(
        %Msdata.SystPermRoleGrants{} = perm_role_grant,
        perm_role_grant_params
      ) do
    perm_role_grant
    |> Msdata.SystPermRoleGrants.update_changeset(perm_role_grant_params)
    |> MscmpSystDb.update(returning: true)
    |> case do
      {:ok, perm} -> {:ok, perm}
      error -> {:error, error}
    end
  rescue
    error in Postgrex.Error -> {:error, MscmpSystDb.get_pg_exception(error)}
    error -> reraise(error, __STACKTRACE__)
  end

  ##############################################################################
  #
  # delete_perm_role_grant
  #
  #

  @spec delete_perm_role_grant(Msdata.SystPermRoleGrants.t() | Types.perm_role_grant_id()) ::
          :ok | ErrorTypes.parsable_error()
  def delete_perm_role_grant(perm_role_grant_id) when is_uuid(perm_role_grant_id) do
    from(p in Msdata.SystPermRoleGrants, where: p.id == ^perm_role_grant_id)
    |> MscmpSystDb.delete_all()
    |> case do
      {1, _} ->
        :ok

      {0, _} ->
        {:error,
         {:not_found, "The requested perm role grant was not found and could not be deleted."}}
    end
  rescue
    error in Postgrex.Error -> {:error, MscmpSystDb.get_pg_exception(error)}
    error -> reraise(error, __STACKTRACE__)
  end

  def delete_perm_role_grant(%Msdata.SystPermRoleGrants{} = perm),
    do: delete_perm_role_grant(perm.id)

  ##############################################################################
  #
  # compare_scopes
  #
  #

  @spec compare_scopes(Types.rights_scope() | String.t(), Types.rights_scope() | String.t()) ::
          :eq | :gt | :lt
  def compare_scopes(test_scope, standard_scope)
      when is_binary(test_scope) and is_binary(standard_scope) do
    test_scope_score = Enum.find_index(@scopes, &(&1 == test_scope))
    standard_scope_score = Enum.find_index(@scopes, &(&1 == standard_scope))

    cond do
      test_scope_score == standard_scope_score -> :eq
      test_scope_score > standard_scope_score -> :gt
      test_scope_score < standard_scope_score -> :lt
      true -> raise "Invalid scope comparison."
    end
  end

  def compare_scopes(test_scope, standard_scope) do
    test_scope = if is_atom(test_scope), do: Atom.to_string(test_scope), else: test_scope

    standard_scope =
      if is_atom(standard_scope), do: Atom.to_string(standard_scope), else: standard_scope

    compare_scopes(test_scope, standard_scope)
  end
end
