# Source File: dev_support.ex
# Location:    musebms/components/system/mscmp_syst_settings/dev_support/dev_support.ex
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

  use MscmpSystDb.Macros
  use MscmpSystSettings.Macros

  db_devsupport(:dev)
  settings_devsupport(:dev)

  @migration_test_source_root_dir "../../../../database"
  @migration_unit_test_ds_type "mscmp_syst_settings_unit_test"
  @migration_integration_test_ds_type "mscmp_syst_settings_integration_test"
  @migration_doc_test_ds_type "mscmp_syst_settings_doc_test"

  @registry :"MscmpSystSettings.DevSupportRegistry"
  @datastore_context_name {:via, Registry, {@registry, @db_support_context_name}}

  def start_dev_environment(db_kind \\ :unit_testing) do
     children =
      [
        Registry.child_spec(keys: :unique, name: @registry),
        setup_database(db_kind),
        MscmpSystSettings.child_spec(
          service_name: @settings_service_name, datastore_context_name: @datastore_context_name )
      ]

      {:ok, _pid} =
        Supervisor.start_link(
          children, strategy: :one_for_one, name: :"MscmpSystSettings.DevSupportSupervisor")

    _ = MscmpSystDb.put_datastore_context(@datastore_context_name)
    _ = MscmpSystSettings.put_settings_service(@settings_service_name)

    :ok
  end

  def stop_dev_environment do
    _ = cleanup_database()
    Supervisor.stop(:"MscmpSystSettings.DevSupportSupervisor")
  end

  defp setup_database(db_kind) do
    datastore_options = get_datastore_options()

    :ok = build_migrations(db_kind)

    {:ok, _} = load_database(datastore_options, get_datastore_type(db_kind))

    MscmpSystDb.Datastore.child_spec(datastore_options, context_registry: @registry )
  end

  defp cleanup_database(db_kind \\ :unit_testing) do
    datastore_options = get_datastore_options()

    :ok = drop_database(datastore_options, context_registry: @registry)

    File.rm_rf!(Path.join(["priv", "database", get_datastore_type(db_kind)]))
  end

  defp get_datastore_type(:unit_testing), do: @migration_unit_test_ds_type
  defp get_datastore_type(:integration_testing), do: @migration_integration_test_ds_type
  defp get_datastore_type(:doc_testing), do: @migration_doc_test_ds_type

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
