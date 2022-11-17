-- File:        test_data_unit_test.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_instance/testing_support/test_data_unit_test.eex.sql
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
$INSTANCE_MGR_TESTING_INIT$
BEGIN

    --
    --  Applications
    --

    INSERT INTO ms_syst_data.syst_applications
        ( internal_name, display_name, syst_description )
    VALUES
        ( 'app2', 'App 2', 'App Two Description' )
         ,
        ( 'app1', 'App 1', 'App One Description' );

    --
    -- Application Contexts
    --

    INSERT INTO ms_syst_data.syst_application_contexts
        ( internal_name
        , display_name
        , application_id
        , description
        , start_context
        , login_context
        , database_owner_context )
    VALUES
        ( 'app1_owner'
        , 'App 1 Owner'
        , ( SELECT id
            FROM ms_syst_data.syst_applications
            WHERE internal_name = 'app1' )
        , 'App 1 Owner'
        , FALSE
        , FALSE
        , TRUE )

         ,
        ( 'app1_appusr'
        , 'App 1 AppUsr'
        , ( SELECT id
            FROM ms_syst_data.syst_applications
            WHERE internal_name = 'app1' )
        , 'App 1 AppUsr'
        , TRUE
        , TRUE
        , FALSE )

         ,
        ( 'app1_apiusr'
        , 'App 1 ApiUsr'
        , ( SELECT id
            FROM ms_syst_data.syst_applications
            WHERE internal_name = 'app1' )
        , 'App 1 API user Context'
        , TRUE
        , TRUE
        , FALSE )

         ,
        ( 'app2_owner'
        , 'App 2 Owner'
        , ( SELECT id
            FROM ms_syst_data.syst_applications
            WHERE internal_name = 'app2' )
        , 'App 2 Owner'
        , FALSE
        , FALSE
        , TRUE )

         ,
        ( 'app2_appusr'
        , 'App 2 AppUsr'
        , ( SELECT id
            FROM ms_syst_data.syst_applications
            WHERE internal_name = 'app2' )
        , 'App 2 App'
        , TRUE
        , TRUE
        , FALSE )

         ,
        ( 'app2_apiusr'
        , 'App 2 ApiUsr'
        , ( SELECT id
            FROM ms_syst_data.syst_applications
            WHERE internal_name = 'app2' )
        , 'App 2 API'
        , TRUE
        , TRUE
        , FALSE );


    --
    --  Owners
    --

    INSERT INTO ms_syst_data.syst_owners
        ( internal_name, display_name, owner_state_id )
    VALUES
        ( 'owner4', 'Owner 4 Inactive', ( SELECT id
                                          FROM ms_syst_data.syst_enum_items
                                          WHERE internal_name = 'owner_states_sysdef_inactive' ) )

         ,
        ( 'owner3', 'Owner 3 Active', ( SELECT id
                                        FROM ms_syst_data.syst_enum_items
                                        WHERE internal_name = 'owner_states_sysdef_active' ) )

         ,
        ( 'owner1', 'Owner 1 Active', ( SELECT id
                                        FROM ms_syst_data.syst_enum_items
                                        WHERE internal_name = 'owner_states_sysdef_active' ) )

         ,
        ( 'owner2', 'Owner 2 Inactive', ( SELECT id
                                          FROM ms_syst_data.syst_enum_items
                                          WHERE internal_name = 'owner_states_sysdef_inactive' ) )

         ,
        ( 'owner5', 'Owner 5 Active', ( SELECT id
                                          FROM ms_syst_data.syst_enum_items
                                          WHERE internal_name = 'owner_states_sysdef_active' ) )

         ,
        ( 'owner6', 'Owner 6 Inactive', ( SELECT id
                                          FROM ms_syst_data.syst_enum_items
                                          WHERE internal_name = 'owner_states_sysdef_active' ) )

         ,
        ( 'owner7', 'Owner 7 Inactive', ( SELECT id
                                          FROM ms_syst_data.syst_enum_items
                                          WHERE internal_name = 'owner_states_sysdef_active' ) )

         ,
        ( 'owner8', 'Owner 8 Inactive', ( SELECT id
                                          FROM ms_syst_data.syst_enum_items
                                          WHERE internal_name = 'owner_states_sysdef_active' ) )

         ,
        ( 'owner9', 'Owner 9 Inactive', ( SELECT id
                                          FROM ms_syst_data.syst_enum_items
                                          WHERE internal_name = 'owner_states_sysdef_active' ) )

         ,
        ( 'owner0', 'Owner 0 Inactive', ( SELECT id
                                          FROM ms_syst_data.syst_enum_items
                                          WHERE internal_name = 'owner_states_sysdef_active' ) );


    --
    -- Create Instance Types.
    --

    INSERT INTO ms_syst_data.syst_enum_items
        ( internal_name
        , display_name
        , external_name
        , enum_id
        , enum_default
        , syst_description
        , user_description
        , user_options )
    VALUES
        ( 'instance_types_big'
        , 'Instance Types / Big'
        , 'Big Instance'
        , (SELECT id FROM ms_syst_data.syst_enums WHERE internal_name = 'instance_types')
        , FALSE
        , '(System Description Not Provided)'
        , 'A Big Instance Description'
        , '{"allowed_server_pools": ["primary"]}'::jsonb )
         ,
        ( 'instance_types_std'
        , 'Instance Types / Standard'
        , 'Standard Instance'
        , (SELECT id FROM ms_syst_data.syst_enums WHERE internal_name = 'instance_types')
        , TRUE
        , '(System Description Not Provided)'
        , 'A Standard Instance Description'
        , '{"allowed_server_pools": ["primary"]}'::jsonb )
         ,
        ( 'instance_types_sml'
        , 'Instance Types / Small'
        , 'Small Instance'
        , (SELECT id FROM ms_syst_data.syst_enums WHERE internal_name = 'instance_types')
        , FALSE
        , '(System Description Not Provided)'
        , 'A Small Instance Description'
        , '{"allowed_server_pools": ["primary"]}'::jsonb );

    --
    -- Insert Instance Type Applications
    --

    INSERT INTO ms_syst_data.syst_instance_type_applications
        ( instance_type_id, application_id )
    SELECT
        sei.id
      , sa.id
    FROM ms_syst_data.syst_applications sa
    CROSS JOIN ( ms_syst_data.syst_enums se JOIN ms_syst_data.syst_enum_items sei
                 ON se.id = sei.enum_id )
    WHERE se.internal_name = 'instance_types' AND sei.internal_name != 'instance_types_std';

    --
    -- Update Instance Type Contexts
    --

    UPDATE ms_syst_data.syst_instance_type_contexts sitc
    SET
        default_db_pool_size = CASE
                                   WHEN it.instance_type_name = 'instance_types_big' AND
                                        it.login_context THEN 20
                                   WHEN it.instance_type_name = 'instance_types_sml' AND
                                        it.login_context THEN 3
                                   ELSE 0
                               END
    FROM ( SELECT
               sac.id            AS application_context_id
             , sac.login_context AS login_context
             , sita.id           AS instance_type_application_id
             , sei.internal_name AS instance_type_name
           FROM ms_syst_data.syst_application_contexts sac,
                ms_syst_data.syst_enums se
                    JOIN ms_syst_data.syst_enum_items sei ON sei.enum_id = se.id
                    JOIN ms_syst_data.syst_instance_type_applications sita ON sita.instance_type_id = sei.id
           WHERE se.internal_name = 'instance_types' ) it
    WHERE it.application_context_id = sitc.application_context_id AND it.instance_type_application_id = sitc.instance_type_application_id;

    --
    -- Create Instances
    --

    INSERT INTO ms_syst_data.syst_instances
        ( internal_name
        , display_name
        , application_id
        , instance_type_id
        , instance_state_id
        , owner_id
        , instance_code)
    SELECT
        sa.internal_name || '_' || so.internal_name || '_' || seiit.internal_name
      , sa.display_name || ' / ' || so.display_name || ' / ' || seiit.external_name
      , sa.id
      , seiit.id
      , seiis.id
      , so.id
      , gen_random_bytes(16)
    FROM ms_syst_data.syst_owners so, ms_syst_data.syst_applications sa
       , ms_syst_data.syst_enums seit
             JOIN ms_syst_data.syst_enum_items seiit
                  ON seit.internal_name = 'instance_types' AND seiit.enum_id = seit.id
       , ms_syst_data.syst_enums seis
             JOIN ms_syst_data.syst_enum_items seiis
                  ON seis.internal_name = 'instance_states' AND seiis.enum_id = seis.id
    WHERE
        CASE sa.internal_name
            WHEN 'app2' THEN
                seiis.internal_name = 'instance_states_sysdef_uninitialized'
            WHEN 'app1' THEN
                seiis.internal_name = 'instance_states_sysdef_active'
        END;

    UPDATE ms_syst_data.syst_instances upttarget
    SET owning_instance_id = owner.new_owning_instance_id
    FROM (SELECT
              si.id AS new_owning_instance_id
            , si.owner_id AS owner_id
            , si.application_id AS application_id
          FROM ms_syst_data.syst_instances si
            JOIN ms_syst_data.syst_enum_items sei
                ON sei.id = si.instance_type_id
          WHERE sei.internal_name = 'instance_types_big') owner,
        (SELECT
              si.id AS to_be_owned_instance_id
         FROM ms_syst_data.syst_instances si
            JOIN ms_syst_data.syst_enum_items sei
                ON sei.id = si.instance_type_id
         WHERE sei.internal_name = 'instance_types_sml') target
    WHERE upttarget.id             = target.to_be_owned_instance_id AND
          upttarget.owner_id       = owner.owner_id AND
          upttarget.application_id = owner.application_id;

END;
$INSTANCE_MGR_TESTING_INIT$;
