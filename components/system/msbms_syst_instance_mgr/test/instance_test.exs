# Source File: instance_test.exs
# Location:    musebms/components/system/msbms_syst_instance_mgr/test/instance_test.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule InstanceTest do
  use InstanceMgrTestCase, async: true

  import Ecto.Query

  alias MsbmsSystInstanceMgr.Data

  test "Can Retrieve Instance Record by Internal Name" do
    instance_record =
      from(i in Data.SystInstances, limit: 1)
      |> MscmpSystDb.one!()

    assert {:ok,
            %Data.SystInstances{
              instance_state: %MsbmsSystEnums.Data.SystEnumItems{
                functional_type: %MsbmsSystEnums.Data.SystEnumFunctionalTypes{}
              }
            }} = MsbmsSystInstanceMgr.get_instance_by_name(instance_record.internal_name)
  end

  test "Can Retreive Instance Record ID by Internal Name" do
    instance_record =
      from(i in Data.SystInstances, limit: 1)
      |> MscmpSystDb.one!()

    assert {:ok, test_instance_id} =
             MsbmsSystInstanceMgr.get_instance_id_by_name(instance_record.internal_name)

    assert test_instance_id == instance_record.id
  end
end
