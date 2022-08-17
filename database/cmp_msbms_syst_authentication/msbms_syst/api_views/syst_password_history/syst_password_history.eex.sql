-- File:        syst_password_history.eex.sql
-- Location:    musebms/database/cmp_msbms_syst_authentication/msbms_syst/api_views/syst_password_history/syst_password_history.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

CREATE VIEW msbms_syst.syst_password_history AS
SELECT
    id
  , access_account_id
  , credential_data
  , diag_timestamp_created
  , diag_role_created
  , diag_timestamp_modified
  , diag_wallclock_modified
  , diag_role_modified
  , diag_row_version
  , diag_update_count
FROM msbms_syst_data.syst_password_history;

ALTER VIEW msbms_syst.syst_password_history OWNER TO <%= msbms_owner %>;

REVOKE ALL ON TABLE msbms_syst.syst_password_history FROM PUBLIC;

CREATE TRIGGER a50_trig_i_i_syst_password_history
    INSTEAD OF INSERT ON msbms_syst.syst_password_history
    FOR EACH ROW EXECUTE PROCEDURE msbms_syst.trig_i_i_syst_password_history();

CREATE TRIGGER a50_trig_i_u_syst_password_history
    INSTEAD OF UPDATE ON msbms_syst.syst_password_history
    FOR EACH ROW EXECUTE PROCEDURE msbms_syst.trig_i_u_syst_password_history();

CREATE TRIGGER a50_trig_i_d_syst_password_history
    INSTEAD OF DELETE ON msbms_syst.syst_password_history
    FOR EACH ROW EXECUTE PROCEDURE msbms_syst.trig_i_d_syst_password_history();

COMMENT ON
    VIEW msbms_syst.syst_password_history IS
$DOC$Keeps the history of access account prior passwords for enforcing the reuse
password rule.

This API View allows the application to read and maintain the data according to
well defined application business rules.  Using this API view for updates to
data is the preferred method of data maintenance in the course of normal usage.

Only user maintainable values may be maintained via this API.  System created or
maintained data is not maintainable via this view.  Attempts at invalid data
maintenance via this API may result in the invalid changes being ignored or may
raise an exception.$DOC$;

COMMENT ON
    COLUMN msbms_syst.syst_password_history.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN msbms_syst.syst_password_history.access_account_id IS
$DOC$The Access Account to which the password history record belongs.

The value in this column must be set on insert, but may not be updated later via
this API view.$DOC$;

COMMENT ON
    COLUMN msbms_syst.syst_password_history.credential_data IS
$DOC$The previously hashed password recorded for reuse comparisons.  This is the same
format as the existing active password credential.

The value in this column must be set on insert, but may not be updated later via
this API view.$DOC$;

COMMENT ON
    COLUMN msbms_syst.syst_password_history.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN msbms_syst.syst_password_history.diag_role_created IS
$DOC$The database role which created the record.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN msbms_syst.syst_password_history.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN msbms_syst.syst_password_history.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN msbms_syst.syst_password_history.diag_role_modified IS
$DOC$The database role which modified the record.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN msbms_syst.syst_password_history.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN msbms_syst.syst_password_history.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.

This value is read only from this API view.$DOC$;
