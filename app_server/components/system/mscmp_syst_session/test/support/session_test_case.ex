# Source File: session_test_case.ex
# Location:    musebms/components/system/mscmp_syst_session/test/support/session_test_case.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule SessionTestCase do
  @moduledoc false

  use ExUnit.CaseTemplate

  setup do
    [
      datastore_context:
        MscmpSystDb.put_datastore_context(MscmpSystDb.get_testsupport_context_name())
    ]
  end
end
