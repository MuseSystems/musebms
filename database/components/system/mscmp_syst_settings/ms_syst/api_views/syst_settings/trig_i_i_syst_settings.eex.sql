CREATE OR REPLACE FUNCTION ms_syst.trig_i_i_syst_settings()
RETURNS trigger AS
$BODY$

-- File:        trig_i_i_syst_settings.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_settings/ms_syst/api_views/syst_settings/trig_i_i_syst_settings.eex.sql
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

    INSERT INTO ms_syst_data.syst_settings
        ( internal_name
        , display_name
        , syst_defined
        , syst_description
        , user_description
        , setting_flag
        , setting_integer
        , setting_integer_range
        , setting_decimal
        , setting_decimal_range
        , setting_interval
        , setting_date
        , setting_date_range
        , setting_time
        , setting_timestamp
        , setting_timestamp_range
        , setting_json
        , setting_text
        , setting_uuid
        , setting_blob )
    VALUES
        ( new.internal_name
        , new.display_name
        , FALSE
        , '(System Description Not Available)'
        , new.user_description
        , new.setting_flag
        , new.setting_integer
        , new.setting_integer_range
        , new.setting_decimal
        , new.setting_decimal_range
        , new.setting_interval
        , new.setting_date
        , new.setting_date_range
        , new.setting_time
        , new.setting_timestamp
        , new.setting_timestamp_range
        , new.setting_json
        , new.setting_text
        , new.setting_uuid
        , new.setting_blob )
    RETURNING * INTO new;

    RETURN new;

END;
$BODY$ LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

ALTER FUNCTION ms_syst.trig_i_i_syst_settings() OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_settings() FROM PUBLIC;

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
    var_comments_config.function_name   := 'trig_i_i_syst_settings';

    var_comments_config.trigger_function := TRUE;
    var_comments_config.trigger_timing   := ARRAY [ 'i' ]::text[ ];
    var_comments_config.trigger_ops      := ARRAY [ 'i' ]::text[ ];

    var_comments_config.description :=
$DOC$Processes incoming API View requests according to globally applicable business 
rules and data validation requirements.$DOC$;

    PERFORM ms_syst_priv.generate_comments_function( var_comments_config );

END;
$DOCUMENTATION$;
