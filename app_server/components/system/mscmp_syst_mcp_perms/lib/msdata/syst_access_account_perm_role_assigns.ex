# Source File: syst_access_account_perm_role_assigns.ex
# Location:    musebms/app_server/components/system/mscmp_syst_mcp_perms/lib/msdata/syst_access_account_perm_role_assigns.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule Msdata.SystAccessAccountPermRoleAssigns do
  @moduledoc """
  Definition of a system/application permission.

  Defined in `MscmpSystMcpPerms`.
  """

  use MscmpSystDb.Schema

  alias MscmpSystMcpPerms.Msdata.Validators
  alias MscmpSystMcpPerms.Types

  @schema_prefix "ms_syst"

  schema "syst_access_account_perm_role_assigns" do
    field(:diag_timestamp_created, :utc_datetime)
    field(:diag_role_created, :string, load_in_query: false)
    field(:diag_timestamp_modified, :utc_datetime)
    field(:diag_wallclock_modified, :utc_datetime, load_in_query: false)
    field(:diag_role_modified, :string, load_in_query: false)
    field(:diag_row_version, :integer)
    field(:diag_update_count, :integer, load_in_query: false)

    belongs_to(:access_account, Msdata.SystAccessAccounts)
    belongs_to(:perm_role, Msdata.SystPermRoles)
  end

  @type t() ::
          %__MODULE__{
            __meta__: Ecto.Schema.Metadata.t(),
            id: Ecto.UUID.t() | nil,
            access_account_id: MscmpSystAuthn.Types.access_account_id() | nil,
            perm_role_id: MscmpSystPerms.Types.perm_role_id() | nil,
            diag_timestamp_created: DateTime.t() | nil,
            diag_role_created: String.t() | nil,
            diag_timestamp_modified: DateTime.t() | nil,
            diag_wallclock_modified: DateTime.t() | nil,
            diag_role_modified: String.t() | nil,
            diag_row_version: integer() | nil,
            diag_update_count: integer() | nil
          }

  @spec insert_changeset(Types.access_account_perm_role_params()) :: Ecto.Changeset.t()
  defdelegate insert_changeset(insert_params), to: Validators.SystAccessAccountPermRoleAssigns
end
