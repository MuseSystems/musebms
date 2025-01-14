# Source File: recovery.ex
# Location:    musebms/components/system/mscmp_syst_authn/lib/impl/identity/recovery.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystAuthn.Impl.Identity.Recovery do
  @moduledoc false

  import Ecto.Query

  alias MscmpSystAuthn.Impl.Identity.Helpers
  alias MscmpSystAuthn.Types

  # The Recovery process currently only supports Password Credential recovery
  # and there are number of places in this module and related modules where this
  # assumption is coded directly.  While it is conceivable that we would want
  # other recoverable credential types, we simply aren't supporting it yet.
  #
  # Recovery identities are sufficiently different from other kinds of
  # identities that we shouldn't implement the
  # MscmpSystAuthn.Impl.Identity behaviour here, though we should be
  # true to its spirit when appropriate.

  ##############################################################################
  #
  # request_credential_recovery
  #
  #

  @spec request_credential_recovery(Types.access_account_id(), Keyword.t()) ::
          {:ok, Msdata.SystIdentities.t()} | {:error, term()}
  def request_credential_recovery(access_account_id, opts) do
    with :ok <- test_recoverability(access_account_id) do
      generated_account_identifier =
        Msutils.String.get_random_string(opts[:identity_token_length], opts[:identity_tokens])

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
  end

  defp test_recoverability(access_account_id) do
    case access_account_credential_recoverable(access_account_id) do
      {:ok, :recoverable} -> :ok
      {:ok, :existing_recovery} -> {:error, :existing_recovery}
      {:error, :not_found} -> {:error, :not_found}
    end
  end

  ##############################################################################
  #
  # access_account_credential_recoverable
  #
  #

  @spec access_account_credential_recoverable(Types.access_account_id()) ::
          {:ok, :recoverable} | {:ok, :existing_recovery} | {:error, :not_found}
  def access_account_credential_recoverable(access_account_id) do
    identity_qry =
      from(i in Msdata.SystIdentities,
        join: ei in assoc(i, :identity_type),
        where:
          i.access_account_id == ^access_account_id and
            ei.internal_name == "identity_types_sysdef_password_recovery",
        select: %{identity_id: i.id, identity_access_account_id: i.access_account_id}
      )

    credential_qry =
      from(c in Msdata.SystCredentials,
        join: ei in assoc(c, :credential_type),
        where:
          c.access_account_id == ^access_account_id and
            ei.internal_name == "credential_types_sysdef_password",
        select: %{credential_id: c.id, credential_access_account_id: c.access_account_id}
      )

    from(aa in Msdata.SystAccessAccounts,
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
    |> MscmpSystDb.one()
    |> case do
      %{recovery_underway: true} -> {:ok, :existing_recovery}
      %{password_credential_exists: true} -> {:ok, :recoverable}
      %{password_credential_exists: false} -> {:error, :not_found}
      nil -> {:error, :not_found}
    end
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
  def identify_access_account(recovery_token, owner_id) when is_binary(recovery_token) do
    recovery_token
    |> Helpers.get_identification_query("identity_types_sysdef_password_recovery", owner_id)
    |> MscmpSystDb.one()
    |> case do
      nil -> {:error, :not_found}
      identity -> {:ok, identity}
    end
  end

  ##############################################################################
  #
  # confirm_credential_recovery
  #
  #

  @spec confirm_credential_recovery(Msdata.SystIdentities.t()) ::
          :ok | {:error, :not_found} | {:error, term()}
  def confirm_credential_recovery(identity), do: Helpers.delete_identity(identity)

  ##############################################################################
  #
  # revoke_credential_recovery
  #
  #

  @spec revoke_credential_recovery(Msdata.SystIdentities.t()) ::
          :ok | {:error, :not_found} | {:error, term()}
  def revoke_credential_recovery(identity), do: Helpers.delete_identity(identity)

  ##############################################################################
  #
  # get_recovery_identity_for_access_account_id
  #
  #

  @spec get_recovery_identity_for_access_account_id(Types.access_account_id()) ::
          {:ok, Msdata.SystIdentities.t()} | {:error, :not_found} | {:error, term()}
  def get_recovery_identity_for_access_account_id(access_account_id) do
    from(i in Msdata.SystIdentities,
      join: ei in assoc(i, :identity_type),
      where:
        i.access_account_id == ^access_account_id and
          ei.internal_name == "identity_types_sysdef_password_recovery"
    )
    |> MscmpSystDb.one()
    |> case do
      nil -> {:error, :not_found}
      identity -> {:ok, identity}
    end
  end
end
