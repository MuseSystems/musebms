# Source File: api.ex
# Location:    musebms/components/system/msbms_syst_authentication/lib/impl/identity/api.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MsbmsSystAuthentication.Impl.Identity.ApiToken do
  import Ecto.Query
  import MsbmsSystUtils

  alias MsbmsSystAuthentication.Data
  alias MsbmsSystAuthentication.Impl.Identity.Helpers
  alias MsbmsSystAuthentication.Types

  require Logger

  @moduledoc false

  @spec create_identity(Types.access_account_id(), Keyword.t()) ::
          Data.SystIdentities.t()
  def create_identity(access_account_id, opts) when is_binary(access_account_id) do
    opts =
      resolve_options(opts,
        create_validated: true,
        identity_token_length: 40,
        tokens: :mixed_alphanum,
        external_name: nil
      )

    api_token = get_random_string(opts[:identity_token_length], opts[:tokens])

    identity_params = %{
      access_account_id: access_account_id,
      identity_type_name: "identity_types_sysdef_api",
      account_identifier: api_token,
      external_name: opts[:external_name]
    }

    Helpers.create_identity(identity_params, opts)
  end

  @spec identify_owned_access_account(
          MsbmsSystInstanceMgr.Types.owner_id(),
          Types.account_identifier()
        ) :: Data.SystAccessAccounts.t() | nil
  def identify_owned_access_account(owner_id, api_token)
      when is_binary(owner_id) and is_binary(api_token) do
    api_token
    |> Helpers.get_identification_query("identity_types_sysdef_api", owner_id)
    |> MsbmsSystDatastore.one()
  end

  @spec identify_unowned_access_account(Types.account_identifier()) ::
          Data.SystAccessAccounts.t() | nil
  def identify_unowned_access_account(api_token) when is_binary(api_token) do
    api_token
    |> Helpers.get_identification_query("identity_types_sysdef_api", nil)
    |> MsbmsSystDatastore.one()
  end

  @spec update_identity_external_name(
          Types.identity_id() | Data.SystIdentities.t(),
          String.t() | nil
        ) :: Data.SystIdentities.t()
  def update_identity_external_name(identity_id, external_name) when is_binary(identity_id) do
    from(i in Data.SystIdentities, where: i.id == ^identity_id)
    |> MsbmsSystDatastore.one!()
    |> update_identity_external_name(external_name)
  end

  def update_identity_external_name(%Data.SystIdentities{} = identity, external_name) do
    update_params = %{
      external_name: external_name
    }

    Helpers.update_record(identity, update_params)
  end

  @spec delete_identity(Types.identity_id() | Data.SystIdentities.t()) :: :ok
  # Right now there's no specific api_token identity related logic, but it's
  # conceivable there will be in future.
  def delete_identity(identity), do: Helpers.delete_identity(identity)
end
