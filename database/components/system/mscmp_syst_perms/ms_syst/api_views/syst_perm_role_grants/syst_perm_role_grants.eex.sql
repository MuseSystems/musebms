-- File:        syst_perm_role_grants.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_perms/ms_syst/api_views/syst_perm_role_grants/syst_perm_role_grants.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

CREATE VIEW ms_syst.syst_perm_role_grants AS
SELECT
    id
  , perm_role_id
  , perm_id
  , view_scope
  , maint_scope
  , admin_scope
  , ops_scope
  , diag_timestamp_created
  , diag_role_created
  , diag_timestamp_modified
  , diag_wallclock_modified
  , diag_role_modified
  , diag_row_version
  , diag_update_count
FROM ms_syst_data.syst_perm_role_grants;

ALTER VIEW ms_syst.syst_perm_role_grants OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst.syst_perm_role_grants FROM PUBLIC;

CREATE TRIGGER a50_trig_i_i_syst_perm_role_grants
    INSTEAD OF INSERT ON ms_syst.syst_perm_role_grants
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_i_syst_perm_role_grants();

CREATE TRIGGER a50_trig_i_u_syst_perm_role_grants
    INSTEAD OF UPDATE ON ms_syst.syst_perm_role_grants
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_u_syst_perm_role_grants();

CREATE TRIGGER a50_trig_i_d_syst_perm_role_grants
    INSTEAD OF DELETE ON ms_syst.syst_perm_role_grants
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_d_syst_perm_role_grants();

DO
$DOCUMENTATION$
DECLARE
    -- View
    v_view_config ms_syst_priv.comments_config_apiview;

    -- View Columns
    v_perm_role_id ms_syst_priv.comments_config_apiview_column;
    v_perm_id      ms_syst_priv.comments_config_apiview_column;
    v_view_scope   ms_syst_priv.comments_config_apiview_column;
    v_maint_scope  ms_syst_priv.comments_config_apiview_column;
    v_admin_scope  ms_syst_priv.comments_config_apiview_column;
    v_ops_scope    ms_syst_priv.comments_config_apiview_column;

BEGIN

    --
    -- API View Config
    --

    v_view_config.table_schema := 'ms_syst_data';
    v_view_config.table_name   := 'syst_perm_role_grants';
    v_view_config.view_schema  := 'ms_syst';
    v_view_config.view_name    := 'syst_perm_role_grants';
    v_view_config.user_delete  := TRUE;
    v_view_config.syst_records := TRUE;

    --
    -- Column Configs
    --

    v_perm_role_id.column_name      := 'perm_role_id';
    v_perm_role_id.required         := TRUE;
    v_perm_role_id.default_value    := '( No Default Value )';
    v_perm_role_id.user_update      := FALSE;
    v_perm_role_id.supplemental     :=
$DOC$This column is part of a composite key.  The combined values of `perm_role_id`
and `perm_id` must be unique; `NULL` values, where allowed, are not considered
distinct for this uniqueness check.$DOC$;

    v_perm_id.column_name      := 'perm_id';
    v_perm_id.required         := TRUE;
    v_perm_id.user_update      := FALSE;
    v_perm_id.supplemental     :=
$DOC$This column is part of a composite key.  The combined values of `perm_role_id`
and `perm_id` must be unique; `NULL` values, where allowed, are not considered
distinct for this uniqueness check.$DOC$;

    v_view_scope.column_name      := 'view_scope';
    v_view_scope.required         := TRUE;

    v_maint_scope.column_name      := 'maint_scope';
    v_maint_scope.required         := TRUE;

    v_admin_scope.column_name      := 'admin_scope';
    v_admin_scope.required         := TRUE;

    v_ops_scope.column_name      := 'ops_scope';
    v_ops_scope.required         := TRUE;

    v_view_config.columns :=
        ARRAY [
              v_perm_role_id
            , v_perm_id
            , v_view_scope
            , v_maint_scope
            , v_admin_scope
            , v_ops_scope
            ]::ms_syst_priv.comments_config_apiview_column[];

    PERFORM ms_syst_priv.generate_comments_apiview( v_view_config );

END;
$DOCUMENTATION$;
