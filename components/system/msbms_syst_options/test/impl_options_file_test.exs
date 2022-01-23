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

  alias MsbmsSystOptions.Impl.OptionsFile
  alias MsbmsSystOptions.Constants

  @default_path Constants.get(:startup_options_path)

  test "Verify correct path to get_options/1 is :ok" do
    assert {:ok, _map} = OptionsFile.get_options(@default_path)
  end

  test "Verify incorrect path to get_options/1 returns :error" do
    assert {:error, _reason} = OptionsFile.get_options("bad_path.toml")
  end

end
