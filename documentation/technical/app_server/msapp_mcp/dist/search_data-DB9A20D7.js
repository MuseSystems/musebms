searchData={"items":[{"type":"module","title":"MsappMcp","doc":"MsappMcp API","ref":"MsappMcp.html"},{"type":"function","title":"MsappMcp.authenticate/4","doc":"","ref":"MsappMcp.html#authenticate/4"},{"type":"function","title":"MsappMcp.delete_session/1","doc":"","ref":"MsappMcp.html#delete_session/1"},{"type":"function","title":"MsappMcp.generate_session_name/0","doc":"","ref":"MsappMcp.html#generate_session_name/0"},{"type":"function","title":"MsappMcp.get_mssub_mcp_state/0","doc":"","ref":"MsappMcp.html#get_mssub_mcp_state/0"},{"type":"function","title":"MsappMcp.launch_bootstrap?/0","doc":"","ref":"MsappMcp.html#launch_bootstrap?/0"},{"type":"function","title":"MsappMcp.load_disallowed_passwords/0","doc":"","ref":"MsappMcp.html#load_disallowed_passwords/0"},{"type":"function","title":"MsappMcp.process_bootstrap_data/1","doc":"","ref":"MsappMcp.html#process_bootstrap_data/1"},{"type":"function","title":"MsappMcp.test_session_authentication/1","doc":"","ref":"MsappMcp.html#test_session_authentication/1"},{"type":"module","title":"MsappMcp.Types","doc":"Defines Msplatform/MsappMcp data types which appear in processing\nfunctionality.","ref":"MsappMcp.Types.html"},{"type":"type","title":"MsappMcp.Types.form_data_def/0","doc":"","ref":"MsappMcp.Types.html#t:form_data_def/0"},{"type":"type","title":"MsappMcp.Types.form_field_def/0","doc":"","ref":"MsappMcp.Types.html#t:form_field_def/0"},{"type":"type","title":"MsappMcp.Types.form_field_name/0","doc":"","ref":"MsappMcp.Types.html#t:form_field_name/0"},{"type":"type","title":"MsappMcp.Types.login_failure_reasons/0","doc":"","ref":"MsappMcp.Types.html#t:login_failure_reasons/0"},{"type":"type","title":"MsappMcp.Types.login_result/0","doc":"","ref":"MsappMcp.Types.html#t:login_result/0"},{"type":"type","title":"MsappMcp.Types.mssub_mcp_states/0","doc":"","ref":"MsappMcp.Types.html#t:mssub_mcp_states/0"},{"type":"module","title":"Msform.AuthEmailPassword","doc":"Form/API data used the Email/Password authentication process.","ref":"Msform.AuthEmailPassword.html"},{"type":"function","title":"Msform.AuthEmailPassword.finish_processing_override/2","doc":"Removes a processing override from the active overrides list.\n\nOnce an active operation previously added to the process overrides list has\ncompleted its processing, this function is used to remove it from the list so\nthat any user interface components that are watching for the operation to be\nactive can resume their normal behavior.","ref":"Msform.AuthEmailPassword.html#finish_processing_override/2"},{"type":"function","title":"Parameters - Msform.AuthEmailPassword.finish_processing_override/2","doc":"* `socket_or_assigns` - the socket or assigns for the current view.\n\n  * `override` - the name of the processing override to remove from the active\n  process overrides list.","ref":"Msform.AuthEmailPassword.html#finish_processing_override/2-parameters"},{"type":"function","title":"Msform.AuthEmailPassword.get_component_info/1","doc":"Retrieves the textual information (`label`, `label_link`, and `info`)\nfield values from the Form Configuration for the identified component.\n\nThis is a convenience function which accepts either a `form_id` value or\na `binding_id` value and returns the textual information for the\ncomponent if found by the passed identifier.","ref":"Msform.AuthEmailPassword.html#get_component_info/1"},{"type":"function","title":"Parameters - Msform.AuthEmailPassword.get_component_info/1","doc":"* `component_id` - this value is either the `form_id` or `binding_id`\n  that is associated with the component for which textual information is\n  being retrieved.","ref":"Msform.AuthEmailPassword.html#get_component_info/1-parameters"},{"type":"function","title":"Msform.AuthEmailPassword.get_form_config/0","doc":"Returns the user interface textual labels associated with each form field.\n\nWe define these here so that the rest of the application has a common\ndefinition of how these form fields should be labelled.","ref":"Msform.AuthEmailPassword.html#get_form_config/0"},{"type":"function","title":"Msform.AuthEmailPassword.process_login_attempt/2","doc":"","ref":"Msform.AuthEmailPassword.html#process_login_attempt/2"},{"type":"function","title":"Msform.AuthEmailPassword.process_login_denied/1","doc":"","ref":"Msform.AuthEmailPassword.html#process_login_denied/1"},{"type":"function","title":"Msform.AuthEmailPassword.start_processing_override/2","doc":"Adds a processing override to the active overrides list.\n\nSome user interface components are configured to change their presentation and\ninteractivity when certain, possibly long running, processes are underway.\nThis function adds the value of the `override` parameter to the active\nprocesses list allowing components interest in that processing state to\nrespond accordingly.","ref":"Msform.AuthEmailPassword.html#start_processing_override/2"},{"type":"function","title":"Parameters - Msform.AuthEmailPassword.start_processing_override/2","doc":"* `socket_or_assigns` - the socket or assigns for the current view.\n\n  * `override` - the name of the processing override to activate.  This value\n  will be an atom and will be form implementation specific.","ref":"Msform.AuthEmailPassword.html#start_processing_override/2-parameters"},{"type":"function","title":"Msform.AuthEmailPassword.update_button_state/3","doc":"Sets the state of `MscmpSystForms.WebComponents.msvalidated_button/1`\ncomponents.\n\nValidated buttons exist in one of three states defined by\n`t:MscmpSystForms.Types.msvalidated_button_states/0`.  This function will\nset the state of the validated button identified by the `form_id`\nparameters to the state identified by the `button_state` parameters.","ref":"Msform.AuthEmailPassword.html#update_button_state/3"},{"type":"function","title":"Parameters - Msform.AuthEmailPassword.update_button_state/3","doc":"* `socket_or_assigns` - the socket or assigns for the current view.\n\n  * `form_id` - the identifier of the component to update.  See\n  `c:MscmpSystForms.get_form_config/0` for more about form configuration\n  attributes.\n\n  * `button_state` - the state to which the validated button component\n  should be set.  Any value defined by the\n  `t:MscmpSystForms.Types.msvalidated_button_states/0` type is valid for\n  this purpose.","ref":"Msform.AuthEmailPassword.html#update_button_state/3-parameters"},{"type":"function","title":"Msform.AuthEmailPassword.update_display_data/3","doc":"Updates the display form data with new values.\n\nThe display data of the form, which represents the form's backing data\nafter the application of effective user permissions to purge values that\nthe user is not entitled to see, is set using this function.  The data is\nstored in the view's assigns as a `t:Phoenix.HTML.Form.t/0' value which is\nthen passed to the view for rendering.","ref":"Msform.AuthEmailPassword.html#update_display_data/3"},{"type":"function","title":"Parameters - Msform.AuthEmailPassword.update_display_data/3","doc":"* `socket_or_assigns` - the socket or assigns for the current view.\n\n  * `display_data` - this option contains either the new display data to\n  set and with which to update the form or indicates the kind of data\n  validation to perform on the assigns stored data (`msrd_original_data` &\n  `msrd_current_data`; see `MscmpSystForms.init_assigns/8` for more).\n\n      One method for setting the display data is to pass this option to\n      the function using actual data.  This data can take the form of\n      either a `t:Ecto.Changeset.t/0` value or a `t:Phoenix.HTML.Form.t/0`\n      value. If a Changeset is passed, the function will automatically\n      process it into a `t:Phoenix.HTML.Form.t/0` struct, applying the\n      permissions currently set in the `msrd_user_perms` Standard Assigns\n      Attribute to filter the data. If the value to be passed in this\n      option is a `t:Phoenix.HTML.Form.t/0` value, the struct should have\n      been generated using `MscmpSystForms.to_form/3` so that the user\n      data visibility permissions will have been allied.\n\n      The second method is to pass `display_data` as a value referencing a\n      display data validation type\n      (`t:MscmpSystForms.Types.data_validation_types/0`).  When this\n      method is used, the values of the `msrd_current_data` and\n      `msrd_original_data` are validated using the standard validation\n      functions (`c:MscmpSystForms.validate_save/2` and\n      `c:MscmpSystForms.validate_post/2`) and then processed into a\n      `t:Phoenix.HTML.Form.t/0` value to save as the new\n      `msrd_display_data` value.  Either of the validation types will\n      result in the application of user data visibility permissions per\n      the `msrd_user_perms` Standard Assigns Attribute.\n\n  * `opts` - this function defines some optionally required parameters\n  which are dependent on the `display_data` parameter. When the\n  `display_data` value is passed as a\n  `t:MscmpSystForms.Types.data_validation_types/0` allowed value the\n  following are required:\n\n    * `original_data` - a struct of values representing the starting data\n    initialized on initial form loading and absent any changes the user\n    may have made and not yet committed to the database.  This value\n    should be available in the standard assigns for `MscmpSystForms` based\n    forms.\n\n    * `current_data` - a map of values representing the current data\n    backing the form.  This data is complete (unfiltered by user data\n    related permissions) and includes any edits made by the user and not\n    yet committed to the database.  This value is available in the\n    standard assigns for `MscmpSystForms` based forms","ref":"Msform.AuthEmailPassword.html#update_display_data/3-parameters"},{"type":"function","title":"Msform.AuthEmailPassword.validate_form_data/2","doc":"","ref":"Msform.AuthEmailPassword.html#validate_form_data/2"},{"type":"function","title":"Msform.AuthEmailPassword.validate_post/2","doc":"Validates a map of form data for validation of form entry prior to final\nsubmission.","ref":"Msform.AuthEmailPassword.html#validate_post/2"},{"type":"type","title":"Msform.AuthEmailPassword.t/0","doc":"","ref":"Msform.AuthEmailPassword.html#t:t/0"},{"type":"module","title":"Msform.AuthPasswordReset","doc":"Form/API data used for the user self-service password reset process.","ref":"Msform.AuthPasswordReset.html"},{"type":"function","title":"Msform.AuthPasswordReset.finish_processing_override/2","doc":"Removes a processing override from the active overrides list.\n\nOnce an active operation previously added to the process overrides list has\ncompleted its processing, this function is used to remove it from the list so\nthat any user interface components that are watching for the operation to be\nactive can resume their normal behavior.","ref":"Msform.AuthPasswordReset.html#finish_processing_override/2"},{"type":"function","title":"Parameters - Msform.AuthPasswordReset.finish_processing_override/2","doc":"* `socket_or_assigns` - the socket or assigns for the current view.\n\n  * `override` - the name of the processing override to remove from the active\n  process overrides list.","ref":"Msform.AuthPasswordReset.html#finish_processing_override/2-parameters"},{"type":"function","title":"Msform.AuthPasswordReset.get_component_info/1","doc":"Retrieves the textual information (`label`, `label_link`, and `info`)\nfield values from the Form Configuration for the identified component.\n\nThis is a convenience function which accepts either a `form_id` value or\na `binding_id` value and returns the textual information for the\ncomponent if found by the passed identifier.","ref":"Msform.AuthPasswordReset.html#get_component_info/1"},{"type":"function","title":"Parameters - Msform.AuthPasswordReset.get_component_info/1","doc":"* `component_id` - this value is either the `form_id` or `binding_id`\n  that is associated with the component for which textual information is\n  being retrieved.","ref":"Msform.AuthPasswordReset.html#get_component_info/1-parameters"},{"type":"function","title":"Msform.AuthPasswordReset.process_reset_attempt/1","doc":"","ref":"Msform.AuthPasswordReset.html#process_reset_attempt/1"},{"type":"function","title":"Msform.AuthPasswordReset.process_reset_finished/1","doc":"","ref":"Msform.AuthPasswordReset.html#process_reset_finished/1"},{"type":"function","title":"Msform.AuthPasswordReset.start_processing_override/2","doc":"Adds a processing override to the active overrides list.\n\nSome user interface components are configured to change their presentation and\ninteractivity when certain, possibly long running, processes are underway.\nThis function adds the value of the `override` parameter to the active\nprocesses list allowing components interest in that processing state to\nrespond accordingly.","ref":"Msform.AuthPasswordReset.html#start_processing_override/2"},{"type":"function","title":"Parameters - Msform.AuthPasswordReset.start_processing_override/2","doc":"* `socket_or_assigns` - the socket or assigns for the current view.\n\n  * `override` - the name of the processing override to activate.  This value\n  will be an atom and will be form implementation specific.","ref":"Msform.AuthPasswordReset.html#start_processing_override/2-parameters"},{"type":"function","title":"Msform.AuthPasswordReset.update_button_state/3","doc":"Sets the state of `MscmpSystForms.WebComponents.msvalidated_button/1`\ncomponents.\n\nValidated buttons exist in one of three states defined by\n`t:MscmpSystForms.Types.msvalidated_button_states/0`.  This function will\nset the state of the validated button identified by the `form_id`\nparameters to the state identified by the `button_state` parameters.","ref":"Msform.AuthPasswordReset.html#update_button_state/3"},{"type":"function","title":"Parameters - Msform.AuthPasswordReset.update_button_state/3","doc":"* `socket_or_assigns` - the socket or assigns for the current view.\n\n  * `form_id` - the identifier of the component to update.  See\n  `c:MscmpSystForms.get_form_config/0` for more about form configuration\n  attributes.\n\n  * `button_state` - the state to which the validated button component\n  should be set.  Any value defined by the\n  `t:MscmpSystForms.Types.msvalidated_button_states/0` type is valid for\n  this purpose.","ref":"Msform.AuthPasswordReset.html#update_button_state/3-parameters"},{"type":"function","title":"Msform.AuthPasswordReset.update_display_data/3","doc":"Updates the display form data with new values.\n\nThe display data of the form, which represents the form's backing data\nafter the application of effective user permissions to purge values that\nthe user is not entitled to see, is set using this function.  The data is\nstored in the view's assigns as a `t:Phoenix.HTML.Form.t/0' value which is\nthen passed to the view for rendering.","ref":"Msform.AuthPasswordReset.html#update_display_data/3"},{"type":"function","title":"Parameters - Msform.AuthPasswordReset.update_display_data/3","doc":"* `socket_or_assigns` - the socket or assigns for the current view.\n\n  * `display_data` - this option contains either the new display data to\n  set and with which to update the form or indicates the kind of data\n  validation to perform on the assigns stored data (`msrd_original_data` &\n  `msrd_current_data`; see `MscmpSystForms.init_assigns/8` for more).\n\n      One method for setting the display data is to pass this option to\n      the function using actual data.  This data can take the form of\n      either a `t:Ecto.Changeset.t/0` value or a `t:Phoenix.HTML.Form.t/0`\n      value. If a Changeset is passed, the function will automatically\n      process it into a `t:Phoenix.HTML.Form.t/0` struct, applying the\n      permissions currently set in the `msrd_user_perms` Standard Assigns\n      Attribute to filter the data. If the value to be passed in this\n      option is a `t:Phoenix.HTML.Form.t/0` value, the struct should have\n      been generated using `MscmpSystForms.to_form/3` so that the user\n      data visibility permissions will have been allied.\n\n      The second method is to pass `display_data` as a value referencing a\n      display data validation type\n      (`t:MscmpSystForms.Types.data_validation_types/0`).  When this\n      method is used, the values of the `msrd_current_data` and\n      `msrd_original_data` are validated using the standard validation\n      functions (`c:MscmpSystForms.validate_save/2` and\n      `c:MscmpSystForms.validate_post/2`) and then processed into a\n      `t:Phoenix.HTML.Form.t/0` value to save as the new\n      `msrd_display_data` value.  Either of the validation types will\n      result in the application of user data visibility permissions per\n      the `msrd_user_perms` Standard Assigns Attribute.\n\n  * `opts` - this function defines some optionally required parameters\n  which are dependent on the `display_data` parameter. When the\n  `display_data` value is passed as a\n  `t:MscmpSystForms.Types.data_validation_types/0` allowed value the\n  following are required:\n\n    * `original_data` - a struct of values representing the starting data\n    initialized on initial form loading and absent any changes the user\n    may have made and not yet committed to the database.  This value\n    should be available in the standard assigns for `MscmpSystForms` based\n    forms.\n\n    * `current_data` - a map of values representing the current data\n    backing the form.  This data is complete (unfiltered by user data\n    related permissions) and includes any edits made by the user and not\n    yet committed to the database.  This value is available in the\n    standard assigns for `MscmpSystForms` based forms","ref":"Msform.AuthPasswordReset.html#update_display_data/3-parameters"},{"type":"function","title":"Msform.AuthPasswordReset.validate_form_data/2","doc":"","ref":"Msform.AuthPasswordReset.html#validate_form_data/2"},{"type":"type","title":"Msform.AuthPasswordReset.t/0","doc":"","ref":"Msform.AuthPasswordReset.html#t:t/0"},{"type":"module","title":"Msform.McpBootstrap","doc":"Form data used during the MCP Bootstrapping process.\n\nNote that currently the data assumes that only an email/password Authenticator\nwill be provided for the administrative Access Account.","ref":"Msform.McpBootstrap.html"},{"type":"function","title":"Msform.McpBootstrap.enter_disallowed_state/1","doc":"","ref":"Msform.McpBootstrap.html#enter_disallowed_state/1"},{"type":"function","title":"Msform.McpBootstrap.enter_finished_state/1","doc":"","ref":"Msform.McpBootstrap.html#enter_finished_state/1"},{"type":"function","title":"Msform.McpBootstrap.enter_records_state/1","doc":"","ref":"Msform.McpBootstrap.html#enter_records_state/1"},{"type":"function","title":"Msform.McpBootstrap.enter_welcome_state/1","doc":"","ref":"Msform.McpBootstrap.html#enter_welcome_state/1"},{"type":"function","title":"Msform.McpBootstrap.finish_processing_override/2","doc":"Removes a processing override from the active overrides list.\n\nOnce an active operation previously added to the process overrides list has\ncompleted its processing, this function is used to remove it from the list so\nthat any user interface components that are watching for the operation to be\nactive can resume their normal behavior.","ref":"Msform.McpBootstrap.html#finish_processing_override/2"},{"type":"function","title":"Parameters - Msform.McpBootstrap.finish_processing_override/2","doc":"* `socket_or_assigns` - the socket or assigns for the current view.\n\n  * `override` - the name of the processing override to remove from the active\n  process overrides list.","ref":"Msform.McpBootstrap.html#finish_processing_override/2-parameters"},{"type":"function","title":"Msform.McpBootstrap.get_component_info/1","doc":"Retrieves the textual information (`label`, `label_link`, and `info`)\nfield values from the Form Configuration for the identified component.\n\nThis is a convenience function which accepts either a `form_id` value or\na `binding_id` value and returns the textual information for the\ncomponent if found by the passed identifier.","ref":"Msform.McpBootstrap.html#get_component_info/1"},{"type":"function","title":"Parameters - Msform.McpBootstrap.get_component_info/1","doc":"* `component_id` - this value is either the `form_id` or `binding_id`\n  that is associated with the component for which textual information is\n  being retrieved.","ref":"Msform.McpBootstrap.html#get_component_info/1-parameters"},{"type":"function","title":"Msform.McpBootstrap.process_disallowed_finished/1","doc":"","ref":"Msform.McpBootstrap.html#process_disallowed_finished/1"},{"type":"function","title":"Msform.McpBootstrap.process_disallowed_load/1","doc":"","ref":"Msform.McpBootstrap.html#process_disallowed_load/1"},{"type":"function","title":"Msform.McpBootstrap.process_records_save/1","doc":"","ref":"Msform.McpBootstrap.html#process_records_save/1"},{"type":"function","title":"Msform.McpBootstrap.process_records_save_finished/1","doc":"","ref":"Msform.McpBootstrap.html#process_records_save_finished/1"},{"type":"function","title":"Msform.McpBootstrap.start_processing_override/2","doc":"Adds a processing override to the active overrides list.\n\nSome user interface components are configured to change their presentation and\ninteractivity when certain, possibly long running, processes are underway.\nThis function adds the value of the `override` parameter to the active\nprocesses list allowing components interest in that processing state to\nrespond accordingly.","ref":"Msform.McpBootstrap.html#start_processing_override/2"},{"type":"function","title":"Parameters - Msform.McpBootstrap.start_processing_override/2","doc":"* `socket_or_assigns` - the socket or assigns for the current view.\n\n  * `override` - the name of the processing override to activate.  This value\n  will be an atom and will be form implementation specific.","ref":"Msform.McpBootstrap.html#start_processing_override/2-parameters"},{"type":"function","title":"Msform.McpBootstrap.update_button_state/3","doc":"Sets the state of `MscmpSystForms.WebComponents.msvalidated_button/1`\ncomponents.\n\nValidated buttons exist in one of three states defined by\n`t:MscmpSystForms.Types.msvalidated_button_states/0`.  This function will\nset the state of the validated button identified by the `form_id`\nparameters to the state identified by the `button_state` parameters.","ref":"Msform.McpBootstrap.html#update_button_state/3"},{"type":"function","title":"Parameters - Msform.McpBootstrap.update_button_state/3","doc":"* `socket_or_assigns` - the socket or assigns for the current view.\n\n  * `form_id` - the identifier of the component to update.  See\n  `c:MscmpSystForms.get_form_config/0` for more about form configuration\n  attributes.\n\n  * `button_state` - the state to which the validated button component\n  should be set.  Any value defined by the\n  `t:MscmpSystForms.Types.msvalidated_button_states/0` type is valid for\n  this purpose.","ref":"Msform.McpBootstrap.html#update_button_state/3-parameters"},{"type":"function","title":"Msform.McpBootstrap.update_display_data/3","doc":"Updates the display form data with new values.\n\nThe display data of the form, which represents the form's backing data\nafter the application of effective user permissions to purge values that\nthe user is not entitled to see, is set using this function.  The data is\nstored in the view's assigns as a `t:Phoenix.HTML.Form.t/0' value which is\nthen passed to the view for rendering.","ref":"Msform.McpBootstrap.html#update_display_data/3"},{"type":"function","title":"Parameters - Msform.McpBootstrap.update_display_data/3","doc":"* `socket_or_assigns` - the socket or assigns for the current view.\n\n  * `display_data` - this option contains either the new display data to\n  set and with which to update the form or indicates the kind of data\n  validation to perform on the assigns stored data (`msrd_original_data` &\n  `msrd_current_data`; see `MscmpSystForms.init_assigns/8` for more).\n\n      One method for setting the display data is to pass this option to\n      the function using actual data.  This data can take the form of\n      either a `t:Ecto.Changeset.t/0` value or a `t:Phoenix.HTML.Form.t/0`\n      value. If a Changeset is passed, the function will automatically\n      process it into a `t:Phoenix.HTML.Form.t/0` struct, applying the\n      permissions currently set in the `msrd_user_perms` Standard Assigns\n      Attribute to filter the data. If the value to be passed in this\n      option is a `t:Phoenix.HTML.Form.t/0` value, the struct should have\n      been generated using `MscmpSystForms.to_form/3` so that the user\n      data visibility permissions will have been allied.\n\n      The second method is to pass `display_data` as a value referencing a\n      display data validation type\n      (`t:MscmpSystForms.Types.data_validation_types/0`).  When this\n      method is used, the values of the `msrd_current_data` and\n      `msrd_original_data` are validated using the standard validation\n      functions (`c:MscmpSystForms.validate_save/2` and\n      `c:MscmpSystForms.validate_post/2`) and then processed into a\n      `t:Phoenix.HTML.Form.t/0` value to save as the new\n      `msrd_display_data` value.  Either of the validation types will\n      result in the application of user data visibility permissions per\n      the `msrd_user_perms` Standard Assigns Attribute.\n\n  * `opts` - this function defines some optionally required parameters\n  which are dependent on the `display_data` parameter. When the\n  `display_data` value is passed as a\n  `t:MscmpSystForms.Types.data_validation_types/0` allowed value the\n  following are required:\n\n    * `original_data` - a struct of values representing the starting data\n    initialized on initial form loading and absent any changes the user\n    may have made and not yet committed to the database.  This value\n    should be available in the standard assigns for `MscmpSystForms` based\n    forms.\n\n    * `current_data` - a map of values representing the current data\n    backing the form.  This data is complete (unfiltered by user data\n    related permissions) and includes any edits made by the user and not\n    yet committed to the database.  This value is available in the\n    standard assigns for `MscmpSystForms` based forms","ref":"Msform.McpBootstrap.html#update_display_data/3-parameters"},{"type":"function","title":"Msform.McpBootstrap.validate_form_data/2","doc":"","ref":"Msform.McpBootstrap.html#validate_form_data/2"},{"type":"function","title":"Msform.McpBootstrap.validate_save/2","doc":"Validates a map of form data for validation of form entry prior to final\nsubmission.","ref":"Msform.McpBootstrap.html#validate_save/2"},{"type":"type","title":"Msform.McpBootstrap.t/0","doc":"","ref":"Msform.McpBootstrap.html#t:t/0"}],"content_type":"text/markdown"}