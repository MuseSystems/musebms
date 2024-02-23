-- File:        syst_interaction_contexts.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_interaction/ms_syst/api_views/syst_interaction_contexts/syst_interaction_contexts.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

CREATE VIEW ms_syst.syst_interaction_contexts AS
SELECT
    id
  , internal_name
  , display_name
  , interaction_category_id
  , perm_id
  , syst_defined
  , user_maintainable
  , syst_description
  , user_description
  , diag_timestamp_created
  , diag_role_created
  , diag_timestamp_modified
  , diag_wallclock_modified
  , diag_role_modified
  , diag_row_version
  , diag_update_count
FROM ms_syst_data.syst_interaction_contexts;

ALTER VIEW ms_syst.syst_interaction_contexts OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst.syst_interaction_contexts FROM PUBLIC;

CREATE TRIGGER a50_trig_i_i_syst_interaction_contexts
    INSTEAD OF INSERT ON ms_syst.syst_interaction_contexts
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_i_syst_interaction_contexts();

CREATE TRIGGER a50_trig_i_u_syst_interaction_contexts
    INSTEAD OF UPDATE ON ms_syst.syst_interaction_contexts
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_u_syst_interaction_contexts();

CREATE TRIGGER a50_trig_i_d_syst_interaction_contexts
    INSTEAD OF DELETE ON ms_syst.syst_interaction_contexts
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_d_syst_interaction_contexts();

DO
$DOCUMENTATION$
DECLARE
    -- View
    var_view_config ms_syst_priv.comments_config_apiview;

    -- View Columns
    var_interaction_category_id ms_syst_priv.comments_config_apiview_column;
    var_perm_id                 ms_syst_priv.comments_config_apiview_column;

BEGIN

    --
    -- API View Config
    --

    var_view_config.table_schema := 'ms_syst_data';
    var_view_config.table_name   := 'syst_interaction_contexts';
    var_view_config.view_schema  := 'ms_syst';
    var_view_config.view_name    := 'syst_interaction_contexts';
    var_view_config.syst_records := TRUE;
    var_view_config.syst_update  := TRUE;

    --
    -- Column Configs
    --

    var_interaction_category_id.column_name      := 'interaction_category_id';
    var_interaction_category_id.syst_update_mode := 'maint';

    var_perm_id.column_name      := 'perm_id';
    var_perm_id.syst_update_mode := 'maint';

    var_view_config.columns :=
        ARRAY [
            var_interaction_category_id
            ,var_perm_id]::ms_syst_priv.comments_config_apiview_column[];

    PERFORM ms_syst_priv.generate_comments_apiview( var_view_config );

END;
$DOCUMENTATION$;
