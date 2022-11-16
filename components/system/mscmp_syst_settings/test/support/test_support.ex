# Source File: test_support.ex
# Location:    musebms/components/system/mscmp_syst_settings/test/support/test_support.ex
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

  @datastore_context_name :settings_app_context

  @datastore_options %{
    database_name: "mscmp_syst_settings",
    datastore_code: "mscmp_syst_settings.testing.code",
    datastore_name: :mscmp_syst_settings,
    contexts: [
      %{
        context_name: nil,
        description: "MsBmsSystSettings Testing Owner",
        database_role: "mscmp_syst_settings_owner",
        database_password: nil,
        starting_pool_size: 0,
        start_context: false,
        login_context: false,
        database_owner_context: true
      },
      %{
        context_name: @datastore_context_name,
        description: "MsBmsSystSettings Testing App User",
        database_role: "mscmp_syst_settings_app_user",
        database_password: "mscmp_syst_settings.testing.code.app.user",
        starting_pool_size: 3,
        start_context: true,
        login_context: true
      }
    ],
    db_server: %{
      server_name: "test_server",
      start_server_instances: true,
      server_pools: [],
      db_host: "127.0.0.1",
      db_port: 5432,
      db_show_sensitive: true,
      db_max_instances: 1,
      server_salt: "mscmp_syst_settings.testing.code.test.salt",
      dbadmin_password: "msbms.syst.dba.testing.password",
      dbadmin_pool_size: 1
    }
  }

  @migration_test_source_root_dir "../../../database"
  @migration_test_datastore_type "mscmp_syst_settings_unit_test"

  def setup_testing_database do
    :ok = build_migrations()

    datastore_options = @datastore_options

    database_owner = Enum.find(datastore_options.contexts, &(&1[:database_owner_context] == true))

    {:ok, :ready, _} = MscmpSystDb.create_datastore(datastore_options)

    {:ok, _} =
      MscmpSystDb.upgrade_datastore(
        datastore_options,
        @migration_test_datastore_type,
        msbms_owner: database_owner.database_role,
        msbms_appusr: "mscmp_syst_settings_app_user"
      )

    {:ok, _, _} = MscmpSystDb.start_datastore(datastore_options)
  end

  def cleanup_testing_database do
    datastore_options = @datastore_options
    :ok = MscmpSystDb.stop_datastore(datastore_options)
    :ok = MscmpSystDb.drop_datastore(datastore_options)
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
