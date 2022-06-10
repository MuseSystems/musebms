CREATE OR REPLACE FUNCTION msbms_syst_data.trig_a_i_syst_instance_type_apps_create_inst_type_contexts()
RETURNS trigger AS
$BODY$

-- File:        trig_a_i_syst_instance_type_apps_create_inst_type_contexts.eex.sql
-- Location:    database\cmp_msbms_syst_instance_mgr\msbms_syst_data\syst_instance_type_applications\trig_a_i_syst_instance_type_apps_create_inst_type_contexts.eex.sql
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

    INSERT INTO msbms_syst_data.syst_instance_type_contexts
        ( instance_type_application_id, application_context_id, default_db_pool_size )
    SELECT
        new.id
      , id
      , 0
    FROM msbms_syst_data.syst_application_contexts
    WHERE application_id = new.application_id;

    RETURN new;
END;
$BODY$
LANGUAGE plpgsql VOLATILE;

ALTER FUNCTION msbms_syst_data.trig_a_i_syst_instance_type_apps_create_inst_type_contexts()
    OWNER TO <%= msbms_owner %>;

REVOKE EXECUTE ON FUNCTION msbms_syst_data.trig_a_i_syst_instance_type_apps_create_inst_type_contexts() FROM public;
GRANT EXECUTE ON FUNCTION msbms_syst_data.trig_a_i_syst_instance_type_apps_create_inst_type_contexts() TO <%= msbms_owner %>;

COMMENT ON FUNCTION msbms_syst_data.trig_a_i_syst_instance_type_apps_create_inst_type_contexts() IS
$DOC$When a new association between an Application and an Instance Type is made by
inserting a record into this table, Instance Type Contexts are automatically
created by this function based on the Application Context records defined at the
time of INSERT into this table.  The default default_db_pool_size value is 0.

After the fact changes to Contexts must be managed manually.$DOC$;
