# Source File: test_support.ex
# Location:    musebms/app_server/components/application/mscmp_core_hierarchy/test/support/test_support.ex
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
  alias MscmpSystDb.Types.{DatastoreContext, DatastoreOptions, DbServer}

  @datastore_options %DatastoreOptions{
    database_name: "mscmp_core_hierarchy",
    datastore_code: "mscmp_core_hierarchy.testing.code",
    datastore_name: :mscmp_core_hierarchy,
    contexts: [
      %DatastoreContext{
        context_name: nil,
        description: "MscmpCoreHierarchy Testing Owner",
        database_role: "mscmp_core_hierarchy_owner",
        database_password: nil,
        starting_pool_size: 0,
        start_context: false,
        login_context: false,
        database_owner_context: true
      },
      %DatastoreContext{
        context_name: :hierachy_app_context,
        description: "MscmpCoreHierarchy Testing App User",
        database_role: "mscmp_core_hierarchy_app_user",
        database_password: "mscmp_core_hierarchy.testing.code.app.user",
        starting_pool_size: 20,
        start_context: true,
        login_context: true
      }
    ],
    db_server: %DbServer{
      server_name: "test_server",
      start_server_instances: true,
      server_pools: [],
      db_host: "127.0.0.1",
      db_port: 5432,
      db_show_sensitive: true,
      db_max_instances: 1,
      server_salt: "mscmp_core_hierarchy.testing.code.test.salt",
      dbadmin_password: "muse.syst.dba.testing.password",
      dbadmin_pool_size: 1
    }
  }

  @migration_test_source_root_dir "../../../../database"
  @migration_unit_test_ds_type "mscmp_core_hierarchy_unit_test"
  @migration_integration_test_ds_type "mscmp_core_hierarchy_integration_test"
  @migration_doc_test_ds_type "mscmp_core_hierarchy_doc_test"

  @datastore_context_name :hierachy_app_context

  def setup_testing_database(test_kind) do
    :ok = build_migrations(test_kind)

    datastore_options = @datastore_options
    datastore_type = get_datastore_type(test_kind)

    database_owner = Enum.find(datastore_options.contexts, &(&1.database_owner_context == true))

    {:ok, :ready, _} = MscmpSystDb.create_datastore(datastore_options)

    {:ok, _} =
      MscmpSystDb.upgrade_datastore(
        datastore_options,
        datastore_type,
        ms_owner: database_owner.database_role,
        ms_appusr: "mscmp_core_hierarchy_app_user"
      )

    {:ok, _, _} = MscmpSystDb.start_datastore(datastore_options)
  end

  def cleanup_testing_database(test_kind) do
    datastore_type = get_datastore_type(test_kind)
    datastore_options = @datastore_options

    :ok = MscmpSystDb.stop_datastore(datastore_options)
    :ok = MscmpSystDb.drop_datastore(datastore_options)

    File.rm_rf!(Path.join(["priv/database", datastore_type]))
  end

  def get_testing_datastore_context_id, do: @datastore_context_name

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
