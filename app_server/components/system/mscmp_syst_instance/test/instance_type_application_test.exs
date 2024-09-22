# Source File: instance_type_application_test.exs
# Location:    musebms/components/system/mscmp_syst_instance/test/instance_type_application_test.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule InstanceTypeApplicationTest do
  use InstanceMgrTestCase, async: true

  import Ecto.Query

  @moduletag :unit
  @moduletag :capture_log

  test "Can Create Instance Type Application" do
    # The test data setup should not set up any instance type application
    # records for the "instance_types_std" instance type.
    instance_type = MscmpSystEnums.get_item_by_name("instance_types", "instance_types_std")

    application_id =
      from(a in Msdata.SystApplications, where: a.internal_name == "app1", select: a.id)
      |> MscmpSystDb.one!()

    assert {:ok, _} =
             MscmpSystInstance.create_instance_type_application(
               instance_type.id,
               application_id
             )
  end

  test "Can Delete Instance Type Application" do
    # The test data setup should not set up any instance type application
    # records for the "instance_types_std" instance type.
    instance_type = MscmpSystEnums.get_item_by_name("instance_types", "instance_types_std")

    application_id =
      from(a in Msdata.SystApplications, where: a.internal_name == "app2", select: a.id)
      |> MscmpSystDb.one!()

    {:ok, instance_type_application} =
      MscmpSystInstance.create_instance_type_application(instance_type.id, application_id)

    # Delete by ID
    assert :ok = MscmpSystInstance.delete_instance_type_application(instance_type_application.id)

    {:ok, instance_type_application} =
      MscmpSystInstance.create_instance_type_application(instance_type.id, application_id)

    # Delete by Msdata.SystInstanceTypeApplications.t()
    assert :ok = MscmpSystInstance.delete_instance_type_application(instance_type_application)
  end
end
