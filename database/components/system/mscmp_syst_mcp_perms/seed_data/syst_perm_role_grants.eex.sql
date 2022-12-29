-- File:        syst_perm_role_grants.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_mcp_perms/seed_data/syst_perm_role_grants.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

INSERT INTO ms_syst_data.syst_perm_role_grants
    ( perm_role_id
    , perm_id
    , view_scope
    , maint_scope
    , admin_scope
    , ops_scope )
VALUES
    ( ( SELECT id FROM ms_syst_data.syst_perm_roles WHERE internal_name = 'global_login' )
    , ( SELECT id FROM ms_syst_data.syst_perms WHERE internal_name = 'global_login' )
    , 'unused'
    , 'unused'
    , 'unused'
    , 'all' )
  ,
    ( ( SELECT id FROM ms_syst_data.syst_perm_roles WHERE internal_name = 'mcp_login' )
    , ( SELECT id FROM ms_syst_data.syst_perms WHERE internal_name = 'mcp_login' )
    , 'unused'
    , 'unused'
    , 'unused'
    , 'all' );
