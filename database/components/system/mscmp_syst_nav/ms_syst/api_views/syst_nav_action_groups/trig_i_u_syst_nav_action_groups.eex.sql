CREATE OR REPLACE FUNCTION ms_syst.trig_i_u_syst_nav_action_groups()
RETURNS trigger AS
$BODY$

-- File:        trig_i_u_syst_nav_action_groups.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_nav/ms_syst/api_views/syst_nav_action_groups/trig_i_u_syst_nav_action_groups.eex.sql
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

    IF old.syst_defined AND new.internal_name != old.internal_name THEN

        RAISE EXCEPTION
        USING
            MESSAGE = 'Prohibited update.  The record is System Defined ' ||
                      'which disallows internal name changes.',
            DETAIL = ms_syst_priv.get_exception_details(
                         p_proc_schema    => 'ms_syst'
                        ,p_proc_name      => 'trig_i_u_syst_nav_action_groups'
                        ,p_exception_name => 'invalid_api_view_call'
                        ,p_errcode        => 'PM008'
                        ,p_param_data     =>
                            jsonb_build_object( 'old', old, 'new', new)
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

    IF
        old.syst_defined AND
            NOT old.user_maintainable AND
            new.command_aliases != old.command_aliases
    THEN

        RAISE EXCEPTION
        USING
            MESSAGE = 'Prohibited update.  The Command Aliases of System ' ||
                      'Defined records may only be updated when also marked ' ||
                      'as User Maintainable.',
            DETAIL = ms_syst_priv.get_exception_details(
                         p_proc_schema    => 'ms_syst'
                        ,p_proc_name      => 'trig_i_u_syst_nav_action_groups'
                        ,p_exception_name => 'invalid_api_view_call'
                        ,p_errcode        => 'PM008'
                        ,p_param_data     =>
                            jsonb_build_object( 'old', old, 'new', new)
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

    UPDATE ms_syst_data.syst_nav_action_groups
    SET
        internal_name    = new.internal_name
      , display_name     = new.display_name
      , external_name    = new.external_name
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

ALTER FUNCTION ms_syst.trig_i_u_syst_nav_action_groups()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_nav_action_groups() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_nav_action_groups() TO <%= ms_owner %>;

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
    var_comments_config.function_name   := 'trig_i_u_syst_nav_action_groups';

    var_comments_config.trigger_function := TRUE;
    var_comments_config.trigger_timing   := ARRAY [ 'i' ]::text[ ];
    var_comments_config.trigger_ops      := ARRAY [ 'u' ]::text[ ];

    var_comments_config.description :=
$DOC$Processes incoming API View requests according to globally applicable business
rules and data validation requirements.$DOC$;

    PERFORM ms_syst_priv.generate_comments_function( var_comments_config );

END;
$DOCUMENTATION$;
