# Source File: access_account_instance_assoc.ex
# Location:    musebms/components/system/msbms_syst_authentication/lib/impl/access_account_instance_assoc.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MsbmsSystAuthentication.Impl.AccessAccountInstanceAssoc do
  import Ecto.Query
  import MsbmsSystUtils

  alias MsbmsSystAuthentication.Data
  alias MsbmsSystAuthentication.Types

  require Logger

  @moduledoc false

  @spec invite_to_instance(
          Types.access_account_id(),
          MsbmsSystInstanceMgr.Types.instance_id(),
          Types.credential_type_id(),
          Keyword.t()
        ) :: {:ok, Data.SystAccessAccountInstanceAssocs.t()} | {:error, MsbmsSystError.t()}
  def invite_to_instance(
        access_account_id,
        instance_id,
        credential_type_id,
        opts
      )
      when is_binary(access_account_id) and is_binary(instance_id) and
             is_binary(credential_type_id) do
    opts = resolve_options(opts, create_accepted: false, expiration_days: 30)

    date_now = DateTime.now!("Etc/UTC")
    date_invitation = date_now
    date_accepted = if opts[:create_accepted], do: date_now, else: nil

    date_expire =
      unless opts[:create_accepted],
        do: DateTime.add(date_now, opts[:expiration_days] * 24 * 60 * 60, :second),
        else: nil

    invite_params = %{
      access_account_id: access_account_id,
      instance_id: instance_id,
      credential_type_id: credential_type_id,
      invitation_issued: date_invitation,
      access_granted: date_accepted,
      invitation_expires: date_expire
    }

    target_record =
      get_access_account_instance_assoc(access_account_id, instance_id, credential_type_id)

    invite_or_reinvite(target_record, invite_params)
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MsbmsSystError{
          code: :undefined_error,
          message: "Failure inviting Access Account to Instance.",
          cause: error
        }
      }
  end

  defp invite_or_reinvite(nil = _target_record, invite_params), do: create_record(invite_params)

  defp invite_or_reinvite(
         %Data.SystAccessAccountInstanceAssocs{} = target_record,
         invite_params
       ) do
    target_record
    |> verify_not_accepted()
    |> update_record(invite_params)
  end

  @spec accept_instance_invite(
          Types.access_account_id(),
          MsbmsSystInstanceMgr.Types.instance_id(),
          Types.credential_type_id()
        ) :: {:ok, Data.SystAccessAccountInstanceAssocs.t()} | {:error, MsbmsSystError.t()}
  def accept_instance_invite(access_account_id, instance_id, credential_type_id)
      when is_binary(access_account_id) and is_binary(instance_id) and
             is_binary(credential_type_id) do
    get_access_account_instance_assoc(access_account_id, instance_id, credential_type_id)
    |> accept_instance_invite()
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MsbmsSystError{
          code: :undefined_error,
          message: "Failure accepting Access Account invitation to Instance by composite key.",
          cause: error
        }
      }
  end

  @spec accept_instance_invite(
          Types.access_account_instance_assoc_id()
          | Data.SystAccessAccountInstanceAssocs.t()
        ) ::
          {:ok, Data.SystAccessAccountInstanceAssocs.t()} | {:error, MsbmsSystError.t()}
  def accept_instance_invite(access_account_instance_assoc_id)
      when is_binary(access_account_instance_assoc_id) do
    access_account_instance_assoc_id
    |> get_access_account_instance_assoc()
    |> accept_instance_invite()
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MsbmsSystError{
          code: :undefined_error,
          message: "Failure accepting Access Account invitation to Instance by ID.",
          cause: error
        }
      }
  end

  def accept_instance_invite(
        %Data.SystAccessAccountInstanceAssocs{} = access_account_instance_assoc
      ) do
    access_account_instance_assoc
    |> verify_not_accepted()
    |> verify_not_declined()
    |> verify_not_expired()
    |> update_record(%{access_granted: DateTime.now!("Etc/UTC")})
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MsbmsSystError{
          code: :undefined_error,
          message: "Failure accepting Access Account invitation to Instance.",
          cause: error
        }
      }
  end

  @spec decline_instance_invite(
          Types.access_account_id(),
          MsbmsSystInstanceMgr.Types.instance_id(),
          Types.credential_type_id()
        ) :: {:ok, Data.SystAccessAccountInstanceAssocs.t()} | {:error, MsbmsSystError.t()}
  def decline_instance_invite(access_account_id, instance_id, credential_type_id)
      when is_binary(access_account_id) and is_binary(instance_id) and
             is_binary(credential_type_id) do
    get_access_account_instance_assoc(access_account_id, instance_id, credential_type_id)
    |> decline_instance_invite()
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MsbmsSystError{
          code: :undefined_error,
          message: "Failure declining Access Account invitation to Instance by composite key.",
          cause: error
        }
      }
  end

  @spec decline_instance_invite(
          Types.access_account_instance_assoc_id()
          | Data.SystAccessAccountInstanceAssocs.t()
        ) ::
          {:ok, Data.SystAccessAccountInstanceAssocs.t()} | {:error, MsbmsSystError.t()}
  def decline_instance_invite(access_account_instance_assoc_id)
      when is_binary(access_account_instance_assoc_id) do
    access_account_instance_assoc_id
    |> get_access_account_instance_assoc()
    |> decline_instance_invite()
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MsbmsSystError{
          code: :undefined_error,
          message: "Failure declining Access Account invitation to Instance by ID.",
          cause: error
        }
      }
  end

  def decline_instance_invite(
        %Data.SystAccessAccountInstanceAssocs{} = access_account_instance_assoc
      ) do
    access_account_instance_assoc
    |> verify_not_accepted()
    |> verify_not_declined()
    |> verify_not_expired()
    |> update_record(%{invitation_declined: DateTime.now!("Etc/UTC")})
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MsbmsSystError{
          code: :undefined_error,
          message: "Failure declining Access Account invitation to Instance.",
          cause: error
        }
      }
  end

  @spec revoke_instance_access(
          Types.access_account_id(),
          MsbmsSystInstanceMgr.Types.instance_id(),
          Types.credential_type_id()
        ) :: :ok | {:error, MsbmsSystError.t()}
  def revoke_instance_access(access_account_id, instance_id, credential_type_id)
      when is_binary(access_account_id) and is_binary(instance_id) and
             is_binary(credential_type_id) do
    get_access_account_instance_assoc(access_account_id, instance_id, credential_type_id)
    |> revoke_instance_access()
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MsbmsSystError{
          code: :undefined_error,
          message: "Failure revoking Access Account invitation to Instance by composite key.",
          cause: error
        }
      }
  end

  @spec revoke_instance_access(
          Types.access_account_instance_assoc_id()
          | Data.SystAccessAccountInstanceAssocs.t()
        ) ::
          :ok | {:error, MsbmsSystError.t()}
  def revoke_instance_access(access_account_instance_assoc_id)
      when is_binary(access_account_instance_assoc_id) do
    access_account_instance_assoc_id
    |> get_access_account_instance_assoc()
    |> revoke_instance_access()
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MsbmsSystError{
          code: :undefined_error,
          message: "Failure revoking Access Account invitation to Instance by ID.",
          cause: error
        }
      }
  end

  def revoke_instance_access(
        %Data.SystAccessAccountInstanceAssocs{} = access_account_instance_assoc
      ) do
    delete_record(access_account_instance_assoc)
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MsbmsSystError{
          code: :undefined_error,
          message: "Failure revoking Access Account invitation to Instance.",
          cause: error
        }
      }
  end

  defp get_access_account_instance_assoc(access_account_id, instance_id, credential_type_id) do
    from(aaia in Data.SystAccessAccountInstanceAssocs,
      where:
        aaia.access_account_id == ^access_account_id and aaia.instance_id == ^instance_id and
          aaia.credential_type_id == ^credential_type_id
    )
    |> MsbmsSystDatastore.one()
  end

  defp get_access_account_instance_assoc(record_id) when is_binary(record_id) do
    MsbmsSystDatastore.get!(Data.SystAccessAccountInstanceAssocs, record_id)
  end

  defp verify_not_accepted(
         %Data.SystAccessAccountInstanceAssocs{access_granted: access_granted} = record
       )
       when not is_nil(access_granted) do
    raise MsbmsSystError,
      message: """
      The requested action may not be taken on an Access Account/Instance Assoc.
      record which has already been accepted."
      """,
      code: :undefined_error,
      cause: %{parameters: [access_account_instance_assoc: record]}
  end

  defp verify_not_accepted(record), do: record

  defp verify_not_expired(
         %Data.SystAccessAccountInstanceAssocs{invitation_expires: invitation_expires} = record
       )
       when not is_nil(invitation_expires) do
    case DateTime.diff(invitation_expires, DateTime.now!("Etc/UTC")) < 0 do
      true ->
        raise MsbmsSystError,
          message: """
          The requested action may not be taken on an Access Account/Instance Assoc.
          record which has expired."
          """,
          code: :undefined_error,
          cause: %{parameters: [access_account_instance_assoc: record]}

      false ->
        record
    end
  end

  defp verify_not_expired(record), do: record

  defp verify_not_declined(
         %Data.SystAccessAccountInstanceAssocs{invitation_declined: invitation_declined} = record
       )
       when not is_nil(invitation_declined) do
    raise MsbmsSystError,
      message: """
      The requested action may not be taken on an Access Account/Instance Assoc.
      record which has been declined."
      """,
      code: :undefined_error,
      cause: %{parameters: [access_account_instance_assoc: record]}
  end

  defp verify_not_declined(record), do: record

  defp create_record(insert_params) do
    insert_params
    |> Data.SystAccessAccountInstanceAssocs.insert_changeset()
    |> MsbmsSystDatastore.insert!(returning: true)
    |> then(&{:ok, &1})
  end

  defp update_record(target_record, update_params) do
    target_record
    |> Data.SystAccessAccountInstanceAssocs.update_changeset(update_params)
    |> MsbmsSystDatastore.update!(returning: true)
    |> then(&{:ok, &1})
  end

  defp delete_record(target_record) do
    MsbmsSystDatastore.delete!(target_record)
    :ok
  end
end
