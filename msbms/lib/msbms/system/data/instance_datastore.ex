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

  @spec get_datastore_options(DbServer.t(), InstanceConfig.t()) :: DatastoreOptions.t()
  def get_datastore_options(%DbServer{} = dbserver, %InstanceConfig{
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
      instance_name: instance_name,
      instance_code: instance_code,
      dbserver: dbserver,
      contexts: [
        [
          context_id: :appusr,
          context_desc: "MSBMS Instance (#{instance_name}) Database Application Access Role",
          context_role:
            Constants.get(:db_appusr)
            |> String.replace("##dbident##", instance_name)
            |> String.downcase()
            |> String.to_atom(),
          context_starting_pool_size: db_app_user_pool
        ],
        [
          context_id: :apiusr,
          context_desc: "MSBMS Instance (#{instance_name}) Database API Access Role",
          context_role:
            Constants.get(:db_apiusr)
            |> String.replace("##dbident##", instance_name)
            |> String.downcase()
            |> String.to_atom(),
          context_starting_pool_size: db_api_user_pool
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
