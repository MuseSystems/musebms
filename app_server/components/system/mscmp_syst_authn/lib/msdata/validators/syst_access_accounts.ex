# Source File: syst_access_accounts.ex
# Location:    musebms/components/system/mscmp_syst_authn/lib/msdata/validators/syst_access_accounts.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystAuthn.Msdata.Validators.SystAccessAccounts do
  import Ecto.Changeset

  alias MscmpSystAuthn.Msdata.Helpers
  alias MscmpSystAuthn.Msdata.Validators
  alias MscmpSystAuthn.Types

  @moduledoc false

  @spec insert_changeset(Types.access_account_params(), Keyword.t()) :: Ecto.Changeset.t()
  def insert_changeset(insert_params, opts) do
    opts = MscmpSystUtils.resolve_options(opts, Helpers.OptionDefaults.defaults())

    resolved_insert_params =
      Helpers.SystAccessAccounts.resolve_name_params(insert_params, :insert)

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

  @spec update_changeset(
          Msdata.SystAccessAccounts.t(),
          Types.access_account_params(),
          Keyword.t()
        ) ::
          Ecto.Changeset.t()
  def update_changeset(access_account, update_params, opts) do
    opts = MscmpSystUtils.resolve_options(opts, Helpers.OptionDefaults.defaults())

    resolved_update_params =
      Helpers.SystAccessAccounts.resolve_name_params(update_params, :update)

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
    |> Validators.General.validate_internal_name(opts)
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
end
