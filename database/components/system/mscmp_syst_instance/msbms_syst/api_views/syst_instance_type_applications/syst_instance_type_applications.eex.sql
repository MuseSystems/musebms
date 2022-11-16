-- File:        syst_instance_type_applications.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_instance/msbms_syst/api_views/syst_instance_type_applications/syst_instance_type_applications.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE VIEW msbms_syst.syst_instance_type_applications AS
SELECT
    id
  , instance_type_id
  , application_id
  , diag_timestamp_created
  , diag_role_created
  , diag_timestamp_modified
  , diag_wallclock_modified
  , diag_role_modified
  , diag_row_version
  , diag_update_count
FROM msbms_syst_data.syst_instance_type_applications;

ALTER VIEW msbms_syst.syst_instance_type_applications OWNER TO <%= msbms_owner %>;

REVOKE ALL ON TABLE msbms_syst.syst_instance_type_applications FROM PUBLIC;

CREATE TRIGGER a50_trig_i_i_syst_instance_type_applications
    INSTEAD OF INSERT ON msbms_syst.syst_instance_type_applications
    FOR EACH ROW EXECUTE PROCEDURE msbms_syst.trig_i_i_syst_instance_type_applications();

CREATE TRIGGER a50_trig_i_u_syst_instance_type_applications
    INSTEAD OF UPDATE ON msbms_syst.syst_instance_type_applications
    FOR EACH ROW EXECUTE PROCEDURE msbms_syst.trig_i_u_syst_instance_type_applications();

CREATE TRIGGER a50_trig_i_d_syst_instance_type_applications
    INSTEAD OF DELETE ON msbms_syst.syst_instance_type_applications
    FOR EACH ROW EXECUTE PROCEDURE msbms_syst.trig_i_d_syst_instance_type_applications();

COMMENT ON
    VIEW msbms_syst.syst_instance_type_applications IS
$DOC$A many-to-many relation indicating which Instance Types are usable for each
Application.

Note that creating msbms_syst_data.syst_application_contexts records prior to
inserting an Instance Type/Application association into this table is
recommended as default Instance Type Context records can be created
automatically on INSERT into this table so long as the supporting data is
available.  After insert here, manipulations of what Contexts Applications
require must be handled manually.

Also note that this API view only allows for INSERT or DELETE operations to be
performed on the data.  UPDATE operations are not valid and will cause an
exception to be raised.

This API View allows the application to create and read the data according to
well defined application business rules.  Using this API view for updates to
data is the preferred method of data maintenance in the course of normal usage.

Only user maintainable values may be maintained via this API.  System created or
maintained data is not maintainable via this view.  Attempts at invalid data
maintenance via this API may result in the invalid changes being ignored or may
raise an exception.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_instance_type_applications.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.

This value may not be updated via this API view.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_instance_type_applications.instance_type_id IS
$DOC$A reference to the Instance Type being associated to an Application.

This value must be set on INSERT and may not be updated later via this API view.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_instance_type_applications.application_id IS
$DOC$A reference to the Application being associated with the Instance Type.

This value must be set on INSERT and may not be updated later via this API view.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_instance_type_applications.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_instance_type_applications.diag_role_created IS
$DOC$The database role which created the record.

This value may not be updated via this API view.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_instance_type_applications.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.

This value may not be updated via this API view.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_instance_type_applications.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.

This value may not be updated via this API view.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_instance_type_applications.diag_role_modified IS
$DOC$The database role which modified the record.

This value may not be updated via this API view.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_instance_type_applications.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.

This value may not be updated via this API view.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_instance_type_applications.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.

This value may not be updated via this API view.$DOC$;
