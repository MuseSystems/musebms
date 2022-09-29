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

  alias MsbmsSystAuthentication.Data
  alias MsbmsSystAuthentication.Impl.Identity.Helpers
  alias MsbmsSystAuthentication.Types

  require Logger

  @behaviour MsbmsSystAuthentication.Impl.Identity

  @moduledoc false

  @default_account_code_params [identity_token_length: 12, identity_tokens: :b32c]

  @spec create_identity(Types.access_account_id(), Types.account_identifier(), Keyword.t()) ::
          Data.SystIdentities.t()
  def create_identity(access_account_id, account_code, opts) when is_binary(access_account_id) do
    opts =
      MsbmsSystUtils.resolve_options(opts, [
        {:create_validated, true} | @default_account_code_params
      ])

    account_code =
      account_code ||
        MsbmsSystUtils.get_random_string(opts[:identity_token_length], opts[:identity_tokens])

    identity_params = %{
      access_account_id: access_account_id,
      identity_type_name: "identity_types_sysdef_account",
      account_identifier: account_code
    }

    Helpers.create_identity(identity_params, opts)
  end

  @spec identify_access_account(
          Types.account_identifier(),
          MsbmsSystInstanceMgr.Types.owner_id() | nil
        ) :: Data.SystIdentities.t() | nil
  def identify_access_account(account_code, owner_id) when is_binary(account_code) do
    account_code
    |> Helpers.get_identification_query("identity_types_sysdef_account", owner_id)
    |> MsbmsSystDatastore.one()
  end

  @spec reset_identity_for_access_account_id(Types.access_account_id(), Keyword.t()) ::
          Data.SystIdentities.t()
  def reset_identity_for_access_account_id(access_account_id, opts) do
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
    opts = MsbmsSystUtils.resolve_options(opts, @default_account_code_params)

    account_code =
      MsbmsSystUtils.get_random_string(opts[:identity_token_length], opts[:identity_tokens])

    update_params = %{
      account_identifier: account_code
    }

    Helpers.update_record(identity, update_params)
  end
end
