defmodule InstanceDbMigrationTest do
  use ExUnit.Case, async: true

  alias Mix.Tasks.Builddb

  @datastore_options %{
    database_name: "test_instance_build",
    database_owner: "instance_build_owner",
    datastore_code: "instance.testing.code",
    datastore_name: :instance,
    contexts: [
      %{
        id: nil,
        description: "Instance Build Testing Owner",
        database_role: "instance_build_owner",
        database_password: nil,
        starting_pool_size: 0,
        start_context: false,
        login_context: false
      },
      %{
        id: :instance_build_app_context,
        description: "Instance Build Testing App User",
        database_role: "instance_build_app_user",
        database_password: "instance.testing.code.app.user",
        starting_pool_size: 3,
        start_context: true,
        login_context: true
      },
      %{
        id: :instance_build_api_user,
        description: "Instance Build Testing Api User",
        database_role: "instance_build_api_user",
        database_password: "instance.testing.code.app.user",
        starting_pool_size: 3,
        start_context: true,
        login_context: true
      }
    ],
    db_server: %{
      server_name: "test_server",
      start_server_instances: true,
      instance_production_dbserver: false,
      instance_sandbox_dbserver: true,
      db_host: "127.0.0.1",
      db_port: 5432,
      db_show_sensitive: true,
      db_log_level: :debug,
      db_max_instances: 1,
      context_defaults: [],
      server_salt: "instance.testing.code.test.salt",
      dbadmin_password: "msbms.syst.dba.testing.password",
      dbadmin_pool_size: 1
    }
  }

  @migration_test_source_root_dir "../../database"
  @migration_test_destination_dir "priv/database_build_testing"
  @migration_test_datastore_type "app_msbms_instance"

  @datastore_context_name :instance_build_app_context

  #  This testing presumes that the database schema is tested separately and is
  #  correct here.

  setup_all do
    setup_test_environment()
    on_exit(&cleanup_test_environment/0)
  end

  defp setup_test_environment do
    :ok = build_migrations()

    datastore_options = @datastore_options

    {:ok, :ready, _} = MsbmsSystDatastore.create_datastore(datastore_options)

    {:ok, _} =
      MsbmsSystDatastore.upgrade_datastore(
        datastore_options,
        @migration_test_datastore_type,
        [
          msbms_owner: datastore_options.database_owner,
          msbms_appusr: "instance_build_app_user",
          msbms_apiusr: "instance_build_api_user"
        ],
        migrations_root_dir: @migration_test_destination_dir
      )
  end

  defp cleanup_test_environment do
    datastore_options = @datastore_options
    :ok = MsbmsSystDatastore.drop_datastore(datastore_options)
    File.rm_rf!(Path.join([@migration_test_destination_dir, @migration_test_datastore_type]))
  end

  defp build_migrations do
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

  test "Misc Test" do
    assert :ok = :ok
  end
end
