# Source File: perm_test.exs
# Location:    musebms/components/system/mscmp_syst_perms/test/perm_test.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule PermTest do
  use PermsTestCase, async: true

  import Ecto.Query

  alias MscmpSystPerms.Impl

  @moduletag :unit
  @moduletag :capture_log

  test "Can create new Perm" do
    perm_functional_type_id =
      from(pt in Msdata.SystPermFunctionalTypes,
        where: pt.internal_name == "func_type_2",
        select: pt.id
      )
      |> MscmpSystDb.one!()

    insert_params = %{
      internal_name: "create_perm",
      display_name: "Create Perm",
      user_description: "Create Perm Test",
      perm_functional_type_id: perm_functional_type_id,
      view_scope_options: [:deny, :same_user, :all],
      maint_scope_options: [:deny, :same_user],
      ops_scope_options: [:unused]
    }

    assert {:ok, %Msdata.SystPerms{} = inserted_perm} = Impl.Perm.create_perm(insert_params)

    assert inserted_perm.internal_name == insert_params.internal_name
    assert inserted_perm.display_name == insert_params.display_name
    assert inserted_perm.user_description == insert_params.user_description
    assert inserted_perm.perm_functional_type_id == insert_params.perm_functional_type_id
    assert inserted_perm.syst_defined == false

    assert inserted_perm.view_scope_options ==
             Enum.map(insert_params.view_scope_options, &Atom.to_string/1)

    assert inserted_perm.maint_scope_options ==
             Enum.map(insert_params.maint_scope_options, &Atom.to_string/1)

    assert inserted_perm.admin_scope_options == ["unused"]

    assert inserted_perm.ops_scope_options ==
             Enum.map(insert_params.ops_scope_options, &Atom.to_string/1)

    assert {:error, _} = Impl.Perm.create_perm(insert_params)
  end

  test "Can update Syst Defined maintainable fields" do
    perm_1 =
      from(p in Msdata.SystPerms, where: p.internal_name == "perm_1")
      |> MscmpSystDb.one!()

    update_params = %{
      display_name: "Updated Perm 1",
      user_description: "Updated Perm 1 User Description"
    }

    assert {:ok, %Msdata.SystPerms{} = updated_perm_1} =
             Impl.Perm.update_perm(perm_1.id, update_params)

    assert updated_perm_1.display_name == update_params.display_name
    assert updated_perm_1.user_description == update_params.user_description

    revert_params = %{
      display_name: perm_1.display_name,
      user_description: perm_1.user_description
    }

    assert {:ok, %Msdata.SystPerms{} = reverted_perm_1} =
             Impl.Perm.update_perm(updated_perm_1, revert_params)

    assert reverted_perm_1.display_name == revert_params.display_name
    assert reverted_perm_1.user_description == revert_params.user_description
  end

  test "Cannot update Syst Defined unmaintainable fields" do
    perm_1 =
      from(p in Msdata.SystPerms, where: p.internal_name == "perm_1")
      |> MscmpSystDb.one!()

    update_params_1 = %{
      internal_name: "updated_perm_1"
    }

    assert {:error, _} = Impl.Perm.update_perm(perm_1.id, update_params_1)

    perm_functional_type_id =
      from(pt in Msdata.SystPermFunctionalTypes,
        where: pt.internal_name == "func_type_2",
        select: pt.id
      )
      |> MscmpSystDb.one!()

    update_params_2 = %{
      perm_functional_type_id: perm_functional_type_id
    }

    assert {:ok, update_ignored_perm} = Impl.Perm.update_perm(perm_1.id, update_params_2)

    assert update_ignored_perm.perm_functional_type_id == perm_1.perm_functional_type_id

    update_params_3 = %{
      view_scope_options: [:deny, :all]
    }

    assert {:error, _} = Impl.Perm.update_perm(perm_1.id, update_params_3)
  end

  test "Can update User Defined maintainable fields" do
    perm_4 =
      from(p in Msdata.SystPerms, where: p.internal_name == "perm_4")
      |> MscmpSystDb.one!()

    update_params = %{
      internal_name: "perm_4",
      display_name: "Updated Perm Type 4",
      user_description: "Updated Perm Type 4 User Description"
    }

    assert {:ok, %Msdata.SystPerms{} = updated_perm_4} =
             Impl.Perm.update_perm(perm_4.id, update_params)

    assert updated_perm_4.internal_name == update_params.internal_name
    assert updated_perm_4.display_name == update_params.display_name
    assert updated_perm_4.user_description == update_params.user_description

    revert_params = %{
      internal_name: perm_4.internal_name,
      display_name: perm_4.display_name,
      user_description: perm_4.user_description
    }

    assert {:ok, %Msdata.SystPerms{} = reverted_perm_4} =
             Impl.Perm.update_perm(updated_perm_4, revert_params)

    assert reverted_perm_4.internal_name == revert_params.internal_name
    assert reverted_perm_4.display_name == revert_params.display_name
    assert reverted_perm_4.user_description == revert_params.user_description

    perm_functional_type_id =
      from(pt in Msdata.SystPermFunctionalTypes,
        where: pt.internal_name == "func_type_1",
        select: pt.id
      )
      |> MscmpSystDb.one!()

    failure_params = %{
      perm_functional_type_id: perm_functional_type_id
    }

    assert {:ok, update_ignored_perm} = Impl.Perm.update_perm(perm_4, failure_params)

    assert update_ignored_perm.perm_functional_type_id == perm_4.perm_functional_type_id
  end

  test "Cannot delete Syst Defined" do
    perm_1 =
      from(p in Msdata.SystPerms, where: p.internal_name == "perm_1")
      |> MscmpSystDb.one!()

    assert {:error, _} = Impl.Perm.delete_perm(perm_1)
  end

  test "Can delete User Defined" do
    perm_5 =
      from(p in Msdata.SystPerms, where: p.internal_name == "perm_5")
      |> MscmpSystDb.one!()

    assert {:ok, :deleted} = Impl.Perm.delete_perm(perm_5)
    assert {:ok, :not_found} = Impl.Perm.delete_perm(perm_5.id)
  end
end
