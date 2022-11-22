DO
$SYS_SETTINGS_OPTION$
    BEGIN
        IF
            exists( SELECT TRUE
                    FROM information_schema.tables
                    WHERE table_schema = 'ms_syst_data'
                      AND table_name = 'syst_settings')
        THEN

CREATE OR REPLACE FUNCTION ms_syst.trig_i_u_syst_feature_setting_assigns()
RETURNS trigger AS
$BODY$

-- File:        trig_i_u_syst_feature_setting_assigns.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_features/ms_syst/api_views/syst_feature_setting_assigns/trig_i_u_syst_feature_setting_assigns.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

DECLARE
    var_setting_system_defined boolean;

BEGIN

    RAISE EXCEPTION
        USING
            MESSAGE = 'You cannot update a system defined setting/feature assignment ' ||
                      'using the API Views.',
            DETAIL = ms_syst_priv.get_exception_details(
                         p_proc_schema    => 'ms_syst'
                        ,p_proc_name      => 'trig_i_u_syst_feature_setting_assigns'
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

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO ms_syst, pg_temp;

ALTER FUNCTION ms_syst.trig_i_u_syst_feature_setting_assigns()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_feature_setting_assigns() FROM public;

COMMENT ON
    FUNCTION ms_syst.trig_i_u_syst_feature_setting_assigns() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_settings API View for UPDATE operations.

Note that for syst_feature_setting_assigns records that updating is not a
supported operation.  Any change in the feature or the setting is a sufficiently
large change to justify just using a full delete/insert.$DOC$;

        END IF;
    END;
$SYS_SETTINGS_OPTION$;
