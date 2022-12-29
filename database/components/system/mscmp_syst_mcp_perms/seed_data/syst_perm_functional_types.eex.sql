-- File:        syst_perm_functional_types.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_mcp_perms/seed_data/syst_perm_functional_types.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

INSERT INTO ms_syst_data.syst_perm_functional_types
    ( internal_name, display_name, syst_description )
VALUES
    ( 'mcp_access_accounts'
    , 'MCP Access Accounts'
    , 'Permissioning for MCP functionality which may be granted to MCP ' ||
      'Access Accounts.' );
