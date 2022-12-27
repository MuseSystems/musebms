# Source File: syst_access_account_instance_assocs.ex
# Location:    musebms/components/system/mscmp_syst_authn/lib/msdata/validators/syst_access_account_instance_assocs.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystAuthn.Msdata.Validators.SystAccessAccountInstanceAssocs do
  import Ecto.Changeset

  alias MscmpSystAuthn.Msdata.Helpers
  alias MscmpSystAuthn.Types

  @moduledoc false

  @spec insert_changeset(Types.access_account_instance_assoc_params()) :: Ecto.Changeset.t()
  def insert_changeset(insert_params) do
    resolved_insert_params =
      Helpers.SystAccessAccountInstanceAssocs.resolve_name_params(insert_params, :insert)

    %Msdata.SystAccessAccountInstanceAssocs{}
    |> cast(resolved_insert_params, [
      :access_account_id,
      :instance_id,
      :access_granted,
      :invitation_issued,
      :invitation_expires,
      :invitation_declined
    ])
    |> unique_constraint([:access_account_id, :instance_id],
      name: "syst_access_account_instance_assoc_a_c_i_udx"
    )
    |> validate_common()
  end

  @spec update_changeset(
          Msdata.SystAccessAccountInstanceAssocs.t(),
          Types.access_account_instance_assoc_params()
        ) :: Ecto.Changeset.t()
  def update_changeset(access_account_instance_assoc, update_params) do
    access_account_instance_assoc
    |> cast(update_params, [
      :access_granted,
      :invitation_issued,
      :invitation_expires,
      :invitation_declined
    ])
    |> validate_common()
    |> optimistic_lock(:diag_row_version)
  end

  defp validate_common(changeset) do
    validate_required(changeset, [
      :access_account_id,
      :instance_id
    ])
  end
end
