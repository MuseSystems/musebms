# Source File: syst_credentials.ex
# Location:    musebms/components/system/msbms_syst_authentication/lib/data/helpers/syst_credentials.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MsbmsSystAuthentication.Data.Helpers.SystCredentials do
  alias MsbmsSystAuthentication.Data.Helpers

  @moduledoc false

  def resolve_name_params(change_params, operation) do
    change_params
    |> Helpers.General.resolve_access_account_id()
    |> resolve_credential_type_id(operation)
  end

  def resolve_credential_type_id(
        %{credential_type_name: credential_type_name} = change_params,
        _operation
      )
      when is_binary(credential_type_name) do
    credential_type =
      MsbmsSystEnums.get_enum_item_by_name("credential_types", credential_type_name)

    Map.put(change_params, :credential_type_id, credential_type.id)
  end

  def resolve_credential_type_id(
        %{credential_type_id: credential_type_id} = change_params,
        _operation
      )
      when is_binary(credential_type_id) do
    change_params
  end

  # TODO: Should we really be defaulting this value?  Is such defaulting valid?
  def resolve_credential_type_id(change_params, :insert) do
    credential_type = MsbmsSystEnums.get_default_enum_item("credential_types")

    Map.put(change_params, :credential_type_id, credential_type.id)
  end
end
