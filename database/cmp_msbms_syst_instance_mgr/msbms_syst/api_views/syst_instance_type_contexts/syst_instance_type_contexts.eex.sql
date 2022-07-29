-- File:        syst_instance_type_contexts.eex.sql
-- Location:    musebms/database/cmp_msbms_syst_instance_mgr/msbms_syst/api_views/syst_instance_type_contexts/syst_instance_type_contexts.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE VIEW msbms_syst.syst_instance_type_contexts AS
SELECT
    id
  , instance_type_application_id
  , application_context_id
  , default_db_pool_size
  , diag_timestamp_created
  , diag_role_created
  , diag_timestamp_modified
  , diag_wallclock_modified
  , diag_role_modified
  , diag_row_version
  , diag_update_count
FROM msbms_syst_data.syst_instance_type_contexts;

ALTER VIEW msbms_syst.syst_instance_type_contexts OWNER TO <%= msbms_owner %>;

REVOKE ALL ON TABLE msbms_syst.syst_instance_type_contexts FROM PUBLIC;

CREATE TRIGGER a50_trig_i_i_syst_instance_type_contexts
    INSTEAD OF INSERT ON msbms_syst.syst_instance_type_contexts
    FOR EACH ROW EXECUTE PROCEDURE msbms_syst.trig_i_i_syst_instance_type_contexts();

CREATE TRIGGER a50_trig_i_u_syst_instance_type_contexts
    INSTEAD OF UPDATE ON msbms_syst.syst_instance_type_contexts
    FOR EACH ROW EXECUTE PROCEDURE msbms_syst.trig_i_u_syst_instance_type_contexts();

CREATE TRIGGER a50_trig_i_d_syst_instance_type_contexts
    INSTEAD OF DELETE ON msbms_syst.syst_instance_type_contexts
    FOR EACH ROW EXECUTE PROCEDURE msbms_syst.trig_i_d_syst_instance_type_contexts();

COMMENT ON
    VIEW msbms_syst.syst_instance_type_contexts IS
$DOC$Establishes Instance Type defaults for each of an Application's defined
datastore contexts.  In practice, these records are used in the creation of
Instance Context records, but do not establish a direct relationship; records in
this table simply inform us what Instance Contexts should exist and give us
default values to use in their creation.

This API View allows the application to read and maintain the data according to
well defined application business rules.  Using this API view for updates to
data is the preferred method of data maintenance in the course of normal usage.

Only user maintainable values may be maintained via this API.  System created or
maintained data is not maintainable via this view.  Attempts at invalid data
maintenance via this API may result in the invalid changes being ignored or may
raise an exception.$DOC$;

COMMENT ON
    COLUMN msbms_syst.syst_instance_type_contexts.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.

This column is read only and not maintainable via this API view.$DOC$;

COMMENT ON
    COLUMN msbms_syst.syst_instance_type_contexts.instance_type_application_id IS
$DOC$The Instance Type/Application association to which the context definition
belongs.

This API view will allow INSERT operations for this column, but not UPDATE.$DOC$;

COMMENT ON
    COLUMN msbms_syst.syst_instance_type_contexts.application_context_id IS
$DOC$The Application Context which is being represented in the Instance Type.

This API view will allow INSERT operations for this column, but not UPDATE.$DOC$;

COMMENT ON
    COLUMN msbms_syst.syst_instance_type_contexts.default_db_pool_size IS
$DOC$A default pool size which is assigned to new Instances of the Instance Type
unless the creator of the Instance specifies a different value.$DOC$;

COMMENT ON
    COLUMN msbms_syst.syst_instance_type_contexts.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.

This column is read only and not maintainable via this API view.$DOC$;

COMMENT ON
    COLUMN msbms_syst.syst_instance_type_contexts.diag_role_created IS
$DOC$The database role which created the record.

This column is read only and not maintainable via this API view.$DOC$;

COMMENT ON
    COLUMN msbms_syst.syst_instance_type_contexts.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.

This column is read only and not maintainable via this API view.$DOC$;

COMMENT ON
    COLUMN msbms_syst.syst_instance_type_contexts.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.

This column is read only and not maintainable via this API view.$DOC$;

COMMENT ON
    COLUMN msbms_syst.syst_instance_type_contexts.diag_role_modified IS
$DOC$The database role which modified the record.

This column is read only and not maintainable via this API view.$DOC$;

COMMENT ON
    COLUMN msbms_syst.syst_instance_type_contexts.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.

This column is read only and not maintainable via this API view.$DOC$;

COMMENT ON
    COLUMN msbms_syst.syst_instance_type_contexts.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.

This column is read only and not maintainable via this API view.$DOC$;
