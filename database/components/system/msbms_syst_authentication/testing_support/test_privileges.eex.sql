-- File:        test_privileges.eex.sql
-- Location:    musebms/database/components/system/msbms_syst_authentication/testing_support/test_privileges.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

GRANT USAGE ON SCHEMA msbms_syst TO <%= msbms_appusr %>;

--
-- MsbmsSystAuthentication
--

-- syst_access_accounts

GRANT SELECT, INSERT, UPDATE, DELETE
    ON TABLE msbms_syst.syst_access_accounts TO <%= msbms_appusr %>;

GRANT SELECT, INSERT, UPDATE, DELETE
    ON TABLE msbms_syst.syst_access_account_instance_assocs TO <%= msbms_appusr %>;

GRANT SELECT, INSERT, UPDATE, DELETE
    ON TABLE msbms_syst.syst_identities TO <%= msbms_appusr %>;

GRANT SELECT, INSERT, UPDATE, DELETE
    ON TABLE msbms_syst.syst_credentials TO <%= msbms_appusr %>;

GRANT SELECT, INSERT, DELETE
    ON TABLE msbms_syst.syst_password_history TO <%= msbms_appusr %>;

GRANT SELECT, INSERT, DELETE
    ON TABLE msbms_syst.syst_disallowed_hosts TO <%= msbms_appusr %>;

GRANT SELECT, INSERT, UPDATE, DELETE
    ON TABLE msbms_syst.syst_global_network_rules TO <%= msbms_appusr %>;

GRANT SELECT, INSERT, UPDATE, DELETE
    ON TABLE msbms_syst.syst_owner_network_rules TO <%= msbms_appusr %>;

GRANT SELECT, INSERT, UPDATE, DELETE
    ON TABLE msbms_syst.syst_instance_network_rules TO <%= msbms_appusr %>;

GRANT SELECT, UPDATE
    ON TABLE msbms_syst.syst_global_password_rules TO <%= msbms_appusr %>;

GRANT SELECT, INSERT, UPDATE, DELETE
    ON TABLE msbms_syst.syst_owner_password_rules TO <%= msbms_appusr %>;

GRANT SELECT, INSERT, UPDATE, DELETE
    ON TABLE msbms_syst.syst_disallowed_passwords TO <%= msbms_appusr %>;

GRANT EXECUTE
    ON FUNCTION msbms_syst.get_applied_network_rule( inet , uuid , uuid )
    TO <%= msbms_appusr %>;
