# Source File: syst_access_accounts.ex
# Location:    musebms/components/system/msbms_syst_authentication/lib/data/validators/syst_access_accounts.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https: //muse.systems

defmodule MsbmsSystAuthentication.Data.Validators.SystAccessAccounts do
  import Ecto.Changeset
  import MsbmsSystUtils
  import MsbmsSystAuthentication.Data.Validators.General

  alias MsbmsSystAuthentication.Data
  alias MsbmsSystAuthentication.Data.Helpers
  alias MsbmsSystAuthentication.Types

  @moduledoc false

  @spec insert_changeset(Types.access_account_params(), Keyword.t()) :: Ecto.Changeset.t()
  def insert_changeset(insert_params, opts) do
    opts = resolve_options(opts, Helpers.OptionDefaults.defaults())

    resolved_insert_params = Helpers.SysAccessAccounts.resolve_name_params(insert_params, :insert)

    %Data.SystAccessAccounts{}
    |> cast(resolved_insert_params, [
      :internal_name,
      :external_name,
      :owning_owner_id,
      :allow_global_logins,
      :access_account_state_id
    ])
    |> validate_internal_name(opts)
    |> validate_required([
      :internal_name,
      :external_name,
      :access_account_state_id,
      :allow_global_logins
    ])
  end

  @spec update_changeset(Data.SystAccessAccounts.t(), Types.access_account_params(), Keyword.t()) ::
          Ecto.Changeset.t()
  def update_changeset(access_account, update_params, opts) do
    opts = resolve_options(opts, Helpers.OptionDefaults.defaults())

    resolved_update_params = Helpers.SysAccessAccounts.resolve_name_params(update_params, :update)

    access_account
    |> cast(resolved_update_params, [
      :internal_name,
      :external_name,
      :owning_owner_id,
      :allow_global_logins,
      :access_account_state_id
    ])
    |> validate_internal_name(opts)
    |> validate_required([
      :internal_name,
      :external_name,
      :access_account_state_id,
      :allow_global_logins
    ])
  end
end
