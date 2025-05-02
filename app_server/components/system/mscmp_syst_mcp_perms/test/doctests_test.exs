# Source File: doctests_test.exs
# Location:    musebms/app_server/components/system/mscmp_syst_mcp_perms/test/doctests_test.exs
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
  use McpPermsTestCase, async: true

  @moduletag :doctest
  @moduletag :capture_log

  # No doctests are actually present in this Component.
  #
  # This test is just a placeholder to ensure that we don't fail the doctests
  # when running the tests for the Component, especially when running in a
  # CI environment using the build scripts.
  #

  test "No doctests" do
    assert true
  end
end
