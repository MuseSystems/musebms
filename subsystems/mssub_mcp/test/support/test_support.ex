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

  @migration_test_source_root_dir "../../database"
  @migration_unit_test_ds_type "mssub_mcp_unit_test"
  @migration_integration_test_ds_type "mssub_mcp_integration_test"

  @default_database_name "mssub_mcp"
  @default_owner_name "mssub_mcp_owner"
  @default_app_access_role_name "mssub_mcp_app_access"

  @datastore_supervisor_name MssubMcp.DatastoreSupervisor

  def setup_testing_database(test_kind) do
    :ok = build_migrations(test_kind)

    opts = [
      owner_name: @default_owner_name,
      app_access_role_name: @default_app_access_role_name,
      name: @datastore_supervisor_name
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

    {:ok, _, _} = MscmpSystDb.start_datastore(datastore_options)
  end

  defp get_datastore_type(:unit_testing), do: @migration_unit_test_ds_type
  defp get_datastore_type(:integration_testing), do: @migration_integration_test_ds_type

  def cleanup_testing_database(test_kind) do
    datastore_type = get_datastore_type(test_kind)

    opts = [
      owner_name: @default_owner_name,
      app_access_role_name: @default_app_access_role_name,
      name: @datastore_supervisor_name
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
