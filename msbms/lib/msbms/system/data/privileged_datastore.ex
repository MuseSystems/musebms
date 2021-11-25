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
  alias Msbms.System.Types.GlobalAdminSettings
  alias Msbms.System.Constants

  @spec get_datastore_id :: atom()
  def get_datastore_id() do
    (Constants.get(:db_name) <> "_sysadmin")
    |> String.replace("##dbtype##", "priv")
    |> String.replace("##dbident##", "0000MS")
    |> String.downcase()
    |> String.to_atom()
  end

  @spec start_datastore(DbServer.t(), GlobalAdminSettings.t()) :: {:ok, pid()} | {:error, term()}
  def start_datastore(%DbServer{} = dbserver, %GlobalAdminSettings{} = global_admin_settings) do
    startup_result =
      start_link(
        name: get_datastore_id(),
        database: "postgres",
        hostname: dbserver.db_host,
        port: dbserver.db_port,
        username: Constants.get(:global_db_login),
        password: global_admin_settings.dbadmin_password,
        show_sensitive_data_on_connection_error: dbserver.db_show_sensitive,
        pool_size: global_admin_settings.dbadmin_pool_size
      )

    case startup_result do
      {:error, {:already_started, repo_pid}} -> {:ok, repo_pid}
      _ -> startup_result
    end
  end

  @spec stop_datastore :: :ok
  def stop_datastore do
    put_dynamic_repo(get_datastore_id())
    stop()
  end
end
