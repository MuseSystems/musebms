# Source File: test_support.ex
# Location:    musebms/components/system/msbms_syst_authentication/test/support/test_support.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

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
    database_name: "msbms_syst_authentication",
    datastore_code: "msbms_syst_authentication.testing.code",
    datastore_name: :msbms_syst_authentication,
    contexts: [
      %{
        context_name: nil,
        description: "MsBmsSystAuthentication Testing Owner",
        database_role: "msbms_syst_authentication_owner",
        database_password: nil,
        starting_pool_size: 0,
        start_context: false,
        login_context: false,
        database_owner_context: true
      },
      %{
        context_name: @datastore_context_name,
        description: "MsBmsSystAuthentication Testing App User",
        database_role: "msbms_syst_authentication_app_user",
        database_password: "msbms_syst_authentication.testing.code.app.user",
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
      db_max_instances: 1,
      server_pools: [],
      server_salt: "msbms_syst_authentication.testing.code.test.salt",
      dbadmin_password: "msbms.syst.dba.testing.password",
      dbadmin_pool_size: 1
    }
  }

  @migration_test_source_root_dir "../../../database"
  @migration_unit_test_ds_type "cmp_msbms_syst_authentication_unit_test"
  @migration_integration_test_ds_type "cmp_msbms_syst_authentication_integration_test"

  @mnesia_database_location Path.join([".mnesia"])

  def setup_testing_database(test_kind) do
    setup_rate_limiter(test_kind)

    :ok = build_migrations(test_kind)

    datastore_options = @datastore_options
    datastore_type = get_datastore_type(test_kind)

    database_owner = Enum.find(datastore_options.contexts, &(&1[:database_owner_context] == true))

    {:ok, :ready, _} = MsbmsSystDatastore.create_datastore(datastore_options)

    {:ok, _} =
      MsbmsSystDatastore.upgrade_datastore(
        datastore_options,
        datastore_type,
        msbms_owner: database_owner.database_role,
        msbms_appusr: "msbms_syst_authentication_app_user"
      )

    {:ok, _, _} = MsbmsSystDatastore.start_datastore(datastore_options)
  end

  defp setup_rate_limiter(:unit_testing), do: MsbmsSystRateLimiter.init_rate_limiter()

  defp setup_rate_limiter(:integration_testing) do
    File.mkdir_p!(@mnesia_database_location)
    Application.put_env(:mnesia, :dir, @mnesia_database_location)

    :mnesia.stop()
    :mnesia.create_schema([node()])
    :mnesia.start()

    MsbmsSystRateLimiter.init_rate_limiter()
  end

  def cleanup_testing_database(test_kind) do
    cleanup_rate_limiter(test_kind)

    datastore_type = get_datastore_type(test_kind)
    datastore_options = @datastore_options

    :ok = MsbmsSystDatastore.stop_datastore(datastore_options)
    :ok = MsbmsSystDatastore.drop_datastore(datastore_options)
    File.rm_rf!(Path.join(["priv/database", datastore_type]))
  end

  defp cleanup_rate_limiter(:integration_testing), do: File.rm_rf!(@mnesia_database_location)
  defp cleanup_rate_limiter(_), do: nil

  def get_testing_datastore_context_id, do: @datastore_context_name

  defp get_datastore_type(:unit_testing), do: @migration_unit_test_ds_type
  defp get_datastore_type(:integration_testing), do: @migration_integration_test_ds_type

  defp build_migrations(test_kind) do
    Builddb.run([
      "-t",
      get_datastore_type(test_kind),
      "-c",
      "-s",
      @migration_test_source_root_dir
    ])
  end
end
