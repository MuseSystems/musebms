# Source File: generic_token.ex
# Location:    musebms/components/system/msbms_syst_authentication/lib/impl/credential/generic_token.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MsbmsSystAuthentication.Impl.Credential.GenericToken do
  import Ecto.Query

  alias MsbmsSystAuthentication.Data
  alias MsbmsSystAuthentication.Impl
  alias MsbmsSystAuthentication.Types

  require Logger

  @moduledoc false

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

  @spec confirm_credential(
          Types.credential_types(),
          Types.access_account_id(),
          Types.identity_id() | nil,
          Types.credential()
        ) ::
          Types.credential_confirm_result()
  def confirm_credential(credential_type, access_account_id, identity_id, token)
      when credential_type in @token_types do
    cred = get_credential_record(credential_type, access_account_id, identity_id)

    credential_state =
      with :ok <- maybe_confirm_credential_exists(cred) do
        maybe_confirm_api_token_hash(cred, token)
      end

    {credential_state, []}
  end

  defp maybe_confirm_credential_exists(%Data.SystCredentials{}), do: :ok
  defp maybe_confirm_credential_exists(_), do: :no_credential

  defp maybe_confirm_api_token_hash(cred, token) do
    hash_verified = Impl.Hash.verify_credential_hash(cred.credential_data, token)

    if hash_verified, do: :confirmed, else: :wrong_credential
  end

  @spec set_credential(
          Types.credential_types(),
          Types.access_account_id(),
          Types.identity_id() | nil,
          Types.credential() | nil,
          Keyword.t()
        ) ::
          {:ok, Types.credential()}
          | Types.credential_set_failures()
          | {:error, MsbmsSystError.t()}
  def set_credential(credential_type, access_account_id, identity_id, token, opts)
      when credential_type in @token_types do
    identity_ownership_confirmed = identity_ownership_confirmed?(access_account_id, identity_id)

    if identity_ownership_confirmed do
      token =
        token ||
          MsbmsSystUtils.get_random_string(
            opts[:credential_token_length],
            opts[:credential_tokens]
          )

      cred = get_credential_record(credential_type, access_account_id, identity_id)
      set_credential_data(credential_type, cred, access_account_id, identity_id, token)
    else
      {:error,
       %MsbmsSystError{
         code: :undefined_error,
         message: "Identity for this Credential is owned by a different Access Account.",
         cause: %{parameters: %{access_account_id: access_account_id, identity_id: identity_id}}
       }}
    end
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MsbmsSystError{
          code: :undefined_error,
          message: "Failure setting APi Token Credential.",
          cause: error
        }
      }
  end

  defp set_credential_data(credential_type, nil = _cred, access_account_id, identity_id, token) do
    credential_type = Atom.to_string(credential_type)

    %{id: credential_type_id} =
      MsbmsSystEnums.get_enum_item_by_name("credential_types", credential_type)

    password_hash = Impl.Hash.create_credential_hash(token)

    %{
      access_account_id: access_account_id,
      credential_type_id: credential_type_id,
      credential_data: password_hash,
      credential_for_identity_id: identity_id
    }
    |> Data.SystCredentials.insert_changeset()
    |> MsbmsSystDatastore.insert!()

    {:ok, token}
  end

  defp set_credential_data(_credential_type, _cred, _access_account_id, _identity_id, _api_token) do
    {:error,
     %MsbmsSystError{
       code: :undefined_error,
       message: "Token Credential records may not be updated.",
       cause: nil
     }}
  end

  defp identity_ownership_confirmed?(access_account_id, identity_id) do
    from(i in Data.SystIdentities,
      where: i.id == ^identity_id and i.access_account_id == ^access_account_id
    )
    |> MsbmsSystDatastore.exists?()
  end

  @spec get_credential_record(
          Types.credential_types(),
          Types.access_account_id(),
          Types.identity_id() | nil
        ) ::
          Data.SystCredentials.t() | nil
  def get_credential_record(credential_type, access_account_id, identity_id) do
    credential_type = Atom.to_string(credential_type)

    from(
      c in Data.SystCredentials,
      join: ct in assoc(c, :credential_type),
      where:
        ct.internal_name == ^credential_type and
          c.access_account_id == ^access_account_id and
          c.credential_for_identity_id == ^identity_id,
      select: c
    )
    |> MsbmsSystDatastore.one()
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MsbmsSystError{
          code: :undefined_error,
          message: "Failure retrieving token Credential record.",
          cause: error
        }
      }
  end

  # Token types involve a matched pair of Identity and Credential records and as
  # such any attempt to delete one will delete the other.  This deletion is done
  # at the database level via foreign key constraints or triggers depending on
  # which of the pair are deleted.

  @spec delete_credential(
          Types.credential_types(),
          Types.credential_id() | Data.SystCredentials.t()
        ) ::
          :ok | {:error, MsbmsSystError.t()}

  def delete_credential(credential_type, credential_id)
      when credential_type in @token_types and is_binary(credential_id) do
    credential_type = Atom.to_string(credential_type)

    from(c in Data.SystCredentials,
      join: ct in assoc(c, :credential_type),
      select: c,
      where: c.id == ^credential_id and ct.internal_name == ^credential_type
    )
    |> MsbmsSystDatastore.one!()
    |> then(&delete_credential(credential_type, &1))
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MsbmsSystError{
          code: :undefined_error,
          message: "Failure deleting token Credential record by ID.",
          cause: error
        }
      }
  end

  def delete_credential(credential_type, %Data.SystCredentials{} = cred) do
    %{internal_name: target_cred_type_name} =
      MsbmsSystEnums.get_enum_item_by_id("credential_types", cred.credential_type_id)

    if target_cred_type_name == Atom.to_string(credential_type) do
      MsbmsSystDatastore.delete!(cred)
      :ok
    else
      {:error,
       %MsbmsSystError{
         code: :undefined_error,
         message: "Incorrect Credential Type for Credential record delete.",
         cause: %{
           parameters: [credential_type: credential_type, cred: cred],
           target_cred_type_name: target_cred_type_name
         }
       }}
    end
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MsbmsSystError{
          code: :undefined_error,
          message: "Failure deleting token Credential record.",
          cause: error
        }
      }
  end
end