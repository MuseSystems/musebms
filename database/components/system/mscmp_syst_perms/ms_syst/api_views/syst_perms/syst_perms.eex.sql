-- File:        syst_perms.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_perms/ms_syst/api_views/syst_perms/syst_perms.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

CREATE VIEW ms_syst.syst_perms AS
SELECT
    id
  , internal_name
  , display_name
  , perm_functional_type_id
  , syst_defined
  , syst_description
  , user_description
  , view_scope_options
  , maint_scope_options
  , admin_scope_options
  , ops_scope_options
  , diag_timestamp_created
  , diag_role_created
  , diag_timestamp_modified
  , diag_wallclock_modified
  , diag_role_modified
  , diag_row_version
  , diag_update_count
FROM ms_syst_data.syst_perms;

ALTER VIEW ms_syst.syst_perms OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst.syst_perms FROM PUBLIC;

CREATE TRIGGER a50_trig_i_i_syst_perms
    INSTEAD OF INSERT ON ms_syst.syst_perms
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_i_syst_perms();

CREATE TRIGGER a50_trig_i_u_syst_perms
    INSTEAD OF UPDATE ON ms_syst.syst_perms
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_u_syst_perms();

CREATE TRIGGER a50_trig_i_d_syst_perms
    INSTEAD OF DELETE ON ms_syst.syst_perms
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_d_syst_perms();

DO
$DOCUMENTATION$
DECLARE
    -- View
    v_view_config ms_syst_priv.comments_config_apiview;

    -- View Columns
    v_perm_functional_type_id ms_syst_priv.comments_config_apiview_column;
    v_view_scope_options      ms_syst_priv.comments_config_apiview_column;
    v_maint_scope_options     ms_syst_priv.comments_config_apiview_column;
    v_admin_scope_options     ms_syst_priv.comments_config_apiview_column;
    v_ops_scope_options       ms_syst_priv.comments_config_apiview_column;

BEGIN

    --
    -- API View Config
    --

    v_view_config.table_schema := 'ms_syst_data';
    v_view_config.table_name   := 'syst_perms';
    v_view_config.view_schema  := 'ms_syst';
    v_view_config.view_name    := 'syst_perms';
    v_view_config.syst_records := TRUE;
    v_view_config.syst_update  := TRUE;

    --
    -- Column Configs
    --

    v_perm_functional_type_id.column_name := 'perm_functional_type_id';
    v_perm_functional_type_id.required    := TRUE;
    v_perm_functional_type_id.user_update := FALSE;

    v_view_scope_options.column_name := 'view_scope_options';
    v_view_scope_options.required    := TRUE;

    v_maint_scope_options.column_name := 'maint_scope_options';
    v_maint_scope_options.required    := TRUE;

    v_admin_scope_options.column_name := 'admin_scope_options';
    v_admin_scope_options.required    := TRUE;

    v_ops_scope_options.column_name := 'ops_scope_options';
    v_ops_scope_options.required    := TRUE;

    v_view_config.columns :=
        ARRAY [
              v_perm_functional_type_id
            , v_view_scope_options
            , v_maint_scope_options
            , v_admin_scope_options
            , v_ops_scope_options
            ]::ms_syst_priv.comments_config_apiview_column[];

    PERFORM ms_syst_priv.generate_comments_apiview( v_view_config );

END;
$DOCUMENTATION$;
