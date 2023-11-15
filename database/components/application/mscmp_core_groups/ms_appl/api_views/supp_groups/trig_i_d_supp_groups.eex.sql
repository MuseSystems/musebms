CREATE OR REPLACE FUNCTION ms_appl.trig_i_d_supp_groups()
RETURNS trigger AS
$BODY$

-- File:        trig_i_d_supp_groups.eex.sql
-- Location:    musebms/database/components/application/mscmp_core_groups/ms_appl/api_views/supp_groups/trig_i_d_supp_groups.eex.sql
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

    CASE
        WHEN old.syst_defined AND NOT old.user_maintainable THEN

            RAISE EXCEPTION
                USING
                    MESSAGE =
                        'You may not delete a non-user maintainable system ' ||
                        'defined Group using this API view.',
                    DETAIL = ms_syst_priv.get_exception_details(
                                 p_proc_schema    => 'ms_appl'
                                ,p_proc_name      => 'trig_i_d_supp_groups'
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

        WHEN old.syst_defined AND old.parent_group_id IS NULL THEN

            RAISE EXCEPTION
                USING
                    MESSAGE =
                        'You may not delete a root level system defined ' ||
                        'Group using this API view.',
                    DETAIL = ms_syst_priv.get_exception_details(
                                 p_proc_schema    => 'ms_appl'
                                ,p_proc_name      => 'trig_i_d_supp_groups'
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

        ELSE

            DELETE FROM ms_appl_data.supp_groups
            WHERE id = old.id
            RETURNING * INTO old;

    END CASE;

    RETURN old;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO ms_appl, pg_temp;

ALTER FUNCTION ms_appl.trig_i_d_supp_groups()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_appl.trig_i_d_supp_groups() FROM public;
GRANT EXECUTE ON FUNCTION ms_appl.trig_i_d_supp_groups() TO <%= ms_owner %>;

COMMENT ON FUNCTION ms_appl.trig_i_d_supp_groups() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
supp_groups API View for DELETE operations.$DOC$;
