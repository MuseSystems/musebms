# Source File: syst_access_account_instance_assocs.ex
# Location:    musebms/components/system/msbms_syst_authentication/lib/data/helpers/syst_access_account_instance_assocs.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https: //muse.systems

defmodule MsbmsSystAuthentication.Data.Helpers.SystAccessAccountInstanceAssocs do
  @moduledoc false

  alias MsbmsSystAuthentication.Impl

  def resolve_name_params(change_params, operation) do
    change_params
    |> resolve_access_account_id()
    |> resolve_credential_type_id(operation)
    |> resolve_instance_id()
  end

  def resolve_access_account_id(%{access_account_name: access_account_name} = change_params)
      when is_binary(access_account_name) do
    {:ok, access_account_id} =
      Impl.AccessAccount.get_access_account_id_by_name(access_account_name)

    Map.put(change_params, :access_account_od, access_account_id)
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

  def resolve_credential_type_id(change_params, :insert) do
    credential_type = MsbmsSystEnums.get_default_enum_item("credential_types")

    Map.put(change_params, :credential_type_id, credential_type.id)
  end

  def resolve_instance_id(%{instance_name: instance_name} = change_params)
      when is_binary(instance_name) do
    {:ok, instance_id} = MsbmsSystInstanceMgr.get_instance_id_by_name(instance_name)

    Map.put(change_params, :instance_id, instance_id)
  end
end
