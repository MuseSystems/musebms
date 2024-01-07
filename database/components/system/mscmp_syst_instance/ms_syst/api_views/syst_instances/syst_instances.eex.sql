-- File:        syst_instances.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_instance/ms_syst/api_views/syst_instances/syst_instances.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE VIEW ms_syst.syst_instances AS
SELECT
    id
  , internal_name
  , display_name
  , application_id
  , instance_type_id
  , instance_state_id
  , owner_id
  , owning_instance_id
  , dbserver_name
  , instance_code
  , instance_options
  , diag_timestamp_created
  , diag_role_created
  , diag_timestamp_modified
  , diag_wallclock_modified
  , diag_role_modified
  , diag_row_version
  , diag_update_count
FROM ms_syst_data.syst_instances;

ALTER VIEW ms_syst.syst_instances OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst.syst_instances FROM PUBLIC;

CREATE TRIGGER a50_trig_i_i_syst_instances
    INSTEAD OF INSERT ON ms_syst.syst_instances
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_i_syst_instances();

CREATE TRIGGER a50_trig_i_u_syst_instances
    INSTEAD OF UPDATE ON ms_syst.syst_instances
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_u_syst_instances();

CREATE TRIGGER a50_trig_i_d_syst_instances
    INSTEAD OF DELETE ON ms_syst.syst_instances
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_d_syst_instances();

DO
$DOCUMENTATION$
DECLARE
    -- View
    var_view_config ms_syst_priv.comments_config_apiview;

    -- View Columns
    var_application_id     ms_syst_priv.comments_config_apiview_column;
    var_instance_type_id   ms_syst_priv.comments_config_apiview_column;
    var_instance_state_id  ms_syst_priv.comments_config_apiview_column;
    var_owner_id           ms_syst_priv.comments_config_apiview_column;
    var_owning_instance_id ms_syst_priv.comments_config_apiview_column;
    var_dbserver_name      ms_syst_priv.comments_config_apiview_column;
    var_instance_code      ms_syst_priv.comments_config_apiview_column;
    var_instance_options   ms_syst_priv.comments_config_apiview_column;

BEGIN

    --
    -- API View Config
    --

    var_view_config.table_schema := 'ms_syst_data';
    var_view_config.table_name   := 'syst_instances';
    var_view_config.view_schema  := 'ms_syst';
    var_view_config.view_name    := 'syst_instances';

    --
    -- Column Configs
    --

    var_application_id.column_name := 'application_id';
    var_application_id.required    := TRUE;
    var_application_id.user_update := FALSE;

    var_instance_type_id.column_name := 'instance_type_id';
    var_instance_type_id.required    := TRUE;
    var_instance_type_id.user_update := FALSE;

    var_instance_state_id.column_name := 'instance_state_id';
    var_instance_state_id.required    := TRUE;

    var_owner_id.column_name := 'owner_id';
    var_owner_id.required    := TRUE;
    var_owner_id.user_update := FALSE;

    var_owning_instance_id.column_name      := 'owning_instance_id';
    var_owning_instance_id.required         := TRUE;
    var_owning_instance_id.user_update      := FALSE;

    var_dbserver_name.column_name      := 'dbserver_name';
    var_dbserver_name.required         := TRUE;

    var_instance_code.column_name      := 'instance_code';
    var_instance_code.required         := TRUE;

    var_instance_options.column_name      := 'instance_options';

    var_view_config.columns :=
        ARRAY [
              var_application_id
            , var_instance_type_id
            , var_instance_state_id
            , var_owner_id
            , var_owning_instance_id
            , var_dbserver_name
            , var_instance_code
            , var_instance_options
            ]::ms_syst_priv.comments_config_apiview_column[];

    PERFORM ms_syst_priv.generate_comments_apiview( var_view_config );

END;
$DOCUMENTATION$;
