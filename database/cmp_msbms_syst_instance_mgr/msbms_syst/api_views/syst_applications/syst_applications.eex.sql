-- File:        syst_applications.eex.sql
-- Location:    database\cmp_msbms_syst_instance_mgr\msbms_syst\api_views\syst_applications\syst_applications.eex.sql
-- Project:     Muse Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE VIEW msbms_syst.syst_applications AS
    SELECT
        id
       ,internal_name
       ,display_name
       ,syst_description
       ,diag_timestamp_created
       ,diag_role_created
       ,diag_timestamp_modified
       ,diag_wallclock_modified
       ,diag_role_modified
       ,diag_row_version
       ,diag_update_count
    FROM msbms_syst_data.syst_applications;

ALTER VIEW msbms_syst.syst_applications OWNER TO <%= msbms_owner %>;

REVOKE ALL ON TABLE msbms_syst.syst_applications FROM PUBLIC;

COMMENT ON
    VIEW msbms_syst.syst_applications IS
$DOC$Describes the known applications which is managed by the global database and
authentication infrastructure.

This API View allows the application to read the data according to well defined
application business rules.

Attempts at invalid data maintenance via this API may result in the invalid
changes being ignored or may raise an exception.$DOC$;
