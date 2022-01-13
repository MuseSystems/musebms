# Source File: startup_options.ex
# Location:    musebms/lib/msbms/system/data/startup_options.ex
# Project:     musebms
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https: //muse.systems

defmodule Msbms.System.Data.StartupOptions do
  import Ecto.Changeset

  alias Msbms.System.Constants
  alias Msbms.System.Types.DbServer

  @spec get_options(binary()) ::
          {:ok, map()} | {:error, {:invalid_toml, binary()} | {:file_read_error, atom()}}
  def get_options(options_file_path \\ Constants.get(:startup_options_path))
      when is_binary(options_file_path) do
    file_read_result = File.read(options_file_path)

    case file_read_result do
      {:ok, file_contents} -> Toml.decode(file_contents)
      {:error, _reason} -> file_read_result
    end
  end

  @spec get_options!(binary()) :: map()
  def get_options!(options_file_path \\ Constants.get(:startup_options_path))
      when is_binary(options_file_path) do
    case get_options(options_file_path) do
      {:ok, options} -> options
      {:error, reason} -> raise "Starup options retrieval failed: #{inspect(reason)}"
    end
  end

  @spec get_global_dbserver!(map()) :: DbServer.t()
  def get_global_dbserver!(startup_options) when is_map(startup_options) do
    case get_global_dbserver(startup_options) do
      {:ok, global_dbserver} -> global_dbserver
      {:error, reason} -> raise "Global database server is not retrievable: #{inspect(reason)}"
    end
  end

  @spec get_global_dbserver(map()) :: {:ok, DbServer.t()} | {:error, any()}
  def get_global_dbserver(startup_options) when is_map(startup_options) do
    get_dbserver(
      startup_options,
      startup_options["global_dbserver_name"]
    )
  end

  @spec get_dbserver(map(), binary()) :: {:ok, DbServer.t()} | {:error, any()}
  def get_dbserver(startup_options, dbserver_name)
      when is_map(startup_options) and is_binary(dbserver_name) do
    dbserver_options =
      Enum.find(
        startup_options["dbserver"],
        {:error, "Database server #{dbserver_name} not found."},
        fn curr_server ->
          curr_server["server_name"] == dbserver_name
        end
      )

    case dbserver_options do
      {:error, _} ->
        dbserver_options

      _ ->
        validate_dbserver(dbserver_options)
    end
  end

  @spec validate_dbserver(map()) :: {:ok, DbServer.t()} | {:error, any()}
  def validate_dbserver(candidate_dbserver) do
    salt_min_bytes = Constants.get(:salt_min_bytes)
    dba_pass_min_bytes = Constants.get(:dba_pass_min_bytes)
    dbserver_types = DbServer.get_dbserver_types()

    changeset =
      {%Msbms.System.Types.DbServer{}, dbserver_types}
      |> cast(candidate_dbserver, Map.keys(dbserver_types))
      |> validate_required(Map.keys(dbserver_types))
      |> validate_length(:server_salt,
        min: salt_min_bytes,
        count: :bytes,
        message: "The server_salt setting must be at least #{salt_min_bytes} bytes long."
      )
      |> validate_length(:dbadmin_password,
        min: dba_pass_min_bytes,
        count: :bytes,
        message: "The dbadmin_password setting must be at least #{dba_pass_min_bytes} bytes long."
      )
      |> validate_inclusion(:db_log_level, [
        "emergency",
        "alert",
        "critical",
        "error",
        "warning",
        "notice",
        "info",
        "debug"
      ])

    case changeset do
      %Ecto.Changeset{valid?: false, errors: validation_errors} ->
        {:error, validation_errors}

      %Ecto.Changeset{valid?: true, changes: changes} ->
        {:ok,
         %DbServer{
           server_name: changes.server_name,
           start_server_instances: changes.start_server_instances,
           instance_production_dbserver: changes.instance_production_dbserver,
           instance_sandbox_dbserver: changes.instance_sandbox_dbserver,
           db_host: changes.db_host,
           db_port: changes.db_port,
           db_show_sensitive: changes.db_show_sensitive,
           db_log_level: String.to_existing_atom(changes.db_log_level),
           db_max_instances: changes.db_max_instances,
           db_default_app_user_pool_size: changes.db_default_app_user_pool_size,
           db_default_api_user_pool_size: changes.db_default_api_user_pool_size,
           server_salt: changes.server_salt,
           dbadmin_password: changes.dbadmin_password,
           dbadmin_pool_size: changes.dbadmin_pool_size
         }}
    end
  end
end
