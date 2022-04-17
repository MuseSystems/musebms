-- File:        syst_complex_format_values.eex.sql
-- Location:    database\cmp_msbms_syst_formats\msbms_syst_data\tables\syst_complex_format_values\syst_complex_format_values.eex.sql
-- Project:     Muse Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE TABLE msbms_syst_data.syst_complex_format_values
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v1( )
        CONSTRAINT syst_complex_format_values_pk PRIMARY KEY
    ,internal_name
        text COLLATE msbms_syst_priv.variant_insensitive
        NOT NULL
        CONSTRAINT syst_complex_format_values_internal_name_udx UNIQUE
    ,display_name
        text COLLATE msbms_syst_priv.variant_insensitive
        NOT NULL
        CONSTRAINT syst_complex_format_values_display_name_udx UNIQUE
    ,external_name
        text
        NOT NULL
    ,complex_format_id
        uuid
        NOT NULL
        CONSTRAINT syst_complex_format_values_complex_format_fk
            REFERENCES msbms_syst_data.syst_complex_formats (id) ON DELETE CASCADE
    ,format_default
        boolean
        NOT NULL DEFAULT FALSE
    ,syst_defined
        boolean
        NOT NULL DEFAULT FALSE
    ,user_maintainable
        boolean
        NOT NULL DEFAULT FALSE
    ,syst_description
        text
        NOT NULL
    ,user_description
        text
    ,sort_order
        integer
        NOT NULL
    ,syst_data
        jsonb
        NOT NULL
    ,syst_form
        jsonb
        NOT NULL
    ,user_data
        jsonb
    ,user_form
        jsonb
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

ALTER TABLE msbms_syst_data.syst_complex_format_values OWNER TO <%= msbms_owner %>;

REVOKE ALL ON TABLE msbms_syst_data.syst_complex_format_values FROM public;
GRANT ALL ON TABLE msbms_syst_data.syst_complex_format_values TO <%= msbms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON msbms_syst_data.syst_complex_format_values
    FOR EACH ROW EXECUTE PROCEDURE msbms_syst_priv.trig_b_iu_set_diagnostic_columns();

COMMENT ON
    TABLE msbms_syst_data.syst_complex_format_values IS
$DOC$The list of values provided by an enumeration as well as related behavioral and
informational metadata.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_complex_format_values.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_complex_format_values.internal_name IS
$DOC$A candidate key useful for programmatic references to individual records.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_complex_format_values.display_name IS
$DOC$A friendly name and candidate key for the record, suitable for use in user
interactions$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_complex_format_values.external_name IS
$DOC$A non-unique/non-key value used to display to users and external parties where
uniqueness is less of a concern than specific end user presentation.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_complex_format_values.complex_format_id IS
$DOC$The format record with which the value is associated.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_complex_format_values.format_default IS
$DOC$If true, indicates that this value is the default selection from all values
defined for the enumerations.  If false then the value record has no special
significance relative to defaulting.

Note that if a record is inserted or updated in this table with enum_default set
true, and another record already exists for the enumeration with its
enum_default set true, the newly inserted/updated record will take precedence
and the value record previously set to be default will have its enum_default
setting set to false.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_complex_format_values.syst_defined IS
$DOC$If true, indicates that the value was created by the system or system
installation process.  A false value indicates that the record was user created.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_complex_format_values.user_maintainable IS
$DOC$If true, the user may maintain the value including setting user_options or
even setting the record inactive/deleting it.  If false, the value record is
required by the system for correct operation.  The user_description and
user_options columns are always available for user maintenance regardless of
this setting.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_complex_format_values.syst_description IS
$DOC$A system default description describing the value and its use cases within the
enumeration.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_complex_format_values.user_description IS
$DOC$A custom user defined description which overrides the syst_description value
where it would otherwise be used.  If this column is set NULL the
syst_description value will be used.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_complex_format_values.sort_order IS
$DOC$Indicates the sort ordering of the particular value record with the lowest value
sorting first.  When a value record for an enumeration is inserted or updated
and this column is being set to a value which equals another enumeration value
record for the same enumeration, the system assumes that the new record is
being set to precede the existing record and it will be set to sort after the
newly inserted/updated enumeration value.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_complex_format_values.syst_data IS
$DOC$For the system expected data definition this column identifies the individual
fields that make up the complex format type along with the expected type and
other expected metadata for each field.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_complex_format_values.syst_form IS
$DOC$Describes how the individual data fields of the complex format are
presented in user interfaces and printed documents.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_complex_format_values.user_data IS
$DOC$Allows for custom user data fields to be defined in place of the system provided
data in syst_data.  Note that when this column is not null, it replaces the
system definition: it does not augment it.  This means that any system expected
data fields should also appear in the user data.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_complex_format_values.user_form IS
$DOC$Allows for custom user layout of the format data fields in user interfaces and
other user presentations.  Note that when this column is not null, it replaces
the system definition and so any system expected layout elements should also
be accounted for in this user layout.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_complex_format_values.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_complex_format_values.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_complex_format_values.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_complex_format_values.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_complex_format_values.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_complex_format_values.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_complex_format_values.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;
