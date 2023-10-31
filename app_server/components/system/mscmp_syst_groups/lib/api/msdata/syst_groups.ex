# Source File: syst_groups.ex
# Location:    musebms/app_server/components/system/mscmp_syst_groups/lib/api/msdata/syst_groups.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule Msdata.SystGroups do
  @moduledoc """
  Defines individual system and user defined Groups with are used for
  organization throughout the application.

  Defined in `MscmpSystGroups`.
  """

  use MscmpSystDb.Schema

  alias MscmpSystGroups.Types

  @schema_prefix "ms_syst"

  schema "syst_groups" do
    field(:internal_name, :string)
    field(:display_name, :string)
    field(:external_name, :string)
    field(:syst_defined, :boolean)
    field(:user_maintainable, :boolean)
    field(:syst_description, :string)
    field(:user_description, :string)
    field(:diag_timestamp_created, :utc_datetime)
    field(:diag_role_created, :string, load_in_query: false)
    field(:diag_timestamp_modified, :utc_datetime)
    field(:diag_wallclock_modified, :utc_datetime, load_in_query: false)
    field(:diag_role_modified, :string, load_in_query: false)
    field(:diag_row_version, :integer)
    field(:diag_update_count, :integer, load_in_query: false)

    belongs_to(:parent_group, Msdata.SystGroups)
    belongs_to(:group_type_item, Msdata.SystGroupTypeItems)

    has_many(:child_groups, Msdata.SystGroups, foreign_key: :parent_group_id)
  end

  @type t() ::
          %__MODULE__{
            __meta__: Ecto.Schema.Metadata.t(),
            id: Ecto.UUID.t() | nil,
            internal_name: Types.group_name() | nil,
            display_name: String.t() | nil,
            external_name: String.t() | nil,
            parent_group_id: Ecto.UUID.t() | nil,
            group_type_item_id: Ecto.UUID.t() | nil,
            syst_defined: boolean() | nil,
            user_maintainable: boolean() | nil,
            syst_description: String.t() | nil,
            user_description: String.t() | nil,
            diag_timestamp_created: DateTime.t() | nil,
            diag_role_created: String.t() | nil,
            diag_timestamp_modified: DateTime.t() | nil,
            diag_wallclock_modified: DateTime.t() | nil,
            diag_role_modified: String.t() | nil,
            diag_row_version: integer() | nil,
            diag_update_count: integer() | nil
          }
end
