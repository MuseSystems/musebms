-- File:        supp_group_type_items.eex.sql
-- Location:    musebms/database/components/application/mscmp_core_groups/ms_appl_data/supp_group_type_items/supp_group_type_items.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

CREATE TABLE ms_appl_data.supp_group_type_items
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v1( )
        CONSTRAINT supp_group_type_items_pk PRIMARY KEY
    ,internal_name
        text
        NOT NULL
        CONSTRAINT supp_group_type_items_internal_name_udx UNIQUE
    ,display_name
        text
        NOT NULL
        CONSTRAINT supp_group_type_items_display_name_udx UNIQUE
    ,external_name
        text
        NOT NULL
    ,group_type_id
        uuid
        NOT NULL
        CONSTRAINT supp_group_type_items_group_type_fk
            REFERENCES ms_appl_data.supp_group_types ( id )
            ON DELETE CASCADE
    ,hierarchy_depth
        smallint
        NOT NULL
    ,CONSTRAINT supp_group_type_items_group_level_udx
        UNIQUE (group_type_id, hierarchy_depth)
        DEFERRABLE
        INITIALLY DEFERRED
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

ALTER TABLE ms_appl_data.supp_group_type_items OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_appl_data.supp_group_type_items FROM public;
GRANT ALL ON TABLE ms_appl_data.supp_group_type_items TO <%= ms_owner %>;

CREATE TRIGGER b50_trig_b_iu_supp_group_type_items_depth_maint
    BEFORE INSERT OR UPDATE ON ms_appl_data.supp_group_type_items
    FOR EACH ROW EXECUTE PROCEDURE
        ms_appl_data.trig_b_iu_supp_group_type_items_depth_maint();

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_appl_data.supp_group_type_items
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

COMMENT ON
    TABLE ms_appl_data.supp_group_type_items IS
$DOC$Group Type Item records represent a level in the hierarchy of their parent Group
Type. Each Group Type Item record is individually sequenced in its group via the
`hierarchy_depth` column.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.supp_group_type_items.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.supp_group_type_items.internal_name IS
$DOC$A candidate key useful for programmatic references to individual records.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.supp_group_type_items.display_name IS
$DOC$A friendly name and candidate key for the record, suitable for use in user
interactions$DOC$;

COMMENT ON
    COLUMN ms_appl_data.supp_group_type_items.external_name IS
$DOC$A non-unique/non-key value used to display to users and external parties where
uniqueness is less of a concern than specific end user presentation.$DOC$;

COMMENT ON
    COLUMN  ms_appl_data.supp_group_type_items.group_type_id IS
$DOC$Identifies the Group Type to which the record belongs.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.supp_group_type_items.hierarchy_depth IS
$DOC$Indicates the at what level in the hierarchy this Group Type Item sits
relative to the other items in the Group Type.  Records with relatively
higher values are deeper or lower in the hierarchy.

When a value for this column is not provided at insert time, the record is
assigned the next hierarchy depth value relative to the existing records.  When
a record is inserted with a set hierarchy_depth value and that value pre-exists
for the same Group Type as the new record, the insert is treated as a "insert
above" operation, with the existing conflicting record being updated to have the
next hierarchy value; existing Group Type Item records are continued to be
updated until the last record is assigned a non-conflicting hierarchy_depth
value.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.supp_group_type_items.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.supp_group_type_items.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.supp_group_type_items.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.supp_group_type_items.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.supp_group_type_items.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.supp_group_type_items.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.supp_group_type_items.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;

COMMENT ON
    CONSTRAINT supp_group_type_items_group_level_udx
    ON ms_appl_data.supp_group_type_items IS
$DOC$No two records in the same Group Type should share the same hierarchy_depth
as their relationship would become ambiguous.  Group Type hierarchies are
only valuable when each individual level is uniquely placed in the hierarchy
relative to other records of the same group.$DOC$;
