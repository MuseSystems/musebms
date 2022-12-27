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

  alias MscmpSystPerms.Impl
  alias MscmpSystPerms.Types

  @moduledoc false

  # TODO:  The SystPermRoles record controls whether or not this record is also
  #        considered system defined.  Really there should be some sort of
  #        check here to see if someone is trying to insert/update into a
  #        system defined SystPermRoles record, but this seems expensive and
  #        duplicative (the database is already performing the check).
  #        We might need a way to catch the PostgreSQL raised exception and
  #        turn it into a nice Ecto.Changeset validation error.

  @spec insert_changeset(Types.perm_role_grant_params()) :: Ecto.Changeset.t()
  def insert_changeset(insert_params) do
    resolved_insert_params = resolve_scopes(insert_params)

    %Msdata.SystPermRoleGrants{}
    |> cast(resolved_insert_params, [
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
    |> validate_view_maint_relative_scopes()
    |> unique_constraint([:pern_role_id, :perm_id],
      name: :syst_perm_role_grants_perm_perm_role_udx
    )
    |> foreign_key_constraint(:perm_role_id, name: :syst_perm_role_grants_perm_role_fk)
    |> foreign_key_constraint(:perm_id, name: :syst_perm_role_grants_perm_fk)
  end

  @spec update_changeset(Msdata.SystPermRoleGrants.t(), Types.perm_role_grant_params()) ::
          Ecto.Changeset.t()
  def update_changeset(perm_role_grant, update_params) do
    resolved_update_params = resolve_scopes(update_params)

    perm_role_grant
    |> cast(resolved_update_params, [:view_scope, :maint_scope, :admin_scope, :ops_scope])
    |> validate_required([
      :perm_role_id,
      :perm_id,
      :view_scope,
      :maint_scope,
      :admin_scope,
      :ops_scope
    ])
    |> validate_view_maint_relative_scopes()
    |> optimistic_lock(:diag_row_version)
    |> unique_constraint([:pern_role_id, :perm_id],
      name: :syst_perm_role_grants_perm_perm_role_udx
    )
    |> foreign_key_constraint(:perm_role_id, name: :syst_perm_role_grants_perm_role_fk)
    |> foreign_key_constraint(:perm_id, name: :syst_perm_role_grants_perm_fk)
  end

  defp resolve_scopes(params) do
    params
    |> Map.replace(:view_scope, Atom.to_string(params[:view_scope]))
    |> Map.replace(:maint_scope, Atom.to_string(params[:maint_scope]))
    |> Map.replace(:admin_scope, Atom.to_string(params[:admin_scope]))
    |> Map.replace(:ops_scope, Atom.to_string(params[:ops_scope]))
  end

  defp validate_view_maint_relative_scopes(changeset) do
    view_scope = get_field(changeset, :view_scope)
    maint_scope = get_field(changeset, :maint_scope)

    comparision_result = Impl.PermRoleGrant.compare_scopes(view_scope, maint_scope)

    maybe_add_view_maint_scope_error(comparision_result, changeset)
  end

  defp maybe_add_view_maint_scope_error(:lt, changeset) do
    add_error(
      changeset,
      :view_scope,
      "The View Right Scope must be equal to or larger than the Maintenance Right Scope."
    )
  end

  defp maybe_add_view_maint_scope_error(_, changeset), do: changeset
end
