# Source File: doctests_test.exs
# Location:    musebms/components/system/mscmp_syst_instance/test/doctests_test.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule DoctestsTest do
  use InstanceMgrTestCase, async: true

  @moduletag :doctest
  @moduletag :capture_log

  setup_all do
    _ = MscmpSystDb.put_datastore_context(MscmpSystDb.get_testsupport_context_name())
    MscmpSystEnums.put_enums_service(MscmpSystEnums.get_testsupport_service_name())

    :ok
  end

  doctest MscmpSystInstance
end
