# Source File: db_server.ex
# Location:    musebms/lib/msbms/system/types/db_server.ex
# Project:     musebms
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https: //muse.systems
defmodule Msbms.System.Data.DbServer do
  @enforce_keys [
    :server_name,
    :start_server_instances,
    :instance_production_db_server,
    :instance_sandbox_db_server,
    :db_host,
    :db_port,
    :db_show_sensitive,
    :db_log_level,
    :db_max_instances,
    :db_default_app_user_pool_size,
    :db_default_api_user_pool_size,
    :db_default_app_admin_pool_size,
    :db_default_api_admin_pool_size,
    :instance_salt
  ]
  @type t() :: %__MODULE__{
          server_name: binary(),
          start_server_instances: boolean(),
          instance_production_db_server: boolean(),
          instance_sandbox_db_server: boolean(),
          db_host: binary(),
          db_port: integer(),
          db_show_sensitive: boolean(),
          db_log_level:
            :emergency | :alert | :critical | :error | :warning | :notice | :info | :debug,
          db_max_instances: integer(),
          db_default_app_user_pool_size: integer(),
          db_default_api_user_pool_size: integer(),
          db_default_app_admin_pool_size: integer(),
          db_default_api_admin_pool_size: integer(),
          instance_salt: binary()
        }
  defstruct [
    :server_name,
    :start_server_instances,
    :instance_production_db_server,
    :instance_sandbox_db_server,
    :db_host,
    :db_port,
    :db_show_sensitive,
    :db_log_level,
    :db_max_instances,
    :db_default_app_user_pool_size,
    :db_default_api_user_pool_size,
    :db_default_app_admin_pool_size,
    :db_default_api_admin_pool_size,
    :instance_salt
  ]

  @default_start_options_path Path.join(["msbms_startup_options.toml"])

  @spec get_startup_options ::
          {:ok, map()} | {:error, {:invalid_toml, binary()} | {:file_read_error, atom()}}
  def get_startup_options() do
    get_startup_options(@default_start_options_path)
  end

  @spec get_startup_options(binary()) ::
          {:ok, map()} | {:error, {:invalid_toml, binary()} | {:file_read_error, atom()}}
  def get_startup_options(startup_options_file_path) when is_binary(startup_options_file_path) do
    file_read_result = File.read(startup_options_file_path)

    case file_read_result do
      {:ok, file_contents} -> Toml.decode(file_contents)
      {:error, _reason} -> file_read_result
    end
  end

  @spec get_global_db_server() :: {:ok, t()} | {:error, any()}
  def get_global_db_server() do
    get_global_db_server(@default_start_options_path)
  end

  @spec get_global_db_server(binary()) :: {:ok, t()} | {:error, any()}
  def get_global_db_server(startup_options_file_path) when is_binary(startup_options_file_path) do
    case get_startup_options(startup_options_file_path) do
      {:ok, startup_options} ->
        get_db_server(startup_options, startup_options["global_admin"]["global_db_server_name"])

      {:error, reason} ->
        {:error, reason}
    end
  end

  @spec get_db_server(map(), binary()) :: {:ok, t()} | {:error, any()}
  def get_db_server(startup_options, db_server_name)
      when is_map(startup_options) and is_binary(db_server_name) do
    db_server_options =
      Enum.find(
        startup_options["db_server"],
        {:error, "Database server #{db_server_name} not found."},
        fn curr_server ->
          curr_server["server_name"] == db_server_name
        end
      )

    case db_server_options do
      {:error, _} ->
        db_server_options

      _ ->
        %Msbms.System.Data.DbServer{
          server_name: db_server_options["server_name"],
          start_server_instances: db_server_options["start_server_instances"],
          instance_production_db_server: db_server_options["instance_production_db_server"],
          instance_sandbox_db_server: db_server_options["instance_sandbox_db_server"],
          db_host: db_server_options["db_host"],
          db_port: db_server_options["db_port"],
          db_show_sensitive: db_server_options["db_show_sensitive"],
          db_log_level: String.to_existing_atom(db_server_options["db_log_level"]),
          db_max_instances: db_server_options["db_max_instances"],
          db_default_app_user_pool_size: db_server_options["db_default_app_user_pool_size"],
          db_default_api_user_pool_size: db_server_options["db_default_api_user_pool_size"],
          db_default_app_admin_pool_size: db_server_options["db_default_app_admin_pool_size"],
          db_default_api_admin_pool_size: db_server_options["db_default_api_admin_pool_size"],
          instance_salt: db_server_options["instance_salt"]
        }
    end
  end
end
