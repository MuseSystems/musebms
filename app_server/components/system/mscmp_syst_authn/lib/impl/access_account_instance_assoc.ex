# Source File: access_account_instance_assoc.ex
# Location:    musebms/app_server/components/system/mscmp_syst_authn/lib/impl/access_account_instance_assoc.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystAuthn.Impl.AccessAccountInstanceAssoc do
  @moduledoc false

  import Msutils.Guards

  import Ecto.Query

  alias MscmpSystAuthn.Types

  ##############################################################################
  #
  # invite_to_instance
  #
  #

  @spec invite_to_instance(
          Types.access_account_id(),
          MscmpSystInstance.Types.instance_id(),
          Keyword.t()
        ) :: {:ok, Msdata.SystAccessAccountInstanceAssocs.t()} | {:error, term()}
  def invite_to_instance(access_account_id, instance_id, opts)
      when is_uuid(access_account_id) and is_uuid(instance_id) do
    date_now = DateTime.now!("Etc/UTC")
    date_invitation = date_now
    date_accepted = if opts[:create_accepted], do: date_now, else: nil

    date_expire =
      if opts[:create_accepted],
        do: nil,
        else: DateTime.add(date_now, opts[:expiration_days] * 24 * 60 * 60, :second)

    invite_params = %{
      access_account_id: access_account_id,
      instance_id: instance_id,
      invitation_issued: date_invitation,
      access_granted: date_accepted,
      invitation_expires: date_expire
    }

    case get_access_account_instance_assoc(access_account_id, instance_id) do
      {:ok, target_record} -> reinvite(target_record, invite_params)
      {:error, :not_found} -> create_record(invite_params)
    end
  end

  defp reinvite(
         %Msdata.SystAccessAccountInstanceAssocs{} = target_record,
         invite_params
       ) do
    with :ok <- verify_not_accepted(target_record) do
      update_record(target_record, invite_params)
    end
  end

  ##############################################################################
  #
  # accept_instance_invite
  #
  #

  @spec accept_instance_invite(
          Types.access_account_id(),
          MscmpSystInstance.Types.instance_id()
        ) ::
          {:ok, Msdata.SystAccessAccountInstanceAssocs.t()}
          | {:error, :not_found}
          | {:error, term()}
  def accept_instance_invite(access_account_id, instance_id)
      when is_uuid(access_account_id) and is_uuid(instance_id) do
    with {:ok, assoc} <- get_access_account_instance_assoc(access_account_id, instance_id) do
      accept_instance_invite(assoc)
    end
  end

  @spec accept_instance_invite(
          Types.access_account_instance_assoc_id()
          | Msdata.SystAccessAccountInstanceAssocs.t()
        ) ::
          {:ok, Msdata.SystAccessAccountInstanceAssocs.t()}
          | {:error, :not_found}
          | {:error, term()}
  def accept_instance_invite(assoc_id) when is_uuid(assoc_id) do
    with {:ok, assoc} <- get_access_account_instance_assoc(assoc_id) do
      accept_instance_invite(assoc)
    end
  end

  def accept_instance_invite(%Msdata.SystAccessAccountInstanceAssocs{} = assoc) do
    with :ok <- verify_not_accepted(assoc),
         :ok <- verify_not_declined(assoc),
         :ok <- verify_not_expired(assoc) do
      update_record(assoc, %{access_granted: DateTime.now!("Etc/UTC")})
    end
  end

  ##############################################################################
  #
  # instance_access_granted?
  #
  #

  @spec instance_access_granted?(
          Types.access_account_id(),
          MscmpSystInstance.Types.instance_id()
        ) :: boolean()
  def instance_access_granted?(access_account_id, instance_id) do
    from(aaia in Msdata.SystAccessAccountInstanceAssocs,
      where:
        aaia.access_account_id == ^access_account_id and aaia.instance_id == ^instance_id and
          not is_nil(aaia.access_granted)
    )
    |> MscmpSystDb.exists?()
  end

  ##############################################################################
  #
  # decline_instance_invite
  #
  #

  @spec decline_instance_invite(
          Types.access_account_id(),
          MscmpSystInstance.Types.instance_id()
        ) ::
          {:ok, Msdata.SystAccessAccountInstanceAssocs.t()}
          | {:error, :not_found}
          | {:error, term()}
  def decline_instance_invite(access_account_id, instance_id) do
    with {:ok, assoc} <- get_access_account_instance_assoc(access_account_id, instance_id) do
      decline_instance_invite(assoc)
    end
  end

  @spec decline_instance_invite(
          Types.access_account_instance_assoc_id()
          | Msdata.SystAccessAccountInstanceAssocs.t()
        ) ::
          {:ok, Msdata.SystAccessAccountInstanceAssocs.t()} | {:error, term()}
  def decline_instance_invite(assoc_id) when is_uuid(assoc_id) do
    with {:ok, assoc} <- get_access_account_instance_assoc(assoc_id) do
      decline_instance_invite(assoc)
    end
  end

  def decline_instance_invite(%Msdata.SystAccessAccountInstanceAssocs{} = assoc) do
    with :ok <- verify_not_accepted(assoc),
         :ok <- verify_not_declined(assoc),
         :ok <- verify_not_expired(assoc) do
      update_record(assoc, %{
        invitation_declined: DateTime.now!("Etc/UTC")
      })
    end
  end

  ##############################################################################
  #
  # revoke_instance_access
  #
  #

  @spec revoke_instance_access(Types.access_account_id(), MscmpSystInstance.Types.instance_id()) ::
          :ok | {:error, :not_found} | {:error, term()}
  def revoke_instance_access(access_account_id, instance_id) do
    with {:ok, assoc} <- get_access_account_instance_assoc(access_account_id, instance_id) do
      revoke_instance_access(assoc)
    end
  end

  @spec revoke_instance_access(
          Types.access_account_instance_assoc_id()
          | Msdata.SystAccessAccountInstanceAssocs.t()
        ) :: :ok | {:error, :not_found} | {:error, term()}
  def revoke_instance_access(assoc_id) when is_uuid(assoc_id) do
    with {:ok, assoc} <- get_access_account_instance_assoc(assoc_id) do
      revoke_instance_access(assoc)
    end
  end

  def revoke_instance_access(%Msdata.SystAccessAccountInstanceAssocs{} = assoc),
    do: delete_record(assoc)

  ##############################################################################
  #
  # General Use Private Functions
  #
  #

  defp get_access_account_instance_assoc(access_account_id, instance_id) do
    from(aaia in Msdata.SystAccessAccountInstanceAssocs,
      where: aaia.access_account_id == ^access_account_id and aaia.instance_id == ^instance_id
    )
    |> MscmpSystDb.one()
    |> case do
      nil -> {:error, :not_found}
      record -> {:ok, record}
    end
  end

  defp get_access_account_instance_assoc(record_id) when is_uuid(record_id) do
    case MscmpSystDb.get(Msdata.SystAccessAccountInstanceAssocs, record_id) do
      nil -> {:error, :not_found}
      record -> {:ok, record}
    end
  end

  defp verify_not_accepted(
         %Msdata.SystAccessAccountInstanceAssocs{access_granted: access_granted} = record
       )
       when not is_nil(access_granted),
       do: {:error, {:accepted, record}}

  defp verify_not_accepted(_), do: :ok

  defp verify_not_expired(
         %Msdata.SystAccessAccountInstanceAssocs{invitation_expires: invitation_expires} = record
       )
       when not is_nil(invitation_expires) do
    case DateTime.diff(invitation_expires, DateTime.now!("Etc/UTC")) < 0 do
      true -> {:error, {:expired, record}}
      false -> :ok
    end
  end

  defp verify_not_expired(_), do: :ok

  defp verify_not_declined(
         %Msdata.SystAccessAccountInstanceAssocs{invitation_declined: invitation_declined} =
           record
       )
       when not is_nil(invitation_declined),
       do: {:error, {:declined, record}}

  defp verify_not_declined(_), do: :ok

  defp create_record(insert_params) do
    insert_params
    |> Msdata.SystAccessAccountInstanceAssocs.insert_changeset()
    |> MscmpSystDb.insert(returning: true)
    |> case do
      {:ok, _} = result -> result
      error -> {:error, {:database_error, error}}
    end
  end

  defp update_record(target_record, update_params) do
    target_record
    |> Msdata.SystAccessAccountInstanceAssocs.update_changeset(update_params)
    |> MscmpSystDb.update(returning: true)
    |> case do
      {:ok, _} = result -> result
      error -> {:error, {:database_error, error}}
    end
  end

  defp delete_record(target_record) do
    case MscmpSystDb.delete(target_record) do
      {:ok, _} -> :ok
      error -> {:error, {:database_error, error}}
    end
  end
end
