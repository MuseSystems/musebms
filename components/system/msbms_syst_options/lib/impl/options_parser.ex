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

  @spec get_global_dbserver_name(map()) :: String.t()
  def get_global_dbserver_name(options) when is_map(options), do: options.global_dbserver_name

  @spec get_global_dbserver(map()) :: MsbmsSystDatastore.Types.db_server()
  def get_global_dbserver(options) do
    Enum.find(options[:dbserver], nil, &(&1.server_name == options[:global_dbserver_name]))
  end

  @spec get_global_pepper_value(map()) :: binary()
  def get_global_pepper_value(options) when is_map(options), do: options.global_pepper_value

  @spec list_dbservers(map(), list(Types.instance_class())) ::
          list(MsbmsSystDatastore.Types.db_server())
  def list_dbservers(options, filters) when is_map(options) do
    options.dbserver
    |> maybe_filter_dbservers_by_instance_class(filters)
  end

  defp maybe_filter_dbservers_by_instance_class(dbservers_list, [_ | _] = instance_classes) do
    Enum.filter(dbservers_list, fn curr_dbserver ->
      for filter_class <- instance_classes,
          server_class <- curr_dbserver[:supported_instance_classes],
          reduce: false do
        acc -> acc or filter_class == server_class
      end
    end)
  end

  defp maybe_filter_dbservers_by_instance_class(dbservers_list, []), do: dbservers_list

  @spec get_dbserver_by_name(map(), String.t()) :: MsbmsSystDatastore.Types.db_server()
  def get_dbserver_by_name(options, dbserver_name) do
    Enum.find(options[:dbserver], nil, &(&1.server_name == dbserver_name))
  end
end
