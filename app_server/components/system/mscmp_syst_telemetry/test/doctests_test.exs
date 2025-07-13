# Source File: doctests_test.exs
# Location:    musebms/app_server/components/system/mscmp_syst_telemetry/test/doctests_test.exs
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
  @moduledoc false
  use ExUnit.Case

  @moduletag :doctest
  @moduletag :capture_log

  doctest MscmpSystTelemetry

  # We need the placeholder as there is no actual testable documenation at this
  # time and finding no tests is treated as a failure.
  test "Placeholder test" do
    assert true
  end
end
