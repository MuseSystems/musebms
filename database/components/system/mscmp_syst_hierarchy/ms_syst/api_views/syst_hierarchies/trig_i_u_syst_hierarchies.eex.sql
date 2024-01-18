CREATE OR REPLACE FUNCTION ms_syst.trig_i_u_syst_hierarchies()
RETURNS trigger AS
$BODY$

-- File:        trig_i_u_syst_hierarchies.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_hierarchy/ms_syst/api_views/syst_hierarchies/trig_i_u_syst_hierarchies.eex.sql
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
        ( old.syst_defined AND
            ( new.internal_name      != old.internal_name       OR
              new.display_name       != old.display_name        OR
              new.hierarchy_state_id != old.hierarchy_state_id  OR
              new.structured         != old.structured ) )
        OR
            new.hierarchy_type_id != old.hierarchy_type_id
    THEN

        RAISE EXCEPTION
            USING
                MESSAGE = 'The requested data update included changes to fields disallowed ' ||
                          'by the business rules of the API View.',
                DETAIL = ms_syst_priv.get_exception_details(
                             p_proc_schema    => 'ms_appl'
                            ,p_proc_name      => 'trig_i_u_syst_hierarchies'
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

    END IF;

    UPDATE ms_syst_data.syst_hierarchies
    SET
        internal_name      = new.internal_name
      , display_name       = new.display_name
      , hierarchy_state_id = new.hierarchy_state_id
      , structured         = new.structured
      , user_description   = new.user_description
    WHERE id = new.id
    RETURNING * INTO new;
END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO ms_appl, pg_temp;

ALTER FUNCTION ms_syst.trig_i_u_syst_hierarchies()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_hierarchies() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_hierarchies() TO <%= ms_owner %>;

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
    var_comments_config.function_name   := 'trig_i_u_syst_hierarchies';

    var_comments_config.trigger_function := TRUE;
    var_comments_config.trigger_timing   := ARRAY [ 'i' ]::text[ ];
    var_comments_config.trigger_ops      := ARRAY [ 'u' ]::text[ ];

    var_comments_config.description :=
$DOC$Processes incoming API View requests according to globally applicable business
rules and data validation requirements.$DOC$;

    PERFORM ms_syst_priv.generate_comments_function( var_comments_config );

END;
$DOCUMENTATION$;
