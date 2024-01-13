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

  use MssubMcp.Macros

  alias Mix.Tasks.Builddb

  mcp_constants()

  @migration_test_source_root_dir "../../../database"
  @migration_unit_test_ds_type "mssub_mcp_unit_test"
  @migration_integration_test_ds_type "mssub_mcp_integration_test"
  @migration_doc_test_ds_type "mssub_mcp_doc_test"

  def setup_testing_database(test_kind, startup_options) do
    :ok = build_migrations(test_kind)

    :ignore =
      MssubMcp.Updater.start_link(
        startup_options: startup_options,
        datastore_type: get_datastore_type(test_kind)
      )
  end

  def cleanup_testing_database(test_kind, startup_options) do
    datastore_type = get_datastore_type(test_kind)

    datastore_options = MssubMcp.Runtime.Options.get_datastore_options(startup_options, [])

    :ok = MscmpSystDb.stop_datastore(datastore_options)
    :ok = MscmpSystDb.drop_datastore(datastore_options)

    File.rm_rf!(Path.join(["priv/database", datastore_type]))
  end

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
