# Source File: dev_support.ex
# Location:    musebms/subsystems/mssub_mcp/dev_support/dev_support.ex
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

  use MssubMcp.Macros

  @migration_test_source_root_dir "../../database"
  @migration_unit_test_ds_type "mssub_mcp_unit_test"
  @migration_integration_test_ds_type "mssub_mcp_integration_test"

  mcp_constants()

  def start_dev_environment(db_kind \\ :unit_testing) do
    :ok = build_migrations(db_kind)

    opts = [
      owner_name: @mcp_db_owner_role,
      app_access_role_name: @mcp_db_app_access_role,
      name: @mcp_datastore_supervisor_name
    ]

    datastore_options = MssubMcp.Runtime.Options.get_datastore_options(opts)
    datastore_type = get_datastore_type(db_kind)

    {:ok, _} =
      MscmpSystDb.upgrade_datastore(
        datastore_options,
        datastore_type,
        ms_owner: @mcp_db_owner_role,
        ms_appusr: @mcp_db_app_access_role
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

  def stop_dev_environment(db_kind \\ :unit_testing), do: cleanup_database(db_kind)

  defp get_datastore_type(:unit_testing), do: @migration_unit_test_ds_type
  defp get_datastore_type(:integration_testing), do: @migration_integration_test_ds_type

  def cleanup_database(db_kind) do
    datastore_type = get_datastore_type(db_kind)

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

  defp build_migrations(db_kind) do
    Builddb.run([
      "-t",
      get_datastore_type(db_kind),
      "-c",
      "-s",
      @migration_test_source_root_dir
    ])
  end
end
