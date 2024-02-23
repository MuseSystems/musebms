-- File:        test_data_integration_test.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_interaction/testing_support/test_data_integration_test.eex.sql
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
$INTERACTION_INTEGRATION_TEST_INIT$
DECLARE
    var_data jsonb;

    var_category jsonb;
    var_context  jsonb;

BEGIN

    var_data := $TEST_DATA$
    {
      "interaction_categories": [
        {
          "internal_name": "cat_01",
          "display_name": "Interaction Category 01",
          "perm_id": "perm_1",
          "syst_defined": true,
          "syst_description": "A testing Interaction Category.",
          "user_description": null
        },
        {
          "internal_name": "cat_02",
          "display_name": "Interaction Category 02",
          "perm_id": "perm_4",
          "syst_defined": true,
          "syst_description": "A testing Interaction Category.",
          "user_description": null
        }
      ],
      "interaction_contexts": [
        {
          "internal_name": "context_01",
          "display_name": "Interaction Context 01",
          "interaction_category_id": "cat_01",
          "perm_id": null,
          "syst_defined": true,
          "user_maintainable": false,
          "syst_description": "A testing Interaction Context for Categorical Testing",
          "user_description": null,
          "state": [
            {
              "internal_name": "state_field_11",
              "perm_id": null,
              "interaction_category_id": null
            },
            {
              "internal_name": "state_field_12",
              "perm_id": null,
              "interaction_category_id": null
            },
            {
              "internal_name": "state_field_13",
              "perm_id": "perm_03",
              "interaction_category_id": null
            },
            {
              "internal_name": "state_field_14",
              "perm_id": null,
              "interaction_category_id": "cat_02"
            }
          ],
          "actions": [
            {
              "internal_name": "action_11",
              "perm_id": null,
              "interaction_category_id": null
            },
            {
              "internal_name": "action_12",
              "perm_id": null,
              "interaction_category_id": null
            },
            {
              "internal_name": "action_13",
              "perm_id": "perm_03",
              "interaction_category_id": null
            },
            {
              "internal_name": "action_14",
              "perm_id": null,
              "interaction_category_id": "cat_02"
            }
          ]
        },
        {
          "internal_name": "context_02",
          "display_name": "Interaction Context 02",
          "interaction_category_id": null,
          "perm_id": "perm_2",
          "syst_defined": true,
          "user_maintainable": false,
          "syst_description": "A testing Interaction Context for Perm Testing",
          "user_description": null,
          "state": [
            {
              "internal_name": "state_field_21",
              "perm_id": null,
              "interaction_category_id": null
            },
            {
              "internal_name": "state_field_22",
              "perm_id": null,
              "interaction_category_id": null
            },
            {
              "internal_name": "state_field_23",
              "perm_id": "perm_03",
              "interaction_category_id": null
            },
            {
              "internal_name": "state_field_24",
              "perm_id": null,
              "interaction_category_id": "cat_02"
            }
          ],
          "actions": [
            {
              "internal_name": "action_21",
              "perm_id": null,
              "interaction_category_id": null
            },
            {
              "internal_name": "action_22",
              "perm_id": null,
              "interaction_category_id": null
            },
            {
              "internal_name": "action_23",
              "perm_id": "perm_03",
              "interaction_category_id": null
            },
            {
              "internal_name": "action_24",
              "perm_id": null,
              "interaction_category_id": "cat_02"
            }
          ]
        }
      ]
    }
    $TEST_DATA$;

    << interaction_catagories_loop >>
    FOR var_category IN
        SELECT q FROM jsonb_array_elements( var_data -> 'interaction_categories') q
    LOOP

        INSERT INTO ms_syst_data.syst_interaction_categories
            ( internal_name
            , display_name
            , perm_id
            , syst_defined
            , syst_description
            , user_description )
        VALUES
            ( var_category ->> 'internal_name'
            , var_category ->> 'display_name'
            , ( SELECT id
                FROM ms_syst_data.syst_perms
                WHERE internal_name = var_category ->> 'perm_id' )
            , (var_category ->> 'syst_defined')::boolean
            , var_category ->> 'syst_description'
            , var_category ->> 'user_description' );

    END LOOP interaction_catagories_loop;

    << interaction_contexts_loop >>
    FOR var_context IN
        SELECT q FROM jsonb_array_elements( var_data -> 'interaction_contexts') q
    LOOP

        DECLARE
            var_context_id uuid;
            var_state      jsonb;
            var_action     jsonb;

        BEGIN

            INSERT INTO ms_syst_data.syst_interaction_contexts
                ( internal_name
                , display_name
                , interaction_category_id
                , perm_id
                , syst_defined
                , user_maintainable
                , syst_description
                , user_description )
            VALUES
                ( var_context ->> 'internal_name'
                , var_context ->> 'display_name'
                , ( SELECT id
                    FROM ms_syst_data.syst_interaction_categories
                    WHERE internal_name = var_context ->> 'interaction_category_id' )
                , ( SELECT id
                    FROM ms_syst_data.syst_perms
                    WHERE internal_name = var_context ->> 'perm_id' )
                , (var_context ->> 'syst_defined')::boolean
                , (var_context ->> 'user_maintainable')::boolean
                , var_context ->> 'syst_description'
                , var_context ->> 'user_description' )
            RETURNING id INTO var_context_id;

            << states_loop >>
            FOR var_state IN
                SELECT q FROM jsonb_array_elements( var_context -> 'states' ) q
            LOOP

                INSERT INTO ms_syst_data.syst_interaction_fields
                    (interaction_context_id, internal_name, perm_id, interaction_category_id)
                VALUES
                    ( var_context_id
                    , var_state ->> 'internal_name'
                    , ( SELECT id
                        FROM ms_syst_data.syst_perms
                        WHERE internal_name = var_state ->> 'perm_id' )
                    , ( SELECT id
                        FROM ms_syst_data.syst_interaction_categories
                        WHERE internal_name = var_state ->> 'interaction_category_id' ));

            END LOOP states_loop;

            << actions_loop >>
            FOR var_action IN
                SELECT q FROM jsonb_array_elements( var_context -> 'actions' ) q
            LOOP

                INSERT INTO ms_syst_data.syst_interaction_actions
                    (interaction_context_id, internal_name, perm_id, interaction_category_id)
                VALUES
                    ( var_context_id
                    , var_action ->> 'internal_name'
                    , ( SELECT id
                        FROM ms_syst_data.syst_perms
                        WHERE internal_name = var_action ->> 'perm_id' )
                    , ( SELECT id
                        FROM ms_syst_data.syst_interaction_categories
                        WHERE internal_name = var_action ->> 'interaction_category_id' ));

            END LOOP actions_loop;

        END;

    END LOOP interaction_contexts_loop;

END;
$INTERACTION_INTEGRATION_TEST_INIT$;
