# Source File: dev_support.ex
# Location:    musebms/application/msbms/dev_support/dev_support.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule DevSupport do
  alias Mix.Tasks.Builddb

  @migration_test_source_root_dir "../../database"

  # MSMCP Datastore Configuration

  @migrations_msmcp "app_msmcp"

  @datastore_context_msmcp_app :dev_app_msmcp
  @datastore_context_msmcp_api :dev_api_msmcp

  @msmcp_datastore_options %{
    database_name: "msmcp_dev",
    datastore_code: "msmcp.dev",
    datastore_name: :msmcp_dev,
    contexts: [
      %{
        context_name: nil,
        description: "MSMCP/Development Owner",
        database_role: "msmcp_dev_owner",
        database_password: nil,
        starting_pool_size: 0,
        start_context: false,
        login_context: false,
        database_owner_context: true
      },
      %{
        context_name: @datastore_context_msmcp_app,
        description: "MSMCP/Development App User",
        database_role: "msmcp_dev_app_user",
        database_password: "msmcp.dev.code.app.user",
        starting_pool_size: 10,
        start_context: true,
        login_context: true
      },
      %{
        context_name: @datastore_context_msmcp_api,
        description: "MSMCP/Development API User",
        database_role: "msmcp_dev_api_user",
        database_password: "msmcp.dev.code.api.user",
        starting_pool_size: 10,
        start_context: true,
        login_context: true
      }
    ],
    db_server: %{
      server_name: "dev_server",
      start_server_instances: true,
      db_host: "127.0.0.1",
      db_port: 5432,
      db_show_sensitive: true,
      db_max_instances: 1,
      server_pools: [],
      server_salt: "msbms.dev.code.test.salt",
      dbadmin_password: "msbms.syst.dba.testing.password",
      dbadmin_pool_size: 1
    }
  }

  # MSBMS Datastore Configuration

  @migrations_instance "app_msbms"

  @datastore_context_msbms_app :dev_app_msbms
  @datastore_context_msbms_api :dev_api_msbms

  @msbms_datastore_options %{
    database_name: "msbms_dev",
    datastore_code: "msbms.dev",
    datastore_name: :msbms_dev,
    contexts: [
      %{
        context_name: nil,
        description: "MSBMS/Development Owner",
        database_role: "msbms_dev_owner",
        database_password: nil,
        starting_pool_size: 0,
        start_context: false,
        login_context: false,
        database_owner_context: true
      },
      %{
        context_name: @datastore_context_msbms_app,
        description: "MSBMS/Development App User",
        database_role: "msbms_dev_app_user",
        database_password: "msbms.dev.code.app.user",
        starting_pool_size: 10,
        start_context: true,
        login_context: true
      },
      %{
        context_name: @datastore_context_msbms_api,
        description: "MSBMS/Development API User",
        database_role: "msbms_dev_api_user",
        database_password: "msbms.dev.code.api.user",
        starting_pool_size: 10,
        start_context: true,
        login_context: true
      }
    ],
    db_server: %{
      server_name: "dev_server",
      start_server_instances: true,
      db_host: "127.0.0.1",
      db_port: 5432,
      db_show_sensitive: true,
      db_max_instances: 1,
      server_pools: [],
      server_salt: "msbms.dev.code.test.salt",
      dbadmin_password: "msbms.syst.dba.testing.password",
      dbadmin_pool_size: 1
    }
  }

  def start_dev_environment() do
    _ = setup_msmcp_database()
    _ = setup_msbms_database()
    :ok
  end

  def stop_dev_environment() do
    _ = cleanup_msmcp_database()
    _ = cleanup_msbms_database()
    File.rm_rf!(Path.join(["priv/database"]))
    :ok
  end

  defp setup_msmcp_database() do
    :ok = build_migrations(@migrations_msmcp)

    context_bindings = [
      msbms_appusr: "msmcp_dev_app_user",
      msbms_apiusr: "msmcp_dev_api_user"
    ]

    setup_database(@migrations_msmcp, @msmcp_datastore_options, context_bindings)
  end

  defp setup_msbms_database() do
    :ok = build_migrations(@migrations_instance)

    context_bindings = [
      msbms_appusr: "msbms_dev_app_user",
      msbms_apiusr: "msbms_dev_api_user"
    ]

    setup_database(@migrations_instance, @msbms_datastore_options, context_bindings)
  end

  defp setup_database(datastore_type, datastore_options, context_bindings) do
    database_owner = Enum.find(datastore_options.contexts, &(&1[:database_owner_context] == true))

    {:ok, :ready, _} = MsbmsSystDatastore.create_datastore(datastore_options)

    migration_bindings =
      Keyword.merge(context_bindings, msbms_owner: database_owner.database_role)

    {:ok, _} =
      MsbmsSystDatastore.upgrade_datastore(datastore_options, datastore_type, migration_bindings)

    {:ok, _, _} = MsbmsSystDatastore.start_datastore(datastore_options)
  end

  defp cleanup_msmcp_database, do: cleanup_database(@msmcp_datastore_options)
  defp cleanup_msbms_database, do: cleanup_database(@msbms_datastore_options)

  defp cleanup_database(datastore_options) do
    :ok = MsbmsSystDatastore.stop_datastore(datastore_options)
    :ok = MsbmsSystDatastore.drop_datastore(datastore_options)
  end

  defp build_migrations(ds_type) do
    Builddb.run([
      "-t",
      ds_type,
      "-c",
      "-s",
      @migration_test_source_root_dir
    ])
  end
end
