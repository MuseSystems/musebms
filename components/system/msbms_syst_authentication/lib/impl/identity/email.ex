# Source File: email.ex
# Location:    musebms/components/system/msbms_syst_authentication/lib/impl/identity/email.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MsbmsSystAuthentication.Impl.Identity.Email do
  import MsbmsSystUtils

  alias MsbmsSystAuthentication.Data
  alias MsbmsSystAuthentication.Impl.Identity.Helpers
  alias MsbmsSystAuthentication.Types

  require Logger

  @moduledoc false

  @spec create_identity(
          Types.access_account_id(),
          Types.account_identifier(),
          Keyword.t()
        ) :: Data.SystIdentities.t()
  def create_identity(access_account_id, email_address, opts)
      when is_binary(access_account_id) and is_binary(email_address) do
    opts = resolve_options(opts, create_validated: false)

    email_address =
      email_address
      |> verify_email_address()
      |> normalize_email_address()

    identity_params = %{
      access_account_id: access_account_id,
      identity_type_name: "identity_types_sysdef_email",
      account_identifier: email_address
    }

    Helpers.create_identity(identity_params, opts)
  end

  @spec identify_owned_access_account(
          MsbmsSystInstanceMgr.Types.owner_id(),
          Types.account_identifier()
        ) :: Data.SystAccessAccounts.t() | nil
  def identify_owned_access_account(owner_id, email_address)
      when is_binary(owner_id) and is_binary(email_address) do
    email_address
    |> verify_email_address()
    |> normalize_email_address()
    |> Helpers.get_identification_query("identity_types_sysdef_email", owner_id)
    |> MsbmsSystDatastore.one()
  end

  @spec identify_unowned_access_account(Types.account_identifier()) ::
          Data.SystAccessAccounts.t() | nil
  def identify_unowned_access_account(email_address) when is_binary(email_address) do
    email_address
    |> verify_email_address()
    |> normalize_email_address()
    |> Helpers.get_identification_query("identity_types_sysdef_email", nil)
    |> MsbmsSystDatastore.one()
  end

  @spec delete_identity(Types.identity_id() | Data.SystIdentities.t()) :: :ok
  # Right now there's no specific email identity related logic, but it's
  # conceivable there will be in future.  For example, we may want to prevent
  # deletion of the last identity or last interactive login identity.
  def delete_identity(identity), do: Helpers.delete_identity(identity)

  # This doesn't catch all RFC compliant email addresses; specifically "@" is
  # valid in the local part of the email address (when properly escaped) and
  # would cause this verification to pass even if the correct local/domain
  # separating "@" were missing.  But we should properly handle the vast
  # majority of cases as embedded "@" should be very rare (and expected to be
  # unreliable).
  defp verify_email_address(email_address) when is_binary(email_address) do
    if Regex.match?(~r/.+@.+/, email_address) do
      email_address
    else
      raise MsbmsSystError,
        message: "The value passed was not a valid email address.",
        code: :undefined_error,
        cause: %{parameters: [email_address: email_address]}
    end
  end

  defp normalize_email_address(email_address) when is_binary(email_address) do
    Regex.replace(~r/(.+)@(.+)$/, email_address, fn _, local_part, domain_part ->
      local_part <> "@" <> String.downcase(domain_part)
    end)
  end
end