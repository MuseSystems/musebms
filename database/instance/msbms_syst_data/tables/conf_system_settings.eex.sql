-- Source File: conf_system_settings.eex.sql
-- Location:    database/instance/msbms_syst_data/tables/conf_system_settings.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE TABLE msbms_syst_data.conf_system_settings
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v1( )
        CONSTRAINT conf_system_settings_pk PRIMARY KEY
    ,internal_name
        text
        NOT NULL
        CONSTRAINT conf_system_settings_internal_name_udx UNIQUE
    ,display_name
        text
        NOT NULL
        CONSTRAINT conf_system_settings_display_name_udx UNIQUE
    ,description
        text
        NOT
            NULL
    ,config_flag
        boolean
    ,config_integer
        bigint
    ,config_decimal
        numeric
    ,config_interval
        interval
    ,config_date
        date
    ,config_time
        time
    ,config_timestamp
        timestamptz
    ,config_json
        jsonb
    ,config_text
        text
    ,config_uuid
        uuid
    ,config_blob
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

ALTER TABLE msbms_syst_data.conf_system_settings OWNER TO <%= msbms_owner %>;

REVOKE ALL ON TABLE msbms_syst_data.conf_system_settings FROM public;
GRANT ALL ON TABLE msbms_syst_data.conf_system_settings TO <%= msbms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON msbms_syst_data.conf_system_settings
    FOR EACH ROW EXECUTE PROCEDURE msbms_syst_priv.trig_b_iu_set_diagnostic_columns();

COMMENT ON
    TABLE msbms_syst_data.conf_system_settings IS
$DOC$Configurations for controlling system behaviors via options.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.conf_system_settings.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.conf_system_settings.internal_name IS
$DOC$A candidate key useful for programmatic references to individual records.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.conf_system_settings.display_name IS
$DOC$A friendly name and candidate key for the record suitable for use in user
interfaces.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.conf_system_settings.description IS
$DOC$A text describing the meaning and use of the specific record.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.conf_system_settings.config_flag IS
$DOC$A boolean configuration point.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.conf_system_settings.config_integer IS
$DOC$An integer configuration point$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.conf_system_settings.config_decimal IS
$DOC$An decimal configuration point (not floating point).$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.conf_system_settings.config_interval IS
$DOC$An interval configuration point.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.conf_system_settings.config_date IS
$DOC$A date configuation point.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.conf_system_settings.config_time IS
$DOC$A time configuration point (without time zone).$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.conf_system_settings.config_timestamp IS
$DOC$A full datetime configuration point including time zone.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.conf_system_settings.config_json IS
$DOC$A JSON configuration point.  Note that duplicate keys at the same level are not
allowed.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.conf_system_settings.config_text IS
$DOC$A text configuration point.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.conf_system_settings.config_uuid IS
$DOC$A UUID configuration point.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.conf_system_settings.config_blob IS
$DOC$A binary configuration point.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.conf_system_settings.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.conf_system_settings.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.conf_system_settings.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.conf_system_settings.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.conf_system_settings.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.conf_system_settings.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.conf_system_settings.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;
