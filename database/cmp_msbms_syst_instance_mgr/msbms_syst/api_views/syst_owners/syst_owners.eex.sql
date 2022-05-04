-- File:        syst_owners.eex.sql
-- Location:    database\cmp_msbms_syst_instance_mgr\msbms_syst\api_views\syst_owners\syst_owners.eex.sql
-- Project:     Muse Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE VIEW msbms_syst.syst_owners AS
    SELECT
        id
      , internal_name
      , display_name
      , owner_state_id
      , diag_timestamp_created
      , diag_role_created
      , diag_timestamp_modified
      , diag_wallclock_modified
      , diag_role_modified
      , diag_row_version
      , diag_update_count
    FROM msbms_syst_data.syst_owners;

ALTER VIEW msbms_syst.syst_owners OWNER TO <%= msbms_owner %>;

REVOKE ALL ON TABLE msbms_syst.syst_owners FROM PUBLIC;

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE msbms_syst.syst_owners TO <%= msbms_appusr %>;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE msbms_syst.syst_owners TO <%= msbms_apiusr %>;

-- CREATE TRIGGER a50_trig_i_i_syst_owners
--     INSTEAD OF INSERT ON msbms_syst.syst_owners
--     FOR EACH ROW EXECUTE PROCEDURE msbms_syst.trig_i_i_syst_owners();
--
-- CREATE TRIGGER a50_trig_i_u_syst_owners
--     INSTEAD OF UPDATE ON msbms_syst.syst_owners
--     FOR EACH ROW EXECUTE PROCEDURE msbms_syst.trig_i_u_syst_owners();
--
-- CREATE TRIGGER a50_trig_i_d_syst_owners
--     INSTEAD OF DELETE ON msbms_syst.syst_owners
--     FOR EACH ROW EXECUTE PROCEDURE msbms_syst.trig_i_d_syst_owners();

COMMENT ON
    VIEW msbms_syst.syst_owners IS
$DOC$Identifies instance owners.  Instance owners are typically the clients which
have commissioned the use of an application instance.

This API View allows the application to read and maintain the data according to
well defined application business rules.  Using this API view for updates to
data is the preferred method of data maintenance in the course of normal usage.

Only user maintainable values may be maintained via this API.  System created or
maintained data is not maintainable via this view.  Attempts at invalid data
maintenance via this API may result in the invalid changes being ignored or may
raise an exception.$DOC$;
