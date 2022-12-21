CREATE OR REPLACE FUNCTION ms_syst.trig_i_i_syst_perm_roles()
RETURNS trigger AS
$BODY$

-- File:        trig_i_i_syst_perm_roles.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_perms/ms_syst/api_views/syst_perm_roles/trig_i_i_syst_perm_roles.eex.sql
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

    INSERT INTO ms_syst_data.syst_perm_roles
        ( internal_name
        , display_name
        , perm_functional_type_id
        , syst_defined
        , syst_description
        , user_description )
    VALUES
        ( new.internal_name
        , new.display_name
        , new.perm_functional_type_id
        , FALSE
        , '(System Description Not Available)'
        , new.user_description )
    RETURNING * INTO new;

    RETURN new;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO ms_syst, pg_temp;

ALTER FUNCTION ms_syst.trig_i_i_syst_perm_roles()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_perm_roles() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_perm_roles() TO <%= ms_owner %>;

COMMENT ON FUNCTION ms_syst.trig_i_i_syst_perm_roles() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_perm_roles API View for INSERT operations.$DOC$;
