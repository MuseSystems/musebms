CREATE OR REPLACE FUNCTION msbms_syst.trig_i_d_syst_global_password_rules()
RETURNS trigger AS
$BODY$

-- File:        trig_i_d_syst_global_password_rules.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/msbms_syst/api_views/syst_global_password_rules/trig_i_d_syst_global_password_rules.eex.sql
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

    RAISE EXCEPTION
        USING
            MESSAGE = 'This API view does not allow for record deletes for ' ||
                      'this table.',
            DETAIL = msbms_syst_priv.get_exception_details(
                         p_proc_schema    => 'msbms_syst'
                        ,p_proc_name      => 'trig_i_d_syst_global_password_rules'
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

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO msbms_syst, pg_temp;

ALTER FUNCTION msbms_syst.trig_i_d_syst_global_password_rules()
    OWNER TO <%= msbms_owner %>;

REVOKE EXECUTE ON FUNCTION msbms_syst.trig_i_d_syst_global_password_rules() FROM public;
GRANT EXECUTE ON FUNCTION msbms_syst.trig_i_d_syst_global_password_rules() TO <%= msbms_owner %>;

COMMENT ON FUNCTION msbms_syst.trig_i_d_syst_global_password_rules() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_global_password_rules API View for DELETE operations.$DOC$;
