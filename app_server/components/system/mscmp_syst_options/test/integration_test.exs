# Source File: integration_test.exs
# Location:    musebms/app_server/components/system/mscmp_syst_options/test/integration_test.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule IntegrationTest do
  @moduledoc false

  use OptionsTestCase, async: false

  @moduletag :integration
  @moduletag :capture_log

  describe "Options File Loading and Parsing Workflow" do
    test "complete options workflow with get_options/1", %{default_options_path: path} do
      # Step 1: Load options from file
      assert {:ok, options} = MscmpSystOptions.get_options(path)
      assert is_map(options)

      # Step 2: Verify core configuration elements are present
      assert Map.has_key?(options, :global_dbserver_name)
      assert Map.has_key?(options, :global_db_password)
      assert Map.has_key?(options, :global_db_pool_size)
      assert Map.has_key?(options, :global_pepper_value)
      assert Map.has_key?(options, :available_server_pools)
      assert Map.has_key?(options, :dbserver)

      # Step 3: Verify global database server configuration workflow
      global_server_name = MscmpSystOptions.get_global_dbserver_name(options)
      assert global_server_name == "global_db"

      global_server = MscmpSystOptions.get_global_dbserver(options)
      assert %MscmpSystDb.Types.DbServer{server_name: ^global_server_name} = global_server

      # Step 4: Verify security and connection parameters
      password = MscmpSystOptions.get_global_db_password(options)
      assert is_binary(password) and byte_size(password) > 0

      pool_size = MscmpSystOptions.get_global_db_pool_size(options)
      assert is_integer(pool_size) and pool_size > 0

      pepper = MscmpSystOptions.get_global_pepper_value(options)
      assert is_binary(pepper) and byte_size(pepper) > 0

      # Step 5: Verify server pool and server listing functionality
      available_pools = MscmpSystOptions.list_available_server_pools(options)
      assert is_list(available_pools) and available_pools != []

      all_servers = MscmpSystOptions.list_dbservers(options)
      assert is_list(all_servers) and all_servers != []
      assert Enum.all?(all_servers, &match?(%MscmpSystDb.Types.DbServer{}, &1))

      # Step 6: Verify filtered server listing works
      primary_servers = MscmpSystOptions.list_dbservers(options, ["primary"])
      assert is_list(primary_servers)
      assert length(primary_servers) <= length(all_servers)

      # Step 7: Verify server lookup by name
      found_server = MscmpSystOptions.get_dbserver_by_name(options, global_server_name)
      assert %MscmpSystDb.Types.DbServer{server_name: ^global_server_name} = found_server
    end

    test "complete options workflow with get_options!/1", %{default_options_path: path} do
      # Step 1: Load options from file (exception-raising version)
      assert options = MscmpSystOptions.get_options!(path)
      assert is_map(options)

      # Step 2: Verify we can chain operations seamlessly
      global_name =
        options
        |> MscmpSystOptions.get_global_dbserver_name()

      global_server =
        options
        |> MscmpSystOptions.get_global_dbserver()

      assert global_server.server_name == global_name

      # Step 3: Verify all configuration parsing functions work together
      config_summary = %{
        global_server: MscmpSystOptions.get_global_dbserver(options),
        password: MscmpSystOptions.get_global_db_password(options),
        pool_size: MscmpSystOptions.get_global_db_pool_size(options),
        pepper: MscmpSystOptions.get_global_pepper_value(options),
        available_pools: MscmpSystOptions.list_available_server_pools(options),
        all_servers: MscmpSystOptions.list_dbservers(options),
        primary_servers: MscmpSystOptions.list_dbservers(options, ["primary"])
      }

      # Verify configuration completeness
      assert %MscmpSystDb.Types.DbServer{} = config_summary.global_server
      assert is_binary(config_summary.password)
      assert is_integer(config_summary.pool_size)
      assert is_binary(config_summary.pepper)
      assert is_list(config_summary.available_pools)
      assert is_list(config_summary.all_servers)
      assert is_list(config_summary.primary_servers)
    end

    test "error handling workflow for missing files" do
      missing_file = "nonexistent_config.toml"

      # Test graceful error handling with get_options/1
      assert {:error, error} = MscmpSystOptions.get_options(missing_file)
      assert %Mserror.OptionsError{} = error

      # Test exception raising with get_options!/1
      assert_raise Mserror.OptionsError, fn ->
        MscmpSystOptions.get_options!(missing_file)
      end
    end

    test "error handling workflow for corrupted files" do
      corrupted_file = "corrupted_config.toml"
      File.write!(corrupted_file, "invalid [[ toml }} syntax")

      on_exit(fn -> File.rm(corrupted_file) end)

      # Test graceful error handling with malformed TOML
      assert {:error, error} = MscmpSystOptions.get_options(corrupted_file)
      assert %Mserror.OptionsError{} = error

      # Test exception raising with malformed TOML
      assert_raise Mserror.OptionsError, fn ->
        MscmpSystOptions.get_options!(corrupted_file)
      end
    end
  end

  describe "Database Server Management Workflows" do
    test "server filtering and selection workflow", %{default_options_path: path} do
      {:ok, options} = MscmpSystOptions.get_options(path)

      # Step 1: Get all available pools
      all_pools = MscmpSystOptions.list_available_server_pools(options)
      assert is_list(all_pools) and all_pools != []

      # Step 2: Get all servers
      all_servers = MscmpSystOptions.list_dbservers(options)
      total_server_count = length(all_servers)

      # Step 3: Filter servers by each available pool
      for pool <- all_pools do
        pool_servers = MscmpSystOptions.list_dbservers(options, [pool])
        assert is_list(pool_servers)

        # Each pool should have at least some servers or none
        assert length(pool_servers) <= total_server_count

        # All returned servers should actually belong to the requested pool
        for server <- pool_servers do
          assert pool in server.server_pools
        end
      end

      # Step 4: Test multi-pool filtering
      if length(all_pools) >= 2 do
        [pool1, pool2 | _] = all_pools
        multi_pool_servers = MscmpSystOptions.list_dbservers(options, [pool1, pool2])

        # Should return servers belonging to either pool
        for server <- multi_pool_servers do
          assert pool1 in server.server_pools or pool2 in server.server_pools
        end
      end

      # Step 5: Test individual server lookup
      for server <- all_servers do
        found_server = MscmpSystOptions.get_dbserver_by_name(options, server.server_name)
        assert found_server == server
      end
    end

    test "global server configuration workflow", %{default_options_path: path} do
      {:ok, options} = MscmpSystOptions.get_options(path)

      # Step 1: Identify global server
      global_name = MscmpSystOptions.get_global_dbserver_name(options)
      global_server = MscmpSystOptions.get_global_dbserver(options)

      # Step 2: Verify global server is in the server list
      all_servers = MscmpSystOptions.list_dbservers(options)
      assert Enum.any?(all_servers, &(&1.server_name == global_name))

      # Step 3: Verify global server can be found by name lookup
      found_global = MscmpSystOptions.get_dbserver_by_name(options, global_name)
      assert found_global == global_server

      # Step 4: Verify global server connection details
      password = MscmpSystOptions.get_global_db_password(options)
      pool_size = MscmpSystOptions.get_global_db_pool_size(options)
      pepper = MscmpSystOptions.get_global_pepper_value(options)

      # All critical connection parameters should be available
      assert is_binary(password) and String.length(password) > 0
      assert is_integer(pool_size) and pool_size > 0
      assert is_binary(pepper) and String.length(pepper) > 0

      # Step 5: Verify server has required structural elements
      assert is_binary(global_server.server_name)
      assert is_list(global_server.server_pools)
    end
  end

  describe "Configuration Validation Workflows" do
    test "configuration completeness validation", %{default_options_path: path} do
      {:ok, options} = MscmpSystOptions.get_options(path)

      # Verify all required global configuration is present and valid
      required_configs = [
        {&MscmpSystOptions.get_global_dbserver_name/1, :binary},
        {&MscmpSystOptions.get_global_db_password/1, :binary},
        {&MscmpSystOptions.get_global_db_pool_size/1, :integer},
        {&MscmpSystOptions.get_global_pepper_value/1, :binary},
        {&MscmpSystOptions.list_available_server_pools/1, :list},
        {&MscmpSystOptions.list_dbservers/1, :list}
      ]

      for {config_func, expected_type} <- required_configs do
        result = config_func.(options)

        case expected_type do
          :binary -> assert is_binary(result) and String.length(result) > 0
          :integer -> assert is_integer(result) and result > 0
          :list -> assert is_list(result) and result != []
        end
      end

      # Verify server structure consistency
      all_servers = MscmpSystOptions.list_dbservers(options)

      for server <- all_servers do
        assert %MscmpSystDb.Types.DbServer{} = server
        assert is_binary(server.server_name) and String.length(server.server_name) > 0
        assert is_list(server.server_pools)
      end
    end

    test "cross-referential integrity validation", %{default_options_path: path} do
      {:ok, options} = MscmpSystOptions.get_options(path)

      # Step 1: Verify global server exists in server list
      global_name = MscmpSystOptions.get_global_dbserver_name(options)
      all_servers = MscmpSystOptions.list_dbservers(options)
      assert Enum.any?(all_servers, &(&1.server_name == global_name))

      # Step 2: Verify all server pools referenced by servers are in available pools
      available_pools = MscmpSystOptions.list_available_server_pools(options)

      for server <- all_servers do
        for pool <- server.server_pools do
          assert pool in available_pools,
                 "Server #{server.server_name} references pool '#{pool}' which is not in available pools"
        end
      end

      # Step 3: Verify server filtering produces consistent results
      all_server_names = MapSet.new(all_servers, & &1.server_name)

      # Union of all filtered servers should include all servers that have pools
      # Note: servers with empty server_pools will not be included in pool-filtered results
      filtered_union =
        available_pools
        |> Enum.flat_map(&MscmpSystOptions.list_dbservers(options, [&1]))
        |> MapSet.new(& &1.server_name)

      # All filtered servers should be a subset of all servers
      assert MapSet.subset?(filtered_union, all_server_names)

      # All servers with non-empty pools should be in the filtered union
      servers_with_pools =
        all_servers
        |> Enum.filter(&(&1.server_pools != []))
        |> MapSet.new(& &1.server_name)

      assert MapSet.equal?(servers_with_pools, filtered_union)
    end
  end

  describe "Edge Cases and Error Recovery" do
    test "handling of edge case configurations" do
      # Test with minimal valid configuration
      minimal_config = """
      global_dbserver_name = "minimal_server"
      global_db_password = "password"
      global_db_pool_size = 1
      global_pepper_value = "pepper"
      available_server_pools = ["default"]

      [[dbserver]]
      server_name = "minimal_server"
      server_pools = ["default"]
      """

      minimal_file = "minimal_config.toml"
      File.write!(minimal_file, minimal_config)
      on_exit(fn -> File.rm(minimal_file) end)

      assert {:ok, options} = MscmpSystOptions.get_options(minimal_file)

      # All functions should work with minimal configuration
      assert "minimal_server" = MscmpSystOptions.get_global_dbserver_name(options)
      assert %MscmpSystDb.Types.DbServer{} = MscmpSystOptions.get_global_dbserver(options)
      assert "password" = MscmpSystOptions.get_global_db_password(options)
      assert 1 = MscmpSystOptions.get_global_db_pool_size(options)
      assert "pepper" = MscmpSystOptions.get_global_pepper_value(options)
      assert ["default"] = MscmpSystOptions.list_available_server_pools(options)
      assert [_server] = MscmpSystOptions.list_dbservers(options)
    end

    test "graceful handling of parameter variations" do
      {:ok, options} = MscmpSystOptions.get_options("testing_options.toml")

      # Test empty filter list (should return all servers)
      all_servers_empty_filter = MscmpSystOptions.list_dbservers(options, [])
      all_servers_no_filter = MscmpSystOptions.list_dbservers(options)
      assert length(all_servers_empty_filter) == length(all_servers_no_filter)

      # Test nonexistent pool filter (should return empty list)
      empty_result = MscmpSystOptions.list_dbservers(options, ["nonexistent_pool"])
      assert empty_result == []

      # Test nonexistent server lookup (should return nil)
      assert nil == MscmpSystOptions.get_dbserver_by_name(options, "nonexistent_server")
    end
  end
end
