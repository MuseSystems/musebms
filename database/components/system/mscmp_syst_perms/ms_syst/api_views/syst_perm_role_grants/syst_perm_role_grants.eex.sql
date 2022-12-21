-- File:        syst_perm_role_grants.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_perms/ms_syst/api_views/syst_perm_role_grants/syst_perm_role_grants.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

CREATE VIEW ms_syst.syst_perm_role_grants AS
SELECT
    id
  , perm_role_id
  , perm_id
  , view_scope
  , maint_scope
  , admin_scope
  , ops_scope
  , diag_timestamp_created
  , diag_role_created
  , diag_timestamp_modified
  , diag_wallclock_modified
  , diag_role_modified
  , diag_row_version
  , diag_update_count
FROM ms_syst_data.syst_perm_role_grants;

ALTER VIEW ms_syst.syst_perm_role_grants OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst.syst_perm_role_grants FROM PUBLIC;

CREATE TRIGGER a50_trig_i_i_syst_perm_role_grants
    INSTEAD OF INSERT ON ms_syst.syst_perm_role_grants
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_i_syst_perm_role_grants();

CREATE TRIGGER a50_trig_i_u_syst_perm_role_grants
    INSTEAD OF UPDATE ON ms_syst.syst_perm_role_grants
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_u_syst_perm_role_grants();

CREATE TRIGGER a50_trig_i_d_syst_perm_role_grants
    INSTEAD OF DELETE ON ms_syst.syst_perm_role_grants
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_d_syst_perm_role_grants();

COMMENT ON
    VIEW ms_syst.syst_perm_role_grants IS
$DOC$Establishes the individual permissions which are granted by the given permission
role.

Note that the absence of an explicit permission grant to a role is an implicit
denial of that permission.

This API View allows the application to read and maintain the data according to
well defined application business rules.  Using this API view for updates to
data is the preferred method of data maintenance in the course of normal usage.

Only user maintainable values may be maintained via this API.  System created or
maintained data is not maintainable via this view.  Attempts at invalid data
maintenance via this API may result in the invalid changes being ignored or may
raise an exception.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_perm_role_grants.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_perm_role_grants.perm_role_id IS
$DOC$Identifies the role to which the permission grant is being made.  This
value is a reference to a syst_perm_roles record which is considered the parent
of this record.

This value is set at record creation time and may not be updated later via this
API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_perm_role_grants.perm_id IS
$DOC$The permission being granted by the role.

This value is set at record creation time and may not be updated later via this
API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_perm_role_grants.view_scope IS
$DOC$Assigns the Scope of the Permission's View Right being granted by the Role.

The valid Scope options are defined by the Permission record.

If the parent Permission Role record is a system defined record, this value may
not be changed using this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_perm_role_grants.maint_scope IS
$DOC$Assigns the Scope of the Permission's Maintenance Right being granted by the
Role.

The valid Scope options are defined by the Permission record.

If the parent Permission Role record is a system defined record, this value may
not be changed using this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_perm_role_grants.admin_scope IS
$DOC$Assigns the Scope of the Permission's Data Administration Right being granted by
the Role.

The valid Scope options are defined by the Permission record.

If the parent Permission Role record is a system defined record, this value may
not be changed using this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_perm_role_grants.ops_scope IS
$DOC$Assigns the Scope of the Permission's Operations Right being granted by the
Role.

The valid Scope options are defined by the Permission record.

If the parent Permission Role record is a system defined record, this value may
not be changed using this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_perm_role_grants.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.

This value is system maintained and is read only via this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_perm_role_grants.diag_role_created IS
$DOC$The database role which created the record.

This value is system maintained and is read only via this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_perm_role_grants.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.

This value is system maintained and is read only via this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_perm_role_grants.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.

This value is system maintained and is read only via this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_perm_role_grants.diag_role_modified IS
$DOC$The database role which modified the record.

This value is system maintained and is read only via this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_perm_role_grants.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.

This value is system maintained and is read only via this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_perm_role_grants.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.

This value is system maintained and is read only via this API view.$DOC$;
