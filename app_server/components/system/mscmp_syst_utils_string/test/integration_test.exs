# Source File: integration_test.exs
# Location:    musebms/app_server/components/system/mscmp_syst_utils_string/test/integration_test.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystUtilsStringTest do
  @moduledoc false

  use ExUnit.Case, async: true

  @moduletag :integration
  @moduletag :capture_log

  describe "get_random_string/2" do
    test "generates a random string of the specified length" do
      assert String.length(Msutils.String.get_random_string(10)) == 10
      assert String.length(Msutils.String.get_random_string(20)) == 20
    end

    test "generates a random string using the specified character set" do
      assert Msutils.String.get_random_string(10, :alphanum) =~ ~r/^[0-9A-Z]{10}$/
      assert Msutils.String.get_random_string(10, :mixed_alphanum) =~ ~r/^[0-9A-Za-z]{10}$/
      assert Msutils.String.get_random_string(10, :b32e) =~ ~r/^[0-9A-V]{10}$/
      assert Msutils.String.get_random_string(10, :b32c) =~ ~r/^[0-9A-HJ-KM-NP-TV-Z]{10}$/
    end
  end
end
