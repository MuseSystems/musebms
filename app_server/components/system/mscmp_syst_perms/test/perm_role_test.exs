# Source File: perm_role_test.exs
# Location:    musebms/components/system/mscmp_syst_perms/test/perm_role_test.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule PermRoleTest do
  use PermsTestCase, async: true

  import Ecto.Query

  alias MscmpSystPerms.Impl

  @moduletag :capture_log

  test "Can create new Perm Role" do
    perm_functional_type_id =
      from(pt in Msdata.SystPermFunctionalTypes,
        where: pt.internal_name == "func_type_2",
        select: pt.id
      )
      |> MscmpSystDb.one!()

    insert_params = %{
      internal_name: "create_perm_role",
      display_name: "Create Perm Role",
      user_description: "Create Perm Role Test",
      perm_functional_type_id: perm_functional_type_id
    }

    assert {:ok, %Msdata.SystPermRoles{} = inserted_perm_role} =
             Impl.PermRole.create_perm_role(insert_params)

    assert inserted_perm_role.internal_name == insert_params.internal_name
    assert inserted_perm_role.display_name == insert_params.display_name
    assert inserted_perm_role.user_description == insert_params.user_description
    assert inserted_perm_role.perm_functional_type_id == insert_params.perm_functional_type_id
    assert inserted_perm_role.syst_defined == false

    assert {:error, _} = Impl.PermRole.create_perm_role(insert_params)
  end

  test "Can update Syst Defined maintainable fields" do
    perm_role_2 =
      from(p in Msdata.SystPermRoles, where: p.internal_name == "perm_role_2")
      |> MscmpSystDb.one!()

    update_params = %{
      display_name: "Updated Perm Role 2",
      user_description: "Updated Perm Role 2 User Description"
    }

    assert {:ok, %Msdata.SystPermRoles{} = updated_perm_role_2} =
             Impl.PermRole.update_perm_role(perm_role_2.id, update_params)

    assert updated_perm_role_2.display_name == update_params.display_name
    assert updated_perm_role_2.user_description == update_params.user_description

    revert_params = %{
      display_name: perm_role_2.display_name,
      user_description: perm_role_2.user_description
    }

    assert {:ok, %Msdata.SystPermRoles{} = reverted_perm_role_2} =
             Impl.PermRole.update_perm_role(updated_perm_role_2, revert_params)

    assert reverted_perm_role_2.display_name == revert_params.display_name
    assert reverted_perm_role_2.user_description == revert_params.user_description
  end

  test "Cannot update Syst Defined unmaintainable fields" do
    perm_role_1 =
      from(p in Msdata.SystPermRoles, where: p.internal_name == "perm_role_1")
      |> MscmpSystDb.one!()

    update_params_1 = %{
      internal_name: "updated_perm_role_1"
    }

    assert {:error, _} = Impl.PermRole.update_perm_role(perm_role_1.id, update_params_1)

    perm_functional_type_id =
      from(pt in Msdata.SystPermFunctionalTypes,
        where: pt.internal_name == "func_type_2",
        select: pt.id
      )
      |> MscmpSystDb.one!()

    update_params_2 = %{
      perm_functional_type_id: perm_functional_type_id
    }

    assert {:ok, update_ignored_perm_role} =
             Impl.PermRole.update_perm_role(perm_role_1.id, update_params_2)

    assert update_ignored_perm_role.perm_functional_type_id == perm_role_1.perm_functional_type_id
  end

  test "Can update User Defined maintainable fields" do
    perm_role_3 =
      from(p in Msdata.SystPermRoles, where: p.internal_name == "perm_role_3")
      |> MscmpSystDb.one!()

    update_params = %{
      internal_name: "updated_perm_role_3",
      display_name: "Updated Perm Type 3",
      user_description: "Updated Perm Type 3 User Description"
    }

    assert {:ok, %Msdata.SystPermRoles{} = updated_perm_role_3} =
             Impl.PermRole.update_perm_role(perm_role_3.id, update_params)

    assert updated_perm_role_3.internal_name == update_params.internal_name
    assert updated_perm_role_3.display_name == update_params.display_name
    assert updated_perm_role_3.user_description == update_params.user_description

    revert_params = %{
      internal_name: perm_role_3.internal_name,
      display_name: perm_role_3.display_name,
      user_description: perm_role_3.user_description
    }

    assert {:ok, %Msdata.SystPermRoles{} = reverted_perm_role_3} =
             Impl.PermRole.update_perm_role(updated_perm_role_3, revert_params)

    assert reverted_perm_role_3.internal_name == revert_params.internal_name
    assert reverted_perm_role_3.display_name == revert_params.display_name
    assert reverted_perm_role_3.user_description == revert_params.user_description

    perm_functional_type_id =
      from(pt in Msdata.SystPermFunctionalTypes,
        where: pt.internal_name == "func_type_1",
        select: pt.id
      )
      |> MscmpSystDb.one!()

    failure_params = %{
      perm_functional_type_id: perm_functional_type_id
    }

    assert {:ok, update_ignored_perm_role} =
             Impl.PermRole.update_perm_role(perm_role_3, failure_params)

    assert update_ignored_perm_role.perm_functional_type_id == perm_role_3.perm_functional_type_id
  end

  test "Cannot delete Syst Defined" do
    perm_role_1 =
      from(p in Msdata.SystPermRoles, where: p.internal_name == "perm_role_1")
      |> MscmpSystDb.one!()

    assert {:error, _} = Impl.PermRole.delete_perm_role(perm_role_1)
  end

  test "Can delete User Defined" do
    perm_5 =
      from(p in Msdata.SystPermRoles, where: p.internal_name == "perm_role_5")
      |> MscmpSystDb.one!()

    assert {:ok, :deleted} = Impl.PermRole.delete_perm_role(perm_5)
    assert {:ok, :not_found} = Impl.PermRole.delete_perm_role(perm_5.id)
  end
end
