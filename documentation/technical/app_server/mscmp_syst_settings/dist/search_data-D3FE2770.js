searchData={"items":[{"type":"module","title":"MscmpSystSettings","doc":"A user options configuration management service.\n\nThe Settings Service provides caching and management functions for user\nconfigurable options which govern how the application operates.  Multiple\nSettings Service instances may be in operation depending on the needs of the\napplication; for example, in the case of multi-tenancy, each tenant will have\nits own instance of the Setting Service running since each tenant's needs of\nthe application may unique.\n\nOn startup, the Settings Service creates an in memory cache and populates the\ncache from the database.  Inquiries for settings are then served from the\ncache rather than the database as needed.  Operations which change the\nSettings data are written to the database and then updated in the cache.\n\nSettings maintained by this service may be changed by users at any time while\nthe application is running.  Therefore, any logic depending on the Settings\nfrom this service should be written as to be insensitive to such changes.\nLogic should avoid multiple retrievals of the same setting during any one\ntransaction.","ref":"MscmpSystSettings.html"},{"type":"function","title":"MscmpSystSettings.create_setting/1","doc":"Creates a new user defined setting.\n\nThis function creates a setting which is automatically marked as being user\ndefined.  User created settings such as those created by this function are the\nonly kind of settings which may be deleted via `delete_setting/2`.","ref":"MscmpSystSettings.html#create_setting/1"},{"type":"function","title":"Parameters - MscmpSystSettings.create_setting/1","doc":"* `creation_params`a map defining the new settings record.  The map must\n    contain the following keys:\n\n    * `internal_name` - This is the unique value which represents the name of\n      the setting and is used for latter lookup of setting values.  This key\n      should be suitable for programmatic references to the setting.\n\n    * `display_name` - A unique value used to display the setting name in user\n      interface contexts.\n\n    * `user_description` - A user visible description of the setting including\n      information describing how the setting is used in the application and\n      directions for correct usage.  Currently, the description must be at least\n      6 characters long.\n\n    other allowed values, such as the setting values themselves, are also\n    permitted here, but not required.","ref":"MscmpSystSettings.html#create_setting/1-parameters"},{"type":"function","title":"Examples - MscmpSystSettings.create_setting/1","doc":"iex> new_setting = %{\n    ...>   internal_name: \"create_example_setting\",\n    ...>   display_name: \"Create Example Setting\",\n    ...>   user_description: \"An example of setting creation.\",\n    ...>   setting_integer: 9876\n    ...> }\n    iex> MscmpSystSettings.create_setting(new_setting)\n    :ok","ref":"MscmpSystSettings.html#create_setting/1-examples"},{"type":"function","title":"MscmpSystSettings.delete_setting/1","doc":"Deletes the named user defined setting from the system.\n\nNote that this function cannot be used to delete a system defined setting.\nTrying to do so will result in a error being raised.","ref":"MscmpSystSettings.html#delete_setting/1"},{"type":"function","title":"Parameters - MscmpSystSettings.delete_setting/1","doc":"* `setting_name` - the name of the setting should be deleted.","ref":"MscmpSystSettings.html#delete_setting/1-parameters"},{"type":"function","title":"Examples - MscmpSystSettings.delete_setting/1","doc":"iex> MscmpSystSettings.delete_setting(\"delete_example_setting\")\n    :ok","ref":"MscmpSystSettings.html#delete_setting/1-examples"},{"type":"function","title":"MscmpSystSettings.get_devsupport_service_name/0","doc":"Retrieves the Settings Service Name typically used to support development.\n\nThis is a way to retrieve the standard development support name for use with\nfunctions such as `put_settings_service/1`","ref":"MscmpSystSettings.html#get_devsupport_service_name/0"},{"type":"function","title":"MscmpSystSettings.get_setting_value/2","doc":"Retrieves the value of the given type for the requested setting.","ref":"MscmpSystSettings.html#get_setting_value/2"},{"type":"function","title":"Parameters - MscmpSystSettings.get_setting_value/2","doc":"* `setting_name` - the name of the setting for which to retrieve a value.\n\n* `setting_type` - the type of value which to return.","ref":"MscmpSystSettings.html#get_setting_value/2-parameters"},{"type":"function","title":"Examples - MscmpSystSettings.get_setting_value/2","doc":"iex> MscmpSystSettings.get_setting_value(\n    ...>   \"get_example_setting\",\n    ...>   :setting_decimal_range)\n    %MscmpSystDb.DbTypes.DecimalRange{\n      lower: Decimal.new(\"1.1\"),\n      upper: Decimal.new(\"99.99\"),\n      lower_inclusive: true,\n      upper_inclusive: false\n    }","ref":"MscmpSystSettings.html#get_setting_value/2-examples"},{"type":"function","title":"MscmpSystSettings.get_setting_values/1","doc":"Retrieves all values associated with the requested setting.","ref":"MscmpSystSettings.html#get_setting_values/1"},{"type":"function","title":"Parameters - MscmpSystSettings.get_setting_values/1","doc":"* `setting_name` - the name of the setting for which to retrieve values.\n\nThe successful return of this function is an instance of the\n`Msdata.SystSettings` struct containing the values requested.","ref":"MscmpSystSettings.html#get_setting_values/1-parameters"},{"type":"function","title":"Examples - MscmpSystSettings.get_setting_values/1","doc":"iex> MscmpSystSettings.get_setting_values(\"get_example_setting\")","ref":"MscmpSystSettings.html#get_setting_values/1-examples"},{"type":"function","title":"MscmpSystSettings.get_settings_service/0","doc":"Retrieves the currently set Settings Service name or `nil` if none has been\nset.","ref":"MscmpSystSettings.html#get_settings_service/0"},{"type":"function","title":"Examples - MscmpSystSettings.get_settings_service/0","doc":"iex> MscmpSystSettings.get_settings_service()\n    :settings_test_service","ref":"MscmpSystSettings.html#get_settings_service/0-examples"},{"type":"function","title":"MscmpSystSettings.get_testsupport_service_name/0","doc":"Retrieves the Settings Service Name typically used to support testing.\n\nThis is a way to retrieve the standard testing support name for use with\nfunctions such as `put_settings_service/1`","ref":"MscmpSystSettings.html#get_testsupport_service_name/0"},{"type":"function","title":"MscmpSystSettings.list_all_settings/0","doc":"Retrieves all values for all settings.\n\nThis function returns all other setting metadata, such as the records' IDs,\ndescriptions, etc.","ref":"MscmpSystSettings.html#list_all_settings/0"},{"type":"function","title":"Examples - MscmpSystSettings.list_all_settings/0","doc":"iex> MscmpSystSettings.list_all_settings()","ref":"MscmpSystSettings.html#list_all_settings/0-examples"},{"type":"function","title":"MscmpSystSettings.put_settings_service/1","doc":"Establishes the current Settings Service instance for the process.\n\nA running system is likely to have more than one instance of the Settings\nService running.  For example, in multi-tenant applications each tenant may\nhave its own instance of the Setting Service, caching data unique to the\ntenant.\n\nCalling `MscmpSystSettings.put_settings_service/1` will set the reference to\nthe desired Settings Service instance for any subsequent MscmpSystSettings\ncalls.  The service name is set in the Process Dictionary of the process from\nwhich the calls are being made.  As such, you must call put_settings_service\nat least once for any process from which you wish to access the Settings\nService.\n\nBecause we're just thinly wrapping `Process.put/2` here, the return value will\nbe the previous value set here, or nil if no previous value was set.","ref":"MscmpSystSettings.html#put_settings_service/1"},{"type":"function","title":"Parameters - MscmpSystSettings.put_settings_service/1","doc":"* `service_name` - The name of the service which is to be set as servicing\n    the process.","ref":"MscmpSystSettings.html#put_settings_service/1-parameters"},{"type":"function","title":"Examples - MscmpSystSettings.put_settings_service/1","doc":"iex> MscmpSystSettings.put_settings_service(:settings_test_service)","ref":"MscmpSystSettings.html#put_settings_service/1-examples"},{"type":"function","title":"MscmpSystSettings.refresh_from_database/0","doc":"Refreshes the cached settings values from the database.\n\nCalling this function causes the existing cached settings to be purged from\nthe cache and the cache to be repopulated from the database using the\ndatastore context provided to `start_link/1`.","ref":"MscmpSystSettings.html#refresh_from_database/0"},{"type":"function","title":"Examples - MscmpSystSettings.refresh_from_database/0","doc":"iex> MscmpSystSettings.refresh_from_database()\n    :ok","ref":"MscmpSystSettings.html#refresh_from_database/0-examples"},{"type":"function","title":"MscmpSystSettings.set_setting_value/3","doc":"Sets the value of any one setting type for the named setting.","ref":"MscmpSystSettings.html#set_setting_value/3"},{"type":"function","title":"Parameters - MscmpSystSettings.set_setting_value/3","doc":"* `setting_name` - the name of the setting to update with the new value.\n\n  * `setting_type` - sets which of the different available value types is\n    being updated.\n\n  * `setting_value` - is the new value to set on the setting. Note that the\n    setting value must be appropriate for the `setting_type` argument or an\n    error will be raised.","ref":"MscmpSystSettings.html#set_setting_value/3-parameters"},{"type":"function","title":"Examples - MscmpSystSettings.set_setting_value/3","doc":"iex> MscmpSystSettings.set_setting_value(\n    ...>   \"set_example_setting\",\n    ...>   :setting_decimal,\n    ...>   Decimal.new(\"1029.3847\"))\n    :ok","ref":"MscmpSystSettings.html#set_setting_value/3-examples"},{"type":"function","title":"MscmpSystSettings.set_setting_values/2","doc":"Sets one or more of the available setting types for the named setting.\n\nThis function is similar to `set_setting_values/4`, except that multiple\nsetting types can have their values set at the same time.  In addition to the\ntyped setting values, the setting display name and/or user description values\nmay also be set.","ref":"MscmpSystSettings.html#set_setting_values/2"},{"type":"function","title":"Parameters - MscmpSystSettings.set_setting_values/2","doc":"* `setting_name` - the name of the setting to update with the new values.\n\n  * `update_params` - is a map that complies with the\n    `MscmpSystSettings.Types.setting_service_params()` type specification and\n    includes the updates to setting type values, updates to the `display_name`\n    value, and/or updates to the `user_description` value.","ref":"MscmpSystSettings.html#set_setting_values/2-parameters"},{"type":"function","title":"Examples - MscmpSystSettings.set_setting_values/2","doc":"iex> update_values = %{\n    ...>   user_description: \"An example of updating the user description.\",\n    ...>   setting_integer: 6758,\n    ...>   setting_date_range:\n    ...>      %MscmpSystDb.DbTypes.DateRange{\n    ...>        lower: ~D[2022-04-01],\n    ...>        upper: ~D[2022-04-12],\n    ...>        upper_inclusive: true\n    ...>      }\n    ...> }\n    iex> MscmpSystSettings.set_setting_values(\n    ...>   \"set_example_setting\",\n    ...>   update_values)\n    :ok","ref":"MscmpSystSettings.html#set_setting_values/2-examples"},{"type":"function","title":"MscmpSystSettings.start_devsupport_services/1","doc":"Starts a Settings Service instance for the purposes of supporting interactive\ndevelopment activities.\n\n>##","ref":"MscmpSystSettings.html#start_devsupport_services/1"},{"type":"function","title":"Not for Production {: .warning} - MscmpSystSettings.start_devsupport_services/1","doc":">\n> This operation is specifically intended to support development and should\n> not be used by code which runs in production environments.\n\nCurrently this function simply redirects to `start_support_services/1`.","ref":"MscmpSystSettings.html#start_devsupport_services/1-not-for-production-warning"},{"type":"function","title":"Parameters - MscmpSystSettings.start_devsupport_services/1","doc":"* `opts` - a `t:Keyword.t/0` list of optional parameters which can override\n    default values for service parameters.  The available options and their\n    defaults are the same as `start_support_services/1`.","ref":"MscmpSystSettings.html#start_devsupport_services/1-parameters"},{"type":"function","title":"MscmpSystSettings.start_link/1","doc":"Starts an instance of the Settings Service.\n\nStarting the service establishes the required processes and pre-populates the\nservice cache with data from the database.  Most other functions in this\nmodule require that the service is started prior to use and will fail if the\nservice is not started.\n\nThe `service_name` argument provides a unique name under which the service can\nbe found.  This argument is a subset of those that allowed for registering\nGenServers; the allowed forms for service name are simple atoms for basic\nlocal name registry or a \"via tuple\", such as might be used with the\n`Registry` module.\n\nThe `datastore_context_name` is an atom which represents a started\n`MscmpSystDb` context.  This context will be used for accessing and\nmodifying database data.","ref":"MscmpSystSettings.html#start_link/1"},{"type":"function","title":"MscmpSystSettings.start_support_services/1","doc":"Starts a Settings Service instance for the purposes of supporting interactive\ndevelopment or testing activities.\n\n>##","ref":"MscmpSystSettings.html#start_support_services/1"},{"type":"function","title":"Not for Production {: .warning} - MscmpSystSettings.start_support_services/1","doc":">\n> This operation is specifically intended to support development and testing\n> activities and should not be used by code which runs in production\n> environments.","ref":"MscmpSystSettings.html#start_support_services/1-not-for-production-warning"},{"type":"function","title":"Parameters - MscmpSystSettings.start_support_services/1","doc":"* `opts` - a `t:Keyword.t/0` list of optional parameters which can override\n    default values for service parameters.  The available options are:\n\n    * `childspec_id` - the ID value used in defining a Child Specification for\n      the service. This is an atom value which defaults to\n      `MscmpSystSettings`.\n\n    * `supervisor_name` - the name of the `DynamicSupervisor` which will\n      will supervise the Settings Service.  This is an atom value which\n      defaults to `MscmpSystSettings.DevSupportSupervisor`.\n\n    * `service_name` - the name of the Settings Service instance.  This is the\n      value by which the specific Settings Service may be set using functions\n      such as `put_settings_service/1`.  This is an atom value which defaults\n      to the value returned by `get_devsupport_service_name/0`.\n\n    * `datastore_context` - the name of the login Datastore Context which can\n      access the database storage backing the Settings Service.  This is an\n      atom value which defaults to the value returned by\n      `MscmpSystDb.get_devsupport_context_name/0`.","ref":"MscmpSystSettings.html#start_support_services/1-parameters"},{"type":"function","title":"MscmpSystSettings.start_testsupport_services/1","doc":"Starts a Settings Service instance for the purposes of supporting testing\nactivities.\n\n>##","ref":"MscmpSystSettings.html#start_testsupport_services/1"},{"type":"function","title":"Not for Production {: .warning} - MscmpSystSettings.start_testsupport_services/1","doc":">\n> This operation is specifically intended to support testing activities and\n> should not be used by code which runs in production environments.","ref":"MscmpSystSettings.html#start_testsupport_services/1-not-for-production-warning"},{"type":"function","title":"Parameters - MscmpSystSettings.start_testsupport_services/1","doc":"* `opts` - a `t:Keyword.t/0` list of optional parameters which can override\n    default values for service parameters.  The available options are:\n\n    * `childspec_id` - the ID value used in defining a Child Specification for\n      the service. This is an atom value which defaults to\n      `MscmpSystSettings`.\n\n    * `supervisor_name` - the name of the `DynamicSupervisor` which will\n      will supervise the Settings Service.  This is an atom value which\n      defaults to `MscmpSystSettings.TestSupportSupervisor`.\n\n    * `service_name` - the name of the Settings Service instance.  This is the\n      value by which the specific Settings Service may be set using functions\n      such as `put_settings_service/1`.  This is an atom value which defaults\n      to the value returned by `get_testsupport_service_name/0`.\n\n    * `datastore_context` - the name of the login Datastore Context which can\n      access the database storage backing the Settings Service.  This is an\n      atom value which defaults to the value returned by\n      `MscmpSystDb.get_testsupport_context_name/0`.","ref":"MscmpSystSettings.html#start_testsupport_services/1-parameters"},{"type":"function","title":"MscmpSystSettings.terminate_settings_service/0","doc":"Terminates a running instance of the settings service.","ref":"MscmpSystSettings.html#terminate_settings_service/0"},{"type":"function","title":"Examples - MscmpSystSettings.terminate_settings_service/0","doc":"> MscmpSystSettings.terminate_settings_service()\n    :ok","ref":"MscmpSystSettings.html#terminate_settings_service/0-examples"},{"type":"module","title":"Msdata.SystSettings","doc":"The primary data structure for applications settings data.\n\nDefined in `MscmpSystSettings`.","ref":"Msdata.SystSettings.html"},{"type":"function","title":"Msdata.SystSettings.changeset/3","doc":"Produces a changeset used to create or update a settings record.\n\nThe `change_params` argument defines the attributes to be used in maintaining\na settings record.  Of the allowed fields, the following are required for\ncreation:\n\n  * `internal_name` - A unique key which is intended for programmatic usage\n    by the application and other applications which make use of the data.\n\n  * `display_name` - A unique key for the purposes of presentation to users\n    in user interfaces, reporting, etc.\n\n  * `user_description` - A description of the setting including its use cases\n    and any limits or restrictions.  This field must contain between 6 and\n    1000 characters to be considered valid.\n\nThe options define other attributes which can guide validation of\n`change_param` values:\n\n  * `min_internal_name_length` - Sets a minimum length for `internal_name`\n    values.  The default value is 6 Unicode graphemes.\n\n  * `max_internal_name_length` - The maximum length allowed for the\n    `internal_name` value.  The default is 64 Unicode graphemes.\n\n  * `min_display_name_length` - Sets a minimum length for `display_name`\n    values.  The default value is 6 Unicode graphemes.\n\n  * `max_display_name_length` - The maximum length allowed for the\n    `display_name` value.  The default is 64 Unicode graphemes.\n\n  * `min_user_description_length` - Sets a minimum length for\n    `user_description` values.  The default value is 6 Unicode graphemes.\n\n  * `max_user_description_length` - The maximum length allowed for the\n    `user_description` value.  The default is 1000 Unicode graphemes.","ref":"Msdata.SystSettings.html#changeset/3"},{"type":"type","title":"Msdata.SystSettings.t/0","doc":"","ref":"Msdata.SystSettings.html#t:t/0"},{"type":"module","title":"MscmpSystSettings.Types","doc":"Types used by Settings service module.","ref":"MscmpSystSettings.Types.html"},{"type":"type","title":"MscmpSystSettings.Types.service_name/0","doc":"The valid forms of service name acceptable to identify the Settings service.\n\nCurrently we expect the service name to be an atom, though we expect that any\nof a simple local name, the :global registry, or the Registry module to be\nused for service registration.  Any registry compatible with those options\nshould also work.","ref":"MscmpSystSettings.Types.html#t:service_name/0"},{"type":"type","title":"MscmpSystSettings.Types.setting_name/0","doc":"Identification of each unique Setting managed by the Settings Service instance.","ref":"MscmpSystSettings.Types.html#t:setting_name/0"},{"type":"type","title":"MscmpSystSettings.Types.setting_params/0","doc":"A map definition describing what specific key/value pairs are available for\npassing as SystSettings changeset parameters.","ref":"MscmpSystSettings.Types.html#t:setting_params/0"},{"type":"type","title":"MscmpSystSettings.Types.setting_service_params/0","doc":"The expected form of the parameters used to start the Settings service.","ref":"MscmpSystSettings.Types.html#t:setting_service_params/0"},{"type":"type","title":"MscmpSystSettings.Types.setting_types/0","doc":"Data types of values accepted by any individual setting record.  Note that any\none setting record may set values for one or more of these types concurrently.","ref":"MscmpSystSettings.Types.html#t:setting_types/0"}],"content_type":"text/markdown"}