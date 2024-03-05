# Source File: syst_interaction_categories.ex
# Location:    musebms/app_server/components/system/mscmp_syst_interaction/lib/api/msdata/syst_interaction_categories.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule Msdata.SystInteractionCategories do
  use MscmpSystDb.Schema

  @type t() :: %__MODULE__{
          __meta__: Ecto.Schema.Metadata.t(),
          id: Ecto.UUID.t() | nil,
          internal_name: String.t() | nil,
          display_name: String.t() | nil,
          syst_defined: boolean() | nil,
          syst_description: String.t() | nil,
          user_maintainable: boolean() | nil,
          user_description: String.t() | nil,
          diag_timestamp_created: DateTime.t() | nil,
          diag_role_created: String.t() | nil,
          diag_timestamp_modified: DateTime.t() | nil,
          diag_wallclock_modified: DateTime.t() | nil,
          diag_role_modified: String.t() | nil,
          diag_row_version: integer() | nil,
          diag_update_count: integer() | nil
        }

  @schema_prefix "ms_syst"

  schema "syst_interaction_categories" do
    field(:internal_name, :string)
    field(:display_name, :string)
    field(:syst_defined, :boolean)
    field(:syst_description, :string)
    field(:user_maintainable, :boolean)
    field(:user_description, :string)
    field(:diag_timestamp_created, :utc_datetime)
    field(:diag_role_created, :string, load_in_query: false)
    field(:diag_timestamp_modified, :utc_datetime)
    field(:diag_wallclock_modified, :utc_datetime, load_in_query: false)
    field(:diag_role_modified, :string, load_in_query: false)
    field(:diag_row_version, :integer)
    field(:diag_update_count, :integer, load_in_query: false)

    belongs_to(:perm, Msdata.SystPerms)

    has_many(:interaction_contexts, Msdata.SystInteractionContexts)
    has_many(:interaction_fields, Msdata.SystInteractionFields)
    has_many(:interaction_actions, Msdata.SystInteractionActions)
  end
end
