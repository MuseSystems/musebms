-- File:        syst_complex_formats.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_formats/msbms_syst_data/syst_complex_formats/syst_complex_formats.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE TABLE msbms_syst_data.syst_complex_formats
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v1( )
        CONSTRAINT syst_complex_formats_pk PRIMARY KEY
    ,internal_name
        text
        NOT NULL
        CONSTRAINT syst_complex_formats_internal_name_udx UNIQUE
    ,display_name
        text
        NOT NULL
        CONSTRAINT syst_complex_formats_display_name_udx UNIQUE
    ,syst_description
        text
        NOT NULL
    ,user_description
        text
    ,feature_id
        uuid
        NOT NULL
        CONSTRAINT syst_complex_formats_feature_fk
            REFERENCES msbms_syst_data.syst_feature_map (id)
    ,syst_defined
        boolean
        NOT NULL DEFAULT FALSE
    ,user_maintainable
        boolean
        NOT NULL DEFAULT TRUE
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

ALTER TABLE msbms_syst_data.syst_complex_formats OWNER TO <%= msbms_owner %>;

REVOKE ALL ON TABLE msbms_syst_data.syst_complex_formats FROM public;
GRANT ALL ON TABLE msbms_syst_data.syst_complex_formats TO <%= msbms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON msbms_syst_data.syst_complex_formats
    FOR EACH ROW EXECUTE PROCEDURE msbms_syst_priv.trig_b_iu_set_diagnostic_columns();

COMMENT ON
    TABLE msbms_syst_data.syst_complex_formats IS
$DOC$Establishes definitions for complex data types and their user interface related
formatting.  Complex data types may include concepts such as street addresses,
personal names, and phone numbers; in each of these cases there are typically
multiple fields, but internationally there is no consistent definition of what
fields are available and how they should be ordered or arranged.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_complex_formats.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_complex_formats.internal_name IS
$DOC$A candidate key useful for programmatic references to individual records.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_complex_formats.display_name IS
$DOC$A friendly name and candidate key for the record, suitable for use in user
interactions$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_complex_formats.syst_description IS
$DOC$A default description of the format which might include details such as how the
format is used and what kind of functionality might be impacted by choosing
specific format values.

Note that users should not change this value.  For custom descriptions, use the
msbms_syst_data.syst_complex_formats.user_description field instead.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_complex_formats.user_description IS
$DOC$A user defined description of the format to support custom user
documentation of the purpose and function of the format.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_complex_formats.feature_id IS
$DOC$A reference to the specific feature of which the format is considered to be
part.  This reference is chiefly used to determine where in the configuration
options the format should appear.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_complex_formats.syst_defined IS
$DOC$If true, this value indicates that the format is considered part of the
application.  Often times, system formats are manageable by users, but the
existence of the format in the system is assumed to exist by the application.
If false, the assumption is that the format was created by users and supports
custom user functionality.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_complex_formats.user_maintainable IS
$DOC$When true, this column indicates that the format is user maintainable;
this might include the ability to add, edit, or remove format values.  When
false, the format is strictly system managed for any functional purpose.
Note that the value of this column doesn't effect the ability to set a
user_description value; the ability to set custom descriptions is always
available for any properly authorized user.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_complex_formats.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_complex_formats.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_complex_formats.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_complex_formats.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_complex_formats.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_complex_formats.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_complex_formats.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;
