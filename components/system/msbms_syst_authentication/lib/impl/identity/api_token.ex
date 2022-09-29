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

  alias MsbmsSystAuthentication.Data
  alias MsbmsSystAuthentication.Impl.Identity.Helpers
  alias MsbmsSystAuthentication.Types

  require Logger

  @behaviour MsbmsSystAuthentication.Impl.Identity

  @moduledoc false

  @spec create_identity(Types.access_account_id(), Types.account_identifier(), Keyword.t()) ::
          Data.SystIdentities.t()
  def create_identity(access_account_id, api_token, opts) when is_binary(access_account_id) do
    opts =
      MsbmsSystUtils.resolve_options(opts,
        create_validated: true,
        identity_token_length: 20,
        identity_tokens: :mixed_alphanum,
        external_name: nil
      )

    api_token =
      api_token ||
        MsbmsSystUtils.get_random_string(opts[:identity_token_length], opts[:identity_tokens])

    identity_params = %{
      access_account_id: access_account_id,
      identity_type_name: "identity_types_sysdef_api",
      account_identifier: api_token,
      external_name: opts[:external_name]
    }

    Helpers.create_identity(identity_params, opts)
  end

  @spec identify_access_account(
          Types.account_identifier(),
          MsbmsSystInstanceMgr.Types.owner_id() | nil
        ) :: Data.SystIdentities.t() | nil
  def identify_access_account(api_token, owner_id) when is_binary(api_token) do
    api_token
    |> Helpers.get_identification_query("identity_types_sysdef_api", owner_id)
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
end
