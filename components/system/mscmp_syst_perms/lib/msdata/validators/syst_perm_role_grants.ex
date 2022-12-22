# Source File: syst_perm_role_grants.ex
# Location:    musebms/components/system/mscmp_syst_perms/lib/msdata/validators/syst_perm_role_grants.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystPerms.Msdata.Validators.SystPermRoleGrants do
  import Ecto.Changeset

  alias MscmpSystPerms.Types

  @moduledoc false

  # TODO:  The SystPermRoles record controls whether or not this record is also
  #        considered system defined.  Really there should be some sort of
  #        check here to see if someone is trying to insert/update into a
  #        system defined SystPermRoles record, but this seems expensive and
  #        duplicative (the database is already performing the check).
  #        We might need a way to catch the PostgreSQL raised exception and
  #        turn it into a nice Ecto.Changeset validation error.

  @spec insert_changeset(Types.syst_perm_role_grant_params()) :: Ecto.Changeset.t()
  def insert_changeset(insert_params) do
    %Msdata.SystPermRoleGrants{}
    |> cast(insert_params, [
      :perm_role_id,
      :perm_id,
      :view_scope,
      :maint_scope,
      :admin_scope,
      :ops_scope
    ])
    |> validate_required([
      :perm_role_id,
      :perm_id,
      :view_scope,
      :maint_scope,
      :admin_scope,
      :ops_scope
    ])
    |> unique_constraint([:pern_role_id, :perm_id],
      name: :syst_perm_role_grants_perm_perm_role_udx
    )
    |> foreign_key_constraint(:perm_role_id, name: :syst_perm_role_grants_perm_role_fk)
    |> foreign_key_constraint(:perm_id, name: :syst_perm_role_grants_perm_fk)
  end

  @spec update_changeset(Msdata.SystPermRoleGrants.t(), Types.syst_perm_role_grant_params()) ::
          Ecto.Changeset.t()
  def update_changeset(perm_role_grant, update_params) do
    perm_role_grant
    |> cast(update_params, [:view_scope, :maint_scope, :admin_scope, :ops_scope])
    |> validate_required([
      :perm_role_id,
      :perm_id,
      :view_scope,
      :maint_scope,
      :admin_scope,
      :ops_scope
    ])
    |> optimistic_lock(:diag_row_version)
    |> unique_constraint([:pern_role_id, :perm_id],
      name: :syst_perm_role_grants_perm_perm_role_udx
    )
    |> foreign_key_constraint(:perm_role_id, name: :syst_perm_role_grants_perm_role_fk)
    |> foreign_key_constraint(:perm_id, name: :syst_perm_role_grants_perm_fk)
  end
end