-- File:        conf_hierarchy_items.eex.sql
-- Location:    musebms/database/components/application/mscmp_core_hierarchy/ms_appl/api_views/conf_hierarchy_items/conf_hierarchy_items.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

CREATE VIEW ms_appl.conf_hierarchy_items AS
SELECT
    id
  , internal_name
  , display_name
  , external_name
  , hierarchy_id
  , hierarchy_depth
  , required
  , allow_leaf_nodes
  , diag_timestamp_created
  , diag_role_created
  , diag_timestamp_modified
  , diag_wallclock_modified
  , diag_role_modified
  , diag_row_version
  , diag_update_count
FROM ms_appl_data.conf_hierarchy_items;

ALTER VIEW ms_appl.conf_hierarchy_items OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_appl.conf_hierarchy_items FROM PUBLIC;

CREATE TRIGGER a50_trig_i_i_conf_hierarchy_items
    INSTEAD OF INSERT ON ms_appl.conf_hierarchy_items
    FOR EACH ROW EXECUTE PROCEDURE ms_appl.trig_i_i_conf_hierarchy_items();

CREATE TRIGGER a50_trig_i_u_conf_hierarchy_items
    INSTEAD OF UPDATE ON ms_appl.conf_hierarchy_items
    FOR EACH ROW EXECUTE PROCEDURE ms_appl.trig_i_u_conf_hierarchy_items();

CREATE TRIGGER a50_trig_i_d_conf_hierarchy_items
    INSTEAD OF DELETE ON ms_appl.conf_hierarchy_items
    FOR EACH ROW EXECUTE PROCEDURE ms_appl.trig_i_d_conf_hierarchy_items();

COMMENT ON
    VIEW ms_appl.conf_hierarchy_items IS
$DOC$Hierarchy Item records represent a level in the hierarchy of their parent
Hierarchy. Each Hierarchy Item record is individually sequenced in its group via
the `hierarchy_depth` column.

Once the Hierarchy is active and in use by Hierarchy implementing Components,
most changes to the Hierarchy Item records will not be allowed to ensure the
consistency of currently used data.  Also for data consistency reasons, using
this API view imposes the fundamental restriction that Hierarchy Item
hierarchies can only be constructed top down and deconstructed bottom up.
Updates are limited to allowing some naming updates, but not updates in
hierarchy changes.

This API View allows the application to read and maintain the data according to
well defined application business rules.  Using this API view for updates to
data is the preferred method of data maintenance in the course of normal usage.

Only user maintainable values may be maintained via this API.  System created or
maintained data is not maintainable via this view.  Attempts at invalid data
maintenance via this API may result in the invalid changes being ignored or may
raise an exception.$DOC$;

COMMENT ON
    COLUMN ms_appl.conf_hierarchy_items.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.

This column is read only and not maintainable using this API view.$DOC$;

COMMENT ON
    COLUMN ms_appl.conf_hierarchy_items.internal_name IS
$DOC$A candidate key useful for programmatic references to individual records.

This column's value must be set on insert.  While it is not recommended in most
circumstances, values in this column may be updated using this API view so long
as the record is either not System Defined or is User Maintainable.$DOC$;

COMMENT ON
    COLUMN ms_appl.conf_hierarchy_items.display_name IS
$DOC$A friendly name and candidate key for the record, suitable for use in user
interactions

This column's value must be set on insert.  Values in this column may be updated
using this API view so long as the record is either not System Defined or is
User Maintainable.$DOC$;

COMMENT ON
    COLUMN ms_appl.conf_hierarchy_items.external_name IS
$DOC$A non-unique/non-key value used to display to users and external parties where
uniqueness is less of a concern than specific end user presentation.

This column's value must be set on insert.  Values in this column may be updated
using this API view so long as the record is either not System Defined or is
User Maintainable.$DOC$;

COMMENT ON
    COLUMN  ms_appl.conf_hierarchy_items.hierarchy_id IS
$DOC$Identifies the Hierarchy to which the record belongs.

This column's value must be set on insert.  Values in this column may not be
updated after the record creation using this API view.$DOC$;

COMMENT ON
    COLUMN ms_appl.conf_hierarchy_items.hierarchy_depth IS
$DOC$Indicates the at what level in the hierarchy this Hierarchy Item sits
relative to the other Hierarchy Items in the Hierarchy.  Records with relatively
higher values are deeper/lower in the hierarchy.

This column's value may be set on insert.  When this value is not provided at
insert time, the record is assigned the next hierarchy depth value relative to
the existing records.  When a record is inserted with a set hierarchy_depth
value and that value pre-exists for the same Hierarchy as the new record, the
insert is treated as a "insert above" operation, with the existing conflicting
record being updated to have the next hierarchy value; existing Hierarchy Item
records are continued to be updated until the last record is assigned a
non-conflicting hierarchy_depth value.  Values in this column may not be updated
after creation using this API view.$DOC$;

COMMENT ON
    COLUMN ms_appl.conf_hierarchy_items.required IS
$DOC$Indicates if the Hierarchy Item level must be represented by a record in the
implementing data, or if the Hierarchy Item level represents an optional level.
If true, the Hierarchy Item level must be represented by a record in the data of
the implementing Component for that data to be considered valid.  If false,
the Hierarchy Item level is considered optional and the data of the implementing
Component may omit the Hierarchy Item level in its data without the data being
considered invalid.

The highest/root Hierarchy Item level must always be required.  If lower levels
of the Hierarchy are required, all parents to the lowest required Hierarchy Item
level must also be marked as required true.

This value may be set on insert or allowed to default to a value of `TRUE` using
this API view..  If the Hierarchy is not currently in an active state, this
value may be updated with the understanding that all records meet previously
described consistency rules prior to the Hierarchy being set to an active state.$DOC$;

COMMENT ON
    COLUMN ms_appl.conf_hierarchy_items.allow_leaf_nodes IS
$DOC$Indicates to implementing Components that this Hierarchy Item level can be
associated with "Leaf Nodes". Leaf Nodes are not defined in the
mscmp_core_hierarchy Component, but are rather defined by Hierarchy implementing
Components.  Leaf Nodes are the records which the Branch Nodes/Hierarchy
definition are organizing.  An example of a Leaf Node would be an application
menu implementing Component defining references/links to specific application
functionality which are then displayed associated to branches of a tree
structure (menu/sub-menu/ etc.)  The links are Leaf Nodes and the branches of
the menu are Branch Nodes: representations of the Hierarchy Items.

If this value is true, it means this Hierarchy Item record may be associated
directly with Leaf Nodes.  If false, Leaf Nodes must be associated with other
levels of the Hierarchy.

The bottom/lowest level required Hierarchy Item must always be marked as
`allow_leaf_nodes` true.  Higher than the lowest required Hierarchy Item level
may arbitrarily allow or disallow Leaf Node associations as the implementing
Component sees fit.

This API view allows the initial value of this field to be set on insert.  If
the Hierarchy is unused and set to an `inactive` state, the value of this column
may be updated.$DOC$;

COMMENT ON
    COLUMN ms_appl.conf_hierarchy_items.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.

This column is read only and not maintainable using this API view.$DOC$;

COMMENT ON
    COLUMN ms_appl.conf_hierarchy_items.diag_role_created IS
$DOC$The database role which created the record.

This column is read only and not maintainable using this API view.$DOC$;

COMMENT ON
    COLUMN ms_appl.conf_hierarchy_items.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.

This column is read only and not maintainable using this API view.$DOC$;

COMMENT ON
    COLUMN ms_appl.conf_hierarchy_items.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.

This column is read only and not maintainable using this API view.$DOC$;

COMMENT ON
    COLUMN ms_appl.conf_hierarchy_items.diag_role_modified IS
$DOC$The database role which modified the record.

This column is read only and not maintainable using this API view.$DOC$;

COMMENT ON
    COLUMN ms_appl.conf_hierarchy_items.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.

This column is read only and not maintainable using this API view.$DOC$;

COMMENT ON
    COLUMN ms_appl.conf_hierarchy_items.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.

This column is read only and not maintainable using this API view.$DOC$;
