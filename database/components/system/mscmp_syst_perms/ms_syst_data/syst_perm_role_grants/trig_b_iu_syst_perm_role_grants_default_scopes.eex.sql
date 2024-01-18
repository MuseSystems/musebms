CREATE OR REPLACE FUNCTION ms_syst_data.trig_b_iu_syst_perm_role_grants_default_scopes()
RETURNS trigger AS
$BODY$

-- File:        trig_b_iu_syst_perm_role_grants_default_scopes.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_perms/ms_syst_data/syst_perm_role_grants/trig_b_iu_syst_perm_role_grants_default_scopes.eex.sql
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
    var_perm ms_syst_data.syst_perms;

BEGIN

    SELECT * INTO STRICT var_perm FROM ms_syst_data.syst_perms WHERE id = new.perm_id;

    IF new.view_scope IS NULL THEN
        new.view_scope = var_perm.view_scope_options[1];
    END IF;

    IF new.maint_scope IS NULL THEN
        new.maint_scope = var_perm.maint_scope_options[1];
    END IF;

    IF new.admin_scope IS NULL THEN
        new.admin_scope = var_perm.admin_scope_options[1];
    END IF;

    IF new.ops_scope IS NULL THEN
        new.ops_scope = var_perm.ops_scope_options[1];
    END IF;

    RETURN new;

END;
$BODY$
LANGUAGE plpgsql VOLATILE;

ALTER FUNCTION ms_syst_data.trig_b_iu_syst_perm_role_grants_default_scopes()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst_data.trig_b_iu_syst_perm_role_grants_default_scopes() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst_data.trig_b_iu_syst_perm_role_grants_default_scopes() TO <%= ms_owner %>;

DO
$DOCUMENTATION$
DECLARE
    -- Function
    var_comments_config ms_syst_priv.comments_config_function;

BEGIN

    --
    -- Function Config
    --

    var_comments_config.function_schema := 'ms_syst_data';
    var_comments_config.function_name   := 'trig_b_iu_syst_perm_role_grants_default_scopes';

    var_comments_config.trigger_function := TRUE;
    var_comments_config.trigger_timing   := ARRAY [ 'b' ]::text[ ];
    var_comments_config.trigger_ops      := ARRAY [ 'i', 'u' ]::text[ ];

    var_comments_config.description :=
$DOC$This trigger will assign default Permmission Scope values based on the
definition of the permission defined in Permissions' `ms_syst_data.syst_perms`
record.$DOC$;

    PERFORM ms_syst_priv.generate_comments_function( var_comments_config );

END;
$DOCUMENTATION$;
