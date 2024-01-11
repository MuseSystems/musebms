# Source File: perm_functional_type_test.exs
# Location:    musebms/components/system/mscmp_syst_perms/test/perm_functional_type_test.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule PermFunctionalTypeTest do
  use PermsTestCase, async: true

  import Ecto.Query

  alias MscmpSystPerms.Impl

  @moduletag :unit
  @moduletag :capture_log

  test "Can update maintainable fields" do
    perm_func_type_1 =
      from(pt in Msdata.SystPermFunctionalTypes, where: pt.internal_name == "func_type_2")
      |> MscmpSystDb.one!()

    update_params = %{
      display_name: "Updated Functional Type 2",
      user_description: "Updated Functional Type 2 User Description"
    }

    assert {:ok, %Msdata.SystPermFunctionalTypes{} = updated_perm_func_type_1} =
             Impl.PermFunctionalType.update_perm_functional_type(
               perm_func_type_1.id,
               update_params
             )

    assert updated_perm_func_type_1.display_name == update_params.display_name
    assert updated_perm_func_type_1.user_description == update_params.user_description

    revert_params = %{
      display_name: perm_func_type_1.display_name,
      user_description: perm_func_type_1.user_description
    }

    assert {:ok, %Msdata.SystPermFunctionalTypes{} = reverted_perm_func_type_1} =
             Impl.PermFunctionalType.update_perm_functional_type(
               updated_perm_func_type_1,
               revert_params
             )

    assert reverted_perm_func_type_1.display_name == revert_params.display_name
    assert reverted_perm_func_type_1.user_description == revert_params.user_description
  end
end
