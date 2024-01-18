CREATE OR REPLACE FUNCTION ms_syst_data.trig_b_d_syst_applications_delete_contexts()
RETURNS trigger AS
$BODY$

-- File:        trig_b_d_syst_applications_delete_contexts.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_instance/ms_syst_data/syst_applications/trig_b_d_syst_applications_delete_contexts.eex.sql
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

    ALTER TABLE ms_syst_data.syst_application_contexts
        DISABLE TRIGGER c50_trig_b_d_syst_application_contexts_validate_owner_context;

    DELETE FROM ms_syst_data.syst_application_contexts WHERE application_id = old.id;

    ALTER TABLE ms_syst_data.syst_application_contexts
        ENABLE TRIGGER c50_trig_b_d_syst_application_contexts_validate_owner_context;

    RETURN old;

END;
$BODY$
LANGUAGE plpgsql VOLATILE;

ALTER FUNCTION ms_syst_data.trig_b_d_syst_applications_delete_contexts()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst_data.trig_b_d_syst_applications_delete_contexts() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst_data.trig_b_d_syst_applications_delete_contexts() TO <%= ms_owner %>;

DO
$DOCUMENTATION$
DECLARE
    -- Function
    var_comments_config ms_syst_priv.comments_config_function;

BEGIN

    --
    -- Function Config
    --

    var_comments_config.function_schema := 'ms_syst_data';
    var_comments_config.function_name   := 'trig_b_d_syst_applications_delete_contexts';

    var_comments_config.trigger_function := TRUE;
    var_comments_config.trigger_timing   := ARRAY [ 'b' ]::text[ ];
    var_comments_config.trigger_ops      := ARRAY [ 'd' ]::text[ ];

    var_comments_config.description :=
$DOC$Deletes the Application Contexts prior to deleting the Application record
itself.  This is needed because the trigger preventing datastore context owner
contexts to be deleted must be disabled prior to the delete.$DOC$;

    PERFORM ms_syst_priv.generate_comments_function( var_comments_config );

END;
$DOCUMENTATION$;
