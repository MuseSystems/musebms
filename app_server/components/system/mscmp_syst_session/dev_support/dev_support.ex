# Source File: dev_support.ex
# Location:    musebms/components/system/mscmp_syst_session/dev_support/dev_support.ex
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
  @migration_unit_test_ds_type "mscmp_syst_session_unit_test"
  @migration_integration_test_ds_type "mscmp_syst_session_integration_test"
  @migration_doc_test_ds_type "mscmp_syst_session_doc_test"

  def start_dev_environment(db_kind \\ :unit_testing) do
    _ = setup_database(db_kind)

    _ = MscmpSystDb.put_datastore_context(MscmpSystDb.get_devsupport_context_name())
  end

  def stop_dev_environment(), do: cleanup_database()

  defp setup_database(db_kind) do
    datastore_options = MscmpSystDb.get_devsupport_datastore_options()

    :ok = build_migrations(db_kind)

    {:ok, _} = MscmpSystDb.load_database(datastore_options, get_datastore_type(db_kind))

    {:ok, _, _} = MscmpSystDb.start_datastore(datastore_options)
  end

  defp cleanup_database(db_kind \\ :unit_testing) do
    datastore_options = MscmpSystDb.get_devsupport_datastore_options()

    :ok = MscmpSystDb.drop_database(datastore_options)

    _ = File.rm_rf!(Path.join(["priv", "database", get_datastore_type(db_kind)]))
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
