# Source File: instance_type_test.exs
# Location:    musebms/components/system/mscmp_syst_instance/test/instance_type_test.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule InstanceTypeTest do
  use InstanceMgrTestCase, async: true

  test "Can Create Instance Type" do
    create_params = %{
      internal_name: "instance_type_create",
      display_name: "Instance Type / Create",
      external_name: "Create Test",
      user_description: "Create Instance Type Test",
      user_options: %{allowed_server_pools: ["primary"]}
    }

    assert {:ok, _instance_type} = MscmpSystInstance.create_instance_type(create_params)
  end

  test "Can Update Instance Type Including Internal Name" do
    create_params = %{
      internal_name: "instance_type_upd_int_name",
      display_name: "Instance Type / Update Int Name",
      external_name: "Update Test w/Internal name",
      user_description: "Update Instance Type Test Including Internal name"
    }

    {:ok, _instance_type} = MscmpSystInstance.create_instance_type(create_params)

    update_params = %{
      internal_name: "instance_type_upd_int_name2",
      display_name: "Instance Type / Updated Int Name",
      external_name: "Updated Test w/Internal name",
      user_description: "Updated Instance Type Test Including Internal name"
    }

    assert {:ok, instance_type} =
             MscmpSystInstance.update_instance_type(
               "instance_type_upd_int_name",
               update_params
             )

    assert update_params.internal_name == instance_type.internal_name
    assert update_params.display_name == instance_type.display_name
    assert update_params.external_name == instance_type.external_name
    assert update_params.user_description == instance_type.user_description
  end

  test "Can retrieve Instance Type by Internal Name w/success tuple." do
    assert {:ok, %Msdata.SystEnumItems{internal_name: "instance_types_big"}} =
             MscmpSystInstance.get_instance_type_by_name("instance_types_big")

    assert {:ok, :not_found} = MscmpSystInstance.get_instance_type_by_name("nonexistent_type")
  end

  test "Can retrieve Instance Type by Internal Name w/raise on error." do
    assert %Msdata.SystEnumItems{internal_name: "instance_types_sml"} =
             MscmpSystInstance.get_instance_type_by_name!("instance_types_sml")

    assert MscmpSystInstance.get_instance_type_by_name!("nonexistent_type") == nil
  end

  test "Can Update Instance Type Excluding Internal Name" do
    create_params = %{
      internal_name: "instance_type_update",
      display_name: "Instance Type / Update",
      external_name: "Update Test",
      user_description: "Update Instance Type Test"
    }

    {:ok, _instance_type} = MscmpSystInstance.create_instance_type(create_params)

    update_params = %{
      display_name: "Instance Type / Updated",
      external_name: "Updated Test",
      user_description: "Updated Instance Type Test"
    }

    assert {:ok, instance_type} =
             MscmpSystInstance.update_instance_type("instance_type_update", update_params)

    assert create_params.internal_name == instance_type.internal_name
    assert update_params.display_name == instance_type.display_name
    assert update_params.external_name == instance_type.external_name
    assert update_params.user_description == instance_type.user_description
  end

  test "Can Delete Instance Type" do
    create_params = %{
      internal_name: "instance_type_delete",
      display_name: "Instance Type / Delete",
      external_name: "Delete Test",
      user_description: "Delete Instance Type Test"
    }

    {:ok, _instance_type} = MscmpSystInstance.create_instance_type(create_params)

    assert :ok = MscmpSystInstance.delete_instance_type(create_params.internal_name)

    assert is_nil(
             MscmpSystEnums.get_enum_item_by_name("instance_types", create_params.internal_name)
           )
  end
end
