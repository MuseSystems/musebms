# Source File: validation.ex
# Location:    musebms/app_server/components/system/mscmp_syst_authn/lib/impl/identity/validation.ex
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

  # Validation identities are sufficiently different from other kinds of
  # identities that we shouldn't implement the
  # MscmpSystAuthn.Impl.Identity behaviour here, though we should be
  # true to its spirit when appropriate.

  ##############################################################################
  #
  # request_identity_validation
  #
  #

  @spec request_identity_validation(Types.identity_id() | Msdata.SystIdentities.t(), Keyword.t()) ::
          {:ok, Msdata.SystIdentities.t()} | {:error, term()}
  def request_identity_validation(target_identity_id, opts) when is_binary(target_identity_id) do
    from(i in Msdata.SystIdentities, where: i.id == ^target_identity_id)
    |> MscmpSystDb.one()
    |> case do
      nil -> {:error, :not_found}
      target_identity -> request_identity_validation(target_identity, opts)
    end
  end

  def request_identity_validation(%Msdata.SystIdentities{} = target_identity, opts) do
    MscmpSystDb.transaction(fn ->
      with {:ok, reset_identity} <-
             reset_validation_target_identity(target_identity, opts),
           {:ok, validation_identity} <- create_validation_identity(reset_identity, opts) do
        validation_identity
      else
        {:error, error} -> MscmpSystDb.rollback(error)
      end
    end)
  end

  defp reset_validation_target_identity(target_identity, _opts) do
    Helpers.update_identity(target_identity, %{
      validated: nil,
      validation_requested: DateTime.now!("Etc/UTC")
    })
  end

  defp create_validation_identity(target_identity, opts) do
    generated_account_identifier =
      Msutils.String.get_random_string(opts[:identity_token_length], opts[:identity_tokens])

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

  ##############################################################################
  #
  # identify_access_account
  #
  #

  @spec identify_access_account(
          Types.account_identifier(),
          MscmpSystInstance.Types.owner_id() | nil
        ) :: {:ok, Msdata.SystIdentities.t()} | {:error, :not_found} | {:error, term()}
  def identify_access_account(validation_token, owner_id) do
    validation_token
    |> Helpers.get_identification_query("identity_types_sysdef_validation", owner_id)
    |> MscmpSystDb.one()
    |> case do
      nil -> {:error, :not_found}
      identity -> {:ok, identity}
    end
  end

  ##############################################################################
  #
  # confirm_identity_validation
  #
  #

  @spec confirm_identity_validation(Msdata.SystIdentities.t()) ::
          {:ok, Msdata.SystIdentities.t()} | {:error, term()}
  def confirm_identity_validation(validation_identity) do
    MscmpSystDb.transaction(fn ->
      date_now = DateTime.now!("Etc/UTC")

      with {:ok, subject_identity} <- get_validation_target_identity(validation_identity),
           :ok <- verify_not_expired(subject_identity),
           :ok <- verify_not_validated(subject_identity),
           {:ok, validated_identity} <-
             Helpers.update_identity(subject_identity, %{validated: date_now}),
           :ok <- Helpers.delete_identity(validation_identity) do
        validated_identity
      else
        {:error, error} -> MscmpSystDb.rollback(error)
      end
    end)
  end

  ##############################################################################
  #
  # revoke_identity_validation
  #
  #

  @spec revoke_identity_validation(Msdata.SystIdentities.t()) ::
          {:ok, Msdata.SystIdentities.t()} | {:error, term()}
  def revoke_identity_validation(validation_identity) do
    MscmpSystDb.transaction(fn ->
      with {:ok, to_revoke_identity} <-
             get_validation_target_identity(validation_identity),
           :ok <- verify_not_validated(to_revoke_identity),
           {:ok, revoked_identity} <-
             Helpers.update_identity(to_revoke_identity, %{validation_requested: nil}),
           :ok <- Helpers.delete_identity(validation_identity) do
        revoked_identity
      else
        {:error, error} -> MscmpSystDb.rollback(error)
      end
    end)
  end

  ##############################################################################
  #
  # get_validation_target_identity
  #
  #

  @spec get_validation_target_identity(Msdata.SystIdentities.t() | Types.identity_id()) ::
          {:ok, Msdata.SystIdentities.t()} | {:error, :not_found} | {:error, term()}
  def get_validation_target_identity(%Msdata.SystIdentities{} = validation_identity),
    do: get_validation_target_identity(validation_identity.id)

  def get_validation_target_identity(validation_identity_id) do
    from(
      vi in Msdata.SystIdentities,
      join: ti in assoc(vi, :validates_identity),
      where: vi.id == ^validation_identity_id,
      select: ti
    )
    |> MscmpSystDb.one()
    |> case do
      nil -> {:error, :not_found}
      identity -> {:ok, identity}
    end
  end

  ##############################################################################
  #
  # get_validator_identity
  #
  #

  @spec get_validator_identity(Msdata.SystIdentities.t() | Types.identity_id()) ::
          {:ok, Msdata.SystIdentities.t()} | {:error, :not_found} | {:error, term()}
  def get_validator_identity(%Msdata.SystIdentities{} = target_identity),
    do: get_validator_identity(target_identity.id)

  def get_validator_identity(target_identity_id) do
    from(i in Msdata.SystIdentities, where: i.validates_identity_id == ^target_identity_id)
    |> MscmpSystDb.one()
    |> case do
      nil -> {:error, :not_found}
      identity -> {:ok, identity}
    end
  end

  ##############################################################################
  #
  # General Use Private Functions
  #
  #

  defp verify_not_expired(
         %Msdata.SystIdentities{identity_expires: identity_expires} = _target_identity
       )
       when not is_nil(identity_expires) do
    case DateTime.diff(identity_expires, DateTime.now!("Etc/UTC")) < 0 do
      true -> {:error, :expired}
      false -> :ok
    end
  end

  defp verify_not_expired(_target_identity), do: :ok

  defp verify_not_validated(%Msdata.SystIdentities{validated: validated})
       when not is_nil(validated),
       do: {:error, :already_validated}

  defp verify_not_validated(_target_identity), do: :ok
end
