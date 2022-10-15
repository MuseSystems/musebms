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

  # Recovery identities are sufficiently different from other kinds of
  # identities that we shouldn't implement the
  # MsbmsSystAuthentication.Impl.Identity behaviour here, though we should be
  # true to its spirit when appropriate.

  @moduledoc false

  @spec request_identity_recovery(Types.identity_id() | Data.SystIdentities.t(), Keyword.t()) ::
          Data.SystIdentities.t()
  def request_identity_recovery(target_identity_id, opts) when is_binary(target_identity_id) do
    from(i in Data.SystIdentities, where: i.id == ^target_identity_id)
    |> MsbmsSystDatastore.one!()
    |> request_identity_recovery(opts)
  end

  def request_identity_recovery(%Data.SystIdentities{} = target_identity, opts) do
    opts =
      MsbmsSystUtils.resolve_options(opts,
        expiration_hours: 24,
        identity_token_length: 40,
        identity_tokens: :mixed_alphanum
      )

    create_recovery_identity(target_identity, opts)
  end

  defp create_recovery_identity(target_identity, opts) do
    generated_account_identifier =
      MsbmsSystUtils.get_random_string(opts[:identity_token_length], opts[:identity_tokens])

    date_now = DateTime.now!("Etc/UTC")
    date_expires = DateTime.add(date_now, opts[:expiration_hours] * 60 * 60)

    recovery_identity_params = %{
      access_account_id: target_identity.access_account_id,
      identity_type_name: "identity_types_sysdef_password_recovery",
      account_identifier: generated_account_identifier,
      identity_expires: date_expires
    }

    Helpers.create_identity(recovery_identity_params, create_validated: false)
  end

  @spec identify_access_account(
          Types.account_identifier(),
          MsbmsSystInstanceMgr.Types.owner_id() | nil
        ) :: Data.SystIdentities.t() | nil
  def identify_access_account(recovery_token, owner_id) when is_binary(recovery_token) do
    recovery_token
    |> Helpers.get_identification_query(
      "identity_types_sysdef_password_recovery",
      owner_id,
      :require_validation
    )
    |> MsbmsSystDatastore.one()
  end

  @spec confirm_identity_recovery(Data.SystIdentities.t()) ::
          :ok | {:error, MsbmsSystError.t()}
  def confirm_identity_recovery(recovery_identity) do
    :ok = Helpers.delete_record(recovery_identity)
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MsbmsSystError{
          code: :undefined_error,
          message: "Failure confirming Recovery Identity.",
          cause: error
        }
      }
  end

  @spec revoke_identity_recovery(Data.SystIdentities.t()) ::
          :ok | {:error, MsbmsSystError.t()}
  def revoke_identity_recovery(recovery_identity) do
    :ok = Helpers.delete_record(recovery_identity)
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MsbmsSystError{
          code: :undefined_error,
          message: "Failure revoking Recovery Identity.",
          cause: error
        }
      }
  end
end
