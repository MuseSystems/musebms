# Source File: instance_mgr_test_case.ex
# Location:    musebms/components/system/mscmp_syst_instance/test/support/instance_mgr_test_case.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule InstanceMgrTestCase do
  @moduledoc false

  use ExUnit.CaseTemplate

  setup do
    [
      datastore_context:
        MscmpSystDb.put_datastore_context(TestSupport.get_testing_datastore_context_id())
    ]
  end

  setup do
    MscmpSystEnums.put_enums_service(:instance_mgr)
    :ok
  end
end
