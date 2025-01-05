# Source File: impl/string_utils_test.exs
# Location:    musebms/app_server/components/system/mscmp_syst_utils/test/impl/string_utils_test.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule StringUtilsTest do
  @moduledoc false

  use ExUnit.Case, async: true

  alias MscmpSystUtils.Impl.StringUtils

  @moduletag :unit
  @moduletag :capture_log

  test "generates a random string using the specified character set" do
    Enum.each(1..50_000, fn _ ->
      length = Enum.random(10..1000)
      assert StringUtils.get_random_string(length, :alphanum) =~ ~r/^[0-9A-Z]{#{length}}$/

      assert StringUtils.get_random_string(length, :mixed_alphanum) =~
               ~r/^[0-9A-Za-z]{#{length}}$/

      assert StringUtils.get_random_string(length, :b32e) =~ ~r/^[0-9A-V]{#{length}}$/

      assert StringUtils.get_random_string(length, :b32c) =~ ~r/^[0-9A-HJ-KM-NP-TV-Z]{#{length}}$/

      assert StringUtils.get_random_string(length, ~c"ABC123") =~ ~r/^[ABC123]{#{length}}$/
    end)
  end
end
