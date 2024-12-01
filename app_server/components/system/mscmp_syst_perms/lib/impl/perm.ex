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

  use Msutils.Guards

  import Ecto.Query

  alias MscmpSystPerms.Types

  @spec create_perm(Types.perm_params()) ::
          {:ok, Msdata.SystPerms.t()} | {:error, term()}
  def create_perm(perm_params) do
    perm_params
    |> Msdata.SystPerms.insert_changeset()
    |> MscmpSystDb.insert(returning: true)
    |> case do
      {:ok, perm} -> {:ok, perm}
      error -> {:error, error}
    end
  end

  @spec update_perm(Types.perm_id() | Msdata.SystPerms.t(), Types.perm_params()) ::
          {:ok, Msdata.SystPerms.t()} | {:error, :not_found} | {:error, term()}
  def update_perm(perm_id, perm_params) when is_uuid(perm_id) do
    case MscmpSystDb.get(Msdata.SystPerms, perm_id) do
      %Msdata.SystPerms{} = perm -> update_perm(perm, perm_params)
      nil -> {:error, :not_found}
      error -> {:error, error}
    end
  end

  def update_perm(%Msdata.SystPerms{} = perm, perm_params) do
    perm
    |> Msdata.SystPerms.update_changeset(perm_params)
    |> MscmpSystDb.update(returning: true)
    |> case do
      {:ok, perm} -> {:ok, perm}
      error -> {:error, error}
    end
  end

  @spec delete_perm(Msdata.SystPerms.t() | Types.perm_id()) ::
          :ok | {:error, :not_found}
  def delete_perm(perm_id) when is_uuid(perm_id) do
    from(p in Msdata.SystPerms, where: p.id == ^perm_id)
    |> MscmpSystDb.delete_all()
    |> case do
      {1, _} -> :ok
      {0, _} -> {:error, :not_found}
    end
  rescue
    error -> {:error, error}
  end

  def delete_perm(%Msdata.SystPerms{} = perm), do: delete_perm(perm.id)
end
