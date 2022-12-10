CREATE OR REPLACE FUNCTION ms_syst.trig_i_i_syst_application_contexts()
RETURNS trigger AS
$BODY$

-- File:        trig_i_i_syst_application_contexts.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_instance/ms_syst/api_views/syst_application_contexts/trig_i_i_syst_application_contexts.eex.sql
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

    INSERT INTO ms_syst_data.syst_application_contexts
        ( internal_name
        , display_name
        , application_id
        , description
        , start_context
        , login_context
        , database_owner_context )
    VALUES
        ( new.internal_name
        , new.display_name
        , new.application_id
        , new.description
        , new.start_context
        , new.login_context
        , new.database_owner_context )
    RETURNING * INTO new;

    RETURN new;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO ms_syst, pg_temp;

ALTER FUNCTION ms_syst.trig_i_i_syst_application_contexts()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_application_contexts() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_application_contexts() TO <%= ms_owner %>;

COMMENT ON FUNCTION ms_syst.trig_i_i_syst_application_contexts() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_application_contexts API View for INSERT operations.$DOC$;
