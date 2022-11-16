CREATE OR REPLACE FUNCTION msbms_syst_data.trig_b_d_syst_applications_delete_contexts()
RETURNS trigger AS
$BODY$

-- File:        trig_b_d_syst_applications_delete_contexts.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_instance/msbms_syst_data/syst_applications/trig_b_d_syst_applications_delete_contexts.eex.sql
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

    ALTER TABLE msbms_syst_data.syst_application_contexts
        DISABLE TRIGGER c50_trig_b_d_syst_application_contexts_validate_owner_context;

    DELETE FROM msbms_syst_data.syst_application_contexts WHERE application_id = old.id;

    ALTER TABLE msbms_syst_data.syst_application_contexts
        ENABLE TRIGGER c50_trig_b_d_syst_application_contexts_validate_owner_context;

    RETURN old;

END;
$BODY$
LANGUAGE plpgsql VOLATILE;

ALTER FUNCTION msbms_syst_data.trig_b_d_syst_applications_delete_contexts()
    OWNER TO <%= msbms_owner %>;

REVOKE EXECUTE ON FUNCTION msbms_syst_data.trig_b_d_syst_applications_delete_contexts() FROM public;
GRANT EXECUTE ON FUNCTION msbms_syst_data.trig_b_d_syst_applications_delete_contexts() TO <%= msbms_owner %>;

COMMENT ON FUNCTION msbms_syst_data.trig_b_d_syst_applications_delete_contexts() IS
$DOC$Deletes the Application Contexts prior to deleting the Application record
itself.  This is needed because the trigger preventing datastore context owner
contexts to be deleted must be disabled prior to the delete.$DOC$;
