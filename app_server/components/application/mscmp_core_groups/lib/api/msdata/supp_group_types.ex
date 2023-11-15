# Source File: supp_group_types.ex
# Location:    musebms/app_server/components/application/mscmp_core_groups/lib/api/msdata/supp_group_types.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule Msdata.SuppGroupTypes do
  @moduledoc """
  Definition of Group Types which allow for both system and user defined types
  of groups which are associated with specific areas of application
  functionality (via Group Functional Type assignment).

  Defined in `MscmpCoreGroups`.
  """

  use MscmpSystDb.Schema

  alias MscmpCoreGroups.Types

  @schema_prefix "ms_appl"

  schema "supp_group_types" do
    field(:internal_name, :string)
    field(:display_name, :string)
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

    belongs_to(:functional_type, Msdata.SuppGroupFunctionalTypes)

    has_many(:group_type_items, Msdata.SuppGroupTypeItems, foreign_key: :group_type_id)
  end

  @type t() ::
          %__MODULE__{
            __meta__: Ecto.Schema.Metadata.t(),
            id: Ecto.UUID.t() | nil,
            internal_name: Types.group_functional_type_name() | nil,
            display_name: String.t() | nil,
            functional_type_id: Ecto.UUID.t() | nil,
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
