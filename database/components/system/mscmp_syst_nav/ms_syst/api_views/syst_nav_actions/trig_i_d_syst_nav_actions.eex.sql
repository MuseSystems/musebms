CREATE OR REPLACE FUNCTION ms_syst.trig_i_d_syst_nav_actions()
RETURNS trigger AS
$BODY$

-- File:        trig_i_d_syst_nav_actions.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_nav/ms_syst/api_views/syst_nav_actions/trig_i_d_syst_nav_actions.eex.sql
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

    IF old.syst_defined THEN

        RAISE EXCEPTION
        USING
            MESSAGE = 'Prohibited delete requested.  System Defined ' ||
                      'Navigation Action records may not be deleted ' ||
                      'using this API view.',
            DETAIL = ms_syst_priv.get_exception_details(
                         p_proc_schema    => 'ms_syst'
                        ,p_proc_name      => 'trig_i_d_syst_nav_actions'
                        ,p_param_data     => to_jsonb(old)
                        ,p_context_data   =>
                            jsonb_build_object(
                                 'tg_op',         tg_op
                                ,'tg_when',       tg_when
                                ,'tg_schema',     tg_table_schema
                                ,'tg_table_name', tg_table_name)),
            ERRCODE = 'PM003',
            SCHEMA = tg_table_schema,
            TABLE = tg_table_name;

    END IF;

    DELETE
    FROM ms_syst_data.syst_nav_actions
    WHERE id = old.id
    RETURNING * INTO old;

    RETURN old;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO ms_syst, pg_temp;

ALTER FUNCTION ms_syst.trig_i_d_syst_nav_actions()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_nav_actions() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_nav_actions() TO <%= ms_owner %>;

DO
$DOCUMENTATION$
DECLARE
    -- Function
    v_comments_config ms_syst_priv.comments_config_function;

BEGIN

    --
    -- Function Config
    --

    v_comments_config.function_schema := 'ms_syst';
    v_comments_config.function_name   := 'trig_i_d_syst_nav_actions';

    v_comments_config.trigger_function := TRUE;
    v_comments_config.trigger_timing   := ARRAY [ 'i' ]::text[ ];
    v_comments_config.trigger_ops      := ARRAY [ 'd' ]::text[ ];

    v_comments_config.description :=
$DOC$Processes incoming API View requests according to globally applicable business
rules and data validation requirements.$DOC$;

    PERFORM ms_syst_priv.generate_comments_function( v_comments_config );

END;
$DOCUMENTATION$;
