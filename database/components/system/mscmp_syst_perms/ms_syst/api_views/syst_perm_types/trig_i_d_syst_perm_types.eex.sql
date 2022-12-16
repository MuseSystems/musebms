CREATE OR REPLACE FUNCTION ms_syst.trig_i_d_syst_perm_types()
RETURNS trigger AS
$BODY$

-- File:        trig_i_d_syst_perm_types.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_perms/ms_syst/api_views/syst_perm_types/trig_i_d_syst_perm_types.eex.sql
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

    IF old.syst_defined THEN
        RAISE EXCEPTION
            USING
                MESSAGE = 'You may not delete system defined permission types ' ||
                          'using this API view.',
                DETAIL = ms_syst_priv.get_exception_details(
                             p_proc_schema    => 'ms_syst'
                            ,p_proc_name      => 'trig_i_u_syst_perm_types'
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

    DELETE FROM ms_syst_data.syst_perm_types WHERE id = old.id RETURNING * INTO old;

    RETURN old;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO ms_syst, pg_temp;

ALTER FUNCTION ms_syst.trig_i_d_syst_perm_types()
    OWNER TO <%= msbms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_perm_types() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_perm_types() TO <%= msbms_owner %>;

COMMENT ON FUNCTION ms_syst.trig_i_d_syst_perm_types() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_perm_types API View for DELETE operations.$DOC$;
