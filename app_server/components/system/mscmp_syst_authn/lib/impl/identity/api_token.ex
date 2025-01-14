# Source File: api_token.ex
# Location:    musebms/components/system/mscmp_syst_authn/lib/impl/identity/api_token.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystAuthn.Impl.Identity.ApiToken do
  @moduledoc false

  @behaviour MscmpSystAuthn.Impl.Identity

  import Ecto.Query

  alias MscmpSystAuthn.Impl.Identity.Helpers
  alias MscmpSystAuthn.Types

  ##############################################################################
  #
  # create_identity
  #
  #

  @spec create_identity(Types.access_account_id(), Types.account_identifier() | nil, Keyword.t()) ::
          {:ok, Msdata.SystIdentities.t()} | {:error, term()}
  def create_identity(access_account_id, api_token, opts)
      when is_binary(access_account_id) do
    api_token =
      api_token ||
        Msutils.String.get_random_string(opts[:identity_token_length], opts[:identity_tokens])

    identity_params = %{
      access_account_id: access_account_id,
      identity_type_name: "identity_types_sysdef_api",
      account_identifier: api_token,
      external_name: opts[:external_name]
    }

    Helpers.create_identity(identity_params, opts)
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
  def identify_access_account(api_token, owner_id) when is_binary(api_token) do
    api_token
    |> Helpers.get_identification_query("identity_types_sysdef_api", owner_id)
    |> MscmpSystDb.one()
    |> case do
      nil -> {:error, :not_found}
      identity -> {:ok, identity}
    end
  end

  ##############################################################################
  #
  # update_identity_external_name
  #
  #

  @spec update_identity_external_name(
          Types.identity_id() | Msdata.SystIdentities.t(),
          String.t() | nil
        ) :: {:ok, Msdata.SystIdentities.t()} | {:error, :not_found} | {:error, term()}
  def update_identity_external_name(identity_id, external_name) when is_binary(identity_id) do
    from(i in Msdata.SystIdentities,
      join: ei in assoc(i, :identity_type),
      where: ei.internal_name == "identity_types_sysdef_api" and i.id == ^identity_id
    )
    |> MscmpSystDb.one()
    |> case do
      nil -> {:error, :not_found}
      identity -> update_identity_external_name(identity, external_name)
    end
  end

  def update_identity_external_name(%Msdata.SystIdentities{} = identity, external_name),
    do: Helpers.update_identity(identity, %{external_name: external_name})
end
