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

  alias Msbms.System.Constants
  alias Msbms.System.Data.Utils
  alias Msbms.System.Types.DatastoreOptions
  alias Msbms.System.Types.DbServer
  alias Msbms.System.Types.InstanceConfig

  @spec get_datastore_options(InstanceConfig.t()) :: DatastoreOptions.t()
  def get_datastore_options(%InstanceConfig{
        instance_name: instance_name,
        db_appusr_pool: db_app_user_pool,
        db_apiusr_pool: db_api_user_pool,
        instance_code: instance_code
      }) do
    %DatastoreOptions{
      database_name:
        Constants.get(:db_name)
        |> String.replace("##dbtype##", "inst")
        |> String.replace("##dbident##", instance_name)
        |> String.downcase(),
      database_owner:
        Constants.get(:db_owner)
        |> String.replace("##dbident##", instance_name)
        |> String.downcase(),
      appusr_pool: db_app_user_pool,
      apiusr_pool: db_api_user_pool,
      instance_name: instance_name,
      instance_code: instance_code,
      datastores: [
        appusr:
          Constants.get(:db_app_usr)
          |> String.replace("##dbident##", instance_name)
          |> String.downcase()
          |> String.to_atom(),
        apiusr:
          Constants.get(:db_api_usr)
          |> String.replace("##dbident##", instance_name)
          |> String.downcase()
          |> String.to_atom()
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
               password:
                 Utils.generate_password(
                   options.instance_code,
                   Atom.to_string(elem(datastore, 1)),
                   dbserver.server_salt
                 ),
               show_sensitive_data_on_connection_error: dbserver.db_show_sensitive,
               pool_size:
                 case elem(datastore, 0) do
                   :appusr -> dbserver.db_default_app_user_pool_size
                   :apiusr -> dbserver.db_default_api_user_pool_size
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
