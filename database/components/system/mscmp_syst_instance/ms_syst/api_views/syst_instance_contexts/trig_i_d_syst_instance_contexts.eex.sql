CREATE OR REPLACE FUNCTION ms_syst.trig_i_d_syst_instance_contexts()
RETURNS trigger AS
$BODY$

-- File:        trig_i_d_syst_instance_contexts.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_instance/ms_syst/api_views/syst_instance_contexts/trig_i_d_syst_instance_contexts.eex.sql
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
            MESSAGE = 'Records in this table are deleted automatically when ' ||
                      'its parent records are deleted.  Direct deletion via ' ||
                      'this API view is not supported.',
            DETAIL = ms_syst_priv.get_exception_details(
                         p_proc_schema    => 'ms_syst'
                        ,p_proc_name      => 'trig_i_d_syst_instance_contexts'
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
    SET search_path TO ms_syst, pg_temp;

ALTER FUNCTION ms_syst.trig_i_d_syst_instance_contexts()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_instance_contexts() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_instance_contexts() TO <%= ms_owner %>;

COMMENT ON FUNCTION ms_syst.trig_i_d_syst_instance_contexts() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_instance_contexts API View for DELETE operations.$DOC$;
