-- File:        syst_menus.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_nav/ms_syst/api_views/syst_menus/syst_menus.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

CREATE VIEW ms_syst.syst_menus AS
SELECT
    id
  , internal_name
  , display_name
  , menu_state_id
  , syst_description
  , user_description
  , syst_defined
  , user_maintainable
  , diag_timestamp_created
  , diag_role_created
  , diag_timestamp_modified
  , diag_wallclock_modified
  , diag_role_modified
  , diag_row_version
  , diag_update_count
FROM ms_syst_data.syst_menus;

ALTER VIEW ms_syst.syst_menus OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst.syst_menus FROM PUBLIC;

-- CREATE TRIGGER a50_trig_i_i_syst_menus
--     INSTEAD OF INSERT ON ms_syst.syst_menus
--     FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_i_syst_menus();
--
-- CREATE TRIGGER a50_trig_i_u_syst_menus
--     INSTEAD OF UPDATE ON ms_syst.syst_menus
--     FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_u_syst_menus();
--
-- CREATE TRIGGER a50_trig_i_d_syst_menus
--     INSTEAD OF DELETE ON ms_syst.syst_menus
--     FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_d_syst_menus();

DO
$DOCUMENTATION$
DECLARE
    -- View
    var_view_config ms_syst_priv.comments_config_apiview;

    -- View Columns
    var_menu_state_id ms_syst_priv.comments_config_apiview_column;

BEGIN

    --
    -- API View Config
    --

    var_view_config.table_schema := 'ms_syst_data';
    var_view_config.table_name   := 'syst_menus';
    var_view_config.view_schema  := 'ms_syst';
    var_view_config.view_name    := 'syst_menus';
    var_view_config.syst_records := TRUE;
    var_view_config.syst_update  := TRUE;
    var_view_config.syst_delete  := TRUE;

    --
    -- Column Configs
    --

    var_menu_state_id.column_name      := 'menu_state_id';
    var_menu_state_id.required         := TRUE;
    var_menu_state_id.syst_update_mode := 'maint';

    var_view_config.columns :=
        ARRAY [ var_menu_state_id ]::ms_syst_priv.comments_config_apiview_column[];

    PERFORM ms_syst_priv.generate_comments_apiview( var_view_config );

END;
$DOCUMENTATION$;
