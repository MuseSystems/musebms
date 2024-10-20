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

  alias MscmpSystAuthn.Impl
  alias MscmpSystAuthn.Types
  alias MscmpSystAuthn.Types.AuthenticatorResult

  require Logger

  # ============================================================================
  #
  # Email / Password Management
  #
  # ============================================================================

  @spec create_authenticator_email_password(
          Types.access_account_id(),
          Types.account_identifier(),
          Types.credential(),
          Keyword.t()
        ) ::
          {:ok, AuthenticatorResult.t()}
          | {:error, MscmpSystError.t() | Exception.t()}
  def create_authenticator_email_password(access_account_id, email_addr, plaintext_pwd, opts) do
    opts = MscmpSystUtils.resolve_options(opts, create_validated: false, credential_token: nil)

    authenticator_func = fn ->
      with {:ok, email_identity} <-
             Impl.Identity.Email.create_identity(access_account_id, email_addr, opts),
           :ok <-
             Impl.Credential.Password.set_credential(access_account_id, plaintext_pwd, opts),
           {:ok, validator_result} <-
             maybe_create_email_validator(opts[:create_validated], email_identity, opts) do
        %AuthenticatorResult{
          validation_identifier: validator_result[:validation_identifier],
          validation_credential: validator_result[:validation_credential],
          access_account_id: access_account_id,
          account_identifier: email_identity.account_identifier
        }
      else
        {:invalid_credential, _} = cred_violations ->
          MscmpSystDb.rollback(cred_violations)

        error ->
          MscmpSystDb.rollback(%MscmpSystError{
            code: :undefined_error,
            message: "Failed creating Email/Password Authenticator.",
            cause: error
          })
      end
    end

    MscmpSystDb.transaction(authenticator_func)
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {:error,
       %MscmpSystError{
         code: :undefined_error,
         message: "Exception while creating Email/Password Authenticator.",
         cause: error
       }}
  end

  defp maybe_create_email_validator(true = _create_validated, _email_identity, _opts),
    do: {:ok, %{}}

  defp maybe_create_email_validator(false = _create_validated, email_identity, opts),
    do: create_validator(email_identity, opts)

  @spec reset_password_credential(Types.access_account_id(), Types.credential()) ::
          :ok | Types.credential_set_failures() | {:error, MscmpSystError.t()}
  def reset_password_credential(access_account_id, new_credential)
      when is_binary(new_credential),
      do: Impl.Credential.Password.set_credential(access_account_id, nil, new_credential, [])

  # ============================================================================
  #
  # Validation Token Management
  #
  # ============================================================================

  @spec request_identity_validation(Types.identity_id() | Msdata.SystIdentities.t(), Keyword.t()) ::
          {:ok, AuthenticatorResult.t()} | {:error, MscmpSystError.t() | Exception.t()}
  def request_identity_validation(target_identity_id, opts) when is_binary(target_identity_id) do
    target_identity_id
    |> Impl.Identity.get_identity_record()
    |> request_identity_validation(opts)
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {:error,
       %MscmpSystError{
         code: :undefined_error,
         message: "Failure requesting Identity validation by Identity ID.",
         cause: error
       }}
  end

  def request_identity_validation(%Msdata.SystIdentities{} = target_identity, opts) do
    case create_validator(target_identity, opts) do
      {:ok, validator} ->
        {:ok,
         %AuthenticatorResult{
           access_account_id: target_identity.access_account_id,
           validation_identifier: validator[:validation_identifier],
           validation_credential: validator[:validation_credential]
         }}

      error ->
        raise MscmpSystError,
          code: :undefined_error,
          message: "Failure requesting Identity Validation.",
          cause: error
    end
  rescue
    error in [MscmpSystError] ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))
      {:error, error}

    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {:error,
       %MscmpSystError{
         code: :undefined_error,
         message: "Error creating Validation Authenticator",
         cause: error
       }}
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
        {:error, %MscmpSystError{cause: cause}} ->
          MscmpSystDb.rollback(cause)
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

  @spec revoke_validator_for_identity_id(Types.identity_id()) ::
          {:ok, :deleted | :not_found} | {:error, MscmpSystError.t() | Exception.t()}
  def revoke_validator_for_identity_id(target_identity_id) do
    with {:ok, %Msdata.SystIdentities{} = validation_identity} <-
           Impl.Identity.Validation.get_validation_identity_for_identity_id(target_identity_id),
         {:ok, %Msdata.SystIdentities{}} <-
           Impl.Identity.Validation.revoke_identity_validation(validation_identity) do
      {:ok, :deleted}
    else
      {:ok, nil} ->
        {:ok, :not_found}

      error ->
        {:error,
         %MscmpSystError{
           code: :undefined_error,
           message: "Failed processing Identity validation revocation.",
           cause: error
         }}
    end
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {:error,
       %MscmpSystError{
         code: :undefined_error,
         message: "Failure revoking Identity validation.",
         cause: error
       }}
  end

  # ============================================================================
  #
  # Recovery Token Management
  #
  # ============================================================================

  @spec request_password_recovery(Types.access_account_id(), Keyword.t()) ::
          {:ok, AuthenticatorResult.t()} | {:error, MscmpSystError.t() | Exception.t()}
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
        {:error, %MscmpSystError{cause: cause}} ->
          MscmpSystDb.rollback(cause)
      end
    end

    MscmpSystDb.transaction(recovery_func)
  rescue
    error in [MscmpSystError] ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))
      {:error, error}

    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {:error,
       %MscmpSystError{
         code: :undefined_error,
         message: "Error creating Recovery Authenticator",
         cause: error
       }}
  end

  @spec revoke_password_recovery(Types.access_account_id()) ::
          {:ok, :deleted | :not_found} | {:error, MscmpSystError.t() | Exception.t()}
  def revoke_password_recovery(access_account_id) when is_binary(access_account_id) do
    with {:ok, %Msdata.SystIdentities{} = recovery_identity} <-
           Impl.Identity.Recovery.get_recovery_identity_for_access_account_id(access_account_id),
         :ok <- Impl.Identity.Recovery.revoke_credential_recovery(recovery_identity) do
      {:ok, :deleted}
    else
      {:ok, nil} ->
        {:ok, :not_found}

      error ->
        {:error,
         %MscmpSystError{
           code: :undefined_error,
           message: "Failed processing Identity recovery revocation.",
           cause: error
         }}
    end
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {:error,
       %MscmpSystError{
         code: :undefined_error,
         message: "Failure revoking Identity recovery.",
         cause: error
       }}
  end

  # ============================================================================
  #
  # API Token Management
  #
  # ============================================================================

  @spec create_authenticator_api_token(Types.access_account_id(), Keyword.t()) ::
          {:ok, AuthenticatorResult.t()} | {:error, MscmpSystError.t() | Exception.t()}
  def create_authenticator_api_token(access_account_id, opts) do
    opts = MscmpSystUtils.resolve_options(opts, identity_token: nil, credential_token: nil)

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
          MscmpSystDb.rollback(%MscmpSystError{
            code: :undefined_error,
            message: "Failed creating API Token Authenticator.",
            cause: error
          })
      end
    end

    MscmpSystDb.transaction(authenticator_func)
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {:error,
       %MscmpSystError{
         code: :undefined_error,
         message: "Exception while creating Email/Password Authenticator.",
         cause: error
       }}
  end

  @spec update_api_token_external_name(
          Types.identity_id() | Msdata.SystIdentities.t(),
          String.t() | nil
        ) ::
          {:ok, Msdata.SystIdentities.t()} | {:error, MscmpSystError.t()}
  def update_api_token_external_name(identity, external_name) do
    {:ok, Impl.Identity.ApiToken.update_identity_external_name(identity, external_name)}
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {:error,
       %MscmpSystError{
         code: :undefined_error,
         message: "Failure setting API Token External Name.",
         cause: error
       }}
  end

  @spec revoke_api_token(Types.identity_id() | Msdata.SystIdentities.t()) ::
          {:ok, :deleted | :not_found} | {:error, MscmpSystError.t()}
  def revoke_api_token(identity) do
    identity
    |> Impl.Identity.delete_identity("identity_types_sysdef_api")
    |> then(&{:ok, &1})
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {:error,
       %MscmpSystError{
         code: :undefined_error,
         message: "Failure revoking API Token Identity.",
         cause: error
       }}
  end

  # ============================================================================
  #
  # Account Code Management
  #
  # ============================================================================

  @spec create_or_reset_account_code(Types.access_account_id(), Keyword.t()) ::
          {:ok, AuthenticatorResult.t()} | {:error, MscmpSystError.t() | Exception.t()}
  def create_or_reset_account_code(access_account_id, opts) do
    access_account_id
    |> Impl.Identity.AccountCode.reset_identity_for_access_account_id(opts)
    |> process_account_code_create_result()
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {:error,
       %MscmpSystError{
         code: :undefined_error,
         message: "Failure creating Account Code Authenticator.",
         cause: error
       }}
  end

  defp process_account_code_create_result({:ok, %Msdata.SystIdentities{} = identity}) do
    {:ok,
     %AuthenticatorResult{
       access_account_id: identity.access_account_id,
       account_identifier: identity.account_identifier
     }}
  end

  defp process_account_code_create_result(error) do
    {:error,
     %MscmpSystError{
       code: :undefined_error,
       message: "Unexpected result processing Account Code creation.",
       cause: error
     }}
  end

  @spec revoke_account_code(Types.access_account_id()) ::
          {:ok, :deleted | :not_found} | {:error, MscmpSystError.t()}
  def revoke_account_code(access_account_id) when is_binary(access_account_id) do
    with {:ok, %Msdata.SystIdentities{} = identity} <-
           Impl.Identity.AccountCode.get_account_code_by_access_account_id(access_account_id) do
      {:ok, Impl.Identity.delete_identity(identity, "identity_types_sysdef_account")}
    end
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {:error,
       %MscmpSystError{
         code: :undefined_error,
         message: "Failure revoking Account Code Authenticator.",
         cause: error
       }}
  end
end
