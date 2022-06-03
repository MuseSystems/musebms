# Source File: syst_owners.ex
# Location:    components/system/msbms_syst_instance_mgr/lib/data/syst_owners.ex
# Project:     msbms
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https: //muse.systems

defmodule MsbmsSystInstanceMgr.Data.SystOwners do
  use MsbmsSystDatastore.Schema
  import Ecto.Changeset
  import MsbmsSystInstanceMgr.Data.Validators.General
  import MsbmsSystInstanceMgr.Data.Helpers.OptionDefaults

  @moduledoc """
  Data description for known instance owners.
  """

  @type t() ::
          %__MODULE__{
            __meta__: Ecto.Schema.Metadata.t(),
            id: Ecto.UUID.t() | nil,
            internal_name: MsbmsSystInstanceMgr.Types.owner_name() | nil,
            display_name: String.t() | nil,
            owner_state_id: Ecto.UUID.t() | nil,
            owner_state:
              MsbmsSystEnums.Data.SystEnumItems.t() | Ecto.Association.NotLoaded.t() | nil,
            diag_timestamp_created: DateTime.t() | nil,
            diag_role_created: String.t() | nil,
            diag_timestamp_modified: DateTime.t() | nil,
            diag_wallclock_modified: DateTime.t() | nil,
            diag_role_modified: String.t() | nil,
            diag_row_version: integer() | nil,
            diag_update_count: integer() | nil
          }

  @schema_prefix "msbms_syst"

  schema "syst_owners" do
    field(:internal_name, :string)
    field(:display_name, :string)
    field(:diag_timestamp_created, :utc_datetime)
    field(:diag_role_created, :string)
    field(:diag_timestamp_modified, :utc_datetime)
    field(:diag_wallclock_modified, :utc_datetime)
    field(:diag_role_modified, :string)
    field(:diag_row_version, :integer)
    field(:diag_update_count, :integer)

    belongs_to(:owner_state, MsbmsSystEnums.Data.SystEnumItems)

    has_many(:instances, MsbmsSystInstanceMgr.Data.SystInstances, foreign_key: :owner_id)
  end

  @spec changeset(t(), MsbmsSystInstanceMgr.Types.owner_params(), Keyword.t()) ::
          Ecto.Changeset.t()
  def changeset(owner, change_params \\ %{}, opts \\ []) do
    opts = resolve_options(opts)

    owner
    |> cast(change_params, [
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
