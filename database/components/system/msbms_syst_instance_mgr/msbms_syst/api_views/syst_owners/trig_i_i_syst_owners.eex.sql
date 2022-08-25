CREATE OR REPLACE FUNCTION msbms_syst.trig_i_i_syst_owners()
RETURNS trigger AS
$BODY$

-- File:        trig_i_i_syst_owners.eex.sql
-- Location:    musebms/database/components/system/msbms_syst_instance_mgr/msbms_syst/api_views/syst_owners/trig_i_i_syst_owners.eex.sql
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

    INSERT INTO msbms_syst_data.syst_owners
        ( internal_name, display_name, owner_state_id )
    VALUES
        ( new.internal_name, new.display_name, new.owner_state_id )
    RETURNING * INTO new;

    RETURN new;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO msbms_syst, pg_temp;

ALTER FUNCTION msbms_syst.trig_i_i_syst_owners()
    OWNER TO <%= msbms_owner %>;

REVOKE EXECUTE ON FUNCTION msbms_syst.trig_i_i_syst_owners() FROM public;

COMMENT ON FUNCTION msbms_syst.trig_i_i_syst_owners() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_owners API View for INSERT operations.$DOC$;
