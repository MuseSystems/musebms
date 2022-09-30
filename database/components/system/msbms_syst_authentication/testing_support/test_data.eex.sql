-- File:        test_data.eex.sql
-- Location:    musebms/database/components/system/msbms_syst_authentication/testing_support/test_data.eex.sql
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

        INSERT INTO msbms_syst_data.syst_disallowed_hosts
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
        -- Password Rules
        ------------------------------------------------------------------------

        INSERT INTO msbms_syst_data.syst_owner_password_rules
            ( owner_id
            , password_length
            , max_age
            , require_upper_case
            , require_lower_case
            , require_numbers
            , require_symbols
            , disallow_recently_used
            , disallow_compromised
            , require_mfa
            , allowed_mfa_types )
        VALUES
            ( (SELECT id FROM msbms_syst_data.syst_owners WHERE internal_name = 'owner1')
            , int4range( 6, 1024, '[]' )
            , interval '0 days'
            , 0
            , 0
            , 0
            , 0
            , 0
            , FALSE
            , FALSE
            , ARRAY['credential_types_secondary_totp']::text[] );

        INSERT INTO msbms_syst_data.syst_owner_password_rules
            ( owner_id
            , password_length
            , max_age
            , require_upper_case
            , require_lower_case
            , require_numbers
            , require_symbols
            , disallow_recently_used
            , disallow_compromised
            , require_mfa
            , allowed_mfa_types )
        VALUES
            ( (SELECT id FROM msbms_syst_data.syst_owners WHERE internal_name = 'owner2')
            , int4range( 12, 64, '[]' )
            , interval '10 days'
            , 2
            , 2
            , 2
            , 2
            , 2
            , FALSE
            , TRUE
            , ARRAY['credential_types_secondary_totp']::text[] );

        INSERT INTO msbms_syst_data.syst_owner_password_rules
            ( owner_id
            , password_length
            , max_age
            , require_upper_case
            , require_lower_case
            , require_numbers
            , require_symbols
            , disallow_recently_used
            , disallow_compromised
            , require_mfa
            , allowed_mfa_types )
        VALUES
            ( (SELECT id FROM msbms_syst_data.syst_owners WHERE internal_name = 'owner3')
            , int4range( 8, 512, '[]' )
            , interval '0 days'
            , 0
            , 0
            , 0
            , 0
            , 0
            , TRUE
            , FALSE
            , ARRAY['credential_types_secondary_totp']::text[] );

        INSERT INTO msbms_syst_data.syst_owner_password_rules
            ( owner_id
            , password_length
            , max_age
            , require_upper_case
            , require_lower_case
            , require_numbers
            , require_symbols
            , disallow_recently_used
            , disallow_compromised
            , require_mfa
            , allowed_mfa_types )
        VALUES
            ( (SELECT id FROM msbms_syst_data.syst_owners WHERE internal_name = 'owner4')
            , int4range( 8, 512, '[]' )
            , interval '0 days'
            , 0
            , 0
            , 0
            , 0
            , 0
            , TRUE
            , FALSE
            , ARRAY['credential_types_secondary_totp']::text[] );

        ------------------------------------------------------------------------
        -- Network Rule Creation
        ------------------------------------------------------------------------

        INSERT INTO msbms_syst_data.syst_global_network_rules
        (
          template_rule
        , ordering
        , functional_type
        , ip_host_or_network
        , ip_host_range_lower
        , ip_host_range_upper
        )
        VALUES
        (
          TRUE,
          1,
          'deny',
          '10.124.124.1',
          NULL,
          NULL
        ),
        (
          TRUE,
          2,
          'allow',
          '10.124.124.0/24',
          NULL,
          NULL
        ),
        (
          TRUE,
          3,
          'allow',
          NULL,
          '10.123.123.1',
          '10.123.123.254'
        ),
        (
          FALSE,
          1,
          'deny',
          '10.124.124.2',
          NULL,
          NULL
        ),
        (
          FALSE,
          2,
          'allow',
          '10.125.125.0/24',
          NULL,
          NULL
        ),
        (
          FALSE,
          3,
          'allow',
          NULL,
          '10.123.123.5',
          '10.123.123.254'
        );

        INSERT INTO msbms_syst_data.syst_owner_network_rules
        (
          owner_id
        , ordering
        , functional_type
        , ip_host_or_network
        , ip_host_range_lower
        , ip_host_range_upper
        )
        VALUES
        (
          (SELECT id FROM msbms_syst_data.syst_owners WHERE internal_name = 'owner1'),
          1,
          'deny',
          '10.124.124.1',
          NULL,
          NULL
        ),
        (
          (SELECT id FROM msbms_syst_data.syst_owners WHERE internal_name = 'owner1'),
          2,
          'allow',
          '10.124.124.0/24',
          NULL,
          NULL
        ),
        (
          (SELECT id FROM msbms_syst_data.syst_owners WHERE internal_name = 'owner1'),
          3,
          'allow',
          NULL,
          '10.123.123.1',
          '10.123.123.254'
        );

        INSERT INTO msbms_syst_data.syst_instance_network_rules
        (
          instance_id
        , ordering
        , functional_type
        , ip_host_or_network
        , ip_host_range_lower
        , ip_host_range_upper
        )
        SELECT
            i.id
            ,1
            ,'allow'
            ,'10.126.126.1'
            ,NULL
            ,NULL
        FROM msbms_syst_data.syst_instances i;

        INSERT INTO msbms_syst_data.syst_instance_network_rules
        (
          instance_id
        , ordering
        , functional_type
        , ip_host_or_network
        , ip_host_range_lower
        , ip_host_range_upper
        )
        SELECT
            i.id
            ,2
            ,'deny'
            ,'10.126.126.2'
            ,NULL
            ,NULL
        FROM msbms_syst_data.syst_instances i;

        INSERT INTO msbms_syst_data.syst_instance_network_rules
        (
          instance_id
        , ordering
        , functional_type
        , ip_host_or_network
        , ip_host_range_lower
        , ip_host_range_upper
        )
        SELECT
            i.id
            ,3
            ,'allow'
            ,'10.126.126.0/24'
            ,NULL
            ,NULL
        FROM msbms_syst_data.syst_instances i;

        INSERT INTO msbms_syst_data.syst_instance_network_rules
        (
          instance_id
        , ordering
        , functional_type
        , ip_host_or_network
        , ip_host_range_lower
        , ip_host_range_upper
        )
        SELECT
            i.id
            ,4
            ,'deny'
            ,NULL
            ,'10.127.127.1'
            ,'10.128.128.254'
        FROM msbms_syst_data.syst_instances i;


        ------------------------------------------------------------------------
        -- Access Account Creation
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
            ( 'update_test_accnt'
            , 'Access Account Update Test Account'
            , ( SELECT id
                FROM msbms_syst_data.syst_owners
                WHERE internal_name = 'owner1' )
            , FALSE
            , ( SELECT
                    id
                FROM msbms_syst_data.syst_enum_items
                WHERE internal_name = 'access_account_states_sysdef_active' ) )
             ,
            ( 'bad_update_test_accnt'
            , 'Bad Access Account Update Test Account'
            , ( SELECT id
                FROM msbms_syst_data.syst_owners
                WHERE internal_name = 'owner1' )
            , FALSE
            , ( SELECT
                    id
                FROM msbms_syst_data.syst_enum_items
                WHERE internal_name = 'access_account_states_sysdef_active' ) )
             ,
            ( 'purge_test_accnt'
            , 'Purge Access Account Test Account'
            , ( SELECT id
                FROM msbms_syst_data.syst_owners
                WHERE internal_name = 'owner1' )
            , FALSE
            , ( SELECT
                    id
                FROM msbms_syst_data.syst_enum_items
                WHERE internal_name = 'access_account_states_sysdef_purge_eligible' ) )
             ,
            ( 'invite_to_instance_test_accnt'
            , 'Invite Access Account/Instance Test Account'
            , ( SELECT id
                FROM msbms_syst_data.syst_owners
                WHERE internal_name = 'owner1' )
            , FALSE
            , ( SELECT
                    id
                FROM msbms_syst_data.syst_enum_items
                WHERE internal_name = 'access_account_states_sysdef_active' ) )
             ,
            ( 'decline_account_to_instance_test_accnt'
            , 'Decline Access Account/Instance Invite Test Account'
            , NULL
            , TRUE
            , ( SELECT
                    id
                FROM msbms_syst_data.syst_enum_items
                WHERE internal_name = 'access_account_states_sysdef_active' ) )
             ,
            ( 'accept_account_to_instance_test_accnt'
            , 'Accept Access Account/Instance Invite Test Account'
            , NULL
            , TRUE
            , ( SELECT
                    id
                FROM msbms_syst_data.syst_enum_items
                WHERE internal_name = 'access_account_states_sysdef_active' ) )
             ,
            ( 'revoke_account_to_instance_test_accnt'
            , 'Revoke Access Account/Instance Invite Test Account'
            , NULL
            , TRUE
            , ( SELECT
                    id
                FROM msbms_syst_data.syst_enum_items
                WHERE internal_name = 'access_account_states_sysdef_active' ) )
             ,
            ( 'example_purge_accnt'
            , 'Example Purge Account'
            , ( SELECT id
                FROM msbms_syst_data.syst_owners
                WHERE internal_name = 'owner1' )
            , FALSE
            , ( SELECT
                    id
                FROM msbms_syst_data.syst_enum_items
                WHERE internal_name = 'access_account_states_sysdef_purge_eligible' ) )
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
            , instance_id
            , access_granted
            , invitation_issued
            , invitation_expires
            , invitation_declined )
        SELECT
            aa.id
          , i.id
          , now( ) - INTERVAL '20 days'
          , now( ) - INTERVAL '40 days'
          , now( ) - INTERVAL '10 days'
          , NULL::timestamptz
        FROM msbms_syst_data.syst_access_accounts aa
           , msbms_syst_data.syst_instances i
        WHERE aa.internal_name = 'unowned_all_access';

        INSERT INTO msbms_syst_data.syst_access_account_instance_assocs
            ( access_account_id
            , instance_id
            , access_granted
            , invitation_issued
            , invitation_expires
            , invitation_declined )
        SELECT
            aa.id
          , i.id
          , now( ) - INTERVAL '20 days'
          , now( ) - INTERVAL '40 days'
          , now( ) - INTERVAL '10 days'
          , NULL::timestamptz
        FROM msbms_syst_data.syst_access_accounts aa
            JOIN msbms_syst_data.syst_owners o ON o.id = aa.owning_owner_id
            JOIN msbms_syst_data.syst_instances i ON i.owner_id = o.id
        WHERE aa.internal_name IN ( 'owned_all_access', 'example_accnt' );

        -- Specialized inserts to facilitate testing
        INSERT INTO msbms_syst_data.syst_access_account_instance_assocs
            ( access_account_id
            , instance_id
            , invitation_issued
            , invitation_expires )
        VALUES
            ( ( SELECT
                    id
                FROM msbms_syst_data.syst_access_accounts
                WHERE internal_name = 'decline_account_to_instance_test_accnt' )
            , ( SELECT
                    id
                FROM msbms_syst_data.syst_instances i
                WHERE internal_name = 'app1_owner1_instance_types_std' )
            , now( ) - INTERVAL '10 days'
            , now( ) + INTERVAL '20 days' )
             ,
            ( ( SELECT
                    id
                FROM msbms_syst_data.syst_access_accounts
                WHERE internal_name = 'accept_account_to_instance_test_accnt' )
            , ( SELECT
                    id
                FROM msbms_syst_data.syst_instances i
                WHERE internal_name = 'app1_owner1_instance_types_std' )
            , now( ) - INTERVAL '10 days'
            , now( ) + INTERVAL '20 days' )
             ,
            ( ( SELECT
                    id
                FROM msbms_syst_data.syst_access_accounts
                WHERE internal_name = 'revoke_account_to_instance_test_accnt' )
            , ( SELECT
                    id
                FROM msbms_syst_data.syst_instances i
                WHERE internal_name = 'app1_owner1_instance_types_std' )
            , now( ) - INTERVAL '10 days'
            , now( ) + INTERVAL '20 days' );

        ------------------------------------------------------------------------
        -- Identity Creation
        ------------------------------------------------------------------------

        INSERT INTO msbms_syst_data.syst_identities
            ( access_account_id
            , identity_type_id
            , account_identifier
            , validated
            , validation_requested
            , identity_expires)
        SELECT
            aa.id
          , ( SELECT id
              FROM msbms_syst_data.syst_enum_items
              WHERE internal_name = 'identity_types_sysdef_email' )
          , aa.internal_name || '@musesystems.com' -- TODO: Change this to something more testable!
          , now( ) - interval '15 days'
          , now( ) - interval '20 days'
          , now( ) - interval '10 days'
        FROM msbms_syst_data.syst_access_accounts aa;

        INSERT INTO msbms_syst_data.syst_identities
            ( access_account_id
            , identity_type_id
            , account_identifier
            , validated
            , validation_requested
            , identity_expires )
        SELECT
            aa.id
          , ( SELECT id
              FROM msbms_syst_data.syst_enum_items
              WHERE internal_name = 'identity_types_sysdef_account' )
          , msbms_syst_priv.get_random_string(9)
          , now( ) - INTERVAL '15 days'
          , now( ) - INTERVAL '20 days'
          , now( ) - INTERVAL '10 days'
        FROM msbms_syst_data.syst_access_accounts aa;

        INSERT INTO msbms_syst_data.syst_identities
            ( access_account_id
            , identity_type_id
            , account_identifier
            , validated
            , validation_requested
            , identity_expires )
        SELECT
            aa.id
          , ( SELECT id
              FROM msbms_syst_data.syst_enum_items
              WHERE internal_name = 'identity_types_sysdef_api' )
          , msbms_syst_priv.get_random_string(16)
          , now( ) - INTERVAL '15 days'
          , now( ) - INTERVAL '20 days'
          , now( ) - INTERVAL '10 days'
        FROM msbms_syst_data.syst_access_accounts aa;

        ------------------------------------------------------------------------
        -- Credential Creation
        ------------------------------------------------------------------------

        INSERT INTO msbms_syst_data.syst_credentials
            ( access_account_id, credential_type_id, credential_data, last_updated )
        VALUES
            ( ( SELECT id
                FROM msbms_syst_data.syst_access_accounts
                WHERE internal_name = 'unowned_all_access' )
            , ( SELECT
                    id
                FROM msbms_syst_data.syst_enum_items
                WHERE internal_name = 'credential_types_sysdef_password' )
            -- unowned.all.access.test.password
            , '$argon2id$v=19$m=65536,t=8,p=2$WuXR7/MzTrdNzsYUaX/ssg$DZaMwZLHDX5z38tNck4vFIuGeZHOwfXxS87BonqETFc'
            , now( ) - INTERVAL '1 day' );

        INSERT INTO msbms_syst_data.syst_credentials
            ( access_account_id, credential_type_id, credential_data, last_updated )
        VALUES
            ( ( SELECT id
                FROM msbms_syst_data.syst_access_accounts
                WHERE internal_name = 'owned_all_access' )
            , ( SELECT
                    id
                FROM msbms_syst_data.syst_enum_items
                WHERE internal_name = 'credential_types_sysdef_password' )
            -- owned.all.access.test.password
            , '$argon2id$v=19$m=65536,t=8,p=2$E3Fo2aZ0ujVew+zFzVmQLg$HmOFV+om6gLAIp6rM8MFtqYpv8vPb8xWeY3RIjynxVw'
            , now( ) - INTERVAL '1 day' );

        INSERT INTO msbms_syst_data.syst_credentials
            ( access_account_id, credential_type_id, credential_data, last_updated )
        VALUES
            ( ( SELECT id
                FROM msbms_syst_data.syst_access_accounts
                WHERE internal_name = 'example_accnt' )
            , ( SELECT
                    id
                FROM msbms_syst_data.syst_enum_items
                WHERE internal_name = 'credential_types_sysdef_password' )
            -- example.test.password
            , '$argon2id$v=19$m=65536,t=8,p=2$0n4sdMLjE7IeQNmR1YfFgg$BzujLUJVkKVvAH6LA8yKuqtGRd00qZN5iQTgskFHhxY'
            , now( ) - INTERVAL '1 day' );

        INSERT INTO msbms_syst_data.syst_credentials
            ( access_account_id
            , credential_type_id
            , credential_for_identity_id
            , credential_data
            , last_updated )
        VALUES
            ( ( SELECT id
                FROM msbms_syst_data.syst_access_accounts
                WHERE internal_name = 'unowned_all_access' )
            , ( SELECT
                    id
                FROM msbms_syst_data.syst_enum_items
                WHERE internal_name = 'credential_types_sysdef_token_api' )
            , ( SELECT
                    i.id
                FROM msbms_syst_data.syst_identities i
                    JOIN msbms_syst_data.syst_access_accounts aa ON aa.id = i.access_account_id
                    JOIN msbms_syst_data.syst_enum_items ei ON ei.id = i.identity_type_id
                WHERE
                      aa.internal_name = 'unowned_all_access'
                  AND ei.internal_name = 'identity_types_sysdef_api' )
              -- TY7N2G9TADG6ADA80FFI4F24PTNYKAQGRG0LYK4FHNJ67NPS
            , '$argon2id$v=19$m=65536,t=8,p=2$etwRUSNGUlv7SK7d3WCg5A$E1t6u7fI599HdoRJB8zXeEqoF/UdhL+lG7UfyAw3O28'
            , now( ) - INTERVAL '1 day' );

        INSERT INTO msbms_syst_data.syst_credentials
            ( access_account_id
            , credential_type_id
            , credential_for_identity_id
            , credential_data
            , last_updated )
        VALUES
            ( ( SELECT id
                FROM msbms_syst_data.syst_access_accounts
                WHERE internal_name = 'owned_all_access' )
            , ( SELECT
                    id
                FROM msbms_syst_data.syst_enum_items
                WHERE internal_name = 'credential_types_sysdef_token_api' )
            , ( SELECT
                    i.id
                FROM msbms_syst_data.syst_identities i
                    JOIN msbms_syst_data.syst_access_accounts aa ON aa.id = i.access_account_id
                    JOIN msbms_syst_data.syst_enum_items ei ON ei.id = i.identity_type_id
                WHERE
                      aa.internal_name = 'owned_all_access'
                  AND ei.internal_name = 'identity_types_sysdef_api' )
              -- QNXWXLSYLB8O3PHMSLOEU9Y1WZF4PIIPUQREXSRRYLVBMPU2
            , '$argon2id$v=19$m=65536,t=8,p=2$HVjIPnRUzdzwubYxKJ6ZZg$vy4aDFg1hUBpMPm5S4/Bfs3Q7VUM725w9zIhcwUeXvQ'
            , now( ) - INTERVAL '1 day' );

        INSERT INTO msbms_syst_data.syst_credentials
            ( access_account_id
            , credential_type_id
            , credential_for_identity_id
            , credential_data
            , last_updated )
        VALUES
            ( ( SELECT id
                FROM msbms_syst_data.syst_access_accounts
                WHERE internal_name = 'example_accnt' )
            , ( SELECT
                    id
                FROM msbms_syst_data.syst_enum_items
                WHERE internal_name = 'credential_types_sysdef_token_api' )
            , ( SELECT
                    i.id
                FROM msbms_syst_data.syst_identities i
                    JOIN msbms_syst_data.syst_access_accounts aa ON aa.id = i.access_account_id
                    JOIN msbms_syst_data.syst_enum_items ei ON ei.id = i.identity_type_id
                WHERE
                      aa.internal_name = 'example_accnt'
                  AND ei.internal_name = 'identity_types_sysdef_api' )
              -- J7RJY39PCI2CJ2P6BWSRA98XFG5SAZ0PIMTELMGLCC3X5PYD
            , '$argon2id$v=19$m=65536,t=8,p=2$IMiQN/YlkA+g20mMgsKV1w$/WP/6UFwnxo46oR4nN6/5MqncIu4JAsnRyCnkoiLS/I'
            , now( ) - INTERVAL '1 day' );


    END;
$AUTHENTICATION_TESTING_INIT$;
