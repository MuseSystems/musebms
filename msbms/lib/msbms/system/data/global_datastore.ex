# Source File: global_datastore.ex
# Location:    musebms/lib/msbms/system/data/global_datastore.ex
# Project:     musebms
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https: //muse.systems

defmodule Msbms.System.Data.GlobalDatastore do
  use Ecto.Repo,
    otp_app: :msbms,
    adapter: Ecto.Adapters.Postgres

  alias Msbms.System.Constants
  alias Msbms.System.Data.Utils
  alias Msbms.System.Types.DatastoreOptions
  alias Msbms.System.Types.DbServer

  @spec get_datastore_options(DbServer.t()) :: DatastoreOptions.t()
  def get_datastore_options(%DbServer{server_salt: server_salt} = dbserver) do
    %DatastoreOptions{
      database_name:
        Constants.get(:db_name)
        |> String.replace("##dbtype##", "glbl")
        |> String.replace("##dbident##", "0000ms")
        |> String.downcase(),
      database_owner:
        Constants.get(:db_owner)
        |> String.replace("##dbident##", "0000ms")
        |> String.downcase(),
      instance_name: "global",
      instance_code: server_salt <> Constants.get(:global_server_salt),
      dbserver: dbserver,
      contexts: [
        [
          context_id:
            Constants.get(:db_appusr)
            |> String.replace("##dbident##", "0000ms")
            |> String.downcase()
            |> String.to_atom(),
          context_starting_pool_size: nil
        ],
        [
          context_id:
            Constants.get(:db_apiusr)
            |> String.replace("##dbident##", "0000ms")
            |> String.downcase()
            |> String.to_atom(),
          context_starting_pool_size: nil
        ]
      ]
    }
  end

  @spec start_datastores(DatastoreOptions.t()) :: [{:ok, pid()} | {:error, term()}]
  def start_datastores(%DatastoreOptions{} = options) do
    Utils.start_datastores(__MODULE__, options)
  end

  @spec stop_datastores(DatastoreOptions.t()) :: :ok
  def stop_datastores(%DatastoreOptions{} = options) do
    Utils.stop_datastores(__MODULE__, options)
  end
end
