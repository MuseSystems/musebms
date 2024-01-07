-- File:        syst_applications.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_instance/ms_syst/api_views/syst_applications/syst_applications.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE VIEW ms_syst.syst_applications AS
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
    FROM ms_syst_data.syst_applications;

ALTER VIEW ms_syst.syst_applications OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst.syst_applications FROM PUBLIC;

CREATE TRIGGER a50_trig_i_i_syst_applications
    INSTEAD OF INSERT ON ms_syst.syst_applications
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_i_syst_applications();

CREATE TRIGGER a50_trig_i_u_syst_applications
    INSTEAD OF UPDATE ON ms_syst.syst_applications
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_u_syst_applications();

CREATE TRIGGER a50_trig_i_d_syst_applications
    INSTEAD OF DELETE ON ms_syst.syst_applications
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_d_syst_applications();

DO
$DOCUMENTATION$
DECLARE
    -- View
    var_view_config ms_syst_priv.comments_config_apiview;

BEGIN

    var_view_config.table_schema := 'ms_syst_data';
    var_view_config.table_name   := 'syst_applications';
    var_view_config.view_schema  := 'ms_syst';
    var_view_config.view_name    := 'syst_applications';
    var_view_config.user_delete  := FALSE;
    var_view_config.syst_records := TRUE;

    PERFORM ms_syst_priv.generate_comments_apiview( var_view_config );

END;
$DOCUMENTATION$;
