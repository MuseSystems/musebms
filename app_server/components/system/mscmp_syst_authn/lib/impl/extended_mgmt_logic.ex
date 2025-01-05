# Source File: extended_mgmt_logic.ex
# Location:    musebms/components/system/mscmp_syst_authn/lib/impl/extended_mgmt_logic.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystAuthn.Impl.ExtendedMgmtLogic do
  @moduledoc false

  import Msutils.Guards

  alias MscmpSystAuthn.Impl
  alias MscmpSystAuthn.Types
  alias MscmpSystAuthn.Types.AuthenticatorResult

  require Logger

  # ============================================================================
  #
  # Email / Password Management
  #
  # ============================================================================

  ##############################################################################
  #
  # create_authenticator_email_password
  #
  #

  @spec create_authenticator_email_password(
          Types.access_account_id(),
          Types.account_identifier(),
          Types.credential(),
          Keyword.t()
        ) ::
          {:ok, AuthenticatorResult.t()}
          | {:error, Types.credential_set_failures()}
          | {:error, term()}
  def create_authenticator_email_password(access_account_id, email_addr, plaintext_pwd, opts) do
    authenticator_func = fn ->
      with {:ok, email_identity} <-
             Impl.Identity.Email.create_identity(access_account_id, email_addr, opts),
           {:ok, _} <-
             Impl.Credential.Password.set_credential(access_account_id, plaintext_pwd, []),
           {:ok, validator_result} <-
             maybe_create_email_validator(opts[:create_validated], email_identity, opts) do
        %AuthenticatorResult{
          validation_identifier: validator_result[:validation_identifier],
          validation_credential: validator_result[:validation_credential],
          access_account_id: access_account_id,
          account_identifier: email_identity.account_identifier
        }
      else
        {:error, {:invalid_credential, _} = cred_violations} ->
          MscmpSystDb.rollback(cred_violations)

        {:error, error} ->
          MscmpSystDb.rollback(error)
      end
    end

    MscmpSystDb.transaction(authenticator_func)
    |> case do
      {:ok, authenticator_result} ->
        {:ok, authenticator_result}

      {:error, %Mserror.DbError{cause: {:invalid_credential, _} = cred_violations}} ->
        {:error, cred_violations}

      {:error, error} ->
        {:error, error}
    end
  end

  defp maybe_create_email_validator(true = _create_validated, _email_identity, _opts),
    do: {:ok, %{}}

  defp maybe_create_email_validator(false = _create_validated, email_identity, opts),
    do: create_validator(email_identity, opts)

  @spec reset_password_credential(Types.access_account_id(), Types.credential()) ::
          {:ok, Types.credential()} | {:error, Types.credential_set_failures()} | {:error, term()}
  def reset_password_credential(access_account_id, new_credential)
      when is_binary(new_credential),
      do: Impl.Credential.Password.set_credential(access_account_id, nil, new_credential, [])

  # ============================================================================
  #
  # Validation Token Management
  #
  # ============================================================================

  ##############################################################################
  #
  # request_identity_validation
  #
  #

  @spec request_identity_validation(Types.identity_id() | Msdata.SystIdentities.t(), Keyword.t()) ::
          {:ok, AuthenticatorResult.t()} | {:error, term()}
  def request_identity_validation(target_identity_id, opts) when is_uuid(target_identity_id) do
    with {:ok, target_identity} <- Impl.Identity.get_identity_record(target_identity_id) do
      request_identity_validation(target_identity, opts)
    end
  end

  def request_identity_validation(%Msdata.SystIdentities{} = target_identity, opts) do
    with {:ok, validator} <- create_validator(target_identity, opts) do
      {:ok,
       %AuthenticatorResult{
         access_account_id: target_identity.access_account_id,
         validation_identifier: validator[:validation_identifier],
         validation_credential: validator[:validation_credential]
       }}
    end
  end

  defp create_validator(identity, opts) do
    validator_func = fn ->
      with {:ok, validation_identity} <-
             Impl.Identity.Validation.request_identity_validation(identity, opts),
           {:ok, validation_credential} <-
             Impl.Credential.Validation.set_credential(
               validation_identity.access_account_id,
               validation_identity.id,
               opts[:credential_token],
               opts
             ) do
        %{
          validation_identifier: validation_identity.account_identifier,
          validation_credential: validation_credential
        }
      else
        error -> MscmpSystDb.rollback(error)
      end
    end

    MscmpSystDb.transaction(validator_func)
  end

  # There's a good argument that revoke_validator_for_identity_id/1 belongs in
  # `Impl.Identity.Validation` since we're not combining cross-module
  # functionality.  The sole rationale for placing it here is based on our
  # starting with an Identity ID for a different kind of Identity.  To a lesser
  # degree we're also combining more primitive functions from the private API
  # defined in `Impl.Identity.Validation` into a more appropriate public API
  # composite function.

  ##############################################################################
  #
  # revoke_validator_for_identity_id
  #
  #

  @spec revoke_validator_for_identity_id(Types.identity_id()) ::
          :ok | {:error, :not_found} | {:error, term()}
  def revoke_validator_for_identity_id(target_identity_id) do
    with {:ok, validation_identity} <-
           Impl.Identity.Validation.get_validator_identity(target_identity_id),
         {:ok, _revoked_validation_identity} <-
           Impl.Identity.Validation.revoke_identity_validation(validation_identity) do
      :ok
    end
  end

  # ============================================================================
  #
  # Recovery Token Management
  #
  # ============================================================================

  ##############################################################################
  #
  # request_password_recovery
  #
  #

  @spec request_password_recovery(Types.access_account_id(), Keyword.t()) ::
          {:ok, AuthenticatorResult.t()} | {:error, term()}
  def request_password_recovery(access_account_id, opts) do
    recovery_func = fn ->
      with {:ok, recovery_identity} <-
             Impl.Identity.Recovery.request_credential_recovery(access_account_id, opts),
           {:ok, recovery_credential} <-
             Impl.Credential.Recovery.set_credential(
               recovery_identity.access_account_id,
               recovery_identity.id,
               opts[:credential_token],
               opts
             ) do
        %AuthenticatorResult{
          access_account_id: recovery_identity.access_account_id,
          account_identifier: recovery_identity.account_identifier,
          credential: recovery_credential
        }
      else
        {:error, error} ->
          MscmpSystDb.rollback(error)
      end
    end

    MscmpSystDb.transaction(recovery_func)
    |> case do
      {:ok, result} -> {:ok, result}
      {:error, %Mserror.DbError{cause: :existing_recovery}} -> {:error, :existing_recovery}
      {:error, error} -> {:error, error}
    end
  end

  ##############################################################################
  #
  # revoke_password_recovery
  #
  #

  @spec revoke_password_recovery(Types.access_account_id()) ::
          :ok | {:error, :not_found} | {:error, term()}
  def revoke_password_recovery(access_account_id) do
    with {:ok, recovery_identity} <-
           Impl.Identity.Recovery.get_recovery_identity_for_access_account_id(access_account_id) do
      Impl.Identity.Recovery.revoke_credential_recovery(recovery_identity)
    end
  end

  # ============================================================================
  #
  # API Token Management
  #
  # ============================================================================

  ##############################################################################
  #
  # create_authenticator_api_token
  #
  #

  @spec create_authenticator_api_token(Types.access_account_id(), Keyword.t()) ::
          {:ok, AuthenticatorResult.t()} | {:error, term()}
  def create_authenticator_api_token(access_account_id, opts) do
    authenticator_func = fn ->
      with {:ok, identity} <-
             Impl.Identity.ApiToken.create_identity(
               access_account_id,
               opts[:identity_token],
               opts
             ),
           {:ok, credential} <-
             Impl.Credential.ApiToken.set_credential(
               access_account_id,
               identity.id,
               opts[:credential_token],
               opts
             ) do
        %AuthenticatorResult{
          access_account_id: access_account_id,
          account_identifier: identity.account_identifier,
          credential: credential
        }
      else
        error ->
          MscmpSystDb.rollback(error)
      end
    end

    MscmpSystDb.transaction(authenticator_func)
  end

  ##############################################################################
  #
  # update_api_token_external_name
  #
  #

  @spec update_api_token_external_name(
          Types.identity_id() | Msdata.SystIdentities.t(),
          String.t() | nil
        ) :: {:ok, Msdata.SystIdentities.t()} | {:error, :not_found} | {:error, term()}
  def update_api_token_external_name(identity, external_name),
    do: Impl.Identity.ApiToken.update_identity_external_name(identity, external_name)

  ##############################################################################
  #
  # revoke_api_token
  #
  #

  @spec revoke_api_token(Types.identity_id() | Msdata.SystIdentities.t()) ::
          :ok | {:error, :not_found} | {:error, term()}
  def revoke_api_token(identity),
    do: Impl.Identity.delete_identity(identity, "identity_types_sysdef_api")

  # ============================================================================
  #
  # Account Code Management
  #
  # ============================================================================

  ##############################################################################
  #
  # create_or_reset_account_code
  #
  #

  @spec create_or_reset_account_code(Types.access_account_id(), Keyword.t()) ::
          {:ok, AuthenticatorResult.t()} | {:error, term()}
  def create_or_reset_account_code(access_account_id, opts) do
    with {:ok, identity} <-
           Impl.Identity.AccountCode.reset_identity_for_access_account_id(access_account_id, opts) do
      {:ok,
       %AuthenticatorResult{
         access_account_id: identity.access_account_id,
         account_identifier: identity.account_identifier
       }}
    end
  end

  ##############################################################################
  #
  # revoke_account_code
  #
  #

  @spec revoke_account_code(Types.access_account_id()) ::
          :ok | {:error, :not_found} | {:error, term()}
  def revoke_account_code(access_account_id) when is_binary(access_account_id) do
    with {:ok, identity} <-
           Impl.Identity.AccountCode.get_account_code_by_access_account_id(access_account_id) do
      Impl.Identity.delete_identity(identity, "identity_types_sysdef_account")
    end
  end
end
