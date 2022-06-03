# Source File: test_support.ex
# Location:    components/system/msbms_syst_instance_mgr/test/support/test_support.ex
# Project:     msbms
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https: //muse.systems

defmodule TestSupport do
  @moduledoc false

  #######################
  #
  # Testing Support
  #
  # This module provides functions used to create, migrate, and clean up the
  # testing database for the individual tests in the suite that require the
  # database.
  #
  ########################

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
        database_password: "msbms_syst_instance_mgr.testing.code.app.user",
        starting_pool_size: 20,
        start_context: true,
        login_context: true
      }
    ],
    db_server: %{
      server_name: "test_server",
      start_server_instances: true,
      db_host: "127.0.0.1",
      db_port: 5432,
      db_show_sensitive: true,
      db_log_level: :debug,
      db_max_instances: 1,
      server_pools: [],
      server_salt: "msbms_syst_instance_mgr.testing.code.test.salt",
      dbadmin_password: "msbms.syst.dba.testing.password",
      dbadmin_pool_size: 1
    }
  }

  @migration_test_source_root_dir "../../../database"
  @migration_test_datastore_type "cmp_msbms_syst_instance_mgr"

  def setup_testing_database do
    :ok = build_migrations()

    datastore_options = @datastore_options

    {:ok, :ready, _} = MsbmsSystDatastore.create_datastore(datastore_options)

    {:ok, _} =
      MsbmsSystDatastore.upgrade_datastore(
        datastore_options,
        @migration_test_datastore_type,
        msbms_owner: datastore_options.database_owner,
        msbms_appusr: "msbms_syst_instance_mgr_app_user"
      )

    {:ok, _, _} = MsbmsSystDatastore.start_datastore(datastore_options)
  end

  def cleanup_testing_database do
    datastore_options = @datastore_options
    :ok = MsbmsSystDatastore.stop_datastore(datastore_options)
    :ok = MsbmsSystDatastore.drop_datastore(datastore_options)
    File.rm_rf!(Path.join(["priv/database", @migration_test_datastore_type]))
  end

  def get_testing_datastore_context_id, do: @datastore_context_name

  defp build_migrations do
    Builddb.run([
      "-t",
      @migration_test_datastore_type,
      "-c",
      "-s",
      @migration_test_source_root_dir
    ])
  end
end
