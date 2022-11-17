# Source File: dev_support.ex
# Location:    musebms/components/system/mscmp_syst_authn/dev_support/dev_support.ex
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

  @migration_test_source_root_dir "../../../database"
  @migration_unit_test_ds_type "mscmp_syst_instance_unit_test"
  @migration_integration_test_ds_type "mscmp_syst_instance_integration_test"

  @datastore_context_name :dev_app_database

  @datastore_options %{
    database_name: "msbms_dev_database",
    datastore_code: "msbms.dev.code",
    datastore_name: :msbms_dev_database,
    contexts: [
      %{
        context_name: nil,
        description: "MSBMS Development Owner",
        database_role: "msbms_dev_owner",
        database_password: nil,
        starting_pool_size: 0,
        start_context: false,
        login_context: false,
        database_owner_context: true
      },
      %{
        context_name: @datastore_context_name,
        description: "MSBMS Development App User",
        database_role: "msbms_dev_app_user",
        database_password: "msbms.dev.code.app.user",
        starting_pool_size: 20,
        start_context: true,
        login_context: true
      }
    ],
    db_server: %{
      server_name: "dev_server",
      start_server_instances: true,
      db_host: "127.0.0.1",
      db_port: 5432,
      db_show_sensitive: true,
      db_max_instances: 1,
      server_pools: [],
      server_salt: "msbms.dev.code.test.salt",
      dbadmin_password: "msbms.syst.dba.testing.password",
      dbadmin_pool_size: 1
    }
  }

  def start_dev_environment(db_kind \\ :unit_testing) do
    _ = setup_database(db_kind)

    _ = MscmpSystDb.set_datastore_context(get_datastore_context_id())

    enum_service_spec = %{
      id: MsbmsDevEnumService,
      start: {
        MscmpSystEnums,
        :start_link,
        [{:msbms_dev_enum_service, get_datastore_context_id()}]
      }
    }

    children = [
      {DynamicSupervisor, strategy: :one_for_one, name: Msbms.DevSupervisor}
    ]

    _ = Supervisor.start_link(children, strategy: :one_for_one)
    Logger.configure(level: :info)

    _ = DynamicSupervisor.start_child(Msbms.DevSupervisor, enum_service_spec)

    _ = MscmpSystEnums.put_enums_service(:msbms_dev_enum_service)
  end

  def stop_dev_environment(), do: cleanup_database()

  def get_datastore_context_id, do: @datastore_context_name

  defp setup_database(db_kind) do
    :ok = build_migrations(db_kind)

    datastore_options = @datastore_options
    datastore_type = get_datastore_type(db_kind)

    database_owner = Enum.find(datastore_options.contexts, &(&1[:database_owner_context] == true))

    {:ok, :ready, _} = MscmpSystDb.create_datastore(datastore_options)

    {:ok, _} =
      MscmpSystDb.upgrade_datastore(
        datastore_options,
        datastore_type,
        msbms_owner: database_owner.database_role,
        msbms_appusr: "msbms_dev_app_user"
      )

    {:ok, _, _} = MscmpSystDb.start_datastore(datastore_options)
  end

  defp cleanup_database() do
    datastore_options = @datastore_options

    :ok = MscmpSystDb.stop_datastore(datastore_options)
    :ok = MscmpSystDb.drop_datastore(datastore_options)
    File.rm_rf!(Path.join(["priv/database"]))
  end

  defp get_datastore_type(:unit_testing), do: @migration_unit_test_ds_type
  defp get_datastore_type(:integration_testing), do: @migration_integration_test_ds_type

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