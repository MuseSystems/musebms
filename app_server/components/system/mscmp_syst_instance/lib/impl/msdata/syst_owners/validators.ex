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

defmodule MscmpSystInstance.Impl.Msdata.SystOwners.Validators do
  @moduledoc false

  import Ecto.Changeset
  import MscmpSystInstance.Impl.Msdata.Helpers

  alias MscmpSystInstance.Impl.Msdata.GeneralValidators
  alias MscmpSystInstance.Types

  ##############################################################################
  #
  # insert_changeset
  #
  #

  @insert_changeset_opts validator_options([
                           :min_internal_name_length,
                           :max_internal_name_length,
                           :min_display_name_length,
                           :max_display_name_length
                         ])

  @spec get_insert_changeset_opts_docs() :: String.t()
  def get_insert_changeset_opts_docs, do: NimbleOptions.docs(@insert_changeset_opts)

  @spec insert_changeset(Types.owner_params()) :: Ecto.Changeset.t()
  @spec insert_changeset(Types.owner_params(), Keyword.t()) :: Ecto.Changeset.t()
  def insert_changeset(insert_params, opts \\ []) do
    opts = NimbleOptions.validate!(opts, @insert_changeset_opts)

    %Msdata.SystOwners{}
    |> cast(insert_params, [:internal_name, :display_name, :owner_state_id])
    |> validate_common(opts)
  end

  ##############################################################################
  #
  # update_changeset
  #
  #

  @update_changeset_opts validator_options([
                           :min_internal_name_length,
                           :max_internal_name_length,
                           :min_display_name_length,
                           :max_display_name_length
                         ])

  @spec get_update_changeset_opts_docs() :: String.t()
  def get_update_changeset_opts_docs, do: NimbleOptions.docs(@update_changeset_opts)

  @spec update_changeset(Msdata.SystOwners.t()) :: Ecto.Changeset.t()
  @spec update_changeset(Msdata.SystOwners.t(), Types.owner_params()) :: Ecto.Changeset.t()
  @spec update_changeset(Msdata.SystOwners.t(), Types.owner_params(), Keyword.t()) ::
          Ecto.Changeset.t()
  def update_changeset(owner, update_params \\ %{}, opts \\ []) do
    opts = NimbleOptions.validate!(opts, @update_changeset_opts)

    owner
    |> cast(update_params, [:internal_name, :display_name, :owner_state_id])
    |> validate_common(opts)
    |> optimistic_lock(:diag_row_version)
  end

  defp validate_common(changeset, opts) do
    changeset
    |> validate_required([:owner_state_id])
    |> GeneralValidators.validate_internal_name(opts)
    |> GeneralValidators.validate_display_name(opts)
    |> unique_constraint(:internal_name, name: :syst_owners_internal_name_udx)
    |> unique_constraint(:display_name, name: :syst_owners_display_name_udx)
    |> foreign_key_constraint(:owner_state_id, name: :syst_owner_owner_states_fk)
  end
end
