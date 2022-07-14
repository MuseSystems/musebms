# Source File: options_parser_test.exs
# Location:    components/system/msbms_syst_options/test/options_parser_test.exs
# Project:     msbms
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https: //muse.systems

defmodule OptionsParserTest do
  use ExUnit.Case, async: true

  setup do
    {:ok, %{options: MsbmsSystOptions.get_options!("testing_options.toml")}}
  end

  test "Can Retrieve Global DbServer Name", %{options: options} do
    assert "global_db" = MsbmsSystOptions.get_global_dbserver_name(options)
  end

  test "Can Retrieve Global Database Server", %{options: options} do
    assert %{server_name: "global_db"} = MsbmsSystOptions.get_global_dbserver(options)
  end

  test "Can Retrieve Global DbServer Pepper", %{options: options} do
    assert "jTtEdXRExP5YXHeARQ1W66lP6wDc9GyOvhFPvwnHhtc=" =
             MsbmsSystOptions.get_global_pepper_value(options)
  end

  test "Can List Available Server Pools", %{options: options} do
    assert ["primary", "linked", "demo", "reserved"] =
             MsbmsSystOptions.list_available_server_pools(options)
  end

  test "Can Retrieve DbServers List Unfiltered", %{options: options} do
    assert [_ | _] = dbserver_list = MsbmsSystOptions.list_dbservers(options)
    assert 2 = length(dbserver_list)
  end

  test "Can Retrieve DbServers List Filtered", %{options: options} do
    assert [%{server_pools: server_pools} | []] =
             MsbmsSystOptions.list_dbservers(options, ["primary"])

    assert "primary" in server_pools
  end

  test "Can Retrieve DbServer by Name", %{options: options} do
    assert %{server_name: "global_db"} =
             MsbmsSystOptions.get_dbserver_by_name(options, "global_db")
  end
end
