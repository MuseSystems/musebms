-- File:        test_privileges.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/testing_support/test_privileges.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

GRANT USAGE ON SCHEMA ms_syst TO <%= ms_appusr %>;

--
-- MscmpSystAuthn
--

-- syst_access_accounts

GRANT SELECT, INSERT, UPDATE, DELETE
    ON TABLE ms_syst.syst_access_accounts TO <%= ms_appusr %>;

GRANT SELECT, INSERT, UPDATE, DELETE
    ON TABLE ms_syst.syst_access_account_instance_assocs TO <%= ms_appusr %>;

GRANT SELECT, INSERT, UPDATE, DELETE
    ON TABLE ms_syst.syst_identities TO <%= ms_appusr %>;

GRANT SELECT, INSERT, UPDATE, DELETE
    ON TABLE ms_syst.syst_credentials TO <%= ms_appusr %>;

GRANT SELECT, INSERT, DELETE
    ON TABLE ms_syst.syst_password_history TO <%= ms_appusr %>;

GRANT SELECT, INSERT, DELETE
    ON TABLE ms_syst.syst_disallowed_hosts TO <%= ms_appusr %>;

GRANT SELECT, INSERT, UPDATE, DELETE
    ON TABLE ms_syst.syst_global_network_rules TO <%= ms_appusr %>;

GRANT SELECT, INSERT, UPDATE, DELETE
    ON TABLE ms_syst.syst_owner_network_rules TO <%= ms_appusr %>;

GRANT SELECT, INSERT, UPDATE, DELETE
    ON TABLE ms_syst.syst_instance_network_rules TO <%= ms_appusr %>;

GRANT SELECT, UPDATE
    ON TABLE ms_syst.syst_global_password_rules TO <%= ms_appusr %>;

GRANT SELECT, INSERT, UPDATE, DELETE
    ON TABLE ms_syst.syst_owner_password_rules TO <%= ms_appusr %>;

GRANT SELECT, INSERT, UPDATE, DELETE
    ON TABLE ms_syst.syst_disallowed_passwords TO <%= ms_appusr %>;

GRANT EXECUTE
    ON FUNCTION ms_syst.get_applied_network_rule( inet , uuid , uuid )
    TO <%= ms_appusr %>;
