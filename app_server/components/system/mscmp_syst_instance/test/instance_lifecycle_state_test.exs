# Source File: instance_lifecycle_state_test.exs
# Location:    musebms/app_server/components/system/mscmp_syst_instance/test/instance_lifecycle_state_test.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule InstanceStateTest do
  @moduledoc false

  use InstanceMgrTestCase, async: true

  @moduletag :unit
  @moduletag :capture_log

  test "Can retrieve system default Instance State" do
    assert %Msdata.SystEnumItems{internal_name: "instance_lifecycle_states_sysdef_uninitialized"} =
             MscmpSystInstance.get_instance_lifecycle_state_default()
  end

  test "Can retrieve functional type default Instance State" do
    assert %Msdata.SystEnumItems{internal_name: "instance_lifecycle_states_sysdef_active"} =
             MscmpSystInstance.get_instance_lifecycle_state_default(
               :instance_lifecycle_states_active
             )
  end
end
