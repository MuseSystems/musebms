CREATE OR REPLACE FUNCTION ms_syst.trig_i_u_syst_nav_actions()
RETURNS trigger AS
$BODY$

-- File:        trig_i_u_syst_nav_actions.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_nav/ms_syst/api_views/syst_nav_actions/trig_i_u_syst_nav_actions.eex.sql
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

    var_exception_message text;
    var_exception_errcode text := 'PM008';

BEGIN

    CASE
        WHEN old.syst_defined AND new.internal_name != old.internal_name THEN
            var_exception_message :=
                'Prohibited update requested.  You may not change the ' ||
                'internal name value of System Defined records using this ' ||
                'API view.';

        WHEN old.syst_defined AND new.command != old.command THEN
            var_exception_message :=
                'Prohibited update requested.  You may not change the ' ||
                'Command value of a System Defined record using this API view.';

        WHEN old.syst_defined AND new.command_config != old.command_config THEN
            var_exception_message :=
                'Prohibited update requested.  You may not change the ' ||
                'Command Config value of a System Defined record using this ' ||
                'API view.';

        WHEN new.action_group_id != old.action_group_id THEN
            var_exception_message :=
                'This record may not be reassigned to a different parent ' ||
                'Action Group using this API view.';

        WHEN
            old.syst_defined AND
            NOT old.user_maintainable AND
            new.command_aliases != old.command_aliases
        THEN
            var_exception_message :=
                'Prohibited update requested.  The Command Aliases of a ' ||
                'System Defined record may only be changed using this API' ||
                'view when the record is also marked User Maintainable.';

        ELSE NULL;

    END CASE;

    IF var_exception_message IS NOT NULL THEN

        RAISE EXCEPTION
        USING
            MESSAGE = var_exception_message,
            DETAIL = ms_syst_priv.get_exception_details(
                         p_proc_schema    => 'ms_syst'
                        ,p_proc_name      => 'trig_i_u_syst_nav_actions'
                        ,p_exception_name => 'invalid_api_view_call'
                        ,p_errcode        => var_exception_errcode
                        ,p_param_data     =>
                            jsonb_build_object( 'old', old, 'new', new)
                        ,p_context_data   =>
                            jsonb_build_object(
                                 'tg_op',         tg_op
                                ,'tg_when',       tg_when
                                ,'tg_schema',     tg_table_schema
                                ,'tg_table_name', tg_table_name)),
            ERRCODE = var_exception_errcode,
            SCHEMA = tg_table_schema,
            TABLE = tg_table_name;

    END IF;

    UPDATE ms_syst_data.syst_nav_actions
    SET
        internal_name    = new.internal_name
      , display_name     = new.display_name
      , external_name    = new.external_name
      , command          = new.command
      , command_config   = new.command_config
      , command_aliases  = new.command_aliases
      , user_description = new.user_description
    WHERE id = new.id
    RETURNING * INTO new;

    RETURN new;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO ms_syst, pg_temp;

ALTER FUNCTION ms_syst.trig_i_u_syst_nav_actions()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_nav_actions() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_nav_actions() TO <%= ms_owner %>;

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
    var_comments_config.function_name   := 'trig_i_u_syst_nav_actions';

    var_comments_config.trigger_function := TRUE;
    var_comments_config.trigger_timing   := ARRAY [ 'i' ]::text[ ];
    var_comments_config.trigger_ops      := ARRAY [ 'u' ]::text[ ];

    var_comments_config.description :=
$DOC$Processes incoming API View requests according to globally applicable business
rules and data validation requirements.$DOC$;

    PERFORM ms_syst_priv.generate_comments_function( var_comments_config );

END;
$DOCUMENTATION$;
