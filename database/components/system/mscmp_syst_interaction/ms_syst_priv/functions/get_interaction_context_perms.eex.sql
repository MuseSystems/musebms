CREATE OR REPLACE FUNCTION
    ms_syst_priv.get_interaction_context_perms(
        p_context_id   uuid DEFAULT NULL::uuid,
        p_context_name text DEFAULT NULL::text
    )
    RETURNS
        table
            ( context_name           text,
              context_perm           text,
              context_perms_required text[],
              context_actions        jsonb,
              context_fields         jsonb )
AS
$BODY$

-- File:        get_interaction_context_perms.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_interaction/ms_syst_priv/functions/get_interaction_context_perms.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

DECLARE
    v_base_query text :=
        'SELECT '
            'con.internal_name                                     AS context_name '
          ', coalesce( iperm.internal_name, icperm.internal_name ) AS context_perm '
          ', CASE '
                'WHEN NOT coalesce( iperm.internal_name, icperm.internal_name ) = ANY (perms.perms) THEN '
                    'perms.perms || coalesce( iperm.internal_name, icperm.internal_name ) '
                'ELSE '
                    'perms.perms '
            'END AS perms_required '
          ', actions.actions                                       AS context_actions '
          ', fields.fields                                         AS context_fields '
        'FROM '
            'ms_syst.syst_interaction_contexts con '
                'LEFT JOIN ms_syst.syst_perms iperm '
                          'ON iperm.id = con.perm_id '
                'LEFT JOIN ms_syst.syst_interaction_categories icat '
                          'ON icat.id = con.interaction_category_id '
                'LEFT JOIN ms_syst.syst_perms icperm '
                          'ON icperm.id = icat.perm_id '
                'LEFT JOIN LATERAL ( SELECT '
                                        'act.interaction_context_id '
                                      ', jsonb_object_agg( '
                                            'act.internal_name '
                                            ', jsonb_build_object( '
                                                '''specific_perm'', '
                                                'coalesce( aperm.internal_name, iperm.internal_name, '
                                                          'icperm.internal_name ) '
                                                ', ''categorical_perm'', cperm.internal_name ) ) AS actions '
                                    'FROM '
                                        'ms_syst.syst_interaction_actions act '
                                            'LEFT JOIN ms_syst.syst_perms aperm '
                                                      'ON aperm.id = act.perm_id '
                                            'LEFT JOIN ms_syst.syst_interaction_categories acat '
                                                      'ON acat.id = act.interaction_category_id '
                                            'LEFT JOIN ms_syst.syst_perms cperm '
                                                      'ON cperm.id = acat.perm_id '
                                    'WHERE act.interaction_context_id = con.id '
                                    'GROUP BY '
                                        'act.interaction_context_id ) actions '
                          'ON actions.interaction_context_id = con.id '
                'LEFT JOIN LATERAL ( SELECT '
                                        'fld.interaction_context_id '
                                      ', jsonb_object_agg( '
                                            'fld.internal_name '
                                            ', jsonb_build_object( '
                                                '''specific_perm'', '
                                                'coalesce( aperm.internal_name, iperm.internal_name, '
                                                          'icperm.internal_name ) '
                                                ', ''categorical_perm'', cperm.internal_name ) ) AS fields '
                                    'FROM '
                                        'ms_syst.syst_interaction_fields fld '
                                            'LEFT JOIN ms_syst.syst_perms aperm '
                                                      'ON aperm.id = fld.perm_id '
                                            'LEFT JOIN ms_syst.syst_interaction_categories fcat '
                                                      'ON fcat.id = fld.interaction_category_id '
                                            'LEFT JOIN ms_syst.syst_perms cperm '
                                                      'ON cperm.id = fcat.perm_id '
                                    'WHERE fld.interaction_context_id = con.id '
                                    'GROUP BY '
                                        'fld.interaction_context_id ) fields '
                          'ON fields.interaction_context_id = con.id '
                'LEFT JOIN LATERAL ( SELECT '
                                        'p.interaction_context_id '
                                      ', array_agg( internal_name ) AS perms '
                                    'FROM '
                                        '( SELECT '
                                              'act.interaction_context_id '
                                            ', aperm.internal_name '
                                          'FROM '
                                              'ms_syst.syst_interaction_actions act '
                                                  'JOIN ms_syst.syst_perms aperm '
                                                       'ON aperm.id = act.perm_id '
                                          'WHERE act.interaction_context_id = con.id '
                                          'UNION '
                                          'SELECT '
                                              'act.interaction_context_id '
                                            ', cperm.internal_name '
                                          'FROM '
                                              'ms_syst.syst_interaction_actions act '
                                                  'JOIN ms_syst.syst_interaction_categories acat '
                                                       'ON acat.id = act.interaction_category_id '
                                                  'JOIN ms_syst.syst_perms cperm '
                                                       'ON cperm.id = acat.perm_id '
                                          'WHERE act.interaction_context_id = con.id '
                                          'UNION '
                                          'SELECT '
                                              'fld.interaction_context_id '
                                            ', fperm.internal_name '
                                          'FROM '
                                              'ms_syst.syst_interaction_fields fld '
                                                  'JOIN ms_syst.syst_perms fperm '
                                                       'ON fperm.id = fld.perm_id '
                                          'WHERE fld.interaction_context_id = con.id '
                                          'UNION '
                                          'SELECT '
                                              'fld.interaction_context_id '
                                            ', cperm.internal_name '
                                          'FROM '
                                              'ms_syst.syst_interaction_fields fld '
                                                  'JOIN ms_syst.syst_interaction_categories fcat '
                                                       'ON fcat.id = fld.interaction_category_id '
                                                  'JOIN ms_syst.syst_perms cperm '
                                                       'ON cperm.id = fcat.perm_id '
                                          'WHERE fld.interaction_context_id = con.id ) p '
                                    'GROUP BY p.interaction_context_id ) perms '
                          'ON perms.interaction_context_id = con.id ';

    v_final_query text;
BEGIN

    v_final_query := v_base_query;

    IF p_context_id IS NOT NULL OR p_context_name IS NOT NULL THEN
        v_final_query := v_final_query || 'WHERE TRUE ';
    END IF;

    IF p_context_id IS NOT NULL THEN
        v_final_query :=
            v_final_query || format('AND con.id = %1$L ', p_context_id);
    END IF;

    IF p_context_name IS NOT NULL THEN
        v_final_query :=
            v_final_query ||
            format('AND con.internal_name = %1$L ', p_context_name);
    END IF;

    RETURN QUERY
        EXECUTE v_final_query;

END;
$BODY$
LANGUAGE plpgsql STABLE;

ALTER FUNCTION
    ms_syst_priv.get_interaction_context_perms( p_context_id uuid, p_context_name text )
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION
    ms_syst_priv.get_interaction_context_perms( p_context_id uuid, p_context_name text )
    FROM public;

GRANT EXECUTE ON FUNCTION
    ms_syst_priv.get_interaction_context_perms( p_context_id uuid, p_context_name text )
    TO <%= ms_owner %>;

DO
$DOCUMENTATION$
DECLARE
    -- Function
    v_comments_config ms_syst_priv.comments_config_function;

    -- Parameters

BEGIN

    --
    -- Function Config
    --

    v_comments_config.function_schema := 'ms_syst_priv';
    v_comments_config.function_name   := 'get_interaction_context_perms';

    v_comments_config.trigger_function := FALSE;
    v_comments_config.trigger_timing   := ARRAY [ ]::text[ ];
    v_comments_config.trigger_ops      := ARRAY [ ]::text[ ];

    v_comments_config.description :=
$DOC$$DOC$;

    v_comments_config.general_usage :=
$DOC$$DOC$;

    --
    -- Parameter Configs
    --



    v_comments_config.params :=
        ARRAY [ ]::ms_syst_priv.comments_config_function_param[];

    PERFORM ms_syst_priv.generate_comments_function( v_comments_config );

END;
$DOCUMENTATION$;
