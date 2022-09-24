# Source File: account_code.ex
# Location:    musebms/components/system/msbms_syst_authentication/lib/impl/identity/account_code.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MsbmsSystAuthentication.Impl.Identity.AccountCode do
  import Ecto.Query
  import MsbmsSystUtils

  alias MsbmsSystAuthentication.Data
  alias MsbmsSystAuthentication.Impl.Identity.Helpers
  alias MsbmsSystAuthentication.Types

  require Logger

  @behaviour MsbmsSystAuthentication.Impl.Identity

  @moduledoc false

  @default_api_token_params [identity_token_length: 12, tokens: :b32c]

  @spec create_identity(Types.access_account_id(), Keyword.t()) :: Data.SystIdentities.t()
  def create_identity(access_account_id, opts) when is_binary(access_account_id) do
    opts = resolve_options(opts, [{:create_validated, true} | @default_api_token_params])

    api_token = get_random_string(opts[:identity_token_length], opts[:tokens])

    identity_params = %{
      access_account_id: access_account_id,
      identity_type_name: "identity_types_sysdef_account",
      account_identifier: api_token
    }

    Helpers.create_identity(identity_params, opts)
  end

  @spec identify_access_account_owned(
          MsbmsSystInstanceMgr.Types.owner_id(),
          Types.account_identifier()
        ) :: Data.SystAccessAccounts.t() | nil
  def identify_access_account_owned(owner_id, account_code)
      when is_binary(owner_id) and is_binary(account_code) do
    account_code
    |> Helpers.get_identification_query("identity_types_sysdef_account", owner_id)
    |> MsbmsSystDatastore.one()
  end

  @spec identify_access_account_unowned(Types.account_identifier()) ::
          Data.SystAccessAccounts.t() | nil
  def identify_access_account_unowned(account_code) when is_binary(account_code) do
    account_code
    |> Helpers.get_identification_query("identity_types_sysdef_account", nil)
    |> MsbmsSystDatastore.one()
  end

  @spec reset_identity_for_access_account(Types.access_account_id(), Keyword.t()) ::
          Data.SystIdentities.t()
  def reset_identity_for_access_account(access_account_id, opts) do
    identity_type =
      MsbmsSystEnums.get_enum_item_by_name("identity_types", "identity_types_sysdef_account")

    from(i in Data.SystIdentities,
      where: i.access_account_id == ^access_account_id and i.identity_type_id == ^identity_type.id
    )
    |> MsbmsSystDatastore.one!()
    |> reset_identity(opts)
  end

  @spec reset_identity(Types.identity_id() | Data.SystIdentities.t(), Keyword.t()) ::
          Data.SystIdentities.t()
  def reset_identity(identity_id, opts) when is_binary(identity_id) do
    from(i in Data.SystIdentities, where: i.id == ^identity_id)
    |> MsbmsSystDatastore.one!()
    |> reset_identity(opts)
  end

  def reset_identity(%Data.SystIdentities{} = identity, opts) do
    opts = resolve_options(opts, @default_api_token_params)

    api_token = get_random_string(opts[:identity_token_length], opts[:tokens])

    update_params = %{
      account_identifier: api_token
    }

    Helpers.update_record(identity, update_params)
  end
end
