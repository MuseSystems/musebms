CREATE OR REPLACE FUNCTION ms_syst.trig_i_d_syst_access_account_instance_assocs()
RETURNS trigger AS
$BODY$

-- File:        trig_i_d_syst_access_account_instance_assocs.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/ms_syst/api_views/syst_access_account_instance_assocs/trig_i_d_syst_access_account_instance_assocs.eex.sql
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

    DELETE
    FROM ms_syst_data.syst_access_account_instance_assocs
    WHERE id = old.id
    RETURNING * INTO old;

    RETURN old;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO ms_syst, pg_temp;

ALTER FUNCTION ms_syst.trig_i_d_syst_access_account_instance_assocs()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_access_account_instance_assocs() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_access_account_instance_assocs() TO <%= ms_owner %>;

COMMENT ON FUNCTION ms_syst.trig_i_d_syst_access_account_instance_assocs() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_access_account_instance_assocs API View for DELETE operations.$DOC$;