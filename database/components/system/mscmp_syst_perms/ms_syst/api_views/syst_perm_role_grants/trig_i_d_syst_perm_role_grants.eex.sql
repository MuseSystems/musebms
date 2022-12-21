CREATE OR REPLACE FUNCTION ms_syst.trig_i_d_syst_perm_role_grants()
RETURNS trigger AS
$BODY$

-- File:        trig_i_d_syst_perm_role_grants.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_perms/ms_syst/api_views/syst_perm_role_grants/trig_i_d_syst_perm_role_grants.eex.sql
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
        ( SELECT syst_defined
          FROM ms_syst_data.syst_perm_roles
          WHERE id = old.perm_role_id )
    THEN
        RAISE EXCEPTION
            USING
                MESSAGE = 'You cannot delete a system defined permission role ' ||
                          'grant using the API Views.',
                DETAIL = ms_syst_priv.get_exception_details(
                             p_proc_schema    => 'ms_syst'
                            ,p_proc_name      => 'trig_i_d_syst_perm_role_grants'
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

    DELETE FROM ms_syst_data.syst_perm_role_grants WHERE id = old.id RETURNING * INTO old;

    RETURN old;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO ms_syst, pg_temp;

ALTER FUNCTION ms_syst.trig_i_d_syst_perm_role_grants()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_perm_role_grants() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_perm_role_grants() TO <%= ms_owner %>;

COMMENT ON FUNCTION ms_syst.trig_i_d_syst_perm_role_grants() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_perm_role_grants API View for DELETE operations.$DOC$;
