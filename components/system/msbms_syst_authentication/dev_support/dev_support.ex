# Source File: dev_support.ex
# Location:    musebms/components/system/msbms_syst_authentication/dev_support/dev_support.ex
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

  @mnesia_database_location Path.join([".mnesia"])

  @migration_test_source_root_dir "../../../database"
  @migration_unit_test_ds_type "cmp_msbms_syst_authentication_unit_test"

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
    setup_database(db_kind)
    setup_mnesia_database(db_kind)

    MsbmsSystDatastore.set_datastore_context(get_datastore_context_id())

    enum_service_spec = %{
      id: MsbmsDevEnumService,
      start: {
        MsbmsSystEnums,
        :start_link,
        [{:msbms_dev_enum_service, get_datastore_context_id()}]
      }
    }

    children = [
      {DynamicSupervisor, strategy: :one_for_one, name: Msbms.DevSupervisor}
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
    Logger.configure(level: :info)

    DynamicSupervisor.start_child(Msbms.DevSupervisor, enum_service_spec)

    MsbmsSystDatastore.set_datastore_context(get_datastore_context_id())
    MsbmsSystEnums.put_enums_service(:msbms_dev_enum_service)
  end

  def stop_dev_environment(db_kind \\ :unit_testing) do
    cleanup_database()
    cleanup_mnesia_database(db_kind)
  end

  def get_datastore_context_id, do: @datastore_context_name

  defp setup_database(db_kind) do
    :ok = build_migrations(db_kind)

    datastore_options = @datastore_options
    datastore_type = get_datastore_type(db_kind)

    database_owner = Enum.find(datastore_options.contexts, &(&1[:database_owner_context] == true))

    {:ok, :ready, _} = MsbmsSystDatastore.create_datastore(datastore_options)

    {:ok, _} =
      MsbmsSystDatastore.upgrade_datastore(
        datastore_options,
        datastore_type,
        msbms_owner: database_owner.database_role,
        msbms_appusr: "msbms_dev_app_user"
      )

    {:ok, _, _} = MsbmsSystDatastore.start_datastore(datastore_options)
  end

  defp setup_mnesia_database(:unit_testing) do
    MsbmsSystRateLimiter.init_rate_limiter()
  end

  defp cleanup_database() do
    datastore_options = @datastore_options

    :ok = MsbmsSystDatastore.stop_datastore(datastore_options)
    :ok = MsbmsSystDatastore.drop_datastore(datastore_options)
    File.rm_rf!(Path.join(["priv/database"]))
  end

  defp cleanup_mnesia_database(:unit_testing), do: nil

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
