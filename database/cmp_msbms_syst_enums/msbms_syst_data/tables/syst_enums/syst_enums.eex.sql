-- File:        syst_enums.eex.sql
-- Location:    database\cmp_msbms_syst_enums\msbms_syst_data\tables\syst_enums.eex.sql
-- Project:     Muse Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE TABLE msbms_syst_data.syst_enums
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v1( )
        CONSTRAINT syst_enums_pk PRIMARY KEY
    ,internal_name
        text
        NOT NULL
        CONSTRAINT syst_enums_internal_name_udx UNIQUE
    ,display_name
        text
        NOT NULL
        CONSTRAINT syst_enums_display_name_udx UNIQUE
    ,syst_description
        text
        NOT NULL
    ,user_description
        text
    ,syst_defined
        boolean
        NOT NULL DEFAULT FALSE
    ,user_maintainable
        boolean
        NOT NULL DEFAULT TRUE
    ,default_syst_options
        jsonb
    ,default_user_options
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

ALTER TABLE msbms_syst_data.syst_enums OWNER TO <%= msbms_owner %>;

REVOKE ALL ON TABLE msbms_syst_data.syst_enums FROM public;
GRANT ALL ON TABLE msbms_syst_data.syst_enums TO <%= msbms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON msbms_syst_data.syst_enums
    FOR EACH ROW EXECUTE PROCEDURE msbms_syst_priv.trig_b_iu_set_diagnostic_columns();

COMMENT ON
    TABLE msbms_syst_data.syst_enums IS
$DOC$Enumerates the enumerations known to the system along with additional metadata
useful in applying them appropriately.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_enums.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_enums.internal_name IS
$DOC$A candidate key useful for programmatic references to individual records.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_enums.display_name IS
$DOC$A friendly name and candidate key for the record, suitable for use in user
interactions$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_enums.syst_description IS
$DOC$A default description of the enumeration which might include details such as how
the enumeration is used and what kind of functionality might be impacted by
choosing specific enumeration values.

Note that users should not change this value.  For custom descriptions, use the
msbms_syst_data.syst_enums.user_description field instead.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_enums.user_description IS
$DOC$A user defined description of the enumeration to support custom user
documentation of the purpose and function of the enumeration.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_enums.syst_defined IS
$DOC$If true, this value indicates that the enumeration is considered part of the
application.  Often times, system enumerations are manageable by users, but the
existence of the enumeration in the system is assumed to exist by the
application.  If false, the assumption is that the enumeration was created by
users and supports custom user functionality.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_enums.user_maintainable IS
$DOC$When true, this column indicates that the enumeration is user maintainable;
this might include the ability to add, edit, or remove enumeration values.  When
false, the enumeration is strictly system managed for any functional purpose.
Note that the value of this column doesn't effect the ability to set a
user_description value; the ability to set custom descriptions is always
available for any properly authorized user.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_enums.default_syst_options IS
$DOC$Establishes the expected extended system options along with default values if
applicable.  Note that this setting is used to both validate
and set defaults in the syst_enum_items.syst_options column.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_enums.default_user_options IS
$DOC$Allows a user to set the definition of syst_enum_items.user_options values and
provide defaults for those values if appropriate.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_enums.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_enums.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_enums.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_enums.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_enums.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_enums.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_enums.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;
