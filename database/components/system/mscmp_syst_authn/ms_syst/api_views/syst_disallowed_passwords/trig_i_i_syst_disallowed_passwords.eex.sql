-- File:        trig_i_i_syst_disallowed_passwords.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/ms_syst/api_views/syst_disallowed_passwords/trig_i_i_syst_disallowed_passwords.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

CREATE OR REPLACE FUNCTION ms_syst.trig_i_i_syst_disallowed_passwords()
RETURNS trigger AS
$BODY$

-- File:        trig_i_i_syst_disallowed_passwords.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/ms_syst/api_views/syst_disallowed_passwords/trig_i_i_syst_disallowed_passwords.eex.sql
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

    INSERT INTO ms_syst_data.syst_disallowed_passwords
        ( password_hash )
    VALUES
        ( new.password_hash )
    ON CONFLICT ( password_hash ) DO NOTHING
    RETURNING * INTO new;

    RETURN new;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO ms_syst, pg_temp;

ALTER FUNCTION ms_syst.trig_i_i_syst_disallowed_passwords()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_disallowed_passwords() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_disallowed_passwords() TO <%= ms_owner %>;

COMMENT ON FUNCTION ms_syst.trig_i_i_syst_disallowed_passwords() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_disallowed_passwords API View for INSERT operations.$DOC$;
