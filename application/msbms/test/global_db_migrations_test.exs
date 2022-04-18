# Source File: global_db_migrations_test.exs
# Location:    application/msbms/test/global_db_migrations_test.exs
# Project:     msbms
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https: //muse.systems

defmodule GlobalDbMigrationsTest do
  use ExUnit.Case, async: true

  alias Mix.Tasks.Builddb

  @datastore_options %{
    database_name: "global_build_build",
    database_owner: "global_build_owner",
    datastore_code: "global.testing.code",
    datastore_name: :global,
    contexts: [
      %{
        id: nil,
        description: "Global Build Testing Owner",
        database_role: "global_build_owner",
        database_password: nil,
        starting_pool_size: 0,
        start_context: false,
        login_context: false
      },
      %{
        id: :global_build_app_context,
        description: "Global Build Testing App User",
        database_role: "global_build_app_user",
        database_password: "global.testing.code.app.user",
        starting_pool_size: 3,
        start_context: true,
        login_context: true
      },
      %{
        id: :global_build_api_user,
        description: "Global Build Testing Api User",
        database_role: "global_build_api_user",
        database_password: "global.testing.code.app.user",
        starting_pool_size: 3,
        start_context: true,
        login_context: true
      }
    ],
    db_server: %{
      server_name: :test_server,
      start_server_databases: true,
      instance_production_dbserver: false,
      instance_sandbox_dbserver: true,
      db_host: "127.0.0.1",
      db_port: "5432",
      db_show_sensitive: true,
      db_log_level: :debug,
      db_max_databases: 1,
      context_defaults: [],
      server_salt: "global.testing.code.test.salt",
      dbadmin_password: "msbms.syst.dba.testing.password",
      dbadmin_pool_size: 1
    }
  }

  @migration_test_source_root_dir "../../database"
  @migration_test_destination_dir "priv/database_build_testing"
  @migration_test_datastore_type "app_msbms_global"

  @datastore_context_name :global_build_app_context

  #  This testing presumes that the database schema is tested separately and is
  #  correct here.

  setup_all do
    on_exit(&cleanup_test_environment/0)
  end

  test "Build & Apply Global Migrations" do
    :ok = build_migrations()

    datastore_options = @datastore_options

    {:ok, :ready, _} = MsbmsSystDatastore.create_datastore(datastore_options)

    {:ok, _} =
      MsbmsSystDatastore.upgrade_datastore(
        datastore_options,
        @migration_test_datastore_type,
        [
          msbms_owner: datastore_options.database_owner,
          msbms_appusr: "global_build_app_user",
          msbms_apiusr: "global_build_api_user"
        ],
        migrations_root_dir: @migration_test_destination_dir
      )
  end

  defp setup_test_environment do
  end

  defp cleanup_test_environment do
    datastore_options = @datastore_options
    :ok = MsbmsSystDatastore.drop_datastore(datastore_options)
    File.rm_rf!(Path.join([@migration_test_destination_dir, @migration_test_datastore_type]))
  end

  defp build_migrations() do
    Builddb.run([
      "-t",
      @migration_test_datastore_type,
      "-c",
      "-s",
      @migration_test_source_root_dir,
      "-d",
      @migration_test_destination_dir
    ])
  end
end
