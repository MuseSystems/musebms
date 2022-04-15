-- File:        syst_settings.eex.sql
-- Location:    database\cmp_msbms_syst_settings\msbms_syst\api_views\syst_settings\syst_settings.eex.sql
-- Project:     Muse Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE VIEW msbms_syst.syst_settings AS
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
    FROM msbms_syst_data.syst_settings;

ALTER VIEW msbms_syst.syst_settings OWNER TO <%= msbms_owner %>;

REVOKE ALL ON TABLE msbms_syst.syst_settings FROM PUBLIC;

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE msbms_syst.syst_settings TO <%= msbms_appusr %>;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE msbms_syst.syst_settings TO <%= msbms_apiusr %>;

CREATE TRIGGER a50_trig_i_i_syst_settings
    INSTEAD OF INSERT ON msbms_syst.syst_settings
    FOR EACH ROW EXECUTE PROCEDURE msbms_syst.trig_i_i_syst_settings();

CREATE TRIGGER a50_trig_i_u_syst_settings
    INSTEAD OF UPDATE ON msbms_syst.syst_settings
    FOR EACH ROW EXECUTE PROCEDURE msbms_syst.trig_i_u_syst_settings();

CREATE TRIGGER a50_trig_i_d_syst_settings
    INSTEAD OF DELETE ON msbms_syst.syst_settings
    FOR EACH ROW EXECUTE PROCEDURE msbms_syst.trig_i_d_syst_settings();

COMMENT ON
    VIEW msbms_syst.syst_settings IS
$DOC$Configuration data which establishes application behaviors, defaults, and
provides a reference center to interested application functionality.

This API View allows the application to read and maintain the data according to
well defined application business rules.  Using this API view for updates to
data is the preferred method of data maintenance in the course of normal usage.$DOC$;

COMMENT ON
    COLUMN msbms_syst.syst_settings.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.

Note that this column may not be updated via this API View.$DOC$;

COMMENT ON
    COLUMN msbms_syst.syst_settings.internal_name IS
$DOC$A candidate key useful for programmatic references to individual records.

Note that this column may not be updated via this API View, though an initial
insert operation may set it initially$DOC$;

COMMENT ON
    COLUMN msbms_syst.syst_settings.display_name IS
$DOC$A friendly name and candidate key for the record suitable for use in user
interfaces.$DOC$;

COMMENT ON
    COLUMN msbms_syst.syst_settings.syst_defined IS
$DOC$When true, indicates that the setting was created as part of the system and is
expected to exist.  If false, the setting is user created and maintained.

Note that this column may not be updated via this API View.$DOC$;

COMMENT ON
    COLUMN msbms_syst.syst_settings.syst_description IS
$DOC$A text describing the meaning and use of the specific record.

Note that this column may not be updated via this API View.$DOC$;

COMMENT ON
    COLUMN msbms_syst.syst_settings.user_description IS
$DOC$A user customizable override of the system description text.  When the value in
this column is not NULL, this text will be displayed to users in preference to
the description found in syst_description.$DOC$;

COMMENT ON
    COLUMN msbms_syst.syst_settings.setting_flag IS
$DOC$A boolean configuration point.$DOC$;

COMMENT ON
    COLUMN msbms_syst.syst_settings.setting_integer IS
$DOC$An integer configuration point$DOC$;

COMMENT ON
    COLUMN msbms_syst.syst_settings.setting_integer_range IS
$DOC$An integer range configuration point.$DOC$;

COMMENT ON
    COLUMN msbms_syst.syst_settings.setting_decimal IS
$DOC$An decimal configuration point (not floating point).$DOC$;

COMMENT ON
    COLUMN msbms_syst.syst_settings.setting_decimal_range IS
$DOC$A decimal range configuration point.$DOC$;

COMMENT ON
    COLUMN msbms_syst.syst_settings.setting_interval IS
$DOC$An interval configuration point.$DOC$;

COMMENT ON
    COLUMN msbms_syst.syst_settings.setting_date IS
$DOC$A date configuation point.$DOC$;

COMMENT ON
    COLUMN msbms_syst.syst_settings.setting_date_range IS
$DOC$A date range configuration point.$DOC$;

COMMENT ON
    COLUMN msbms_syst.syst_settings.setting_time IS
$DOC$A time configuration point (without time zone).$DOC$;

COMMENT ON
    COLUMN msbms_syst.syst_settings.setting_timestamp IS
$DOC$A full datetime configuration point including time zone.$DOC$;

COMMENT ON
    COLUMN msbms_syst.syst_settings.setting_timestamp_range IS
$DOC$A range of timestamps with time zone configuration points.$DOC$;

COMMENT ON
    COLUMN msbms_syst.syst_settings.setting_json IS
$DOC$A JSON configuration point.  Note that duplicate keys at the same level are not
allowed.$DOC$;

COMMENT ON
    COLUMN msbms_syst.syst_settings.setting_text IS
$DOC$A text configuration point.$DOC$;

COMMENT ON
    COLUMN msbms_syst.syst_settings.setting_uuid IS
$DOC$A UUID configuration point.$DOC$;

COMMENT ON
    COLUMN msbms_syst.syst_settings.setting_blob IS
$DOC$A binary configuration point.$DOC$;

COMMENT ON
    COLUMN msbms_syst.syst_settings.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.

Note that this column may not be updated via this API View.$DOC$;

COMMENT ON
    COLUMN msbms_syst.syst_settings.diag_role_created IS
$DOC$The database role which created the record.

Note that this column may not be updated via this API View.$DOC$;

COMMENT ON
    COLUMN msbms_syst.syst_settings.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.

Note that this column may not be updated via this API View.$DOC$;

COMMENT ON
    COLUMN msbms_syst.syst_settings.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.

Note that this column may not be updated via this API View.$DOC$;

COMMENT ON
    COLUMN msbms_syst.syst_settings.diag_role_modified IS
$DOC$The database role which modified the record.

Note that this column may not be updated via this API View.$DOC$;

COMMENT ON
    COLUMN msbms_syst.syst_settings.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.

Note that this column may not be updated via this API View.$DOC$;

COMMENT ON
    COLUMN msbms_syst.syst_settings.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.

Note that this column may not be updated via this API View.$DOC$;
