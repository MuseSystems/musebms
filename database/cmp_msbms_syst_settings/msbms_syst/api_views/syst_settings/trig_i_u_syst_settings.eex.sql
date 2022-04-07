CREATE OR REPLACE FUNCTION msbms_syst.trig_i_u_syst_settings()
RETURNS trigger AS
$BODY$

-- File:        trig_i_u_syst_settings.eex.sql
-- Location:    database\cmp_msbms_syst_settings\msbms_syst\api_views\syst_settings\trig_i_u_syst_settings.eex.sql
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

    IF
        old.syst_defined AND
        ( new.internal_name    != old.internal_name OR
          new.display_name     != old.display_name OR
          new.syst_defined     != old.syst_defined OR
          new.syst_description != old.syst_description )
    THEN
        RAISE EXCEPTION
            USING
                MESSAGE = 'The requested data update included changes to fields disallowed ' ||
                          'by the business rules of the API View.',
                DETAIL = msbms_syst_priv.get_exception_details(
                             p_proc_schema    => 'msbms_syst'
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

    UPDATE msbms_syst_data.syst_settings SET
          user_description       = new.user_description
        , config_flag            = new.config_flag
        , config_integer         = new.config_integer
        , config_integer_range   = new.config_integer_range
        , config_decimal         = new.config_decimal
        , config_decimal_range   = new.config_decimal_range
        , config_interval        = new.config_interval
        , config_date            = new.config_date
        , config_date_range      = new.config_date_range
        , config_time            = new.config_time
        , config_timestamp       = new.config_timestamp
        , config_timestamp_range = new.config_timestamp_range
        , config_json            = new.config_json
        , config_text            = new.config_text
        , config_uuid            = new.config_uuid
        , config_blob            = new.config_blob
    WHERE id = new.id;

    RETURN new;

END;
$BODY$ LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

ALTER FUNCTION msbms_syst.trig_i_u_syst_settings() OWNER TO <%= msbms_owner %>;

REVOKE EXECUTE ON FUNCTION msbms_syst.trig_i_u_syst_settings() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION msbms_syst.trig_i_u_syst_settings() TO <%= msbms_appusr %>;
GRANT EXECUTE ON FUNCTION msbms_syst.trig_i_u_syst_settings() TO <%= msbms_apiusr %>;

COMMENT ON
    FUNCTION msbms_syst.trig_i_u_syst_settings() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_settings API View for UPDATE operations.$DOC$;
