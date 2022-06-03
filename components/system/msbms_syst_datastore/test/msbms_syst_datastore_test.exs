defmodule MsbmsSystDatastoreTest do
  use ExUnit.Case, async: false

  alias Mix.Tasks.Builddb

  @datastore_options_type_one %{
    database_name: "msbms_test_type_one",
    database_owner: "msbms_test_type_one_owner",
    datastore_code: "datastore_code_test_type_one",
    datastore_name: :msbms_type_one_datastore,
    contexts: [
      %{
        id: nil,
        description: "Type One Owner",
        database_role: "msbms_test_type_one_owner",
        database_password: nil,
        starting_pool_size: 0,
        start_context: false,
        login_context: false
      },
      %{
        id: :msbms_type_one_role_01,
        description: "Type One Role 01 ",
        database_role: "msbms_type_one_role_01",
        database_password: 'type_one_role_01',
        starting_pool_size: 3,
        start_context: true,
        login_context: true
      },
      %{
        id: :msbms_type_one_role_02,
        description: "Type One Role 02 ",
        database_role: "msbms_type_one_role_02",
        database_password: 'type_one_role_02',
        starting_pool_size: 3,
        start_context: true,
        login_context: true
      }
    ],
    db_server: %{
      server_name: "test_server",
      start_server_instances: true,
      server_pools: [],
      db_host: "127.0.0.1",
      db_port: 5432,
      db_show_sensitive: true,
      db_log_level: :debug,
      db_max_instances: 1,
      server_salt: "test",
      dbadmin_password: "msbms.syst.dba.testing.password",
      dbadmin_pool_size: 1
    }
  }

  @context_type_one_group_two [
    %{
      id: :msbms_type_one_role_03,
      description: "Type One Role 03 ",
      database_role: "msbms_type_one_role_03",
      database_password: 'type_one_role_03',
      starting_pool_size: 3,
      start_context: true,
      login_context: true
    },
    %{
      id: :msbms_type_one_role_04,
      description: "Type One Role 04 ",
      database_role: "msbms_type_one_role_04",
      database_password: 'type_one_role_04',
      starting_pool_size: 3,
      start_context: true,
      login_context: true
    }
  ]

  @migration_test_source_root_dir "database/migration_test"
  @migration_test_migrations_root_dir "priv/database/migration_test"
  @migration_test_datastore_type "test_type_four"
  @migration_test_opts [migrations_root_dir: @migration_test_migrations_root_dir]

  @migration_test_datastore_options %{
    database_name: "msbms_test_type_four",
    database_owner: "msbms_test_type_four_owner",
    datastore_code: "datastore_code_test_type_four",
    datastore_name: :msbms_type_four_datastore,
    contexts: [
      %{
        id: nil,
        description: "Type Four Owner",
        database_role: "msbms_test_type_four_owner",
        database_password: nil,
        starting_pool_size: 0,
        start_context: false,
        login_context: false
      },
      %{
        id: :msbms_type_four_role_01,
        description: "Type Four Role 01 ",
        database_role: "msbms_type_four_role_01",
        database_password: 'type_four_role_01',
        starting_pool_size: 3,
        start_context: true,
        login_context: true
      }
    ],
    db_server: %{
      server_name: "test_server",
      start_server_instances: true,
      server_pools: [],
      db_host: "127.0.0.1",
      db_port: 5432,
      db_show_sensitive: true,
      db_log_level: :debug,
      db_max_instances: 1,
      server_salt: "test",
      dbadmin_password: "msbms.syst.dba.testing.password",
      dbadmin_pool_size: 1
    }
  }

  defp setup_first_stage_migration_test do
    Builddb.run([
      "-t",
      "test_type_four",
      "-c",
      "-s",
      @migration_test_source_root_dir,
      "-d",
      @migration_test_migrations_root_dir
    ])

    (@migration_test_migrations_root_dir <>
       "/test_type_four/test_type_four.{02,03}.??.???.0000MS.???.eex.sql")
    |> Path.wildcard()
    |> Enum.each(&File.rm!(&1))
  end

  defp setup_second_stage_migration_test do
    Builddb.run([
      "-t",
      "test_type_four",
      "-s",
      @migration_test_source_root_dir,
      "-d",
      @migration_test_migrations_root_dir
    ])
  end

  doctest MsbmsSystDatastore

  test "Basic datastore management" do
    # Create a datastore with contexts
    assert {:ok, :ready, context_states} =
             MsbmsSystDatastore.create_datastore(@datastore_options_type_one)

    assert 3 = length(context_states)

    # Create additional contexts for the just created datastore
    assert {:ok, context_states} =
             MsbmsSystDatastore.create_datastore_contexts(
               @datastore_options_type_one,
               @context_type_one_group_two
             )

    assert 2 = length(context_states)

    # Get datastore state after contexts added
    new_datastore_options =
      @datastore_options_type_one
      |> Map.update(:contexts, [], &(&1 ++ @context_type_one_group_two))

    assert {:ok, :ready, context_states} =
             MsbmsSystDatastore.get_datastore_state(new_datastore_options)

    assert 4 = length(context_states)

    # Drop contexts from an existing datastore.
    assert :ok =
             MsbmsSystDatastore.drop_datastore_contexts(
               @datastore_options_type_one,
               @context_type_one_group_two
             )

    # Get datastore state after added contexts dropped
    assert {:ok, :ready, context_states} =
             MsbmsSystDatastore.get_datastore_state(@datastore_options_type_one)

    assert 2 = length(context_states)

    # Get datastore context states
    assert {:ok, context_states} =
             MsbmsSystDatastore.get_datastore_context_states(@datastore_options_type_one)

    assert 2 = length(context_states)

    assert true =
             context_states
             |> Enum.reduce(true, &(&1.state == :ready and &2))

    # Drop the datastore
    assert :ok = MsbmsSystDatastore.drop_datastore(@datastore_options_type_one)
  end

  test "Migrations & Querying" do
    :ok = setup_first_stage_migration_test()

    datastore_options = @migration_test_datastore_options

    {:ok, :ready, _} = MsbmsSystDatastore.create_datastore(datastore_options)

    assert {:ok, :all_started, _contexts} = MsbmsSystDatastore.start_datastore(datastore_options)

    assert {:ok, first_stage_migrations_applied} =
             MsbmsSystDatastore.upgrade_datastore(
               datastore_options,
               @migration_test_datastore_type,
               [msbms_owner: datastore_options.database_owner],
               @migration_test_opts
             )

    MsbmsSystDatastore.set_datastore_context(:msbms_type_four_role_01)

    assert 3 = length(first_stage_migrations_applied)

    assert :ok = MsbmsSystDatastore.query_for_none("SELECT true;")

    assert {:ok, 2} =
             MsbmsSystDatastore.query_for_value(
               "SELECT count(id) AS rec_count FROM msbms_test.test_type_four;"
             )

    assert {:ok, %{num_rows: 2}} =
             MsbmsSystDatastore.query_for_many("SELECT * FROM msbms_test.test_type_four;")

    :ok = setup_second_stage_migration_test()

    assert {:ok, second_stage_migrations_applied} =
             MsbmsSystDatastore.upgrade_datastore(
               datastore_options,
               @migration_test_datastore_type,
               [msbms_owner: datastore_options.database_owner],
               @migration_test_opts
             )

    assert 8 = length(second_stage_migrations_applied)

    MsbmsSystDatastore.set_datastore_context(:msbms_type_four_role_01)

    assert {:ok, 10} =
             MsbmsSystDatastore.query_for_value(
               "SELECT count(id) AS rec_count FROM msbms_test.test_type_four;"
             )

    assert {:ok, %{num_rows: 10}} =
             MsbmsSystDatastore.query_for_many("SELECT * FROM msbms_test.test_type_four;")

    assert :ok = MsbmsSystDatastore.stop_datastore(datastore_options)

    assert :ok = MsbmsSystDatastore.drop_datastore(datastore_options)
  end
end
