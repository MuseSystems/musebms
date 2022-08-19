# Source File: syst_identities.ex
# Location:    musebms/components/system/msbms_syst_authentication/lib/data/validators/syst_identities.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MsbmsSystAuthentication.Data.Validators.SystIdentities do
  import Ecto.Changeset

  alias MsbmsSystAuthentication.Data
  alias MsbmsSystAuthentication.Data.Helpers
  alias MsbmsSystAuthentication.Types

  @moduledoc false

  @spec insert_changeset(Types.identity_params()) :: Ecto.Changeset.t()
  def insert_changeset(insert_params) do
    resolved_insert_params = Helpers.SystIdentities.resolve_name_params(insert_params, :insert)

    core_changeset(%Data.SystIdentities{}, resolved_insert_params)
  end

  @spec update_changeset(Data.SystIdentities.t(), Types.identity_params()) :: Ecto.Changeset.t()
  def update_changeset(identity, update_params) do
    resolved_update_params = Helpers.SystIdentities.resolve_name_params(update_params, :update)

    identity
    |> core_changeset(resolved_update_params)
    |> optimistic_lock(:diag_row_version)
  end

  defp core_changeset(identity, change_params) do
    identity
    |> cast(change_params, [
      :access_account_id,
      :identity_type_id,
      :account_identifier,
      :validated,
      :validates_identity_id,
      :validation_requested,
      :validation_expires,
      :primary_contact
    ])
    |> validate_required([
      :access_account_id,
      :identity_type_id,
      :account_identifier,
      :primary_contact
    ])
  end
end
