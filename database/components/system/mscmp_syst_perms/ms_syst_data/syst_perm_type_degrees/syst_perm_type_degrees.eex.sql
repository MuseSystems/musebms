-- File:        syst_perm_type_degrees.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_perms/ms_syst_data/syst_perm_type_degrees/syst_perm_type_degrees.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

CREATE TABLE ms_syst_data.syst_perm_type_degrees
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v1( )
        CONSTRAINT syst_perm_type_degrees_pk PRIMARY KEY
    ,internal_name
        text
        NOT NULL
        CONSTRAINT syst_perm_type_degrees_internal_name_udx UNIQUE
    ,display_name
        text
        NOT NULL
        CONSTRAINT syst_perm_type_degrees_display_name_udx UNIQUE
    ,external_name
        text
        NOT NULL
    ,perm_type_id
        uuid
        NOT NULL
        CONSTRAINT syst_perm_type_degrees_perm_type_fk
            REFERENCES ms_syst_data.syst_perm_types (id)
            ON DELETE CASCADE
    ,ordering
        smallint
        NOT NULL DEFAULT 0
    ,syst_description
        text
        NOT NULL
    ,user_description
        text
    ,diag_timestamp_created
        timestamptz
        NOT NULL DEFAULT now( )
    ,diag_role_created
        text
    ,diag_timestamp_modified
        timestamptz
        NOT NULL DEFAULT now( )
    ,diag_wallclock_modified
        timestamptz
        NOT NULL DEFAULT clock_timestamp( )
    ,diag_role_modified
        text
    ,diag_row_version
        bigint
        NOT NULL DEFAULT 1
    ,diag_update_count
        bigint
        NOT NULL DEFAULT 0
);

ALTER TABLE ms_syst_data.syst_perm_type_degrees OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst_data.syst_perm_type_degrees FROM public;
GRANT ALL ON TABLE ms_syst_data.syst_perm_type_degrees TO <%= ms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_syst_data.syst_perm_type_degrees
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

CREATE TRIGGER b50_trig_a_iu_syst_perm_type_degrees_ordering
    AFTER INSERT OR UPDATE ON ms_syst_data.syst_perm_type_degrees
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_data.trig_a_iu_syst_perm_type_degrees_ordering();

COMMENT ON
    TABLE ms_syst_data.syst_perm_type_degrees IS
$DOC$The available permission degrees available to the parent syst_perm_types record.
Degrees are the relative degrees of authority that a permission of a given type
may grant.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_perm_type_degrees.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_perm_type_degrees.internal_name IS
$DOC$A candidate key useful for programmatic references to individual records.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_perm_type_degrees.display_name IS
$DOC$A friendly name and candidate key for the record, suitable for use in user
interactions$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_perm_type_degrees.external_name IS
$DOC$A non-unique/non-key value used to display to users and external parties where
uniqueness is less of a concern than specific end user presentation.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_perm_type_degrees.perm_type_id IS
$DOC$Associates the syst_perm_type_degrees record with a parent syst_perm_types
record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_perm_type_degrees.ordering IS
$DOC$Allows relative sorting of lower degrees of authority to higher degrees where
lower values convey less authority than higher degrees.  This ordering allows
for sorting the records in user interfaces and elsewhere such relative authority
is useful.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_perm_type_degrees.syst_description IS
$DOC$A system default description describing the permission and its uses in the
system.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_perm_type_degrees.user_description IS
$DOC$A custom user defined description which overrides the syst_description value
where it would otherwise be used.  If this column is set NULL the
syst_description value will be used.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_perm_type_degrees.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_perm_type_degrees.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_perm_type_degrees.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_perm_type_degrees.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_perm_type_degrees.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_perm_type_degrees.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_perm_type_degrees.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;
