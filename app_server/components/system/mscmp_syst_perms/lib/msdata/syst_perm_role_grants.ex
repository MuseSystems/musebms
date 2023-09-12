# Source File: syst_perm_role_grants.ex
# Location:    musebms/components/system/mscmp_syst_perms/lib/msdata/syst_perm_role_grants.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule Msdata.SystPermRoleGrants do
  @moduledoc """
  Records that grant permissions to specific roles and in specific degrees of
  authority.

  Defined in `MscmpSystPerms`.
  """

  use MscmpSystDb.Schema

  alias MscmpSystPerms.Msdata.Validators
  alias MscmpSystPerms.Types

  @schema_prefix "ms_syst"

  schema "syst_perm_role_grants" do
    field(:view_scope, :string)
    field(:maint_scope, :string)
    field(:admin_scope, :string)
    field(:ops_scope, :string)
    field(:diag_timestamp_created, :utc_datetime)
    field(:diag_role_created, :string, load_in_query: false)
    field(:diag_timestamp_modified, :utc_datetime)
    field(:diag_wallclock_modified, :utc_datetime, load_in_query: false)
    field(:diag_role_modified, :string, load_in_query: false)
    field(:diag_row_version, :integer)
    field(:diag_update_count, :integer, load_in_query: false)

    belongs_to(:perm_role, Msdata.SystPermRoles)
    belongs_to(:perm, Msdata.SystPerms)
  end

  @type t() ::
          %__MODULE__{
            __meta__: Ecto.Schema.Metadata.t(),
            id: Ecto.UUID.t() | nil,
            perm_role_id: Types.perm_role_id() | nil,
            perm_id: Types.perm_id() | nil,
            view_scope: Types.rights_scope() | nil,
            maint_scope: Types.rights_scope() | nil,
            admin_scope: Types.rights_scope() | nil,
            ops_scope: Types.rights_scope() | nil,
            diag_timestamp_created: DateTime.t() | nil,
            diag_role_created: String.t() | nil,
            diag_timestamp_modified: DateTime.t() | nil,
            diag_wallclock_modified: DateTime.t() | nil,
            diag_role_modified: String.t() | nil,
            diag_row_version: integer() | nil,
            diag_update_count: integer() | nil
          }

  @spec insert_changeset(Types.perm_role_grant_params()) :: Ecto.Changeset.t()
  defdelegate insert_changeset(insert_params), to: Validators.SystPermRoleGrants

  @spec update_changeset(Msdata.SystPermRoleGrants.t(), Types.perm_role_grant_params()) ::
          Ecto.Changeset.t()
  defdelegate update_changeset(perm_role_grant, update_params), to: Validators.SystPermRoleGrants
end
