DO
$SYS_SETTINGS_OPTION$
    BEGIN
        IF
            exists( SELECT TRUE
                    FROM information_schema.tables
                    WHERE table_schema = 'msbms_syst_data'
                      AND table_name = 'syst_settings')
        THEN

CREATE OR REPLACE FUNCTION msbms_syst.trig_i_d_syst_feature_setting_assigns()
RETURNS trigger AS
$BODY$

-- File:        trig_i_d_syst_feature_setting_assigns.eex.sql
-- Location:    musebms/database/cmp_msbms_syst_features/msbms_syst/api_views/syst_feature_setting_assigns/trig_i_d_syst_feature_setting_assigns.eex.sql
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
        (
            SELECT syst_defined
            FROM   msbms_syst_data.syst_settings
            WHERE  id = old.setting_id
        )
    THEN
        RAISE EXCEPTION
            USING
                MESSAGE = 'You cannot delete a system defined setting/feature assignment ' ||
                          'using the API Views.',
                DETAIL = msbms_syst_priv.get_exception_details(
                             p_proc_schema    => 'msbms_syst'
                            ,p_proc_name      => 'trig_i_d_syst_feature_setting_assigns'
                            ,p_exception_name => 'invalid_api_view_call'
                            ,p_errcode        => 'PM008'
                            ,p_param_data     => to_jsonb(old)
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

    DELETE FROM msbms_syst_data.syst_feature_setting_assigns WHERE id = old.id;

    RETURN null;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO msbms_syst, pg_temp;

ALTER FUNCTION msbms_syst.trig_i_d_syst_feature_setting_assigns()
    OWNER TO <%= msbms_owner %>;

REVOKE EXECUTE ON FUNCTION msbms_syst.trig_i_d_syst_feature_setting_assigns() FROM public;
GRANT EXECUTE ON FUNCTION msbms_syst.trig_i_d_syst_feature_setting_assigns() TO <%= msbms_appusr %>;
GRANT EXECUTE ON FUNCTION msbms_syst.trig_i_d_syst_feature_setting_assigns() TO <%= msbms_apiusr %>;


COMMENT ON
    FUNCTION msbms_syst.trig_i_d_syst_feature_setting_assigns() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_settings API View for DELETE operations.$DOC$;

        END IF;
    END;
$SYS_SETTINGS_OPTION$;
