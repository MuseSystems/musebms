sidebarNodes={"extras":[{"group":"","headers":[{"anchor":"modules","id":"Modules"}],"id":"api-reference","title":"API Reference"}],"modules":[{"group":"API","id":"MscmpSystForms","nodeGroups":[{"key":"form-generation","name":"Form Generation","nodes":[{"anchor":"get_component_info/2","id":"get_component_info/2","title":"get_component_info(module, component_id)"},{"anchor":"get_render_configs/5","id":"get_render_configs/5","title":"get_render_configs(module, feature, mode, state, perms)"},{"anchor":"init_assigns/8","id":"init_assigns/8","title":"init_assigns(socket_or_assigns, session_name, module, feature, mode, state, user_perms, opts \\\\ [])"},{"anchor":"rebuild_component_assigns/1","id":"rebuild_component_assigns/1","title":"rebuild_component_assigns(socket_or_assigns)"}]},{"key":"form-data-management","name":"Form Data Management","nodes":[{"anchor":"to_form/3","id":"to_form/3","title":"to_form(changeset, perms, opts \\\\ [])"},{"anchor":"update_display_data/3","id":"update_display_data/3","title":"update_display_data(socket_or_assigns, display_data, opts \\\\ [])"}]},{"key":"state-management","name":"State Management","nodes":[{"anchor":"finish_processing_override/2","id":"finish_processing_override/2","title":"finish_processing_override(socket_or_assigns, override)"},{"anchor":"set_form_state/2","id":"set_form_state/2","title":"set_form_state(socket_or_assigns, state)"},{"anchor":"set_form_state/3","id":"set_form_state/3","title":"set_form_state(socket_or_assigns, mode, state)"},{"anchor":"set_form_state/4","id":"set_form_state/4","title":"set_form_state(socket_or_assigns, feature, mode, state)"},{"anchor":"start_processing_override/2","id":"start_processing_override/2","title":"start_processing_override(socket_or_assigns, override)"},{"anchor":"update_button_state/3","id":"update_button_state/3","title":"update_button_state(socket_or_assigns, form_id, button_state)"}]},{"key":"callbacks","name":"Callbacks","nodes":[{"anchor":"c:get_form_config/0","id":"get_form_config/0","title":"get_form_config()"},{"anchor":"c:get_form_modes/0","id":"get_form_modes/0","title":"get_form_modes()"},{"anchor":"c:postconnect_init/1","id":"postconnect_init/1","title":"postconnect_init(socket_or_assigns)"},{"anchor":"c:preconnect_init/6","id":"preconnect_init/6","title":"preconnect_init(socket_or_assigns, session_name, feature, mode, state, opts)"},{"anchor":"c:validate_post/2","id":"validate_post/2","title":"validate_post(original_data, current_data)"},{"anchor":"c:validate_save/2","id":"validate_save/2","title":"validate_save(original_data, current_data)"}]}],"sections":[{"anchor":"module-foundational-ideas","id":"Foundational Ideas"},{"anchor":"module-developing-forms","id":"Developing Forms"}],"title":"MscmpSystForms"},{"group":"Web Components","id":"MscmpSystForms.WebComponents","nodeGroups":[{"key":"containers","name":"Containers","nodes":[{"anchor":"mscontainer/1","id":"mscontainer/1","title":"mscontainer(assigns)"},{"anchor":"msdisplay/1","id":"msdisplay/1","title":"msdisplay(assigns)"},{"anchor":"msform/1","id":"msform/1","title":"msform(assigns)"},{"anchor":"msinfo/1","id":"msinfo/1","title":"msinfo(assigns)"},{"anchor":"mslist/1","id":"mslist/1","title":"mslist(assigns)"},{"anchor":"mslistitem/1","id":"mslistitem/1","title":"mslistitem(assigns)"},{"anchor":"msmodal/1","id":"msmodal/1","title":"msmodal(assigns)"},{"anchor":"mssection/1","id":"mssection/1","title":"mssection(assigns)"}]},{"key":"controls","name":"Controls","nodes":[{"anchor":"msbutton/1","id":"msbutton/1","title":"msbutton(assigns)"},{"anchor":"msvalidated_button/1","id":"msvalidated_button/1","title":"msvalidated_button(assigns)"}]},{"key":"inputs","name":"Inputs","nodes":[{"anchor":"msinput/1","id":"msinput/1","title":"msinput(assigns)"}]},{"key":"utility","name":"Utility","nodes":[{"anchor":"msfield_errors/1","id":"msfield_errors/1","title":"msfield_errors(assigns)"},{"anchor":"msicon/1","id":"msicon/1","title":"msicon(assigns)"}]}],"sections":[],"title":"MscmpSystForms.WebComponents"},{"group":"Supporting Types","id":"MscmpSystForms.Types","nodeGroups":[{"key":"types","name":"Types","nodes":[{"anchor":"t:binding_id/0","id":"binding_id/0","title":"binding_id()"},{"anchor":"t:component_display_modes/0","id":"component_display_modes/0","title":"component_display_modes()"},{"anchor":"t:component_info/0","id":"component_info/0","title":"component_info()"},{"anchor":"t:component_modes/0","id":"component_modes/0","title":"component_modes()"},{"anchor":"t:data_validation_types/0","id":"data_validation_types/0","title":"data_validation_types()"},{"anchor":"t:display_modes/0","id":"display_modes/0","title":"display_modes()"},{"anchor":"t:form_id/0","id":"form_id/0","title":"form_id()"},{"anchor":"t:form_state_components/0","id":"form_state_components/0","title":"form_state_components()"},{"anchor":"t:form_state_feature_name/0","id":"form_state_feature_name/0","title":"form_state_feature_name()"},{"anchor":"t:form_state_features/0","id":"form_state_features/0","title":"form_state_features()"},{"anchor":"t:form_state_mode_name/0","id":"form_state_mode_name/0","title":"form_state_mode_name()"},{"anchor":"t:form_state_modes/0","id":"form_state_modes/0","title":"form_state_modes()"},{"anchor":"t:form_state_overrides/0","id":"form_state_overrides/0","title":"form_state_overrides()"},{"anchor":"t:form_state_state_name/0","id":"form_state_state_name/0","title":"form_state_state_name()"},{"anchor":"t:form_state_states/0","id":"form_state_states/0","title":"form_state_states()"},{"anchor":"t:form_states/0","id":"form_states/0","title":"form_states()"},{"anchor":"t:msvalidated_button_states/0","id":"msvalidated_button_states/0","title":"msvalidated_button_states()"},{"anchor":"t:permission_name/0","id":"permission_name/0","title":"permission_name()"},{"anchor":"t:processing_override_name/0","id":"processing_override_name/0","title":"processing_override_name()"},{"anchor":"t:render_configs/0","id":"render_configs/0","title":"render_configs()"},{"anchor":"t:session_name/0","id":"session_name/0","title":"session_name()"},{"anchor":"t:socket_or_assigns/0","id":"socket_or_assigns/0","title":"socket_or_assigns()"}]}],"sections":[],"title":"MscmpSystForms.Types"},{"group":"Supporting Types","id":"MscmpSystForms.Types.ComponentConfig","nodeGroups":[{"key":"types","name":"Types","nodes":[{"anchor":"t:t/0","id":"t/0","title":"t()"}]}],"sections":[],"title":"MscmpSystForms.Types.ComponentConfig"},{"group":"Supporting Types","id":"MscmpSystForms.Types.FormConfig","nodeGroups":[{"key":"types","name":"Types","nodes":[{"anchor":"t:t/0","id":"t/0","title":"t()"}]}],"sections":[],"title":"MscmpSystForms.Types.FormConfig"}],"tasks":[]}