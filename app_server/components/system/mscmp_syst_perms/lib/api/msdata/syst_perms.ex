# Source File: syst_perms.ex
# Location:    musebms/app_server/components/system/mscmp_syst_perms/lib/api/msdata/syst_perms.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule Msdata.SystPerms do
  @moduledoc """
  Definition of a system/application permission.

  Defined in `MscmpSystPerms`.
  """

  use MscmpSystDb.Schema

  import Msutils.Data, only: [common_validator_options: 1]

  alias MscmpSystPerms.Impl.Msdata.SystPerms.Validators
  alias MscmpSystPerms.Types

  require Msutils.Data

  @type t() ::
          %__MODULE__{
            __meta__: Ecto.Schema.Metadata.t(),
            id: Ecto.UUID.t() | nil,
            internal_name: Types.perm_name() | nil,
            display_name: String.t() | nil,
            perm_functional_type_id: Types.perm_functional_type_id() | nil,
            syst_defined: boolean() | nil,
            syst_description: String.t() | nil,
            user_description: String.t() | nil,
            view_scope_options: list(Types.rights_scope()) | nil,
            maint_scope_options: list(Types.rights_scope()) | nil,
            admin_scope_options: list(Types.rights_scope()) | nil,
            ops_scope_options: list(Types.rights_scope()) | nil,
            diag_timestamp_created: DateTime.t() | nil,
            diag_role_created: String.t() | nil,
            diag_timestamp_modified: DateTime.t() | nil,
            diag_wallclock_modified: DateTime.t() | nil,
            diag_role_modified: String.t() | nil,
            diag_row_version: integer() | nil,
            diag_update_count: integer() | nil
          }

  @schema_prefix "ms_syst"

  schema "syst_perms" do
    field(:internal_name, :string)
    field(:display_name, :string)
    field(:syst_defined, :boolean)
    field(:syst_description, :string)
    field(:user_description, :string)
    field(:view_scope_options, {:array, :string})
    field(:maint_scope_options, {:array, :string})
    field(:admin_scope_options, {:array, :string})
    field(:ops_scope_options, {:array, :string})
    field(:diag_timestamp_created, :utc_datetime)
    field(:diag_role_created, :string, load_in_query: false)
    field(:diag_timestamp_modified, :utc_datetime)
    field(:diag_wallclock_modified, :utc_datetime, load_in_query: false)
    field(:diag_role_modified, :string, load_in_query: false)
    field(:diag_row_version, :integer)
    field(:diag_update_count, :integer, load_in_query: false)

    belongs_to(:perm_functional_type, Msdata.SystPermFunctionalTypes)

    has_many(:perm_role_grants, Msdata.SystPermRoleGrants, foreign_key: :perm_id)
  end

  ##############################################################################
  #
  # insert_changeset
  #
  #

  @insert_changeset_opts common_validator_options([
                           :internal_name,
                           :display_name,
                           :user_description
                         ])

  @doc """
  Creates a validated `Ecto.Changeset` struct for inserting into the database.

  ## Parameters

    * `insert_params` - the initial values with which to populate the new
      record.

    * `opts` - a keyword list of options to control the validation.

  ## Options

    #{NimbleOptions.docs(@insert_changeset_opts)}
  """
  @spec insert_changeset(Types.perm_params()) :: Ecto.Changeset.t()
  @spec insert_changeset(Types.perm_params(), Keyword.t()) :: Ecto.Changeset.t()
  def insert_changeset(insert_params, opts \\ []) do
    opts = NimbleOptions.validate!(opts, @insert_changeset_opts)
    Validators.insert_changeset(insert_params, opts)
  end

  ##############################################################################
  #
  # update_changeset
  #
  #

  @update_changeset_opts common_validator_options([
                           :internal_name,
                           :display_name,
                           :user_description
                         ])
  @doc """
  Creates a validated `Ecto.Changeset` struct for updating an existing database
  record.

  ## Parameters

    * `perm` - The `Msdata.SystPerms` record to update.

    * `update_params` - the values with which to update the record.

    * `opts` - a keyword list of options to control the validation.

  ## Options

    #{NimbleOptions.docs(@update_changeset_opts)}
  """
  @spec update_changeset(Msdata.SystPerms.t(), Types.perm_params()) ::
          Ecto.Changeset.t()
  @spec update_changeset(Msdata.SystPerms.t(), Types.perm_params(), Keyword.t()) ::
          Ecto.Changeset.t()
  def update_changeset(perm, update_params, opts \\ []) do
    opts = NimbleOptions.validate!(opts, @update_changeset_opts)
    Validators.update_changeset(perm, update_params, opts)
  end
end
