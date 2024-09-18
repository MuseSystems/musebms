# Source File: owner_test.exs
# Location:    musebms/components/system/mscmp_syst_instance/test/owner_test.exs
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

  alias MscmpSystInstance.Impl

  @moduletag :unit
  @moduletag :capture_log

  # TODO: Historically, unit testing was performed using the public API calls.
  #       while unit testing the public API helps to ensure the bare essentials
  #       are tested, it's not the final approach we've settled on.  Unit tests
  #       should exercise the internal API and integration tests should exercise
  #       the public API.  These tests were mostly written using the old way and
  #       should be converted at some point.  This only applies to the direct
  #       code being tested; incidental calls supporting the tests should remain
  #       directed to their respective public APIs,

  test "Can Create Owner" do
    new_owner_state = MscmpSystEnums.get_default_enum_item("owner_states")

    new_owner_params = %{
      internal_name: "create_test",
      display_name: "Owner Create Test",
      owner_state_id: new_owner_state.id
    }

    assert {:ok, new_owner} = MscmpSystInstance.create_owner(new_owner_params)

    assert new_owner.internal_name == new_owner_params.internal_name
    assert new_owner.display_name == new_owner_params.display_name
    assert new_owner.owner_state_id == new_owner_params.owner_state_id
  end

  test "Can retrieve Owner State by Internal Name" do
    assert %Msdata.SystEnumItems{internal_name: "owner_states_sysdef_active"} =
             MscmpSystInstance.get_owner_state_by_name("owner_states_sysdef_active")
  end

  test "Can retrieve system default Owner State" do
    assert %Msdata.SystEnumItems{internal_name: "owner_states_sysdef_active"} =
             MscmpSystInstance.get_owner_state_default()
  end

  test "Can retrieve functional type default Owner State" do
    assert %Msdata.SystEnumItems{internal_name: "owner_states_sysdef_inactive"} =
             MscmpSystInstance.get_owner_state_default(:owner_states_inactive)
  end

  test "Can Update Owner by ID" do
    new_owner_state = MscmpSystEnums.get_default_enum_item("owner_states")

    new_owner_params = %{
      internal_name: "update_test1",
      display_name: "Owner Update Test1",
      owner_state_id: new_owner_state.id
    }

    {:ok, new_owner} = MscmpSystInstance.create_owner(new_owner_params)

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
             MscmpSystInstance.update_owner(new_owner.id, update_owner_params)

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

    {:ok, new_owner} = MscmpSystInstance.create_owner(new_owner_params)

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

    assert {:ok, updated_owner} = MscmpSystInstance.update_owner(new_owner, update_owner_params)

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

    {:ok, new_owner} = MscmpSystInstance.create_owner(new_owner_params)

    assert :ok = MscmpSystInstance.purge_owner(new_owner.id)
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

    {:ok, new_owner} = MscmpSystInstance.create_owner(new_owner_params)

    assert :ok = MscmpSystInstance.purge_owner(new_owner)
  end

  test "Can Retrieve Owner by Name" do
    owner_record =
      from(o in Msdata.SystOwners, limit: 1)
      |> MscmpSystDb.one!()

    assert {:ok, test_owner} = MscmpSystInstance.get_owner_by_name(owner_record.internal_name)

    assert %Msdata.SystOwners{
             owner_state: %Msdata.SystEnumItems{
               functional_type: %Msdata.SystEnumFunctionalTypes{}
             }
           } = test_owner

    assert test_owner.id == owner_record.id
  end

  test "Can Retrieve Owner ID by Name" do
    owner_record =
      from(o in Msdata.SystOwners, limit: 1)
      |> MscmpSystDb.one!()

    assert {:ok, test_owner_id} =
             MscmpSystInstance.get_owner_id_by_name(owner_record.internal_name)

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

    {:ok, new_owner} = MscmpSystInstance.create_owner(new_owner_params)

    assert :ok =
             from(
               o in Msdata.SystOwners,
               join: os in assoc(o, :owner_state),
               join: osft in assoc(os, :functional_type),
               where: o.id == ^new_owner.id,
               preload: [owner_state: {os, functional_type: osft}]
             )
             |> MscmpSystDb.one!()
             |> MscmpSystInstance.purge_owner()
  end

  test "Can test if Owner Exists" do
    owner_record =
      from(o in Msdata.SystOwners, limit: 1)
      |> MscmpSystDb.one!()

    assert true == Impl.Owner.owners_exist?()
    assert true == Impl.Owner.owner_id_exists?(owner_record.id)
    assert true == Impl.Owner.owner_name_exists?(owner_record.internal_name)

    assert false == Impl.Owner.owner_id_exists?(Ecto.UUID.generate())
    assert false == Impl.Owner.owner_name_exists?("nonexistent_owner")
  end
end
