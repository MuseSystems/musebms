# Source File: syst_access_accounts.ex
# Location:    musebms/components/system/mscmp_syst_authn/lib/msdata/helpers/syst_access_accounts.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystAuthn.Msdata.Helpers.SystAccessAccounts do
  @moduledoc false

  alias MscmpSystAuthn.Msdata.Helpers

  def resolve_name_params(access_account_params, operation) do
    access_account_params
    |> Helpers.General.resolve_owner_id()
    |> resolve_access_account_state_id(operation)
  end

  def resolve_access_account_state_id(
        %{access_account_state_name: access_account_state_name} = access_account_params,
        _operation
      )
      when is_binary(access_account_state_name) do
    access_account_state =
      MscmpSystEnums.get_enum_item_by_name("access_account_states", access_account_state_name)

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
      MscmpSystEnums.get_default_enum_item("access_account_states",
        functional_type_name: "access_account_states_pending"
      )

    Map.put(access_account_params, :access_account_state_id, access_account_state.id)
  end

  def resolve_access_account_state_id(access_account_params, _operation),
    do: access_account_params
end
