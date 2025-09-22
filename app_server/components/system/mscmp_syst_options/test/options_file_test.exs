# Source File: options_file_test.exs
# Location:    musebms/app_server/components/system/mscmp_syst_options/test/options_file_test.exs
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
  @moduledoc false

  use OptionsTestCase, async: true

  alias MscmpSystOptions.Impl.OptionsFile

  @moduletag :unit
  @moduletag :capture_log

  describe "get_options/1" do
    test "returns parsed options map when file exists", %{default_options_path: path} do
      assert {:ok, options} = OptionsFile.get_options(path)
      assert is_map(options)
      assert Map.has_key?(options, :global_dbserver_name)
      assert options.global_dbserver_name == "global_db"
    end

    test "returns error tuple when file does not exist" do
      assert {:error, _error} = OptionsFile.get_options("nonexistent_file.toml")
    end

    test "returns error tuple when file has invalid TOML syntax" do
      # Create a temporary file with invalid TOML content
      invalid_toml_path = "invalid_syntax.toml"
      File.write!(invalid_toml_path, "invalid [[ toml syntax")

      on_exit(fn -> File.rm(invalid_toml_path) end)

      assert {:error, _error} = OptionsFile.get_options(invalid_toml_path)
    end

    test "handles empty file gracefully" do
      empty_file_path = "empty.toml"
      File.write!(empty_file_path, "")

      on_exit(fn -> File.rm(empty_file_path) end)

      assert {:ok, options} = OptionsFile.get_options(empty_file_path)
      assert options == %{}
    end

    test "requires file path to be a string" do
      assert_raise FunctionClauseError, fn ->
        OptionsFile.get_options(:not_a_string)
      end
    end

    test "preserves TOML data structure and types", %{default_options_path: path} do
      assert {:ok, options} = OptionsFile.get_options(path)

      # Verify different data types are preserved
      assert is_binary(options.global_dbserver_name)
      assert is_integer(options.global_db_pool_size)
      assert is_list(options.available_server_pools)
      assert is_list(options.dbserver)
    end
  end
end
