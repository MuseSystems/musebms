-- File:        syst_application_contexts.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_instance/ms_syst/api_views/syst_application_contexts/syst_application_contexts.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE VIEW ms_syst.syst_application_contexts AS
SELECT
    id
  , internal_name
  , display_name
  , application_id
  , description
  , start_context
  , login_context
  , database_owner_context
  , diag_timestamp_created
  , diag_role_created
  , diag_timestamp_modified
  , diag_wallclock_modified
  , diag_role_modified
  , diag_row_version
  , diag_update_count
FROM ms_syst_data.syst_application_contexts;

ALTER VIEW ms_syst.syst_application_contexts OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst.syst_application_contexts FROM PUBLIC;

CREATE TRIGGER a50_trig_i_u_syst_application_contexts
    INSTEAD OF UPDATE ON ms_syst.syst_application_contexts
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_u_syst_application_contexts();

COMMENT ON
    VIEW ms_syst.syst_application_contexts IS
$DOC$Applications are written with certain security and connection
characteristics in mind which correlate to database roles used by the
application for establishing connections.  This table defines the datastore
contexts the application is expecting so that Instance records can be validated
against the expectations.

This API View allows the application to read and maintain the data according to
well defined application business rules.  Using this API view for updates to
data is the preferred method of data maintenance in the course of normal usage.

Only user maintainable values may be maintained via this API.  System created or
maintained data is not maintainable via this view.  Attempts at invalid data
maintenance via this API may result in the invalid changes being ignored or may
raise an exception.$DOC$;
