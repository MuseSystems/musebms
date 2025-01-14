# Source File: account_code.ex
# Location:    musebms/components/system/mscmp_syst_authn/lib/impl/identity/account_code.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystAuthn.Impl.Identity.AccountCode do
  @moduledoc false

  @behaviour MscmpSystAuthn.Impl.Identity

  import Msutils.Guards

  import Ecto.Query

  alias MscmpSystAuthn.Impl
  alias MscmpSystAuthn.Types

  ##############################################################################
  #
  # create_identity
  #
  #

  @spec create_identity(Types.access_account_id(), Types.account_identifier() | nil, Keyword.t()) ::
          {:ok, Msdata.SystIdentities.t()} | {:error, term()}
  def create_identity(access_account_id, account_code, opts)
      when is_binary(access_account_id) do
    account_code =
      account_code ||
        Msutils.String.get_random_string(opts[:identity_token_length], opts[:identity_tokens])

    identity_params = %{
      access_account_id: access_account_id,
      identity_type_name: "identity_types_sysdef_account",
      account_identifier: account_code
    }

    Impl.Identity.Helpers.create_identity(identity_params, opts)
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
  def identify_access_account(account_code, owner_id) when is_binary(account_code) do
    account_code
    |> Impl.Identity.Helpers.get_identification_query("identity_types_sysdef_account", owner_id)
    |> MscmpSystDb.one()
    |> case do
      nil -> {:error, :not_found}
      identity -> {:ok, identity}
    end
  end

  ##############################################################################
  #
  # reset_identity_for_access_account_id
  #
  #

  @spec reset_identity_for_access_account_id(Types.access_account_id(), Keyword.t()) ::
          {:ok, Msdata.SystIdentities.t()} | {:error, term()}
  def reset_identity_for_access_account_id(access_account_id, opts) do
    reset_func = fn ->
      with identity_id when is_uuid(identity_id) or is_nil(identity_id) <-
             maybe_get_account_code_identity(access_account_id),
           :ok <- maybe_delete_account_code_identity(identity_id),
           {:ok, identity} <- create_identity(access_account_id, opts[:account_code], opts) do
        identity
      else
        {:error, error} -> MscmpSystDb.rollback(error)
      end
    end

    MscmpSystDb.transaction(reset_func)
  end

  defp maybe_get_account_code_identity(access_account_id) do
    from(i in Msdata.SystIdentities,
      join: ei in assoc(i, :identity_type),
      where:
        i.access_account_id == ^access_account_id and
          ei.internal_name == "identity_types_sysdef_account",
      select: i.id
    )
    |> MscmpSystDb.one()
  end

  defp maybe_delete_account_code_identity(identity_id) when is_uuid(identity_id),
    do: Impl.Identity.delete_identity(identity_id, "identity_types_sysdef_account")

  defp maybe_delete_account_code_identity(nil), do: :ok

  ##############################################################################
  #
  # get_account_code_by_access_account_id
  #
  #

  @spec get_account_code_by_access_account_id(Types.access_account_id()) ::
          {:ok, Msdata.SystIdentities.t()} | {:error, :not_found} | {:error, term()}
  def get_account_code_by_access_account_id(access_account_id)
      when is_binary(access_account_id) do
    from(i in Msdata.SystIdentities,
      join: ei in assoc(i, :identity_type),
      where:
        i.access_account_id == ^access_account_id and
          ei.internal_name == "identity_types_sysdef_account"
    )
    |> MscmpSystDb.one()
    |> case do
      %Msdata.SystIdentities{} = identity -> {:ok, identity}
      nil -> {:error, :not_found}
      error -> {:error, {:database_error, error}}
    end
  end
end
