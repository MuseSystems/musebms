# Source File: syst_enum_items.ex
# Location:    components/system/msbms_syst_enums/lib/data/syst_enum_items.ex
# Project:     msbms
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https: //muse.systems

defmodule MsbmsSystEnums.Data.SystEnumItems do
  use MsbmsSystDatastore.Schema
  import Ecto.Changeset
  import MsbmsSystEnums.Impl.ChangesetHelpers

  @moduledoc """
  The data structure defining individual enumerated values.
  """

  @type t() ::
          %__MODULE__{
            __meta__: Ecto.Schema.Metadata.t(),
            id: Ecto.UUID.t() | nil,
            internal_name: MsbmsSystEnums.Types.enum_item_name() | nil,
            display_name: String.t() | nil,
            external_name: String.t() | nil,
            enum_id: Ecto.UUID.t() | nil,
            enum: MsbmsSystEnums.Data.SystEnums.t() | Ecto.Association.NotLoaded.t() | nil,
            functional_type_id: Ecto.UUID.t() | nil,
            functional_type:
              MsbmsSystEnums.Data.SystEnumFunctionalTypes.t()
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

  @schema_prefix "msbms_syst"

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
    field(:diag_role_created, :string)
    field(:diag_timestamp_modified, :utc_datetime)
    field(:diag_wallclock_modified, :utc_datetime)
    field(:diag_role_modified, :string)
    field(:diag_row_version, :integer)
    field(:diag_update_count, :integer)
    belongs_to(:enum, MsbmsSystEnums.Data.SystEnums)
    belongs_to(:functional_type, MsbmsSystEnums.Data.SystEnumFunctionalTypes)
  end

  @spec changeset(t(), map(), Keyword.t()) :: Ecto.Changeset.t()
  def changeset(syst_enum_items, change_params \\ %{}, opts \\ []) do
    opts = resolve_options(opts)

    syst_enum_items
    |> cast(change_params, [
      :internal_name,
      :display_name,
      :external_name,
      :enum_default,
      :functional_type_default,
      :user_description,
      :sort_order,
      :user_options,
      :enum_id,
      :functional_type_id
    ])
    |> validate_required([:enum_default, :functional_type_default])
    |> validate_enum_id()
    |> validate_functional_type_id()
    |> validate_internal_name(opts)
    |> validate_display_name(opts)
    |> validate_external_name(opts)
    |> validate_user_description(opts)
    |> maybe_put_syst_defined()
    |> maybe_put_user_maintainable()
  end
end
