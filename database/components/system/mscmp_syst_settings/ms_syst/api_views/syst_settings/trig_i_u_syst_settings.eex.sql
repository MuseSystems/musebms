CREATE OR REPLACE FUNCTION ms_syst.trig_i_u_syst_settings()
RETURNS trigger AS
$BODY$

-- File:        trig_i_u_syst_settings.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_settings/ms_syst/api_views/syst_settings/trig_i_u_syst_settings.eex.sql
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
                            ,p_proc_name      => 'trig_i_u_syst_settings'
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

    UPDATE ms_syst_data.syst_settings SET
          internal_name           = new.internal_name
        , display_name            = new.display_name
        , user_description        = new.user_description
        , setting_flag            = new.setting_flag
        , setting_integer         = new.setting_integer
        , setting_integer_range   = new.setting_integer_range
        , setting_decimal         = new.setting_decimal
        , setting_decimal_range   = new.setting_decimal_range
        , setting_interval        = new.setting_interval
        , setting_date            = new.setting_date
        , setting_date_range      = new.setting_date_range
        , setting_time            = new.setting_time
        , setting_timestamp       = new.setting_timestamp
        , setting_timestamp_range = new.setting_timestamp_range
        , setting_json            = new.setting_json
        , setting_text            = new.setting_text
        , setting_uuid            = new.setting_uuid
        , setting_blob            = new.setting_blob
    WHERE id = new.id
    RETURNING * INTO new;

    RETURN new;

END;
$BODY$ LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

ALTER FUNCTION ms_syst.trig_i_u_syst_settings() OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_settings() FROM PUBLIC;

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
    var_comments_config.function_name   := 'trig_i_u_syst_settings';

    var_comments_config.trigger_function := TRUE;
    var_comments_config.trigger_timing   := ARRAY [ 'i' ]::text[ ];
    var_comments_config.trigger_ops      := ARRAY [ 'u' ]::text[ ];

    var_comments_config.description :=
$DOC$Processes incoming API View requests according to globally applicable business
rules and data validation requirements.$DOC$;

    PERFORM ms_syst_priv.generate_comments_function( var_comments_config );

END;
$DOCUMENTATION$;
