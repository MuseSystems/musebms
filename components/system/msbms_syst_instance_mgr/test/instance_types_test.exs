# Source File: instance_types_test.exs
# Location:    components/system/msbms_syst_instance_mgr/test/instance_types_test.exs
# Project:     msbms
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https: //muse.systems

defmodule InstanceTypesTest do
  use InstanceMgrTestCase, async: true

  test "Can List Instance Types" do
    assert {:ok, _instance_types_list} = MsbmsSystInstanceMgr.list_instance_types()
  end

  test "Can create Instance Type" do
    new_instance_type = %{
      internal_name: "can_create_instance_type",
      display_name: "Can Create Instance Type",
      enum_default: true,
      user_description: "Can Create Instance Type Description",
      external_name: "Can Create Instance Type",
      user_options: %{"allowed_server_pools" => ["primary"]}
    }

    assert {:ok, %MsbmsSystEnums.Data.SystEnumItems{internal_name: "can_create_instance_type"}} =
             MsbmsSystInstanceMgr.create_instance_type(new_instance_type)
  end

  test "Can Get Instance by Instance Internal Name" do
    assert {:ok, %MsbmsSystEnums.Data.SystEnumItems{internal_name: "instance_types_big"}} =
             MsbmsSystInstanceMgr.get_instance_type_by_name("instance_types_big")
  end

  test "Can Set Instance Type Values" do
    instance_type_changes = %{
      external_name: "Standard Instance (Changed)",
      display_name: "Instance Types / Std. Instance (Changed)"
    }

    assert {:ok,
            %MsbmsSystEnums.Data.SystEnumItems{
              internal_name: "instance_types_std",
              external_name: "Standard Instance (Changed)",
              display_name: "Instance Types / Std. Instance (Changed)"
            }} =
             MsbmsSystInstanceMgr.set_instance_type_values(
               "instance_types_std",
               instance_type_changes
             )
  end

  test "Can Delete Instance Type" do
    instance_type = %{
      internal_name: "can_delete_instance_type",
      display_name: "Can Delete Instance Type",
      enum_default: true,
      user_description: "Can Delete Instance Type Description",
      external_name: "Can Delete Instance Type",
      user_options: %{"allowed_server_pools" => ["primary"]}
    }

    {:ok, _instance_type} = MsbmsSystInstanceMgr.create_instance_type(instance_type)

    assert :ok = MsbmsSystInstanceMgr.delete_instance_type("can_delete_instance_type")
  end
end
