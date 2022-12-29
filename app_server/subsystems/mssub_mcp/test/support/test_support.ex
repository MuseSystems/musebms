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

  mcp_constants()

  @migration_test_source_root_dir "../../../database"
  @migration_unit_test_ds_type "mssub_mcp_unit_test"
  @migration_integration_test_ds_type "mssub_mcp_integration_test"

  @mnesia_database_location Path.join([".mnesia"])

  def setup_testing_database(test_kind, startup_options) do
    setup_rate_limiter(test_kind)

    :ok = build_migrations(test_kind)

    :ignore =
      MssubMcp.Updater.start_link(
        startup_options: startup_options,
        datastore_type: get_datastore_type(test_kind)
      )
  end

  defp setup_rate_limiter(:unit_testing), do: nil

  defp setup_rate_limiter(:integration_testing) do
    File.mkdir_p!(@mnesia_database_location)
    Application.put_env(:mnesia, :dir, @mnesia_database_location)

    :mnesia.stop()
    :mnesia.create_schema([node()])
    :mnesia.start()
  end

  def cleanup_testing_database(test_kind, startup_options) do
    cleanup_rate_limiter(test_kind)

    datastore_type = get_datastore_type(test_kind)

    datastore_options = MssubMcp.Runtime.Options.get_datastore_options(startup_options, [])

    :ok = MscmpSystDb.stop_datastore(datastore_options)
    :ok = MscmpSystDb.drop_datastore(datastore_options)

    File.rm_rf!(Path.join(["priv/database", datastore_type]))
  end

  defp cleanup_rate_limiter(:integration_testing), do: File.rm_rf!(@mnesia_database_location)
  defp cleanup_rate_limiter(_), do: nil

  def get_testing_datastore_context_id, do: @mcp_db_app_access_context

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
