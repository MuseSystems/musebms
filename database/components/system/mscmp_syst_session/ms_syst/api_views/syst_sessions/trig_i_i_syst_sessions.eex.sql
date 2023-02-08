CREATE OR REPLACE FUNCTION ms_syst.trig_i_i_syst_sessions()
RETURNS trigger AS
$BODY$

-- File:        trig_i_i_syst_sessions.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_session/ms_syst/api_views/syst_sessions/trig_i_i_syst_sessions.eex.sql
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

    INSERT INTO ms_syst_data.syst_sessions
        ( internal_name, session_data, session_expires )
    VALUES
        ( new.internal_name, new.session_data, new.session_expires )
    RETURNING * INTO new;

    RETURN new;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO ms_syst, pg_temp;

ALTER FUNCTION ms_syst.trig_i_i_syst_sessions()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_sessions() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_sessions() TO <%= ms_owner %>;

COMMENT ON FUNCTION ms_syst.trig_i_i_syst_sessions() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_sessions API View for INSERT operations.$DOC$;
