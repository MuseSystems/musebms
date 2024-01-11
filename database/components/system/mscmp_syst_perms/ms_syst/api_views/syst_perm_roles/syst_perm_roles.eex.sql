-- File:        syst_perm_roles.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_perms/ms_syst/api_views/syst_perm_roles/syst_perm_roles.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems
CREATE VIEW ms_syst.syst_perm_roles AS
SELECT
    id
  , internal_name
  , display_name
  , perm_functional_type_id
  , syst_defined
  , syst_description
  , user_description
  , diag_timestamp_created
  , diag_role_created
  , diag_timestamp_modified
  , diag_wallclock_modified
  , diag_role_modified
  , diag_row_version
  , diag_update_count
FROM ms_syst_data.syst_perm_roles;

ALTER VIEW ms_syst.syst_perm_roles OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst.syst_perm_roles FROM PUBLIC;

CREATE TRIGGER a50_trig_i_i_syst_perm_roles
    INSTEAD OF INSERT ON ms_syst.syst_perm_roles
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_i_syst_perm_roles();

CREATE TRIGGER a50_trig_i_u_syst_perm_roles
    INSTEAD OF UPDATE ON ms_syst.syst_perm_roles
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_u_syst_perm_roles();

CREATE TRIGGER a50_trig_i_d_syst_perm_roles
    INSTEAD OF DELETE ON ms_syst.syst_perm_roles
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_d_syst_perm_roles();

DO
$DOCUMENTATION$
DECLARE
    -- View
    var_view_config ms_syst_priv.comments_config_apiview;

    -- View Columns
    var_perm_functional_type_id ms_syst_priv.comments_config_apiview_column;

BEGIN

    --
    -- API View Config
    --

    var_view_config.table_schema := 'ms_syst_data';
    var_view_config.table_name   := 'syst_perm_roles';
    var_view_config.view_schema  := 'ms_syst';
    var_view_config.view_name    := 'syst_perm_roles';
    var_view_config.syst_records := TRUE;
    var_view_config.syst_update  := TRUE;

    --
    -- Column Configs
    --

    var_perm_functional_type_id.column_name      := 'perm_functional_type_id';
    var_perm_functional_type_id.required         := TRUE;
    var_perm_functional_type_id.user_update      := FALSE;

    var_view_config.columns :=
        ARRAY [ var_perm_functional_type_id ]::ms_syst_priv.comments_config_apiview_column[];

    PERFORM ms_syst_priv.generate_comments_apiview( var_view_config );

END;
$DOCUMENTATION$;
