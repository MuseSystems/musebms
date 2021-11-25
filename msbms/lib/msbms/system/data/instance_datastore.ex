# Source File: instance_datastore.ex
# Location:    musebms/lib/msbms/system/data/instance_datastore.ex
# Project:     musebms
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https: //muse.systems

defmodule Msbms.System.Data.InstanceDatastore do
  use Ecto.Repo,
    otp_app: :msbms,
    adapter: Ecto.Adapters.Postgres

  alias Msbms.System.Types.DatastoreOptions
  alias Msbms.System.Types.DbServer
  alias Msbms.System.Types.InstanceConfig
  alias Msbms.System.Constants

  @spec get_datastore_options(InstanceConfig.t()) :: DatastoreOptions.t()
  def get_datastore_options(%InstanceConfig{
        instance_name: instance_name,
        db_app_user_pool: db_app_user_pool,
        db_app_admin_pool: db_app_admin_pool,
        db_api_user_pool: db_api_user_pool,
        db_api_admin_pool: db_api_admin_pool
      }) do
    global_database_name =
      Constants.get(:db_name)
      |> String.replace("##dbtype##", "inst")
      |> String.replace("##dbident##", instance_name)
      |> String.downcase()

    %DatastoreOptions{
      database_name: global_database_name,
      database_owner: String.replace(Constants.get(:db_owner), "##dbident##", instance_name),
      app_user_pool: db_app_user_pool,
      app_admin_pool: db_app_admin_pool,
      api_user_pool: db_api_user_pool,
      api_admin_pool: db_api_admin_pool,
      datastores: [
        appusr:
          String.to_atom(
            String.downcase(
              String.replace(Constants.get(:db_app_usr), "##dbident##", instance_name)
            )
          ),
        apiusr:
          String.to_atom(
            String.downcase(
              String.replace(Constants.get(:db_api_usr), "##dbident##", instance_name)
            )
          ),
        appadm:
          String.to_atom(
            String.downcase(
              String.replace(Constants.get(:db_app_admin), "##dbident##", instance_name)
            )
          ),
        apiadm:
          String.to_atom(
            String.downcase(
              String.replace(Constants.get(:db_api_admin), "##dbident##", instance_name)
            )
          )
      ]
    }
  end

  @spec start_datastores(DbServer.t(), DatastoreOptions.t()) :: [{:ok, pid()} | {:error, term()}]
  def start_datastores(%DbServer{} = dbserver, %DatastoreOptions{} = options) do
    Enum.reduce(options.datastores, [], fn datastore, acc ->
      [
        case start_link(
               name: elem(datastore, 1),
               database: options.database_name,
               hostname: dbserver.db_host,
               port: dbserver.db_port,
               username: Atom.to_string(elem(datastore, 1)),
               password: dbserver.instance_salt <> Atom.to_string(elem(datastore, 1)),
               show_sensitive_data_on_connection_error: dbserver.db_show_sensitive,
               pool_size:
                 case elem(datastore, 0) do
                   :appusr -> dbserver.db_default_app_user_pool_size
                   :apiusr -> dbserver.db_default_api_user_pool_size
                   :appadm -> dbserver.db_default_app_admin_pool_size
                   :apiadm -> dbserver.db_default_api_admin_pool_size
                   _ -> 1
                 end
             ) do
          {:error, {:already_started, ds_pid}} -> {:ok, ds_pid}
          return_value -> return_value
        end
        | acc
      ]
    end)
  end

  @spec stop_datastores(DatastoreOptions.t()) :: :ok
  def stop_datastores(%DatastoreOptions{datastores: datastores}) do
    Enum.each(
      datastores,
      fn datastore_id ->
        put_dynamic_repo(datastore_id)
        stop()
      end
    )

    :ok
  end
end
