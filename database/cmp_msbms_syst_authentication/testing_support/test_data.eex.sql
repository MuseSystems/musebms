-- File:        test_data.eex.sql
-- Location:    musebms/database/cmp_msbms_syst_authentication/testing_support/test_data.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

DO
$AUTHENTICATION_TESTING_INIT$
    BEGIN

        ------------------------------------------------------------------------
        -- Generalized / Independent Lists
        ------------------------------------------------------------------------

        INSERT INTO msbms_syst_data.syst_disallowed_passwords
            ( password_hash )
        VALUES
            ( digest( 'password', 'sha1' ) )
             ,
            ( digest( '12345678', 'sha1' ) )
             ,
            ( digest( '123456789', 'sha1' ) )
             ,
            ( digest( 'baseball', 'sha1' ) )
             ,
            ( digest( 'football', 'sha1' ) )
             ,
            ( digest( 'qwertyuiop', 'sha1' ) )
             ,
            ( digest( '1234567890', 'sha1' ) )
             ,
            ( digest( 'superman', 'sha1' ) )
             ,
            ( digest( '1qaz2wsx', 'sha1' ) )
             ,
            ( digest( 'trustno1', 'sha1' ) );

        INSERT INTO msbms_syst_data.syst_banned_hosts
            ( host_address )
        VALUES
            ( '10.123.123.1'::inet )
             ,
            ( '10.123.123.2'::inet )
             ,
            ( '10.123.123.3'::inet )
             ,
            ( '10.123.123.4'::inet )
             ,
            ( '10.123.123.5'::inet );

        ------------------------------------------------------------------------
        -- All Access / Example User Test Data
        ------------------------------------------------------------------------

        INSERT INTO msbms_syst_data.syst_access_accounts
            ( internal_name
            , external_name
            , owning_owner_id
            , allow_global_logins
            , access_account_state_id )
        VALUES
            ( 'unowned_all_access',
              'Unowned / All Access',
              NULL,
              TRUE,
              ( SELECT
                    id
                FROM msbms_syst_data.syst_enum_items
                WHERE internal_name = 'access_account_states_sysdef_active' ) )
             ,
            ( 'owned_all_access'
            , 'Owned / All Access'
            , ( SELECT id
                FROM msbms_syst_data.syst_owners
                WHERE internal_name = 'owner1' )
            , FALSE
            , ( SELECT
                    id
                FROM msbms_syst_data.syst_enum_items
                WHERE internal_name = 'access_account_states_sysdef_active' ) )
             ,
            ( 'example_accnt'
            , 'Example Account'
            , ( SELECT id
                FROM msbms_syst_data.syst_owners
                WHERE internal_name = 'owner1' )
            , FALSE
            , ( SELECT
                    id
                FROM msbms_syst_data.syst_enum_items
                WHERE internal_name = 'access_account_states_sysdef_active' ) );

        -- Owned accounts and unowned accounts have slightly different
        -- restrictions on which instances they can be associated with.

        INSERT INTO msbms_syst_data.syst_access_account_instance_assocs
            ( access_account_id
            , credential_type_id
            , instance_id
            , access_granted
            , invitation_issued
            , invitation_expires
            , invitation_declined )
        SELECT
            aa.id
          , ctei.id
          , i.id
          , now( ) - INTERVAL '20 days'
          , now( ) - INTERVAL '40 days'
          , now( ) - INTERVAL '10 days'
          , NULL::timestamptz
        FROM msbms_syst_data.syst_enums cte
                 JOIN msbms_syst_data.syst_enum_items ctei ON ctei.enum_id = cte.id
           , msbms_syst_data.syst_access_accounts aa
           , msbms_syst_data.syst_instances i
        WHERE cte.internal_name = 'credential_types' AND aa.internal_name = 'unowned_all_access';

        INSERT INTO msbms_syst_data.syst_access_account_instance_assocs
            ( access_account_id
            , credential_type_id
            , instance_id
            , access_granted
            , invitation_issued
            , invitation_expires
            , invitation_declined )
        SELECT
            aa.id
          , ctei.id
          , i.id
          , now( ) - INTERVAL '20 days'
          , now( ) - INTERVAL '40 days'
          , now( ) - INTERVAL '10 days'
          , NULL::timestamptz
        FROM msbms_syst_data.syst_enums cte
                 JOIN msbms_syst_data.syst_enum_items ctei ON ctei.enum_id = cte.id
           , msbms_syst_data.syst_access_accounts aa
                 JOIN msbms_syst_data.syst_owners o ON o.id = aa.owning_owner_id
                 JOIN msbms_syst_data.syst_instances i ON i.owner_id = o.id
        WHERE
              cte.internal_name = 'credential_types'
          AND aa.internal_name IN ( 'unowned_all_access', 'example_accnt' );

        INSERT INTO msbms_syst_data.syst_identities
            ( access_account_id
            , identity_type_id
            , account_identifier
            , validated
            , validation_requested
            , validation_expires
            , primary_contact )
        SELECT
            aa.id
          , ( SELECT id
              FROM msbms_syst_data.syst_enum_items
              WHERE internal_name = 'identity_types_sysdef_email' )
          , aa.internal_name || '@musesystems.com' -- TODO: Change this to something more testable!
          , now( ) - interval '15 days'
          , now( ) - interval '20 days'
          , now( ) - interval '10 days'
          , TRUE
        FROM msbms_syst_data.syst_access_accounts aa;

        INSERT INTO msbms_syst_data.syst_identities
            ( access_account_id
            , identity_type_id
            , account_identifier
            , validated
            , validation_requested
            , validation_expires
            , primary_contact )
        SELECT
            aa.id
          , ( SELECT id
              FROM msbms_syst_data.syst_enum_items
              WHERE internal_name = 'identity_types_sysdef_account' )
          , msbms_syst_priv.get_random_string(9)
          , now( ) - INTERVAL '15 days'
          , now( ) - INTERVAL '20 days'
          , now( ) - INTERVAL '10 days'
          , TRUE
        FROM msbms_syst_data.syst_access_accounts aa;



    END;
$AUTHENTICATION_TESTING_INIT$;
