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

  import Msutils.Data, only: [common_validator_options: 1]

  alias MscmpSystEnums.Impl.Msdata.SystEnumItems.Validators

  require Msutils.Data

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

  ##############################################################################
  #
  # changeset
  #
  #

  @changeset_opts common_validator_options([
                    :internal_name,
                    :display_name,
                    :external_name,
                    :user_description
                  ])

  @doc """
  Produces a changeset used to create or update a Enum Items record.

  The `change_params` argument defines the attributes to be used in maintaining
  a Enum Items record.  Of the allowed fields, the following are required for
  creation:

    * `internal_name` - A unique key which is intended for programmatic usage
      by the application and other applications which make use of the data.

    * `display_name` - A unique key for the purposes of presentation to users
      in user interfaces, reporting, etc.

    * `external_name` - A non-unique name for the purposes of presentation to
      users in user interfaces, reporting, etc.

    * `user_description` - A description of the setting including its use cases
      and any limits or restrictions.

  ## Options

    #{NimbleOptions.docs(@changeset_opts)}
  """
  @spec changeset(t()) :: Ecto.Changeset.t()
  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  @spec changeset(t(), map(), Keyword.t()) :: Ecto.Changeset.t()
  def changeset(syst_enum_items, change_params \\ %{}, opts \\ []) do
    opts = NimbleOptions.validate!(opts, @changeset_opts)
    Validators.changeset(syst_enum_items, change_params, opts)
  end
end
