# Source File: options_file_test.exs
# Location:    musebms/components/system/msbms_syst_options/test/options_file_test.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule OptionsFileTest do
  use ExUnit.Case, async: true

  @default_path "testing_options.toml"

  test "Can get_options/1 Return Options" do
    assert {:ok, %{global_dbserver_name: "global_db"}} =
             MsbmsSystOptions.get_options(@default_path)
  end

  test "Can get_options/1 Return MscmpSystError Tuple" do
    assert {:error, %MscmpSystError{}} = MsbmsSystOptions.get_options("bad_path.toml")
  end

  test "Can get_options!/1 Return Options" do
    assert %{global_dbserver_name: "global_db"} = MsbmsSystOptions.get_options!(@default_path)
  end

  test "Does get_options!/1 Raise with Bad File" do
    assert_raise MscmpSystError, fn -> MsbmsSystOptions.get_options!("bad_path.toml") end
  end
end
