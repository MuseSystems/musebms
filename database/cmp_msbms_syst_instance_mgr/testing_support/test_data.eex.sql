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
BEGIN

    --
    --  Applications
    --

    INSERT INTO msbms_syst_data.syst_applications
        ( internal_name, display_name, syst_description )
    VALUES
        ( 'app2', 'App 2', 'App Two Description' )
         ,
        ( 'app1', 'App 1', 'App One Description' );

    --
    -- Application Contexts
    --

    INSERT INTO msbms_syst_data.syst_application_contexts
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
            FROM msbms_syst_data.syst_applications
            WHERE internal_name = 'app1' )
        , 'App 1 Owner'
        , FALSE
        , FALSE
        , TRUE )

         ,
        ( 'app1_appusr'
        , 'App 1 AppUsr'
        , ( SELECT id
            FROM msbms_syst_data.syst_applications
            WHERE internal_name = 'app1' )
        , 'App 1 AppUsr'
        , TRUE
        , TRUE
        , FALSE )

         ,
        ( 'app1_apiusr'
        , 'App 1 ApiUsr'
        , ( SELECT id
            FROM msbms_syst_data.syst_applications
            WHERE internal_name = 'app1' )
        , 'App 1 API user Context'
        , TRUE
        , TRUE
        , FALSE )

         ,
        ( 'app2_owner'
        , 'App 2 Owner'
        , ( SELECT id
            FROM msbms_syst_data.syst_applications
            WHERE internal_name = 'app2' )
        , 'App 2 Owner'
        , FALSE
        , FALSE
        , TRUE )

         ,
        ( 'app2_appusr'
        , 'App 2 AppUsr'
        , ( SELECT id
            FROM msbms_syst_data.syst_applications
            WHERE internal_name = 'app2' )
        , 'App 2 App'
        , TRUE
        , TRUE
        , FALSE )

         ,
        ( 'app2_apiusr'
        , 'App 2 ApiUsr'
        , ( SELECT id
            FROM msbms_syst_data.syst_applications
            WHERE internal_name = 'app2' )
        , 'App 2 API'
        , TRUE
        , TRUE
        , FALSE );


    --
    --  Owners
    --

    INSERT INTO msbms_syst_data.syst_owners
        ( internal_name, display_name, owner_state_id )
    VALUES
        ( 'owner4', 'Owner 4 Inactive', ( SELECT id
                                          FROM msbms_syst_data.syst_enum_items
                                          WHERE internal_name = 'owner_states_sysdef_inactive' ) )

         ,
        ( 'owner3', 'Owner 3 Active', ( SELECT id
                                        FROM msbms_syst_data.syst_enum_items
                                        WHERE internal_name = 'owner_states_sysdef_active' ) )

         ,
        ( 'owner1', 'Owner 1 Active', ( SELECT id
                                        FROM msbms_syst_data.syst_enum_items
                                        WHERE internal_name = 'owner_states_sysdef_active' ) )

         ,
        ( 'owner2', 'Owner 2 Inactive', ( SELECT id
                                          FROM msbms_syst_data.syst_enum_items
                                          WHERE internal_name = 'owner_states_sysdef_inactive' ) );


    --
    -- Create Instance Types.
    --

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
        ( 'instance_types_big'
        , 'Instance Types / Big'
        , 'Big Instance'
        , (SELECT id FROM msbms_syst_data.syst_enums WHERE internal_name = 'instance_types')
        , FALSE
        , '(System Description Not Provided)'
        , 'A Big Instance Description'
        , '{"allowed_server_pools": ["primary"]}'::jsonb )
         ,
        ( 'instance_types_std'
        , 'Instance Types / Standard'
        , 'Standard Instance'
        , (SELECT id FROM msbms_syst_data.syst_enums WHERE internal_name = 'instance_types')
        , TRUE
        , '(System Description Not Provided)'
        , 'A Standard Instance Description'
        , '{"allowed_server_pools": ["primary"]}'::jsonb )
         ,
        ( 'instance_types_sml'
        , 'Instance Types / Small'
        , 'Small Instance'
        , (SELECT id FROM msbms_syst_data.syst_enums WHERE internal_name = 'instance_types')
        , FALSE
        , '(System Description Not Provided)'
        , 'A Small Instance Description'
        , '{"allowed_server_pools": ["primary"]}'::jsonb );

    --
    -- Insert Instance Type Applications
    --

    INSERT INTO msbms_syst_data.syst_instance_type_applications
        ( instance_type_id, application_id )
    SELECT
        sei.id
      , sa.id
    FROM msbms_syst_data.syst_applications sa
    CROSS JOIN ( msbms_syst_data.syst_enums se JOIN msbms_syst_data.syst_enum_items sei
                 ON se.id = sei.enum_id )
    WHERE se.internal_name = 'instance_types';

    --
    -- Update Instance Type Contexts
    --

    UPDATE msbms_syst_data.syst_instance_type_contexts sitc
    SET
        default_db_pool_size = CASE
                                   WHEN it.instance_type_name = 'instance_types_big' AND
                                        it.login_context THEN 20
                                   WHEN it.instance_type_name = 'instance_types_std' AND
                                        it.login_context THEN 10
                                   WHEN it.instance_type_name = 'instance_types_sml' AND
                                        it.login_context THEN 3
                                   ELSE 0
                               END
    FROM ( SELECT
               sac.id            AS application_context_id
             , sac.login_context AS login_context
             , sita.id           AS instance_type_application_id
             , sei.internal_name AS instance_type_name
           FROM msbms_syst_data.syst_application_contexts sac,
                msbms_syst_data.syst_enums se
                    JOIN msbms_syst_data.syst_enum_items sei ON sei.enum_id = se.id
                    JOIN msbms_syst_data.syst_instance_type_applications sita ON sita.instance_type_id = sei.id
           WHERE se.internal_name = 'instance_types' ) it
    WHERE it.application_context_id = sitc.application_context_id AND it.instance_type_application_id = sitc.instance_type_application_id;

    --
    -- Create Instances
    --

    INSERT INTO msbms_syst_data.syst_instances
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
    FROM msbms_syst_data.syst_owners so, msbms_syst_data.syst_applications sa
       , msbms_syst_data.syst_enums seit
             JOIN msbms_syst_data.syst_enum_items seiit
                  ON seit.internal_name = 'instance_types' AND seiit.enum_id = seit.id
       , msbms_syst_data.syst_enums seis
             JOIN msbms_syst_data.syst_enum_items seiis
                  ON seis.internal_name = 'instance_states' AND seiis.enum_id = seis.id
    WHERE
        CASE sa.internal_name
            WHEN 'app2' THEN
                seiis.internal_name = 'instance_states_sysdef_uninitialized'
            WHEN 'app1' THEN
                seiis.internal_name = 'instance_states_sysdef_active'
        END;

    UPDATE msbms_syst_data.syst_instances upttarget
    SET owning_instance_id = owner.new_owning_instance_id
    FROM (SELECT
              si.id AS new_owning_instance_id
            , si.owner_id AS owner_id
            , si.application_id AS application_id
          FROM msbms_syst_data.syst_instances si
            JOIN msbms_syst_data.syst_enum_items sei
                ON sei.id = si.instance_type_id
          WHERE sei.internal_name = 'instance_types_big') owner,
        (SELECT
              si.id AS to_be_owned_instance_id
         FROM msbms_syst_data.syst_instances si
            JOIN msbms_syst_data.syst_enum_items sei
                ON sei.id = si.instance_type_id
         WHERE sei.internal_name = 'instance_types_sml') target
    WHERE upttarget.id             = target.to_be_owned_instance_id AND
          upttarget.owner_id       = owner.owner_id AND
          upttarget.application_id = owner.application_id;

    --
    -- Create Instance Contexts
    --

    INSERT INTO msbms_syst_data.syst_instance_contexts
    ( internal_name
    , display_name
    , instance_id
    , application_context_id
    , start_context
    , db_pool_size
    , context_code)
    SELECT
        sac.internal_name || '_' || so.internal_name || '_' || si.internal_name
      , sac.display_name || ' / ' || si.display_name
      , si.id
      , sac.id
      , sac.start_context
      , CASE
          WHEN si.internal_name = 'instance_types_std' THEN
            round(sitc.default_db_pool_size::numeric / 2.0)::integer
          ELSE
            sitc.default_db_pool_size
        END
      , gen_random_bytes(16)
    FROM msbms_syst_data.syst_instances si
        JOIN msbms_syst_data.syst_owners so
            ON so.id = si.owner_id
        JOIN msbms_syst_data.syst_application_contexts sac
            ON sac.application_id = si.application_id
        JOIN msbms_syst_data.syst_instance_type_applications sita
            ON sita.application_id = si.application_id AND sita.instance_type_id = si.instance_type_id
        JOIN msbms_syst_data.syst_enum_items sei
            ON sei.id = sita.instance_type_id
        JOIN msbms_syst_data.syst_instance_type_contexts sitc
            ON sitc.instance_type_application_id = sita.id AND sitc.application_context_id = sac.id;

END;
$INSTANCE_MGR_TESTING_INIT$;
