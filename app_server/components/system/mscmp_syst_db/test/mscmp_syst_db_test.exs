defmodule MscmpSystDbTest do
  @moduledoc false

  use ExUnit.Case, async: false

  alias Mix.Tasks.Builddb
  alias MscmpSystDb.Types.{DatastoreContext, DatastoreOptions, DbServer}

  @datastore_options_type_one %DatastoreOptions{
    database_name: "ms_test_type_one",
    datastore_code: "datastore_code_test_type_one",
    datastore_name: "ms_type_one_datastore",
    contexts: [
      %DatastoreContext{
        context_name: nil,
        description: "Type One Owner",
        database_role: "ms_test_type_one_owner",
        database_password: nil,
        starting_pool_size: 0,
        start_context: false,
        login_context: false,
        database_owner_context: true
      },
      %DatastoreContext{
        context_name: "ms_type_one_role_01",
        description: "Type One Role 01 ",
        database_role: "ms_type_one_role_01",
        database_password: "type_one_role_01",
        starting_pool_size: 3,
        start_context: true,
        login_context: true
      },
      %DatastoreContext{
        context_name: "ms_type_one_role_02",
        description: "Type One Role 02 ",
        database_role: "ms_type_one_role_02",
        database_password: "type_one_role_02",
        starting_pool_size: 3,
        start_context: true,
        login_context: true,
        database_owner_context: false
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
      server_salt: "test",
      dbadmin_password: "musesystems.publicly.known.insecure.devsupport.password",
      dbadmin_pool_size: 1
    }
  }

  @context_type_one_group_two [
    %DatastoreContext{
      context_name: "ms_type_one_role_03",
      description: "Type One Role 03 ",
      database_role: "ms_type_one_role_03",
      database_password: "type_one_role_03",
      starting_pool_size: 3,
      start_context: true,
      login_context: true
    },
    %DatastoreContext{
      context_name: "ms_type_one_role_04",
      description: "Type One Role 04 ",
      database_role: "ms_type_one_role_04",
      database_password: "type_one_role_04",
      starting_pool_size: 3,
      start_context: true,
      login_context: true,
      database_owner_context: false
    }
  ]

  @migration_test_source_root_dir "database/migration_test"
  @migration_test_migrations_root_dir "priv/database/migration_test"
  @migration_test_datastore_type "test_type_four"
  @migration_test_opts [migrations_root_dir: @migration_test_migrations_root_dir]

  @migration_test_datastore_options %DatastoreOptions{
    database_name: "ms_test_type_four",
    datastore_code: "datastore_code_test_type_four",
    datastore_name: "ms_type_four_datastore",
    contexts: [
      %DatastoreContext{
        context_name: nil,
        description: "Type Four Owner",
        database_role: "ms_test_type_four_owner",
        database_password: nil,
        starting_pool_size: 0,
        start_context: false,
        login_context: false,
        database_owner_context: true
      },
      %DatastoreContext{
        context_name: "ms_type_four_role_01",
        description: "Type Four Role 01 ",
        database_role: "ms_type_four_role_01",
        database_password: "type_four_role_01",
        starting_pool_size: 3,
        start_context: true,
        login_context: true,
        database_owner_context: false
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
      server_salt: "test",
      dbadmin_password: "musesystems.publicly.known.insecure.devsupport.password",
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

  doctest MscmpSystDb

  test "Basic datastore management" do
    # Create a datastore with contexts
    assert {:ok, :ready, context_states} =
             MscmpSystDb.create_datastore(@datastore_options_type_one)

    assert 3 = length(context_states)

    # Create additional contexts for the just created datastore
    assert {:ok, context_states} =
             MscmpSystDb.create_datastore_contexts(
               @datastore_options_type_one,
               @context_type_one_group_two
             )

    assert 2 = length(context_states)

    # Get datastore state after contexts added
    new_datastore_options =
      @datastore_options_type_one
      |> Map.update(:contexts, [], &(&1 ++ @context_type_one_group_two))

    assert {:ok, :ready, context_states} = MscmpSystDb.get_datastore_state(new_datastore_options)

    assert 4 = length(context_states)

    # Drop contexts from an existing datastore.
    assert :ok =
             MscmpSystDb.drop_datastore_contexts(
               @datastore_options_type_one,
               @context_type_one_group_two
             )

    # Get datastore state after added contexts dropped
    assert {:ok, :ready, context_states} =
             MscmpSystDb.get_datastore_state(@datastore_options_type_one)

    assert 2 = length(context_states)

    # Get datastore context states
    assert {:ok, context_states} =
             MscmpSystDb.get_datastore_context_states(@datastore_options_type_one)

    assert 2 = length(context_states)

    assert true =
             context_states
             |> Enum.reduce(true, &(&1.state == :ready and &2))

    # Drop the datastore
    assert :ok = MscmpSystDb.drop_datastore(@datastore_options_type_one)
  end

  test "Migrations & Querying" do
    :ok = setup_first_stage_migration_test()

    datastore_options = @migration_test_datastore_options

    database_owner = Enum.find(datastore_options.contexts, &(&1.database_owner_context == true))

    {:ok, :ready, _} = MscmpSystDb.create_datastore(datastore_options)

    {:ok, _test_supervisor_pid} =
      DynamicSupervisor.start_link(strategy: :one_for_one, name: :migration_test_supervisor)

    datastore_child_spec =
      MscmpSystDb.Datastore.child_spec(datastore_options,
        datastore_name: {:via, Registry, {MscmpSystDb.TestRegistry, "test_datastore"}},
        context_registry: MscmpSystDb.TestRegistry
      )

    assert {:ok, _datastore_pid, {:all_started, _context_states}} =
             DynamicSupervisor.start_child(:migration_test_supervisor, datastore_child_spec)

    assert {:ok, first_stage_migrations_applied} =
             MscmpSystDb.upgrade_datastore(
               datastore_options,
               @migration_test_datastore_type,
               [ms_owner: database_owner.database_role],
               @migration_test_opts
             )

    MscmpSystDb.put_datastore_context(MscmpSystDb.TestRegistry, "ms_type_four_role_01")

    assert 3 = length(first_stage_migrations_applied)

    assert :ok = MscmpSystDb.query_for_none("SELECT true;")

    assert {:ok, 2} =
             MscmpSystDb.query_for_value(
               "SELECT count(id) AS rec_count FROM ms_test.test_type_four;"
             )

    assert {:ok, %{num_rows: 2}} =
             MscmpSystDb.query_for_many("SELECT * FROM ms_test.test_type_four;")

    :ok = setup_second_stage_migration_test()

    assert {:ok, second_stage_migrations_applied} =
             MscmpSystDb.upgrade_datastore(
               datastore_options,
               @migration_test_datastore_type,
               [ms_owner: database_owner.database_role],
               @migration_test_opts
             )

    assert 8 = length(second_stage_migrations_applied)

    MscmpSystDb.put_datastore_context(MscmpSystDb.TestRegistry, "ms_type_four_role_01")

    assert {:ok, 10} =
             MscmpSystDb.query_for_value(
               "SELECT count(id) AS rec_count FROM ms_test.test_type_four;"
             )

    assert {:ok, %{num_rows: 10}} =
             MscmpSystDb.query_for_many("SELECT * FROM ms_test.test_type_four;")

    assert :ok =
             MscmpSystDb.stop_datastore(datastore_options,
               context_registry: MscmpSystDb.TestRegistry
             )

    assert :ok = MscmpSystDb.drop_datastore(datastore_options)
  end
end
