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

CREATE TRIGGER a50_trig_i_i_syst_application_contexts
    INSTEAD OF INSERT ON ms_syst.syst_application_contexts
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_i_syst_application_contexts();

CREATE TRIGGER a50_trig_i_u_syst_application_contexts
    INSTEAD OF UPDATE ON ms_syst.syst_application_contexts
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_u_syst_application_contexts();

CREATE TRIGGER a50_trig_i_d_syst_application_contexts
    INSTEAD OF DELETE ON ms_syst.syst_application_contexts
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_d_syst_application_contexts();

DO
$DOCUMENTATION$
DECLARE
    -- View
    var_view_config ms_syst_priv.comments_config_apiview;

    -- View Columns
    var_application_id         ms_syst_priv.comments_config_apiview_column;
    var_description            ms_syst_priv.comments_config_apiview_column;
    var_start_context          ms_syst_priv.comments_config_apiview_column;
    var_login_context          ms_syst_priv.comments_config_apiview_column;
    var_database_owner_context ms_syst_priv.comments_config_apiview_column;

BEGIN

    --
    -- API View Config
    --

    var_view_config.table_schema := 'ms_syst_data';
    var_view_config.table_name   := 'syst_application_contexts';
    var_view_config.view_schema  := 'ms_syst';
    var_view_config.view_name    := 'syst_application_contexts';
    var_view_config.syst_records := TRUE;
    var_view_config.syst_update  := TRUE;
    var_view_config.syst_delete  := TRUE;

    --
    -- Column Configs
    --

    var_application_id.column_name := 'application_id';
    var_application_id.required    := TRUE;
    var_application_id.user_update := FALSE;

    var_description.column_name      := 'description';
    var_description.required         := TRUE;
    var_description.syst_update_mode := 'always';

    var_start_context.column_name      := 'start_context';
    var_start_context.required         := TRUE;
    var_start_context.syst_update_mode := 'always';

    var_login_context.column_name := 'login_context';
    var_login_context.required    := TRUE;
    var_login_context.user_update := FALSE;

    var_database_owner_context.column_name := 'database_owner_context';
    var_database_owner_context.required    := TRUE;
    var_database_owner_context.user_update := FALSE;

    var_view_config.columns :=
        ARRAY [
             var_application_id
            ,var_description
            ,var_start_context
            ,var_login_context
            ,var_database_owner_context
        ]::ms_syst_priv.comments_config_apiview_column[];

    PERFORM ms_syst_priv.generate_comments_apiview( var_view_config );

END;
$DOCUMENTATION$;
