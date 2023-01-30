# Source File: integration_test.exs
# Location:    musebms/components/system/mscmp_syst_perms/test/integration_test.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule IntegrationTest do
  use PermsTestCase, async: false

  import Ecto.Query

  @moduletag :integration
  @moduletag :capture_log

  # ==============================================================================================
  #
  # Topic 1: System Defined Record Data Maintenance
  #
  # ==============================================================================================

  test "Step 1.01: Validate Permission Function Type Data Maintenance" do
    func_type_id =
      from(pft in Msdata.SystPermFunctionalTypes,
        where: pft.internal_name == "func_type_2",
        select: pft.id
      )
      |> MscmpSystDb.one!()

    update_params = %{
      display_name: "Updated Func Type 2",
      user_description: "Functional Type 2 User Description"
    }

    assert {:ok, updated_record} =
             MscmpSystPerms.update_perm_functional_type(func_type_id, update_params)

    assert updated_record.display_name == update_params.display_name
    assert updated_record.user_description == update_params.user_description

    update_params_2 = %{user_description: nil}

    assert {:ok, updated_record_2} =
             MscmpSystPerms.update_perm_functional_type(func_type_id, update_params_2)

    assert updated_record_2.user_description == nil

    failure_params = %{
      internal_name: "bad_func_type_2_name",
      syst_description: "Bad Functional Type 2 System Description Update"
    }

    assert {:ok, failure_record} =
             MscmpSystPerms.update_perm_functional_type(func_type_id, failure_params)

    assert failure_record.internal_name == "func_type_2"

    # Use updated_record_2 here as a proxy for "correct" to avoid extra DB call.
    assert failure_record.syst_description == updated_record_2.syst_description

    failure_params_2 = %{display_name: nil}

    assert {:error, _} =
             MscmpSystPerms.update_perm_functional_type(func_type_id, failure_params_2)
  end

  test "Step 1.02: Validate System Defined Permission Data Maintenance" do
    perm_id =
      from(p in Msdata.SystPerms, where: p.internal_name == "perm_2", select: p.id)
      |> MscmpSystDb.one!()

    failure_func_type_id =
      from(pft in Msdata.SystPermFunctionalTypes,
        where: pft.internal_name == "func_type_2",
        select: pft.id
      )
      |> MscmpSystDb.one!()

    update_params = %{
      display_name: "Updated Permission 2",
      user_description: "Permission 2 User Description"
    }

    assert {:ok, updated_record} = MscmpSystPerms.update_perm(perm_id, update_params)

    assert updated_record.display_name == update_params.display_name
    assert updated_record.user_description == update_params.user_description

    update_params_2 = %{user_description: nil}

    assert {:ok, updated_record_2} = MscmpSystPerms.update_perm(perm_id, update_params_2)

    assert updated_record_2.user_description == nil

    failure_parms = %{display_name: nil}

    assert {:error, _} = MscmpSystPerms.update_perm(perm_id, failure_parms)

    failure_params_2 = %{internal_name: "bad_perm_2_name"}

    assert {:error, _} = MscmpSystPerms.update_perm(perm_id, failure_params_2)

    failure_parms_3 = %{perm_functional_type: failure_func_type_id}

    assert {:ok, failure_record_3} = MscmpSystPerms.update_perm(perm_id, failure_parms_3)

    # Use updated_record_2 here as a proxy for "correct" to avoid extra DB call.

    assert failure_record_3.perm_functional_type_id == updated_record_2.perm_functional_type_id

    failure_params_4 = %{syst_description: "Bad Permission Syst Description Update"}

    assert {:ok, failure_record_4} = MscmpSystPerms.update_perm(perm_id, failure_params_4)

    # Use updated_record_2 here as a proxy for "correct" to avoid extra DB call.

    assert failure_record_4.syst_description == updated_record_2.syst_description
  end

  test "Step 1.03: Validate System Defined Permission Role Data Maintenance" do
    perm_role =
      from(pr in Msdata.SystPermRoles, where: pr.internal_name == "perm_role_1")
      |> MscmpSystDb.one!()

    update_params = %{
      display_name: "Updated Perm Role 1",
      user_description: "Permission Role 1 user Description"
    }

    assert {:ok, updated_record} = MscmpSystPerms.update_perm_role(perm_role.id, update_params)

    assert update_params.display_name == updated_record.display_name
    assert update_params.user_description == updated_record.user_description

    update_params_2 = %{user_description: nil}

    assert {:ok, updated_record_2} =
             MscmpSystPerms.update_perm_role(perm_role.id, update_params_2)

    assert updated_record_2.user_description == nil

    update_params_3 = %{internal_name: "updated_perm_role_1"}

    assert {:error, _} = MscmpSystPerms.update_perm_role(perm_role.id, update_params_3)

    perm_func_type_id =
      from(pft in Msdata.SystPermFunctionalTypes,
        where: pft.internal_name == "func_type_2",
        select: pft.id
      )
      |> MscmpSystDb.one!()

    update_params_4 = %{
      perm_functional_type_id: perm_func_type_id,
      syst_defined: false,
      syst_description: "Updated Permission Role 1 Syst Description"
    }

    assert {:ok, updated_record_4} = MscmpSystPerms.update_perm_role(perm_role, update_params_4)

    assert updated_record_4.perm_functional_type_id == perm_role.perm_functional_type_id
    assert updated_record_4.syst_defined == perm_role.syst_defined
    assert updated_record_4.syst_description == perm_role.syst_description
  end

  test "Step 1.04: Validate Permission Role Record ID Look-Up" do
    perm_role_id =
      from(pr in Msdata.SystPermRoles, where: pr.internal_name == "perm_role_1", select: pr.id)
      |> MscmpSystDb.one!()

    assert ^perm_role_id = MscmpSystPerms.get_perm_role_id_by_name("func_type_1", "perm_role_1")
    assert is_nil(MscmpSystPerms.get_perm_role_id_by_name("func_type_1", "nonexistent_role"))
  end

  test "Step 1.05: Validate System Defined Permission Role Grant Data Maintenance" do
    perm_role_grant =
      from(prg in Msdata.SystPermRoleGrants,
        join: pr in assoc(prg, :perm_role),
        join: p in assoc(prg, :perm),
        where: pr.internal_name == "perm_role_1" and p.internal_name == "perm_2",
        select: prg
      )
      |> MscmpSystDb.one!()

    update_params = %{view_scope: :same_user}

    assert {:error, _} = MscmpSystPerms.update_perm_role_grant(perm_role_grant.id, update_params)

    update_params_2 = %{maint_scope: :same_user}

    assert {:error, _} =
             MscmpSystPerms.update_perm_role_grant(perm_role_grant.id, update_params_2)

    update_params_3 = %{admin_scope: :same_user}

    assert {:error, _} =
             MscmpSystPerms.update_perm_role_grant(perm_role_grant.id, update_params_3)

    update_params_4 = %{ops_scope: :same_user}

    assert {:error, _} =
             MscmpSystPerms.update_perm_role_grant(perm_role_grant.id, update_params_4)

    perm_role_id =
      from(pr in Msdata.SystPermRoles, where: pr.internal_name == "perm_role_2", select: pr.id)
      |> MscmpSystDb.one!()

    perm_id =
      from(p in Msdata.SystPerms, where: p.internal_name == "perm_1", select: p.id)
      |> MscmpSystDb.one!()

    update_params_5 = %{perm_role_id: perm_role_id, perm_id: perm_id}

    assert {:ok, updated_record_5} =
             MscmpSystPerms.update_perm_role_grant(perm_role_grant.id, update_params_5)

    assert updated_record_5.perm_role_id == perm_role_grant.perm_role_id
    assert updated_record_5.perm_id == perm_role_grant.perm_id
  end

  # ==============================================================================================
  #
  # Topic 2: User Defined Record Data Maintenance
  #
  # ==============================================================================================

  test "Step 2.XX: Create User Defined Permission Record" do
    func_type_id =
      from(pft in Msdata.SystPermFunctionalTypes,
        where: pft.internal_name == "func_type_2",
        select: pft.id
      )
      |> MscmpSystDb.one!()

    create_params = %{
      internal_name: "user_perm_1",
      display_name: "User Defined Perm 1",
      perm_functional_type_id: func_type_id,
      user_description: "User defined Permission 1 user description.",
      view_scope_options: [:all],
      maint_scope_options: [:deny, :all],
      admin_scope_options: [:deny, :same_user, :all],
      ops_scope_options: [:unused]
    }

    assert {:ok, created_record} = MscmpSystPerms.create_perm(create_params)

    assert created_record.internal_name == create_params.internal_name
    assert created_record.display_name == create_params.display_name
    assert created_record.perm_functional_type_id == create_params.perm_functional_type_id
    assert created_record.user_description == create_params.user_description

    assert created_record.view_scope_options ==
             Enum.map(create_params.view_scope_options, &Atom.to_string/1)

    assert created_record.maint_scope_options ==
             Enum.map(create_params.maint_scope_options, &Atom.to_string/1)

    assert created_record.admin_scope_options ==
             Enum.map(create_params.admin_scope_options, &Atom.to_string/1)

    assert created_record.ops_scope_options ==
             Enum.map(create_params.ops_scope_options, &Atom.to_string/1)
  end

  test "Step 2.XX: Update User Defined Permission Record" do
    perm =
      from(p in Msdata.SystPerms, where: p.internal_name == "user_perm_1")
      |> MscmpSystDb.one!()

    update_params = %{
      internal_name: "user_permission_1",
      display_name: "User Defined Permission 1",
      user_description: "User defined Permission 1 updated user description.",
      view_scope_options: [:deny, :all],
      maint_scope_options: [:deny, :same_user, :all],
      admin_scope_options: [:deny, :same_user, :all],
      ops_scope_options: [:deny, :all]
    }

    assert {:ok, updated_record} = MscmpSystPerms.update_perm(perm.id, update_params)

    assert updated_record.internal_name == update_params.internal_name
    assert updated_record.display_name == update_params.display_name
    assert updated_record.user_description == update_params.user_description

    assert updated_record.view_scope_options ==
             Enum.map(update_params.view_scope_options, &Atom.to_string/1)

    assert updated_record.maint_scope_options ==
             Enum.map(update_params.maint_scope_options, &Atom.to_string/1)

    assert updated_record.admin_scope_options ==
             Enum.map(update_params.admin_scope_options, &Atom.to_string/1)

    assert updated_record.ops_scope_options ==
             Enum.map(update_params.ops_scope_options, &Atom.to_string/1)
  end

  test "Step 2.XX: Prevent Disallowed User Defined Permission Record Maintenance" do
    perm =
      from(p in Msdata.SystPerms, where: p.internal_name == "user_permission_1")
      |> MscmpSystDb.one!()

    func_type_id =
      from(pft in Msdata.SystPermFunctionalTypes,
        where: pft.internal_name == "func_type_1",
        select: pft.id
      )
      |> MscmpSystDb.one!()

    failure_params = %{perm_functional_type_id: func_type_id}

    assert {:ok, failure_record} = MscmpSystPerms.update_perm(perm, failure_params)

    assert failure_record.perm_functional_type_id == perm.perm_functional_type_id
  end

  test "Step 2.XX: Create User Defined Permission Role Record" do
    func_type_id =
      from(pft in Msdata.SystPermFunctionalTypes,
        where: pft.internal_name == "func_type_2",
        select: pft.id
      )
      |> MscmpSystDb.one!()

    create_params = %{
      internal_name: "user_perm_role_1",
      display_name: "User Defined Perm Role 1",
      perm_functional_type_id: func_type_id,
      user_description: "User Perm Role 1 User Description"
    }

    assert {:ok, created_record} = MscmpSystPerms.create_perm_role(create_params)

    assert created_record.internal_name == create_params.internal_name
    assert created_record.display_name == create_params.display_name
    assert created_record.perm_functional_type_id == create_params.perm_functional_type_id
    assert created_record.user_description == create_params.user_description
  end

  test "Step 2.XX: Update User Defined Permission Role Record" do
    perm_role =
      from(pr in Msdata.SystPermRoles, where: pr.internal_name == "user_perm_role_1")
      |> MscmpSystDb.one!()

    update_params = %{
      internal_name: "user_permission_role_1",
      display_name: "User Defined Permission Role 1",
      user_description: "User defined Permission Role 1 updated user description."
    }

    assert {:ok, updated_record} = MscmpSystPerms.update_perm_role(perm_role.id, update_params)

    assert updated_record.internal_name == update_params.internal_name
    assert updated_record.display_name == update_params.display_name
    assert updated_record.user_description == update_params.user_description
  end

  test "Step 2.XX: Prevent Disallowed User Defined Permission Role Record Maintenance" do
    perm_role =
      from(pr in Msdata.SystPermRoles, where: pr.internal_name == "user_permission_role_1")
      |> MscmpSystDb.one!()

    func_type_id =
      from(pft in Msdata.SystPermFunctionalTypes,
        where: pft.internal_name == "func_type_1",
        select: pft.id
      )
      |> MscmpSystDb.one!()

    failure_params = %{perm_functional_type_id: func_type_id}

    assert {:ok, failure_record} = MscmpSystPerms.update_perm_role(perm_role, failure_params)

    assert failure_record.perm_functional_type_id == perm_role.perm_functional_type_id
  end

  test "Step 2.XX: Create User Defined Permission Role Grant Record" do
    perm_role_id =
      from(pr in Msdata.SystPermRoles,
        where: pr.internal_name == "user_permission_role_1",
        select: pr.id
      )
      |> MscmpSystDb.one!()

    perm_id =
      from(p in Msdata.SystPerms, where: p.internal_name == "user_permission_1", select: p.id)
      |> MscmpSystDb.one!()

    create_params = %{
      perm_role_id: perm_role_id,
      perm_id: perm_id,
      view_scope: :all,
      maint_scope: :all,
      admin_scope: :all,
      ops_scope: :all
    }

    assert {:ok, created_record} = MscmpSystPerms.create_perm_role_grant(create_params)

    assert created_record.perm_role_id == create_params.perm_role_id
    assert created_record.perm_id == create_params.perm_id
    assert created_record.view_scope == Atom.to_string(create_params.view_scope)
    assert created_record.maint_scope == Atom.to_string(create_params.maint_scope)
    assert created_record.admin_scope == Atom.to_string(create_params.admin_scope)
    assert created_record.ops_scope == Atom.to_string(create_params.ops_scope)
  end

  test "Step 2.XX: Update User Defined Permission Role Grant Record" do
    perm_role_grant =
      from(prg in Msdata.SystPermRoleGrants,
        join: pr in assoc(prg, :perm_role),
        join: p in assoc(prg, :perm),
        where:
          pr.internal_name == "user_permission_role_1" and p.internal_name == "user_permission_1",
        select: prg
      )
      |> MscmpSystDb.one!()

    # The permission below is not a very useful grant but should suffice for
    # this test without running afoul of the rule that says the `view_scope`
    # value must be equal to order greater than both `maint_scope` and
    # `admin_scope`;  this rule isn't enforced yet, but will work with the
    # data create above and that rule once it is implemented.

    update_params = %{
      view_scope: :deny,
      maint_scope: :deny,
      admin_scope: :deny,
      ops_scope: :deny
    }

    assert {:ok, updated_record} =
             MscmpSystPerms.update_perm_role_grant(perm_role_grant.id, update_params)

    assert updated_record.view_scope == Atom.to_string(update_params.view_scope)
    assert updated_record.maint_scope == Atom.to_string(update_params.maint_scope)
    assert updated_record.admin_scope == Atom.to_string(update_params.admin_scope)
    assert updated_record.ops_scope == Atom.to_string(update_params.ops_scope)
  end

  test "Step 2.XX: Prevent Disallowed User Defined Permission Role Grant Record Maintenance" do
    perm_role_grant =
      from(prg in Msdata.SystPermRoleGrants,
        join: pr in assoc(prg, :perm_role),
        join: p in assoc(prg, :perm),
        where:
          pr.internal_name == "user_permission_role_1" and p.internal_name == "user_permission_1",
        select: prg
      )
      |> MscmpSystDb.one!()

    perm_role_id =
      from(pr in Msdata.SystPermRoles, where: pr.internal_name == "perm_role_2", select: pr.id)
      |> MscmpSystDb.one!()

    perm_id =
      from(p in Msdata.SystPerms, where: p.internal_name == "perm_2", select: p.id)
      |> MscmpSystDb.one!()

    failure_params = %{
      perm_role_id: perm_role_id,
      perm_id: perm_id
    }

    assert {:ok, failure_record} =
             MscmpSystPerms.update_perm_role_grant(perm_role_grant.id, failure_params)

    assert failure_record.perm_role_id == perm_role_grant.perm_role_id
    assert failure_record.perm_id == perm_role_grant.perm_id
  end

  test "Step 2.XX: Delete User Defined Permission Role Grant Record" do
    perm_role_grant =
      from(prg in Msdata.SystPermRoleGrants,
        join: pr in assoc(prg, :perm_role),
        join: p in assoc(prg, :perm),
        where:
          pr.internal_name == "user_permission_role_1" and p.internal_name == "user_permission_1",
        select: prg
      )
      |> MscmpSystDb.one!()

    assert {:ok, :deleted} = MscmpSystPerms.delete_perm_role_grant(perm_role_grant)
    assert {:ok, :not_found} = MscmpSystPerms.delete_perm_role_grant(perm_role_grant.id)
  end

  test "Step 2.XX: Delete User Defined Permission Record" do
    perm =
      from(p in Msdata.SystPerms, where: p.internal_name == "user_permission_1")
      |> MscmpSystDb.one!()

    assert {:ok, :deleted} = MscmpSystPerms.delete_perm(perm)
    assert {:ok, :not_found} = MscmpSystPerms.delete_perm(perm.id)
  end

  test "Step 2.XX: Delete User Defined Permission Role Record" do
    perm_role =
      from(pr in Msdata.SystPermRoles, where: pr.internal_name == "user_permission_role_1")
      |> MscmpSystDb.one!()

    assert {:ok, :deleted} = MscmpSystPerms.delete_perm_role(perm_role)
    assert {:ok, :not_found} = MscmpSystPerms.delete_perm_role(perm_role.id)
  end
end
