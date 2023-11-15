-- File:        supp_groups.eex.sql
-- Location:    musebms/database/components/application/mscmp_core_groups/ms_appl/api_views/supp_groups/supp_groups.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

CREATE VIEW ms_appl.supp_groups AS
SELECT
    id
  , internal_name
  , display_name
  , external_name
  , parent_group_id
  , group_type_item_id
  , syst_defined
  , user_maintainable
  , syst_description
  , user_description
  , diag_timestamp_created
  , diag_role_created
  , diag_timestamp_modified
  , diag_wallclock_modified
  , diag_role_modified
  , diag_row_version
  , diag_update_count
FROM ms_appl_data.supp_groups;

ALTER VIEW ms_appl.supp_groups OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_appl.supp_groups FROM PUBLIC;

CREATE TRIGGER a50_trig_i_i_supp_groups
    INSTEAD OF INSERT ON ms_appl.supp_groups
    FOR EACH ROW EXECUTE PROCEDURE ms_appl.trig_i_i_supp_groups();

CREATE TRIGGER a50_trig_i_u_supp_groups
    INSTEAD OF UPDATE ON ms_appl.supp_groups
    FOR EACH ROW EXECUTE PROCEDURE ms_appl.trig_i_u_supp_groups();

CREATE TRIGGER a50_trig_i_d_supp_groups
    INSTEAD OF DELETE ON ms_appl.supp_groups
    FOR EACH ROW EXECUTE PROCEDURE ms_appl.trig_i_d_supp_groups();

COMMENT ON
    VIEW ms_appl.supp_groups IS
$DOC$Groups provide a mechanism for defining groups of other relations for a variety
of use cases including menus, nests product categorization, or simple customer
groups.  Groups are established as being of specific Group Types which determine
where in the application a Group may appear and if a series of hierarchically
related Groups must be defined prior to use in the broader application.

System Defined records which are marked as User Maintainable allow for certain
user maintenance options including the addition, alteration, or deletion of
system created records.  Typically, root level System Defined parent records
(records which are not the child of some other Group record) are not able to be
deleted.

This API View allows the application to read and maintain the data according to
well defined application business rules.  Using this API view for updates to
data is the preferred method of data maintenance in the course of normal usage.

Only user maintainable values may be maintained via this API.  System created or
maintained data is not maintainable via this view.  Attempts at invalid data
maintenance via this API may result in the invalid changes being ignored or may
raise an exception.$DOC$;

COMMENT ON
    COLUMN ms_appl.supp_groups.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.

This column is read only and not maintainable via this API view.$DOC$;

COMMENT ON
    COLUMN ms_appl.supp_groups.internal_name IS
$DOC$A candidate key useful for programmatic references to individual records.

This column must be set when inserting new records.  Only records which are not
System Defined are maintainable via the API view.$DOC$;

COMMENT ON
    COLUMN ms_appl.supp_groups.display_name IS
$DOC$A friendly name and candidate key for the record, suitable for use in user
interactions

On inserting new records this value is required.

If the record is System Defined and marked User Maintainable, this value may be
updated via this API view; other, non-user maintainable System Defined records
may not use this API view for updating this column.  User defined records may
update this column via the API view as needed.$DOC$;

COMMENT ON
    COLUMN ms_appl.supp_groups.external_name IS
$DOC$A non-unique/non-key value used to display to users and external parties where
uniqueness is less of a concern than specific end user presentation.

This value is required for inserting new Group records.

If the record is System Defined this column may not be updated using this API
view unless the record is also marked User Maintainable.  User created records
may update this column using this API view as required.$DOC$;

COMMENT ON
    COLUMN ms_appl.supp_groups.parent_group_id IS
$DOC$If populated, indicates that the Group is the child of Group record higher in
the hierarchy.  If `NULL`, the record is a "root" Group record which acts as the
primarily selector for retrieving all the associated Group records from the
database.

If the record is System Defined this column may not be updated using this API
view unless the record is also marked User Maintainable.  User created records
may update this column using this API view as required.$DOC$;

COMMENT ON
    COLUMN ms_appl.supp_groups.group_type_item_id IS
$DOC$Groups of certain Functional Types require that their structure is
validated against a specific structure. This reference links a Group entry to
a specific level in the required hierarchy and may aid in querying Groups in
various selection scenario.

A value for this column must be set on record creation.

If the record is System Defined this column may not be updated using this API
view unless the record is also marked User Maintainable.  User created records
may update this column using this API view as required.$DOC$;

COMMENT ON
    COLUMN ms_appl.supp_groups.syst_defined IS
$DOC$If true, this value indicates that the Group was created as an integral part of
the application and minimally expects to find the root level Group to be
available under the system installation time unique identifiers.  If false, the
group is considered part of the optional user configuration and may be fully
managed as needed by the user, including fully deleting the Group hierarchy.

This column is read only and not maintainable via this API view.$DOC$;

COMMENT ON
    COLUMN ms_appl.supp_groups.user_maintainable IS
$DOC$When `syst_defined` is true, this flag indicates if limited user maintenance
functions are permitted.  When this value is true, limited user maintenance is
permitted; when false, user maintenance is more strictly enforced.  Note that
this value being false never prevents the user maintenance of the
`user_description` field as that field exists to support user supplied
documentation under all circumstances.  Finally, the value of this column is
disregarded when the record does not set `syst_defined` true.

This column is read only and not maintainable via this API view.$DOC$;

COMMENT ON
    COLUMN ms_appl.supp_groups.syst_description IS
$DOC$A default description of a specific Group displayable to end users in cases
where no user supplied description exists.

This column is read only and not maintainable via this API view.$DOC$;

COMMENT ON
    COLUMN ms_appl.supp_groups.user_description IS
$DOC$A user defined description of a specific Group which overrides the
`syst_description` field.  The override is effective in cases where this column
is not null.

This column may is user modifiable even when the record is System Defined or not
marked as User Maintainable.$DOC$;

COMMENT ON
    COLUMN ms_appl.supp_groups.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.

This column is read only and not maintainable via this API view.$DOC$;

COMMENT ON
    COLUMN ms_appl.supp_groups.diag_role_created IS
$DOC$The database role which created the record.

This column is read only and not maintainable via this API view.$DOC$;

COMMENT ON
    COLUMN ms_appl.supp_groups.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.

This column is read only and not maintainable via this API view.$DOC$;

COMMENT ON
    COLUMN ms_appl.supp_groups.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.

This column is read only and not maintainable via this API view.$DOC$;

COMMENT ON
    COLUMN ms_appl.supp_groups.diag_role_modified IS
$DOC$The database role which modified the record.

This column is read only and not maintainable via this API view.$DOC$;

COMMENT ON
    COLUMN ms_appl.supp_groups.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.

This column is read only and not maintainable via this API view.$DOC$;

COMMENT ON
    COLUMN ms_appl.supp_groups.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.

This column is read only and not maintainable via this API view.$DOC$;
