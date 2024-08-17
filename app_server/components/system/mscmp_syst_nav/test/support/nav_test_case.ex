# Source File: nav_test_case.ex
# Location:    musebms/app_server/components/system/mscmp_syst_nav/test/support/nav_test_case.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule NavTestCase do
  @moduledoc false

  use ExUnit.CaseTemplate

  setup do
    [
      datastore_context:
        MscmpSystDb.put_datastore_context(
          {:via, Registry, {MscmpSystNav.TestRegistry, TestSupport.get_datastore_context_name()}}
        ),
      enums_service: MscmpSystEnums.put_enums_service(TestSupport.get_enums_service_name())
    ]
  end
end
