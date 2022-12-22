CREATE OR REPLACE FUNCTION ms_syst.trig_i_u_syst_perms()
RETURNS trigger AS
$BODY$

-- File:        trig_i_u_syst_perms.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_perms/ms_syst/api_views/syst_perms/trig_i_u_syst_perms.eex.sql
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
        (old.syst_defined AND
            (new.internal_name != old.internal_name OR
             new.view_scope_options != old.view_scope_options OR
             new.maint_scope_options != old.maint_scope_options OR
             new.admin_scope_options != old.admin_scope_options OR
             new.ops_scope_options != old.ops_scope_options )) OR
        new.syst_defined != old.syst_defined OR
        new.perm_functional_type_id != old.perm_functional_type_id
    THEN
        RAISE EXCEPTION
            USING
                MESSAGE = 'The requested data update included changes to fields disallowed ' ||
                          'by the business rules of the API View.',
                DETAIL = ms_syst_priv.get_exception_details(
                             p_proc_schema    => 'ms_syst'
                            ,p_proc_name      => 'trig_i_u_syst_perms'
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
    END IF;

    UPDATE ms_syst_data.syst_perms
    SET
        internal_name       = new.internal_name
      , display_name        = new.display_name
      , user_description    = new.user_description
      , view_scope_options  = new.view_scope_options
      , maint_scope_options = new.maint_scope_options
      , admin_scope_options = new.admin_scope_options
      , ops_scope_options   = new.ops_scope_options
    WHERE id = new.id
    RETURNING * INTO new;

    RETURN new;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO ms_syst, pg_temp;

ALTER FUNCTION ms_syst.trig_i_u_syst_perms()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_perms() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_perms() TO <%= ms_owner %>;

COMMENT ON FUNCTION ms_syst.trig_i_u_syst_perms() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_perms API View for UPDATE operations.$DOC$;