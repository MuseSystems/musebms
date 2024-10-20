# Source File: email.ex
# Location:    musebms/components/system/mscmp_syst_authn/lib/impl/identity/email.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystAuthn.Impl.Identity.Email do
  @moduledoc false

  @behaviour MscmpSystAuthn.Impl.Identity

  alias MscmpSystAuthn.Impl.Identity.Helpers
  alias MscmpSystAuthn.Types

  require Logger

  @default_create_validated false

  @spec create_identity(Types.access_account_id(), Types.account_identifier(), Keyword.t()) ::
          {:ok, Msdata.SystIdentities.t()} | {:error, MscmpSystError.t() | Exception.t()}
  def create_identity(access_account_id, email_address, opts \\ [])
      when is_binary(access_account_id) and is_binary(email_address) do
    opts = MscmpSystUtils.resolve_options(opts, create_validated: @default_create_validated)

    case verify_email_address(email_address) do
      {:ok, valid_email} ->
        normalized_email = normalize_email_address(valid_email)

        identity_params = %{
          access_account_id: access_account_id,
          identity_type_name: "identity_types_sysdef_email",
          account_identifier: normalized_email
        }

        created_identity = Helpers.create_identity(identity_params, opts)

        {:ok, created_identity}

      {:error, _} = error ->
        {:error,
         %MscmpSystError{
           code: :undefined_error,
           message: "Failure creating Email Identity.",
           cause: error
         }}
    end
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {:error,
       %MscmpSystError{
         code: :undefined_error,
         message: "Failure creating Email Identity.",
         cause: error
       }}
  end

  @spec identify_access_account(
          Types.account_identifier(),
          MscmpSystInstance.Types.owner_id() | nil
        ) :: Msdata.SystIdentities.t() | nil
  def identify_access_account(email_address, owner_id) when is_binary(email_address) do
    case verify_email_address(email_address) do
      {:ok, valid_email} ->
        valid_email
        |> normalize_email_address()
        |> Helpers.get_identification_query("identity_types_sysdef_email", owner_id)
        |> MscmpSystDb.one()

      _ ->
        nil
    end
  end

  # This doesn't catch all RFC compliant email addresses; specifically "@" is
  # valid in the local part of the email address (when properly escaped) and
  # would cause this verification to pass even if the correct local/domain
  # separating "@" were missing.  But we should properly handle the vast
  # majority of cases as embedded "@" should be very rare (and expected to be
  # unreliable).
  @spec verify_email_address(Types.account_identifier()) ::
          {:ok, Types.account_identifier()} | {:error, MscmpSystError.t()}
  def verify_email_address(email_address) when is_binary(email_address) do
    if Regex.match?(~r/.+@.+/, email_address) do
      {:ok, email_address}
    else
      {:error,
       %MscmpSystError{
         message: "The value passed was not a valid email address.",
         code: :undefined_error,
         cause: %{parameters: [email_address: email_address]}
       }}
    end
  end

  @spec normalize_email_address(Types.account_identifier()) :: Types.account_identifier()
  def normalize_email_address(email_address) when is_binary(email_address) do
    Regex.replace(~r/(.+)@(.+)$/, email_address, fn _, local_part, domain_part ->
      local_part <> "@" <> String.downcase(domain_part)
    end)
  end
end
