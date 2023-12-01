# Source File: conf_hierarchy_items.ex
# Location:    musebms/app_server/components/application/mscmp_core_hierarchy/lib/api/msdata/conf_hierarchy_items.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule Msdata.ConfHierarchyItems do
  @moduledoc """
  Defines the hierarchy levels of a referenced Hierarchy.  Modules implementing
  MscmpCoreHierarchy into their data structures are expected to conform to the
  hierarchical structure defined by these records and test for conformance prior
  to allowing their data to be used in the application.

  Defined in `MscmpCoreHierarchy`.
  """

  use MscmpSystDb.Schema

  alias MscmpCoreHierarchy.Types

  @type t() ::
          %__MODULE__{
            __meta__: Ecto.Schema.Metadata.t(),
            id: Types.hierarchy_item_id() | nil,
            internal_name: Types.hierarchy_item_name() | nil,
            display_name: String.t() | nil,
            external_name: String.t() | nil,
            hierarchy_id: Types.hierarchy_id() | nil,
            hierarchy_depth: integer() | nil,
            diag_timestamp_created: DateTime.t() | nil,
            diag_role_created: String.t() | nil,
            diag_timestamp_modified: DateTime.t() | nil,
            diag_wallclock_modified: DateTime.t() | nil,
            diag_role_modified: String.t() | nil,
            diag_row_version: integer() | nil,
            diag_update_count: integer() | nil
          }

  @schema_prefix "ms_appl"

  schema "conf_hierarchy_items" do
    field(:internal_name, :string)
    field(:display_name, :string)
    field(:external_name, :string)
    field(:hierarchy_depth, :integer)
    field(:diag_timestamp_created, :utc_datetime)
    field(:diag_role_created, :string, load_in_query: false)
    field(:diag_timestamp_modified, :utc_datetime)
    field(:diag_wallclock_modified, :utc_datetime, load_in_query: false)
    field(:diag_role_modified, :string, load_in_query: false)
    field(:diag_row_version, :integer)
    field(:diag_update_count, :integer, load_in_query: false)

    belongs_to(:hierarchy, Msdata.ConfHierarchies)
  end
end
