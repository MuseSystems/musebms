-- File:        syst_instances.eex.sql
-- Location:    database\cmp_msbms_syst_instance_mgr\msbms_syst\api_views\syst_instances\syst_instances.eex.sql
-- Project:     Muse Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE VIEW msbms_syst.syst_instances AS
SELECT
    id
  , internal_name
  , display_name
  , application_id
  , instance_type_id
  , instance_state_id
  , owner_id
  , owning_instance_id
  , instance_options
  , diag_timestamp_created
  , diag_role_created
  , diag_timestamp_modified
  , diag_wallclock_modified
  , diag_role_modified
  , diag_row_version
  , diag_update_count
FROM msbms_syst_data.syst_instances;

ALTER VIEW msbms_syst.syst_instances OWNER TO <%= msbms_owner %>;

REVOKE ALL ON TABLE msbms_syst.syst_instances FROM PUBLIC;

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE msbms_syst.syst_instances TO <%= msbms_appusr %>;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE msbms_syst.syst_instances TO <%= msbms_apiusr %>;

-- CREATE TRIGGER a50_trig_i_i_syst_instances
--     INSTEAD OF INSERT ON msbms_syst.syst_instances
--     FOR EACH ROW EXECUTE PROCEDURE msbms_syst.trig_i_i_syst_instances();
--
-- CREATE TRIGGER a50_trig_i_u_syst_instances
--     INSTEAD OF UPDATE ON msbms_syst.syst_instances
--     FOR EACH ROW EXECUTE PROCEDURE msbms_syst.trig_i_u_syst_instances();
--
-- CREATE TRIGGER a50_trig_i_d_syst_instances
--     INSTEAD OF DELETE ON msbms_syst.syst_instances
--     FOR EACH ROW EXECUTE PROCEDURE msbms_syst.trig_i_d_syst_instances();

COMMENT ON
    VIEW msbms_syst.syst_instances IS
$DOC$Defines known application instances and provides their configuration settings.

This API View allows the application to read and maintain the data according to
well defined application business rules.  Using this API view for updates to
data is the preferred method of data maintenance in the course of normal usage.

Only user maintainable values may be maintained via this API.  System created or
maintained data is not maintainable via this view.  Attempts at invalid data
maintenance via this API may result in the invalid changes being ignored or may
raise an exception.$DOC$;
