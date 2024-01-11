-- File:        test_data_doc_test.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/testing_support/test_data_doc_test.eex.sql
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
$AUTHENTICATION_TESTING_INIT$
    DECLARE
        var_data jsonb;
    BEGIN

        /**********************************************************************
         **
         **  Test Data Description
         **
         **********************************************************************/

        var_data := $TEST_DATA_DEFINTION$
        {
          "disallowed_passwords": [
            "Is Disallowed",
            "No Longer Disallowed"
            ],
          "disallowed_hosts": [
            "10.123.123.1",
            "10.123.123.2",
            "10.123.123.3",
            "10.123.123.4",
            "10.123.123.5",
            "10.10.250.1",
            "10.10.250.2",
            "10.10.250.3",
            "10.10.250.4",
            "10.10.250.5",
            "10.10.250.6",
            "10.10.254.1",
            "10.10.254.2",
            "10.10.254.3",
            "10.10.254.4",
            "10.10.254.5",
            "10.10.254.6",
            "10.10.251.1",
            "10.10.251.2",
            "10.10.251.3"
          ],
          "owner_password_rules": [ ],
          "global_network_rules": [
            {
              "ordering": 1,
              "functional_type": "deny",
              "ip_host_or_network": "10.131.131.0/24",
              "ip_host_range_lower": null,
              "ip_host_range_upper": null
            },
            {
              "ordering": 2,
              "functional_type": "allow",
              "ip_host_or_network": "10.131.131.5",
              "ip_host_range_lower": null,
              "ip_host_range_upper": null
            },
            {
              "ordering": 3,
              "functional_type": "allow",
              "ip_host_or_network": "10.125.125.0/24",
              "ip_host_range_lower": null,
              "ip_host_range_upper": null
            },
            {
              "ordering": 4,
              "functional_type": "allow",
              "ip_host_or_network": null,
              "ip_host_range_lower": "10.123.123.5",
              "ip_host_range_upper": "10.123.123.254"
            },
            {
              "ordering": 5,
              "functional_type": "allow",
              "ip_host_or_network": "10.131.131.5",
              "ip_host_range_lower": null,
              "ip_host_range_upper": null
            },
            {
              "ordering": 6,
              "functional_type": "allow",
              "ip_host_or_network": "10.125.125.0/24",
              "ip_host_range_lower": null,
              "ip_host_range_upper": null
            },
            {
              "ordering": 7,
              "functional_type": "allow",
              "ip_host_or_network": null,
              "ip_host_range_lower": "10.123.123.5",
              "ip_host_range_upper": "10.123.123.254"
            },
            {
              "ordering": 8,
              "functional_type": "allow",
              "ip_host_or_network": null,
              "ip_host_range_lower": "10.123.123.5",
              "ip_host_range_upper": "10.123.123.254"
            }
          ],
          "owner_network_rules": [],
          "instance_network_rules": [
            {
              "instance_name": "app1_owner1_instance_types_std",
              "ordering": 1,
              "functional_type": "allow",
              "ip_host_or_network": "10.170.170.1",
              "ip_host_range_lower": null,
              "ip_host_range_upper": null
            },
            {
              "instance_name": "app1_owner1_instance_types_std",
              "ordering": 2,
              "functional_type": "deny",
              "ip_host_or_network": "10.170.170.2",
              "ip_host_range_lower": null,
              "ip_host_range_upper": null
            }
            ],
          "access_accounts": [
            {
              "access_account_name": "example_purge_accnt",
              "external_name": "Example Purge Account",
              "owning_owner_name": null,
              "allow_global_logins": false,
              "access_account_state_name": "access_account_states_sysdef_purge_eligible",
              "instance_access": [
                {
                  "instance_name": null,
                  "access_granted_days": -20,
                  "invitation_issued_days": -40,
                  "invitation_expires_days": -10,
                  "invitation_declined_days": null
                }
              ],
              "identities": [
                {
                  "identity_type_name": "identity_types_sysdef_email",
                  "account_identifier": "example_purge_accnt@musesystems.com",
                  "account_identifier_length": null,
                  "validated_days": -15,
                  "validation_requested_days": -20,
                  "identity_expires_days": null,
                  "validation": null,
                  "credential": null
                },
                {
                  "identity_type_name": "identity_types_sysdef_api",
                  "account_identifier": null,
                  "account_identifier_length": 16,
                  "validated_days": -15,
                  "validation_requested_days": null,
                  "identity_expires_days": 1,
                  "validation": null,
                  "credential": {
                    "credential_type_name": "credential_types_sysdef_token_api",
                    "credential_plaintext": "HZgRmnCwJ0ND8uKynUUodg41jWf8fe7Y28MWAeSGr3yksdMs",
                    "credential_data": "$argon2id$v=19$m=65536,t=8,p=2$TYuXhFE8ummSK7wdPhrprQ$1ASZF0VWX3w7c5TobSZRooZonRDpjxvaMF1Sz+0wvIA",
                    "last_updated_days": -10
                  }
                }
              ],
              "credentials": [],
              "password_history": []
            },
            {
              "access_account_name": "example_accnt",
              "external_name": "Example Account",
              "owning_owner_name": null,
              "allow_global_logins": false,
              "access_account_state_name": "access_account_states_sysdef_purge_eligible",
              "instance_access": [
                {
                  "instance_name": null,
                  "access_granted_days": -20,
                  "invitation_issued_days": -40,
                  "invitation_expires_days": -10,
                  "invitation_declined_days": null
                }
              ],
              "identities": [
                {
                  "identity_type_name": "identity_types_sysdef_email",
                  "account_identifier": "example_accnt@musesystems.com",
                  "account_identifier_length": null,
                  "validated_days": -15,
                  "validation_requested_days": -20,
                  "identity_expires_days": null,
                  "validation": null,
                  "credential": null
                },
                {
                  "identity_type_name": "identity_types_sysdef_api",
                  "account_identifier": null,
                  "account_identifier_length": 16,
                  "validated_days": -15,
                  "validation_requested_days": null,
                  "identity_expires_days": 1,
                  "validation": null,
                  "credential": {
                    "credential_type_name": "credential_types_sysdef_token_api",
                    "credential_plaintext": "J7RJY39PCI2CJ2P6BWSRA98XFG5SAZ0PIMTELMGLCC3X5PYD",
                    "credential_data": "$argon2id$v=19$m=65536,t=8,p=2$IMiQN/YlkA+g20mMgsKV1w$/WP/6UFwnxo46oR4nN6/5MqncIu4JAsnRyCnkoiLS/I",
                    "last_updated_days": -10
                  }
                }
              ],
              "credentials": [
                {
                  "credential_type_name": "credential_types_sysdef_password",
                  "credential_plaintext": "example.test.password",
                  "credential_data": "$argon2id$v=19$m=65536,t=8,p=2$0n4sdMLjE7IeQNmR1YfFgg$BzujLUJVkKVvAH6LA8yKuqtGRd00qZN5iQTgskFHhxY",
                  "last_updated_days": -1
                }
              ],
              "password_history": []
            }
          ]
        }
        $TEST_DATA_DEFINTION$;

        /**********************************************************************
         **
         **  Test Data Creation
         **
         **********************************************************************/

        ----------------------------------------------------
        -- Disallowed Passwords
        ----------------------------------------------------

        INSERT INTO ms_syst_data.syst_disallowed_passwords
            ( password_hash )
        SELECT
            digest( password, 'sha1' )
        FROM jsonb_array_elements_text( var_data -> 'disallowed_passwords' ) password;

        ----------------------------------------------------
        -- Disallowed Hosts
        ----------------------------------------------------

        INSERT INTO ms_syst_data.syst_disallowed_hosts
            ( host_address )
        SELECT
            ip_addr::inet
        FROM jsonb_array_elements_text( var_data -> 'disallowed_hosts' ) ip_addr;

        ----------------------------------------------------
        -- Owner Password Rules
        ----------------------------------------------------

        INSERT INTO ms_syst_data.syst_owner_password_rules
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
        SELECT
            o.id
          , int4range( ( opr #>> '{password_length, lower}' )::integer,
                       ( opr #>> '{password_length, upper}' )::integer,
                       opr #>> '{password_length, inclusion}' )
          , make_interval( days => ( opr ->> 'max_age_days' )::integer )
          , ( opr ->> 'require_upper_case' )::integer
          , ( opr ->> 'require_lower_case' )::integer
          , ( opr ->> 'require_numbers' )::integer
          , ( opr ->> 'require_symbols' )::integer
          , ( opr ->> 'disallow_recently_used' )::integer
          , ( opr ->> 'disallow_compromised' )::boolean
          , ( opr ->> 'require_mfa' )::boolean
          , array( SELECT jsonb_array_elements_text( opr -> 'allowed_mfa_types' ) )
        FROM jsonb_array_elements( var_data -> 'owner_password_rules' ) opr
            JOIN ms_syst_data.syst_owners o ON o.internal_name = opr ->> 'owner_name';

        ----------------------------------------------------
        -- Network Rules
        ----------------------------------------------------

        INSERT INTO ms_syst_data.syst_global_network_rules
            (
              ordering
            , functional_type
            , ip_host_or_network
            , ip_host_range_lower
            , ip_host_range_upper
            )
        SELECT
              (gnr ->> 'ordering')::integer
            , gnr ->> 'functional_type'
            , (gnr ->> 'ip_host_or_network')::inet
            , (gnr ->> 'ip_host_range_lower')::inet
            , (gnr ->> 'ip_host_range_upper')::inet
        FROM jsonb_array_elements( var_data -> 'global_network_rules' ) gnr;

        INSERT INTO ms_syst_data.syst_owner_network_rules
            (
              owner_id
            , ordering
            , functional_type
            , ip_host_or_network
            , ip_host_range_lower
            , ip_host_range_upper
            )
        SELECT
              o.id
            , (onr ->> 'ordering')::integer
            , onr ->> 'functional_type'
            , (onr ->> 'ip_host_or_network')::inet
            , (onr ->> 'ip_host_range_lower')::inet
            , (onr ->> 'ip_host_range_upper')::inet
        FROM jsonb_array_elements( var_data -> 'owner_network_rules' ) onr
            JOIN ms_syst_data.syst_owners o ON o.internal_name = onr ->> 'owner_name';

        INSERT INTO ms_syst_data.syst_owner_network_rules
            ( owner_id
            , ordering
            , functional_type
            , ip_host_or_network
            , ip_host_range_lower
            , ip_host_range_upper )
        SELECT
            o.id
          , ( onr ->> 'ordering' )::integer
          , onr ->> 'functional_type'
          , ( onr ->> 'ip_host_or_network' )::inet
          , ( onr ->> 'ip_host_range_lower' )::inet
          , ( onr ->> 'ip_host_range_upper' )::inet
        FROM  jsonb_path_query( var_data, '$.owner_network_rules[*] ? (@.owner_name == null)' ) onr
            CROSS JOIN ms_syst_data.syst_owners o
        WHERE o.id NOT IN (SELECT owner_id FROM ms_syst_data.syst_owner_network_rules);

        INSERT INTO ms_syst_data.syst_instance_network_rules
            ( instance_id
            , ordering
            , functional_type
            , ip_host_or_network
            , ip_host_range_lower
            , ip_host_range_upper )
        SELECT
            i.id
          , ( inr ->> 'ordering' )::integer
          , inr ->> 'functional_type'
          , ( inr ->> 'ip_host_or_network' )::inet
          , ( inr ->> 'ip_host_range_lower' )::inet
          , ( inr ->> 'ip_host_range_upper' )::inet
        FROM jsonb_array_elements( var_data -> 'instance_network_rules' ) inr
            JOIN ms_syst_data.syst_instances i ON i.internal_name = inr ->> 'instance_name';

        INSERT INTO ms_syst_data.syst_instance_network_rules
            ( instance_id
            , ordering
            , functional_type
            , ip_host_or_network
            , ip_host_range_lower
            , ip_host_range_upper )
        SELECT
            i.id
          , ( inr ->> 'ordering' )::integer
          , inr ->> 'functional_type'
          , ( inr ->> 'ip_host_or_network' )::inet
          , ( inr ->> 'ip_host_range_lower' )::inet
          , ( inr ->> 'ip_host_range_upper' )::inet
        FROM  jsonb_path_query( var_data, '$.instance_network_rules[*] ? (@.instance_name == null)' ) inr
            CROSS JOIN ms_syst_data.syst_instances i
        WHERE i.id NOT IN (SELECT instance_id FROM ms_syst_data.syst_instance_network_rules);

        ----------------------------------------------------
        -- Access Account Processing
        ----------------------------------------------------

        << access_account_creation >>
        DECLARE
            var_account_data           record;
            var_access_account_id      uuid;

            var_identity_data          record;
            var_primary_identity_id    uuid;
            var_validation_identity_id uuid;

            var_credential_data        record;

        BEGIN

            << access_account_loop >>
            FOR var_account_data IN
                SELECT
                    aa ->> 'access_account_name'              AS access_account_name
                  , aa ->> 'external_name'                    AS external_name
                  , o.internal_name                           AS owning_owner_name
                  , o.id                                      AS owning_owner_id
                  , ( aa ->> 'allow_global_logins' )::boolean AS allow_global_logins
                  , ei.id                                     AS access_account_state_id
                  , aa -> 'instance_access'                   AS instance_access
                  , aa -> 'identities'                        AS identities
                  , aa -> 'credentials'                       AS credentials
                  , aa -> 'password_history'                  AS password_history
                FROM jsonb_array_elements( var_data -> 'access_accounts' ) aa
                    JOIN ms_syst_data.syst_enum_items ei
                        ON ei.internal_name = aa ->> 'access_account_state_name'
                    LEFT JOIN ms_syst_data.syst_owners o
                        ON o.internal_name = aa ->> 'owning_owner_name'
            LOOP

                ----------------------------------------------------
                -- Access Accounts
                ----------------------------------------------------

                INSERT INTO ms_syst_data.syst_access_accounts
                    ( internal_name
                    , external_name
                    , owning_owner_id
                    , allow_global_logins
                    , access_account_state_id )
                VALUES
                    ( var_account_data.access_account_name
                    , var_account_data.external_name
                    , var_account_data.owning_owner_id
                    , var_account_data.allow_global_logins
                    , var_account_data.access_account_state_id)
                RETURNING id INTO var_access_account_id;

                ----------------------------------------------------
                -- Access Account Instance Access
                ----------------------------------------------------

                INSERT INTO ms_syst_data.syst_access_account_instance_assocs
                    ( access_account_id
                    , instance_id
                    , access_granted
                    , invitation_issued
                    , invitation_expires
                    , invitation_declined )
                SELECT
                      aa.id
                    , i.id
                    , now() + make_interval( days => ( ia ->> 'access_granted_days' )::integer )
                    , now() + make_interval( days => ( ia ->> 'invitation_issued_days' )::integer )
                    , now() + make_interval( days => ( ia ->> 'invitation_expires_days' )::integer )
                    , now() + make_interval( days => ( ia ->> 'invitation_declined_days' )::integer )
                FROM jsonb_array_elements( var_account_data.instance_access ) ia
                    JOIN ms_syst_data.syst_access_accounts aa
                        ON aa.internal_name = var_account_data.access_account_name
                    JOIN ms_syst_data.syst_instances i
                        ON i.internal_name = ia ->> 'instance_name';

                INSERT INTO ms_syst_data.syst_access_account_instance_assocs
                    ( access_account_id
                    , instance_id
                    , access_granted
                    , invitation_issued
                    , invitation_expires
                    , invitation_declined )
                SELECT
                      aa.id
                    , i.id
                    , now() + make_interval( days => ( ia ->> 'access_granted_days' )::integer )
                    , now() + make_interval( days => ( ia ->> 'invitation_issued_days' )::integer )
                    , now() + make_interval( days => ( ia ->> 'invitation_expires_days' )::integer )
                    , now() + make_interval( days => ( ia ->> 'invitation_declined_days' )::integer )
                FROM jsonb_array_elements( var_account_data.instance_access ) ia
                    JOIN ms_syst_data.syst_access_accounts aa
                        ON aa.internal_name = var_account_data.access_account_name
                    CROSS JOIN ms_syst_data.syst_instances i
                WHERE i.id NOT IN (SELECT instance_id
                                   FROM ms_syst_data.syst_access_account_instance_assocs
                                   WHERE access_account_id = var_access_account_id)
                  AND ( i.owner_id = aa.owning_owner_id or
                        coalesce( ( ia ->> 'no_owner_restriction' )::boolean, FALSE ) );

                ----------------------------------------------------
                -- Access Account Identities
                ----------------------------------------------------

                << access_account_identities_loop >>
                FOR var_identity_data IN
                    SELECT
                        i ->> 'identity_type_name'                                       AS identity_type_name
                      , ei.id                                                            AS identity_type_id
                      , coalesce( i ->> 'account_identifier',
                                  ms_syst_priv.get_random_string(
                                      ( i ->> 'account_identifier_length' )::integer ) ) AS account_identifier
                      , now( ) +
                        make_interval(
                            days => ( i ->> 'validated_days' )::integer )                AS validated
                      , now( ) +
                        make_interval(
                            days => ( i ->> 'validation_requested_days' )::integer )     AS validation_requested
                      , now( ) +
                        make_interval(
                            days => ( i ->> 'identity_expires_days' )::integer )         AS identity_expires
                      , i -> 'validation'                                                AS validation
                      , i -> 'credential'                                                AS credential
                    FROM jsonb_array_elements( var_account_data.identities ) i
                        JOIN ms_syst_data.syst_enum_items ei
                             ON ei.internal_name = i ->> 'identity_type_name'
                LOOP

                    ----------------------------------------------------
                    -- Identities
                    ----------------------------------------------------

                    INSERT INTO ms_syst_data.syst_identities
                        ( access_account_id
                        , identity_type_id
                        , account_identifier
                        , validated
                        , validation_requested
                        , identity_expires)
                    VALUES
                        ( var_access_account_id
                        , var_identity_data.identity_type_id
                        , var_identity_data.account_identifier
                        , var_identity_data.validated
                        , var_identity_data.validation_requested
                        , var_identity_data.identity_expires )
                    RETURNING id INTO var_primary_identity_id;

                    ----------------------------------------------------
                    -- Identity Linked Credential
                    ----------------------------------------------------

                    INSERT INTO ms_syst_data.syst_credentials
                        ( access_account_id
                        , credential_type_id
                        , credential_for_identity_id
                        , credential_data
                        , force_reset
                        , last_updated )
                    SELECT
                          var_access_account_id
                        , (SELECT id
                           FROM ms_syst_data.syst_enum_items
                           WHERE internal_name = var_identity_data.credential ->> 'credential_type_name' )
                        , var_primary_identity_id
                        , var_identity_data.credential ->> 'credential_data'
                        , CASE
                            WHEN ( var_identity_data.credential ->> 'force_reset' )::boolean THEN
                                now()
                          END
                        , now() +
                          make_interval(
                              days =>
                                  coalesce(
                                      ( var_identity_data.credential ->> 'last_updated_days' )::integer,
                                      0) )
                    WHERE jsonb_typeof(var_identity_data.credential) = 'object';

                    ----------------------------------------------------
                    -- Identity Linked Validation Identity/Credential
                    ----------------------------------------------------

                    INSERT INTO ms_syst_data.syst_identities
                        ( access_account_id
                        , identity_type_id
                        , account_identifier
                        , validates_identity_id
                        , validated
                        , identity_expires )
                    SELECT
                          var_access_account_id
                        , ( SELECT
                                id
                            FROM ms_syst_data.syst_enum_items
                            WHERE internal_name = 'identity_types_sysdef_validation' )
                        , coalesce( var_identity_data.validation #>>
                                        '{identity, account_identifier}',
                                    ms_syst_priv.get_random_string(
                                        ( var_identity_data.validation #>>
                                          '{identity, account_identifier_length}' )::integer ) )
                        , var_primary_identity_id
                        , now( )
                        , now( ) +
                          make_interval(
                              days => ( var_identity_data.validation #>>
                                        '{identity, identity_expires_days}' )::integer )
                    WHERE jsonb_typeof(var_identity_data.validation -> 'identity') = 'object'
                    RETURNING id INTO var_validation_identity_id;

                    INSERT INTO ms_syst_data.syst_credentials
                        ( access_account_id
                        , credential_type_id
                        , credential_for_identity_id
                        , credential_data
                        , force_reset
                        , last_updated )
                    SELECT
                          var_access_account_id
                        , ( SELECT
                                id
                            FROM ms_syst_data.syst_enum_items
                            WHERE internal_name = 'credential_types_sysdef_token_validation' )
                        , var_validation_identity_id
                        , var_identity_data.validation #>> '{credential, credential_data}'
                        , CASE
                            WHEN
                               ( var_identity_data.validation #>> '{credential, force_reset}' )::boolean
                            THEN
                                now()
                          END
                        , now( ) +
                          make_interval(
                              days => coalesce(
                                  ( var_identity_data.validation #>>
                                    '{credential, last_updated_days}' )::integer,
                                  0 ) )
                    WHERE jsonb_typeof(var_identity_data.validation -> 'credential') = 'object'
                      AND var_validation_identity_id IS NOT NULL;

                END LOOP access_account_identities_loop;

                ----------------------------------------------------
                -- Non-linked Credentials
                ----------------------------------------------------

                INSERT INTO ms_syst_data.syst_credentials
                    ( access_account_id
                    , credential_type_id
                    , credential_data
                    , force_reset
                    , last_updated )
                SELECT
                      var_access_account_id
                    , ei.id
                    , c ->> 'credential_data'
                    , CASE
                        WHEN ( c ->> 'force_reset' )::boolean THEN
                            now()
                      END
                    , now( ) +
                      make_interval( days => coalesce( ( c ->> 'last_updated_days' )::integer, 0 ) )
                FROM jsonb_array_elements( var_account_data.credentials ) c
                    JOIN ms_syst_data.syst_enum_items ei
                         ON ei.internal_name = c ->> 'credential_type_name';

                ----------------------------------------------------
                -- Password History
                ----------------------------------------------------

                INSERT INTO ms_syst_data.syst_password_history
                    (access_account_id, credential_data )
                SELECT
                      var_access_account_id
                    , credential_data
                FROM jsonb_array_elements_text( var_account_data.password_history ) credential_data;

            END LOOP access_account_loop;

        END access_account_creation;

    END;
$AUTHENTICATION_TESTING_INIT$;
