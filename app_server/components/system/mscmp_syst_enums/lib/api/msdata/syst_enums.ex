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

  import Msutils.Data, only: [common_validator_options: 1]

  alias MscmpSystEnums.Impl.Msdata.SystEnums.Validators

  require Msutils.Data

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

  ##############################################################################
  #
  # changeset
  #
  #

  @changeset_opts common_validator_options([:internal_name, :display_name, :user_description])

  @doc """
  Produces a changeset used to create or update a Enumeration record.

  The `change_params` argument defines the attributes to be used in maintaining
  an Enumerations record.  Of the allowed fields, the following are required for
  creation:

    * `internal_name` - A unique key which is intended for programmatic usage
      by the application and other applications which make use of the data.

    * `display_name` - A unique key for the purposes of presentation to users
      in user interfaces, reporting, etc.

    * `user_description` - A description of the setting including its use cases
      and any limits or restrictions.

  ## Options

    #{NimbleOptions.docs(@changeset_opts)}
  """

  @spec changeset(t()) :: Ecto.Changeset.t()
  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  @spec changeset(t(), map(), Keyword.t()) :: Ecto.Changeset.t()
  def changeset(syst_enums, change_params \\ %{}, opts \\ []) do
    opts = NimbleOptions.validate!(opts, @changeset_opts)
    Validators.changeset(syst_enums, change_params, opts)
  end
end
