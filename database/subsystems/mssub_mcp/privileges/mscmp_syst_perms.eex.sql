-- File:        mscmp_syst_perms.eex.sql
-- Location:    musebms/database/platform/msapp_platform/mssub_mcp/privileges/mscmp_syst_perms.eex.sql
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
