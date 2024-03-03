CREATE OR REPLACE FUNCTION ms_syst.trig_i_i_syst_nav_actions()
RETURNS trigger AS
$BODY$

-- File:        trig_i_i_syst_nav_actions.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_nav/ms_syst/api_views/syst_nav_actions/trig_i_i_syst_nav_actions.eex.sql
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

    INSERT INTO ms_syst_data.syst_nav_actions
        ( internal_name
        , display_name
        , external_name
        , action_group_id
        , command
        , command_config
        , command_aliases
        , syst_defined
        , syst_description
        , user_maintainable
        , user_description )
    VALUES
        ( new.internal_name
        , new.display_name
        , new.external_name
        , new.action_group_id
        , new.command
        , new.command_config
        , new.command_aliases
        , FALSE
        , '( User Description Not Provided )'
        , TRUE
        , new.user_description )
    RETURNING * INTO new;

    RETURN new;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO ms_syst, pg_temp;

ALTER FUNCTION ms_syst.trig_i_i_syst_nav_actions()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_nav_actions() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_nav_actions() TO <%= ms_owner %>;

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
    var_comments_config.function_name   := 'trig_i_i_syst_nav_actions';

    var_comments_config.trigger_function := TRUE;
    var_comments_config.trigger_timing   := ARRAY [ 'i' ]::text[ ];
    var_comments_config.trigger_ops      := ARRAY [ 'i' ]::text[ ];

    var_comments_config.description :=
$DOC$Processes incoming API View requests according to globally applicable business
rules and data validation requirements.$DOC$;

    PERFORM ms_syst_priv.generate_comments_function( var_comments_config );

END;
$DOCUMENTATION$;