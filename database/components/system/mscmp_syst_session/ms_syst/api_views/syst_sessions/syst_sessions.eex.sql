-- File:        syst_sessions.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_session/ms_syst/api_views/syst_sessions/syst_sessions.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

CREATE VIEW ms_syst.syst_sessions AS
SELECT
    id
  , internal_name
  , session_data
  , session_expires
  , diag_timestamp_created
  , diag_role_created
  , diag_timestamp_modified
  , diag_wallclock_modified
  , diag_role_modified
  , diag_row_version
  , diag_update_count
FROM ms_syst_data.syst_sessions;

ALTER VIEW ms_syst.syst_sessions OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst.syst_sessions FROM PUBLIC;

CREATE TRIGGER a50_trig_i_i_syst_sessions
    INSTEAD OF INSERT ON ms_syst.syst_sessions
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_i_syst_sessions();

CREATE TRIGGER a50_trig_i_u_syst_sessions
    INSTEAD OF UPDATE ON ms_syst.syst_sessions
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_u_syst_sessions();

CREATE TRIGGER a50_trig_i_d_syst_sessions
    INSTEAD OF DELETE ON ms_syst.syst_sessions
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_d_syst_sessions();

DO
$DOCUMENTATION$
DECLARE
    -- View
    var_view_config ms_syst_priv.comments_config_apiview;

    -- View Columns
    var_session_data    ms_syst_priv.comments_config_apiview_column;
    var_session_expires ms_syst_priv.comments_config_apiview_column;

BEGIN

    --
    -- API View Config
    --

    var_view_config.table_schema := 'ms_syst_data';
    var_view_config.table_name   := 'syst_sessions';
    var_view_config.view_schema  := 'ms_syst';
    var_view_config.view_name    := 'syst_sessions';

    --
    -- Column Configs
    --

    var_session_data.column_name      := 'session_data';
    var_session_data.required         := FALSE;

    var_session_expires.column_name      := 'session_expires';
    var_session_expires.required         := TRUE;

    var_view_config.columns :=
        ARRAY [
              var_session_data
            , var_session_expires
            ]::ms_syst_priv.comments_config_apiview_column[];

    PERFORM ms_syst_priv.generate_comments_apiview( var_view_config );

END;
$DOCUMENTATION$;
