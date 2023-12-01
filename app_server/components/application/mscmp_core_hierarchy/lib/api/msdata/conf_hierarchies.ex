# Source File: conf_hierarchies.ex
# Location:    musebms/app_server/components/application/mscmp_core_hierarchy/lib/api/msdata/conf_hierarchies.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule Msdata.ConfHierarchies do
  @moduledoc """
  Definition of Hierarchies which allow for both system and user defined
  hierarchies which are associated with specific areas of application
  functionality (via Hierarchy Type assignment).

  Defined in `MscmpCoreHierarchy`.
  """

  use MscmpSystDb.Schema

  alias MscmpCoreHierarchy.Types

  @type t() ::
          %__MODULE__{
            __meta__: Ecto.Schema.Metadata.t(),
            id: Types.hierarchy_id() | nil,
            internal_name: Types.hierarchy_name() | nil,
            display_name: String.t() | nil,
            hierarchy_type_id: Types.hierarchy_type_id() | nil,
            syst_defined: boolean() | nil,
            user_maintainable: boolean() | nil,
            structured: boolean() | nil,
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

  @schema_prefix "ms_appl"

  schema "conf_hierarchies" do
    field(:internal_name, :string)
    field(:display_name, :string)
    field(:syst_defined, :boolean)
    field(:user_maintainable, :boolean)
    field(:structured, :boolean)
    field(:syst_description, :string)
    field(:user_description, :string)
    field(:diag_timestamp_created, :utc_datetime)
    field(:diag_role_created, :string, load_in_query: false)
    field(:diag_timestamp_modified, :utc_datetime)
    field(:diag_wallclock_modified, :utc_datetime, load_in_query: false)
    field(:diag_role_modified, :string, load_in_query: false)
    field(:diag_row_version, :integer)
    field(:diag_update_count, :integer, load_in_query: false)

    belongs_to(:hierarchy_type, Msdata.SystEnumItems)

    has_many(:hierarchy_items, Msdata.ConfHierarchyItems, foreign_key: :hierarchy_id)
  end
end
