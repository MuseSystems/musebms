-- File:        syst_settings.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_settings/ms_syst_data/syst_settings/syst_settings.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE TABLE ms_syst_data.syst_settings
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v7( )
        CONSTRAINT syst_settings_pk PRIMARY KEY
    ,internal_name
        text
        NOT NULL
        CONSTRAINT syst_settings_internal_name_udx UNIQUE
    ,display_name
        text
        NOT NULL
        CONSTRAINT syst_settings_display_name_udx UNIQUE
    ,syst_defined
        boolean
        NOT NULL DEFAULT FALSE
    ,syst_description
        text
        NOT NULL
    ,user_description
        text
    ,setting_flag
        boolean
    ,setting_integer
        bigint
    ,setting_integer_range
        int8range
    ,setting_decimal
        numeric
    ,setting_decimal_range
        numrange
    ,setting_interval
        interval
    ,setting_date
        date
    ,setting_date_range
        daterange
    ,setting_time
        time
    ,setting_timestamp
        timestamptz
    ,setting_timestamp_range
        tstzrange
    ,setting_json
        jsonb
    ,setting_text
        text
    ,setting_uuid
        uuid
    ,setting_blob
        bytea
    ,diag_timestamp_created
        timestamptz
        NOT NULL DEFAULT now( )
    ,diag_role_created
        text
        NOT NULL
    ,diag_timestamp_modified
        timestamptz
        NOT NULL DEFAULT now( )
    ,diag_wallclock_modified
        timestamptz
        NOT NULL DEFAULT clock_timestamp( )
    ,diag_role_modified
        text
        NOT NULL
    ,diag_row_version
        bigint
        NOT NULL DEFAULT 1
    ,diag_update_count
        bigint
        NOT NULL DEFAULT 0
);

ALTER TABLE ms_syst_data.syst_settings OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst_data.syst_settings FROM public;
GRANT ALL ON TABLE ms_syst_data.syst_settings TO <%= ms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_syst_data.syst_settings
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

DO
$DOCUMENTATION$
DECLARE
    var_comments_config ms_syst_priv.comments_config_table;

    var_setting_flag            ms_syst_priv.comments_config_table_column;
    var_setting_integer         ms_syst_priv.comments_config_table_column;
    var_setting_integer_range   ms_syst_priv.comments_config_table_column;
    var_setting_decimal         ms_syst_priv.comments_config_table_column;
    var_setting_decimal_range   ms_syst_priv.comments_config_table_column;
    var_setting_interval        ms_syst_priv.comments_config_table_column;
    var_setting_date            ms_syst_priv.comments_config_table_column;
    var_setting_date_range      ms_syst_priv.comments_config_table_column;
    var_setting_time            ms_syst_priv.comments_config_table_column;
    var_setting_timestamp       ms_syst_priv.comments_config_table_column;
    var_setting_timestamp_range ms_syst_priv.comments_config_table_column;
    var_setting_json            ms_syst_priv.comments_config_table_column;
    var_setting_text            ms_syst_priv.comments_config_table_column;
    var_setting_uuid            ms_syst_priv.comments_config_table_column;
    var_setting_blob            ms_syst_priv.comments_config_table_column;
BEGIN
    var_comments_config.table_schema := 'ms_syst_data';
    var_comments_config.table_name   := 'syst_settings';

    var_comments_config.description :=
$DOC$Configuration data which establishes application behaviors, defaults, and
provides a reference center to interested application functionality.$DOC$;

    var_setting_flag.column_name := 'setting_flag';
    var_setting_flag.description :=
$DOC$A boolean configuration point.$DOC$;

    var_setting_integer.column_name := 'setting_integer';
    var_setting_integer.description :=
$DOC$An integer configuration point$DOC$;

    var_setting_integer_range.column_name := 'setting_integer_range';
    var_setting_integer_range.description :=
$DOC$An integer range configuration point.$DOC$;

    var_setting_decimal.column_name := 'setting_decimal';
    var_setting_decimal.description :=
$DOC$An decimal configuration point (not floating point).$DOC$;

    var_setting_decimal_range.column_name := 'setting_decimal_range';
    var_setting_decimal_range.description :=
$DOC$A decimal range configuration point.$DOC$;

    var_setting_interval.column_name := 'setting_interval';
    var_setting_interval.description :=
$DOC$An interval configuration point.$DOC$;

    var_setting_date.column_name := 'setting_date';
    var_setting_date.description :=
$DOC$A date configuation point.$DOC$;

    var_setting_date_range.column_name := 'setting_date_range';
    var_setting_date_range.description :=
$DOC$A date range configuration point.$DOC$;

    var_setting_time.column_name := 'setting_time';
    var_setting_time.description :=
$DOC$A time configuration point (without time zone).$DOC$;

    var_setting_timestamp.column_name := 'setting_timestamp';
    var_setting_timestamp.description :=
$DOC$A full datetime configuration point including time zone.$DOC$;

    var_setting_timestamp_range.column_name := 'setting_timestamp_range';
    var_setting_timestamp_range.description :=
$DOC$A range of timestamps with time zone configuration points.$DOC$;

    var_setting_json.column_name := 'setting_json';
    var_setting_json.description :=
$DOC$A JSON configuration point.  Note that duplicate keys at the same level are not
allowed.$DOC$;

    var_setting_text.column_name := 'setting_text';
    var_setting_text.description :=
$DOC$A text configuration point.$DOC$;

    var_setting_uuid.column_name := 'setting_uuid';
    var_setting_uuid.description :=
$DOC$A UUID configuration point.$DOC$;

    var_setting_blob.column_name := 'setting_blob';
    var_setting_blob.description :=
$DOC$A binary configuration point.$DOC$;

    var_comments_config.columns :=
        ARRAY
            [
              var_setting_flag
            , var_setting_integer
            , var_setting_integer_range
            , var_setting_decimal
            , var_setting_decimal_range
            , var_setting_interval
            , var_setting_date
            , var_setting_date_range
            , var_setting_time
            , var_setting_timestamp
            , var_setting_timestamp_range
            , var_setting_json
            , var_setting_text
            , var_setting_uuid
            , var_setting_blob]::ms_syst_priv.comments_config_table_column[];

    PERFORM ms_syst_priv.generate_comments_table( var_comments_config);

END;
$DOCUMENTATION$;
