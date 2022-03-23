-- File:        conf_enum_values.eex.sql
-- Location:    database\common\msbms_syst_data\tables\conf_enum_values.eex.sql
-- Project:     Muse Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE TABLE msbms_syst_data.conf_enum_values
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v1( )
        CONSTRAINT conf_enum_values_pk PRIMARY KEY
    ,internal_name
        text COLLATE msbms_syst_priv.variant_insensitive
        NOT NULL
        CONSTRAINT conf_enum_values_internal_name_udx UNIQUE
    ,display_name
        text COLLATE msbms_syst_priv.variant_insensitive
        NOT NULL
        CONSTRAINT conf_enum_values_display_name_udx UNIQUE
    ,enum_id
        uuid
        NOT NULL
        CONSTRAINT conf_enum_values_enum_fk
            REFERENCES msbms_syst_data.conf_enums (id) ON DELETE CASCADE
    ,functional_type_id
        uuid
        CONSTRAINT conf_enum_values_enum_functional_type_fk
            REFERENCES msbms_syst_data.conf_enum_functional_types (id)
    ,enum_default
        boolean
        NOT NULL DEFAULT FALSE
    ,functional_type_default
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
    ,syst_options
        jsonb
    ,user_options
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

ALTER TABLE msbms_syst_data.conf_enum_values OWNER TO <%= msbms_owner %>;

REVOKE ALL ON TABLE msbms_syst_data.conf_enum_values FROM public;
GRANT ALL ON TABLE msbms_syst_data.conf_enum_values TO <%= msbms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON msbms_syst_data.conf_enum_values
    FOR EACH ROW EXECUTE PROCEDURE msbms_syst_priv.trig_b_iu_set_diagnostic_columns();

CREATE CONSTRAINT TRIGGER a50_trig_a_i_conf_enum_values_check_functional_type
    AFTER INSERT ON msbms_syst_data.conf_enum_values
    FOR EACH ROW EXECUTE PROCEDURE msbms_syst_priv.trig_a_conf_enum_values_check_functional_types();

CREATE CONSTRAINT TRIGGER a50_trig_a_u_conf_enum_values_check_functional_type
    AFTER UPDATE ON msbms_syst_data.conf_enum_values
    FOR EACH ROW WHEN ( OLD.functional_type_id IS DISTINCT FROM NEW.functional_type_id )
        EXECUTE PROCEDURE msbms_syst_priv.trig_a_conf_enum_values_check_functional_types();

COMMENT ON
    TABLE msbms_syst_data.conf_enum_values IS
$DOC$The list of values provided by an enumeration as well as related behavioral and
informational metadata.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.conf_enum_values.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.conf_enum_values.internal_name IS
$DOC$A candidate key useful for programmatic references to individual records.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.conf_enum_values.display_name IS
$DOC$A friendly name and candidate key for the record, suitable for use in user
interactions$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.conf_enum_values.enum_id IS
$DOC$The enumeration record with which the value is associated.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.conf_enum_values.functional_type_id IS
$DOC$If the enumeration requires a functional type, this column references the
functional type associated with the enumeration value record.  Note that not all
enumerations require functional types.  If conf_enum_functional_types records
exist for an enumeration, then this column will be required for any values of
that enumeration; if there are no functional types defined for an enumeration,
the this column must remain NULL.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.conf_enum_values.enum_default IS
$DOC$If true, indicates that this value is the default selection from all values
defined for the enumerations.  If false then the value record has no special
significance relative to defaulting.

Note that if a record is inserted or updated in this table with enum_default set
true, and another record already exists for the enumeration with its
enum_default set true, the newly inserted/updated record will take precedence
and the value record previously set to be default will have its enum_default
setting set to false.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.conf_enum_values.functional_type_default IS
$DOC$If true, the value record is the default selection for any of a specific
fucntional type.  This is helpful in situations where a progression of state is
automatically processed by the system and the state is represented by an
enumeration.  In cases where there are no functional types, this value should
simply remain false.

Note that if a record is inserted or updated in this table with its
functional_type_default set true, and another record already exists for the
enumeration/functional type combination with its functional_type_default set
true, the newly inserted/updated record will take precedence and the value
record previously set to be default will have its functional_type_default
setting set to false.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.conf_enum_values.syst_defined IS
$DOC$If true, indicates that the value was created by the system or system
installation process.  A false value indicates that the record was user created.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.conf_enum_values.user_maintainable IS
$DOC$If true, the user may maintain the value including setting user_options or
even setting the record inactive/deleting it.  If false, the value record is
required by the system for correct operation.  The user_description and
user_options columns are always available for user maintenance regardless of
this setting.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.conf_enum_values.syst_description IS
$DOC$A system default description describing the value and its use cases within the
enumeration.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.conf_enum_values.user_description IS
$DOC$A custom user defined description which overrides the syst_description value
where it would otherwise be used.  If this column is set NULL the
syst_description value will be used.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.conf_enum_values.sort_order IS
$DOC$Indicates the sort ordering of the particular value record with the lowest value
sorting first.  When a value record for an enumeration is inserted or updated
and this column is being set to a value which equals another enumeration value
record for the same enumeration, the system assumes that the new record is
being set to precede the existing record and it will be set to sort after the
newly inserted/updated enumeration value.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.conf_enum_values.syst_options IS
$DOC$Extended options and metadata which describe the behavior and meaning of the
specific value within the enumeration.  The owning
conf_enums record's default_syst_options column will indicate what syst_options
are required or available and establishes default values for them.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.conf_enum_values.user_options IS
$DOC$Extended user defined options, similar to syst_options, but for the purpose of
driving custom functionality.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.conf_enum_values.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.conf_enum_values.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.conf_enum_values.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.conf_enum_values.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.conf_enum_values.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.conf_enum_values.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.conf_enum_values.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;
