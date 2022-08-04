CREATE OR REPLACE FUNCTION msbms_syst.trig_i_d_syst_credentials()
RETURNS trigger AS
$BODY$

-- File:        trig_i_d_syst_credentials.eex.sql
-- Location:    musebms/database/cmp_msbms_syst_authentication/msbms_syst/api_views/syst_credentials/trig_i_d_syst_credentials.eex.sql
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

    DELETE FROM msbms_syst_data.syst_credentials WHERE id = old.id RETURNING * INTO old;

    RETURN old;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO msbms_syst, pg_temp;

ALTER FUNCTION msbms_syst.trig_i_d_syst_credentials()
    OWNER TO <%= msbms_owner %>;

REVOKE EXECUTE ON FUNCTION msbms_syst.trig_i_d_syst_credentials() FROM public;
GRANT EXECUTE ON FUNCTION msbms_syst.trig_i_d_syst_credentials() TO <%= msbms_owner %>;

COMMENT ON FUNCTION msbms_syst.trig_i_d_syst_credentials() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_credentials API View for DELETE operations.$DOC$;