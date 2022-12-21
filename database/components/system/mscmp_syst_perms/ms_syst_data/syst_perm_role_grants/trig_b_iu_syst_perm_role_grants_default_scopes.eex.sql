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

COMMENT ON FUNCTION ms_syst_data.trig_b_iu_syst_perm_role_grants_default_scopes() IS
$DOC$This function is not yet documented.$DOC$;
