# Source File: syst_access_account_instance_assocs.ex
# Location:    musebms/components/system/msbms_syst_authentication/lib/data/validators/syst_access_account_instance_assocs.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MsbmsSystAuthentication.Data.Validators.SystAccessAccountInstanceAssocs do
  import Ecto.Changeset

  alias MsbmsSystAuthentication.Data
  alias MsbmsSystAuthentication.Data.Helpers
  alias MsbmsSystAuthentication.Types

  @moduledoc false

  @spec insert_changeset(Types.access_account_instance_assoc_params()) :: Ecto.Changeset.t()
  def insert_changeset(insert_params) do
    resolved_insert_params =
      Helpers.SystAccessAccountInstanceAssocs.resolve_name_params(insert_params, :insert)

    %Data.SystAccessAccountInstanceAssocs{}
    |> cast(resolved_insert_params, [
      :access_account_id,
      :credential_type_id,
      :instance_id,
      :access_granted,
      :invitation_issued,
      :invitation_expires,
      :invitation_declined
    ])
    |> validate_required([
      :access_account_id,
      :credential_type_id,
      :instance_id
    ])
  end

  @spec update_changeset(
          Data.SystAccessAccountInstanceAssocs,
          Types.access_account_instance_assoc_params()
        ) :: Ecto.Changeset.t()
  def update_changeset(access_account_instance_assoc, update_params) do
    resolved_update_params =
      Helpers.SystAccessAccountInstanceAssocs.resolve_name_params(update_params, :update)

    access_account_instance_assoc
    |> cast(resolved_update_params, [
      :access_account_id,
      :credential_type_id,
      :instance_id,
      :access_granted,
      :invitation_issued,
      :invitation_expires,
      :invitation_declined
    ])
    |> validate_required([
      :access_account_id,
      :credential_type_id,
      :instance_id
    ])
    |> optimistic_lock(:diag_row_version)
  end
end
