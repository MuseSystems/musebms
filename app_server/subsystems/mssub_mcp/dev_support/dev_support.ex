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

  @migration_test_source_root_dir "../../../database"
  @migration_unit_test_ds_type "mssub_mcp_unit_test"
  @migration_integration_test_ds_type "mssub_mcp_integration_test"

  mcp_constants()

  def start_dev_environment(db_kind \\ :unit_testing) do
    :ok = build_migrations(db_kind)

    startup_options = MscmpSystOptions.get_options!("test_startup_options.toml") |> IO.inspect()

    :ignore =
      MssubMcp.Updater.start_link(
        startup_options: startup_options,
        datastore_type: get_datastore_type(db_kind)
      )

    Supervisor.start_link([{MssubMcp.Supervisor, startup_options: startup_options}],
      strategy: :one_for_one,
      name: DevSupport.Supervisor
    )
  end

  def stop_dev_environment(db_kind \\ :unit_testing), do: cleanup_database(db_kind)

  defp get_datastore_type(:unit_testing), do: @migration_unit_test_ds_type
  defp get_datastore_type(:integration_testing), do: @migration_integration_test_ds_type

  def cleanup_database(db_kind) do
    datastore_type = get_datastore_type(db_kind)

    Supervisor.stop(DevSupport.Supervisor)

    startup_options = MscmpSystOptions.get_options!("test_startup_options.toml")

    datastore_options = MssubMcp.Runtime.Options.get_datastore_options(startup_options, [])

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
