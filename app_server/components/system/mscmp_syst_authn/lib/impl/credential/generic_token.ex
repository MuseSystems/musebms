# Source File: generic_token.ex
# Location:    musebms/app_server/components/system/mscmp_syst_authn/lib/impl/credential/generic_token.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystAuthn.Impl.Credential.GenericToken do
  @moduledoc false

  import Ecto.Query

  alias MscmpSystAuthn.Impl
  alias MscmpSystAuthn.Types

  @token_types [
    :credential_types_sysdef_token_api,
    :credential_types_sysdef_token_validation,
    :credential_types_sysdef_token_recovery
  ]

  # Credential Types for API Token, Validation, and Recovery use the same basic
  # implementation mechanics, but are applicable to different usage contexts.
  # In this module we implement the common mechanics for all of these 'token'
  # based credential types.  The functions of this module should not be used
  # directly, but rather via the appropriate specialized modules for each type.

  ##############################################################################
  #
  # confirm_credential
  #
  #

  @spec confirm_credential(
          Types.credential_types(),
          Types.access_account_id(),
          Types.identity_id() | nil,
          Types.credential()
        ) :: {:ok, Types.credential_confirm_result()} | {:error, term()}
  def confirm_credential(credential_type, access_account_id, identity_id, token)
      when credential_type in @token_types do
    with {:ok, cred} <- get_credential_record(credential_type, access_account_id, identity_id),
         :ok <- maybe_confirm_api_token_hash(cred, token) do
      {:ok, {:confirmed, []}}
    else
      {:error, :not_found} -> {:ok, {:no_credential, []}}
      {:error, :wrong_credential} -> {:ok, {:wrong_credential, []}}
      error -> error
    end
  end

  defp maybe_confirm_api_token_hash(cred, token) do
    if Impl.Hash.verify_credential_hash(cred.credential_data, token),
      do: :ok,
      else: {:error, :wrong_credential}
  end

  ##############################################################################
  #
  # set_credential
  #
  #

  @spec set_credential(
          Types.credential_types(),
          Types.access_account_id(),
          Types.identity_id() | nil,
          Types.credential() | nil,
          Keyword.t()
        ) :: {:ok, Types.credential()} | {:error, term()}
  def set_credential(credential_type, access_account_id, identity_id, token, opts)
      when credential_type in @token_types do
    token =
      token ||
        Msutils.String.get_random_string(
          opts[:credential_token_length],
          opts[:credential_tokens]
        )

    with :ok <- confirm_identity_ownership(access_account_id, identity_id),
         {:ok, cred} <-
           maybe_get_credential_record(credential_type, access_account_id, identity_id) do
      set_credential_data(credential_type, cred, access_account_id, identity_id, token)
    end
  end

  defp maybe_get_credential_record(credential_type, access_account_id, identity_id) do
    case get_credential_record(credential_type, access_account_id, identity_id) do
      {:ok, cred} -> {:ok, cred}
      {:error, :not_found} -> {:ok, nil}
    end
  end

  defp set_credential_data(credential_type, nil = _cred, access_account_id, identity_id, token) do
    credential_type = Atom.to_string(credential_type)

    %{id: credential_type_id} =
      MscmpSystEnums.get_item_by_name("credential_types", credential_type)

    password_hash = Impl.Hash.create_credential_hash(token)

    %{
      access_account_id: access_account_id,
      credential_type_id: credential_type_id,
      credential_data: password_hash,
      credential_for_identity_id: identity_id
    }
    |> Msdata.SystCredentials.insert_changeset()
    |> MscmpSystDb.insert()
    |> case do
      {:ok, _} -> {:ok, token}
      error -> {:error, {:token_set_error, error}}
    end
  end

  defp set_credential_data(_credential_type, _cred, _access_account_id, _identity_id, _api_token),
    do: {:error, :invalid_token_set}

  defp confirm_identity_ownership(access_account_id, identity_id) do
    from(i in Msdata.SystIdentities,
      where: i.id == ^identity_id and i.access_account_id == ^access_account_id
    )
    |> MscmpSystDb.exists?()
    |> case do
      true -> :ok
      false -> {:error, :identity_ownership_mismatch}
    end
  end

  ##############################################################################
  #
  # get_credential_record
  #
  #

  @spec get_credential_record(
          Types.credential_types(),
          Types.access_account_id(),
          Types.identity_id() | nil
        ) ::
          {:ok, Msdata.SystCredentials.t()} | {:error, :not_found} | {:error, term()}
  def get_credential_record(credential_type, access_account_id, identity_id)
      when is_atom(credential_type) and is_binary(access_account_id) and is_binary(identity_id) do
    credential_type = Atom.to_string(credential_type)

    from(
      c in Msdata.SystCredentials,
      join: ct in assoc(c, :credential_type),
      where:
        ct.internal_name == ^credential_type and
          c.access_account_id == ^access_account_id and
          c.credential_for_identity_id == ^identity_id,
      select: c
    )
    |> MscmpSystDb.one()
    |> case do
      nil -> {:error, :not_found}
      cred -> {:ok, cred}
    end
  end

  def get_credential_record(_credential_type, _access_account_id, _identity_id),
    do: {:error, :invalid_request}

  ##############################################################################
  #
  # delete_credential
  #
  #

  # Token types involve a matched pair of Identity and Credential records and as
  # such any attempt to delete one will delete the other.  This deletion is done
  # at the database level via foreign key constraints or triggers depending on
  # which of the pair are deleted.

  @spec delete_credential(
          Types.credential_types(),
          Types.credential_id() | Msdata.SystCredentials.t()
        ) ::
          :ok | {:error, :not_found} | {:error, term()}

  def delete_credential(credential_type, credential_id)
      when credential_type in @token_types and is_binary(credential_id) do
    cred_type_param = Atom.to_string(credential_type)

    from(c in Msdata.SystCredentials,
      join: ct in assoc(c, :credential_type),
      select: c,
      where: c.id == ^credential_id and ct.internal_name == ^cred_type_param
    )
    |> MscmpSystDb.one()
    |> case do
      nil -> {:error, :not_found}
      cred -> delete_credential(credential_type, cred)
    end
  end

  def delete_credential(credential_type, %Msdata.SystCredentials{} = cred) do
    %{internal_name: target_cred_type_name} =
      MscmpSystEnums.get_item_by_id("credential_types", cred.credential_type_id)

    if target_cred_type_name == Atom.to_string(credential_type) do
      MscmpSystDb.delete(cred)
      |> case do
        {:ok, _} -> :ok
        error -> {:error, error}
      end
    else
      raise "Incorrect Credential Type for Credential record delete."
    end
  end
end
