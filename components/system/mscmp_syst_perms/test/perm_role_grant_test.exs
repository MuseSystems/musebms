# Source File: perm_role_grant_test.exs
# Location:    musebms/components/system/mscmp_syst_perms/test/perm_role_grant_test.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule PermRoleGrantTest do
  use PermsTestCase, async: true

  import Ecto.Query

  alias MscmpSystPerms.Impl

  @moduletag :capture_log

  test "Can create new Perm Role Grant" do
    perm_role_id =
      from(pr in Msdata.SystPermRoles,
        where: pr.internal_name == "perm_role_4",
        select: pr.id
      )
      |> MscmpSystDb.one!()

    perm_id =
      from(p in Msdata.SystPerms,
        where: p.internal_name == "perm_3",
        select: p.id
      )
      |> MscmpSystDb.one!()

    insert_params = %{
      perm_role_id: perm_role_id,
      perm_id: perm_id,
      view_scope: :unused,
      maint_scope: :unused,
      admin_scope: :unused,
      ops_scope: :same_user
    }

    assert {:ok, %Msdata.SystPermRoleGrants{} = inserted_grant} =
             Impl.PermRoleGrant.create_perm_role_grant(insert_params)

    assert inserted_grant.perm_role_id == insert_params.perm_role_id
    assert inserted_grant.perm_id == insert_params.perm_id
    assert inserted_grant.view_scope == Atom.to_string(insert_params.view_scope)
    assert inserted_grant.maint_scope == Atom.to_string(insert_params.maint_scope)
    assert inserted_grant.admin_scope == Atom.to_string(insert_params.admin_scope)
    assert inserted_grant.ops_scope == Atom.to_string(insert_params.ops_scope)

    assert {:error, _} = Impl.PermRoleGrant.create_perm_role_grant(insert_params)
  end

  test "Cannot create new Perm Role Grant for Syst Defined Perm Role" do
    perm_role_id =
      from(pr in Msdata.SystPermRoles,
        where: pr.internal_name == "perm_role_2",
        select: pr.id
      )
      |> MscmpSystDb.one!()

    perm_id =
      from(p in Msdata.SystPerms,
        where: p.internal_name == "perm_2",
        select: p.id
      )
      |> MscmpSystDb.one!()

    insert_params = %{
      perm_role_id: perm_role_id,
      perm_id: perm_id,
      view_scope: :all,
      maint_scope: :all,
      admin_scope: :all,
      ops_scope: :unused
    }

    assert {:error, _} = Impl.PermRoleGrant.create_perm_role_grant(insert_params)
  end

  test "Cannot create Grant when View Scope is less than Maint Scope" do
    perm_role_id =
      from(pr in Msdata.SystPermRoles,
        where: pr.internal_name == "perm_role_3",
        select: pr.id
      )
      |> MscmpSystDb.one!()

    perm_id =
      from(p in Msdata.SystPerms,
        where: p.internal_name == "perm_6",
        select: p.id
      )
      |> MscmpSystDb.one!()

    insert_params = %{
      perm_role_id: perm_role_id,
      perm_id: perm_id,
      view_scope: :same_user,
      maint_scope: :same_group,
      admin_scope: :same_group,
      ops_scope: :unused
    }

    assert {:error, _} = Impl.PermRoleGrant.create_perm_role_grant(insert_params)
  end

  test "Cannot update Syst Defined unmaintainable fields" do
    grant_id =
      from(prg in Msdata.SystPermRoleGrants,
        join: pr in assoc(prg, :perm_role),
        join: p in assoc(prg, :perm),
        where: p.internal_name == "perm_1" and pr.internal_name == "perm_role_1",
        select: prg.id
      )
      |> MscmpSystDb.one!()

    update_params = %{ops_scope: :deny}

    assert {:error, _} = Impl.PermRoleGrant.update_perm_role_grant(grant_id, update_params)
  end

  test "Can update User Defined maintainable fields" do
    grant_id =
      from(prg in Msdata.SystPermRoleGrants,
        join: pr in assoc(prg, :perm_role),
        join: p in assoc(prg, :perm),
        where: p.internal_name == "perm_3" and pr.internal_name == "perm_role_3",
        select: prg.id
      )
      |> MscmpSystDb.one!()

    update_params = %{ops_scope: :deny}

    assert {:ok, updated_grant} =
             Impl.PermRoleGrant.update_perm_role_grant(grant_id, update_params)

    revert_parmas = %{ops_scope: :same_user}

    assert {:ok, _} = Impl.PermRoleGrant.update_perm_role_grant(updated_grant, revert_parmas)
  end

  test "Cannot update View Scope to less than Maint Scope" do
    grant =
      from(prg in Msdata.SystPermRoleGrants,
        join: pr in assoc(prg, :perm_role),
        join: p in assoc(prg, :perm),
        where: p.internal_name == "perm_6" and pr.internal_name == "perm_role_6",
        select: prg
      )
      |> MscmpSystDb.one!()

    update_params = %{view_scope: :same_group}

    assert {:error, _} = Impl.PermRoleGrant.update_perm_role_grant(grant, update_params)
  end

  test "Cannot update User Defined unmaintainable fields" do
    grant =
      from(prg in Msdata.SystPermRoleGrants,
        join: pr in assoc(prg, :perm_role),
        join: p in assoc(prg, :perm),
        where: p.internal_name == "perm_3" and pr.internal_name == "perm_role_3",
        select: prg
      )
      |> MscmpSystDb.one!()

    bad_perm_id = from(p in Msdata.SystPerms, where: p.internal_name == 'perm_4', select: p.id)

    update_params_1 = %{perm_id: bad_perm_id}

    assert {:ok, perm_updated_grant} =
             Impl.PermRoleGrant.update_perm_role_grant(grant, update_params_1)

    assert perm_updated_grant.perm_id == grant.perm_id

    bad_perm_role_id =
      from(p in Msdata.SystPermRoles, where: p.internal_name == 'perm_role_4', select: p.id)

    update_params_2 = %{perm_role_id: bad_perm_role_id}

    assert {:ok, perm_role_updated_grant} =
             Impl.PermRoleGrant.update_perm_role_grant(grant, update_params_2)

    assert perm_role_updated_grant.perm_role_id == grant.perm_role_id

    update_params_3 = %{view_scope: :same_user}

    assert {:error, _} = Impl.PermRoleGrant.update_perm_role_grant(grant, update_params_3)
  end

  test "Cannot delete Syst Defined" do
    grant_id =
      from(prg in Msdata.SystPermRoleGrants,
        join: pr in assoc(prg, :perm_role),
        join: p in assoc(prg, :perm),
        where: p.internal_name == "perm_1" and pr.internal_name == "perm_role_1",
        select: prg.id
      )
      |> MscmpSystDb.one!()

    assert {:error, _} = Impl.PermRoleGrant.delete_perm_role_grant(grant_id)
  end

  test "Can delete User Defined" do
    grant =
      from(prg in Msdata.SystPermRoleGrants,
        join: pr in assoc(prg, :perm_role),
        join: p in assoc(prg, :perm),
        where: p.internal_name == "perm_4" and pr.internal_name == "perm_role_4",
        select: prg
      )
      |> MscmpSystDb.one!()

    assert {:ok, :deleted} = Impl.PermRoleGrant.delete_perm_role_grant(grant)
    assert {:ok, :not_found} = Impl.PermRoleGrant.delete_perm_role_grant(grant.id)
  end
end
