# Source File: validators.ex
# Location:    musebms/app_server/components/system/mscmp_syst_authn/lib/impl/msdata/syst_access_account_instance_assocs/validators.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystAuthn.Impl.Msdata.SystAccessAccountInstanceAssocs.Validators do
  @moduledoc false

  import Ecto.Changeset

  alias MscmpSystAuthn.Impl.Msdata.Helpers
  alias MscmpSystAuthn.Types

  ##############################################################################
  #
  # insert_changeset
  #
  #

  @spec insert_changeset(Types.access_account_instance_assoc_params()) :: Ecto.Changeset.t()
  def insert_changeset(insert_params) do
    resolved_insert_params = resolve_name_params(insert_params, :insert)

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

  ##############################################################################
  #
  # update_changeset
  #
  #

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
    |> foreign_key_constraint(:access_account_id,
      name: :syst_access_account_instance_assocs_access_accounts_fk
    )
    |> foreign_key_constraint(:instance_id,
      name: :syst_access_account_instance_assocs_instances_fk
    )
    |> unique_constraint([:access_account_id, :instance_id],
      name: :syst_access_account_instance_assoc_a_i_udx
    )
  end

  defp resolve_name_params(change_params, _operation) do
    change_params
    |> Helpers.resolve_access_account_id()
    |> Helpers.resolve_instance_id()
  end
end
