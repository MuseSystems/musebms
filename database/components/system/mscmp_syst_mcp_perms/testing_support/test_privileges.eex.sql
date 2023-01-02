-- File:        test_privileges.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_mcp_perms/testing_support/test_privileges.eex.sql
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
-- MscmpSystMcpPerms
--

GRANT USAGE ON SCHEMA ms_syst TO <%= ms_appusr %>;

-- syst_access_account_perm_role_assigns

GRANT SELECT, INSERT, DELETE ON TABLE ms_syst.syst_access_account_perm_role_assigns TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_access_account_perm_role_assigns() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_access_account_perm_role_assigns() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_access_account_perm_role_assigns() TO <%= ms_appusr %>;