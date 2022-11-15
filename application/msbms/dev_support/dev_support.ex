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

  # Global Datastore Configuration

  @migrations_global "app_msbms_global"

  @datastore_context_global_app :dev_app_global
  @datastore_context_global_api :dev_api_global

  @global_datastore_options %{
    database_name: "msbms_dev_global",
    datastore_code: "msbms.dev.global",
    datastore_name: :msbms_dev_global,
    contexts: [
      %{
        context_name: nil,
        description: "MSBMS Global/Development Owner",
        database_role: "msbms_dev_global_owner",
        database_password: nil,
        starting_pool_size: 0,
        start_context: false,
        login_context: false,
        database_owner_context: true
      },
      %{
        context_name: @datastore_context_global_app,
        description: "MSBMS Global/Development App User",
        database_role: "msbms_dev_global_app_user",
        database_password: "msbms.dev.global.code.app.user",
        starting_pool_size: 10,
        start_context: true,
        login_context: true
      },
      %{
        context_name: @datastore_context_global_api,
        description: "MSBMS Global/Development API User",
        database_role: "msbms_dev_global_api_user",
        database_password: "msbms.dev.global.code.api.user",
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

  # Instance Datastore Configuration

  @migrations_instance "app_msbms_instance"

  @datastore_context_instance_app :dev_app_instance
  @datastore_context_instance_api :dev_api_instance

  @instance_datastore_options %{
    database_name: "msbms_dev_instance",
    datastore_code: "msbms.dev.instance",
    datastore_name: :msbms_dev_instance,
    contexts: [
      %{
        context_name: nil,
        description: "MSBMS Instance/Development Owner",
        database_role: "msbms_dev_instance_owner",
        database_password: nil,
        starting_pool_size: 0,
        start_context: false,
        login_context: false,
        database_owner_context: true
      },
      %{
        context_name: @datastore_context_instance_app,
        description: "MSBMS Instance/Development App User",
        database_role: "msbms_dev_instance_app_user",
        database_password: "msbms.dev.instance.code.app.user",
        starting_pool_size: 10,
        start_context: true,
        login_context: true
      },
      %{
        context_name: @datastore_context_instance_api,
        description: "MSBMS Instance/Development API User",
        database_role: "msbms_dev_instance_api_user",
        database_password: "msbms.dev.instance.code.api.user",
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
    _ = setup_global_database()
    _ = setup_instance_database()
  end

  def stop_dev_environment() do
    _ = cleanup_global_database()
    _ = cleanup_instance_database()
    File.rm_rf!(Path.join(["priv/database"]))
  end

  defp setup_global_database() do
    :ok = build_migrations(@migrations_global)

    context_bindings = [
      msbms_appusr: "msbms_dev_global_app_user",
      msbms_apiusr: "msbms_dev_global_api_user"
    ]

    setup_database(@migrations_global, @global_datastore_options, context_bindings)
  end

  defp setup_instance_database() do
    :ok = build_migrations(@migrations_instance)

    context_bindings = [
      msbms_appusr: "msbms_dev_instance_app_user",
      msbms_apiusr: "msbms_dev_instance_api_user"
    ]

    setup_database(@migrations_instance, @instance_datastore_options, context_bindings)
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

  defp cleanup_global_database, do: cleanup_database(@global_datastore_options)
  defp cleanup_instance_database, do: cleanup_database(@instance_datastore_options)

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
