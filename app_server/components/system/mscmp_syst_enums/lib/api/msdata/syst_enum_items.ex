# Source File: syst_enum_items.ex
# Location:    musebms/app_server/components/system/mscmp_syst_enums/lib/api/msdata/syst_enum_items.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule Msdata.SystEnumItems do
  @moduledoc """
  The data structure defining individual enumerated values.

  Defined in `MscmpSystEnums`.
  """

  use MscmpSystDb.Schema

  alias MscmpSystEnums.Impl.Msdata.SystEnumItems.Validators

  @type t() ::
          %__MODULE__{
            __meta__: Ecto.Schema.Metadata.t(),
            id: Ecto.UUID.t() | nil,
            internal_name: MscmpSystEnums.Types.enum_item_name() | nil,
            display_name: String.t() | nil,
            external_name: String.t() | nil,
            enum_id: Ecto.UUID.t() | nil,
            enum: Msdata.SystEnums.t() | Ecto.Association.NotLoaded.t() | nil,
            functional_type_id: Ecto.UUID.t() | nil,
            functional_type:
              Msdata.SystEnumFunctionalTypes.t()
              | Ecto.Association.NotLoaded.t()
              | nil,
            enum_default: boolean() | nil,
            functional_type_default: boolean() | nil,
            syst_defined: boolean() | nil,
            user_maintainable: boolean() | nil,
            syst_description: String.t() | nil,
            user_description: String.t() | nil,
            sort_order: integer() | nil,
            syst_options: map() | nil,
            user_options: map() | nil,
            diag_timestamp_created: DateTime.t() | nil,
            diag_role_created: String.t() | nil,
            diag_timestamp_modified: DateTime.t() | nil,
            diag_wallclock_modified: DateTime.t() | nil,
            diag_role_modified: String.t() | nil,
            diag_row_version: integer() | nil,
            diag_update_count: integer() | nil
          }

  @schema_prefix "ms_syst"

  schema "syst_enum_items" do
    field(:internal_name, :string)
    field(:display_name, :string)
    field(:external_name, :string)
    field(:enum_default, :boolean)
    field(:functional_type_default, :boolean)
    field(:syst_defined, :boolean)
    field(:user_maintainable, :boolean)
    field(:syst_description, :string)
    field(:user_description, :string)
    field(:sort_order, :integer)
    field(:syst_options, :map)
    field(:user_options, :map)
    field(:diag_timestamp_created, :utc_datetime)
    field(:diag_role_created, :string, load_in_query: false)
    field(:diag_timestamp_modified, :utc_datetime)
    field(:diag_wallclock_modified, :utc_datetime, load_in_query: false)
    field(:diag_role_modified, :string, load_in_query: false)
    field(:diag_row_version, :integer)
    field(:diag_update_count, :integer, load_in_query: false)
    belongs_to(:enum, Msdata.SystEnums)
    belongs_to(:functional_type, Msdata.SystEnumFunctionalTypes)
  end

  @spec changeset(t(), map(), Keyword.t()) :: Ecto.Changeset.t()
  defdelegate changeset(syst_enum_items, change_params \\ %{}, opts \\ []), to: Validators
end
