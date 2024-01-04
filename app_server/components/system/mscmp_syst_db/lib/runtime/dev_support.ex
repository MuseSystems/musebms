# Source File: dev_support.ex
# Location:    musebms/app_server/components/system/mscmp_syst_db/lib/runtime/dev_support.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystDb.Runtime.DevSupport do
  @moduledoc false

  alias MscmpSystDb.Types.{DatastoreContext, DatastoreOptions, DbServer}

  @spec get_devsupport_context_name() :: atom()
  def get_devsupport_context_name, do: :ms_devsupport_context

  @spec get_testsupport_context_name() :: atom()
  def get_testsupport_context_name, do: :ms_testsupport_context

  @spec get_datastore_options(Keyword.t()) :: DatastoreOptions.t()
  def get_datastore_options(opts) do
    opts =
      MscmpSystUtils.resolve_options(opts,
        database_name: "ms_devsupport_database",
        datastore_code: "musesystems.publicly.known.insecure.devsupport.code",
        datastore_name: :ms_devsupport_database,
        description_prefix: "Muse Systems DevSupport",
        database_role_prefix: "ms_devsupport",
        context_name: get_devsupport_context_name(),
        database_password: "musesystems.publicly.known.insecure.devsupport.apppassword",
        starting_pool_size: 5,
        db_host: "127.0.0.1",
        db_port: 5432,
        server_salt: "musesystems.publicly.known.insecure.devsupport.salt",
        dbadmin_password: "musesystems.publicly.known.insecure.devsupport.password",
        dbadmin_pool_size: 1
      )

    %DatastoreOptions{
      database_name: opts[:database_name],
      datastore_code: opts[:database_code],
      datastore_name: opts[:datastore_name],
      contexts: [
        %DatastoreContext{
          context_name: nil,
          description: opts[:description_prefix] <> " Owner",
          database_role: opts[:database_role_prefix] <> "_owner",
          database_password: nil,
          starting_pool_size: 0,
          start_context: false,
          login_context: false,
          database_owner_context: true
        },
        %DatastoreContext{
          context_name: opts[:context_name],
          description: opts[:description_prefix] <> " Context Role",
          database_role: opts[:database_role_prefix] <> "_context",
          database_password: opts[:database_password],
          starting_pool_size: opts[:starting_pool_size],
          start_context: true,
          login_context: true
        }
      ],
      db_server: %DbServer{
        server_name: "devsupport_server",
        start_server_instances: true,
        db_host: opts[:db_host],
        db_port: opts[:db_port],
        db_show_sensitive: true,
        db_max_instances: 1,
        server_pools: [],
        server_salt: opts[:server_salt],
        dbadmin_password: opts[:dbadmin_password],
        dbadmin_pool_size: opts[:dbadmin_pool_size]
      }
    }
  end

  @spec get_testsupport_datastore_options(Keyword.t()) :: DatastoreOptions.t()
  def get_testsupport_datastore_options(opts) do
    opts =
      MscmpSystUtils.resolve_options(opts,
        database_name: "ms_testsupport_database",
        datastore_code: "musesystems.publicly.known.insecure.testsupport.code",
        datastore_name: :ms_testsupport_database,
        description_prefix: "Muse Systems TestSupport",
        database_role_prefix: "ms_testsupport",
        context_name: get_testsupport_context_name(),
        database_password: "musesystems.publicly.known.insecure.testsupport.apppassword",
        server_salt: "musesystems.publicly.known.insecure.testsupport.salt",
        dbadmin_password: "musesystems.publicly.known.insecure.devsupport.password"
      )

    _ = get_datastore_options(opts)
  end

  @spec load_database(DatastoreOptions.t(), String.t()) ::
          {:ok, [String.t()]} | {:error, MscmpSystError.t()}
  def load_database(datastore_options, datastore_type) do
    database_owner = Enum.find(datastore_options.contexts, &(&1.database_owner_context == true))

    database_context =
      Enum.find(
        datastore_options.contexts,
        &((&1.database_owner_context == false or &1.database_owner_context == nil) and
            &1.login_context == true)
      )

    {:ok, :ready, _} = MscmpSystDb.create_datastore(datastore_options)

    {:ok, _} =
      MscmpSystDb.upgrade_datastore(datastore_options, datastore_type,
        ms_owner: database_owner.database_role,
        ms_appusr: database_context.database_role
      )
  end

  @spec drop_database(DatastoreOptions.t()) :: :ok
  def drop_database(datastore_options) do
    :ok = MscmpSystDb.stop_datastore(datastore_options)
    :ok = MscmpSystDb.drop_datastore(datastore_options)
  end
end
