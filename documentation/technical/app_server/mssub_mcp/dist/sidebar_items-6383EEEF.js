sidebarNodes={"modules":[{"id":"DevSupport","deprecated":false,"group":"","title":"DevSupport","sections":[],"nodeGroups":[{"name":"Functions","nodes":[{"id":"cleanup_database/1","deprecated":false,"title":"cleanup_database(db_kind)","anchor":"cleanup_database/1"},{"id":"start_dev_environment/1","deprecated":false,"title":"start_dev_environment(db_kind \\\\ :unit_testing)","anchor":"start_dev_environment/1"},{"id":"stop_dev_environment/1","deprecated":false,"title":"stop_dev_environment(db_kind \\\\ :unit_testing)","anchor":"stop_dev_environment/1"}],"key":"functions"}]},{"id":"MssubMcp.Types","deprecated":false,"group":"","title":"MssubMcp.Types","sections":[],"nodeGroups":[{"name":"Types","nodes":[{"id":"session_name/0","deprecated":false,"title":"session_name()","anchor":"t:session_name/0"},{"id":"tenant_bootstrap_params/0","deprecated":false,"title":"tenant_bootstrap_params()","anchor":"t:tenant_bootstrap_params/0"},{"id":"tenant_bootstrap_result/0","deprecated":false,"title":"tenant_bootstrap_result()","anchor":"t:tenant_bootstrap_result/0"}],"key":"types"}]},{"id":"MssubMcp.Updater","deprecated":false,"group":"","title":"MssubMcp.Updater","sections":[],"nodeGroups":[{"name":"Functions","nodes":[{"id":"child_spec/1","deprecated":false,"title":"child_spec(opts)","anchor":"child_spec/1"},{"id":"start_link/1","deprecated":false,"title":"start_link(opts)","anchor":"start_link/1"}],"key":"functions"}]},{"id":"MssubMcp","deprecated":false,"group":"API","title":"MssubMcp","sections":[],"nodeGroups":[{"name":"Instance Manager Runtime","nodes":[{"id":"start_all_applications/2","deprecated":false,"title":"start_all_applications(startup_options, opts \\\\ [])","anchor":"start_all_applications/2"},{"id":"start_application/3","deprecated":false,"title":"start_application(application, startup_options, opts \\\\ [])","anchor":"start_application/3"},{"id":"start_instance/3","deprecated":false,"title":"start_instance(instance, startup_options, opts \\\\ [])","anchor":"start_instance/3"},{"id":"stop_all_applications/1","deprecated":false,"title":"stop_all_applications(opts \\\\ [])","anchor":"stop_all_applications/1"},{"id":"stop_application/2","deprecated":false,"title":"stop_application(application, opts \\\\ [])","anchor":"stop_application/2"},{"id":"stop_instance/2","deprecated":false,"title":"stop_instance(instance, opts \\\\ [])","anchor":"stop_instance/2"}],"key":"instance-manager-runtime"},{"name":"Instance Applications","nodes":[{"id":"create_application/1","deprecated":false,"title":"create_application(application_params)","anchor":"create_application/1"},{"id":"create_application_context/1","deprecated":false,"title":"create_application_context(application_context_params)","anchor":"create_application_context/1"},{"id":"delete_application_context/1","deprecated":false,"title":"delete_application_context(application_context_id)","anchor":"delete_application_context/1"},{"id":"get_application/2","deprecated":false,"title":"get_application(application, opts \\\\ [])","anchor":"get_application/2"},{"id":"get_application_context_id_by_name/1","deprecated":false,"title":"get_application_context_id_by_name(application_context_name)","anchor":"get_application_context_id_by_name/1"},{"id":"get_application_id_by_name/1","deprecated":false,"title":"get_application_id_by_name(application_name)","anchor":"get_application_id_by_name/1"},{"id":"list_application_contexts/1","deprecated":false,"title":"list_application_contexts(application_id \\\\ nil)","anchor":"list_application_contexts/1"},{"id":"update_application/2","deprecated":false,"title":"update_application(application, application_params)","anchor":"update_application/2"},{"id":"update_application_context/2","deprecated":false,"title":"update_application_context(application_context, application_context_params)","anchor":"update_application_context/2"}],"key":"instance-applications"},{"name":"Instance Types","nodes":[{"id":"create_instance_type/1","deprecated":false,"title":"create_instance_type(instance_type_params)","anchor":"create_instance_type/1"},{"id":"create_instance_type_application/2","deprecated":false,"title":"create_instance_type_application(instance_type_id, application_id)","anchor":"create_instance_type_application/2"},{"id":"delete_instance_type/1","deprecated":false,"title":"delete_instance_type(instance_type_name)","anchor":"delete_instance_type/1"},{"id":"delete_instance_type_application/1","deprecated":false,"title":"delete_instance_type_application(instance_type_application)","anchor":"delete_instance_type_application/1"},{"id":"get_instance_type_by_name/1","deprecated":false,"title":"get_instance_type_by_name(instance_type_name)","anchor":"get_instance_type_by_name/1"},{"id":"get_instance_type_default/0","deprecated":false,"title":"get_instance_type_default()","anchor":"get_instance_type_default/0"},{"id":"update_instance_type/2","deprecated":false,"title":"update_instance_type(instance_type_name, instance_type_params \\\\ %{})","anchor":"update_instance_type/2"},{"id":"update_instance_type_context/2","deprecated":false,"title":"update_instance_type_context(instance_type_context, instance_type_context_params \\\\ %{})","anchor":"update_instance_type_context/2"}],"key":"instance-types"},{"name":"Owners","nodes":[{"id":"create_owner/1","deprecated":false,"title":"create_owner(owner_params)","anchor":"create_owner/1"},{"id":"get_owner_by_name/1","deprecated":false,"title":"get_owner_by_name(owner_name)","anchor":"get_owner_by_name/1"},{"id":"get_owner_id_by_name/1","deprecated":false,"title":"get_owner_id_by_name(owner_name)","anchor":"get_owner_id_by_name/1"},{"id":"get_owner_state_by_name/1","deprecated":false,"title":"get_owner_state_by_name(owner_state_name)","anchor":"get_owner_state_by_name/1"},{"id":"get_owner_state_default/1","deprecated":false,"title":"get_owner_state_default(functional_type \\\\ nil)","anchor":"get_owner_state_default/1"},{"id":"owner_exists?/1","deprecated":false,"title":"owner_exists?(opts \\\\ [])","anchor":"owner_exists?/1"},{"id":"purge_owner/1","deprecated":false,"title":"purge_owner(owner)","anchor":"purge_owner/1"},{"id":"update_owner/2","deprecated":false,"title":"update_owner(owner, update_params)","anchor":"update_owner/2"}],"key":"owners"},{"name":"Instances","nodes":[{"id":"create_instance/1","deprecated":false,"title":"create_instance(instance_params)","anchor":"create_instance/1"},{"id":"get_default_instance_state_ids/0","deprecated":false,"title":"get_default_instance_state_ids()","anchor":"get_default_instance_state_ids/0"},{"id":"get_instance_by_name/1","deprecated":false,"title":"get_instance_by_name(instance_name)","anchor":"get_instance_by_name/1"},{"id":"get_instance_datastore_options/2","deprecated":false,"title":"get_instance_datastore_options(instance, startup_options)","anchor":"get_instance_datastore_options/2"},{"id":"get_instance_id_by_name/1","deprecated":false,"title":"get_instance_id_by_name(instance_name)","anchor":"get_instance_id_by_name/1"},{"id":"get_instance_state_by_name/1","deprecated":false,"title":"get_instance_state_by_name(instance_state_name)","anchor":"get_instance_state_by_name/1"},{"id":"get_instance_state_default/1","deprecated":false,"title":"get_instance_state_default(functional_type \\\\ nil)","anchor":"get_instance_state_default/1"},{"id":"initialize_instance/3","deprecated":false,"title":"initialize_instance(instance_id, startup_options, opts \\\\ [])","anchor":"initialize_instance/3"},{"id":"purge_instance/2","deprecated":false,"title":"purge_instance(instance, startup_options)","anchor":"purge_instance/2"},{"id":"set_instance_state/2","deprecated":false,"title":"set_instance_state(instance, instance_state_id)","anchor":"set_instance_state/2"}],"key":"instances"},{"name":"Authentication Enums","nodes":[{"id":"get_credential_type_by_name/1","deprecated":false,"title":"get_credential_type_by_name(credential_type_name)","anchor":"get_credential_type_by_name/1"},{"id":"get_credential_type_default/1","deprecated":false,"title":"get_credential_type_default(functional_type \\\\ nil)","anchor":"get_credential_type_default/1"},{"id":"get_identity_type_by_name/1","deprecated":false,"title":"get_identity_type_by_name(identity_type_name)","anchor":"get_identity_type_by_name/1"},{"id":"get_identity_type_default/1","deprecated":false,"title":"get_identity_type_default(functional_type \\\\ nil)","anchor":"get_identity_type_default/1"}],"key":"authentication-enums"},{"name":"Access Accounts","nodes":[{"id":"access_account_exists?/1","deprecated":false,"title":"access_account_exists?(opts \\\\ [])","anchor":"access_account_exists?/1"},{"id":"create_access_account/1","deprecated":false,"title":"create_access_account(access_account_params)","anchor":"create_access_account/1"},{"id":"get_access_account_by_name/1","deprecated":false,"title":"get_access_account_by_name(access_account_name)","anchor":"get_access_account_by_name/1"},{"id":"get_access_account_id_by_name/1","deprecated":false,"title":"get_access_account_id_by_name(access_account_name)","anchor":"get_access_account_id_by_name/1"},{"id":"get_access_account_state_by_name/1","deprecated":false,"title":"get_access_account_state_by_name(access_account_state_name)","anchor":"get_access_account_state_by_name/1"},{"id":"get_access_account_state_default/1","deprecated":false,"title":"get_access_account_state_default(functional_type \\\\ nil)","anchor":"get_access_account_state_default/1"},{"id":"purge_access_account/1","deprecated":false,"title":"purge_access_account(access_account)","anchor":"purge_access_account/1"},{"id":"update_access_account/2","deprecated":false,"title":"update_access_account(access_account, access_account_params)","anchor":"update_access_account/2"}],"key":"access-accounts"},{"name":"Access Account/Instance Assocs.","nodes":[{"id":"accept_instance_invite/1","deprecated":false,"title":"accept_instance_invite(access_account_instance_assoc)","anchor":"accept_instance_invite/1"},{"id":"accept_instance_invite/2","deprecated":false,"title":"accept_instance_invite(access_account_id, instance_id)","anchor":"accept_instance_invite/2"},{"id":"decline_instance_invite/1","deprecated":false,"title":"decline_instance_invite(access_account_instance_assoc)","anchor":"decline_instance_invite/1"},{"id":"decline_instance_invite/2","deprecated":false,"title":"decline_instance_invite(access_account_id, instance_id)","anchor":"decline_instance_invite/2"},{"id":"invite_to_instance/3","deprecated":false,"title":"invite_to_instance(access_account_id, instance_id, opts \\\\ [])","anchor":"invite_to_instance/3"},{"id":"revoke_instance_access/1","deprecated":false,"title":"revoke_instance_access(access_account_instance_assoc)","anchor":"revoke_instance_access/1"},{"id":"revoke_instance_access/2","deprecated":false,"title":"revoke_instance_access(access_account_id, instance_id)","anchor":"revoke_instance_access/2"}],"key":"access-account-instance-assocs"},{"name":"Password Rules","nodes":[{"id":"create_disallowed_password/1","deprecated":false,"title":"create_disallowed_password(password)","anchor":"create_disallowed_password/1"},{"id":"create_owner_password_rules/2","deprecated":false,"title":"create_owner_password_rules(owner_id, insert_params)","anchor":"create_owner_password_rules/2"},{"id":"delete_disallowed_password/1","deprecated":false,"title":"delete_disallowed_password(password)","anchor":"delete_disallowed_password/1"},{"id":"delete_owner_password_rules/1","deprecated":false,"title":"delete_owner_password_rules(owner_id)","anchor":"delete_owner_password_rules/1"},{"id":"disallowed_passwords_populated?/0","deprecated":false,"title":"disallowed_passwords_populated?()","anchor":"disallowed_passwords_populated?/0"},{"id":"get_access_account_password_rule/1","deprecated":false,"title":"get_access_account_password_rule(access_account_id)","anchor":"get_access_account_password_rule/1"},{"id":"get_access_account_password_rule!/1","deprecated":false,"title":"get_access_account_password_rule!(access_account_id)","anchor":"get_access_account_password_rule!/1"},{"id":"get_generic_password_rules/2","deprecated":false,"title":"get_generic_password_rules(pwd_rules_struct, access_account_id \\\\ nil)","anchor":"get_generic_password_rules/2"},{"id":"get_global_password_rules/0","deprecated":false,"title":"get_global_password_rules()","anchor":"get_global_password_rules/0"},{"id":"get_global_password_rules!/0","deprecated":false,"title":"get_global_password_rules!()","anchor":"get_global_password_rules!/0"},{"id":"get_owner_password_rules/1","deprecated":false,"title":"get_owner_password_rules(owner_id)","anchor":"get_owner_password_rules/1"},{"id":"get_owner_password_rules!/1","deprecated":false,"title":"get_owner_password_rules!(owner_id)","anchor":"get_owner_password_rules!/1"},{"id":"load_disallowed_passwords/2","deprecated":false,"title":"load_disallowed_passwords(password_list, opts \\\\ [])","anchor":"load_disallowed_passwords/2"},{"id":"password_disallowed/1","deprecated":false,"title":"password_disallowed(password)","anchor":"password_disallowed/1"},{"id":"password_disallowed?/1","deprecated":false,"title":"password_disallowed?(password)","anchor":"password_disallowed?/1"},{"id":"test_credential/2","deprecated":false,"title":"test_credential(access_account_id, plaintext_pwd)","anchor":"test_credential/2"},{"id":"update_global_password_rules/1","deprecated":false,"title":"update_global_password_rules(update_params)","anchor":"update_global_password_rules/1"},{"id":"update_global_password_rules/2","deprecated":false,"title":"update_global_password_rules(global_password_rules, update_params)","anchor":"update_global_password_rules/2"},{"id":"update_owner_password_rules/2","deprecated":false,"title":"update_owner_password_rules(owner, update_params)","anchor":"update_owner_password_rules/2"},{"id":"verify_password_rules/2","deprecated":false,"title":"verify_password_rules(test_rules, standard_rules \\\\ nil)","anchor":"verify_password_rules/2"},{"id":"verify_password_rules!/2","deprecated":false,"title":"verify_password_rules!(test_rules, standard_rules \\\\ nil)","anchor":"verify_password_rules!/2"}],"key":"password-rules"},{"name":"Network Rules","nodes":[{"id":"create_disallowed_host/1","deprecated":false,"title":"create_disallowed_host(host_address)","anchor":"create_disallowed_host/1"},{"id":"create_global_network_rule/1","deprecated":false,"title":"create_global_network_rule(insert_params)","anchor":"create_global_network_rule/1"},{"id":"create_instance_network_rule/2","deprecated":false,"title":"create_instance_network_rule(instance_id, insert_params)","anchor":"create_instance_network_rule/2"},{"id":"create_owner_network_rule/2","deprecated":false,"title":"create_owner_network_rule(owner_id, insert_params)","anchor":"create_owner_network_rule/2"},{"id":"delete_disallowed_host/1","deprecated":false,"title":"delete_disallowed_host(disallowed_host)","anchor":"delete_disallowed_host/1"},{"id":"delete_disallowed_host_addr/1","deprecated":false,"title":"delete_disallowed_host_addr(host_addr)","anchor":"delete_disallowed_host_addr/1"},{"id":"delete_global_network_rule/1","deprecated":false,"title":"delete_global_network_rule(global_network_rule_id)","anchor":"delete_global_network_rule/1"},{"id":"delete_instance_network_rule/1","deprecated":false,"title":"delete_instance_network_rule(instance_network_rule_id)","anchor":"delete_instance_network_rule/1"},{"id":"delete_owner_network_rule/1","deprecated":false,"title":"delete_owner_network_rule(owner_network_rule_id)","anchor":"delete_owner_network_rule/1"},{"id":"get_applied_network_rule/3","deprecated":false,"title":"get_applied_network_rule(host_address, instance_id \\\\ nil, instance_owner_id \\\\ nil)","anchor":"get_applied_network_rule/3"},{"id":"get_applied_network_rule!/3","deprecated":false,"title":"get_applied_network_rule!(host_address, instance_id \\\\ nil, instance_owner_id \\\\ nil)","anchor":"get_applied_network_rule!/3"},{"id":"get_disallowed_host_record_by_host/1","deprecated":false,"title":"get_disallowed_host_record_by_host(host_addr)","anchor":"get_disallowed_host_record_by_host/1"},{"id":"get_disallowed_host_record_by_host!/1","deprecated":false,"title":"get_disallowed_host_record_by_host!(host_addr)","anchor":"get_disallowed_host_record_by_host!/1"},{"id":"get_disallowed_host_record_by_id/1","deprecated":false,"title":"get_disallowed_host_record_by_id(disallowed_host_id)","anchor":"get_disallowed_host_record_by_id/1"},{"id":"get_disallowed_host_record_by_id!/1","deprecated":false,"title":"get_disallowed_host_record_by_id!(disallowed_host_id)","anchor":"get_disallowed_host_record_by_id!/1"},{"id":"get_global_network_rule/1","deprecated":false,"title":"get_global_network_rule(global_network_rule_id)","anchor":"get_global_network_rule/1"},{"id":"get_global_network_rule!/1","deprecated":false,"title":"get_global_network_rule!(global_network_rule_id)","anchor":"get_global_network_rule!/1"},{"id":"get_instance_network_rule/1","deprecated":false,"title":"get_instance_network_rule(instance_network_rule_id)","anchor":"get_instance_network_rule/1"},{"id":"get_instance_network_rule!/1","deprecated":false,"title":"get_instance_network_rule!(instance_network_rule_id)","anchor":"get_instance_network_rule!/1"},{"id":"get_owner_network_rule/1","deprecated":false,"title":"get_owner_network_rule(owner_network_rule_id)","anchor":"get_owner_network_rule/1"},{"id":"get_owner_network_rule!/1","deprecated":false,"title":"get_owner_network_rule!(owner_network_rule_id)","anchor":"get_owner_network_rule!/1"},{"id":"host_disallowed/1","deprecated":false,"title":"host_disallowed(host_address)","anchor":"host_disallowed/1"},{"id":"host_disallowed?/1","deprecated":false,"title":"host_disallowed?(host_address)","anchor":"host_disallowed?/1"},{"id":"update_global_network_rule/2","deprecated":false,"title":"update_global_network_rule(global_network_rule, update_params)","anchor":"update_global_network_rule/2"},{"id":"update_instance_network_rule/2","deprecated":false,"title":"update_instance_network_rule(instance_network_rule, update_params)","anchor":"update_instance_network_rule/2"},{"id":"update_owner_network_rule/2","deprecated":false,"title":"update_owner_network_rule(owner_network_rule, update_params)","anchor":"update_owner_network_rule/2"}],"key":"network-rules"},{"name":"Account Code","nodes":[{"id":"create_or_reset_account_code/2","deprecated":false,"title":"create_or_reset_account_code(access_account_id, opts \\\\ [])","anchor":"create_or_reset_account_code/2"},{"id":"get_account_code_by_access_account_id/1","deprecated":false,"title":"get_account_code_by_access_account_id(access_account_id)","anchor":"get_account_code_by_access_account_id/1"},{"id":"identify_access_account_by_code/2","deprecated":false,"title":"identify_access_account_by_code(account_code, owner_id)","anchor":"identify_access_account_by_code/2"},{"id":"revoke_account_code/1","deprecated":false,"title":"revoke_account_code(access_account_id)","anchor":"revoke_account_code/1"}],"key":"account-code"},{"name":"Authenticator Management","nodes":[{"id":"access_account_credential_recoverable!/1","deprecated":false,"title":"access_account_credential_recoverable!(access_account_id)","anchor":"access_account_credential_recoverable!/1"},{"id":"create_authenticator_api_token/2","deprecated":false,"title":"create_authenticator_api_token(access_account_id, opts \\\\ [])","anchor":"create_authenticator_api_token/2"},{"id":"create_authenticator_email_password/4","deprecated":false,"title":"create_authenticator_email_password(access_account_id, email_address, plaintext_pwd, opts \\\\ [])","anchor":"create_authenticator_email_password/4"},{"id":"request_identity_validation/2","deprecated":false,"title":"request_identity_validation(target_identity, opts \\\\ [])","anchor":"request_identity_validation/2"},{"id":"request_password_recovery/2","deprecated":false,"title":"request_password_recovery(access_account_id, opts \\\\ [])","anchor":"request_password_recovery/2"},{"id":"reset_password_credential/2","deprecated":false,"title":"reset_password_credential(access_account_id, new_credential)","anchor":"reset_password_credential/2"},{"id":"revoke_api_token/1","deprecated":false,"title":"revoke_api_token(identity)","anchor":"revoke_api_token/1"},{"id":"revoke_password_recovery/1","deprecated":false,"title":"revoke_password_recovery(access_account_id)","anchor":"revoke_password_recovery/1"},{"id":"revoke_validator_for_identity_id/1","deprecated":false,"title":"revoke_validator_for_identity_id(target_identity_id)","anchor":"revoke_validator_for_identity_id/1"},{"id":"update_api_token_external_name/2","deprecated":false,"title":"update_api_token_external_name(identity, external_name)","anchor":"update_api_token_external_name/2"}],"key":"authenticator-management"},{"name":"Authentication","nodes":[{"id":"authenticate_api_token/5","deprecated":false,"title":"authenticate_api_token(identifier, plaintext_token, host_addr, instance_id, opts \\\\ [])","anchor":"authenticate_api_token/5"},{"id":"authenticate_email_password/2","deprecated":false,"title":"authenticate_email_password(authentication_state, opts \\\\ [])","anchor":"authenticate_email_password/2"},{"id":"authenticate_email_password/4","deprecated":false,"title":"authenticate_email_password(email_address, plaintext_pwd, host_address, opts \\\\ [])","anchor":"authenticate_email_password/4"},{"id":"authenticate_recovery_token/4","deprecated":false,"title":"authenticate_recovery_token(identifier, plaintext_token, host_addr, opts \\\\ [])","anchor":"authenticate_recovery_token/4"},{"id":"authenticate_validation_token/4","deprecated":false,"title":"authenticate_validation_token(identifier, plaintext_token, host_address, opts \\\\ [])","anchor":"authenticate_validation_token/4"}],"key":"authentication"},{"name":"Session Management","nodes":[{"id":"create_session/2","deprecated":false,"title":"create_session(session_data, opts \\\\ [])","anchor":"create_session/2"},{"id":"delete_session/1","deprecated":false,"title":"delete_session(session_name)","anchor":"delete_session/1"},{"id":"generate_session_name/0","deprecated":false,"title":"generate_session_name()","anchor":"generate_session_name/0"},{"id":"get_session/2","deprecated":false,"title":"get_session(session_name, opts \\\\ [])","anchor":"get_session/2"},{"id":"purge_expired_sessions/1","deprecated":false,"title":"purge_expired_sessions(opts \\\\ [])","anchor":"purge_expired_sessions/1"},{"id":"refresh_session_expiration/2","deprecated":false,"title":"refresh_session_expiration(session_name, opts \\\\ [])","anchor":"refresh_session_expiration/2"},{"id":"update_session/3","deprecated":false,"title":"update_session(session_name, session_data, opts \\\\ [])","anchor":"update_session/3"}],"key":"session-management"},{"name":"Permissions","nodes":[{"id":"compare_scopes/2","deprecated":false,"title":"compare_scopes(test_scope, standard_scope)","anchor":"compare_scopes/2"},{"id":"get_effective_perm_grants/2","deprecated":false,"title":"get_effective_perm_grants(selector, opts \\\\ [])","anchor":"get_effective_perm_grants/2"},{"id":"grant_perm_role/2","deprecated":false,"title":"grant_perm_role(selector, perm_role_id)","anchor":"grant_perm_role/2"},{"id":"list_perm_denials/2","deprecated":false,"title":"list_perm_denials(selector, opts \\\\ [])","anchor":"list_perm_denials/2"},{"id":"list_perm_grants/2","deprecated":false,"title":"list_perm_grants(selector, opts \\\\ [])","anchor":"list_perm_grants/2"},{"id":"revoke_perm_role/2","deprecated":false,"title":"revoke_perm_role(selector, perm_role_id)","anchor":"revoke_perm_role/2"}],"key":"permissions"},{"name":"MCP Processing","nodes":[{"id":"bootstrap_tenant/1","deprecated":false,"title":"bootstrap_tenant(params)","anchor":"bootstrap_tenant/1"},{"id":"process_operation/1","deprecated":false,"title":"process_operation(operation)","anchor":"process_operation/1"},{"id":"start_mcp_service_context/0","deprecated":false,"title":"start_mcp_service_context()","anchor":"start_mcp_service_context/0"},{"id":"stop_mcp_service_context/1","deprecated":false,"title":"stop_mcp_service_context(replacement_service_names \\\\ {nil, nil, nil})","anchor":"stop_mcp_service_context/1"}],"key":"mcp-processing"},{"name":"Functions","nodes":[{"id":"get_perm_role_id_by_name/2","deprecated":false,"title":"get_perm_role_id_by_name(perm_func_type_name, perm_role_name)","anchor":"get_perm_role_id_by_name/2"},{"id":"get_setting_value/2","deprecated":false,"title":"get_setting_value(setting_name, setting_type)","anchor":"get_setting_value/2"},{"id":"get_setting_values/1","deprecated":false,"title":"get_setting_values(setting_name)","anchor":"get_setting_values/1"},{"id":"list_all_settings/0","deprecated":false,"title":"list_all_settings()","anchor":"list_all_settings/0"},{"id":"set_setting_value/3","deprecated":false,"title":"set_setting_value(setting_name, setting_type, setting_value)","anchor":"set_setting_value/3"},{"id":"set_setting_values/2","deprecated":false,"title":"set_setting_values(setting_name, update_params)","anchor":"set_setting_values/2"}],"key":"functions"}]}],"extras":[{"id":"api-reference","group":"","title":"API Reference","headers":[{"id":"Modules","anchor":"modules"}]}],"tasks":[]}