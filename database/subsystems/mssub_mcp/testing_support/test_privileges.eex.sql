-- File:        test_privileges.eex.sql
-- Location:    musebms/database/subsystems/mssub_mcp/testing_support/test_privileges.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

GRANT USAGE ON SCHEMA ms_syst TO <%= ms_appusr %>;

--
-- MscmpSystSettings
--

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE ms_syst.syst_settings TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_settings() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_settings() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_settings() TO <%= ms_appusr %>;

--
-- MscmpSystEnums
--

-- syst_enums

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE ms_syst.syst_enums TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_enums() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_enums() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_enums() TO <%= ms_appusr %>;

-- syst_enum_functional_types

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE ms_syst.syst_enum_functional_types TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_enum_functional_types() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_enum_functional_types() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_enum_functional_types() TO <%= ms_appusr %>;

-- syst_enum_items

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE ms_syst.syst_enum_items TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_enum_items() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_enum_items() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_enum_items() TO <%= ms_appusr %>;

--
-- MscmpSystInstance
--

-- syst_applications

GRANT SELECT, INSERT, UPDATE ON TABLE ms_syst.syst_applications TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_applications() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_applications() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_applications() TO <%= ms_appusr %>;

-- syst_application_contexts

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE ms_syst.syst_application_contexts TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_application_contexts() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_application_contexts() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_application_contexts() TO <%= ms_appusr %>;

-- syst_owners

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE ms_syst.syst_owners TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_owners() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_owners() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_owners() TO <%= ms_appusr %>;

-- syst_instance_type_applications

GRANT SELECT, INSERT, DELETE ON TABLE ms_syst.syst_instance_type_applications TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_instance_type_applications() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_instance_type_applications() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_instance_type_applications() TO <%= ms_appusr %>;

-- syst_instance_type_contexts

GRANT SELECT, UPDATE ON TABLE ms_syst.syst_instance_type_contexts TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_instance_type_contexts() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_instance_type_contexts() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_instance_type_contexts() TO <%= ms_appusr %>;

-- syst_instances

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE ms_syst.syst_instances TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_instances() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_instances() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_instances() TO <%= ms_appusr %>;

-- syst_instance_contexts

GRANT SELECT, UPDATE ON TABLE ms_syst.syst_instance_contexts TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_instance_contexts() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_instance_contexts() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_instance_contexts() TO <%= ms_appusr %>;

--
-- MscmpSystAuthn
--

-- syst_access_accounts

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE ms_syst.syst_access_accounts TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_access_accounts TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_access_accounts TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_access_accounts TO <%= ms_appusr %>;

-- syst_access_account_instance_assocs

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE ms_syst.syst_access_account_instance_assocs TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_access_account_instance_assocs TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_access_account_instance_assocs TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_access_account_instance_assocs TO <%= ms_appusr %>;

-- syst_identities

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE ms_syst.syst_identities TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_identities TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_identities TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_identities TO <%= ms_appusr %>;

-- syst_credentials

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE ms_syst.syst_credentials TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_credentials TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_credentials TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_credentials TO <%= ms_appusr %>;

-- syst_global_network_rules

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE ms_syst.syst_global_network_rules TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_global_network_rules TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_global_network_rules TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_global_network_rules TO <%= ms_appusr %>;

-- syst_owner_network_rules

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE ms_syst.syst_owner_network_rules TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_owner_network_rules TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_owner_network_rules TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_owner_network_rules TO <%= ms_appusr %>;

-- syst_instance_network_rules

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE ms_syst.syst_instance_network_rules TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_instance_network_rules TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_instance_network_rules TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_instance_network_rules TO <%= ms_appusr %>;

-- syst_disallowed_hosts

GRANT SELECT, INSERT, DELETE ON TABLE ms_syst.syst_disallowed_hosts TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_disallowed_hosts TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_disallowed_hosts TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_disallowed_hosts TO <%= ms_appusr %>;

-- syst_global_password_rules

GRANT SELECT, UPDATE ON TABLE ms_syst.syst_global_password_rules TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_global_password_rules TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_global_password_rules TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_global_password_rules TO <%= ms_appusr %>;

-- syst_owner_password_rules

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE ms_syst.syst_owner_password_rules TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_owner_password_rules TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_owner_password_rules TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_owner_password_rules TO <%= ms_appusr %>;

-- syst_disallowed_passwords

GRANT SELECT, INSERT, DELETE ON TABLE ms_syst.syst_disallowed_passwords TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_disallowed_passwords TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_disallowed_passwords TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_disallowed_passwords TO <%= ms_appusr %>;

-- syst_password_history

GRANT SELECT, INSERT, DELETE ON TABLE ms_syst.syst_password_history TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_password_history TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_password_history TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_password_history TO <%= ms_appusr %>;

--
-- MscmpSystPerms
--

-- syst_perm_functional_types

GRANT SELECT, UPDATE ON TABLE ms_syst.syst_perm_functional_types TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_perm_functional_types() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_perm_functional_types() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_perm_functional_types() TO <%= ms_appusr %>;

-- syst_perms

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE ms_syst.syst_perms TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_perms() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_perms() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_perms() TO <%= ms_appusr %>;

-- syst_perm_roles

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE ms_syst.syst_perm_roles TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_perm_roles() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_perm_roles() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_perm_roles() TO <%= ms_appusr %>;

-- syst_perm_role_grants

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE ms_syst.syst_perm_role_grants TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_perm_role_grants() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_perm_role_grants() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_perm_role_grants() TO <%= ms_appusr %>;

-- API Functions

GRANT EXECUTE ON FUNCTION ms_syst.get_greatest_rights_scope(text[]) TO <%= ms_appusr %>;

--
-- MscmpSystMcpPerms
--

-- syst_access_account_perm_role_assigns

GRANT SELECT, INSERT, DELETE ON TABLE ms_syst.syst_access_account_perm_role_assigns TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_access_account_perm_role_assigns() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_access_account_perm_role_assigns() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_access_account_perm_role_assigns() TO <%= ms_appusr %>;

--
-- MscmpSystSession
--

-- syst_sessions

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE ms_syst.syst_sessions TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_sessions() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_sessions() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_sessions() TO <%= ms_appusr %>;

-- API Functions

GRANT EXECUTE
  ON FUNCTION ms_syst.get_applied_network_rule( p_host_addr         inet
                                              , p_instance_id       uuid
                                              , p_instance_owner_id uuid )
  TO <%= ms_appusr %>;
