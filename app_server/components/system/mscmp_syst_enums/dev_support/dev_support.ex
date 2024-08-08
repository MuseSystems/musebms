# Source File: dev_support.ex
# Location:    musebms/components/system/mscmp_syst_enums/dev_support/dev_support.ex
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

  @migration_test_source_root_dir "../../../../database"
  @migration_unit_test_ds_type "mscmp_syst_enums_unit_test"

  @registry :"MscmpSystEnums.DevSupportRegistry"

  def start_dev_environment(db_kind \\ :unit_testing) do

    _ = Registry.start_link(name: @registry, keys: :unique)

    _ = setup_database(db_kind)

    datastore_context_name = {:via, Registry, {@registry, MscmpSystDb.get_devsupport_context_name()}}

    _ = MscmpSystDb.put_datastore_context(datastore_context_name)

    _ = MscmpSystEnums.start_devsupport_services(datastore_context_name: datastore_context_name)

    _ = MscmpSystEnums.put_enums_service(MscmpSystEnums.get_devsupport_service_name)
  end

  def stop_dev_environment do
    _ = MscmpSystEnums.stop_devsupport_services()
    cleanup_database()
  end

  defp setup_database(db_kind) do
    datastore_options = MscmpSystDb.get_devsupport_datastore_options()

    :ok = build_migrations(db_kind)

    {:ok, _} = MscmpSystDb.load_database(datastore_options, get_datastore_type(db_kind))

    {:ok, _, _} = MscmpSystDb.start_datastore(datastore_options, context_registry: @registry)

  end

  defp cleanup_database() do
    datastore_options = MscmpSystDb.get_devsupport_datastore_options()

    :ok = MscmpSystDb.drop_database(datastore_options, context_registry: @registry)

    _ = File.rm_rf!(Path.join(["priv", "database", @migration_unit_test_ds_type]))
  end

  defp get_datastore_type(:unit_testing), do: @migration_unit_test_ds_type

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
