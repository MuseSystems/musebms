CREATE OR REPLACE FUNCTION ms_syst.trig_i_u_syst_sessions()
RETURNS trigger AS
$BODY$

-- File:        trig_i_u_syst_sessions.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_session/ms_syst/api_views/syst_sessions/trig_i_u_syst_sessions.eex.sql
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
        WHEN new.internal_name != old.internal_name THEN

            RAISE EXCEPTION
                USING
                    MESSAGE = 'The requested data update included changes to fields disallowed ' ||
                              'by the business rules of the API View.',
                    DETAIL = ms_syst_priv.get_exception_details(
                                 p_proc_schema    => 'ms_syst'
                                ,p_proc_name      => 'trig_i_u_syst_sessions'
                                ,p_exception_name => 'invalid_api_view_call'
                                ,p_errcode        => 'PM008'
                                ,p_param_data     => jsonb_build_object('new', new, 'old', old)
                                ,p_context_data   =>
                                    jsonb_build_object(
                                         'tg_op',         tg_op
                                        ,'tg_when',       tg_when
                                        ,'tg_schema',     tg_table_schema
                                        ,'tg_table_name', tg_table_name)),
                    ERRCODE = 'PM008',
                    SCHEMA = tg_table_schema,
                    TABLE = tg_table_name;

        WHEN new.session_expires < now() THEN

            RAISE EXCEPTION
                USING
                    MESSAGE = 'The syst_sessions record may not be updated after the ' ||
                              'session_expires date/time is past.',
                    DETAIL = ms_syst_priv.get_exception_details(
                                 p_proc_schema    => 'ms_syst'
                                ,p_proc_name      => 'trig_i_u_syst_sessions'
                                ,p_exception_name => 'invalid_api_view_call'
                                ,p_errcode        => 'PM008'
                                ,p_param_data     => jsonb_build_object('new', new, 'old', old)
                                ,p_context_data   =>
                                    jsonb_build_object(
                                         'tg_op',         tg_op
                                        ,'tg_when',       tg_when
                                        ,'tg_schema',     tg_table_schema
                                        ,'tg_table_name', tg_table_name)),
                    ERRCODE = 'PM008',
                    SCHEMA = tg_table_schema,
                    TABLE = tg_table_name;

        ELSE

            UPDATE ms_syst_data.syst_sessions
            SET
                session_data    = new.session_data
              , session_expires = new.session_expires
            WHERE id = new.id
            RETURNING * INTO new;

            RETURN new;

    END CASE;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO ms_syst, pg_temp;

ALTER FUNCTION ms_syst.trig_i_u_syst_sessions()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_sessions() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_sessions() TO <%= ms_owner %>;

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
    var_comments_config.function_name   := 'trig_i_u_syst_sessions';

    var_comments_config.trigger_function := TRUE;
    var_comments_config.trigger_timing   := ARRAY [ 'i' ]::text[ ];
    var_comments_config.trigger_ops      := ARRAY [ 'u' ]::text[ ];

    var_comments_config.description :=
$DOC$Processes incoming API View requests according to globally applicable business
rules and data validation requirements.$DOC$;

    PERFORM ms_syst_priv.generate_comments_function( var_comments_config );

END;
$DOCUMENTATION$;
