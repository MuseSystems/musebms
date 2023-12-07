-- File:        syst_hierarchies.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_hierarchy/ms_syst/api_views/syst_hierarchies/syst_hierarchies.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

CREATE VIEW ms_syst.syst_hierarchies AS
SELECT
    id
  , internal_name
  , display_name
  , hierarchy_type_id
  , hierarchy_state_id
  , syst_defined
  , user_maintainable
  , structured
  , syst_description
  , user_description
  , diag_timestamp_created
  , diag_role_created
  , diag_timestamp_modified
  , diag_wallclock_modified
  , diag_role_modified
  , diag_row_version
  , diag_update_count
FROM ms_syst_data.syst_hierarchies;

ALTER VIEW ms_syst.syst_hierarchies OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst.syst_hierarchies FROM PUBLIC;

CREATE TRIGGER a50_trig_i_i_syst_hierarchies
    INSTEAD OF INSERT ON ms_syst.syst_hierarchies
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_i_syst_hierarchies();

CREATE TRIGGER a50_trig_i_u_syst_hierarchies
    INSTEAD OF UPDATE ON ms_syst.syst_hierarchies
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_u_syst_hierarchies();

CREATE TRIGGER a50_trig_i_d_syst_hierarchies
    INSTEAD OF DELETE ON ms_syst.syst_hierarchies
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_d_syst_hierarchies();

COMMENT ON
    VIEW ms_syst.syst_hierarchies IS
$DOC$Establishes a hierarchical template for parent/child relationships to
follow. The `hierarchies` relation creates a type of hierarchy which is linked
to a specific feature or functional area of the application via a record's
`hierarchy_type_id` reference. Hierarchies is also the parent relation of
Hierarchy Items relation (`ms_syst_data.syst_hierarchy_items`)
records where each Hierarchy Items record represents a level of the
hierarchy.

Note that once the Hierarchy is active and in use by Hierarchy implementing
Components, most changes to the Hierarchy records will not be allowed to ensure
the consistency of currently used data.

This API View allows the application to read and maintain the data according to
well defined application business rules.  Using this API view for updates to
data is the preferred method of data maintenance in the course of normal usage.

Only user maintainable values may be maintained via this API.  System created or
maintained data is not maintainable via this view.  Attempts at invalid data
maintenance via this API may result in the invalid changes being ignored or may
raise an exception.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_hierarchies.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.

This column is read only and not maintainable using this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_hierarchies.internal_name IS
$DOC$A candidate key useful for programmatic references to individual records.

This column's value must be set on insert.  While it is not recommended in most
circumstances, values in this column may be updated using this API view so long
as the record is either not System Defined or is User Maintainable.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_hierarchies.display_name IS
$DOC$A friendly name and candidate key for the record, suitable for use in user
interactions

This column's value must be set on insert.  Values in this column may be updated
using this API view so long as the record is either not System Defined or is
User Maintainable.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_hierarchies.hierarchy_type_id IS
$DOC$A reference indicating in which specific functional area or with which feature
of the application the Hierarchy is associated with.

This column's value must be set on insert and may not be changed at any later
time.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_hierarchies.hierarchy_state_id IS
$DOC$A reference indicating at which point in the Hierarchy life-cycle the record
sits.  The record may only be set in an `active` state if the record and any
associated Hierarchy Item records are in a consistent, valid state.  Similarly,
the record may only be set to an `inactive` state if the Hierarchy record is not
in use, which is defined as the record being referenced by an Hierarchy
implementing Component's records.

This API view allows callers to set this value on insert and update so long as
all other data validity and consistency rules are satisfied.  These rules are
discussed above and in the documentation of related data elements.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_hierarchies.syst_defined IS
$DOC$Indicates whether or not the Hierarchies record is system created for specific
purposes within the application or user created and fully manageable by the
user.  A true value in this column indicates that a record is system created and
managed whereas a false value indicates a user created and managed Hierarchy.

This column is read only and not maintainable using this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_hierarchies.user_maintainable IS
$DOC$If a record is System Defined (`syst_defined` is true) this value will
determine if some aspects of the Group Type and Group Type Items are user
maintainable.  Principally this will indicate whether or not the Group Type
Items may be created or deleted by users or if the Group Type Item structure is
only maintainable by the system.

Note that the value of this column has no effect for user defined fields
(`syst_defined` is false) and will not have any bearing on the maintainability
of the `user_description` fields as those fields are always user maintainable.

This column is read only and not maintainable using this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_hierarchies.structured IS
$DOC$A flag indicating whether or not the Hierarchy actually defines a structure, or
if the any implementations allow fully ad hoc structuring within the
implementing Component.

This configuration exists for cases where a Component implements Hierarchy
functionality, but can also operate while bypassing any hierarchy checks at all;
this way we can still require a Hierarchy record reference in the implementation
while allowing the Hierarchy definition itself be the configuration point for
determining whether or not hierarchical structure is required.

This value may be set on insert using this API view and if not provided will
default to `TRUE`.  This value may only be updated if the Hierarchy record is
not in use by any Hierarchy implementing Component's data and the Hierarchy is
in an `inactive` state.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_hierarchies.syst_description IS
$DOC$A system defined description of a record's purpose and use cases which may be
presented to end users.  This value may be overridden by setting the
`user_description` column to a non-null value.

This column is read only and may not be updated using this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_hierarchies.user_description IS
$DOC$An optional user provided description of the record purpose and use cases.
When this column is non-null, the value will override the text defined by the
`syst_description` column.

This column is user maintainable using this API view, even if the record is
`sys_defined` true and `user_maintainable` is false.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_hierarchies.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.

This column is read only when using this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_hierarchies.diag_role_created IS
$DOC$The database role which created the record.

This column is read only when using this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_hierarchies.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.

This column is read only when using this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_hierarchies.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.

This column is read only when using this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_hierarchies.diag_role_modified IS
$DOC$The database role which modified the record.

This column is read only when using this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_hierarchies.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.

This column is read only when using this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_hierarchies.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.

This column is read only when using this API view.$DOC$;
