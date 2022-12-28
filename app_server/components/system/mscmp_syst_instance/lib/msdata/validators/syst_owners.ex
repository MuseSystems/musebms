# Source File: syst_owners.ex
# Location:    musebms/components/system/mscmp_syst_instance/lib/msdata/validators/syst_owners.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystInstance.Msdata.Validators.SystOwners do
  import Ecto.Changeset

  alias MscmpSystInstance.Msdata.Helpers
  alias MscmpSystInstance.Msdata.Validators
  alias MscmpSystInstance.Types

  @moduledoc false

  @spec insert_changeset(Types.owner_params(), Keyword.t()) :: Ecto.Changeset.t()
  def insert_changeset(insert_params, opts \\ []) do
    opts = MscmpSystUtils.resolve_options(opts, Helpers.OptionDefaults.defaults())

    %Msdata.SystOwners{}
    |> cast(insert_params, [
      :internal_name,
      :display_name,
      :owner_state_id
    ])
    |> validate_common(opts)
  end

  @spec update_changeset(Msdata.SystOwners.t(), Types.owner_params(), Keyword.t()) ::
          Ecto.Changeset.t()
  def update_changeset(owner, update_params \\ %{}, opts \\ []) do
    opts = MscmpSystUtils.resolve_options(opts, Helpers.OptionDefaults.defaults())

    owner
    |> cast(update_params, [
      :internal_name,
      :display_name,
      :owner_state_id
    ])
    |> validate_common(opts)
    |> optimistic_lock(:diag_row_version)
  end

  defp validate_common(changeset, opts) do
    changeset
    |> validate_required([:owner_state_id])
    |> Validators.General.validate_internal_name(opts)
    |> Validators.General.validate_display_name(opts)
    |> unique_constraint(:internal_name, name: :syst_owners_internal_name_udx)
    |> unique_constraint(:display_name, name: :syst_owners_display_name_udx)
    |> foreign_key_constraint(:owner_state_id, name: :syst_owner_owner_states_fk)
  end
end
