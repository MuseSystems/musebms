# Source File: syst_enum_functional_types.ex
# Location:    musebms/app_server/components/system/mscmp_syst_enums/lib/api/msdata/syst_enum_functional_types.ex
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

  import Msutils.Data, only: [common_validator_options: 1]

  alias MscmpSystEnums.Impl.Msdata.SystEnumFunctionalTypes.Validators

  require Msutils.Data

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
  Produces a changeset used to create or update a Enum Functional Type record.

  The `change_params` argument defines the attributes to be used in maintaining
  an Enum Functional Type record.  Of the allowed fields, the following are
  required for creation:

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
  def changeset(syst_enum_functional_types, change_params \\ %{}, opts \\ [])

  def changeset(syst_enum_functional_types, change_params, opts) do
    opts = NimbleOptions.validate!(opts, @changeset_opts)
    Validators.changeset(syst_enum_functional_types, change_params, opts)
  end
end
