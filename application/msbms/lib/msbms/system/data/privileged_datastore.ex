# Source File: privileged_datastore.ex
# Location:    musebms/lib/msbms/system/data/privileged_datastore.ex
# Project:     musebms
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https: //muse.systems

defmodule Msbms.System.Data.PrivilegedDatastore do
  use Ecto.Repo,
    otp_app: :msbms,
    adapter: Ecto.Adapters.Postgres

  alias Msbms.System.Constants
  alias Msbms.System.Types.DatastoreOptions

  @spec start_datastore(DatastoreOptions.t(), :server_privileged | :db_privileged | binary()) ::
          {:ok, pid()} | {:error, any()}
  def start_datastore(%DatastoreOptions{} = options, :server_privileged) do
    start_datastore(options, "postgres")
  end

  def start_datastore(%DatastoreOptions{} = options, :db_privileged) do
    start_datastore(options, options.database_name)
  end

  def start_datastore(%DatastoreOptions{} = options, database_name)
      when is_binary(database_name) do
    startup_result =
      start_link(
        name: nil,
        database: database_name,
        hostname: options.dbserver.db_host,
        port: options.dbserver.db_port,
        username: Constants.get(:global_db_login),
        password: options.dbserver.dbadmin_password,
        show_sensitive_data_on_connection_error: options.dbserver.db_show_sensitive,
        pool_size: options.dbserver.dbadmin_pool_size
      )

    case startup_result do
      {:ok, priv_db_conn_id} ->
        put_dynamic_repo(priv_db_conn_id)
        query("SET application_name TO 'MSBMS Privileged Datastore';")
        {:ok, priv_db_conn_id}
      {:error, reason} ->
        {:error, "Failure to start #{database_name} privileged datastore:\n#{inspect(reason)}"}
    end
  end

  @spec stop_datastore(pid) :: :ok
  def stop_datastore(priv_db_conn_id) when is_pid(priv_db_conn_id) do
    put_dynamic_repo(priv_db_conn_id)
    stop()
  end
end
