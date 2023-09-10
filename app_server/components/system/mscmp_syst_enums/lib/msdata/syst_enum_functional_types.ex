# Source File: syst_enum_functional_types.ex
# Location:    musebms/components/system/mscmp_syst_enums/lib/msdata/syst_enum_functional_types.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule Msdata.SystEnumFunctionalTypes do
  @moduledoc """
  The data structure defining the functional types associated with a given
  enumeration.

  Functional types allow the application behavior associated with list choices
  to be decoupled from the information conveyance that the same list of choices
  may be able to provide.  For example, the application may only need to
  recognize the difference between 'active' and 'inactive' order records as a
  status, however a user may want to see some reflection of why an order was
  made inactive, such as it was cancelled or that it was fulfilled.  In this
  case would create two entries of functional type inactive, one each for
  cancelled and fulfilled.  Functionally the application will see the same
  value, but user reporting can reflect the nuance not needed by the application
  functionality.

  Defined in `MscmpSystEnums`.
  """

  use MscmpSystDb.Schema

  import Ecto.Changeset

  alias MscmpSystEnums.Impl.ChangesetHelpers

  @type t() ::
          %__MODULE__{
            __meta__: Ecto.Schema.Metadata.t(),
            id: Ecto.UUID.t() | nil,
            internal_name: MscmpSystEnums.Types.enum_functional_type_name() | nil,
            display_name: String.t() | nil,
            external_name: String.t() | nil,
            syst_defined: boolean() | nil,
            enum_id: Ecto.UUID.t() | nil,
            enum: Msdata.SystEnums.t() | Ecto.Association.NotLoaded.t() | nil,
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

  @schema_prefix "ms_syst"

  schema "syst_enum_functional_types" do
    field(:internal_name, :string)
    field(:display_name, :string)
    field(:external_name, :string)
    field(:syst_defined, :boolean)
    field(:syst_description, :string)
    field(:user_description, :string)
    field(:diag_timestamp_created, :utc_datetime)
    field(:diag_role_created, :string, load_in_query: false)
    field(:diag_timestamp_modified, :utc_datetime)
    field(:diag_wallclock_modified, :utc_datetime, load_in_query: false)
    field(:diag_role_modified, :string, load_in_query: false)
    field(:diag_row_version, :integer)
    field(:diag_update_count, :integer, load_in_query: false)

    belongs_to(:enum, Msdata.SystEnums)
  end

  @doc false
  @spec changeset(t(), map(), Keyword.t()) :: Ecto.Changeset.t()
  def changeset(syst_enum_functional_types, change_params \\ %{}, opts \\ []) do
    opts = ChangesetHelpers.resolve_options(opts)

    syst_enum_functional_types
    |> cast(change_params, [
      :internal_name,
      :display_name,
      :external_name,
      :enum_id,
      :user_description
    ])
    |> ChangesetHelpers.validate_internal_name(opts)
    |> ChangesetHelpers.validate_display_name(opts)
    |> ChangesetHelpers.validate_enum_id()
    |> ChangesetHelpers.validate_external_name(opts)
    |> ChangesetHelpers.validate_user_description(opts)
    |> optimistic_lock(:diag_row_version)
    |> unique_constraint(:internal_name, name: :syst_enum_functional_types_internal_name_udx)
    |> unique_constraint(:display_name, name: :syst_enum_functional_types_display_name_udx)
    |> foreign_key_constraint(:enum_id, name: :syst_enum_functional_types_enum_fk)
  end
end
