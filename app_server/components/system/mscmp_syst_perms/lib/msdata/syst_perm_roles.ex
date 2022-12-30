# Source File: syst_perm_roles.ex
# Location:    musebms/components/system/mscmp_syst_perms/lib/msdata/syst_perm_roles.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule Msdata.SystPermRoles do
  use MscmpSystDb.Schema

  alias MscmpSystPerms.Msdata.Validators
  alias MscmpSystPerms.Types

  @moduledoc """
  Groups together individual permissions such that they can be sensibly granted
  to users.

  Defined in `MscmpSystPerms`.
  """

  @type t() ::
          %__MODULE__{
            __meta__: Ecto.Schema.Metadata.t(),
            id: Ecto.UUID.t() | nil,
            internal_name: Types.perm_role_name() | nil,
            display_name: String.t() | nil,
            perm_functional_type_id: Types.perm_functional_type_id() | nil,
            syst_defined: boolean() | nil,
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

  schema "syst_perm_roles" do
    field(:internal_name, :string)
    field(:display_name, :string)
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

    belongs_to(:perm_functional_type, Msdata.SystPermFunctionalTypes)

    has_many(:perm_role_grants, Msdata.SystPermRoleGrants, foreign_key: :perm_role_id)
  end

  @spec insert_changeset(Types.perm_role_params(), Keyword.t()) :: Ecto.Changeset.t()
  defdelegate insert_changeset(insert_params, opts \\ []), to: Validators.SystPermRoles

  @spec update_changeset(Msdata.SystPermRoles.t(), Types.perm_role_params(), Keyword.t()) ::
          Ecto.Changeset.t()
  defdelegate update_changeset(perm_role, update_params, opts \\ []), to: Validators.SystPermRoles
end
