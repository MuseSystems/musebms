# Source File: options_parser.ex
# Location:    components/system/msbms_syst_options/lib/impl/options_parser.ex
# Project:     msbms
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https: //muse.systems

defmodule MsbmsSystOptions.Impl.OptionsParser do
  @moduledoc false

  alias MsbmsSystOptions.Types

  ######
  #
  # The OptionsParser module provides convenience functions for parsing out
  # certain common values from the provided options map.
  #
  ######

  @spec get_global_dbserver_name(map()) :: String.t()
  def get_global_dbserver_name(options) when is_map(options), do: options.global_dbserver_name

  @spec get_global_dbserver(map()) :: MsbmsSystDatastore.Types.db_server()
  def get_global_dbserver(options) do
    Enum.find(options[:dbserver], nil, &(&1.server_name == options[:global_dbserver_name]))
  end

  @spec get_global_pepper_value(map()) :: binary()
  def get_global_pepper_value(options) when is_map(options), do: options.global_pepper_value

  @spec list_available_server_pools(map()) :: list(Types.server_pool())
  def list_available_server_pools(options), do: options[:available_server_pools]

  @spec list_dbservers(map(), list(Types.server_pool())) ::
          list(MsbmsSystDatastore.Types.db_server())
  def list_dbservers(options, filters) when is_map(options) do
    options.dbserver
    |> maybe_filter_dbservers_by_server_pool(filters)
  end

  defp maybe_filter_dbservers_by_server_pool(dbservers_list, [_ | _] = server_pools) do
    Enum.filter(dbservers_list, fn curr_dbserver ->
      for filter_pool <- server_pools,
          server_pool <- curr_dbserver[:server_pools],
          reduce: false do
        acc -> acc or filter_pool == server_pool
      end
    end)
  end

  defp maybe_filter_dbservers_by_server_pool(dbservers_list, []), do: dbservers_list

  @spec get_dbserver_by_name(map(), String.t()) :: MsbmsSystDatastore.Types.db_server()
  def get_dbserver_by_name(options, dbserver_name) do
    Enum.find(options[:dbserver], nil, &(&1.server_name == dbserver_name))
  end
end
