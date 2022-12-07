# Source File: test_support.ex
# Location:    musebms/subsystems/mssub_mcp/test/support/test_support.ex
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

  use MssubMcp.Macros

  @migration_test_source_root_dir "../../database"
  @migration_unit_test_ds_type "mssub_mcp_unit_test"
  @migration_integration_test_ds_type "mssub_mcp_integration_test"

  mcp_constants()

  def setup_testing_database(test_kind) do
    :ok = build_migrations(test_kind)

    opts = [
      owner_name: @mcp_db_owner_role,
      app_access_role_name: @mcp_db_app_access_role,
      name: @mcp_datastore_supervisor_name
    ]

    datastore_options = MssubMcp.Runtime.Options.get_datastore_options(opts)
    datastore_type = get_datastore_type(test_kind)

    database_owner = Enum.find(datastore_options.contexts, &(&1[:database_owner_context] == true))

    {:ok, _} =
      MscmpSystDb.upgrade_datastore(
        datastore_options,
        datastore_type,
        ms_owner: database_owner.database_role,
        ms_appusr: "mssub_mcp_app_access"
      )

    # This is required post upgrade because we're loading enumerations data
    # migrations after the enums service is started and initialized.  This isn't
    # an expected use case and is an artifact of our testing jury rigging.  By
    # killing the process and allowing it to restart, it refreshes its data with
    # the newly migrated values now in the database.
    #
    # TODO:  Expose the refresh from database functionality in MscmpSystEnums.

    Process.whereis(@mcp_enums_service_name) |> Process.exit(:kill)
  end

  defp get_datastore_type(:unit_testing), do: @migration_unit_test_ds_type
  defp get_datastore_type(:integration_testing), do: @migration_integration_test_ds_type

  def cleanup_testing_database(test_kind) do
    datastore_type = get_datastore_type(test_kind)

    opts = [
      owner_name: @mcp_db_owner_role,
      app_access_role_name: @mcp_db_app_access_role,
      name: @mcp_datastore_supervisor_name
    ]

    datastore_options = MssubMcp.Runtime.Options.get_datastore_options(opts)

    :ok = MscmpSystDb.stop_datastore(datastore_options)
    :ok = MscmpSystDb.drop_datastore(datastore_options)

    File.rm_rf!(Path.join(["priv/database", datastore_type]))
  end

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
