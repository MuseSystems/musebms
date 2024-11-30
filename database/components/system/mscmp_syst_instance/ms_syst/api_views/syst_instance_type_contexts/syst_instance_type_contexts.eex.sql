-- File:        syst_instance_type_contexts.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_instance/ms_syst/api_views/syst_instance_type_contexts/syst_instance_type_contexts.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE VIEW ms_syst.syst_instance_type_contexts AS
SELECT
    id
  , instance_type_application_id
  , application_context_id
  , default_db_pool_size
  , diag_timestamp_created
  , diag_role_created
  , diag_timestamp_modified
  , diag_wallclock_modified
  , diag_role_modified
  , diag_row_version
  , diag_update_count
FROM ms_syst_data.syst_instance_type_contexts;

ALTER VIEW ms_syst.syst_instance_type_contexts OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst.syst_instance_type_contexts FROM PUBLIC;

CREATE TRIGGER a50_trig_i_i_syst_instance_type_contexts
    INSTEAD OF INSERT ON ms_syst.syst_instance_type_contexts
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_i_syst_instance_type_contexts();

CREATE TRIGGER a50_trig_i_u_syst_instance_type_contexts
    INSTEAD OF UPDATE ON ms_syst.syst_instance_type_contexts
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_u_syst_instance_type_contexts();

CREATE TRIGGER a50_trig_i_d_syst_instance_type_contexts
    INSTEAD OF DELETE ON ms_syst.syst_instance_type_contexts
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_d_syst_instance_type_contexts();

DO
$DOCUMENTATION$
DECLARE
    -- View
    v_view_config ms_syst_priv.comments_config_apiview;

    -- View Columns
    v_instance_type_application_id ms_syst_priv.comments_config_apiview_column;
    v_application_context_id       ms_syst_priv.comments_config_apiview_column;
    v_default_db_pool_size         ms_syst_priv.comments_config_apiview_column;

BEGIN

    --
    -- API View Config
    --

    v_view_config.table_schema := 'ms_syst_data';
    v_view_config.table_name   := 'syst_instance_type_contexts';
    v_view_config.view_schema  := 'ms_syst';
    v_view_config.view_name    := 'syst_instance_type_contexts';
    v_view_config.user_insert  := FALSE;
    v_view_config.user_delete  := FALSE;

    --
    -- Column Configs
    --

    v_instance_type_application_id.column_name := 'instance_type_application_id';
    v_instance_type_application_id.required    := TRUE;
    v_instance_type_application_id.user_insert := FALSE;
    v_instance_type_application_id.user_update := FALSE;

    v_application_context_id.column_name := 'application_context_id';
    v_application_context_id.required    := TRUE;
    v_application_context_id.user_insert := FALSE;
    v_application_context_id.user_update := FALSE;

    v_default_db_pool_size.column_name      := 'default_db_pool_size';
    v_default_db_pool_size.required         := TRUE;
    v_default_db_pool_size.user_insert      := FALSE;

    v_view_config.columns :=
        ARRAY [
              v_instance_type_application_id
            , v_application_context_id
            , v_default_db_pool_size
            ]::ms_syst_priv.comments_config_apiview_column[];

    PERFORM ms_syst_priv.generate_comments_apiview( v_view_config );

END;
$DOCUMENTATION$;
