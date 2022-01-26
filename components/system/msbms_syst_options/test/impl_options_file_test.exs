# Source File: options_file_test.exs
# Location:    components/system/msbms_syst_options/test/options_file_test.exs
# Project:     msbms
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https: //muse.systems

defmodule MsbmsSystOptions.Impl.OptionsFileTest do
  use ExUnit.Case

  alias MsbmsSystOptions.Constants
  alias MsbmsSystOptions.Impl.OptionsFile

  @default_path "testing_options.toml"

  test "Verify get_options/1 finds file and returns {:ok, map()} " do
    assert {:ok, map} = OptionsFile.get_options(@default_path)
    assert is_map(map)
  end

  test "Verify incorrect path passed to get_options/1 returns correct error type" do
    assert {:error, _reason = %MsbmsSystError{}} = OptionsFile.get_options("bad_path.toml")
  end

end
