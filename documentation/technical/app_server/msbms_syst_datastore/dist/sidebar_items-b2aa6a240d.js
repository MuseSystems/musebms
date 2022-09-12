sidebarNodes={"extras":[{"group":"","headers":[{"anchor":"modules","id":"Modules"},{"anchor":"mix-tasks","id":"Mix Tasks"}],"id":"api-reference","title":"API Reference"}],"modules":[{"group":"","id":"MsbmsSystDatastore.DbTypes","nodeGroups":[{"key":"types","name":"Types","nodes":[{"anchor":"t:t/0","id":"t/0"}]},{"key":"functions","name":"Functions","nodes":[{"anchor":"compare/2","id":"compare/2"},{"anchor":"test_compare/3","id":"test_compare/3"}]}],"sections":[],"title":"MsbmsSystDatastore.DbTypes"},{"group":"API","id":"MsbmsSystDatastore","nodeGroups":[{"key":"api-query","name":"API - Query","nodes":[{"anchor":"aggregate/4","id":"aggregate/4"},{"anchor":"all/2","id":"all/2"},{"anchor":"delete!/2","id":"delete!/2"},{"anchor":"delete/2","id":"delete/2"},{"anchor":"delete_all/2","id":"delete_all/2"},{"anchor":"exists?/2","id":"exists?/2"},{"anchor":"get!/3","id":"get!/3"},{"anchor":"get/3","id":"get/3"},{"anchor":"get_by!/3","id":"get_by!/3"},{"anchor":"get_by/3","id":"get_by/3"},{"anchor":"in_transaction?/0","id":"in_transaction?/0"},{"anchor":"insert!/2","id":"insert!/2"},{"anchor":"insert/2","id":"insert/2"},{"anchor":"insert_all/3","id":"insert_all/3"},{"anchor":"insert_or_update!/2","id":"insert_or_update!/2"},{"anchor":"insert_or_update/2","id":"insert_or_update/2"},{"anchor":"load/2","id":"load/2"},{"anchor":"one!/2","id":"one!/2"},{"anchor":"one/2","id":"one/2"},{"anchor":"preload/3","id":"preload/3"},{"anchor":"prepare_query/3","id":"prepare_query/3"},{"anchor":"query_for_many!/3","id":"query_for_many!/3"},{"anchor":"query_for_many/3","id":"query_for_many/3"},{"anchor":"query_for_none!/3","id":"query_for_none!/3"},{"anchor":"query_for_none/3","id":"query_for_none/3"},{"anchor":"query_for_one!/3","id":"query_for_one!/3"},{"anchor":"query_for_one/3","id":"query_for_one/3"},{"anchor":"query_for_value!/3","id":"query_for_value!/3"},{"anchor":"query_for_value/3","id":"query_for_value/3"},{"anchor":"record_count/2","id":"record_count/2"},{"anchor":"reload!/2","id":"reload!/2"},{"anchor":"reload/2","id":"reload/2"},{"anchor":"rollback/1","id":"rollback/1"},{"anchor":"stream/2","id":"stream/2"},{"anchor":"transaction/2","id":"transaction/2"},{"anchor":"update!/2","id":"update!/2"},{"anchor":"update/2","id":"update/2"},{"anchor":"update_all/3","id":"update_all/3"}]},{"key":"api-runtime","name":"API - Runtime","nodes":[{"anchor":"current_datastore_context/0","id":"current_datastore_context/0"},{"anchor":"set_datastore_context/1","id":"set_datastore_context/1"},{"anchor":"start_datastore/2","id":"start_datastore/2"},{"anchor":"start_datastore_context/2","id":"start_datastore_context/2"},{"anchor":"stop_datastore/2","id":"stop_datastore/2"},{"anchor":"stop_datastore_context/2","id":"stop_datastore_context/2"}]},{"key":"api-datastore-migrations","name":"API - Datastore Migrations","nodes":[{"anchor":"get_datastore_version/2","id":"get_datastore_version/2"},{"anchor":"upgrade_datastore/4","id":"upgrade_datastore/4"}]},{"key":"api-datastore-management","name":"API - Datastore Management","nodes":[{"anchor":"create_datastore/2","id":"create_datastore/2"},{"anchor":"create_datastore_contexts/3","id":"create_datastore_contexts/3"},{"anchor":"drop_datastore/2","id":"drop_datastore/2"},{"anchor":"drop_datastore_contexts/3","id":"drop_datastore_contexts/3"},{"anchor":"get_datastore_context_states/2","id":"get_datastore_context_states/2"},{"anchor":"get_datastore_state/2","id":"get_datastore_state/2"}]}],"sections":[],"title":"MsbmsSystDatastore"},{"group":"Supporting Types","id":"MsbmsSystDatastore.Types","nodeGroups":[{"key":"types","name":"Types","nodes":[{"anchor":"t:context_name/0","id":"context_name/0"},{"anchor":"t:context_role/0","id":"context_role/0"},{"anchor":"t:context_state/0","id":"context_state/0"},{"anchor":"t:context_state_values/0","id":"context_state_values/0"},{"anchor":"t:database_state_values/0","id":"database_state_values/0"},{"anchor":"t:datastore_context/0","id":"datastore_context/0"},{"anchor":"t:datastore_options/0","id":"datastore_options/0"},{"anchor":"t:db_server/0","id":"db_server/0"},{"anchor":"t:db_type_comparison_operators/0","id":"db_type_comparison_operators/0"},{"anchor":"t:migration_state_values/0","id":"migration_state_values/0"}]}],"sections":[],"title":"MsbmsSystDatastore.Types"},{"group":"Database Types","id":"MsbmsSystDatastore.DbTypes.DateRange","nested_context":"MsbmsSystDatastore.DbTypes","nested_title":".DateRange","nodeGroups":[{"key":"types","name":"Types","nodes":[{"anchor":"t:t/0","id":"t/0"}]},{"key":"functions","name":"Functions","nodes":[{"anchor":"embed_as/1","id":"embed_as/1"},{"anchor":"equal?/2","id":"equal?/2"}]}],"sections":[],"title":"MsbmsSystDatastore.DbTypes.DateRange"},{"group":"Database Types","id":"MsbmsSystDatastore.DbTypes.DateTimeRange","nested_context":"MsbmsSystDatastore.DbTypes","nested_title":".DateTimeRange","nodeGroups":[{"key":"types","name":"Types","nodes":[{"anchor":"t:t/0","id":"t/0"}]},{"key":"functions","name":"Functions","nodes":[{"anchor":"embed_as/1","id":"embed_as/1"},{"anchor":"equal?/2","id":"equal?/2"}]}],"sections":[],"title":"MsbmsSystDatastore.DbTypes.DateTimeRange"},{"group":"Database Types","id":"MsbmsSystDatastore.DbTypes.DecimalRange","nested_context":"MsbmsSystDatastore.DbTypes","nested_title":".DecimalRange","nodeGroups":[{"key":"types","name":"Types","nodes":[{"anchor":"t:t/0","id":"t/0"}]},{"key":"functions","name":"Functions","nodes":[{"anchor":"embed_as/1","id":"embed_as/1"},{"anchor":"equal?/2","id":"equal?/2"}]}],"sections":[],"title":"MsbmsSystDatastore.DbTypes.DecimalRange"},{"group":"Database Types","id":"MsbmsSystDatastore.DbTypes.Inet","nested_context":"MsbmsSystDatastore.DbTypes","nested_title":".Inet","nodeGroups":[{"key":"types","name":"Types","nodes":[{"anchor":"t:t/0","id":"t/0"}]},{"key":"functions","name":"Functions","nodes":[{"anchor":"embed_as/1","id":"embed_as/1"},{"anchor":"equal?/2","id":"equal?/2"}]}],"sections":[],"title":"MsbmsSystDatastore.DbTypes.Inet"},{"group":"Database Types","id":"MsbmsSystDatastore.DbTypes.IntegerRange","nested_context":"MsbmsSystDatastore.DbTypes","nested_title":".IntegerRange","nodeGroups":[{"key":"types","name":"Types","nodes":[{"anchor":"t:t/0","id":"t/0"}]},{"key":"functions","name":"Functions","nodes":[{"anchor":"embed_as/1","id":"embed_as/1"},{"anchor":"equal?/2","id":"equal?/2"}]}],"sections":[],"title":"MsbmsSystDatastore.DbTypes.IntegerRange"},{"group":"Database Types","id":"MsbmsSystDatastore.DbTypes.Interval","nested_context":"MsbmsSystDatastore.DbTypes","nested_title":".Interval","nodeGroups":[{"key":"types","name":"Types","nodes":[{"anchor":"t:t/0","id":"t/0"}]},{"key":"functions","name":"Functions","nodes":[{"anchor":"embed_as/1","id":"embed_as/1"},{"anchor":"equal?/2","id":"equal?/2"}]}],"sections":[],"title":"MsbmsSystDatastore.DbTypes.Interval"},{"group":"Datastore Service","id":"MsbmsSystDatastore.Datastore","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"child_spec/2","id":"child_spec/2"},{"anchor":"start_link/1","id":"start_link/1"}]}],"sections":[],"title":"MsbmsSystDatastore.Datastore"},{"group":"Datastore Context Service","id":"MsbmsSystDatastore.DatastoreContext","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"child_spec/3","id":"child_spec/3"},{"anchor":"start_link/1","id":"start_link/1"}]}],"sections":[],"title":"MsbmsSystDatastore.DatastoreContext"},{"group":"Schema","id":"MsbmsSystDatastore.Schema","sections":[],"title":"MsbmsSystDatastore.Schema"}],"tasks":[{"group":"","id":"Mix.Tasks.Builddb","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"run/1","id":"run/1"}]}],"sections":[{"anchor":"module-options","id":"Options:"},{"anchor":"module-description","id":"Description:"}],"title":"mix builddb"}]}