CREATE OR REPLACE FUNCTION ms_syst.get_greatest_rights_scope(p_scopes text[] DEFAULT NULL::text[])
RETURNS text AS
$BODY$

-- File:        get_greatest_rights_scope.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_perms/ms_syst/functions/get_greatest_rights_scope.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

    SELECT ms_syst_priv.get_greatest_rights_scope(p_scopes);

$BODY$
    LANGUAGE sql
    IMMUTABLE
    SECURITY DEFINER
    SET search_path TO ms_syst, pg_temp;

ALTER FUNCTION ms_syst.get_greatest_rights_scope(p_scopes text[])
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst.get_greatest_rights_scope(p_scopes text[]) FROM public;
GRANT EXECUTE ON FUNCTION ms_syst.get_greatest_rights_scope(p_scopes text[]) TO <%= ms_owner %>;

COMMENT ON FUNCTION ms_syst.get_greatest_rights_scope(p_scopes text[]) IS
$DOC$Given an array of Permission Right Scopes, returns the most expansive scope
found in the array.

If the array is NULL the returned value is 'deny'.$DOC$;
