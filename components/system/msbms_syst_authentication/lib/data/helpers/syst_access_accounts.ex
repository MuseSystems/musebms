# Source File: syst_access_accounts.ex
# Location:    musebms/components/system/msbms_syst_authentication/lib/data/helpers/syst_access_accounts.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MsbmsSystAuthentication.Data.Helpers.SysAccessAccounts do
  @moduledoc false

  def resolve_name_params(access_account_params, operation) do
    access_account_params
    |> resolve_owner_id()
    |> resolve_access_account_state_id(operation)
  end

  def resolve_owner_id(%{owning_owner_name: owner_name} = access_account_params)
      when is_binary(owner_name) do
    {:ok, owner_id} = MsbmsSystInstanceMgr.get_owner_id_by_name(owner_name)

    Map.put(access_account_params, :owning_owner_id, owner_id)
  end

  def resolve_owner_id(access_account_params), do: access_account_params

  def resolve_access_account_state_id(
        %{access_account_state_name: access_account_state_name} = access_account_params,
        _operation
      )
      when is_binary(access_account_state_name) do
    access_account_state =
      MsbmsSystEnums.get_enum_item_by_name("access_account_states", access_account_state_name)

    Map.put(access_account_params, :access_account_state_id, access_account_state.id)
  end

  def resolve_access_account_state_id(
        %{access_account_state_id: access_account_state_id} = access_account_params,
        _operation
      )
      when is_binary(access_account_state_id) do
    access_account_params
  end

  def resolve_access_account_state_id(access_account_params, :insert) do
    access_account_state =
      MsbmsSystEnums.get_default_enum_item("access_account_states",
        functional_type_name: "access_account_states_pending"
      )

    Map.put(access_account_params, :access_account_state_id, access_account_state.id)
  end
end
