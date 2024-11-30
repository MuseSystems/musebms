-- File:        syst_hierarchy_items.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_hierarchy/ms_syst/api_views/syst_hierarchy_items/syst_hierarchy_items.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

CREATE VIEW ms_syst.syst_hierarchy_items AS
SELECT
    id
  , internal_name
  , display_name
  , external_name
  , hierarchy_id
  , hierarchy_depth
  , required
  , allow_leaf_nodes
  , diag_timestamp_created
  , diag_role_created
  , diag_timestamp_modified
  , diag_wallclock_modified
  , diag_role_modified
  , diag_row_version
  , diag_update_count
FROM ms_syst_data.syst_hierarchy_items;

ALTER VIEW ms_syst.syst_hierarchy_items OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst.syst_hierarchy_items FROM PUBLIC;

CREATE TRIGGER a50_trig_i_i_syst_hierarchy_items
    INSTEAD OF INSERT ON ms_syst.syst_hierarchy_items
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_i_syst_hierarchy_items();

CREATE TRIGGER a50_trig_i_u_syst_hierarchy_items
    INSTEAD OF UPDATE ON ms_syst.syst_hierarchy_items
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_u_syst_hierarchy_items();

CREATE TRIGGER a50_trig_i_d_syst_hierarchy_items
    INSTEAD OF DELETE ON ms_syst.syst_hierarchy_items
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_d_syst_hierarchy_items();

DO
$DOCUMENTATION$
DECLARE
    -- View
    v_view_config ms_syst_priv.comments_config_apiview;

    -- View Columns
    v_hierarchy_id     ms_syst_priv.comments_config_apiview_column;
    v_hierarchy_depth  ms_syst_priv.comments_config_apiview_column;
    v_required         ms_syst_priv.comments_config_apiview_column;
    v_allow_leaf_nodes ms_syst_priv.comments_config_apiview_column;

BEGIN

    --
    -- API View Config
    --

    v_view_config.table_schema := 'ms_syst_data';
    v_view_config.table_name   := 'syst_hierarchy_items';
    v_view_config.view_schema  := 'ms_syst';
    v_view_config.view_name    := 'syst_hierarchy_items';
    v_view_config.syst_records := TRUE;
    v_view_config.syst_select  := TRUE;
    v_view_config.syst_update  := TRUE;
    v_view_config.syst_delete  := TRUE;
    v_view_config.supplemental :=
$DOC$Once the Hierarchy is active and in use by Hierarchy implementing Components,
most changes to the Hierarchy Item records will not be allowed to ensure the
consistency of currently used data.  Also for data consistency reasons, using
this API view imposes the fundamental restriction that Hierarchy Item
hierarchies can only be constructed top down and deconstructed bottom up.
Updates are limited to allowing some naming updates, but not updates in
hierarchy changes.$DOC$;

    --
    -- Column Configs
    --

    v_hierarchy_id.column_name      := 'hierarchy_id';
    v_hierarchy_id.required         := TRUE;
    v_hierarchy_id.user_update      := FALSE;

    v_hierarchy_depth.column_name      := 'hierarchy_depth';
    v_hierarchy_depth.user_update      := FALSE;

    v_required.column_name      := 'required';
    v_required.required         := TRUE;
    v_required.syst_update_mode := 'maint';

    v_allow_leaf_nodes.column_name      := 'allow_leaf_nodes';
    v_allow_leaf_nodes.required         := TRUE;
    v_allow_leaf_nodes.syst_update_mode := 'maint';


    v_view_config.columns :=
        ARRAY [
              v_hierarchy_id
            , v_hierarchy_depth
            , v_required
            , v_allow_leaf_nodes
            ]::ms_syst_priv.comments_config_apiview_column[];

    PERFORM ms_syst_priv.generate_comments_apiview( v_view_config );

END;
$DOCUMENTATION$;
