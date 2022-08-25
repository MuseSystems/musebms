CREATE OR REPLACE FUNCTION msbms_syst.trig_i_d_syst_banned_hosts()
RETURNS trigger AS
$BODY$

-- File:        trig_i_d_syst_banned_hosts.eex.sql
-- Location:    musebms/database/components/system/msbms_syst_authentication/msbms_syst/api_views/syst_banned_hosts/trig_i_d_syst_banned_hosts.eex.sql
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

    DELETE FROM msbms_syst_data.syst_banned_hosts WHERE id = old.id RETURNING * INTO old;

    RETURN old;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO msbms_syst, pg_temp;

ALTER FUNCTION msbms_syst.trig_i_d_syst_banned_hosts()
    OWNER TO <%= msbms_owner %>;

REVOKE EXECUTE ON FUNCTION msbms_syst.trig_i_d_syst_banned_hosts() FROM public;
GRANT EXECUTE ON FUNCTION msbms_syst.trig_i_d_syst_banned_hosts() TO <%= msbms_owner %>;

COMMENT ON FUNCTION msbms_syst.trig_i_d_syst_banned_hosts() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_banned_hosts API View for DELETE operations.$DOC$;
