CREATE OR REPLACE FUNCTION msbms_syst.trig_i_u_syst_owners()
RETURNS trigger AS
$BODY$

-- File:        trig_i_u_syst_owners.eex.sql
-- Location:    database\cmp_msbms_syst_instance_mgr\msbms_syst\api_views\syst_owners\trig_i_u_syst_owners.eex.sql
-- Project:     Muse Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

BEGIN

    UPDATE msbms_syst_data.syst_owners SET
        internal_name  = new.internal_name
      , display_name   = new.display_name
      , owner_state_id = new.owner_state_id
    WHERE id = new.id
    RETURNING * INTO new;

    RETURN new;

END;
$BODY$
LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

ALTER FUNCTION msbms_syst.trig_i_u_syst_owners()
    OWNER TO <%= msbms_owner %>;

REVOKE EXECUTE ON FUNCTION msbms_syst.trig_i_u_syst_owners() FROM public;
GRANT EXECUTE ON FUNCTION msbms_syst.trig_i_u_syst_owners() TO <%= msbms_appusr %>;
GRANT EXECUTE ON FUNCTION msbms_syst.trig_i_u_syst_owners() TO <%= msbms_apiusr %>;


COMMENT ON FUNCTION msbms_syst.trig_i_u_syst_owners() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_owners API View for UPDATE operations.$DOC$;
