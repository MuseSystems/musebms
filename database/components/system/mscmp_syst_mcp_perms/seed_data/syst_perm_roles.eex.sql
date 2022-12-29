-- File:        syst_perm_roles.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_mcp_perms/seed_data/syst_perm_roles.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

INSERT INTO ms_syst_data.syst_perm_roles
    ( internal_name
    , display_name
    , perm_functional_type_id
    , syst_defined
    , syst_description )
VALUES
    ( 'global_login'
    , 'Global Login'
    , ( SELECT id FROM ms_syst_data.syst_perm_functional_types WHERE internal_name = 'mcp_access_accounts' )
    , TRUE
    , 'Allows Access Accounts to log in without specifying a specific Instance.  Access ' ||
        'Account holders may log into the system and then select an Instance from the list ' ||
        'of Instances to which they have access.' )
  ,
    ( 'mcp_login'
    , 'MCP Login'
    , ( SELECT id FROM ms_syst_data.syst_perm_functional_types WHERE internal_name = 'mcp_access_accounts' )
    , TRUE
    , 'Grants an Access Account visibility and access to MCP management functionality.' );
