-- File:        test_data.eex.sql
-- Location:    database\cmp_msbms_syst_instance_mgr\testing_support\test_data.eex.sql
-- Project:     Muse Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

DO
$INSTANCE_MGR_TESTING_INIT$
DECLARE
    var_test_app_1 msbms_syst_data.syst_applications;
    var_test_app_2 msbms_syst_data.syst_applications;

    var_owner_4 msbms_syst_data.syst_owners;
    var_owner_3 msbms_syst_data.syst_owners;
    var_owner_1 msbms_syst_data.syst_owners;
    var_owner_2 msbms_syst_data.syst_owners;

    var_instance_type_enum msbms_syst_data.syst_enums;
    var_big_instance msbms_syst_data.syst_enum_items;
    var_std_instance msbms_syst_data.syst_enum_items;
    var_sml_instance msbms_syst_data.syst_enum_items;

    var_test_instance_1 msbms_syst_data.syst_instances;
    var_test_instance_2 msbms_syst_data.syst_instances;
    var_test_instance_3 msbms_syst_data.syst_instances;
    var_test_instance_4 msbms_syst_data.syst_instances;
    var_test_instance_5 msbms_syst_data.syst_instances;

BEGIN

    --
    --  Applications
    --

    INSERT INTO msbms_syst_data.syst_applications
        ( internal_name, display_name, syst_description )
    VALUES
        ( 'test_app_2', 'Test App 2', 'Test App Two Description' )
    RETURNING * INTO var_test_app_2;

    INSERT INTO msbms_syst_data.syst_applications
        ( internal_name, display_name, syst_description )
    VALUES
        ( 'test_app_1', 'Test App 1', 'Test App One Description' )
    RETURNING * INTO var_test_app_1;

    --
    --  Owners
    --

    INSERT INTO msbms_syst_data.syst_owners
        ( internal_name, display_name, owner_state_id )
    VALUES
        ( 'owner_4', 'Owner 4 Inactive', ( SELECT id
                                           FROM msbms_syst_data.syst_enum_items
                                           WHERE internal_name = 'owner_states_sysdef_inactive' ) )
    RETURNING * INTO var_owner_4;

    INSERT INTO msbms_syst_data.syst_owners
        ( internal_name, display_name, owner_state_id )
    VALUES
        ( 'owner_3', 'Owner 3 Active', ( SELECT id
                                         FROM msbms_syst_data.syst_enum_items
                                         WHERE internal_name = 'owner_states_sysdef_active' ) )
    RETURNING * INTO var_owner_3;

    INSERT INTO msbms_syst_data.syst_owners
        ( internal_name, display_name, owner_state_id )
    VALUES
        ( 'owner_1', 'Owner 1 Active', ( SELECT id
                                         FROM msbms_syst_data.syst_enum_items
                                         WHERE internal_name = 'owner_states_sysdef_active' ) )
    RETURNING * INTO var_owner_1;

    INSERT INTO msbms_syst_data.syst_owners
        ( internal_name, display_name, owner_state_id )
    VALUES
        ( 'owner_2', 'Owner 2 Inactive', ( SELECT id
                                           FROM msbms_syst_data.syst_enum_items
                                           WHERE internal_name = 'owner_states_sysdef_inactive' ) )
    RETURNING * INTO var_owner_2;


    --
    -- Create some instance types.
    --

    SELECT *
    INTO var_instance_type_enum
    FROM msbms_syst_data.syst_enums
    WHERE internal_name = 'instance_types';

    INSERT INTO msbms_syst_data.syst_enum_items
        ( internal_name
        , display_name
        , external_name
        , enum_id
        , enum_default
        , syst_description
        , user_description
        , user_options )
    VALUES
        ( 'instance_types_big_instance'
        , 'Instance Types / Big Instance'
        , 'Big Instance'
        , var_instance_type_enum.id
        , FALSE
        , '(System Description Not Provided)'
        , 'A Big Instance Description'
        , '{
          "datastore_contexts": [
            {
              "id": "test_datastore_context_1",
              "db_pool_size": 20
            },
            {
              "id": "test_datastore_context_1",
              "db_pool_size": 20
            }
          ]
        }'::jsonb )
    RETURNING * INTO var_big_instance;

    INSERT INTO msbms_syst_data.syst_enum_items
        ( internal_name
        , display_name
        , external_name
        , enum_id
        , enum_default
        , syst_description
        , user_description
        , user_options )
    VALUES
        ( 'instance_types_std_instance'
        , 'Instance Types / Std. Instance'
        , 'Standard Instance'
        , var_instance_type_enum.id
        , FALSE
        , '(System Description Not Provided)'
        , 'A Standard Instance Description'
        , '{
          "datastore_contexts": [
            {
              "id": "test_datastore_context_1",
              "db_pool_size": 10
            },
            {
              "id": "test_datastore_context_1",
              "db_pool_size": 10
            }
          ]
        }'::jsonb )
    RETURNING * INTO var_std_instance;

    INSERT INTO msbms_syst_data.syst_enum_items
        ( internal_name
        , display_name
        , external_name
        , enum_id
        , enum_default
        , syst_description
        , user_description
        , user_options )
    VALUES
        ( 'instance_types_sml_instance'
        , 'Instance Types / Small Instance'
        , 'Small Instance'
        , var_instance_type_enum.id
        , FALSE
        , '(System Description Not Provided)'
        , 'A Small Instance Description'
        , '{
          "datastore_contexts": [
            {
              "id": "test_datastore_context_1",
              "db_pool_size": 3
            },
            {
              "id": "test_datastore_context_1",
              "db_pool_size": 3
            }
          ]
        }'::jsonb )
    RETURNING * INTO var_sml_instance;

    --
    -- Create some instances.
    --

    INSERT INTO msbms_syst_data.syst_instances
        ( internal_name
        , display_name
        , application_id
        , instance_type_id
        , instance_state_id
        , owner_id
        , owning_instance_id
        , instance_options )
    VALUES
        ( 'test_instance_1'
        , 'Test Instance One'
        , var_test_app_1.id
        , var_big_instance.id
        , ( SELECT
                id
            FROM msbms_syst_data.syst_enum_items
            WHERE internal_name = 'instance_states_sysdef_active' )
        , var_owner_3.id
        , NULL
        , '{
          "datastore_contexts": [
            {
              "id": "test_datastore_context_1",
              "db_pool_size": 20
            },
            {
              "id": "test_datastore_context_1",
              "db_pool_size": 20
            }
          ]
        }'::jsonb )
    RETURNING * INTO var_test_instance_1;

    INSERT INTO msbms_syst_data.syst_instances
        ( internal_name
        , display_name
        , application_id
        , instance_type_id
        , instance_state_id
        , owner_id
        , owning_instance_id
        , instance_options )
    VALUES
        ( 'test_instance_2'
        , 'Test Instance Two (Sub 1)'
        , var_test_app_1.id
        , var_std_instance.id
        , ( SELECT id
            FROM msbms_syst_data.syst_enum_items
            WHERE internal_name = 'instance_states_sysdef_active' )
        , var_owner_3.id
        , var_test_instance_1.id
        , '{
          "datastore_contexts": [
            {
              "id": "test_datastore_context_1",
              "db_pool_size": 10
            },
            {
              "id": "test_datastore_context_1",
              "db_pool_size": 10
            }
          ]
        }'::jsonb )
    RETURNING * INTO var_test_instance_2;

    INSERT INTO msbms_syst_data.syst_instances
        ( internal_name
        , display_name
        , application_id
        , instance_type_id
        , instance_state_id
        , owner_id
        , owning_instance_id
        , instance_options )
    VALUES
        ( 'test_instance_3'
        , 'Test Instance Three (Sub 1)'
        , var_test_app_1.id
        , var_sml_instance.id
        , ( SELECT
                id
            FROM msbms_syst_data.syst_enum_items
            WHERE internal_name = 'instance_states_sysdef_inactive' )
        , var_owner_3.id
        , var_test_instance_1.id
        , '{
          "datastore_contexts": [
            {
              "id": "test_datastore_context_1",
              "db_pool_size": 3
            },
            {
              "id": "test_datastore_context_1",
              "db_pool_size": 3
            }
          ]
        }'::jsonb )
    RETURNING * INTO var_test_instance_3;

    INSERT INTO msbms_syst_data.syst_instances
        ( internal_name
        , display_name
        , application_id
        , instance_type_id
        , instance_state_id
        , owner_id
        , owning_instance_id
        , instance_options )
    VALUES
        ( 'test_instance_4'
        , 'Test Instance Four'
        , var_test_app_2.id
        , var_big_instance.id
        , ( SELECT
                id
            FROM msbms_syst_data.syst_enum_items
            WHERE internal_name = 'instance_states_sysdef_active' )
        , var_owner_4.id
        , NULL
        , '{
          "datastore_contexts": [
            {
              "id": "test_datastore_context_1",
              "db_pool_size": 20
            },
            {
              "id": "test_datastore_context_1",
              "db_pool_size": 20
            }
          ]
        }'::jsonb )
    RETURNING * INTO var_test_instance_4;

    INSERT INTO msbms_syst_data.syst_instances
        ( internal_name
        , display_name
        , application_id
        , instance_type_id
        , instance_state_id
        , owner_id
        , owning_instance_id
        , instance_options )
    VALUES
        ( 'test_instance_5'
        , 'Test Instance Five'
        , var_test_app_1.id
        , var_big_instance.id
        , ( SELECT
                id
            FROM msbms_syst_data.syst_enum_items
            WHERE internal_name = 'instance_states_sysdef_inactive' )
        , var_owner_4.id
        , NULL
        , '{
          "datastore_contexts": [
            {
              "id": "test_datastore_context_1",
              "db_pool_size": 20
            },
            {
              "id": "test_datastore_context_1",
              "db_pool_size": 20
            }
          ]
        }'::jsonb )
    RETURNING * INTO var_test_instance_5;

END;
$INSTANCE_MGR_TESTING_INIT$;
