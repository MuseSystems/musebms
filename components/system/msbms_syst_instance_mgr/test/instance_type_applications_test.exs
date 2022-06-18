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

  alias MsbmsSystInstanceMgr.Data

  test "Can List Instance Type Applications" do
    assert {:ok, [_ | _]} = MsbmsSystInstanceMgr.list_instance_type_applications()
  end

  test "Can List Instance Type Applications Filtered by application_id" do
    {:ok, [application | _]} = MsbmsSystInstanceMgr.list_applications()

    assert {:ok, test_list} =
             MsbmsSystInstanceMgr.list_instance_type_applications(
               filters: [application_id: application.id]
             )

    Enum.each(test_list, fn element ->
      assert element.application_id == application.id
    end)
  end

  test "Can List Instance Type Applications Filtered by application_name" do
    {:ok, [application | _]} = MsbmsSystInstanceMgr.list_applications()

    assert {:ok, test_list} =
             MsbmsSystInstanceMgr.list_instance_type_applications(
               filters: [application_name: application.internal_name],
               sorts: [:application]
             )

    Enum.each(test_list, fn element ->
      assert element.application_id == application.id
    end)
  end

  test "Can List Instance Type Applications Filtered by instance_type_id" do
    {:ok, [instance_type | _]} = MsbmsSystInstanceMgr.list_instance_types()

    assert {:ok, test_list} =
             MsbmsSystInstanceMgr.list_instance_type_applications(
               filters: [instance_type_id: instance_type.id]
             )

    Enum.each(test_list, fn element ->
      assert element.instance_type_id == instance_type.id
    end)
  end

  test "Can List Instance Type Applications Filtered by instance_type_name" do
    {:ok, [instance_type | _]} = MsbmsSystInstanceMgr.list_instance_types()

    assert {:ok, test_list} =
             MsbmsSystInstanceMgr.list_instance_type_applications(
               filters: [instance_type_name: instance_type.internal_name]
             )

    Enum.each(test_list, fn element ->
      assert element.instance_type_id == instance_type.id
    end)
  end

  test "Can Get Instance Type Application List with Application Extra Data Only" do
    assert {:ok,
            [
              %Data.SystInstanceTypeApplications{
                application: %Data.SystApplications{},
                instance_type: %Ecto.Association.NotLoaded{},
                instance_type_contexts: %Ecto.Association.NotLoaded{}
              }
              | _
            ]} = MsbmsSystInstanceMgr.list_instance_type_applications(extra_data: [:application])
  end

  test "Can Get Instance Type Application List with Instance Type Extra Data Only" do
    assert {:ok,
            [
              %Data.SystInstanceTypeApplications{
                application: %Ecto.Association.NotLoaded{},
                instance_type: %MsbmsSystEnums.Data.SystEnumItems{},
                instance_type_contexts: %Ecto.Association.NotLoaded{}
              }
              | _
            ]} =
             MsbmsSystInstanceMgr.list_instance_type_applications(extra_data: [:instance_type])
  end

  test "Can Get Instance Type Application List with Instance Type Context Extra Data Only" do
    assert {:ok,
            [
              %Data.SystInstanceTypeApplications{
                application: %Ecto.Association.NotLoaded{},
                instance_type: %Ecto.Association.NotLoaded{},
                instance_type_contexts: [%Data.SystInstanceTypeContexts{} | _]
              }
              | _
            ]} =
             MsbmsSystInstanceMgr.list_instance_type_applications(
               extra_data: [:instance_type_contexts]
             )
  end

  test "Can Get Instance Type Application List with All Extra Data" do
    assert {:ok,
            [
              %Data.SystInstanceTypeApplications{
                application: %Data.SystApplications{},
                instance_type: %MsbmsSystEnums.Data.SystEnumItems{},
                instance_type_contexts: [%Data.SystInstanceTypeContexts{} | _]
              }
              | _
            ]} =
             MsbmsSystInstanceMgr.list_instance_type_applications(
               extra_data: [:instance_type_contexts, :application, :instance_type]
             )
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
