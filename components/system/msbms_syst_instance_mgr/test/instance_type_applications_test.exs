# Source File: instance_type_applications_test.exs
# Location:    components/system/msbms_syst_instance_mgr/test/instance_type_applications_test.exs
# Project:     msbms
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https: //muse.systems

defmodule InstanceTypeApplicationsTest do
  use InstanceMgrTestCase, async: true

  test "Can List Instance Type Applications" do
    assert {:ok, [_ | _]} = MsbmsSystInstanceMgr.list_instance_type_applications()
  end

  test "Can Create Instance Type Application" do
    new_instance_type = %{
      internal_name: "inst_type_apps_test",
      display_name: "Instance Type Application Test ",
      enum_default: false,
      user_description: "Testing for Instance Type Applications",
      external_name: "Testing Type",
      user_options: %{"allowed_server_pools" => []}
    }

    {:ok, instance_type} = MsbmsSystInstanceMgr.create_instance_type(new_instance_type)

    {:ok, [application | _]} = MsbmsSystInstanceMgr.list_applications()

    assert {:ok, %MsbmsSystInstanceMgr.Data.SystInstanceTypeApplications{}} =
             MsbmsSystInstanceMgr.create_instance_type_application(
               instance_type.id,
               application.id
             )
  end

  test "Can delete Instance Type Applications" do
    new_instance_type = %{
      internal_name: "inst_type_apps_delete_test",
      display_name: "Instance Type Application Delete Test ",
      enum_default: false,
      user_description: "Testing for Instance Type Applications",
      external_name: "Testing Type",
      user_options: %{"allowed_server_pools" => []}
    }

    {:ok, instance_type} = MsbmsSystInstanceMgr.create_instance_type(new_instance_type)

    {:ok, [application | _]} = MsbmsSystInstanceMgr.list_applications()

    {:ok, new_instance_type_application} =
      MsbmsSystInstanceMgr.create_instance_type_application(instance_type.id, application.id)

    assert {:ok, _result} =
             MsbmsSystInstanceMgr.delete_instance_type_application(
               new_instance_type_application.id
             )
  end
end
