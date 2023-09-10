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

  require Logger

  @default_create_validated true
  @default_identity_token_length 20
  @default_identity_tokens :mixed_alphanum
  @default_external_name nil

  @spec create_identity(Types.access_account_id(), Types.account_identifier() | nil, Keyword.t()) ::
          {:ok, Msdata.SystIdentities.t()} | {:error, MscmpSystError.t() | Exception.t()}
  def create_identity(access_account_id, api_token, opts \\ [])
      when is_binary(access_account_id) do
    opts =
      MscmpSystUtils.resolve_options(opts,
        create_validated: @default_create_validated,
        identity_token_length: @default_identity_token_length,
        identity_tokens: @default_identity_tokens,
        external_name: @default_external_name
      )

    api_token =
      api_token ||
        MscmpSystUtils.get_random_string(opts[:identity_token_length], opts[:identity_tokens])

    identity_params = %{
      access_account_id: access_account_id,
      identity_type_name: "identity_types_sysdef_api",
      account_identifier: api_token,
      external_name: opts[:external_name]
    }

    {:ok, Helpers.create_identity(identity_params, opts)}
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MscmpSystError{
          code: :undefined_error,
          message: "Failure creating API Token Identity.",
          cause: error
        }
      }
  end

  @spec identify_access_account(
          Types.account_identifier(),
          MscmpSystInstance.Types.owner_id() | nil
        ) :: Msdata.SystIdentities.t() | nil
  def identify_access_account(api_token, owner_id) when is_binary(api_token) do
    api_token
    |> Helpers.get_identification_query("identity_types_sysdef_api", owner_id)
    |> MscmpSystDb.one()
  end

  @spec update_identity_external_name(
          Types.identity_id() | Msdata.SystIdentities.t(),
          String.t() | nil
        ) :: Msdata.SystIdentities.t()
  def update_identity_external_name(identity_id, external_name) when is_binary(identity_id) do
    from(i in Msdata.SystIdentities,
      join: ei in assoc(i, :identity_type),
      where: ei.internal_name == "identity_types_sysdef_api" and i.id == ^identity_id
    )
    |> MscmpSystDb.one!()
    |> update_identity_external_name(external_name)
  end

  def update_identity_external_name(%Msdata.SystIdentities{} = identity, external_name) do
    update_params = %{
      external_name: external_name
    }

    Helpers.update_record(identity, update_params)
  end
end
