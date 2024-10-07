# Source File: doctests_test.exs
# Location:    musebms/app_server/components/system/mscmp_syst_utils_data/test/doctests_test.exs
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

  use ExUnit.Case, async: true

  @moduletag :doctest
  @moduletag :capture_log

  doctest Msutils.Data

  test "placeholder test" do
    assert true
  end
end
