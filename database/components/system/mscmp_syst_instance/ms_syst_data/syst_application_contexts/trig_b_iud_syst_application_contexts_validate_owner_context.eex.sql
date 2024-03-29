CREATE OR REPLACE FUNCTION ms_syst_data.trig_b_iud_syst_application_contexts_validate_owner_context()
RETURNS trigger AS
$BODY$

-- File:        trig_b_iud_syst_application_contexts_validate_owner_context.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_instance/ms_syst_data/syst_application_contexts/trig_b_iud_syst_application_contexts_validate_owner_context.eex.sql
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

    IF tg_op = 'DELETE' THEN

        IF old.database_owner_context THEN
            RAISE EXCEPTION
                USING
                    MESSAGE = 'You may not delete the designated database owner ' ||
                              'context for an Application from the database.',
                    DETAIL = ms_syst_priv.get_exception_details(
                                 p_proc_schema    => 'ms_syst_data'
                                ,p_proc_name      => 'trig_b_iud_syst_application_contexts_validate_owner_context'
                                ,p_exception_name => 'invalid_duplicate'
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

        RETURN old;

    END IF;

    IF tg_op = 'UPDATE' THEN

        IF
            new.database_owner_context != old.database_owner_context
        THEN
            RAISE EXCEPTION
                USING
                    MESSAGE = 'The database owner context designation may ' ||
                              'only be set on INSERT.',
                    DETAIL = ms_syst_priv.get_exception_details(
                                 p_proc_schema    => 'ms_syst'
                                ,p_proc_name      => 'trig_b_iud_syst_application_contexts_validate_owner_context'
                                ,p_exception_name => 'invalid_duplicate'
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

    END IF;

    IF tg_op IN ('INSERT', 'UPDATE') THEN

        -- There may only be one database owner context for any one application.
        IF
            new.database_owner_context AND
            exists( SELECT
                        TRUE
                    FROM ms_syst_data.syst_application_contexts sac
                    WHERE
                          sac.application_id = new.application_id
                      AND sac.id != new.id
                      AND sac.database_owner_context)
        THEN
            RAISE EXCEPTION
                USING
                    MESSAGE = 'Each Application may only have one Application Context ' ||
                              'defined as being the database owner.',
                    DETAIL = ms_syst_priv.get_exception_details(
                                 p_proc_schema    => 'ms_syst'
                                ,p_proc_name      => 'trig_b_iud_syst_application_contexts_validate_owner_context'
                                ,p_exception_name => 'invalid_duplicate'
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

        -- Database context owners may not be login contexts nor may they be
        -- started
        IF new.database_owner_context AND (new.login_context OR new.start_context) THEN
            RAISE EXCEPTION
                USING
                    MESSAGE = 'A database owner context may not be a login ' ||
                              'context nor may it be started.',
                    DETAIL = ms_syst_priv.get_exception_details(
                                 p_proc_schema    => 'ms_syst'
                                ,p_proc_name      => 'trig_b_iud_syst_application_contexts_validate_owner_context'
                                ,p_exception_name => 'invalid_duplicate'
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

        RETURN new;

    END IF;

END;
$BODY$
LANGUAGE plpgsql VOLATILE;

ALTER FUNCTION ms_syst_data.trig_b_iud_syst_application_contexts_validate_owner_context()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst_data.trig_b_iud_syst_application_contexts_validate_owner_context() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst_data.trig_b_iud_syst_application_contexts_validate_owner_context() TO <%= ms_owner %>;

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
    var_comments_config.function_name   := 'trig_b_iud_syst_application_contexts_validate_owner_context';

    var_comments_config.trigger_function := TRUE;
    var_comments_config.trigger_timing   := ARRAY [ 'b' ]::text[ ];
    var_comments_config.trigger_ops      := ARRAY [ 'i', 'u', 'd' ]::text[ ];

    var_comments_config.description :=
$DOC$Validates database_owner_context values based on the pre-existing state of the database.$DOC$;

    PERFORM ms_syst_priv.generate_comments_function( var_comments_config );

END;
$DOCUMENTATION$;
