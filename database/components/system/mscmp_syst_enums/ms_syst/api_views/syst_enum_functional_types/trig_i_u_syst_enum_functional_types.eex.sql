CREATE OR REPLACE FUNCTION ms_syst.trig_i_u_syst_enum_functional_types()
RETURNS trigger AS
$BODY$

-- File:        trig_i_u_syst_enum_functional_types.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_enums/ms_syst/api_views/syst_enum_functional_types/trig_i_u_syst_enum_functional_types.eex.sql
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
    IF
        (old.syst_defined AND old.internal_name != new.internal_name) OR
        old.enum_id != new.enum_id
    THEN
        RAISE EXCEPTION
            USING
                MESSAGE = 'The requested data update included changes to fields disallowed ' ||
                          'by the business rules of the API View.',
                DETAIL = ms_syst_priv.get_exception_details(
                             p_proc_schema    => 'ms_syst'
                            ,p_proc_name      => 'trig_i_u_syst_enum_functional_types'
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

    UPDATE ms_syst_data.syst_enum_functional_types
    SET
        internal_name    = new.internal_name
      , display_name     = new.display_name
      , external_name    = new.external_name
      , user_description = new.user_description
    WHERE id = new.id
    RETURNING INTO new
          id
        , internal_name
        , display_name
        , external_name
        , old.syst_defined
        , enum_id
        , syst_description
        , user_description
        , diag_timestamp_created
        , diag_role_created
        , diag_timestamp_modified
        , diag_wallclock_modified
        , diag_role_modified
        , diag_row_version
        , diag_update_count ;

    RAISE WARNING '======>>>>>>> New Func. Type: %', to_jsonb(new);

    RETURN new;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO ms_syst, pg_temp;

ALTER FUNCTION ms_syst.trig_i_u_syst_enum_functional_types()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_enum_functional_types() FROM public;

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
    var_comments_config.function_name   := 'trig_i_u_syst_enum_functional_types';

    var_comments_config.trigger_function := TRUE;
    var_comments_config.trigger_timing   := ARRAY [ 'i' ]::text[ ];
    var_comments_config.trigger_ops      := ARRAY [ 'u' ]::text[ ];

    var_comments_config.description :=
$DOC$Processes incoming API View requests according to globally applicable business
rules and data validation requirements.$DOC$;

    PERFORM ms_syst_priv.generate_comments_function( var_comments_config );

END;
$DOCUMENTATION$;
