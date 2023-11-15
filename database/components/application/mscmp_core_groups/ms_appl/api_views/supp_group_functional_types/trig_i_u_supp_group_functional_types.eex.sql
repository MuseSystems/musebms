CREATE OR REPLACE FUNCTION ms_appl.trig_i_u_supp_group_functional_types()
RETURNS trigger AS
$BODY$

-- File:        trig_i_u_supp_group_functional_types.eex.sql
-- Location:    musebms/database/components/application/mscmp_core_groups/ms_appl/api_views/supp_group_functional_types/trig_i_u_supp_group_functional_types.eex.sql
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

    IF
        new.internal_name    != old.internal_name OR
        new.display_name     != old.display_name OR
        new.syst_description != old.syst_description
    THEN
        RAISE EXCEPTION
            USING
                MESSAGE = 'The requested data update included changes to fields disallowed ' ||
                          'by the business rules of the API View.',
                DETAIL = ms_syst_priv.get_exception_details(
                             p_proc_schema    => 'ms_appl'
                            ,p_proc_name      => 'trig_i_u_supp_group_functional_types'
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

    UPDATE ms_appl_data.supp_group_functional_types
    SET user_description = new.user_description
    WHERE id = new.id
    RETURNING * INTO new;

    RETURN new;
END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO ms_appl, pg_temp;

ALTER FUNCTION ms_appl.trig_i_u_supp_group_functional_types()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_appl.trig_i_u_supp_group_functional_types() FROM public;
GRANT EXECUTE ON FUNCTION ms_appl.trig_i_u_supp_group_functional_types() TO <%= ms_owner %>;

COMMENT ON FUNCTION ms_appl.trig_i_u_supp_group_functional_types() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
supp_group_functional_types API View for UPDATE operations.$DOC$;
