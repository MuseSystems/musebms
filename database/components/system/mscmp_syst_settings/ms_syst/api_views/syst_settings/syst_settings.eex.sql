-- File:        syst_settings.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_settings/ms_syst/api_views/syst_settings/syst_settings.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE VIEW ms_syst.syst_settings AS
    SELECT
        id
      , internal_name
      , display_name
      , syst_defined
      , syst_description
      , user_description
      , setting_flag
      , setting_integer
      , setting_integer_range
      , setting_decimal
      , setting_decimal_range
      , setting_interval
      , setting_date
      , setting_date_range
      , setting_time
      , setting_timestamp
      , setting_timestamp_range
      , setting_json
      , setting_text
      , setting_uuid
      , setting_blob
      , diag_timestamp_created
      , diag_role_created
      , diag_timestamp_modified
      , diag_wallclock_modified
      , diag_role_modified
      , diag_row_version
      , diag_update_count
    FROM ms_syst_data.syst_settings;

ALTER VIEW ms_syst.syst_settings OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst.syst_settings FROM PUBLIC;

CREATE TRIGGER a50_trig_i_i_syst_settings
    INSTEAD OF INSERT ON ms_syst.syst_settings
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_i_syst_settings();

CREATE TRIGGER a50_trig_i_u_syst_settings
    INSTEAD OF UPDATE ON ms_syst.syst_settings
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_u_syst_settings();

CREATE TRIGGER a50_trig_i_d_syst_settings
    INSTEAD OF DELETE ON ms_syst.syst_settings
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_d_syst_settings();

DO
$DOCUMENTATION$
DECLARE
    v_view_config ms_syst_priv.comments_config_apiview;

    v_setting_flag            ms_syst_priv.comments_config_apiview_column;
    v_setting_integer         ms_syst_priv.comments_config_apiview_column;
    v_setting_integer_range   ms_syst_priv.comments_config_apiview_column;
    v_setting_decimal         ms_syst_priv.comments_config_apiview_column;
    v_setting_decimal_range   ms_syst_priv.comments_config_apiview_column;
    v_setting_interval        ms_syst_priv.comments_config_apiview_column;
    v_setting_date            ms_syst_priv.comments_config_apiview_column;
    v_setting_date_range      ms_syst_priv.comments_config_apiview_column;
    v_setting_time            ms_syst_priv.comments_config_apiview_column;
    v_setting_timestamp       ms_syst_priv.comments_config_apiview_column;
    v_setting_timestamp_range ms_syst_priv.comments_config_apiview_column;
    v_setting_json            ms_syst_priv.comments_config_apiview_column;
    v_setting_text            ms_syst_priv.comments_config_apiview_column;
    v_setting_uuid            ms_syst_priv.comments_config_apiview_column;
    v_setting_blob            ms_syst_priv.comments_config_apiview_column;

BEGIN

    v_view_config.table_schema := 'ms_syst_data';
    v_view_config.table_name   := 'syst_settings';
    v_view_config.view_schema  := 'ms_syst';
    v_view_config.view_name    := 'syst_settings';
    v_view_config.syst_records := TRUE;
    v_view_config.syst_update  := TRUE;
    v_view_config.syst_delete  := FALSE;

    v_setting_flag.column_name := 'setting_flag';
    v_setting_flag.syst_update_mode := 'always';

    v_setting_integer.column_name := 'setting_integer';
    v_setting_integer.syst_update_mode := 'always';

    v_setting_integer_range.column_name := 'setting_integer_range';
    v_setting_integer_range.syst_update_mode := 'always';

    v_setting_decimal.column_name := 'setting_decimal';
    v_setting_decimal.syst_update_mode := 'always';

    v_setting_decimal_range.column_name := 'setting_decimal_range';
    v_setting_decimal_range.syst_update_mode := 'always';

    v_setting_interval.column_name := 'setting_interval';
    v_setting_interval.syst_update_mode := 'always';

    v_setting_date.column_name := 'setting_date';
    v_setting_date.syst_update_mode := 'always';

    v_setting_date_range.column_name := 'setting_date_range';
    v_setting_date_range.syst_update_mode := 'always';

    v_setting_time.column_name := 'setting_time';
    v_setting_time.syst_update_mode := 'always';

    v_setting_timestamp.column_name := 'setting_timestamp';
    v_setting_timestamp.syst_update_mode := 'always';

    v_setting_timestamp_range.column_name := 'setting_timestamp_range';
    v_setting_timestamp_range.syst_update_mode := 'always';

    v_setting_json.column_name := 'setting_json';
    v_setting_json.syst_update_mode := 'always';

    v_setting_text.column_name := 'setting_text';
    v_setting_text.syst_update_mode := 'always';

    v_setting_uuid.column_name := 'setting_uuid';
    v_setting_uuid.syst_update_mode := 'always';

    v_setting_blob.column_name := 'setting_blob';
    v_setting_blob.syst_update_mode := 'always';


    v_view_config.columns :=
        ARRAY [
              v_setting_flag
            , v_setting_integer
            , v_setting_integer_range
            , v_setting_decimal
            , v_setting_decimal_range
            , v_setting_interval
            , v_setting_date
            , v_setting_date_range
            , v_setting_time
            , v_setting_timestamp
            , v_setting_timestamp_range
            , v_setting_json
            , v_setting_text
            , v_setting_uuid
            , v_setting_blob
            ]::ms_syst_priv.comments_config_apiview_column[];

    PERFORM ms_syst_priv.generate_comments_apiview( v_view_config );

END;
$DOCUMENTATION$;
