# Source File: syst_credentials.ex
# Location:    musebms/components/system/msbms_syst_authentication/lib/data/validators/syst_credentials.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MsbmsSystAuthentication.Data.Validators.SystCredentials do
  import Ecto.Changeset

  alias MsbmsSystAuthentication.Data
  alias MsbmsSystAuthentication.Data.Helpers
  alias MsbmsSystAuthentication.Types

  @moduledoc false

  @spec insert_changeset(Types.credential_params()) :: Ecto.Changeset.t()
  def insert_changeset(insert_params) do
    resolved_insert_params = Helpers.SystCredentials.resolve_name_params(insert_params, :insert)

    %Data.SystCredentials{}
    |> cast(resolved_insert_params, [
      :access_account_id,
      :credential_type_id,
      :credential_data,
      :credential_for_identity_id
    ])
    |> put_change(:last_updated, DateTime.utc_now())
    |> validate_common()
  end

  def update_changeset(credential, update_params) do
    credential
    |> cast(update_params, [:credential_data])
    |> maybe_set_last_updated()
    |> validate_common()
    |> optimistic_lock(:diag_row_version)
  end

  defp maybe_set_last_updated(%Ecto.Changeset{changes: %{credential_data: _}} = changeset) do
    put_change(changeset, :last_updated, DateTime.utc_now())
  end

  defp maybe_set_last_updated(changeset), do: changeset

  defp validate_common(changeset) do
    validate_required(changeset, [
      :access_account_id,
      :credential_type_id,
      :credential_data,
      :last_updated
    ])
  end
end
