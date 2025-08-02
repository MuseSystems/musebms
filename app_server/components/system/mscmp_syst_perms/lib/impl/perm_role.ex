# Source File: perm_role.ex
# Location:    musebms/app_server/components/system/mscmp_syst_perms/lib/impl/perm_role.ex
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
  @moduledoc false

  import Msutils.Guards

  import Ecto.Query

  alias MscmpSystError.Types, as: ErrorTypes
  alias MscmpSystPerms.Types

  ##############################################################################
  #
  # create_perm_role
  #
  #

  @spec create_perm_role(Types.perm_role_params()) ::
          {:ok, Msdata.SystPermRoles.t()} | ErrorTypes.parsable_error()
  def create_perm_role(perm_role_params) do
    perm_role_params
    |> Msdata.SystPermRoles.insert_changeset()
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
  # update_perm_role
  #
  #

  @spec update_perm_role(
          Types.perm_role_id() | Msdata.SystPermRoles.t(),
          Types.perm_role_params()
        ) ::
          {:ok, Msdata.SystPermRoles.t()} | ErrorTypes.parsable_error()
  def update_perm_role(perm_role_id, perm_role_params) when is_uuid(perm_role_id) do
    case MscmpSystDb.get(Msdata.SystPermRoles, perm_role_id) do
      %Msdata.SystPermRoles{} = perm ->
        update_perm_role(perm, perm_role_params)

      nil ->
        {:error, {:not_found, "The requested perm role was not found and could not be updated."}}
    end
  rescue
    error in Postgrex.Error -> {:error, MscmpSystDb.get_pg_exception(error)}
    error -> reraise(error, __STACKTRACE__)
  end

  def update_perm_role(%Msdata.SystPermRoles{} = perm, perm_role_params) do
    perm
    |> Msdata.SystPermRoles.update_changeset(perm_role_params)
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
  # get_perm_role_id_by_name
  #
  #

  @spec get_perm_role_id_by_name(Types.perm_functional_type_name(), Types.perm_role_name()) ::
          {:ok, Types.perm_role_id()} | ErrorTypes.parsable_error()
  def get_perm_role_id_by_name(perm_func_type_name, perm_role_name) do
    from(pr in Msdata.SystPermRoles,
      join: pft in assoc(pr, :perm_functional_type),
      where: pr.internal_name == ^perm_role_name and pft.internal_name == ^perm_func_type_name,
      select: pr.id
    )
    |> MscmpSystDb.one()
    |> case do
      nil ->
        {:error, {:not_found, "The requested perm role was not found."}}

      perm_role_id ->
        {:ok, perm_role_id}
    end
  rescue
    error in Postgrex.Error -> {:error, MscmpSystDb.get_pg_exception(error)}
    error -> reraise(error, __STACKTRACE__)
  end

  ##############################################################################
  #
  # delete_perm_role
  #
  #

  @spec delete_perm_role(Msdata.SystPermRoles.t() | Types.perm_role_id()) ::
          :ok | ErrorTypes.parsable_error()
  def delete_perm_role(perm_role_id) when is_binary(perm_role_id) do
    from(p in Msdata.SystPermRoles, where: p.id == ^perm_role_id)
    |> MscmpSystDb.delete_all()
    |> case do
      {1, _} ->
        :ok

      {0, _} ->
        {:error, {:not_found, "The requested perm role was not found and could not be deleted."}}
    end
  rescue
    error in Postgrex.Error -> {:error, MscmpSystDb.get_pg_exception(error)}
    error -> reraise(error, __STACKTRACE__)
  end

  def delete_perm_role(%Msdata.SystPermRoles{} = perm), do: delete_perm_role(perm.id)
end
