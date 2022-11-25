# Source File: syst_identities.ex
# Location:    musebms/components/system/mscmp_syst_authn/lib/msdata/validators/syst_identities.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystAuthn.Msdata.Validators.SystIdentities do
  import Ecto.Changeset

  alias MscmpSystAuthn.Msdata.Helpers
  alias MscmpSystAuthn.Types

  @moduledoc false

  @spec insert_changeset(Types.identity_params()) :: Ecto.Changeset.t()
  def insert_changeset(insert_params) do
    resolved_insert_params = Helpers.SystIdentities.resolve_name_params(insert_params, :insert)

    %Msdata.SystIdentities{}
    |> cast(resolved_insert_params, [
      :access_account_id,
      :identity_type_id,
      :account_identifier,
      :validated,
      :validates_identity_id,
      :validation_requested,
      :identity_expires,
      :external_name
    ])
    |> validate_common()
  end

  @spec update_changeset(Msdata.SystIdentities.t(), Types.identity_params()) :: Ecto.Changeset.t()
  def update_changeset(identity, update_params) do
    identity
    |> cast(update_params, [
      :validated,
      :validation_requested,
      :identity_expires,
      :external_name
    ])
    |> validate_common()
    |> optimistic_lock(:diag_row_version)
  end

  defp validate_common(changeset) do
    validate_required(changeset, [
      :access_account_id,
      :identity_type_id,
      :account_identifier
    ])
    |> unique_constraint(:validates_identity_id, name: :syst_identities_validates_identities_udx)
  end
end
