# Source File: syst_credentials.ex
# Location:    musebms/components/system/mscmp_syst_authn/lib/msdata/validators/syst_credentials.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystAuthn.Msdata.Validators.SystCredentials do
  @moduledoc false

  import Ecto.Changeset

  alias MscmpSystAuthn.Msdata.Helpers
  alias MscmpSystAuthn.Types

  @spec insert_changeset(Types.credential_params()) :: Ecto.Changeset.t()
  def insert_changeset(insert_params) do
    resolved_insert_params = Helpers.SystCredentials.resolve_name_params(insert_params, :insert)

    %Msdata.SystCredentials{}
    |> cast(resolved_insert_params, [
      :access_account_id,
      :credential_type_id,
      :credential_data,
      :credential_for_identity_id,
      :force_reset
    ])
    |> put_last_updated()
    |> validate_common()
  end

  @spec update_changeset(Msdata.SystCredentials.t(), Types.credential_params()) ::
          Ecto.Changeset.t()
  def update_changeset(credential, update_params) do
    credential
    |> cast(update_params, [:credential_data, :force_reset])
    |> maybe_set_credential_dates()
    |> validate_common()
    |> optimistic_lock(:diag_row_version)
  end

  defp maybe_set_credential_dates(%Ecto.Changeset{changes: %{credential_data: _}} = changeset) do
    changeset
    |> put_last_updated()
    |> put_change(:force_reset, nil)
  end

  defp maybe_set_credential_dates(changeset), do: changeset

  defp put_last_updated(changeset) do
    curr_timestamp = DateTime.utc_now() |> DateTime.truncate(:second)

    put_change(changeset, :last_updated, curr_timestamp)
  end

  defp validate_common(changeset) do
    validate_required(changeset, [
      :access_account_id,
      :credential_type_id,
      :credential_data,
      :last_updated
    ])
    |> foreign_key_constraint(:access_account_id, name: :syst_credentials_access_accounts_fk)
    |> foreign_key_constraint(:credential_type_id, name: :syst_credentials_credential_types_fk)
    |> foreign_key_constraint(:credential_for_identity_id,
      name: :syst_credentials_for_identities_fk
    )
    |> unique_constraint([:access_account_id, :credential_type_id, :credential_for_identity_id],
      name: :syst_credentials_udx
    )
  end
end
