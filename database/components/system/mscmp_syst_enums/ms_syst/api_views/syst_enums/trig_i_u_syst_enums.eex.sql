CREATE OR REPLACE FUNCTION ms_syst.trig_i_u_syst_enums()
RETURNS trigger AS
$BODY$

-- File:        trig_i_u_syst_enums.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_enums/ms_syst/api_views/syst_enums/trig_i_u_syst_enums.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

BEGIN

    IF old.syst_defined AND new.internal_name != old.internal_name THEN
        RAISE EXCEPTION
            USING
                MESSAGE = 'The requested data update included changes to fields disallowed ' ||
                          'by the business rules of the API View.',
                DETAIL = ms_syst_priv.get_exception_details(
                             p_proc_schema    => 'ms_syst'
                            ,p_proc_name      => 'trig_i_u_syst_enums'
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

    UPDATE ms_syst_data.syst_enums SET
          internal_name        = new.internal_name
        , display_name         = new.display_name
        , user_description     = new.user_description
        , default_user_options = new.default_user_options
    WHERE id = new.id
    RETURNING * INTO new;

    RETURN new;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO ms_syst, pg_temp;

ALTER FUNCTION ms_syst.trig_i_u_syst_enums()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_enums() FROM public;
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
     var_comments_config.function_name   := 'trig_i_u_syst_enums';
 
     var_comments_config.trigger_function := TRUE;
     var_comments_config.trigger_timing   := ARRAY [ 'i' ]::text[ ];
     var_comments_config.trigger_ops      := ARRAY [ 'u' ]::text[ ];
 
     var_comments_config.description :=
 $DOC$Processes incoming API View requests according to globally applicable business 
 rules and data validation requirements.$DOC$;
 
     PERFORM ms_syst_priv.generate_comments_function( var_comments_config );
 
 END;
 $DOCUMENTATION$;
