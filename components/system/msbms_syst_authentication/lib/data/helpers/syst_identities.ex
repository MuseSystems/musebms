# Source File: syst_identities.ex
# Location:    musebms/components/system/msbms_syst_authentication/lib/data/helpers/syst_identities.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MsbmsSystAuthentication.Data.Helpers.SystIdentities do
  @moduledoc false

  alias MsbmsSystAuthentication.Data.Helpers

  def resolve_name_params(change_params, operation) do
    change_params
    |> Helpers.General.resolve_access_account_id()
    |> resolve_identity_type_id(operation)
  end

  def resolve_identity_type_id(
        %{identity_type_name: identity_type_name} = change_params,
        _operation
      )
      when is_binary(identity_type_name) do
    identity_type = MsbmsSystEnums.get_enum_item_by_name("identity_types", identity_type_name)

    Map.put(change_params, :identity_type_id, identity_type.id)
  end

  def resolve_identity_type_id(
        %{identity_type_id: identity_type_id} = change_params,
        _operation
      )
      when is_binary(identity_type_id) do
    change_params
  end

  def resolve_identity_type_id(change_params, :insert) do
    identity_type = MsbmsSystEnums.get_default_enum_item("identity_types")

    Map.put(change_params, :identity_type_id, identity_type.id)
  end
end
