sidebarNodes={"extras":[{"group":"","headers":[{"anchor":"modules","id":"Modules"}],"id":"api-reference","title":"API Reference"}],"modules":[{"group":"","id":"DevSupport","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"cleanup_database/1","id":"cleanup_database/1","title":"cleanup_database(db_kind)"},{"anchor":"start_dev_environment/1","id":"start_dev_environment/1","title":"start_dev_environment(db_kind \\\\ :unit_testing)"},{"anchor":"stop_dev_environment/1","id":"stop_dev_environment/1","title":"stop_dev_environment(db_kind \\\\ :unit_testing)"}]}],"sections":[],"title":"DevSupport"},{"group":"API","id":"MssubMcp","nodeGroups":[{"key":"instance-manager-runtime","name":"Instance Manager Runtime","nodes":[{"anchor":"start_all_applications/2","id":"start_all_applications/2","title":"start_all_applications(startup_options, opts \\\\ [])"},{"anchor":"start_application/3","id":"start_application/3","title":"start_application(application, startup_options, opts \\\\ [])"},{"anchor":"start_instance/3","id":"start_instance/3","title":"start_instance(instance, startup_options, opts \\\\ [])"},{"anchor":"stop_all_applications/1","id":"stop_all_applications/1","title":"stop_all_applications(opts \\\\ [])"},{"anchor":"stop_application/2","id":"stop_application/2","title":"stop_application(application, opts \\\\ [])"},{"anchor":"stop_instance/2","id":"stop_instance/2","title":"stop_instance(instance, opts \\\\ [])"}]},{"key":"instance-applications","name":"Instance Applications","nodes":[{"anchor":"create_application/1","id":"create_application/1","title":"create_application(application_params)"},{"anchor":"create_application_context/1","id":"create_application_context/1","title":"create_application_context(application_context_params)"},{"anchor":"delete_application_context/1","id":"delete_application_context/1","title":"delete_application_context(application_context_id)"},{"anchor":"get_application/2","id":"get_application/2","title":"get_application(application, opts \\\\ [])"},{"anchor":"get_application_context_id_by_name/1","id":"get_application_context_id_by_name/1","title":"get_application_context_id_by_name(application_context_name)"},{"anchor":"get_application_id_by_name/1","id":"get_application_id_by_name/1","title":"get_application_id_by_name(application_name)"},{"anchor":"list_application_contexts/1","id":"list_application_contexts/1","title":"list_application_contexts(application_id \\\\ nil)"},{"anchor":"update_application/2","id":"update_application/2","title":"update_application(application, application_params)"},{"anchor":"update_application_context/2","id":"update_application_context/2","title":"update_application_context(application_context, application_context_params)"}]},{"key":"instance-types","name":"Instance Types","nodes":[{"anchor":"create_instance_type/1","id":"create_instance_type/1","title":"create_instance_type(instance_type_params)"},{"anchor":"create_instance_type_application/2","id":"create_instance_type_application/2","title":"create_instance_type_application(instance_type_id, application_id)"},{"anchor":"delete_instance_type/1","id":"delete_instance_type/1","title":"delete_instance_type(instance_type_name)"},{"anchor":"delete_instance_type_application/1","id":"delete_instance_type_application/1","title":"delete_instance_type_application(instance_type_application)"},{"anchor":"get_instance_type_by_name/1","id":"get_instance_type_by_name/1","title":"get_instance_type_by_name(instance_type_name)"},{"anchor":"get_instance_type_default/0","id":"get_instance_type_default/0","title":"get_instance_type_default()"},{"anchor":"update_instance_type/2","id":"update_instance_type/2","title":"update_instance_type(instance_type_name, instance_type_params \\\\ %{})"},{"anchor":"update_instance_type_context/2","id":"update_instance_type_context/2","title":"update_instance_type_context(instance_type_context, instance_type_context_params \\\\ %{})"}]},{"key":"owners","name":"Owners","nodes":[{"anchor":"create_owner/1","id":"create_owner/1","title":"create_owner(owner_params)"},{"anchor":"get_owner_by_name/1","id":"get_owner_by_name/1","title":"get_owner_by_name(owner_name)"},{"anchor":"get_owner_id_by_name/1","id":"get_owner_id_by_name/1","title":"get_owner_id_by_name(owner_name)"},{"anchor":"get_owner_state_by_name/1","id":"get_owner_state_by_name/1","title":"get_owner_state_by_name(owner_state_name)"},{"anchor":"get_owner_state_default/1","id":"get_owner_state_default/1","title":"get_owner_state_default(functional_type \\\\ nil)"},{"anchor":"purge_owner/1","id":"purge_owner/1","title":"purge_owner(owner)"},{"anchor":"update_owner/2","id":"update_owner/2","title":"update_owner(owner, update_params)"}]},{"key":"instances","name":"Instances","nodes":[{"anchor":"create_instance/1","id":"create_instance/1","title":"create_instance(instance_params)"},{"anchor":"get_default_instance_state_ids/0","id":"get_default_instance_state_ids/0","title":"get_default_instance_state_ids()"},{"anchor":"get_instance_by_name/1","id":"get_instance_by_name/1","title":"get_instance_by_name(instance_name)"},{"anchor":"get_instance_datastore_options/2","id":"get_instance_datastore_options/2","title":"get_instance_datastore_options(instance, startup_options)"},{"anchor":"get_instance_id_by_name/1","id":"get_instance_id_by_name/1","title":"get_instance_id_by_name(instance_name)"},{"anchor":"get_instance_state_by_name/1","id":"get_instance_state_by_name/1","title":"get_instance_state_by_name(instance_state_name)"},{"anchor":"get_instance_state_default/1","id":"get_instance_state_default/1","title":"get_instance_state_default(functional_type \\\\ nil)"},{"anchor":"initialize_instance/3","id":"initialize_instance/3","title":"initialize_instance(instance_id, startup_options, opts \\\\ [])"},{"anchor":"purge_instance/2","id":"purge_instance/2","title":"purge_instance(instance, startup_options)"},{"anchor":"set_instance_state/2","id":"set_instance_state/2","title":"set_instance_state(instance, instance_state_id)"}]},{"key":"authentication-enums","name":"Authentication Enums","nodes":[{"anchor":"get_credential_type_by_name/1","id":"get_credential_type_by_name/1","title":"get_credential_type_by_name(credential_type_name)"},{"anchor":"get_credential_type_default/1","id":"get_credential_type_default/1","title":"get_credential_type_default(functional_type \\\\ nil)"},{"anchor":"get_identity_type_by_name/1","id":"get_identity_type_by_name/1","title":"get_identity_type_by_name(identity_type_name)"},{"anchor":"get_identity_type_default/1","id":"get_identity_type_default/1","title":"get_identity_type_default(functional_type \\\\ nil)"}]},{"key":"access-accounts","name":"Access Accounts","nodes":[{"anchor":"create_access_account/1","id":"create_access_account/1","title":"create_access_account(access_account_params)"},{"anchor":"get_access_account_by_name/1","id":"get_access_account_by_name/1","title":"get_access_account_by_name(access_account_name)"},{"anchor":"get_access_account_id_by_name/1","id":"get_access_account_id_by_name/1","title":"get_access_account_id_by_name(access_account_name)"},{"anchor":"get_access_account_state_by_name/1","id":"get_access_account_state_by_name/1","title":"get_access_account_state_by_name(access_account_state_name)"},{"anchor":"get_access_account_state_default/1","id":"get_access_account_state_default/1","title":"get_access_account_state_default(functional_type \\\\ nil)"},{"anchor":"purge_access_account/1","id":"purge_access_account/1","title":"purge_access_account(access_account)"},{"anchor":"update_access_account/2","id":"update_access_account/2","title":"update_access_account(access_account, access_account_params)"}]},{"key":"access-account-instance-assocs","name":"Access Account/Instance Assocs.","nodes":[{"anchor":"accept_instance_invite/1","id":"accept_instance_invite/1","title":"accept_instance_invite(access_account_instance_assoc)"},{"anchor":"accept_instance_invite/2","id":"accept_instance_invite/2","title":"accept_instance_invite(access_account_id, instance_id)"},{"anchor":"decline_instance_invite/1","id":"decline_instance_invite/1","title":"decline_instance_invite(access_account_instance_assoc)"},{"anchor":"decline_instance_invite/2","id":"decline_instance_invite/2","title":"decline_instance_invite(access_account_id, instance_id)"},{"anchor":"invite_to_instance/3","id":"invite_to_instance/3","title":"invite_to_instance(access_account_id, instance_id, opts \\\\ [])"},{"anchor":"revoke_instance_access/1","id":"revoke_instance_access/1","title":"revoke_instance_access(access_account_instance_assoc)"},{"anchor":"revoke_instance_access/2","id":"revoke_instance_access/2","title":"revoke_instance_access(access_account_id, instance_id)"}]},{"key":"password-rules","name":"Password Rules","nodes":[{"anchor":"create_disallowed_password/1","id":"create_disallowed_password/1","title":"create_disallowed_password(password)"},{"anchor":"create_owner_password_rules/2","id":"create_owner_password_rules/2","title":"create_owner_password_rules(owner_id, insert_params)"},{"anchor":"delete_disallowed_password/1","id":"delete_disallowed_password/1","title":"delete_disallowed_password(password)"},{"anchor":"delete_owner_password_rules/1","id":"delete_owner_password_rules/1","title":"delete_owner_password_rules(owner_id)"},{"anchor":"get_access_account_password_rule/1","id":"get_access_account_password_rule/1","title":"get_access_account_password_rule(access_account_id)"},{"anchor":"get_access_account_password_rule!/1","id":"get_access_account_password_rule!/1","title":"get_access_account_password_rule!(access_account_id)"},{"anchor":"get_global_password_rules/0","id":"get_global_password_rules/0","title":"get_global_password_rules()"},{"anchor":"get_global_password_rules!/0","id":"get_global_password_rules!/0","title":"get_global_password_rules!()"},{"anchor":"get_owner_password_rules/1","id":"get_owner_password_rules/1","title":"get_owner_password_rules(owner_id)"},{"anchor":"get_owner_password_rules!/1","id":"get_owner_password_rules!/1","title":"get_owner_password_rules!(owner_id)"},{"anchor":"password_disallowed/1","id":"password_disallowed/1","title":"password_disallowed(password)"},{"anchor":"password_disallowed?/1","id":"password_disallowed?/1","title":"password_disallowed?(password)"},{"anchor":"test_credential/2","id":"test_credential/2","title":"test_credential(access_account_id, plaintext_pwd)"},{"anchor":"update_global_password_rules/1","id":"update_global_password_rules/1","title":"update_global_password_rules(update_params)"},{"anchor":"update_global_password_rules/2","id":"update_global_password_rules/2","title":"update_global_password_rules(global_password_rules, update_params)"},{"anchor":"update_owner_password_rules/2","id":"update_owner_password_rules/2","title":"update_owner_password_rules(owner, update_params)"},{"anchor":"verify_password_rules/2","id":"verify_password_rules/2","title":"verify_password_rules(test_rules, standard_rules \\\\ nil)"},{"anchor":"verify_password_rules!/2","id":"verify_password_rules!/2","title":"verify_password_rules!(test_rules, standard_rules \\\\ nil)"}]},{"key":"network-rules","name":"Network Rules","nodes":[{"anchor":"create_disallowed_host/1","id":"create_disallowed_host/1","title":"create_disallowed_host(host_address)"},{"anchor":"create_global_network_rule/1","id":"create_global_network_rule/1","title":"create_global_network_rule(insert_params)"},{"anchor":"create_instance_network_rule/2","id":"create_instance_network_rule/2","title":"create_instance_network_rule(instance_id, insert_params)"},{"anchor":"create_owner_network_rule/2","id":"create_owner_network_rule/2","title":"create_owner_network_rule(owner_id, insert_params)"},{"anchor":"delete_disallowed_host/1","id":"delete_disallowed_host/1","title":"delete_disallowed_host(disallowed_host)"},{"anchor":"delete_disallowed_host_addr/1","id":"delete_disallowed_host_addr/1","title":"delete_disallowed_host_addr(host_addr)"},{"anchor":"delete_global_network_rule/1","id":"delete_global_network_rule/1","title":"delete_global_network_rule(global_network_rule_id)"},{"anchor":"delete_instance_network_rule/1","id":"delete_instance_network_rule/1","title":"delete_instance_network_rule(instance_network_rule_id)"},{"anchor":"delete_owner_network_rule/1","id":"delete_owner_network_rule/1","title":"delete_owner_network_rule(owner_network_rule_id)"},{"anchor":"get_applied_network_rule/3","id":"get_applied_network_rule/3","title":"get_applied_network_rule(host_address, instance_id \\\\ nil, instance_owner_id \\\\ nil)"},{"anchor":"get_applied_network_rule!/3","id":"get_applied_network_rule!/3","title":"get_applied_network_rule!(host_address, instance_id \\\\ nil, instance_owner_id \\\\ nil)"},{"anchor":"get_disallowed_host_record_by_host/1","id":"get_disallowed_host_record_by_host/1","title":"get_disallowed_host_record_by_host(host_addr)"},{"anchor":"get_disallowed_host_record_by_host!/1","id":"get_disallowed_host_record_by_host!/1","title":"get_disallowed_host_record_by_host!(host_addr)"},{"anchor":"get_disallowed_host_record_by_id/1","id":"get_disallowed_host_record_by_id/1","title":"get_disallowed_host_record_by_id(disallowed_host_id)"},{"anchor":"get_disallowed_host_record_by_id!/1","id":"get_disallowed_host_record_by_id!/1","title":"get_disallowed_host_record_by_id!(disallowed_host_id)"},{"anchor":"get_global_network_rule/1","id":"get_global_network_rule/1","title":"get_global_network_rule(global_network_rule_id)"},{"anchor":"get_global_network_rule!/1","id":"get_global_network_rule!/1","title":"get_global_network_rule!(global_network_rule_id)"},{"anchor":"get_instance_network_rule/1","id":"get_instance_network_rule/1","title":"get_instance_network_rule(instance_network_rule_id)"},{"anchor":"get_instance_network_rule!/1","id":"get_instance_network_rule!/1","title":"get_instance_network_rule!(instance_network_rule_id)"},{"anchor":"get_owner_network_rule/1","id":"get_owner_network_rule/1","title":"get_owner_network_rule(owner_network_rule_id)"},{"anchor":"get_owner_network_rule!/1","id":"get_owner_network_rule!/1","title":"get_owner_network_rule!(owner_network_rule_id)"},{"anchor":"host_disallowed/1","id":"host_disallowed/1","title":"host_disallowed(host_address)"},{"anchor":"host_disallowed?/1","id":"host_disallowed?/1","title":"host_disallowed?(host_address)"},{"anchor":"update_global_network_rule/2","id":"update_global_network_rule/2","title":"update_global_network_rule(global_network_rule, update_params)"},{"anchor":"update_instance_network_rule/2","id":"update_instance_network_rule/2","title":"update_instance_network_rule(instance_network_rule, update_params)"},{"anchor":"update_owner_network_rule/2","id":"update_owner_network_rule/2","title":"update_owner_network_rule(owner_network_rule, update_params)"}]},{"key":"account-code","name":"Account Code","nodes":[{"anchor":"create_or_reset_account_code/2","id":"create_or_reset_account_code/2","title":"create_or_reset_account_code(access_account_id, opts \\\\ [])"},{"anchor":"get_account_code_by_access_account_id/1","id":"get_account_code_by_access_account_id/1","title":"get_account_code_by_access_account_id(access_account_id)"},{"anchor":"identify_access_account_by_code/2","id":"identify_access_account_by_code/2","title":"identify_access_account_by_code(account_code, owner_id)"},{"anchor":"revoke_account_code/1","id":"revoke_account_code/1","title":"revoke_account_code(access_account_id)"}]},{"key":"authenticator-management","name":"Authenticator Management","nodes":[{"anchor":"access_account_credential_recoverable!/1","id":"access_account_credential_recoverable!/1","title":"access_account_credential_recoverable!(access_account_id)"},{"anchor":"create_authenticator_api_token/2","id":"create_authenticator_api_token/2","title":"create_authenticator_api_token(access_account_id, opts \\\\ [])"},{"anchor":"create_authenticator_email_password/4","id":"create_authenticator_email_password/4","title":"create_authenticator_email_password(access_account_id, email_address, plaintext_pwd, opts \\\\ [])"},{"anchor":"request_identity_validation/2","id":"request_identity_validation/2","title":"request_identity_validation(target_identity, opts \\\\ [])"},{"anchor":"request_password_recovery/2","id":"request_password_recovery/2","title":"request_password_recovery(access_account_id, opts \\\\ [])"},{"anchor":"revoke_api_token/1","id":"revoke_api_token/1","title":"revoke_api_token(identity)"},{"anchor":"revoke_password_recovery/1","id":"revoke_password_recovery/1","title":"revoke_password_recovery(access_account_id)"},{"anchor":"revoke_validator_for_identity_id/1","id":"revoke_validator_for_identity_id/1","title":"revoke_validator_for_identity_id(target_identity_id)"},{"anchor":"update_api_token_external_name/2","id":"update_api_token_external_name/2","title":"update_api_token_external_name(identity, external_name)"}]},{"key":"authentication","name":"Authentication","nodes":[{"anchor":"authenticate_api_token/5","id":"authenticate_api_token/5","title":"authenticate_api_token(identifier, plaintext_token, host_addr, instance_id, opts \\\\ [])"},{"anchor":"authenticate_email_password/2","id":"authenticate_email_password/2","title":"authenticate_email_password(authentication_state, opts \\\\ [])"},{"anchor":"authenticate_email_password/4","id":"authenticate_email_password/4","title":"authenticate_email_password(email_address, plaintext_pwd, host_address, opts \\\\ [])"},{"anchor":"authenticate_recovery_token/4","id":"authenticate_recovery_token/4","title":"authenticate_recovery_token(identifier, plaintext_token, host_addr, opts \\\\ [])"},{"anchor":"authenticate_validation_token/4","id":"authenticate_validation_token/4","title":"authenticate_validation_token(identifier, plaintext_token, host_address, opts \\\\ [])"}]},{"key":"mcp-processing","name":"MCP Processing","nodes":[{"anchor":"process_operation/1","id":"process_operation/1","title":"process_operation(operation)"},{"anchor":"start_mcp_service_context/0","id":"start_mcp_service_context/0","title":"start_mcp_service_context()"},{"anchor":"stop_mcp_service_context/1","id":"stop_mcp_service_context/1","title":"stop_mcp_service_context(replacement_service_names \\\\ {nil, nil, nil})"}]}],"sections":[],"title":"MssubMcp"}],"tasks":[]}