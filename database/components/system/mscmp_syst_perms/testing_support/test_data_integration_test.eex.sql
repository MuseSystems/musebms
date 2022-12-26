-- File:        test_data_integration_test.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_perms/testing_support/test_data_integration_test.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

DO
$PERMS_INTEGRATION_TEST_INIT$
DECLARE
    var_data jsonb;

BEGIN

    /**********************************************************************
     **
     **  Test Data Description
     **
     **********************************************************************/
    var_data := $TEST_DATA$
    {
      "perm_functional_types": [
        {
          "internal_name": "func_type_1",
          "display_name": "Functional Type 1",
          "syst_description": "Functional type for system defined permissions testing.",
          "user_description": null
        },
        {
          "internal_name": "func_type_2",
          "display_name": "Functional Type 2",
          "syst_description": "Functional type for user defined permissions testing.",
          "user_description": null
        }
      ],
      "perms": [
        {
          "internal_name": "perm_1",
          "display_name": "Perm 1",
          "perm_functional_type_name": "func_type_1",
          "syst_defined": true,
          "syst_description": "System Defined Permission 1",
          "user_description": null,
          "view_scope_options": [
            "unused"
          ],
          "maint_scope_options": [
            "unused"
          ],
          "admin_scope_options": [
            "unused"
          ],
          "ops_scope_options": [
            "deny",
            "same_user"
          ]
        },
        {
          "internal_name": "perm_2",
          "display_name": "Perm 2",
          "perm_functional_type_name": "func_type_1",
          "syst_defined": true,
          "syst_description": "System Defined Permission 2",
          "user_description": null,
          "view_scope_options": [
            "deny",
            "same_user",
            "same_group",
            "all"
          ],
          "maint_scope_options": [
            "deny",
            "same_user",
            "same_group",
            "all"
          ],
          "admin_scope_options": [
            "deny",
            "same_user",
            "same_group",
            "all"
          ],
          "ops_scope_options": [
            "unused"
          ]
        }
      ],
      "perm_roles": [
        {
          "internal_name": "perm_role_1",
          "display_name": "Perm Role 1",
          "perm_functional_type_name": "func_type_1",
          "syst_defined": true,
          "syst_description": "Permission Role 1 Syst Defined",
          "user_description": null
        },
        {
          "internal_name": "perm_role_2",
          "display_name": "Perm Role 2",
          "perm_functional_type_name": "func_type_1",
          "syst_defined": true,
          "syst_description": "Permission Role 2 Syst Defined",
          "user_description": null
        }
      ],
      "perm_role_grants": [
        {
          "perm_role_name": "perm_role_1",
          "perm_name": "perm_1",
          "view_scope": "unused",
          "maint_scope": "unused",
          "admin_scope": "unused",
          "ops_scope": "same_user"
        },
        {
          "perm_role_name": "perm_role_1",
          "perm_name": "perm_2",
          "view_scope": "all",
          "maint_scope": "deny",
          "admin_scope": "deny",
          "ops_scope": "unused"
        },
        {
          "perm_role_name": "perm_role_2",
          "perm_name": "perm_2",
          "view_scope": "all",
          "maint_scope": "deny",
          "admin_scope": "deny",
          "ops_scope": "unused"
        }
      ]
    }
    $TEST_DATA$;

    /**********************************************************************
     **
     **  Test Data Creation
     **
     **********************************************************************/

    ----------------------------------------------------
    -- Perm Functional Types
    ----------------------------------------------------

    INSERT INTO ms_syst_data.syst_perm_functional_types
        ( internal_name
        , display_name
        , syst_description
        , user_description )
    SELECT
        perm_func_type ->> 'internal_name'
      , perm_func_type ->> 'display_name'
      , perm_func_type ->> 'syst_description'
      , perm_func_type ->> 'user_description'
    FROM jsonb_array_elements( var_data -> 'perm_functional_types' ) perm_func_type;

    ----------------------------------------------------
    -- Perms
    ----------------------------------------------------

    INSERT INTO ms_syst_data.syst_perms
        ( internal_name, display_name, perm_functional_type_id, syst_defined, syst_description, user_description
        , view_scope_options
        , maint_scope_options, admin_scope_options, ops_scope_options )
    SELECT
        perm ->> 'internal_name'
      , perm ->> 'display_name'
      , ( SELECT id
          FROM ms_syst_data.syst_perm_functional_types
          WHERE internal_name = (perm ->> 'perm_functional_type_name') )
      , (perm ->> 'syst_defined')::boolean
      , perm ->> 'syst_description'
      , perm ->> 'user_description'
      , array( SELECT jsonb_array_elements_text( perm -> 'view_scope_options' ) )
      , array( SELECT jsonb_array_elements_text( perm -> 'maint_scope_options' ) )
      , array( SELECT jsonb_array_elements_text( perm -> 'admin_scope_options' ) )
      , array( SELECT jsonb_array_elements_text( perm -> 'ops_scope_options' ) )
    FROM jsonb_array_elements( var_data -> 'perms' ) perm;

    ----------------------------------------------------
    -- Perms Roles
    ----------------------------------------------------

    INSERT INTO ms_syst_data.syst_perm_roles
        ( internal_name
        , display_name
        , perm_functional_type_id
        , syst_defined
        , syst_description
        , user_description )
    SELECT
        perm_role ->> 'internal_name'
      , perm_role ->> 'display_name'
      , ( SELECT id
          FROM ms_syst_data.syst_perm_functional_types
          WHERE internal_name = (perm_role ->> 'perm_functional_type_name') )
      , (perm_role ->> 'syst_defined')::boolean
      , perm_role ->> 'syst_description'
      , perm_role ->> 'user_description'
    FROM jsonb_array_elements( var_data -> 'perm_roles' ) perm_role;

    ----------------------------------------------------
    -- Perms Role Grants
    ----------------------------------------------------

    INSERT INTO ms_syst_data.syst_perm_role_grants
        ( perm_role_id
        , perm_id
        , view_scope
        , maint_scope
        , admin_scope
        , ops_scope )
    SELECT
        ( SELECT id FROM ms_syst_data.syst_perm_roles WHERE internal_name = perm_role_grant ->> 'perm_role_name' )
      , ( SELECT id FROM ms_syst_data.syst_perms WHERE internal_name = perm_role_grant ->> 'perm_name' )
      , perm_role_grant ->> 'view_scope'
      , perm_role_grant ->> 'maint_scope'
      , perm_role_grant ->> 'admin_scope'
      , perm_role_grant ->> 'ops_scope'
    FROM jsonb_array_elements( var_data -> 'perm_role_grants' ) perm_role_grant;

END;
$PERMS_INTEGRATION_TEST_INIT$;
