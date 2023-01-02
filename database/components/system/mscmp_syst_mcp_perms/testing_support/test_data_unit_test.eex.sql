-- File:        test_data_unit_test.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_mcp_perms/testing_support/test_data_unit_test.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

INSERT INTO ms_syst_data.syst_access_account_perm_role_assigns
    ( access_account_id, perm_role_id )
VALUES
    ( ( SELECT id FROM ms_syst_data.syst_access_accounts WHERE internal_name = 'unowned_all_access' )
    , ( SELECT id FROM ms_syst_data.syst_perm_roles WHERE internal_name = 'mcp_login' ) )
  ,
    ( ( SELECT id FROM ms_syst_data.syst_access_accounts WHERE internal_name = 'unowned_all_access' )
    , ( SELECT id FROM ms_syst_data.syst_perm_roles WHERE internal_name = 'global_login' ) )
  ,
    ( ( SELECT id FROM ms_syst_data.syst_access_accounts WHERE internal_name = 'owned_all_access' )
    , ( SELECT id FROM ms_syst_data.syst_perm_roles WHERE internal_name = 'mcp_login' ) );
