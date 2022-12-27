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
  import Ecto.Query

  alias MscmpSystPerms.Types

  @moduledoc false

  require Logger

  @scopes ["unused", "deny", "same_user", "same_group", "all"]

  @spec create_perm_role_grant(Types.perm_role_grant_params()) ::
          {:ok, Msdata.SystPermRoleGrants.t()} | {:error, MscmpSystError.t()}
  def create_perm_role_grant(perm_role_grant_params) do
    perm_role_grant_params
    |> Msdata.SystPermRoleGrants.insert_changeset()
    |> MscmpSystDb.insert!(returning: true)
    |> then(&{:ok, &1})
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {:error,
       %MscmpSystError{
         code: :undefined_error,
         message: "Failure creating Permission Role Grant.",
         cause: error
       }}
  end

  @spec update_perm_role_grant(
          Types.perm_role_grant_id() | Msdata.SystPermRoleGrants.t(),
          Types.perm_role_grant_params()
        ) ::
          {:ok, Msdata.SystPermRoleGrants.t()} | {:error, MscmpSystError.t()}
  def update_perm_role_grant(perm_role_grant_id, perm_role_grant_params)
      when is_binary(perm_role_grant_id) do
    MscmpSystDb.get!(Msdata.SystPermRoleGrants, perm_role_grant_id)
    |> update_perm_role_grant(perm_role_grant_params)
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {:error,
       %MscmpSystError{
         code: :undefined_error,
         message: "Failure updating Permission Role Grant by ID.",
         cause: error
       }}
  end

  def update_perm_role_grant(
        %Msdata.SystPermRoleGrants{} = perm_role_grant,
        perm_role_grant_params
      ) do
    perm_role_grant
    |> Msdata.SystPermRoleGrants.update_changeset(perm_role_grant_params)
    |> MscmpSystDb.update!(returning: true)
    |> then(&{:ok, &1})
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {:error,
       %MscmpSystError{
         code: :undefined_error,
         message: "Failure updating Permission Role Grant.",
         cause: error
       }}
  end

  @spec delete_perm_role_grant(Msdata.SystPermRoleGrants.t() | Types.perm_role_grant_id()) ::
          {:ok, :deleted | :not_found} | {:error, MscmpSystError.t()}
  def delete_perm_role_grant(perm_role_grant_id) when is_binary(perm_role_grant_id) do
    from(p in Msdata.SystPermRoleGrants, where: p.id == ^perm_role_grant_id)
    |> MscmpSystDb.delete_all()
    |> case do
      {0, _} ->
        {:ok, :not_found}

      {1, _} ->
        {:ok, :deleted}

      error ->
        {:error,
         %MscmpSystError{
           code: :undefined_error,
           message: "Unexpected result deleting Permission Role Grant by ID.",
           cause: error
         }}
    end
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {:error,
       %MscmpSystError{
         code: :undefined_error,
         message: "Failure deleting Permission Role Grant.",
         cause: error
       }}
  end

  def delete_perm_role_grant(%Msdata.SystPermRoleGrants{} = perm),
    do: delete_perm_role_grant(perm.id)

  @spec compare_scopes(Types.rights_scope() | String.t(), Types.rights_scope() | String.t()) ::
          :eq | :gt | :lt
  def compare_scopes(test_scope, standard_scope)
      when is_binary(test_scope) and is_binary(standard_scope) do
    test_scope_score = Enum.find_index(@scopes, &(&1 == test_scope))
    standard_scope_score = Enum.find_index(@scopes, &(&1 == standard_scope))

    cond do
      test_scope_score == standard_scope_score ->
        :eq

      test_scope_score > standard_scope_score ->
        :gt

      test_scope_score < standard_scope_score ->
        :lt

      true ->
        raise MscmpSystError,
          code: :undefined_error,
          message: "Invalid scope comparison.",
          cause: %{parameters: %{test_scope: test_scope, standard_scope: standard_scope}}
    end
  end

  def compare_scopes(test_scope, standard_scope) do
    test_scope = if is_atom(test_scope), do: Atom.to_string(test_scope), else: test_scope

    standard_scope =
      if is_atom(standard_scope), do: Atom.to_string(standard_scope), else: standard_scope

    compare_scopes(test_scope, standard_scope)
  end
end
