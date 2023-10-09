CREATE OR REPLACE FUNCTION ms_syst.trig_i_d_syst_group_types()
RETURNS trigger AS
$BODY$

-- File:        trig_i_d_syst_group_types.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_groups/ms_syst/api_views/syst_group_types/trig_i_d_syst_group_types.eex.sql
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
                MESSAGE = 'You cannot delete a system defined Group Type using the API Views.',
                DETAIL = ms_syst_priv.get_exception_details(
                             p_proc_schema    => 'ms_syst'
                            ,p_proc_name      => 'trig_i_d_syst_group_types'
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

    DELETE FROM ms_syst_data.syst_group_types WHERE id = old.id RETURNING * INTO old;

    RETURN old;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO ms_syst, pg_temp;

ALTER FUNCTION ms_syst.trig_i_d_syst_group_types()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_group_types() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_group_types() TO <%= ms_owner %>;

COMMENT ON FUNCTION ms_syst.trig_i_d_syst_group_types() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_group_types API View for DELETE operations.$DOC$;