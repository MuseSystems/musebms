CREATE OR REPLACE FUNCTION ms_syst_data.trig_b_u_syst_hierarchies_validate_structured()
RETURNS trigger AS
$BODY$

-- File:        trig_b_u_syst_hierarchies_validate_structured.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_hierarchy/ms_syst_data/syst_hierarchies/trig_b_u_syst_hierarchies_validate_structured.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

BEGIN

    CASE
        WHEN
            new.structured != old.structured
                AND ( SELECT eft.internal_name = 'hierarchy_states_active'
                      FROM ms_syst_data.syst_enum_items ei
                          JOIN ms_syst_data.syst_enum_functional_types eft
                              ON eft.id = ei.functional_type_id
                      WHERE ei.id = new.hierarchy_state_id )
        THEN

            RAISE EXCEPTION
                USING
                    MESSAGE = 'The "structured" value of the Hierarchy may ' ||
                              'only be changed when the Hierarchy is in an ' ||
                              '"inactive" state.',
                    DETAIL  = ms_syst_priv.get_exception_details(
                                 p_proc_schema    => 'ms_appl_data'
                                ,p_proc_name      =>
                                    'trig_b_u_syst_hierarchies_validate_structured'
                                ,p_exception_name => 'invalid_state'
                                ,p_errcode        => 'PM003'
                                ,p_param_data     =>
                                    jsonb_build_object('new', new, 'old', old)
                                ,p_context_data   =>
                                    jsonb_build_object(
                                         'tg_op',         tg_op
                                        ,'tg_when',       tg_when
                                        ,'tg_schema',     tg_table_schema
                                        ,'tg_table_name', tg_table_name)),
                    ERRCODE = 'PM003',
                    SCHEMA  = tg_table_schema,
                    TABLE   = tg_table_name;

        WHEN
            old.structured
                AND NOT new.structured
                AND exists( SELECT TRUE
                            FROM ms_syst_data.syst_hierarchy_items chi
                            WHERE chi.hierarchy_id = new.id )
        THEN

            RAISE EXCEPTION
                USING
                    MESSAGE = 'Unstructured Hierarchies should not have ' ||
                              'structuring Hierarchy Item records.',
                    DETAIL  = ms_syst_priv.get_exception_details(
                                 p_proc_schema    => 'ms_appl_data'
                                ,p_proc_name      =>
                                    'trig_b_u_syst_hierarchies_validate_structured'
                                ,p_exception_name => 'invalid_state'
                                ,p_errcode        => 'PM003'
                                ,p_param_data     =>
                                    jsonb_build_object('new', new, 'old', old)
                                ,p_context_data   =>
                                    jsonb_build_object(
                                         'tg_op',         tg_op
                                        ,'tg_when',       tg_when
                                        ,'tg_schema',     tg_table_schema
                                        ,'tg_table_name', tg_table_name)),
                    ERRCODE = 'PM003',
                    SCHEMA  = tg_table_schema,
                    TABLE   = tg_table_name;

    ELSE

        RETURN new;

    END CASE;


END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE;

ALTER FUNCTION ms_syst_data.trig_b_u_syst_hierarchies_validate_structured()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst_data.trig_b_u_syst_hierarchies_validate_structured() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst_data.trig_b_u_syst_hierarchies_validate_structured() TO <%= ms_owner %>;

DO
$DOCUMENTATION$
DECLARE
    -- Function
    var_comments_config ms_syst_priv.comments_config_function;

BEGIN

    --
    -- Function Config
    --

    var_comments_config.function_schema := 'ms_syst_data';
    var_comments_config.function_name   := 'trig_b_u_syst_hierarchies_validate_structured';

    var_comments_config.trigger_function := TRUE;
    var_comments_config.trigger_timing   := ARRAY [ 'b' ]::text[ ];
    var_comments_config.trigger_ops      := ARRAY [ 'u' ]::text[ ];

    var_comments_config.description :=
$DOC$A trigger function which ensures that changing a hierarchy between being
"structured" and "unstructured" is only possible when the Hierarchy record is
in an "inactive" state.$DOC$;

    PERFORM ms_syst_priv.generate_comments_function( var_comments_config );

END;
$DOCUMENTATION$;
