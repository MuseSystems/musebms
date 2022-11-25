# Source File: credential.ex
# Location:    musebms/components/system/mscmp_syst_authn/lib/impl/credential.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystAuthn.Impl.Credential do
  alias MscmpSystAuthn.Types

  @moduledoc false

  @callback set_credential(
              Types.access_account_id(),
              Types.identity_id() | nil,
              Types.credential() | nil,
              Keyword.t()
            ) ::
              :ok
              | {:ok, Types.credential()}
              | Types.credential_set_failures()
              | {:error, MscmpSystError.t()}

  @callback confirm_credential!(
              Types.access_account_id(),
              Types.identity_id() | nil,
              Types.credential()
            ) ::
              Types.credential_confirm_result()

  @callback confirm_credential(
              Types.access_account_id(),
              Types.identity_id() | nil,
              Types.credential()
            ) ::
              {:ok, Types.credential_confirm_result()}
              | {:error, MscmpSystError.t() | Exception.t()}

  @callback get_credential_record!(Types.access_account_id(), Types.identity_id() | nil) ::
              Msdata.SystCredentials.t() | nil

  @callback get_credential_record(Types.access_account_id(), Types.identity_id() | nil) ::
              {:ok, Msdata.SystCredentials.t() | nil}
              | {:error, MscmpSystError.t() | Exception.t()}

  @callback delete_credential(Types.credential_id() | Msdata.SystCredentials.t()) ::
              :ok | {:error, MscmpSystError.t() | Exception.t()}

  @callback delete_credential!(Types.credential_id() | Msdata.SystCredentials.t()) :: :ok
end
