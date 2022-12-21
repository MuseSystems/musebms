-- File:        syst_perms.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_perms/ms_syst/api_views/syst_perms/syst_perms.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

CREATE VIEW ms_syst.syst_perms AS
SELECT
    id
  , internal_name
  , display_name
  , perm_functional_type_id
  , syst_defined
  , syst_description
  , user_description
  , view_scope_options
  , maint_scope_options
  , admin_scope_options
  , ops_scope_options
  , diag_timestamp_created
  , diag_role_created
  , diag_timestamp_modified
  , diag_wallclock_modified
  , diag_role_modified
  , diag_row_version
  , diag_update_count
FROM ms_syst_data.syst_perms;

ALTER VIEW ms_syst.syst_perms OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst.syst_perms FROM PUBLIC;

CREATE TRIGGER a50_trig_i_i_syst_perms
    INSTEAD OF INSERT ON ms_syst.syst_perms
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_i_syst_perms();

CREATE TRIGGER a50_trig_i_u_syst_perms
    INSTEAD OF UPDATE ON ms_syst.syst_perms
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_u_syst_perms();

CREATE TRIGGER a50_trig_i_d_syst_perms
    INSTEAD OF DELETE ON ms_syst.syst_perms
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_d_syst_perms();

COMMENT ON
    VIEW ms_syst.syst_perms IS
$DOC$Defines the available system and application permissions which can be
assigned to users.  For a more detailed description see the table comment for
ms_syst_data.syst_perms.

This API View allows the application to read and maintain the data according to
well defined application business rules.  Using this API view for updates to
data is the preferred method of data maintenance in the course of normal usage.

Only user maintainable values may be maintained via this API.  System created or
maintained data is not maintainable via this view.  Attempts at invalid data
maintenance via this API may result in the invalid changes being ignored or may
raise an exception.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_perms.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_perms.internal_name IS
$DOC$A candidate key useful for programmatic references to individual records.

Updates to this value are only acceptable if the record's syst_defined value is
set 'false'.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_perms.display_name IS
$DOC$A friendly name and candidate key for the record, suitable for use in user
interactions.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_perms.perm_functional_type_id IS
$DOC$Assigns the Permission to a specific Permission Functional Type.

Permissions may only be granted in Permission Roles of the same Permission
Functional Type.

This value can only be set at record INSERT time using this API view.$DOC$;

COMMENT ON
     COLUMN ms_syst.syst_perms.syst_defined IS
$DOC$If true, indicates that the permission was created by the system or system
installation process.  A false value indicates that the record was user created.

This value is system maintained and read only via this API.$DOC$;

COMMENT ON
     COLUMN ms_syst.syst_perms.syst_description IS
$DOC$A system default description describing the permission and its uses in the
system.

This value is a system defined, read only value.$DOC$;

COMMENT ON
     COLUMN ms_syst.syst_perms.user_description IS
$DOC$A custom user defined description which overrides the syst_description value
where it would otherwise be used.  If this column is set NULL the
syst_description value will be used.

This field is intended to accommodate end user defined descriptions and is
maintainable via this view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_perms.view_scope_options IS
$DOC$If applicable, enumerates the available Scopes of viewable data offered by the
permission.  If not applicable the only option will be 'unused'.

If the Permission is system defined, the data in this column is not maintainable
via this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_perms.maint_scope_options IS
$DOC$If applicable, enumerates the available Scopes of maintainable data offered by
the permission.  Maintenance in this context refers to changing existing data.
If not applicable the only option will be 'unused'.

If the Permission is system defined, the data in this column is not maintainable
via this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_perms.admin_scope_options IS
$DOC$If applicable, enumerates the available Scopes of data administration offered
by the permission.  Administration in this context refers to creating or
deleting records.  If not applicable the only option will be 'unused'.

If the Permission is system defined, the data in this column is not maintainable
via this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_perms.ops_scope_options IS
$DOC$If applicable, enumerates the available Scopes of a given operation or
processing capability offered by the permission.  If not applicable the only
option will be 'unused'.

If the Permission is system defined, the data in this column is not maintainable
via this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_perms.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.

This value is system maintained and is read only via this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_perms.diag_role_created IS
$DOC$The database role which created the record.

This value is system maintained and is read only via this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_perms.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.

This value is system maintained and is read only via this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_perms.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.

This value is system maintained and is read only via this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_perms.diag_role_modified IS
$DOC$The database role which modified the record.

This value is system maintained and is read only via this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_perms.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.

This value is system maintained and is read only via this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_perms.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.

This value is system maintained and is read only via this API view.$DOC$;
