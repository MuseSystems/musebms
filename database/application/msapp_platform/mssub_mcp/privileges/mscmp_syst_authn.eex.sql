-- File:        mscmp_syst_authn.eex.sql
-- Location:    musebms/database/application/msapp_platform/mssub_mcp/privileges/mscmp_syst_authn.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

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

-- Functions

GRANT EXECUTE
  ON FUNCTION ms_syst.get_applied_network_rule( p_host_addr         inet
                                              , p_instance_id       uuid
                                              , p_instance_owner_id uuid )
  TO <%= ms_appusr %>;
