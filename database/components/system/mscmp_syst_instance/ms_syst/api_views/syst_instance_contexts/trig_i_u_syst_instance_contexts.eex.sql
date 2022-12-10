CREATE OR REPLACE FUNCTION ms_syst.trig_i_u_syst_instance_contexts()
RETURNS trigger AS
$BODY$

-- File:        trig_i_u_syst_instance_contexts.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_instance/ms_syst/api_views/syst_instance_contexts/trig_i_u_syst_instance_contexts.eex.sql
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
        new.internal_name          != old.internal_name OR
        new.instance_id            != old.instance_id OR
        new.application_context_id != old.application_context_id
    THEN
        RAISE EXCEPTION
            USING
                MESSAGE = 'The requested data update included changes to fields disallowed ' ||
                          'by the business rules of the API View.',
                DETAIL = ms_syst_priv.get_exception_details(
                             p_proc_schema    => 'ms_syst'
                            ,p_proc_name      => 'trig_i_u_syst_instance_contexts'
                            ,p_exception_name => 'invalid_api_view_call'
                            ,p_errcode        => 'PM008'
                            ,p_param_data     =>
                                jsonb_build_object('new', to_jsonb(new), 'old', to_jsonb(old))
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

    UPDATE ms_syst_data.syst_instance_contexts
    SET
        start_context = new.start_context
      , db_pool_size  = new.db_pool_size
      , context_code  = new.context_code
    WHERE id = new.id
    RETURNING * INTO new;

    RETURN new;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO ms_syst, pg_temp;

ALTER FUNCTION ms_syst.trig_i_u_syst_instance_contexts()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_instance_contexts() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_instance_contexts() TO <%= ms_owner %>;

COMMENT ON FUNCTION ms_syst.trig_i_u_syst_instance_contexts() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_instance_contexts API View for UPDATE operations.$DOC$;
