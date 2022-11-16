CREATE OR REPLACE FUNCTION msbms_syst.trig_i_u_syst_instance_type_applications()
RETURNS trigger AS
$BODY$

-- File:        trig_i_u_syst_instance_type_applications.eex.sql
-- Location:    musebms/database/components/system/msbms_syst_instance_mgr/msbms_syst/api_views/syst_instance_type_applications/trig_i_u_syst_instance_type_applications.eex.sql
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

    RAISE EXCEPTION
        USING
            MESSAGE = 'No fields are updatable via this API view for this relation.',
            DETAIL = msbms_syst_priv.get_exception_details(
                         p_proc_schema    => 'msbms_syst'
                        ,p_proc_name      => 'trig_i_u_syst_instance_type_applications'
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

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO msbms_syst, pg_temp;

ALTER FUNCTION msbms_syst.trig_i_u_syst_instance_type_applications()
    OWNER TO <%= msbms_owner %>;

REVOKE EXECUTE ON FUNCTION msbms_syst.trig_i_u_syst_instance_type_applications() FROM public;
GRANT EXECUTE ON FUNCTION msbms_syst.trig_i_u_syst_instance_type_applications() TO <%= msbms_owner %>;

COMMENT ON FUNCTION msbms_syst.trig_i_u_syst_instance_type_applications() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_enum_items API View for UPDATE operations.$DOC$;