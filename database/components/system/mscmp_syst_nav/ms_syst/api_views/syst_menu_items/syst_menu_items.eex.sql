-- File:        syst_menu_items.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_nav/ms_syst/api_views/syst_menu_items/syst_menu_items.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

CREATE VIEW ms_syst.syst_menu_items AS
SELECT
    id
  , internal_name
  , display_name
  , external_name
  , menu_id
  , parent_menu_item_id
  , sort_order
  , submenu_menu_id
  , action_id
  , syst_description
  , user_description
  , diag_timestamp_created
  , diag_role_created
  , diag_timestamp_modified
  , diag_wallclock_modified
  , diag_role_modified
  , diag_row_version
  , diag_update_count
FROM ms_syst_data.syst_menu_items;

ALTER VIEW ms_syst.syst_menu_items OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst.syst_menu_items FROM PUBLIC;

CREATE TRIGGER a50_trig_i_i_syst_menu_items
    INSTEAD OF INSERT ON ms_syst.syst_menu_items
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_i_syst_menu_items();

CREATE TRIGGER a50_trig_i_u_syst_menu_items
    INSTEAD OF UPDATE ON ms_syst.syst_menu_items
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_u_syst_menu_items();

CREATE TRIGGER a50_trig_i_d_syst_menu_items
    INSTEAD OF DELETE ON ms_syst.syst_menu_items
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_d_syst_menu_items();

DO
$DOCUMENTATION$
DECLARE
    -- View
    v_view_config ms_syst_priv.comments_config_apiview;

    -- View Columns
    v_menu_id             ms_syst_priv.comments_config_apiview_column;
    v_parent_menu_item_id ms_syst_priv.comments_config_apiview_column;
    v_sort_order          ms_syst_priv.comments_config_apiview_column;
    v_submenu_menu_id     ms_syst_priv.comments_config_apiview_column;
    v_action_id           ms_syst_priv.comments_config_apiview_column;

BEGIN

    --
    -- API View Config
    --

    v_view_config.table_schema := 'ms_syst_data';
    v_view_config.table_name   := 'syst_menu_items';
    v_view_config.view_schema  := 'ms_syst';
    v_view_config.view_name    := 'syst_menu_items';
    v_view_config.syst_records := TRUE;
    v_view_config.syst_select  := TRUE;
    v_view_config.syst_update  := TRUE;
    v_view_config.syst_delete  := TRUE;

    --
    -- Column Configs
    --

    v_menu_id.column_name  := 'menu_id';
    v_menu_id.required     := TRUE;
    v_menu_id.user_update  := FALSE;
    v_menu_id.supplemental :=
$DOC$This column is part of a composite key.  The combined values of `menu_id`,
`parent_menu_item_id`, and `sort_order` must be unique.  The
`parent_menu_item_id` is allowed to be `NULL`, but all `NULL` in this column are
considered not distinct, therefore are treated as the same grouping for the
purposes of this uniqueness check.$DOC$;

    v_parent_menu_item_id.column_name  := 'parent_menu_item_id';
    v_parent_menu_item_id.user_update  := FALSE;
    v_parent_menu_item_id.supplemental :=
$DOC$This column is part of a composite key.  The combined values of `menu_id`,
`parent_menu_item_id`, and `sort_order` must be unique.  The
`parent_menu_item_id` is allowed to be `NULL`, but all `NULL` in this column are
considered not distinct, therefore are treated as the same grouping for the
purposes of this uniqueness check.$DOC$;

    v_sort_order.column_name      := 'sort_order';
    v_sort_order.required         := TRUE;
    v_sort_order.syst_update_mode := 'maint';
    v_sort_order.supplemental         :=
$DOC$This column is part of a composite key.  The combined values of `menu_id`,
`parent_menu_item_id`, and `sort_order` must be unique.  The
`parent_menu_item_id` is allowed to be `NULL`, but all `NULL` in this column are
considered not distinct, therefore are treated as the same grouping for the
purposes of this uniqueness check.$DOC$;

    v_submenu_menu_id.column_name      := 'submenu_menu_id';
    v_submenu_menu_id.syst_update_mode := 'maint';

    v_action_id.column_name      := 'action_id';
    v_action_id.syst_update_mode := 'maint';

    v_view_config.columns :=
        ARRAY [
              v_menu_id
            , v_parent_menu_item_id
            , v_sort_order
            , v_submenu_menu_id
            , v_action_id
            ]::ms_syst_priv.comments_config_apiview_column[];

    PERFORM ms_syst_priv.generate_comments_apiview( v_view_config );

END;
$DOCUMENTATION$;
