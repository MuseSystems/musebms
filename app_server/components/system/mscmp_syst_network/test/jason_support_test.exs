# Source File: jason_support_test.exs
# Location:    musebms/app_server/components/system/mscmp_syst_network/test/jason_support_test.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule JasonSupportTest do
  use ExUnit.Case, async: true

  import MscmpSystNetwork, only: [sigil_i: 2]

  @moduletag :capture_log

  # Rather than test the Impl.JasonSupport.encode/2 function directly, we're
  # going to test via Jason module functionality.  This is more important for
  # our purposes since the only reason our function exists is to be called from
  # the Jason encoder.

  test "Can encode an IPv4 address to JSON" do
    assert "\"10.1.1.10/32\"" === Jason.encode!(~i"10.1.1.10")
    assert "\"10.1.0.0/16\"" === Jason.encode!(~i"10.1.0.0/16")
  end

  test "Can encode an IPv6 address to JSON" do
    assert "\"fd9b:77f8:714d:cabb::20/128\"" === Jason.encode!(~i"fd9b:77f8:714d:cabb::20")
    assert "\"fd9b:77f8:714d:cabb::/64\"" === Jason.encode!(~i"fd9b:77f8:714d:cabb::/64")
  end
end
