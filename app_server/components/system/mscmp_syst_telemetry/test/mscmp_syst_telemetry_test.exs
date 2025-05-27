# Source File: mscmp_syst_telemetry_test.exs
# Location:    musebms/app_server/components/system/mscmp_syst_telemetry/test/mscmp_syst_telemetry_test.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystTelemetryTest do
  use ExUnit.Case
  doctest MscmpSystTelemetry

  test "greets the world" do
    assert MscmpSystTelemetry.hello() == :world
  end
end
