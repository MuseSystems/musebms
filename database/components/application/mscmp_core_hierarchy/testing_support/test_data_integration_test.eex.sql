-- File:        test_data_integration_test.eex.sql
-- Location:    musebms/database/components/application/mscmp_core_hierarchy/testing_support/test_data_integration_test.eex.sql
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
$HIERACHY_TESTING_INIT$
DECLARE
    var_data              jsonb;
    var_hierachy_states   record;

    var_enum_id           uuid;

    var_enum_func_type    record;
    var_enum_func_type_id uuid;

    var_enum_item         record;
    var_enum_item_id      uuid;

    var_hierarchy         record;
    var_hierarchy_id      uuid;

    var_hierarchy_item    record;

BEGIN

    /**********************************************************************
     **
     **  Test Data Description
     **
     **********************************************************************/
    var_enum_id :=
        ( SELECT id FROM ms_syst_data.syst_enums WHERE internal_name = 'hierarchy_types' );

    var_data := $TEST_DATA_DEFINITIONS$
    []
    $TEST_DATA_DEFINITIONS$;

    SELECT INTO var_hierachy_states
        ( SELECT id
          FROM ms_syst_data.syst_enum_items
          WHERE internal_name = 'hierarchy_states_sysdef_active' )   AS active_id
      , ( SELECT id
          FROM ms_syst_data.syst_enum_items
          WHERE internal_name = 'hierarchy_states_sysdef_inactive' ) AS inactive_id;

    /**********************************************************************
     **
     **  Test Data Creation
     **
     **********************************************************************/

    << enum_functional_types_loop >>
    FOR var_enum_func_type IN
        SELECT
            eft ->> 'internal_name'    AS internal_name
          , eft ->> 'display_name'     AS display_name
          , eft ->> 'external_name'    AS external_name
          , eft ->> 'syst_description' AS syst_description
          , eft -> 'enum_items'        AS enum_items
        FROM jsonb_array_elements( var_data ) eft
    LOOP
        INSERT INTO ms_syst_data.syst_enum_functional_types
            ( internal_name, display_name, external_name, enum_id, syst_description )
        VALUES
            ( var_enum_func_type.internal_name
            , var_enum_func_type.display_name
            , var_enum_func_type.external_name
            , var_enum_id
            , var_enum_func_type.syst_description )
        RETURNING id INTO var_enum_func_type_id;

        << enum_items_loop >>
        FOR var_enum_item IN
            SELECT
                ei ->> 'internal_name'                      AS internal_name
              , ei ->> 'display_name'                       AS display_name
              , ei ->> 'external_name'                      AS external_name
              , (ei ->> 'enum_default')::boolean            AS enum_default
              , (ei ->> 'functional_type_default')::boolean AS functional_type_default
              , (ei ->> 'syst_defined')::boolean            AS syst_defined
              , (ei ->> 'user_maintainable')::boolean       AS user_maintainable
              , ei ->> 'syst_description'                   AS syst_description
              , ei -> 'syst_options'                        AS syst_options
              , ei ->> 'sort_order'                         AS sort_order
              , ei -> 'hierarchies'                         AS hierarchies
            FROM jsonb_array_elements( var_enum_func_type.enum_items ) ei

        LOOP
            INSERT INTO ms_syst_data.syst_enum_items
                ( internal_name
                , display_name
                , external_name
                , enum_id
                , functional_type_id
                , enum_default
                , functional_type_default
                , syst_defined
                , user_maintainable
                , syst_description
                , syst_options
                , sort_order )
            VALUES
                ( var_enum_item.internal_name
                , var_enum_item.display_name
                , var_enum_item.external_name
                , var_enum_id
                , var_enum_func_type_id
                , var_enum_item.enum_default
                , var_enum_item.functional_type_default
                , var_enum_item.syst_defined
                , var_enum_item.user_maintainable
                , var_enum_item.syst_description
                , var_enum_item.syst_options
                , var_enum_item.sort_order )
            RETURNING id INTO var_enum_item_id;

            << hierarchies_loop >>
            FOR var_hierarchy IN
                SELECT
                    h ->> 'internal_name'                AS internal_name
                  , h ->> 'display_name'                 AS display_name
                  , (h ->> 'syst_defined')::boolean      AS syst_defined
                  , (h ->> 'user_maintainable')::boolean AS user_maintainable
                  , h ->> 'syst_description'             AS syst_description
                  , h ->> 'user_description'             AS user_description
                  , (h ->> 'structured')::boolean        AS structured
                  , h -> 'hierarchy_items'               AS hierarchy_items
                FROM jsonb_array_elements( var_enum_item.hierarchies) h
            LOOP
                INSERT INTO ms_appl_data.conf_hierarchies
                    ( internal_name
                    , display_name
                    , hierarchy_type_id
                    , hierarchy_state_id
                    , syst_defined
                    , user_maintainable
                    , structured
                    , syst_description
                    , user_description )
                VALUES
                    ( var_hierarchy.internal_name
                    , var_hierarchy.display_name
                    , var_enum_item_id
                    , var_hierachy_states.inactive_id
                    , var_hierarchy.syst_defined
                    , var_hierarchy.user_maintainable
                    , var_hierarchy.structured
                    , var_hierarchy.syst_description
                    , var_hierarchy.user_description )
                RETURNING id INTO var_hierarchy_id;

                << hierarchy_items_loops >>
                FOR var_hierarchy_item IN
                    SELECT
                        hi ->> 'internal_name'               AS internal_name
                      , hi ->> 'display_name'                AS display_name
                      , hi ->> 'external_name'               AS external_name
                      , (hi ->> 'hierarchy_depth')::smallint AS hierarchy_depth
                      , (hi ->> 'required')::boolean         AS required
                      , (hi ->> 'allow_leaf_nodes')::boolean  AS allow_leaf_nodes
                    FROM jsonb_array_elements( var_hierarchy.hierarchy_items ) hi
                LOOP
                    INSERT INTO ms_appl_data.conf_hierarchy_items
                        (internal_name
                        ,display_name
                        ,external_name
                        ,hierarchy_id
                        ,hierarchy_depth
                        ,required
                        ,allow_leaf_nodes)
                    VALUES
                    (var_hierarchy_item.internal_name
                    ,var_hierarchy_item.display_name
                    ,var_hierarchy_item.external_name
                    ,var_hierarchy_id
                    ,var_hierarchy_item.hierarchy_depth
                    ,var_hierarchy_item.required
                    ,var_hierarchy_item.allow_leaf_nodes);

                END LOOP hierarchy_items_loops;

                UPDATE ms_appl_data.conf_hierarchies
                SET hierarchy_state_id = var_hierachy_states.active_id
                WHERE id = var_hierarchy_id;

            END LOOP hierarchies_loop;

        END LOOP enum_items_loop;

    END LOOP enum_functional_types_loop;

END;
$HIERACHY_TESTING_INIT$;
