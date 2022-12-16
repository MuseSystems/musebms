-- File:        syst_perm_type_degrees.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_perms/ms_syst/api_views/syst_perm_type_degrees/syst_perm_type_degrees.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

CREATE VIEW ms_syst.syst_perm_type_degrees AS
SELECT
    id
  , internal_name
  , display_name
  , external_name
  , perm_type_id
  , ordering
  , syst_description
  , user_description
  , diag_timestamp_created
  , diag_role_created
  , diag_timestamp_modified
  , diag_wallclock_modified
  , diag_role_modified
  , diag_row_version
  , diag_update_count
FROM ms_syst_data.syst_perm_type_degrees;

ALTER VIEW ms_syst.syst_perm_type_degrees OWNER TO <%= msbms_owner %>;

REVOKE ALL ON TABLE ms_syst.syst_perm_type_degrees FROM PUBLIC;

CREATE TRIGGER a50_trig_i_i_syst_perm_type_degrees
    INSTEAD OF INSERT ON ms_syst.syst_perm_type_degrees
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_i_syst_perm_type_degrees();

CREATE TRIGGER a50_trig_i_u_syst_perm_type_degrees
    INSTEAD OF UPDATE ON ms_syst.syst_perm_type_degrees
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_u_syst_perm_type_degrees();

CREATE TRIGGER a50_trig_i_d_syst_perm_type_degrees
    INSTEAD OF DELETE ON ms_syst.syst_perm_type_degrees
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_d_syst_perm_type_degrees();

COMMENT ON
    VIEW ms_syst.syst_perm_type_degrees IS
$DOC$The available permission degrees available to the parent syst_perm_types record.
Degrees are the relative degrees of authority that a permission of a given type
may grant.

This API View allows the application to read and maintain the data according to
well defined application business rules.  Using this API view for updates to
data is the preferred method of data maintenance in the course of normal usage.

Note that the parent syst_perm_types record referenced by the
syst_perm_type_degrees.perm_type_id field determines the degree to which this
API view allows changes to be made.  If the parent syst_perm_types.syst_defined
value is set true, new child syst_perm_type_degrees records may not be created
or deleted and most update operations will be restricted to a subset of those
allowed by a parent record where the syst_perm_types.syst_defined value is set
false.

Only user maintainable values may be maintained via this API.  System created or
maintained data is not maintainable via this view.  Attempts at invalid data
maintenance via this API may result in the invalid changes being ignored or may
raise an exception.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_perm_type_degrees.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_perm_type_degrees.internal_name IS
$DOC$A candidate key useful for programmatic references to individual records.

Updates to this value are only acceptable if the record's parent
syst_perm_types.syst_defined value is set 'false'.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_perm_type_degrees.display_name IS
$DOC$A friendly name and candidate key for the record, suitable for use in user
interactions$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_perm_type_degrees.external_name IS
$DOC$A non-unique/non-key value used to display to users and external parties where
uniqueness is less of a concern than specific end user presentation.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_perm_type_degrees.perm_type_id IS
$DOC$Associates the syst_perm_type_degrees record with a parent syst_perm_types
record.

After record creation, this value cannot be updated via this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_perm_type_degrees.ordering IS
$DOC$Allows relative sorting of lower degrees of authority to higher degrees where
lower values convey less authority than higher degrees.  This ordering allows
for sorting the records in user interfaces and elsewhere such relative authority
is useful.

Updates to this value are only acceptable if the record's parent
syst_perm_types.syst_defined value is set 'false'.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_perm_type_degrees.syst_description IS
$DOC$A system default description describing the permission and its uses in the
system.

This value may not be set via this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_perm_type_degrees.user_description IS
$DOC$A custom user defined description which overrides the syst_description value
where it would otherwise be used.  If this column is set NULL the
syst_description value will be used.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_perm_type_degrees.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.

This value is system maintained and may only be read via this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_perm_type_degrees.diag_role_created IS
$DOC$The database role which created the record.

This value is system maintained and may only be read via this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_perm_type_degrees.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.

This value is system maintained and may only be read via this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_perm_type_degrees.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.

This value is system maintained and may only be read via this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_perm_type_degrees.diag_role_modified IS
$DOC$The database role which modified the record.

This value is system maintained and may only be read via this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_perm_type_degrees.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.

This value is system maintained and may only be read via this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_perm_type_degrees.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.

This value is system maintained and may only be read via this API view.$DOC$;
