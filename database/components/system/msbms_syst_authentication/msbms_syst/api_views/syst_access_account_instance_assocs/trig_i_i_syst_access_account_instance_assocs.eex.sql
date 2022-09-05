CREATE OR REPLACE FUNCTION msbms_syst.trig_i_i_syst_access_account_instance_assocs()
RETURNS trigger AS
$BODY$

-- File:        trig_i_i_syst_access_account_instance_assocs.eex.sql
-- Location:    musebms/database/components/system/msbms_syst_authentication/msbms_syst/api_views/syst_access_account_instance_assocs/trig_i_i_syst_access_account_instance_assocs.eex.sql
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

    INSERT INTO msbms_syst_data.syst_access_account_instance_assocs
        ( access_account_id
        , instance_id
        , access_granted
        , invitation_issued
        , invitation_expires
        , invitation_declined )
    VALUES
        ( new.access_account_id
        , new.instance_id
        , new.access_granted
        , new.invitation_issued
        , new.invitation_expires
        , new.invitation_declined )
    RETURNING * INTO new;

    RETURN new;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO msbms_syst, pg_temp;

ALTER FUNCTION msbms_syst.trig_i_i_syst_access_account_instance_assocs()
    OWNER TO <%= msbms_owner %>;

REVOKE EXECUTE ON FUNCTION msbms_syst.trig_i_i_syst_access_account_instance_assocs() FROM public;
GRANT EXECUTE ON FUNCTION msbms_syst.trig_i_i_syst_access_account_instance_assocs() TO <%= msbms_owner %>;

COMMENT ON FUNCTION msbms_syst.trig_i_i_syst_access_account_instance_assocs() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_access_account_instance_assocs API View for INSERT operations.$DOC$;
