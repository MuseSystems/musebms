CREATE OR REPLACE FUNCTION ms_appl.trig_i_d_supp_group_functional_types()
RETURNS trigger AS
$BODY$

-- File:        trig_i_d_supp_group_functional_types.eex.sql
-- Location:    musebms/database/components/application/mscmp_core_groups/ms_appl/api_views/supp_group_functional_types/trig_i_d_supp_group_functional_types.eex.sql
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
            MESSAGE = 'Records in this table are system maintained and may not ' ||
            'be deleted using this API view.',
            DETAIL = ms_syst_priv.get_exception_details(
                         p_proc_schema    => 'ms_appl'
                        ,p_proc_name      => 'trig_i_d_supp_group_functional_types'
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
    SET search_path TO ms_appl, pg_temp;

ALTER FUNCTION ms_appl.trig_i_d_supp_group_functional_types()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_appl.trig_i_d_supp_group_functional_types() FROM public;
GRANT EXECUTE ON FUNCTION ms_appl.trig_i_d_supp_group_functional_types() TO <%= ms_owner %>;

COMMENT ON FUNCTION ms_appl.trig_i_d_supp_group_functional_types() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
supp_instance_contexts API View for DELETE operations.$DOC$;
