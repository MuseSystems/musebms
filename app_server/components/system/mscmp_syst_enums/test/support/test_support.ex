# Source File: test_support.ex
# Location:    musebms/components/system/mscmp_syst_enums/test/support/test_support.ex
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

  @migration_test_source_root_dir "../../../../database"
  @migration_unit_test_ds_type "mscmp_syst_enums_unit_test"
  @migration_integration_test_ds_type "mscmp_syst_enums_integration_test"
  @migration_doc_test_ds_type "mscmp_syst_enums_doc_test"

  def setup_testing_database(test_kind) do
    datastore_options = MscmpSystDb.get_testsupport_datastore_options()

    :ok = build_migrations(test_kind)

    {:ok, _} = MscmpSystDb.load_database(datastore_options, get_datastore_type(test_kind))

    {:ok, _, _} = MscmpSystDb.start_datastore(datastore_options)
  end

  def cleanup_testing_database(test_kind) do
    datastore_options = MscmpSystDb.get_testsupport_datastore_options()

    :ok = MscmpSystDb.drop_database(datastore_options)

    _ = File.rm_rf!(Path.join(["priv", "database", get_datastore_type(test_kind)]))
  end

  defp get_datastore_type(:unit_testing), do: @migration_unit_test_ds_type
  defp get_datastore_type(:integration_testing), do: @migration_integration_test_ds_type
  defp get_datastore_type(:doc_testing), do: @migration_doc_test_ds_type

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
