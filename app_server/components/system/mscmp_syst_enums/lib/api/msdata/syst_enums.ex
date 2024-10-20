# Source File: syst_enums.ex
# Location:    musebms/app_server/components/system/mscmp_syst_enums/lib/api/msdata/syst_enums.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule Msdata.SystEnums do
  @moduledoc """
  The data structure defining available system enumerations (lists of values).

  Defined in `MscmpSystEnums`.
  """

  use MscmpSystDb.Schema

  alias MscmpSystEnums.Impl.Msdata.SystEnums.Validators

  @type t() ::
          %__MODULE__{
            __meta__: Ecto.Schema.Metadata.t(),
            id: Ecto.UUID.t() | nil,
            internal_name: MscmpSystEnums.Types.enum_name() | nil,
            display_name: String.t() | nil,
            syst_description: String.t() | nil,
            user_description: String.t() | nil,
            syst_defined: boolean() | nil,
            user_maintainable: boolean() | nil,
            default_syst_options: map() | nil,
            default_user_options: map() | nil,
            functional_types:
              list(Msdata.SystEnumFunctionalTypes.t())
              | Ecto.Association.NotLoaded.t()
              | nil,
            enum_items: list(Msdata.SystEnumItems.t()) | Ecto.Association.NotLoaded.t() | nil,
            diag_timestamp_created: DateTime.t() | nil,
            diag_role_created: String.t() | nil,
            diag_timestamp_modified: DateTime.t() | nil,
            diag_wallclock_modified: DateTime.t() | nil,
            diag_role_modified: String.t() | nil,
            diag_row_version: integer() | nil,
            diag_update_count: integer() | nil
          }

  @schema_prefix "ms_syst"

  schema "syst_enums" do
    field(:internal_name, :string)
    field(:display_name, :string)
    field(:syst_description, :string)
    field(:user_description, :string)
    field(:syst_defined, :boolean)
    field(:user_maintainable, :boolean)
    field(:default_syst_options, :map)
    field(:default_user_options, :map)
    field(:diag_timestamp_created, :utc_datetime)
    field(:diag_role_created, :string, load_in_query: false)
    field(:diag_timestamp_modified, :utc_datetime)
    field(:diag_wallclock_modified, :utc_datetime, load_in_query: false)
    field(:diag_role_modified, :string, load_in_query: false)
    field(:diag_row_version, :integer)
    field(:diag_update_count, :integer, load_in_query: false)

    has_many(:functional_types, Msdata.SystEnumFunctionalTypes, foreign_key: :enum_id)

    has_many(:enum_items, Msdata.SystEnumItems, foreign_key: :enum_id)
  end

  @spec changeset(t(), map(), Keyword.t()) :: Ecto.Changeset.t()
  defdelegate changeset(syst_enums, change_params \\ %{}, opts \\ []), to: Validators
end
