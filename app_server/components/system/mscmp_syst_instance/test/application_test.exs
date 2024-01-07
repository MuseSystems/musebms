# Source File: application_test.exs
# Location:    musebms/components/system/mscmp_syst_instance/test/application_test.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule ApplicationTest do
  use InstanceMgrTestCase, async: true

  import Ecto.Query

  alias MscmpSystInstance.Impl

  @moduletag :unit
  @moduletag :capture_log

  test "Can retrieve Application ID by Internal Name" do
    target_app_name = "app1"

    application_record =
      from(a in Msdata.SystApplications, where: a.internal_name == ^target_app_name)
      |> MscmpSystDb.one!()

    assert application_id = Impl.Application.get_application_id_by_name(target_app_name)

    assert application_record.id == application_id
  end

  test "Can get nil Application ID by nonexistent Internal Name" do
    assert Impl.Application.get_application_id_by_name("nonexistent_app") == nil
  end

  test "Can create and update Application records" do
    assert {:ok, %Msdata.SystApplications{display_name: "Test App1"} = new_app} =
             Impl.Application.create_application(%{
               internal_name: "tst_app1",
               display_name: "Test App1",
               syst_description: "Testing Application 1"
             })

    assert {:ok,
            %Msdata.SystApplications{
              display_name: "Test App One",
              syst_description: "Testing App One"
            }} =
             Impl.Application.update_application(
               new_app,
               %{
                 display_name: "Test App One",
                 syst_description: "Testing App One"
               }
             )

    assert {:ok,
            %Msdata.SystApplications{
              display_name: "Test App #1",
              syst_description: "Testing App #1"
            }} =
             Impl.Application.update_application(
               new_app.id,
               %{
                 display_name: "Test App #1",
                 syst_description: "Testing App #1"
               }
             )
  end

  test "Can get Application record without Contexts preloaded" do
    assert %Msdata.SystApplications{
             internal_name: "app1",
             application_contexts: %Ecto.Association.NotLoaded{}
           } = Impl.Application.get_application("app1", [])
  end

  test "Can get Application record with Contexts preloaded" do
    assert %Msdata.SystApplications{
             internal_name: "app1",
             application_contexts: [%Msdata.SystApplicationContexts{} | _]
           } = Impl.Application.get_application("app1", include_contexts: true)
  end
end
