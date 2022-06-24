# Source File: syst_owners.ex
# Location:    components/system/msbms_syst_instance_mgr/lib/data/validators/syst_owners.ex
# Project:     msbms
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https: //muse.systems

defmodule MsbmsSystInstanceMgr.Data.Validators.SystOwners do
  import Ecto.Changeset
  import MsbmsSystUtils
  import MsbmsSystInstanceMgr.Data.Validators.General

  alias MsbmsSystInstanceMgr.Data
  alias MsbmsSystInstanceMgr.Data.Helpers
  alias MsbmsSystInstanceMgr.Types

  @moduledoc false

  @spec insert_changeset(Types.owner_params(), Keyword.t()) :: Ecto.Changeset.t()
  def insert_changeset(insert_params, opts \\ []) do
    opts = resolve_options(opts, Helpers.OptionDefaults.defaults())

    %Data.SystOwners{}
    |> cast(insert_params, [
      :internal_name,
      :display_name,
      :owner_state_id
    ])
    |> validate_required([:owner_state_id])
    |> validate_internal_name(opts)
    |> validate_display_name(opts)
  end

  @spec update_changeset(Data.SystOwners.t(), Types.owner_params(), Keyword.t()) ::
          Ecto.Changeset.t()
  def update_changeset(owner, update_params \\ %{}, opts \\ []) do
    opts = resolve_options(opts, Helpers.OptionDefaults.defaults())

    owner
    |> cast(update_params, [
      :internal_name,
      :display_name,
      :owner_state_id
    ])
    |> validate_required([:owner_state_id])
    |> validate_internal_name(opts)
    |> validate_display_name(opts)
    |> optimistic_lock(:diag_row_version)
  end
end
