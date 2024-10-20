# Source File: validation.ex
# Location:    musebms/components/system/mscmp_syst_authn/lib/impl/identity/validation.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystAuthn.Impl.Identity.Validation do
  @moduledoc false

  import Ecto.Query

  alias MscmpSystAuthn.Impl.Identity.Helpers
  alias MscmpSystAuthn.Types

  require Logger

  @default_expiration_hours 24
  @default_identity_token_length 40
  @default_identity_tokens :mixed_alphanum
  @default_create_validated true

  # Validation identities are sufficiently different from other kinds of
  # identities that we shouldn't implement the
  # MscmpSystAuthn.Impl.Identity behaviour here, though we should be
  # true to its spirit when appropriate.

  @spec request_identity_validation(Types.identity_id() | Msdata.SystIdentities.t(), Keyword.t()) ::
          {:ok, Msdata.SystIdentities.t()} | {:error, MscmpSystError.t() | Exception.t()}
  def request_identity_validation(target_identity_id, opts) when is_binary(target_identity_id) do
    from(i in Msdata.SystIdentities, where: i.id == ^target_identity_id)
    |> MscmpSystDb.one!()
    |> request_identity_validation(opts)
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MscmpSystError{
          code: :undefined_error,
          message: "Failure creating Validation Identity by ID.",
          cause: error
        }
      }
  end

  def request_identity_validation(%Msdata.SystIdentities{} = target_identity, opts) do
    opts =
      MscmpSystUtils.resolve_options(opts,
        expiration_hours: @default_expiration_hours,
        identity_token_length: @default_identity_token_length,
        identity_tokens: @default_identity_tokens,
        create_validated: @default_create_validated
      )

    MscmpSystDb.transaction(fn ->
      target_identity
      |> reset_validation_target_identity(opts)
      |> create_validation_identity(opts)
    end)
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MscmpSystError{
          code: :undefined_error,
          message: "Failure creating Validation Identity.",
          cause: error
        }
      }
  end

  defp reset_validation_target_identity(target_identity, _opts) do
    date_now = DateTime.now!("Etc/UTC")

    reset_target_identity =
      Helpers.update_record(target_identity, %{
        validated: nil,
        validation_requested: date_now
      })

    reset_target_identity
  end

  defp create_validation_identity(target_identity, opts) do
    generated_account_identifier =
      MscmpSystUtils.get_random_string(opts[:identity_token_length], opts[:identity_tokens])

    date_now = DateTime.now!("Etc/UTC")
    date_expires = DateTime.add(date_now, opts[:expiration_hours] * 60 * 60)

    validation_identity_params = %{
      access_account_id: target_identity.access_account_id,
      identity_type_name: "identity_types_sysdef_validation",
      account_identifier: generated_account_identifier,
      validates_identity_id: target_identity.id,
      identity_expires: date_expires
    }

    Helpers.create_identity(validation_identity_params, opts)
  end

  @spec identify_access_account(
          Types.account_identifier(),
          MscmpSystInstance.Types.owner_id() | nil
        ) :: Msdata.SystIdentities.t() | nil
  def identify_access_account(validation_token, owner_id) when is_binary(validation_token) do
    validation_token
    |> Helpers.get_identification_query("identity_types_sysdef_validation", owner_id)
    |> MscmpSystDb.one()
  end

  @spec confirm_identity_validation(Msdata.SystIdentities.t()) ::
          {:ok, Msdata.SystIdentities.t()} | {:error, MscmpSystError.t()}
  def confirm_identity_validation(validation_identity) do
    MscmpSystDb.transaction(fn ->
      date_now = DateTime.now!("Etc/UTC")

      validated_identity =
        from(i in Msdata.SystIdentities,
          where: i.id == ^validation_identity.validates_identity_id
        )
        |> MscmpSystDb.one!()
        |> verify_not_expired()
        |> verify_not_validated()
        |> Helpers.update_record(%{validated: date_now})

      :ok = Helpers.delete_record(validation_identity)

      validated_identity
    end)
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MscmpSystError{
          code: :undefined_error,
          message: "Failure confirming Identity validation.",
          cause: error
        }
      }
  end

  @spec revoke_identity_validation(Msdata.SystIdentities.t()) ::
          {:ok, Msdata.SystIdentities.t()} | {:error, MscmpSystError.t()}
  def revoke_identity_validation(validation_identity) do
    MscmpSystDb.transaction(fn ->
      revoked_identity =
        from(i in Msdata.SystIdentities,
          where: i.id == ^validation_identity.validates_identity_id
        )
        |> MscmpSystDb.one!()
        |> verify_not_validated()
        |> Helpers.update_record(%{validation_requested: nil})

      :ok = Helpers.delete_record(validation_identity)

      revoked_identity
    end)
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MscmpSystError{
          code: :undefined_error,
          message: "Failure revoking Identity validation.",
          cause: error
        }
      }
  end

  defp verify_not_expired(
         %Msdata.SystIdentities{identity_expires: identity_expires} = target_identity
       )
       when not is_nil(identity_expires) do
    case DateTime.diff(identity_expires, DateTime.now!("Etc/UTC")) < 0 do
      true ->
        raise MscmpSystError,
          message: """
          The requested action may not be taken on a validation Identity
          record which has expired."
          """,
          code: :undefined_error,
          cause: %{parameters: [identity: target_identity]}

      false ->
        target_identity
    end
  end

  defp verify_not_expired(target_identity), do: target_identity

  defp verify_not_validated(%Msdata.SystIdentities{validated: validated} = target_identity)
       when not is_nil(validated) do
    # Getting here really shouldn't be possible, but just in case...

    raise MscmpSystError,
      message: "Operation not valid for an already Validated Identity.",
      code: :undefined_error,
      cause: %{parameters: [identity: target_identity]}
  end

  defp verify_not_validated(target_identity), do: target_identity

  @spec get_validation_identity_for_identity_id(Types.identity_id()) ::
          {:ok, Msdata.SystIdentities.t() | nil} | {:error, MscmpSystError.t()}
  def get_validation_identity_for_identity_id(target_identity_id) do
    from(i in Msdata.SystIdentities, where: i.validates_identity_id == ^target_identity_id)
    |> MscmpSystDb.one()
    |> then(&{:ok, &1})
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MscmpSystError{
          code: :undefined_error,
          message: "Failure retrieving Validation Identity by Target Identity ID.",
          cause: error
        }
      }
  end
end
