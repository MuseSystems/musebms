# Source File: validators.ex
# Location:    musebms/app_server/components/system/mscmp_syst_authn/lib/impl/msdata/syst_access_accounts/validators.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystAuthn.Impl.Msdata.SystAccessAccounts.Validators do
  @moduledoc false

  import Ecto.Changeset

  alias MscmpSystAuthn.Impl.Msdata.Helpers
  alias MscmpSystAuthn.Types

  ##############################################################################
  #
  # insert_changeset
  #
  #

  @spec insert_changeset(Types.access_account_params(), Keyword.t()) :: Ecto.Changeset.t()
  def insert_changeset(insert_params, opts) do
    resolved_insert_params = resolve_name_params(insert_params, :insert)

    %Msdata.SystAccessAccounts{}
    |> cast(resolved_insert_params, [
      :internal_name,
      :external_name,
      :owning_owner_id,
      :allow_global_logins,
      :access_account_state_id
    ])
    |> validate_common(opts)
  end

  ##############################################################################
  #
  # update_changeset
  #
  #

  @spec update_changeset(
          Msdata.SystAccessAccounts.t(),
          Types.access_account_params(),
          Keyword.t()
        ) ::
          Ecto.Changeset.t()
  def update_changeset(access_account, update_params, opts) do
    resolved_update_params = resolve_name_params(update_params, :update)

    access_account
    |> cast(resolved_update_params, [
      :internal_name,
      :external_name,
      :allow_global_logins,
      :access_account_state_id
    ])
    |> validate_common(opts)
    |> optimistic_lock(:diag_row_version)
  end

  defp validate_common(changeset, opts) do
    changeset
    |> Msutils.Data.validate_internal_name(opts)
    |> Msutils.Data.validate_external_name(opts)
    |> validate_required([
      :internal_name,
      :external_name,
      :access_account_state_id,
      :allow_global_logins
    ])
    |> unique_constraint(:internal_name, name: :syst_access_accounts_internal_name_udx)
    |> foreign_key_constraint(:owning_owner_id, name: :syst_access_accounts_owners_fk)
    |> foreign_key_constraint(:access_account_state_id,
      name: :syst_access_accounts_access_account_states_fk
    )
  end

  defp resolve_name_params(access_account_params, operation) do
    access_account_params
    |> Helpers.resolve_owner_id()
    |> resolve_access_account_state_id(operation)
  end

  defp resolve_access_account_state_id(
         %{access_account_state_name: access_account_state_name} = access_account_params,
         _operation
       )
       when is_binary(access_account_state_name) do
    access_account_state =
      MscmpSystEnums.get_enum_item_by_name("access_account_states", access_account_state_name)

    Map.put(access_account_params, :access_account_state_id, access_account_state.id)
  end

  defp resolve_access_account_state_id(
         %{access_account_state_id: access_account_state_id} = access_account_params,
         _operation
       )
       when is_binary(access_account_state_id) do
    access_account_params
  end

  defp resolve_access_account_state_id(access_account_params, :insert) do
    access_account_state =
      MscmpSystEnums.get_default_enum_item("access_account_states",
        functional_type_name: "access_account_states_pending"
      )

    Map.put(access_account_params, :access_account_state_id, access_account_state.id)
  end

  defp resolve_access_account_state_id(access_account_params, _operation),
    do: access_account_params
end
