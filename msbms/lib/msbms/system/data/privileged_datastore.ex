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
  alias Msbms.System.Types.DbServer

  @spec start_datastore(DbServer.t(), binary()) :: {:ok, pid()} | {:error, term()}
  def start_datastore(%DbServer{} = dbserver, database_name) when is_binary(database_name) do
    startup_result =
      start_link(
        name: nil,
        database: database_name,
        hostname: dbserver.db_host,
        port: dbserver.db_port,
        username: Constants.get(:global_db_login),
        password: dbserver.dbadmin_password,
        show_sensitive_data_on_connection_error: dbserver.db_show_sensitive,
        pool_size: dbserver.dbadmin_pool_size
      )

    case startup_result do
      {:error, {:already_started, repo_pid}} -> {:ok, repo_pid}
      {:ok, repo_pid} ->
        put_dynamic_repo(repo_pid)
        query("SET application_name TO 'MSBMS Privileged Datastore';")
        startup_result
      _ ->
        startup_result
    end
  end

  @spec start_datastore(Msbms.System.Types.DbServer.t()) :: {:error, any} | {:ok, pid}
  def start_datastore(%DbServer{} = dbserver) do
    start_datastore(dbserver, "postgres")
  end

  def stop_datastore(datastore_pid) when is_pid(datastore_pid) do
    put_dynamic_repo(datastore_pid)

    stop()
  end
end
