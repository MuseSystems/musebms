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
    assert {:ok, instance_types_list} = MsbmsSystInstanceMgr.list_instance_types()
  end

  test "Can create Instance Type" do
    new_instance_type = %{
      internal_name: "can_create_instance_type",
      display_name: "Can Create Instance Type",
      enum_default: true,
      user_description: "Can Create Instance Type Description",
      external_name: "Can Create Instance Type",
      user_options: %{
        datastore_contexts: [
          %{
            id: :test_datastore_context_1,
            db_pool_size: 3
          },
          %{
            id: :test_datastore_context_1,
            db_pool_size: 3
          }
        ]
      }
    }

    assert {:ok, %MsbmsSystEnums.Data.SystEnumItems{internal_name: "can_create_instance_type"}} =
             MsbmsSystInstanceMgr.create_instance_type(new_instance_type)
  end

  test "Can Get Instance by Instance Internal Name" do
    assert {:ok, %MsbmsSystEnums.Data.SystEnumItems{internal_name: "instance_types_big_instance"}} =
             MsbmsSystInstanceMgr.get_instance_type_by_name("instance_types_big_instance")
  end

  test "Can Set Instance Type Values" do
    instance_type_changes = %{
      external_name: "Standard Instance (Changed)",
      display_name: "Instance Types / Std. Instance (Changed)"
    }

    assert {:ok,
            %MsbmsSystEnums.Data.SystEnumItems{
              internal_name: "instance_types_std_instance",
              external_name: "Standard Instance (Changed)",
              display_name: "Instance Types / Std. Instance (Changed)"
            }} =
             MsbmsSystInstanceMgr.set_instance_type_values(
               "instance_types_std_instance",
               instance_type_changes
             )
  end
end
