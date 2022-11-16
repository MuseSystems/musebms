# Source File: recovery.ex
# Location:    musebms/components/system/msbms_syst_authentication/lib/impl/identity/recovery.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MsbmsSystAuthentication.Impl.Identity.Recovery do
  import Ecto.Query

  alias MsbmsSystAuthentication.Data
  alias MsbmsSystAuthentication.Impl.Identity.Helpers
  alias MsbmsSystAuthentication.Types

  require Logger

  # The Recovery process currently only supports Password Credential recovery
  # and there are number of places in this module and related modules where this
  # assumption is coded directly.  While it is conceivable that we would want
  # other recoverable credential types, we simply aren't supporting it yet.
  #
  # Recovery identities are sufficiently different from other kinds of
  # identities that we shouldn't implement the
  # MsbmsSystAuthentication.Impl.Identity behaviour here, though we should be
  # true to its spirit when appropriate.

  @moduledoc false

  @default_expiration_hours 24
  @default_identity_token_length 40
  @default_identity_tokens :mixed_alphanum
  @default_create_validated true

  @spec request_credential_recovery(Types.access_account_id(), Keyword.t()) ::
          {:ok, Data.SystIdentities.t()} | {:error, MscmpSystError.t() | Exception.t()}
  def request_credential_recovery(access_account_id, opts) when is_binary(access_account_id) do
    opts =
      MscmpSystUtils.resolve_options(opts,
        expiration_hours: @default_expiration_hours,
        identity_token_length: @default_identity_token_length,
        identity_tokens: @default_identity_tokens,
        create_validated: @default_create_validated
      )

    access_account_id
    |> access_account_credential_recoverable!()
    |> maybe_create_recovery_identity(access_account_id, opts)
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MscmpSystError{
          code: :undefined_error,
          message: "Failure creating Recovery Identity.",
          cause: error
        }
      }
  end

  defp maybe_create_recovery_identity(:ok, access_account_id, opts),
    do: {:ok, create_recovery_identity(access_account_id, opts)}

  defp maybe_create_recovery_identity(:not_found, _, _) do
    {
      :error,
      %MscmpSystError{
        code: :undefined_error,
        message: "Password Credential unrecoverable because it doesn't exist.",
        cause: :not_found
      }
    }
  end

  defp maybe_create_recovery_identity(:existing_recovery, _, _) do
    {
      :error,
      %MscmpSystError{
        code: :undefined_error,
        message: "Password Credential is already being recovered.",
        cause: :existing_recovery
      }
    }
  end

  defp create_recovery_identity(access_account_id, opts) do
    generated_account_identifier =
      MscmpSystUtils.get_random_string(opts[:identity_token_length], opts[:identity_tokens])

    date_now = DateTime.now!("Etc/UTC")
    date_expires = DateTime.add(date_now, opts[:expiration_hours] * 60 * 60)

    recovery_identity_params = %{
      access_account_id: access_account_id,
      identity_type_name: "identity_types_sysdef_password_recovery",
      account_identifier: generated_account_identifier,
      identity_expires: date_expires
    }

    Helpers.create_identity(recovery_identity_params, opts)
  end

  @spec access_account_credential_recoverable!(Types.access_account_id()) ::
          :ok | :not_found | :existing_recovery
  def access_account_credential_recoverable!(access_account_id)
      when is_binary(access_account_id) do
    identity_qry =
      from(i in Data.SystIdentities,
        join: ei in assoc(i, :identity_type),
        where:
          i.access_account_id == ^access_account_id and
            ei.internal_name == "identity_types_sysdef_password_recovery",
        select: %{identity_id: i.id, identity_access_account_id: i.access_account_id}
      )

    credential_qry =
      from(c in Data.SystCredentials,
        join: ei in assoc(c, :credential_type),
        where:
          c.access_account_id == ^access_account_id and
            ei.internal_name == "credential_types_sysdef_password",
        select: %{credential_id: c.id, credential_access_account_id: c.access_account_id}
      )

    from(aa in Data.SystAccessAccounts,
      left_join: i in subquery(identity_qry),
      on: i.identity_access_account_id == aa.id,
      left_join: c in subquery(credential_qry),
      on: c.credential_access_account_id == aa.id,
      where: aa.id == ^access_account_id,
      select: %{
        password_credential_exists: not is_nil(c.credential_access_account_id),
        recovery_underway: not is_nil(i.identity_access_account_id)
      }
    )
    |> MsbmsSystDatastore.one!()
    |> case do
      %{recovery_underway: true} -> :existing_recovery
      %{password_credential_exists: false} -> :not_found
      _ -> :ok
    end
  end

  @spec identify_access_account(
          Types.account_identifier(),
          MsbmsSystInstanceMgr.Types.owner_id() | nil
        ) :: Data.SystIdentities.t() | nil
  def identify_access_account(recovery_token, owner_id) when is_binary(recovery_token) do
    recovery_token
    |> Helpers.get_identification_query("identity_types_sysdef_password_recovery", owner_id)
    |> MsbmsSystDatastore.one()
  end

  @spec confirm_credential_recovery(Data.SystIdentities.t()) ::
          :ok | {:error, MscmpSystError.t()}
  def confirm_credential_recovery(recovery_identity) do
    :ok = Helpers.delete_record(recovery_identity)
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MscmpSystError{
          code: :undefined_error,
          message: "Failure confirming Recovery Identity.",
          cause: error
        }
      }
  end

  @spec revoke_credential_recovery(Data.SystIdentities.t()) ::
          :ok | {:error, MscmpSystError.t()}
  def revoke_credential_recovery(recovery_identity) do
    :ok = Helpers.delete_record(recovery_identity)
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MscmpSystError{
          code: :undefined_error,
          message: "Failure revoking Recovery Identity.",
          cause: error
        }
      }
  end

  @spec get_recovery_identity_for_access_account_id(Types.access_account_id()) ::
          {:ok, Data.SystIdentities.t() | nil} | {:error, MscmpSystError.t()}
  def get_recovery_identity_for_access_account_id(access_account_id) do
    from(i in Data.SystIdentities,
      join: ei in assoc(i, :identity_type),
      where:
        i.access_account_id == ^access_account_id and
          ei.internal_name == "identity_types_sysdef_password_recovery"
    )
    |> MsbmsSystDatastore.one()
    |> then(&{:ok, &1})
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MscmpSystError{
          code: :undefined_error,
          message: "Failure retrieving Recovery Identity by Access Account ID.",
          cause: error
        }
      }
  end
end
