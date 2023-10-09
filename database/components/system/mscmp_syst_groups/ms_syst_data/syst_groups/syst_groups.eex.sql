-- File:        syst_groups.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_groups/ms_syst_data/syst_groups/syst_groups.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

CREATE TABLE ms_syst_data.syst_groups
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v1( )
        CONSTRAINT syst_groups_pk PRIMARY KEY
    ,internal_name
        text
        NOT NULL
        CONSTRAINT syst_groups_internal_name_udx UNIQUE 
    ,display_name
        text
        NOT NULL
        CONSTRAINT syst_groups_display_name_udx UNIQUE
    ,external_name
        text
        NOT NULL
    ,parent_group_id
        uuid
        CONSTRAINT syst_group_parent_group_fk
            REFERENCES ms_syst_data.syst_groups ( id )
    ,group_type_item_id
        uuid
        NOT NULL
        CONSTRAINT syst_groups_group_type_item_fk
            REFERENCES ms_syst_data.syst_group_type_items ( id )
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

ALTER TABLE ms_syst_data.syst_groups OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst_data.syst_groups FROM public;
GRANT ALL ON TABLE ms_syst_data.syst_groups TO <%= ms_owner %>;

CREATE TRIGGER c50_trig_b_i_syst_groups_validate_parent_group_type_item
    BEFORE INSERT ON ms_syst_data.syst_groups
    FOR EACH ROW
    EXECUTE PROCEDURE ms_syst_data.trig_b_iu_syst_groups_validate_parent_group_type_item();

CREATE TRIGGER c50_trig_b_u_syst_groups_validate_parent_group_type_item
    BEFORE UPDATE ON ms_syst_data.syst_groups
    FOR EACH ROW
    WHEN (  new.parent_group_id != old.parent_group_id OR
            new.group_type_item_id != old.group_type_item_id )
    EXECUTE PROCEDURE ms_syst_data.trig_b_iu_syst_groups_validate_parent_group_type_item();

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_syst_data.syst_groups
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

COMMENT ON
    TABLE ms_syst_data.syst_groups IS
$DOC$Groups provide a mechanism for defining groups of other relations for a variety
of use cases including menus, nests product categorization, or simple customer
groups.  Groups are established as being of specific Group Types which determine
where in the application a Group may appear and if a series of hierarchically
related Groups must be defined prior to use in the broader application.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_groups.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_groups.internal_name IS
$DOC$A candidate key useful for programmatic references to individual records.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_groups.display_name IS
$DOC$A friendly name and candidate key for the record, suitable for use in user
interactions$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_groups.external_name IS
$DOC$A non-unique/non-key value used to display to users and external parties where
uniqueness is less of a concern than specific end user presentation.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_groups.parent_group_id IS
$DOC$If populated, indicates that the Group is the child of Group record higher in
the hierarchy.  If `NULL`, the record is a "root" Group record which acts as the
primarily selector for retrieving all the associated Group records from the
database.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_groups.group_type_item_id IS
$DOC$Groups of certain Functional Types require that their structure is
validated against a specific structure. This reference links a Group entry to
a specific level in the required hierarchy and may aid in querying Groups in
various selection scenario.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_groups.syst_description IS
$DOC$A default description of a specific Group displayable to end users in cases
where no user supplied description exists.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_groups.user_description IS
$DOC$A user defined description of a specific Group which overrides the
`syst_description` field.  The override is effective in cases where this column
is not null.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_groups.syst_defined IS
$DOC$If true, this value indicates that the Group was created as an integral part of
the application and minimally expects to find the root level Group to be
available under the system installation time unique identifiers.  If false, the
group is considered part of the optional user configuration and may be fully
managed as needed by the user, including fully deleting the Group hierarchy.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_groups.user_maintainable IS
$DOC$When `syst_defined` is true, this flag indicates if limited user maintenance
functions are permitted.  When this value is true, limited user maintenance is
permitted; when false, user maintenance is more strictly enforced.  Note that
this value being false never prevents the user maintenance of the
`user_description` field as that field exists to support user supplied
documentation under all circumstances.  Finally, the value of this column is
disregarded when the record does not set `syst_defined` true.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_groups.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record 
started.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_groups.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_groups.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record 
started.  This field will be the same as diag_timestamp_created for inserted 
records.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_groups.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the 
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_groups.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_groups.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual 
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version 
is not updated, nor are any updates made to the other diag_* columns other than 
diag_update_count.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_groups.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if 
the update actually changed any data.  In this way needless or redundant record 
updates can be found.  This row starts at 0 and therefore may be the same as the 
diag_row_version - 1.$DOC$;
