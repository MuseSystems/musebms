# Source File: owner_test.exs
# Location:    musebms/components/system/msbms_syst_instance_mgr/test/owner_test.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule OwnerTest do
  use InstanceMgrTestCase, async: true

  import Ecto.Query

  alias MsbmsSystInstanceMgr.Data

  test "Can Create Owner" do
    new_owner_state = MscmpSystEnums.get_default_enum_item("owner_states")

    new_owner_params = %{
      internal_name: "create_test",
      display_name: "Owner Create Test",
      owner_state_id: new_owner_state.id
    }

    assert {:ok, new_owner} = MsbmsSystInstanceMgr.create_owner(new_owner_params)

    assert new_owner.internal_name == new_owner_params.internal_name
    assert new_owner.display_name == new_owner_params.display_name
    assert new_owner.owner_state_id == new_owner_params.owner_state_id
  end

  test "Can Update Owner by ID" do
    new_owner_state = MscmpSystEnums.get_default_enum_item("owner_states")

    new_owner_params = %{
      internal_name: "update_test1",
      display_name: "Owner Update Test1",
      owner_state_id: new_owner_state.id
    }

    {:ok, new_owner} = MsbmsSystInstanceMgr.create_owner(new_owner_params)

    update_owner_state =
      MscmpSystEnums.get_default_enum_item(
        "owner_states",
        functional_type_name: "owner_states_suspended"
      )

    update_owner_params = %{
      internal_name: "updated_test1",
      display_name: "Updated owner Test1",
      owner_state_id: update_owner_state.id
    }

    assert {:ok, updated_owner} =
             MsbmsSystInstanceMgr.update_owner(new_owner.id, update_owner_params)

    assert updated_owner.internal_name == update_owner_params.internal_name
    assert updated_owner.display_name == update_owner_params.display_name
    assert updated_owner.owner_state_id == update_owner_params.owner_state_id
  end

  test "Can Update Owner by Struct" do
    new_owner_state = MscmpSystEnums.get_default_enum_item("owner_states")

    new_owner_params = %{
      internal_name: "update_test2",
      display_name: "Owner Update Test2",
      owner_state_id: new_owner_state.id
    }

    {:ok, new_owner} = MsbmsSystInstanceMgr.create_owner(new_owner_params)

    update_owner_state =
      MscmpSystEnums.get_default_enum_item(
        "owner_states",
        functional_type_name: "owner_states_suspended"
      )

    update_owner_params = %{
      internal_name: "updated_test2",
      display_name: "Updated owner Test2",
      owner_state_id: update_owner_state.id
    }

    assert {:ok, updated_owner} =
             MsbmsSystInstanceMgr.update_owner(new_owner, update_owner_params)

    assert updated_owner.internal_name == update_owner_params.internal_name
    assert updated_owner.display_name == update_owner_params.display_name
    assert updated_owner.owner_state_id == update_owner_params.owner_state_id
  end

  test "Can Purge Owner by ID" do
    new_owner_state =
      MscmpSystEnums.get_default_enum_item("owner_states",
        functional_type_name: "owner_states_purge_eligible"
      )

    new_owner_params = %{
      internal_name: "delete_test1",
      display_name: "Owner Delete Test1",
      owner_state_id: new_owner_state.id
    }

    {:ok, new_owner} = MsbmsSystInstanceMgr.create_owner(new_owner_params)

    assert :ok = MsbmsSystInstanceMgr.purge_owner(new_owner.id)
  end

  test "Can Purge Owner by Bare Struct" do
    new_owner_state =
      MscmpSystEnums.get_default_enum_item("owner_states",
        functional_type_name: "owner_states_purge_eligible"
      )

    new_owner_params = %{
      internal_name: "delete_test2",
      display_name: "Owner Delete Test2",
      owner_state_id: new_owner_state.id
    }

    {:ok, new_owner} = MsbmsSystInstanceMgr.create_owner(new_owner_params)

    assert :ok = MsbmsSystInstanceMgr.purge_owner(new_owner)
  end

  test "Can Retrieve Owner by Name" do
    owner_record =
      from(o in Data.SystOwners, limit: 1)
      |> MscmpSystDb.one!()

    assert {:ok, test_owner} = MsbmsSystInstanceMgr.get_owner_by_name(owner_record.internal_name)

    assert %Data.SystOwners{
             owner_state: %MscmpSystEnums.Data.SystEnumItems{
               functional_type: %MscmpSystEnums.Data.SystEnumFunctionalTypes{}
             }
           } = test_owner

    assert test_owner.id == owner_record.id
  end

  test "Can Retrieve Owner ID by Name" do
    owner_record =
      from(o in Data.SystOwners, limit: 1)
      |> MscmpSystDb.one!()

    assert {:ok, test_owner_id} =
             MsbmsSystInstanceMgr.get_owner_id_by_name(owner_record.internal_name)

    assert test_owner_id == owner_record.id
  end

  test "Can Purge Owner by Preloaded Struct" do
    new_owner_state =
      MscmpSystEnums.get_default_enum_item("owner_states",
        functional_type_name: "owner_states_purge_eligible"
      )

    new_owner_params = %{
      internal_name: "delete_test3",
      display_name: "Owner Delete Test3",
      owner_state_id: new_owner_state.id
    }

    {:ok, new_owner} = MsbmsSystInstanceMgr.create_owner(new_owner_params)

    assert :ok =
             from(
               o in Data.SystOwners,
               join: os in assoc(o, :owner_state),
               join: osft in assoc(os, :functional_type),
               where: o.id == ^new_owner.id,
               preload: [owner_state: {os, functional_type: osft}]
             )
             |> MscmpSystDb.one!()
             |> MsbmsSystInstanceMgr.purge_owner()
  end
end
