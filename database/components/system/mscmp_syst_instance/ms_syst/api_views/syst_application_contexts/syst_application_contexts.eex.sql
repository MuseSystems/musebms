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
    v_view_config ms_syst_priv.comments_config_apiview;

    -- View Columns
    v_application_id         ms_syst_priv.comments_config_apiview_column;
    v_description            ms_syst_priv.comments_config_apiview_column;
    v_start_context          ms_syst_priv.comments_config_apiview_column;
    v_login_context          ms_syst_priv.comments_config_apiview_column;
    v_database_owner_context ms_syst_priv.comments_config_apiview_column;

BEGIN

    --
    -- API View Config
    --

    v_view_config.table_schema := 'ms_syst_data';
    v_view_config.table_name   := 'syst_application_contexts';
    v_view_config.view_schema  := 'ms_syst';
    v_view_config.view_name    := 'syst_application_contexts';
    v_view_config.syst_records := TRUE;
    v_view_config.syst_update  := TRUE;
    v_view_config.syst_delete  := TRUE;

    --
    -- Column Configs
    --

    v_application_id.column_name := 'application_id';
    v_application_id.required    := TRUE;
    v_application_id.user_update := FALSE;

    v_description.column_name      := 'description';
    v_description.required         := TRUE;
    v_description.syst_update_mode := 'always';

    v_start_context.column_name      := 'start_context';
    v_start_context.required         := TRUE;
    v_start_context.syst_update_mode := 'always';

    v_login_context.column_name := 'login_context';
    v_login_context.required    := TRUE;
    v_login_context.user_update := FALSE;

    v_database_owner_context.column_name := 'database_owner_context';
    v_database_owner_context.required    := TRUE;
    v_database_owner_context.user_update := FALSE;

    v_view_config.columns :=
        ARRAY [
             v_application_id
            ,v_description
            ,v_start_context
            ,v_login_context
            ,v_database_owner_context
        ]::ms_syst_priv.comments_config_apiview_column[];

    PERFORM ms_syst_priv.generate_comments_apiview( v_view_config );

END;
$DOCUMENTATION$;
