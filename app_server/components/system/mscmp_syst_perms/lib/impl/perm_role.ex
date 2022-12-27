# Source File: perm_role.ex
# Location:    musebms/components/system/mscmp_syst_perms/lib/impl/perm_role.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystPerms.Impl.PermRole do
  import Ecto.Query

  alias MscmpSystPerms.Types

  @moduledoc false

  require Logger

  @spec create_perm_role(Types.perm_role_params()) ::
          {:ok, Msdata.SystPermRoles.t()} | {:error, MscmpSystError.t()}
  def create_perm_role(perm_role_params) do
    perm_role_params
    |> Msdata.SystPermRoles.insert_changeset()
    |> MscmpSystDb.insert!(returning: true)
    |> then(&{:ok, &1})
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {:error,
       %MscmpSystError{
         code: :undefined_error,
         message: "Failure creating Permission Role.",
         cause: error
       }}
  end

  @spec update_perm_role(
          Types.perm_role_id() | Msdata.SystPermRoles.t(),
          Types.perm_role_params()
        ) ::
          {:ok, Msdata.SystPermRoles.t()} | {:error, MscmpSystError.t()}
  def update_perm_role(perm_role_id, perm_role_params) when is_binary(perm_role_id) do
    MscmpSystDb.get!(Msdata.SystPermRoles, perm_role_id)
    |> update_perm_role(perm_role_params)
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {:error,
       %MscmpSystError{
         code: :undefined_error,
         message: "Failure updating Permission Role by ID.",
         cause: error
       }}
  end

  def update_perm_role(%Msdata.SystPermRoles{} = perm, perm_role_params) do
    perm
    |> Msdata.SystPermRoles.update_changeset(perm_role_params)
    |> MscmpSystDb.update!(returning: true)
    |> then(&{:ok, &1})
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {:error,
       %MscmpSystError{
         code: :undefined_error,
         message: "Failure updating Permission Role.",
         cause: error
       }}
  end

  @spec delete_perm_role(Msdata.SystPermRoles.t() | Types.perm_role_id()) ::
          {:ok, :deleted | :not_found} | {:error, MscmpSystError.t()}
  def delete_perm_role(perm_role_id) when is_binary(perm_role_id) do
    from(p in Msdata.SystPermRoles, where: p.id == ^perm_role_id)
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
           message: "Unexpected result deleting Permission Role by ID.",
           cause: error
         }}
    end
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {:error,
       %MscmpSystError{
         code: :undefined_error,
         message: "Failure deleting Permission Role.",
         cause: error
       }}
  end

  def delete_perm_role(%Msdata.SystPermRoles{} = perm), do: delete_perm_role(perm.id)
end
