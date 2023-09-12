# Source File: perm.ex
# Location:    musebms/components/system/mscmp_syst_perms/lib/impl/perm.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystPerms.Impl.Perm do
  @moduledoc false

  import Ecto.Query

  alias MscmpSystPerms.Types

  require Logger

  @spec create_perm(Types.perm_params()) ::
          {:ok, Msdata.SystPerms.t()} | {:error, MscmpSystError.t()}
  def create_perm(perm_params) do
    perm_params
    |> Msdata.SystPerms.insert_changeset()
    |> MscmpSystDb.insert!(returning: true)
    |> then(&{:ok, &1})
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {:error,
       %MscmpSystError{
         code: :undefined_error,
         message: "Failure creating Permission.",
         cause: error
       }}
  end

  @spec update_perm(Types.perm_id() | Msdata.SystPerms.t(), Types.perm_params()) ::
          {:ok, Msdata.SystPerms.t()} | {:error, MscmpSystError.t()}
  def update_perm(perm_id, perm_params) when is_binary(perm_id) do
    MscmpSystDb.get!(Msdata.SystPerms, perm_id)
    |> update_perm(perm_params)
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {:error,
       %MscmpSystError{
         code: :undefined_error,
         message: "Failure updating Permission by ID.",
         cause: error
       }}
  end

  def update_perm(%Msdata.SystPerms{} = perm, perm_params) do
    perm
    |> Msdata.SystPerms.update_changeset(perm_params)
    |> MscmpSystDb.update!(returning: true)
    |> then(&{:ok, &1})
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {:error,
       %MscmpSystError{
         code: :undefined_error,
         message: "Failure updating Permission.",
         cause: error
       }}
  end

  @spec delete_perm(Msdata.SystPerms.t() | Types.perm_id()) ::
          {:ok, :deleted | :not_found} | {:error, MscmpSystError.t()}
  def delete_perm(perm_id) when is_binary(perm_id) do
    from(p in Msdata.SystPerms, where: p.id == ^perm_id)
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
           message: "Unexpected result deleting Permission by ID.",
           cause: error
         }}
    end
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {:error,
       %MscmpSystError{
         code: :undefined_error,
         message: "Failure deleting Permission.",
         cause: error
       }}
  end

  def delete_perm(%Msdata.SystPerms{} = perm), do: delete_perm(perm.id)
end
