# Source File: recovery.ex
# Location:    musebms/components/system/mscmp_syst_authn/lib/impl/credential/recovery.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystAuthn.Impl.Credential.Recovery do
  @moduledoc false

  @behaviour MscmpSystAuthn.Impl.Credential

  alias MscmpSystAuthn.Impl.Credential.GenericToken
  alias MscmpSystAuthn.Types

  @token_type :credential_types_sysdef_token_recovery

  ##############################################################################
  #
  # confirm_credential
  #
  #

  @spec confirm_credential(
          Types.access_account_id(),
          Types.identity_id() | nil,
          Types.credential()
        ) ::
          {:ok, Types.credential_confirm_result()} | {:error, term()}
  def confirm_credential(access_account_id, identity_id, token),
    do: GenericToken.confirm_credential(@token_type, access_account_id, identity_id, token)

  ##############################################################################
  #
  # confirm_credential
  #
  #

  @spec set_credential(
          Types.access_account_id(),
          Types.identity_id() | nil,
          String.t() | nil,
          Keyword.t()
        ) :: {:ok, Types.credential()} | {:error, term()}
  def set_credential(access_account_id, identity_id, token, opts),
    do: GenericToken.set_credential(@token_type, access_account_id, identity_id, token, opts)

  ##############################################################################
  #
  # get_credential_record
  #
  #

  @spec get_credential_record(Types.access_account_id(), Types.identity_id() | nil) ::
          {:ok, Msdata.SystCredentials.t()} | {:error, :not_found} | {:error, term()}
  def get_credential_record(access_account_id, identity_id),
    do: GenericToken.get_credential_record(@token_type, access_account_id, identity_id)

  ##############################################################################
  #
  # delete_credential
  #
  #

  @spec delete_credential(Types.credential_id() | Msdata.SystCredentials.t()) ::
          :ok | {:error, :not_found} | {:error, term()}
  def delete_credential(credential), do: GenericToken.delete_credential(@token_type, credential)
end
