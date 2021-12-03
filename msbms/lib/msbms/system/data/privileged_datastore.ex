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

  alias Msbms.System.Types.DbServer
  alias Msbms.System.Constants

  @spec get_datastore_id(DbServer.t()) :: atom()
  def get_datastore_id(%DbServer{} = dbserver) do
    (Constants.get(:db_name)  <> "_sysadmin")
    |> String.replace("##dbtype##", "priv")
    |> String.replace("##dbident##", dbserver.server_name)
    |> String.downcase()
    |> String.to_atom()
  end

  @spec start_datastore(DbServer.t()) :: {:ok, pid()} | {:error, term()}
  def start_datastore(%DbServer{} = dbserver) do
    startup_result =
      start_link(
        name: get_datastore_id(dbserver),
        database: "postgres",
        hostname: dbserver.db_host,
        port: dbserver.db_port,
        username: Constants.get(:global_db_login),
        password: dbserver.dbadmin_password,
        show_sensitive_data_on_connection_error: dbserver.db_show_sensitive,
        pool_size: dbserver.dbadmin_pool_size
      )

    case startup_result do
      {:error, {:already_started, repo_pid}} -> {:ok, repo_pid}
      _ -> startup_result
    end
  end

  @spec stop_datastore(DbServer.t()) :: :ok
  def stop_datastore(%DbServer{} = dbserver) do
    dbserver
    |> get_datastore_id()
    |> put_dynamic_repo()

    stop()
  end
end
