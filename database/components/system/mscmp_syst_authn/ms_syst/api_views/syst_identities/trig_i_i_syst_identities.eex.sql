CREATE OR REPLACE FUNCTION ms_syst.trig_i_i_syst_identities()
RETURNS trigger AS
$BODY$

-- File:        trig_i_i_syst_identities.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/ms_syst/api_views/syst_identities/trig_i_i_syst_identities.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

BEGIN

    INSERT INTO ms_syst_data.syst_identities
        ( access_account_id
        , identity_type_id
        , account_identifier
        , validated
        , validates_identity_id
        , validation_requested
        , identity_expires
        , external_name )
    VALUES
        ( new.access_account_id
        , new.identity_type_id
        , new.account_identifier
        , new.validated
        , new.validates_identity_id
        , new.validation_requested
        , new.identity_expires
        , new.external_name )
    RETURNING * INTO new;

    RETURN new;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO ms_syst, pg_temp;

ALTER FUNCTION ms_syst.trig_i_i_syst_identities()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_identities() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_identities() TO <%= ms_owner %>;

COMMENT ON FUNCTION ms_syst.trig_i_i_syst_identities() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_identities API View for INSERT operations.$DOC$;
