-- File:        syst_access_account_perm_role_assigns.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_mcp_perms/ms_syst/api_views/syst_access_account_perm_role_assigns/syst_access_account_perm_role_assigns.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

CREATE VIEW ms_syst.syst_access_account_perm_role_assigns AS
    SELECT
          id
        , access_account_id
        , perm_role_id
        , diag_timestamp_created
        , diag_role_created
        , diag_timestamp_modified
        , diag_wallclock_modified
        , diag_role_modified
        , diag_row_version
        , diag_update_count
    FROM ms_syst_data.syst_access_account_perm_role_assigns;

ALTER VIEW ms_syst.syst_access_account_perm_role_assigns OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst.syst_access_account_perm_role_assigns FROM PUBLIC;

CREATE TRIGGER a50_trig_i_i_syst_access_account_perm_role_assigns
    INSTEAD OF INSERT ON ms_syst.syst_access_account_perm_role_assigns
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_i_syst_access_account_perm_role_assigns();

CREATE TRIGGER a50_trig_i_u_syst_access_account_perm_role_assigns
    INSTEAD OF UPDATE ON ms_syst.syst_access_account_perm_role_assigns
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_u_syst_access_account_perm_role_assigns();

CREATE TRIGGER a50_trig_i_d_syst_access_account_perm_role_assigns
    INSTEAD OF DELETE ON ms_syst.syst_access_account_perm_role_assigns
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_d_syst_access_account_perm_role_assigns();

DO
$DOCUMENTATION$
DECLARE
    -- View
    v_view_config ms_syst_priv.comments_config_apiview;

    -- View Columns
    v_access_account_id ms_syst_priv.comments_config_apiview_column;
    v_perm_role_id      ms_syst_priv.comments_config_apiview_column;

BEGIN

    --
    -- API View Config
    --

    v_view_config.table_schema := 'ms_syst_data';
    v_view_config.table_name   := 'syst_access_account_perm_role_assigns';
    v_view_config.view_schema  := 'ms_syst';
    v_view_config.view_name    := 'syst_access_account_perm_role_assigns';
    v_view_config.user_update  := FALSE;

    --
    -- Column Configs
    --

    v_access_account_id.column_name  := 'access_account_id';
    v_access_account_id.required     := TRUE;
    v_access_account_id.supplemental :=
$DOC$This column is part of a composite key.  The combined values of
`access_account_id` and `perm_role_id` must be unique.$DOC$;

    v_perm_role_id.column_name  := 'perm_role_id';
    v_perm_role_id.required     := TRUE;
    v_perm_role_id.supplemental :=
$DOC$This column is part of a composite key.  The combined values of
`access_account_id` and `perm_role_id` must be unique.$DOC$;

    v_view_config.columns :=
        ARRAY [
              v_access_account_id
            , v_perm_role_id
            ]::ms_syst_priv.comments_config_apiview_column[];

    PERFORM ms_syst_priv.generate_comments_apiview( v_view_config );

END;
$DOCUMENTATION$;
