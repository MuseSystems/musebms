# Source File: syst_owners.ex
# Location:    musebms/app_server/components/system/mscmp_syst_instance/lib/api/msdata/syst_owners.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule Msdata.SystOwners do
  @moduledoc """
  Data description for known instance owners.

  Defined in `MscmpSystInstance`.
  """

  use MscmpSystDb.Schema

  alias MscmpSystInstance.Impl.Msdata.SystOwners.Validators
  alias MscmpSystInstance.Types

  @type t() ::
          %__MODULE__{
            __meta__: Ecto.Schema.Metadata.t(),
            id: Ecto.UUID.t() | nil,
            internal_name: Types.owner_name() | nil,
            display_name: String.t() | nil,
            owner_state_id: Ecto.UUID.t() | nil,
            owner_state: Msdata.SystEnumItems.t() | Ecto.Association.NotLoaded.t() | nil,
            diag_timestamp_created: DateTime.t() | nil,
            diag_role_created: String.t() | nil,
            diag_timestamp_modified: DateTime.t() | nil,
            diag_wallclock_modified: DateTime.t() | nil,
            diag_role_modified: String.t() | nil,
            diag_row_version: integer() | nil,
            diag_update_count: integer() | nil
          }

  @schema_prefix "ms_syst"

  schema "syst_owners" do
    field(:internal_name, :string)
    field(:display_name, :string)
    field(:diag_timestamp_created, :utc_datetime)
    field(:diag_role_created, :string, load_in_query: false)
    field(:diag_timestamp_modified, :utc_datetime)
    field(:diag_wallclock_modified, :utc_datetime, load_in_query: false)
    field(:diag_role_modified, :string, load_in_query: false)
    field(:diag_row_version, :integer)
    field(:diag_update_count, :integer, load_in_query: false)

    belongs_to(:owner_state, Msdata.SystEnumItems)

    has_many(:instances, Msdata.SystInstances, foreign_key: :owner_id)
  end

  @spec insert_changeset(Types.owner_params(), Keyword.t()) :: Ecto.Changeset.t()
  defdelegate insert_changeset(insert_params, opts \\ []), to: Validators

  @spec update_changeset(Msdata.SystOwners.t(), Types.owner_params(), Keyword.t()) ::
          Ecto.Changeset.t()
  defdelegate update_changeset(owner, update_params \\ %{}, opts \\ []), to: Validators
end
