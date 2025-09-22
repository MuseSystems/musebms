# Source File: doctests_test.exs
# Location:    musebms/app_server/components/system/mscmp_syst_service/test/doctests_test.exs
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
  @moduledoc false

  use ExUnit.Case

  @moduletag :doctest
  @moduletag :capture_log
  doctest MscmpSystService

  # The nature of this module doesn't offer up an examples since we're not
  # implementing anything here, merely giving the shape of a general "service"
  # pattern.  As such there are no applicable doctests and so we'll simply add
  # placeholder test to keep build scripts and the like happy.

  test "No doctests are applicable." do
    assert true
  end
end
