defmodule MsbmsSystInstanceMgrTest do
  use ExUnit.Case, async: true

  import Ecto.Query

  alias Mix.Tasks.Builddb

  @datastore_context_name :instmgr_app_context

  @datastore_options %{
    database_name: "msbms_syst_instance_mgr",
    database_owner: "msbms_syst_instance_mgr_owner",
    datastore_code: "msbms_syst_instance_mgr.testing.code",
    datastore_name: :msbms_syst_instance_mgr,
    contexts: [
      %{
        id: nil,
        description: "MsBmsSystInstanceMgr Testing Owner",
        database_role: "msbms_syst_instance_mgr_owner",
        database_password: nil,
        starting_pool_size: 0,
        start_context: false,
        login_context: false
      },
      %{
        id: @datastore_context_name,
        description: "MsBmsSystInstanceMgr Testing App User",
        database_role: "msbms_syst_instance_mgr_app_user",
        database_password: 'msbms_syst_instance_mgr.testing.code.app.user',
        starting_pool_size: 20,
        start_context: true,
        login_context: true
      },
      %{
        id: :msbms_syst_instance_mgr_api_user,
        description: "MsBmsSystInstanceMgr Testing Api User",
        database_role: "msbms_syst_instance_mgr_api_user",
        database_password: 'msbms_syst_instance_mgr.testing.code.app.user',
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
      server_salt: "msbms_syst_instance_mgr.testing.code.test.salt",
      dbadmin_password: "msbms.syst.dba.testing.password",
      dbadmin_pool_size: 1
    }
  }

  @migration_test_source_root_dir "../../../database"
  @migration_test_datastore_type "cmp_msbms_syst_instance_mgr"

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
        msbms_owner: datastore_options.database_owner,
        msbms_appusr: "msbms_syst_instance_mgr_app_user",
        msbms_apiusr: "msbms_syst_instance_mgr_api_user"
      )

    {:ok, _, _} = MsbmsSystDatastore.start_datastore(datastore_options)
  end

  defp cleanup_test_environment do
    datastore_options = @datastore_options
    :ok = MsbmsSystDatastore.drop_datastore(datastore_options)
    File.rm_rf!("priv/database/cmp_msbms_syst_instance_mgr")
  end

  defp build_migrations do
    Builddb.run([
      "-t",
      @migration_test_datastore_type,
      "-c",
      "-s",
      @migration_test_source_root_dir
    ])
  end

  doctest MsbmsSystInstanceMgr
end
