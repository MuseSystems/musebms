-- File:        syst_interaction_actions.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_interaction/ms_syst/api_views/syst_interaction_actions/syst_interaction_actions.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

CREATE VIEW ms_syst.syst_interaction_actions AS
SELECT
    id
  , interaction_context_id
  , internal_name
  , perm_id
  , interaction_category_id
  , diag_timestamp_created
  , diag_role_created
  , diag_timestamp_modified
  , diag_wallclock_modified
  , diag_role_modified
  , diag_row_version
  , diag_update_count
FROM ms_syst_data.syst_interaction_actions;

ALTER VIEW ms_syst.syst_interaction_actions OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst.syst_interaction_actions FROM PUBLIC;

CREATE TRIGGER a50_trig_i_i_syst_interaction_actions
    INSTEAD OF INSERT ON ms_syst.syst_interaction_actions
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_i_syst_interaction_actions();

CREATE TRIGGER a50_trig_i_u_syst_interaction_actions
    INSTEAD OF UPDATE ON ms_syst.syst_interaction_actions
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_u_syst_interaction_actions();

CREATE TRIGGER a50_trig_i_d_syst_interaction_actions
    INSTEAD OF DELETE ON ms_syst.syst_interaction_actions
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_d_syst_interaction_actions();

DO
$DOCUMENTATION$
DECLARE
    -- View
    var_view_config ms_syst_priv.comments_config_apiview;

    -- View Columns
    var_interaction_context_id  ms_syst_priv.comments_config_apiview_column;
    var_perm_id                 ms_syst_priv.comments_config_apiview_column;
    var_interaction_category_id ms_syst_priv.comments_config_apiview_column;

BEGIN

    --
    -- API View Config
    --

    var_view_config.table_schema := 'ms_syst_data';
    var_view_config.table_name   := 'syst_interaction_actions';
    var_view_config.view_schema  := 'ms_syst';
    var_view_config.view_name    := 'syst_interaction_actions';
    var_view_config.user_records := FALSE;
    var_view_config.syst_records := TRUE;
    var_view_config.syst_select  := TRUE;
    var_view_config.syst_update  := TRUE;
    var_view_config.syst_delete  := FALSE;
    var_view_config.generate_common := TRUE;
    var_view_config.supplemental :=
$DOC$While this API View doesn't currently allow the creation of strictly "User
Defined" records, if the parent Integration Context record is user maintainable,
this API view will allow the creation of new records.  These user added records,
while created by the user, would still be considered "System Defined" and would
be immediately subject to the normal limitations applied to System Defined
Interaction Context records; for example, such a newly added Interaction Action
record would not be deletable.$DOC$;

    --
    -- Column Configs
    --

    var_interaction_context_id.column_name      := 'interaction_context_id';
    var_interaction_context_id.required         := TRUE;
    var_interaction_context_id.user_update      := FALSE;

    var_perm_id.column_name      := 'perm_id';
    var_perm_id.syst_update_mode := 'maint';

    var_interaction_category_id.column_name      := 'interaction_category_id';
    var_interaction_category_id.syst_update_mode := 'maint';

    var_view_config.columns :=
        ARRAY [
            var_interaction_context_id
            ,var_perm_id
            ,var_interaction_category_id
            ]::ms_syst_priv.comments_config_apiview_column[];

    PERFORM ms_syst_priv.generate_comments_apiview( var_view_config );

END;
$DOCUMENTATION$;
