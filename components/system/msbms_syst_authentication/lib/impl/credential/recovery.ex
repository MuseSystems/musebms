# Source File: recovery.ex
# Location:    musebms/components/system/msbms_syst_authentication/lib/impl/credential/recovery.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MsbmsSystAuthentication.Impl.Credential.Recovery do
  alias MsbmsSystAuthentication.Data
  alias MsbmsSystAuthentication.Impl.Credential.GenericToken
  alias MsbmsSystAuthentication.Types

  require Logger

  @behaviour MsbmsSystAuthentication.Impl.Credential

  @moduledoc false

  @token_type :credential_types_sysdef_token_recovery

  @spec confirm_credential(
          Types.access_account_id(),
          Types.identity_id() | nil,
          Types.credential()
        ) ::
          Types.credential_confirm_result()
  def confirm_credential(access_account_id, identity_id, token),
    do: GenericToken.confirm_credential(@token_type, access_account_id, identity_id, token)

  @spec set_credential(
          Types.access_account_id(),
          Types.identity_id() | nil,
          String.t() | nil,
          Keyword.t()
        ) ::
          {:ok, Types.credential()}
          | Types.credential_set_failures()
          | {:error, MsbmsSystError.t()}
  def set_credential(access_account_id, identity_id, token \\ nil, opts \\ []) do
    opts =
      MsbmsSystUtils.resolve_options(opts,
        credential_token_length: 40,
        credential_tokens: :mixed_alphanum
      )

    GenericToken.set_credential(@token_type, access_account_id, identity_id, token, opts)
  end

  @spec get_credential_record(Types.access_account_id(), Types.identity_id() | nil) ::
          Data.SystCredentials.t() | nil
  def get_credential_record(access_account_id, identity_id),
    do: GenericToken.get_credential_record(@token_type, access_account_id, identity_id)

  @spec delete_credential(Types.credential_id() | Data.SystCredentials.t()) ::
          :ok | {:error, MsbmsSystError.t()}

  def delete_credential(credential), do: GenericToken.delete_credential(@token_type, credential)
end