CREATE OR REPLACE FUNCTION ms_syst.trig_i_i_syst_instance_type_applications()
RETURNS trigger AS
$BODY$

-- File:        trig_i_i_syst_instance_type_applications.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_instance/ms_syst/api_views/syst_instance_type_applications/trig_i_i_syst_instance_type_applications.eex.sql
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

    INSERT INTO ms_syst_data.syst_instance_type_applications
        ( instance_type_id, application_id )
    VALUES
        ( new.instance_type_id, new.application_id )
    RETURNING * INTO new;

    RETURN new;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO ms_syst, pg_temp;

ALTER FUNCTION ms_syst.trig_i_i_syst_instance_type_applications()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_instance_type_applications() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_instance_type_applications() TO <%= ms_owner %>;

COMMENT ON FUNCTION ms_syst.trig_i_i_syst_instance_type_applications() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_enum_items API View for INSERT operations.$DOC$;
