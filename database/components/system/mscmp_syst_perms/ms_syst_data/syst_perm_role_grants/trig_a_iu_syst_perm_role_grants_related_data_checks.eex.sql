CREATE OR REPLACE FUNCTION ms_syst_data.trig_a_iu_syst_perm_role_grants_related_data_checks()
RETURNS trigger AS
$BODY$

-- File:        trig_a_iu_syst_perm_role_grants_related_data_checks.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_perms/ms_syst_data/syst_perm_role_grants/trig_a_iu_syst_perm_role_grants_related_data_checks.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

DECLARE
    var_context_data record;
    var_errors       text[] := ARRAY [];

BEGIN

    SELECT INTO STRICT var_context_data
        sp.view_scope_options
      , sp.maint_scope_options
      , sp.admin_scope_options
      , sp.ops_scope_options
      , sp.perm_functional_type_id                              AS perm_perm_functional_type_id
      , spr.perm_functional_type_id                             AS perm_role_perm_functional_type_id
      , NOT spr.view_scope = ANY (sp.view_scope_options)        AS view_scope_invalid
      , NOT spr.maint_scope = ANY (sp.maint_scope_options)      AS maint_scope_invalid
      , NOT spr.admin_scope = ANY (sp.admin_scope_options)      AS admin_scope_invalid
      , NOT spr.ops_scope = ANY (sp.ops_scope_options)          AS ops_scope_invalid
      , spr.perm_function_type_id != sp.perm_functional_type_id AS perm_functional_type_invalid
    FROM
        ms_syst_data.syst_perms sp
      , ms_syst_data.syst_perm_roles spr
    WHERE sp.id = new.perm_id AND spr.id = new.perm_role_id;

    --
    -- Functional Type Check
    --

    IF var_context_data.perm_functional_type_invalid THEN

        RAISE EXCEPTION
            USING
                MESSAGE = 'This record may only grant Permissions of the same ' ||
                          'Permission Functional Type that is assigned to the ' ||
                          'Permission Role which owns this record.',
                DETAIL = ms_syst_priv.get_exception_details(
                             p_proc_schema    => 'ms_syst'
                            ,p_proc_name      => 'trig_a_iu_syst_perm_role_grants_related_data_checks'
                            ,p_exception_name => 'invalid_data'
                            ,p_errcode        => 'PM008'
                            ,p_param_data     =>
                                jsonb_build_object(
                                     'syst_perms_perm_functional_type_id'
                                    , var_context_data.perm_perm_functional_type_id
                                    ,'syst_perm_roles_perm_functional_type_id'
                                    ,var_context_data.perm_role_perm_functional_type_id )
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

    --
    -- Rights Scoping Checks
    --

    IF NOT var_context_data.view_scope_invalid THEN
            var_errors :=
                var_errors ||
                'The assigned View Right Scope is not valid for this Permission.';
    END IF;

    IF NOT var_context_data.maint_scope_invalid THEN
            var_errors :=
                var_errors ||
                'The assigned Maintenance Right Scope is not valid for this Permission.';
    END IF;

    IF NOT var_context_data.admin_scope_invalid THEN
            var_errors :=
                var_errors ||
                'The assigned Administration Right Scope is not valid for this Permission.';
    END IF;

    IF NOT var_context_data.ops_scope_invalid THEN
            var_errors :=
                var_errors ||
                'The assigned Operations Right Scope is not valid for this Permission.';
    END IF;


    IF array_length(var_errors, 1) > 0 THEN

        RAISE EXCEPTION
            USING
                MESSAGE = 'Invalid Scopes for Permission Rights provided.',
                DETAIL = ms_syst_priv.get_exception_details(
                             p_proc_schema    => 'ms_syst'
                            ,p_proc_name      => 'trig_a_iu_syst_perm_role_grants_related_data_checks'
                            ,p_exception_name => 'invalid_data'
                            ,p_errcode        => 'PM008'
                            ,p_param_data     =>
                                jsonb_build_object(
                                     'error_scopes',        var_errors
                                    ,'view_scope_options',  var_context_data.view_scope_options
                                    ,'maint_scope_options', var_context_data.maint_scope_options
                                    ,'admin_scope_options', var_context_data.admin_scope_options
                                    ,'ops_scope_options',   var_context_data.ops_scope_options
                                    ,'parameters',          new )
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

    RETURN new;

END;
$BODY$
LANGUAGE plpgsql VOLATILE;

ALTER FUNCTION ms_syst_data.trig_a_iu_syst_perm_role_grants_related_data_checks()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst_data.trig_a_iu_syst_perm_role_grants_related_data_checks() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst_data.trig_a_iu_syst_perm_role_grants_related_data_checks() TO <%= ms_owner %>;

COMMENT ON FUNCTION ms_syst_data.trig_a_iu_syst_perm_role_grants_related_data_checks() IS
$DOC$Checks that Permission Role Grant records are consistent with their defining
parent records.

This trigger $DOC$;
