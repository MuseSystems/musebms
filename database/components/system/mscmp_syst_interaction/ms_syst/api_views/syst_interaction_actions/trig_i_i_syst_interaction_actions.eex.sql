CREATE OR REPLACE FUNCTION ms_syst.trig_i_i_syst_interaction_actions()
RETURNS trigger AS
$BODY$

-- File:        trig_i_i_syst_interaction_actions.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_interaction/ms_syst/api_views/syst_interaction_actions/trig_i_i_syst_interaction_actions.eex.sql
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

    IF
        (SELECT syst_defined AND NOT user_maintainable
         FROM ms_syst_data.syst_interaction_contexts
         WHERE id = new.interaction_context_id)
    THEN

        RAISE EXCEPTION
        USING
            MESSAGE = 'The parent Interaction Context is System Defined but ' ||
                      'is not User Maintainable, prohibiting the creation ' ||
                      'of new Interaction Action records using this API view.',
            DETAIL = ms_syst_priv.get_exception_details(
                         p_proc_schema    => 'ms_syst'
                        ,p_proc_name      => 'trig_i_i_syst_interaction_actions'
                        ,p_exception_name => 'invalid_api_view_call'
                        ,p_errcode        => 'PM008'
                        ,p_param_data     => to_jsonb(new)
                        ,p_context_data   =>
                            jsonb_build_object(
                                 'tg_op',         tg_op
                                ,'tg_when',       tg_when
                                ,'tg_schema',     tg_table_schema
                                ,'tg_table_name', tg_table_name)),
            ERRCODE = 'PM008',
            SCHEMA = tg_table_schema,
            TABLE = tg_table_name;

    END IF;

    INSERT INTO ms_syst_data.syst_interaction_actions
        ( interaction_context_id
        , internal_name
        , perm_id
        , interaction_category_id )
    VALUES
        ( new.interaction_context_id
        , new.internal_name
        , new.perm_id
        , new.interaction_category_id )
    RETURNING * INTO new;

    RETURN new;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO ms_syst, pg_temp;

ALTER FUNCTION ms_syst.trig_i_i_syst_interaction_actions()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_interaction_actions() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_interaction_actions() TO <%= ms_owner %>;

DO
$DOCUMENTATION$
DECLARE
    -- Function
    var_comments_config ms_syst_priv.comments_config_function;

BEGIN

    --
    -- Function Config
    --

    var_comments_config.function_schema := 'ms_syst';
    var_comments_config.function_name   := 'trig_i_i_syst_interaction_actions';

    var_comments_config.trigger_function := TRUE;
    var_comments_config.trigger_timing   := ARRAY [ 'i' ]::text[ ];
    var_comments_config.trigger_ops      := ARRAY [ 'i' ]::text[ ];

    var_comments_config.description :=
$DOC$Processes incoming API View requests according to globally applicable business
rules and data validation requirements.$DOC$;

    PERFORM ms_syst_priv.generate_comments_function( var_comments_config );

END;
$DOCUMENTATION$;
