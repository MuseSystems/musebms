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

  test "Can retrieve Application ID by Internal Name w/success tuple" do
    target_app_name = "app2"

    application_record =
      from(a in Msdata.SystApplications, where: a.internal_name == ^target_app_name)
      |> MscmpSystDb.one!()

    assert {:ok, application_id} = MscmpSystInstance.get_application_id_by_name(target_app_name)

    assert application_record.id == application_id
  end

  test "Can retrieve Application ID by Internal Name w/raise on error" do
    target_app_name = "app1"

    application_record =
      from(a in Msdata.SystApplications, where: a.internal_name == ^target_app_name)
      |> MscmpSystDb.one!()

    assert application_id = MscmpSystInstance.get_application_id_by_name!(target_app_name)

    assert application_record.id == application_id
  end

  test "Can get not found Application ID by Internal Name result w/success tuple" do
    assert {:ok, :not_found} = MscmpSystInstance.get_application_id_by_name("nonexistent_app")
  end

  test "Can get nil Application ID by Internal Name w/raise on error" do
    assert MscmpSystInstance.get_application_id_by_name!("nonexistent_app") == nil
  end
end
