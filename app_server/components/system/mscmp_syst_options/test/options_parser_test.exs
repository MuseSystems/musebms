# Source File: options_parser_test.exs
# Location:    musebms/app_server/components/system/mscmp_syst_options/test/options_parser_test.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule OptionsParserTest do
  @moduledoc false

  use OptionsTestCase, async: true

  alias MscmpSystOptions.Impl.OptionsFile
  alias MscmpSystOptions.Impl.OptionsParser

  @moduletag :unit
  @moduletag :capture_log

  setup %{default_options_path: path} do
    {:ok, options} = OptionsFile.get_options(path)
    %{options: options}
  end

  describe "get_global_dbserver_name/1" do
    test "returns global dbserver name from options", %{options: options} do
      assert "global_db" = OptionsParser.get_global_dbserver_name(options)
    end

    test "requires options to be a map" do
      assert_raise FunctionClauseError, fn ->
        OptionsParser.get_global_dbserver_name("not_a_map")
      end
    end
  end

  describe "get_global_dbserver/1" do
    test "returns global dbserver struct from options", %{options: options} do
      assert %MscmpSystDb.Types.DbServer{server_name: "global_db"} =
               OptionsParser.get_global_dbserver(options)
    end

    test "handles case when global dbserver not found" do
      options_without_global = %{
        global_dbserver_name: "nonexistent",
        dbserver: [%{server_name: "other_server"}]
      }

      assert is_nil(OptionsParser.get_global_dbserver(options_without_global))
    end
  end

  describe "get_global_db_password/1" do
    test "returns global db password from options", %{options: options} do
      assert "(eXI0BU&elq1(mvw" = OptionsParser.get_global_db_password(options)
    end

    test "requires options to be a map" do
      assert_raise FunctionClauseError, fn ->
        OptionsParser.get_global_db_password("not_a_map")
      end
    end
  end

  describe "get_global_db_pool_size/1" do
    test "returns global db pool size from options", %{options: options} do
      assert 10 = OptionsParser.get_global_db_pool_size(options)
    end

    test "requires options to be a map" do
      assert_raise FunctionClauseError, fn ->
        OptionsParser.get_global_db_pool_size("not_a_map")
      end
    end
  end

  describe "get_global_pepper_value/1" do
    test "returns global pepper value from options", %{options: options} do
      assert "jTtEdXRExP5YXHeARQ1W66lP6wDc9GyOvhFPvwnHhtc=" =
               OptionsParser.get_global_pepper_value(options)
    end

    test "requires options to be a map" do
      assert_raise FunctionClauseError, fn ->
        OptionsParser.get_global_pepper_value("not_a_map")
      end
    end
  end

  describe "list_available_server_pools/1" do
    test "returns list of available server pools", %{options: options} do
      assert ["primary", "linked", "demo", "reserved"] =
               OptionsParser.list_available_server_pools(options)
    end

    test "handles missing available_server_pools key" do
      options_without_pools = %{}
      assert is_nil(OptionsParser.list_available_server_pools(options_without_pools))
    end
  end

  describe "list_dbservers/2" do
    test "returns unfiltered dbserver list when no filters", %{options: options} do
      assert [_ | _] = dbserver_list = OptionsParser.list_dbservers(options, [])
      assert 2 = length(dbserver_list)
      assert Enum.all?(dbserver_list, &match?(%MscmpSystDb.Types.DbServer{}, &1))
    end

    test "returns filtered dbserver list when filters provided", %{options: options} do
      assert [%MscmpSystDb.Types.DbServer{server_pools: server_pools} | []] =
               OptionsParser.list_dbservers(options, ["primary"])

      assert "primary" in server_pools
    end

    test "returns empty list when no servers match filter", %{options: options} do
      assert [] = OptionsParser.list_dbservers(options, ["nonexistent_pool"])
    end

    test "handles multiple filters", %{options: options} do
      # Should return servers that match any of the provided pools
      result = OptionsParser.list_dbservers(options, ["primary", "demo"])
      assert length(result) >= 1
    end

    test "requires options to be a map" do
      assert_raise FunctionClauseError, fn ->
        OptionsParser.list_dbservers("not_a_map", [])
      end
    end
  end

  describe "get_dbserver_by_name/2" do
    test "returns dbserver struct when server found", %{options: options} do
      assert %MscmpSystDb.Types.DbServer{server_name: "global_db"} =
               OptionsParser.get_dbserver_by_name(options, "global_db")
    end

    test "returns nil when server not found", %{options: options} do
      assert is_nil(OptionsParser.get_dbserver_by_name(options, "nonexistent_server"))
    end

    test "handles empty dbserver list" do
      options_without_servers = %{dbserver: []}
      assert is_nil(OptionsParser.get_dbserver_by_name(options_without_servers, "any_server"))
    end
  end

  describe "private function behavior" do
    test "dbserver_map_to_struct converts map to struct properly" do
      # This is tested indirectly through the public functions
      # but we can verify the conversion works through get_dbserver_by_name
      options = %{
        dbserver: [
          %{
            server_name: "test_server",
            db_host: "localhost",
            db_port: 5432
          }
        ]
      }

      result = OptionsParser.get_dbserver_by_name(options, "test_server")
      assert %MscmpSystDb.Types.DbServer{} = result
      assert result.server_name == "test_server"
      assert result.db_host == "localhost"
      assert result.db_port == 5432
    end

    test "filter function correctly filters by server pools" do
      options = %{
        dbserver: [
          %{server_name: "server1", server_pools: ["primary", "backup"]},
          %{server_name: "server2", server_pools: ["demo"]},
          %{server_name: "server3", server_pools: ["primary"]}
        ]
      }

      # Should return servers 1 and 3 as they have "primary" pool
      result = OptionsParser.list_dbservers(options, ["primary"])
      assert length(result) == 2
      server_names = Enum.map(result, & &1.server_name)
      assert "server1" in server_names
      assert "server3" in server_names
      refute "server2" in server_names
    end
  end
end
