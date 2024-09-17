searchData={"items":[{"type":"module","title":"DevSupport","doc":"","ref":"DevSupport.html"},{"type":"function","title":"DevSupport.drop_database/2","doc":"","ref":"DevSupport.html#drop_database/2"},{"type":"function","title":"DevSupport.get_datastore_options/1","doc":"","ref":"DevSupport.html#get_datastore_options/1"},{"type":"function","title":"DevSupport.load_database/2","doc":"","ref":"DevSupport.html#load_database/2"},{"type":"function","title":"DevSupport.start_dev_environment/1","doc":"","ref":"DevSupport.html#start_dev_environment/1"},{"type":"function","title":"DevSupport.stop_dev_environment/0","doc":"","ref":"DevSupport.html#stop_dev_environment/0"},{"type":"module","title":"MscmpSystEnums","doc":"A framework for user configurable 'list of values' type functionality.","ref":"MscmpSystEnums.html"},{"type":"function","title":"MscmpSystEnums.child_spec/1","doc":"Returns a child specification for the Enumerations Service.","ref":"MscmpSystEnums.html#child_spec/1"},{"type":"function","title":"Parameters - MscmpSystEnums.child_spec/1","doc":"* `opts` - A keyword list of options.","ref":"MscmpSystEnums.html#child_spec/1-parameters"},{"type":"function","title":"Options - MscmpSystEnums.child_spec/1","doc":"* `:debug` (`t:boolean/0`) - If true, the GenServer backing the Settings Service will be started in\n  debug mode.\n\n* `:timeout` (`t:timeout/0`) - Timeout value for the start_link call. The default value is `:infinity`.\n\n* `:hibernate_after` (`t:timeout/0`) - If present, the GenServer process awaits any message for the specified\n  time before hibernating.  The timeout value is expressed in Milliseconds.\n\n* `:datastore_context_name` (`t:GenServer.name/0 or `nil`) - Specifies the name of the Datastore Context to be used by the Settings\n  Service.\n\n* `:service_name` (`t:GenServer.name/0 or `nil`) - The name to use for the GenServer backing this specific Enumerations\n  Service instance.","ref":"MscmpSystEnums.html#child_spec/1-options"},{"type":"function","title":"Examples - MscmpSystEnums.child_spec/1","doc":"iex> MscmpSystEnums.child_spec(\n    ...>   service_name: MyApp.EnumsService,\n    ...>   datastore_context_name: MyApp.DatastoreContext)\n    %{\n      id: MscmpSystEnums.Runtime.Service,\n      start:\n        {MscmpSystEnums,\n         :start_link,\n         [MyApp.EnumsService, MyApp.DatastoreContext, [timeout: :infinity]]},\n    }","ref":"MscmpSystEnums.html#child_spec/1-examples"},{"type":"function","title":"MscmpSystEnums.create_enum/1","doc":"Create a new user defined enumeration, optionally including functional type\nand enumeration item definitions.","ref":"MscmpSystEnums.html#create_enum/1"},{"type":"function","title":"Parameters - MscmpSystEnums.create_enum/1","doc":"* `enum_params` - a map containing the enumeration field values used in\n    creating the user defined enumerations.  If the enumeration's functional\n    types and enumeration items are known at enumeration creation time,\n    it is recommended to nest values for those records under the\n    `functional_types` and `enum_items` attributes as appropriate.  See the\n    documentation for `t:MscmpSystEnums.Types.enum_params/0`,\n    `t:MscmpSystEnums.Types.enum_functional_type_params/0`, and\n    `t:MscmpSystEnums.Types.enum_item_params/0` for more information about the\n    available and required attributes.","ref":"MscmpSystEnums.html#create_enum/1-parameters"},{"type":"function","title":"Examples - MscmpSystEnums.create_enum/1","doc":"iex> example_enumeration =\n    ...>   %{\n    ...>      internal_name: \"example_create_enum\",\n    ...>      display_name: \"Create Example Enum\",\n    ...>      user_description: \"Demonstrate enumeration creation.\",\n    ...>      functional_types: [\n    ...>        %{\n    ...>          internal_name: \"example_create_enum_functional_type\",\n    ...>          display_name: \"Create Example Enum / Functional Type\",\n    ...>          external_name: \"Functional Type\",\n    ...>          user_description: \"Demonstrate Functional Type Creation\"\n    ...>        }\n    ...>      ],\n    ...>      enum_items: [\n    ...>        %{\n    ...>          internal_name: \"example_create_enum_item\",\n    ...>          display_name: \"Create Example Enum / Enum Item\",\n    ...>          external_name: \"Enum Item\",\n    ...>          user_description: \"Demonstration of enumeration item creation.\",\n    ...>          enum_default: true,\n    ...>          functional_type_default: false,\n    ...>          functional_type_name: \"example_create_enum_functional_type\"\n    ...>        }\n    ...>      ]\n    ...>    }\n    iex> MscmpSystEnums.create_enum(example_enumeration)\n    :ok","ref":"MscmpSystEnums.html#create_enum/1-examples"},{"type":"function","title":"MscmpSystEnums.create_enum_functional_type/2","doc":"Creates a new user defined functional type.\n\nUser defined functional types may only be added to user defined enumerations.","ref":"MscmpSystEnums.html#create_enum_functional_type/2"},{"type":"function","title":"Parameters - MscmpSystEnums.create_enum_functional_type/2","doc":"* `enum_name` - the Enumeration to which the new functional type will be a\n    child.\n\n  * `functional_type_params` - a map of type\n    `t:Types.enum_functional_type_params/0` which establishes\n    the data values for the new functional type.","ref":"MscmpSystEnums.html#create_enum_functional_type/2-parameters"},{"type":"function","title":"MscmpSystEnums.create_enum_item/2","doc":"Creates a new user defined enumeration item.\n\nUser defined enumeration items may be added to either user defined\nenumerations or system defined enumerations which are also marked user\nmaintainable.","ref":"MscmpSystEnums.html#create_enum_item/2"},{"type":"function","title":"Parameters - MscmpSystEnums.create_enum_item/2","doc":"* `enum_name` -the  enumeration to which the new enumeration item will be a\n    child.\n\n  * `enum_item_params` - a map of type\n    `t:MscmpSystEnums.Types.enum_item_params/0` which establishes the data\n    values for the new enumeration item.","ref":"MscmpSystEnums.html#create_enum_item/2-parameters"},{"type":"function","title":"MscmpSystEnums.delete_enum/1","doc":"Deletes a user defined enumeration and its child functional type and\nenumeration item records.\n\nYou cannot delete a system defined enumeration nor can you delete an\nenumeration that has been referenced in other application data records.","ref":"MscmpSystEnums.html#delete_enum/1"},{"type":"function","title":"Parameters - MscmpSystEnums.delete_enum/1","doc":"* `enum_name` - the enumeration which is to be deleted by the function.","ref":"MscmpSystEnums.html#delete_enum/1-parameters"},{"type":"function","title":"MscmpSystEnums.delete_enum_functional_type/2","doc":"Deletes a user defined enumeration functional type record.\n\nYou cannot delete a system defined functional type nor can you delete a\nfunctional type which is still referenced by enumeration item records.","ref":"MscmpSystEnums.html#delete_enum_functional_type/2"},{"type":"function","title":"Parameters - MscmpSystEnums.delete_enum_functional_type/2","doc":"* `enum_name` - the enumeration which is is the parent of the functional\n    type to be deleted.\n\n  * `enum_functional_type_name`- the target functional type of the delete\n    operation.","ref":"MscmpSystEnums.html#delete_enum_functional_type/2-parameters"},{"type":"function","title":"MscmpSystEnums.delete_enum_item/2","doc":"Deletes a user defined enumeration item record.\n\nYou cannot delete a system defined enumeration item nor can you delete an\nan enumeration item record which has been referenced in application data.","ref":"MscmpSystEnums.html#delete_enum_item/2"},{"type":"function","title":"Parameters - MscmpSystEnums.delete_enum_item/2","doc":"* `enum_name` - the enumeration which is is the parent of the enumeration\n    item to be deleted.\n\n  * `enum_item_name` - the target functional type of the delete operation.","ref":"MscmpSystEnums.html#delete_enum_item/2-parameters"},{"type":"function","title":"MscmpSystEnums.get_default_enum_item/2","doc":"Finds the default enumeration item for the requested enumeration or for the\nenumeration functional type.\n\nWhen no qualifying options are specified, this function will return the\nenumeration item record which is marked as being default for the enumeration.\nIf the `functional_type_name` option is used, then the function returns the\nrecord which is marked as default for the functional type.","ref":"MscmpSystEnums.html#get_default_enum_item/2"},{"type":"function","title":"Parameters - MscmpSystEnums.get_default_enum_item/2","doc":"* `enum_name`- the name of the enumeration for which to retrieve the default\n    enumeration item.\n\n  * `opts` - a keyword list of optional values.","ref":"MscmpSystEnums.html#get_default_enum_item/2-parameters"},{"type":"function","title":"Options - MscmpSystEnums.get_default_enum_item/2","doc":"* `:functional_type_name` (`t:String.t/0`) - The Internal Name of the Enumeration's Functional Type.","ref":"MscmpSystEnums.html#get_default_enum_item/2-options"},{"type":"function","title":"Examples - MscmpSystEnums.get_default_enum_item/2","doc":"iex> %Msdata.SystEnumItems{\n    ...>   internal_name: \"example_enum_item_two\"\n    ...> } =\n    ...>   MscmpSystEnums.get_default_enum_item(\"example_enumeration\")\n\n    iex> %Msdata.SystEnumItems{\n    ...>   internal_name: \"example_enum_item_one\"\n    ...> } =\n    ...>   MscmpSystEnums.get_default_enum_item(\n    ...>     \"example_enumeration\",\n    ...>     [functional_type_name: \"example_enum_func_type_1\"]\n    ...>   )","ref":"MscmpSystEnums.html#get_default_enum_item/2-examples"},{"type":"function","title":"MscmpSystEnums.get_enum_item_by_id/2","doc":"Returns an Enumeration Item record from the named Enumeration as identified by\nits id value.\n\nOther than using a different identifier to locate the enumeration item record,\nthis function behaves the same as `get_enum_by_name/2`.","ref":"MscmpSystEnums.html#get_enum_item_by_id/2"},{"type":"function","title":"Parameters - MscmpSystEnums.get_enum_item_by_id/2","doc":"* `enum_name` - the name of the Enumeration that is parent to the target\n  Enumeration Item record.\n\n  * `enum_item_id` - the id value of the Enumeration Item record to return.","ref":"MscmpSystEnums.html#get_enum_item_by_id/2-parameters"},{"type":"function","title":"MscmpSystEnums.get_enum_item_by_name/2","doc":"Returns an Enumeration Item record from the named Enumeration as identified by\nits name.","ref":"MscmpSystEnums.html#get_enum_item_by_name/2"},{"type":"function","title":"Parameters - MscmpSystEnums.get_enum_item_by_name/2","doc":"* `enum_name` - the name of the Enumeration that is parent to the target\n  Enumeration Item record.\n\n  * `enum_item_name` - the name of the Enumeration Item record to return.","ref":"MscmpSystEnums.html#get_enum_item_by_name/2-parameters"},{"type":"function","title":"Examples - MscmpSystEnums.get_enum_item_by_name/2","doc":"iex> %Msdata.SystEnumItems{\n    ...>   internal_name: \"example_enum_item_one\"\n    ...> } =\n    ...>   MscmpSystEnums.get_enum_item_by_name(\n    ...>     \"example_enumeration\",\n    ...>     \"example_enum_item_one\"\n    ...>   )","ref":"MscmpSystEnums.html#get_enum_item_by_name/2-examples"},{"type":"function","title":"MscmpSystEnums.get_enum_syst_defined/1","doc":"Returns true if the requested enumeration is system defined, false otherwise.","ref":"MscmpSystEnums.html#get_enum_syst_defined/1"},{"type":"function","title":"Parameters - MscmpSystEnums.get_enum_syst_defined/1","doc":"* `enum_name` - the name of the enumeration to test as being system defined.","ref":"MscmpSystEnums.html#get_enum_syst_defined/1-parameters"},{"type":"function","title":"Examples - MscmpSystEnums.get_enum_syst_defined/1","doc":"iex> MscmpSystEnums.get_enum_syst_defined(\"example_enumeration\")\n    false","ref":"MscmpSystEnums.html#get_enum_syst_defined/1-examples"},{"type":"function","title":"MscmpSystEnums.get_enum_user_maintainable/1","doc":"Returns true if the requested enumeration is user maintainable, false\notherwise.","ref":"MscmpSystEnums.html#get_enum_user_maintainable/1"},{"type":"function","title":"Parameters - MscmpSystEnums.get_enum_user_maintainable/1","doc":"* `enum_name` - the name of the enumeration to test as being user\n    maintainable.","ref":"MscmpSystEnums.html#get_enum_user_maintainable/1-parameters"},{"type":"function","title":"Examples - MscmpSystEnums.get_enum_user_maintainable/1","doc":"iex> MscmpSystEnums.get_enum_user_maintainable( \"example_enumeration\")\n    true","ref":"MscmpSystEnums.html#get_enum_user_maintainable/1-examples"},{"type":"function","title":"MscmpSystEnums.get_enum_values/1","doc":"Retrieves all values associated with the requested enumeration.","ref":"MscmpSystEnums.html#get_enum_values/1"},{"type":"function","title":"Parameters - MscmpSystEnums.get_enum_values/1","doc":"* `enum_name` - the name of the enumeration for which to retrieve values.\n\nThe successful return of this function is an instance of the\n`Msdata.SystEnums` struct containing the values requested.","ref":"MscmpSystEnums.html#get_enum_values/1-parameters"},{"type":"function","title":"Examples - MscmpSystEnums.get_enum_values/1","doc":"iex> MscmpSystEnums.get_enum_values(\"example_enumeration\")","ref":"MscmpSystEnums.html#get_enum_values/1-examples"},{"type":"function","title":"MscmpSystEnums.get_enums_service/0","doc":"Retrieve the current specific Enumerations Service name in effect for the process.\n\nThis function returns the name of the Enumerations Service that has been using the\n`put_enums_service/1` function to override the default Enumerations Service\nassociated with the Instance Name. If no specific Enumerations Service name has\nbeen set, this function will return `nil`.","ref":"MscmpSystEnums.html#get_enums_service/0"},{"type":"function","title":"Examples - MscmpSystEnums.get_enums_service/0","doc":"Retrieving a specific Enumerations Service name:\n\n    iex> MscmpSystEnums.put_enums_service(:\"MscmpSystEnums.TestSupportService\")\n    ...> MscmpSystEnums.get_enums_service()\n    :\"MscmpSystEnums.TestSupportService\"\n\n  Retrieving a specific Enumerations Service name when no value is currently set\n  for the process:\n\n    iex> MscmpSystEnums.put_enums_service(nil)\n    ...> MscmpSystEnums.get_enums_service()\n    nil","ref":"MscmpSystEnums.html#get_enums_service/0-examples"},{"type":"function","title":"MscmpSystEnums.get_functional_type_by_enum_item_id/2","doc":"Returns the internal name of the functional type to which the given Enum Item\nrecord belongs.","ref":"MscmpSystEnums.html#get_functional_type_by_enum_item_id/2"},{"type":"function","title":"Parameters - MscmpSystEnums.get_functional_type_by_enum_item_id/2","doc":"* `enum_name` - the name of the enumeration to which the Enum Item ID\n  belongs.\n\n  * `enum_item_id` - the record ID of the Enum Item record of interest.","ref":"MscmpSystEnums.html#get_functional_type_by_enum_item_id/2-parameters"},{"type":"function","title":"Example - MscmpSystEnums.get_functional_type_by_enum_item_id/2","doc":"iex> example_enum_item = MscmpSystEnums.get_enum_item_by_name(\n    ...>   \"example_enumeration\",\n    ...>   \"example_enum_item_one\")\n    iex> MscmpSystEnums.get_functional_type_by_enum_item_id(\n    ...>   \"example_enumeration\",\n    ...>   example_enum_item.id)\n    \"example_enum_func_type_1\"","ref":"MscmpSystEnums.html#get_functional_type_by_enum_item_id/2-example"},{"type":"function","title":"MscmpSystEnums.list_all_enums/0","doc":"Retrieves all values for all enumerations.\n\nThis function returns all other enumeration metadata, such as the records' IDs,\ndescriptions, etc.  Also included is association data for the `enum_items`\nfield and the `functional_type` association of each item.","ref":"MscmpSystEnums.html#list_all_enums/0"},{"type":"function","title":"Examples - MscmpSystEnums.list_all_enums/0","doc":"iex> MscmpSystEnums.list_all_enums()","ref":"MscmpSystEnums.html#list_all_enums/0-examples"},{"type":"function","title":"MscmpSystEnums.list_enum_functional_types/1","doc":"Returns the list of Enumeration Functional Types associated with the requested\nenumeration.","ref":"MscmpSystEnums.html#list_enum_functional_types/1"},{"type":"function","title":"Parameters - MscmpSystEnums.list_enum_functional_types/1","doc":"* `enum_name` - the name of the enumeration for which to retrieve the list\n    of enumeration functional types.","ref":"MscmpSystEnums.html#list_enum_functional_types/1-parameters"},{"type":"function","title":"MscmpSystEnums.list_enum_items/1","doc":"Returns the list of Enumeration Items associated with the requested\nenumeration.","ref":"MscmpSystEnums.html#list_enum_items/1"},{"type":"function","title":"Parameters - MscmpSystEnums.list_enum_items/1","doc":"* `enum_name`- the name of the enumeration for which to retrieve the list of\n    enumeration items.","ref":"MscmpSystEnums.html#list_enum_items/1-parameters"},{"type":"function","title":"MscmpSystEnums.list_sorted_enum_items/1","doc":"Returns the list of Enumeration Items associated with the requested\nenumeration sorted by their sort_order value.\n\nIn all other regards this function works the same\n`MscmpSystEnums.list_enum_items/1`.","ref":"MscmpSystEnums.html#list_sorted_enum_items/1"},{"type":"function","title":"MscmpSystEnums.put_enums_service/1","doc":"An optional method for establishing a specific, named Enumerations Service to\naccess by the current process.\n\nIn some cases it may be desirable to establish an instance of the Enumerations\nService outside of the constraints the \"Instance Name\" as defined by\n`Msutils.String`. In such cases, this function can be used to set a current\nEnumerations Service instance for the current process which will access the named\nEnumerations Service directly rather than the Enumerations Service associated with the\nprevailing named Instance.  See `Msutils.String` for more about establishing\nan instance identity with a given process.\n\n> #### Limited Use Cases {: .tip}\n>\n> Under most circumstances the correct Enumerations Service instance to access\n> will be determined by the prevailing Instance Name as managed by calls to\n> `Msutils.String.put_instance_name/1` and `Msutils.String.get_instance_name/0`,\n> meaning that typically calls to `put_enums_service/1` are not necessary.\n>\n> The only time this function is required is when an alternative Enumerations\n> Service should be accessed or there is no Instance Name to set for the\n> process using `Msutils.String.put_instance_name/1`.","ref":"MscmpSystEnums.html#put_enums_service/1"},{"type":"function","title":"Parameters - MscmpSystEnums.put_enums_service/1","doc":"* `enums_service_name` - the canonical name of the specific Enumerations\n  Service to access.  When this function is called with a non-nil argument,\n  calls to Enumerations related functions will make use of the Enumerations Service\n  specified here, overriding any Enumerations Service which may be started derived\n  from the Instance Name.  Setting this value to `nil` will clear the special\n  Enumerations Service name and revert to using the Enumerations Service associated\n  with the Instance Name, if one has been set.","ref":"MscmpSystEnums.html#put_enums_service/1-parameters"},{"type":"function","title":"Examples - MscmpSystEnums.put_enums_service/1","doc":"Setting a specific Enumerations Service name:\n\n    iex> MscmpSystEnums.put_enums_service(:\"MscmpSystEnums.TestSupportService\")\n    ...> MscmpSystEnums.get_enums_service()\n    :\"MscmpSystEnums.TestSupportService\"\n\n  Clearing a previously set specific Service Name:\n\n    iex> MscmpSystEnums.put_enums_service(nil)\n    ...> MscmpSystEnums.get_enums_service()\n    nil","ref":"MscmpSystEnums.html#put_enums_service/1-examples"},{"type":"function","title":"MscmpSystEnums.set_enum_functional_type_values/3","doc":"Change the values of an existing enumeration functional type record.\n\nThe following fields may be changed using this function:\n\n  * `internal_name` - Note that you cannot change the internal name of a\n    system defined functional type.\n\n  * `display_name`\n\n  * `external_name`\n\n  * `user_description`\n\nOther fields of the Msdata.SystEnumFunctionalTypes data type may\nnot be modified via this module.","ref":"MscmpSystEnums.html#set_enum_functional_type_values/3"},{"type":"function","title":"Parameters - MscmpSystEnums.set_enum_functional_type_values/3","doc":"* `enum_name`- the enumeration which is parent to the functional type being\n    modified.\n\n  * `functional_type_name` - the specific functional type which will be\n    updated.\n\n  * `functional_type_params` - a map of type\n    `t:MscmpSystEnums.Types.enum_functional_type_params/0` which establishes\n    the data values which are to be changed.","ref":"MscmpSystEnums.html#set_enum_functional_type_values/3-parameters"},{"type":"function","title":"MscmpSystEnums.set_enum_item_values/3","doc":"Change the values of an existing enumeration item record.\n\nThe following fields may be changed using this function:\n\n  * `internal_name` - Note that you cannot change the internal name of a\n    system defined enumeration item.\n\n  * `display_name`\n\n  * `external_name`\n\n  * `user_description`\n\n  * `enum_default`\n\n  * `functional_type_default`\n\n  * `sort_order`\n\n  * `user_options`\n\nOther fields of the Msdata.SystEnumItems data type may not be\nmodified via this module.","ref":"MscmpSystEnums.html#set_enum_item_values/3"},{"type":"function","title":"Parameters - MscmpSystEnums.set_enum_item_values/3","doc":"* `enum_name` - the enumeration which is parent to the enumeration item.\n\n  * `enum_item_name` - the specific enumeration item which will be updated.\n\n  * `enum_item_params` - a map of type\n    `t:MscmpSystEnums.Types.enum_item_params/0` which establishes the data values\n    which are to be changed.","ref":"MscmpSystEnums.html#set_enum_item_values/3-parameters"},{"type":"function","title":"MscmpSystEnums.set_enum_values/2","doc":"Changes the values of an existing enumeration.\n\nYou can change the following fields using the this function:\n\n  * `internal_name` - Note that you cannot change the internal name of a\n    system defined enumeration.\n\n  * `display_name`\n\n  * `user_description`\n\n  * `default_user_options`\n\nOther fields of the `Msdata.SystEnums` data type may not be\nmodified via this module.  Also note that only the enumeration value itself\ncan be modified.  Changes to functional type or enumeration item records must\nbe addressed individually.","ref":"MscmpSystEnums.html#set_enum_values/2"},{"type":"function","title":"Parameters - MscmpSystEnums.set_enum_values/2","doc":"* `enum_name` - the enumeration which is being modified.\n\n  * `enum_params` - a map of type `t:MscmpSystEnums.Types.enum_params/0` which\n    establishes the data values which are to be changed.","ref":"MscmpSystEnums.html#set_enum_values/2-parameters"},{"type":"function","title":"MscmpSystEnums.start_link/3","doc":"Starts an instance of the Enumerations Service.\n\nStarting the service establishes the required processes and pre-populates the\nservice cache with data from the database.  Most other functions in this\nmodule require that the service is started prior to use and will fail if the\nservice is not started.","ref":"MscmpSystEnums.html#start_link/3"},{"type":"function","title":"Parameters - MscmpSystEnums.start_link/3","doc":"* `service_name` - The name to use for the GenServer backing this specific\n    Enumerations Service instance.\n\n  * `datastore_context_name` - The name of the Datastore Context to be used\n    by the Enumerations Service.\n\n  * `opts` - A keyword list of options.","ref":"MscmpSystEnums.html#start_link/3-parameters"},{"type":"function","title":"Options - MscmpSystEnums.start_link/3","doc":"* `:debug` (`t:boolean/0`) - If true, the GenServer backing the Settings Service will be started in\n  debug mode.\n\n* `:timeout` (`t:timeout/0`) - Timeout value for the start_link call. The default value is `:infinity`.\n\n* `:hibernate_after` (`t:timeout/0`) - If present, the GenServer process awaits any message for the specified\n  time before hibernating.  The timeout value is expressed in Milliseconds.","ref":"MscmpSystEnums.html#start_link/3-options"},{"type":"module","title":"Msdata.SystEnumFunctionalTypes","doc":"The data structure defining the functional types associated with a given\nenumeration.\n\nFunctional types allow the application behavior associated with list choices\nto be decoupled from the information conveyance that the same list of choices\nmay be able to provide.  For example, the application may only need to\nrecognize the difference between 'active' and 'inactive' order records as a\nstatus, however a user may want to see some reflection of why an order was\nmade inactive, such as it was cancelled or that it was fulfilled.  In this\ncase would create two entries of functional type inactive, one each for\ncancelled and fulfilled.  Functionally the application will see the same\nvalue, but user reporting can reflect the nuance not needed by the application\nfunctionality.\n\nDefined in `MscmpSystEnums`.","ref":"Msdata.SystEnumFunctionalTypes.html"},{"type":"function","title":"Msdata.SystEnumFunctionalTypes.changeset/3","doc":"Produces a changeset used to create or update a Enum Functional Type record.\n\nThe `change_params` argument defines the attributes to be used in maintaining\nan Enum Functional Type record.  Of the allowed fields, the following are\nrequired for creation:\n\n  * `internal_name` - A unique key which is intended for programmatic usage\n    by the application and other applications which make use of the data.\n\n  * `display_name` - A unique key for the purposes of presentation to users\n    in user interfaces, reporting, etc.\n\n  * `external_name` - A non-unique name for the purposes of presentation to\n    users in user interfaces, reporting, etc.\n\n  * `user_description` - A description of the setting including its use cases\n    and any limits or restrictions.","ref":"Msdata.SystEnumFunctionalTypes.html#changeset/3"},{"type":"function","title":"Options - Msdata.SystEnumFunctionalTypes.changeset/3","doc":"* `:min_internal_name_length` (`t:pos_integer/0`) - Sets the minimum grapheme length of internal_name values. The default value is `6`.\n\n* `:max_internal_name_length` (`t:pos_integer/0`) - Sets the maximum grapheme length of internal_name values. The default value is `64`.\n\n* `:min_display_name_length` (`t:pos_integer/0`) - Sets the minimum grapheme length of display_name values. The default value is `6`.\n\n* `:max_display_name_length` (`t:pos_integer/0`) - Sets the maximum grapheme length of display_name values. The default value is `64`.\n\n* `:min_external_name_length` (`t:pos_integer/0`) - Sets the minimum grapheme length of external_name values. The default value is `6`.\n\n* `:max_external_name_length` (`t:pos_integer/0`) - Sets the maximum grapheme length of external_name values. The default value is `64`.\n\n* `:min_user_description_length` (`t:pos_integer/0`) - Sets the minimum grapheme length of user_description values. The default value is `6`.\n\n* `:max_user_description_length` (`t:pos_integer/0`) - Sets the maximum grapheme length of user_description values. The default value is `1000`.","ref":"Msdata.SystEnumFunctionalTypes.html#changeset/3-options"},{"type":"type","title":"Msdata.SystEnumFunctionalTypes.t/0","doc":"","ref":"Msdata.SystEnumFunctionalTypes.html#t:t/0"},{"type":"module","title":"Msdata.SystEnumItems","doc":"The data structure defining individual enumerated values.\n\nDefined in `MscmpSystEnums`.","ref":"Msdata.SystEnumItems.html"},{"type":"function","title":"Msdata.SystEnumItems.changeset/3","doc":"Produces a changeset used to create or update a Enum Items record.\n\nThe `change_params` argument defines the attributes to be used in maintaining\na Enum Items record.  Of the allowed fields, the following are required for\ncreation:\n\n  * `internal_name` - A unique key which is intended for programmatic usage\n    by the application and other applications which make use of the data.\n\n  * `display_name` - A unique key for the purposes of presentation to users\n    in user interfaces, reporting, etc.\n\n  * `external_name` - A non-unique name for the purposes of presentation to\n    users in user interfaces, reporting, etc.\n\n  * `user_description` - A description of the setting including its use cases\n    and any limits or restrictions.","ref":"Msdata.SystEnumItems.html#changeset/3"},{"type":"function","title":"Options - Msdata.SystEnumItems.changeset/3","doc":"* `:min_internal_name_length` (`t:pos_integer/0`) - Sets the minimum grapheme length of internal_name values. The default value is `6`.\n\n* `:max_internal_name_length` (`t:pos_integer/0`) - Sets the maximum grapheme length of internal_name values. The default value is `64`.\n\n* `:min_display_name_length` (`t:pos_integer/0`) - Sets the minimum grapheme length of display_name values. The default value is `6`.\n\n* `:max_display_name_length` (`t:pos_integer/0`) - Sets the maximum grapheme length of display_name values. The default value is `64`.\n\n* `:min_external_name_length` (`t:pos_integer/0`) - Sets the minimum grapheme length of external_name values. The default value is `6`.\n\n* `:max_external_name_length` (`t:pos_integer/0`) - Sets the maximum grapheme length of external_name values. The default value is `64`.\n\n* `:min_user_description_length` (`t:pos_integer/0`) - Sets the minimum grapheme length of user_description values. The default value is `6`.\n\n* `:max_user_description_length` (`t:pos_integer/0`) - Sets the maximum grapheme length of user_description values. The default value is `1000`.","ref":"Msdata.SystEnumItems.html#changeset/3-options"},{"type":"type","title":"Msdata.SystEnumItems.t/0","doc":"","ref":"Msdata.SystEnumItems.html#t:t/0"},{"type":"module","title":"Msdata.SystEnums","doc":"The data structure defining available system enumerations (lists of values).\n\nDefined in `MscmpSystEnums`.","ref":"Msdata.SystEnums.html"},{"type":"function","title":"Msdata.SystEnums.changeset/3","doc":"Produces a changeset used to create or update a Enumeration record.\n\nThe `change_params` argument defines the attributes to be used in maintaining\nan Enumerations record.  Of the allowed fields, the following are required for\ncreation:\n\n  * `internal_name` - A unique key which is intended for programmatic usage\n    by the application and other applications which make use of the data.\n\n  * `display_name` - A unique key for the purposes of presentation to users\n    in user interfaces, reporting, etc.\n\n  * `user_description` - A description of the setting including its use cases\n    and any limits or restrictions.","ref":"Msdata.SystEnums.html#changeset/3"},{"type":"function","title":"Options - Msdata.SystEnums.changeset/3","doc":"* `:min_internal_name_length` (`t:pos_integer/0`) - Sets the minimum grapheme length of internal_name values. The default value is `6`.\n\n* `:max_internal_name_length` (`t:pos_integer/0`) - Sets the maximum grapheme length of internal_name values. The default value is `64`.\n\n* `:min_display_name_length` (`t:pos_integer/0`) - Sets the minimum grapheme length of display_name values. The default value is `6`.\n\n* `:max_display_name_length` (`t:pos_integer/0`) - Sets the maximum grapheme length of display_name values. The default value is `64`.\n\n* `:min_user_description_length` (`t:pos_integer/0`) - Sets the minimum grapheme length of user_description values. The default value is `6`.\n\n* `:max_user_description_length` (`t:pos_integer/0`) - Sets the maximum grapheme length of user_description values. The default value is `1000`.","ref":"Msdata.SystEnums.html#changeset/3-options"},{"type":"type","title":"Msdata.SystEnums.t/0","doc":"","ref":"Msdata.SystEnums.html#t:t/0"},{"type":"module","title":"MscmpSystEnums.Types","doc":"Types used by the Enums service module.","ref":"MscmpSystEnums.Types.html"},{"type":"type","title":"MscmpSystEnums.Types.enum_functional_type_name/0","doc":"Identification of each unique Enum Functional Type that can be associated with\nan Enum.","ref":"MscmpSystEnums.Types.html#t:enum_functional_type_name/0"},{"type":"type","title":"MscmpSystEnums.Types.enum_functional_type_params/0","doc":"A map definition describing what specific key/value pairs are available for\npassing as SystEnumFunctionalTypes changeset parameters.","ref":"MscmpSystEnums.Types.html#t:enum_functional_type_params/0"},{"type":"type","title":"MscmpSystEnums.Types.enum_item_id/0","doc":"Record ID type for the Enum Item record.","ref":"MscmpSystEnums.Types.html#t:enum_item_id/0"},{"type":"type","title":"MscmpSystEnums.Types.enum_item_name/0","doc":"Identification of each unique Enum Value that can be associated with an Enum.","ref":"MscmpSystEnums.Types.html#t:enum_item_name/0"},{"type":"type","title":"MscmpSystEnums.Types.enum_item_params/0","doc":"A map definition describing what specific key/value pairs are available for\npassing as SystEnumItems changeset parameters.","ref":"MscmpSystEnums.Types.html#t:enum_item_params/0"},{"type":"type","title":"MscmpSystEnums.Types.enum_name/0","doc":"Identification of each unique Enum managed by the Enums Service instance.","ref":"MscmpSystEnums.Types.html#t:enum_name/0"},{"type":"type","title":"MscmpSystEnums.Types.enum_params/0","doc":"A map definition describing what specific key/value pairs are available for\npassing as SystEnums changeset parameters.","ref":"MscmpSystEnums.Types.html#t:enum_params/0"},{"type":"type","title":"MscmpSystEnums.Types.service_name/0","doc":"The valid forms of service name acceptable to identify the Enumerations\nservice.\n\nWhen the service name is an atom, it is assumed to be a registered name using\nthe default Elixir name registration process.  When the service name is a\nString, you must also identify a valid registry with which the name will be\nregistered.  Finally, if the value is `nil`, the service will be started\nwithout a name and you are responsible for using the returned PID for later\naccesses of the service.","ref":"MscmpSystEnums.Types.html#t:service_name/0"}],"content_type":"text/markdown","producer":{"name":"ex_doc","version":[48,46,51,52,46,50]}}