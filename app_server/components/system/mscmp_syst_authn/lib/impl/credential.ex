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
  @moduledoc false

  alias MscmpSystAuthn.Types

  ##############################################################################
  #
  # Credential Behaviour Callbacks
  #
  #

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

  ##############################################################################
  #
  # get_credential_type_by_name
  #
  #

  @spec get_credential_type_by_name(Types.credential_type_name()) ::
          Msdata.SystEnumItems.t() | nil
  def get_credential_type_by_name(credential_type_name) when is_binary(credential_type_name),
    do: MscmpSystEnums.get_item_by_name("credential_types", credential_type_name)

  ##############################################################################
  #
  # get_credential_type_default
  #
  #

  @spec get_credential_type_default(Types.credential_type_functional_types() | nil) ::
          Msdata.SystEnumItems.t()
  def get_credential_type_default(nil),
    do: MscmpSystEnums.get_default_item("credential_types")

  def get_credential_type_default(functional_type) when is_atom(functional_type) do
    MscmpSystEnums.get_default_item("credential_types",
      functional_type_name: Atom.to_string(functional_type)
    )
  end
end
