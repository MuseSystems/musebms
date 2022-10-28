# Source File: api_token.ex
# Location:    musebms/components/system/msbms_syst_authentication/lib/impl/credential/api_token.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MsbmsSystAuthentication.Impl.Credential.ApiToken do
  alias MsbmsSystAuthentication.Data
  alias MsbmsSystAuthentication.Impl.Credential.GenericToken
  alias MsbmsSystAuthentication.Types

  require Logger

  @behaviour MsbmsSystAuthentication.Impl.Credential

  @moduledoc false

  @token_type :credential_types_sysdef_token_api

  @spec confirm_credential(
          Types.access_account_id(),
          Types.identity_id() | nil,
          Types.credential()
        ) ::
          {:ok, Types.credential_confirm_result()} | {:error, MsbmsSystError.t() | Exception.t()}
  def confirm_credential(access_account_id, identity_id, token) do
    {:ok, confirm_credential!(access_account_id, identity_id, token)}
  rescue
    error -> {:error, error}
  end

  @spec confirm_credential!(
          Types.access_account_id(),
          Types.identity_id() | nil,
          Types.credential()
        ) ::
          Types.credential_confirm_result()
  def confirm_credential!(access_account_id, identity_id, token),
    do: GenericToken.confirm_credential(@token_type, access_account_id, identity_id, token)

  @spec set_credential(
          Types.access_account_id(),
          Types.identity_id() | nil,
          Types.credential() | nil,
          Keyword.t()
        ) ::
          {:ok, String.t()} | Types.credential_set_failures() | {:error, MsbmsSystError.t()}
  def set_credential(access_account_id, identity_id, token \\ nil, opts \\ []) do
    opts =
      MsbmsSystUtils.resolve_options(opts,
        credential_token_length: 40,
        credential_tokens: :mixed_alphanum
      )

    GenericToken.set_credential(@token_type, access_account_id, identity_id, token, opts)
  end

  @spec get_credential_record(Types.access_account_id(), Types.identity_id() | nil) ::
          {:ok, Data.SystCredentials.t() | nil} | {:error, MsbmsSystError.t() | Exception.t()}
  def get_credential_record(access_account_id, identity_id) do
    {:ok, get_credential_record!(access_account_id, identity_id)}
  rescue
    error -> {:error, error}
  end

  @spec get_credential_record!(Types.access_account_id(), Types.identity_id() | nil) ::
          Data.SystCredentials.t() | nil
  def get_credential_record!(access_account_id, identity_id),
    do: GenericToken.get_credential_record(@token_type, access_account_id, identity_id)

  @spec delete_credential(Types.credential_id() | Data.SystCredentials.t()) ::
          :ok | {:error, MsbmsSystError.t() | Exception.t()}
  def delete_credential(credential) do
    delete_credential!(credential)
  rescue
    error -> {:error, error}
  end

  @spec delete_credential!(Types.credential_id() | Data.SystCredentials.t()) :: :ok
  def delete_credential!(credential), do: GenericToken.delete_credential(@token_type, credential)
end
