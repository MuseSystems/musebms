CREATE OR REPLACE FUNCTION msbms_syst.trig_i_i_syst_settings()
RETURNS trigger AS
$BODY$

-- File:        trig_i_i_syst_settings.eex.sql
-- Location:    database\cmp_msbms_syst_settings\msbms_syst\api_views\syst_settings\trig_i_i_syst_settings.eex.sql
-- Project:     Muse Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

BEGIN

    INSERT INTO msbms_syst_data.syst_settings
        ( internal_name
        , display_name
        , syst_defined
        , syst_description
        , user_description
        , config_flag
        , config_integer
        , config_integer_range
        , config_decimal
        , config_decimal_range
        , config_interval
        , config_date
        , config_date_range
        , config_time
        , config_timestamp
        , config_timestamp_range
        , config_json
        , config_text
        , config_uuid
        , config_blob )
    VALUES
        ( new.internal_name
        , new.display_name
        , FALSE
        , '(System Description Not Provided)'
        , new.user_description
        , new.config_flag
        , new.config_integer
        , new.config_integer_range
        , new.config_decimal
        , new.config_decimal_range
        , new.config_interval
        , new.config_date
        , new.config_date_range
        , new.config_time
        , new.config_timestamp
        , new.config_timestamp_range
        , new.config_json
        , new.config_text
        , new.config_uuid
        , new.config_blob );

    RETURN new;

END;
$BODY$ LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

ALTER FUNCTION msbms_syst.trig_i_i_syst_settings() OWNER TO <%= msbms_owner %>;

REVOKE EXECUTE ON FUNCTION msbms_syst.trig_i_i_syst_settings() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION msbms_syst.trig_i_i_syst_settings() TO <%= msbms_appusr %>;
GRANT EXECUTE ON FUNCTION msbms_syst.trig_i_i_syst_settings() TO <%= msbms_apiusr %>;

COMMENT ON
    FUNCTION msbms_syst.trig_i_i_syst_settings() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_settings API View for INSERT operations.$DOC$;
