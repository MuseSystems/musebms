-- File:        syst_credentials.eex.sql
-- Location:    musebms/database/components/system/msbms_syst_authentication/msbms_syst/api_views/syst_credentials/syst_credentials.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE VIEW msbms_syst.syst_credentials AS
SELECT
    id
  , access_account_id
  , credential_type_id
  , credential_for_identity_id
  , credential_data
  , last_updated
  , external_name
  , diag_timestamp_created
  , diag_role_created
  , diag_timestamp_modified
  , diag_wallclock_modified
  , diag_role_modified
  , diag_row_version
  , diag_update_count
FROM msbms_syst_data.syst_credentials;

ALTER VIEW msbms_syst.syst_credentials OWNER TO <%= msbms_owner %>;

REVOKE ALL ON TABLE msbms_syst.syst_credentials FROM PUBLIC;

CREATE TRIGGER a50_trig_i_i_syst_credentials
    INSTEAD OF INSERT ON msbms_syst.syst_credentials
    FOR EACH ROW EXECUTE PROCEDURE msbms_syst.trig_i_i_syst_credentials();

CREATE TRIGGER a50_trig_i_u_syst_credentials
    INSTEAD OF UPDATE ON msbms_syst.syst_credentials
    FOR EACH ROW EXECUTE PROCEDURE msbms_syst.trig_i_u_syst_credentials();

CREATE TRIGGER a50_trig_i_d_syst_credentials
    INSTEAD OF DELETE ON msbms_syst.syst_credentials
    FOR EACH ROW EXECUTE PROCEDURE msbms_syst.trig_i_d_syst_credentials();

COMMENT ON
    VIEW msbms_syst.syst_credentials IS
$DOC$Hosts the credentials by which a user or external system will prove its identity.
Note that not all credential types are available for authentication with all
identity types.

This API View allows the application to read and maintain the data according to
well defined application business rules.  Using this API view for updates to
data is the preferred method of data maintenance in the course of normal usage.

Only user maintainable values may be maintained via this API.  System created or
maintained data is not maintainable via this view.  Attempts at invalid data
maintenance via this API may result in the invalid changes being ignored or may
raise an exception.$DOC$;

COMMENT ON
    COLUMN msbms_syst.syst_credentials.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN msbms_syst.syst_credentials.access_account_id IS
$DOC$The access account for which the credential is to be used.

This value may only be set on INSERT via this API view.  UPDATEs to this value
are not allowed after record creation.$DOC$;

COMMENT ON
    COLUMN msbms_syst.syst_credentials.credential_type_id IS
$DOC$The kind of credential that the record represents.  Note that the behavior and
use cases of the credential may have specific processing and handling
requirements based on the functional type of the credential type.

This value may only be set on INSERT via this API view.  UPDATEs to this value
are not allowed after record creation.$DOC$;

COMMENT ON
    COLUMN msbms_syst.syst_credentials.credential_for_identity_id IS
$DOC$When an access account identity is created for either identity validation or
access account recovery, a single use identity is created as well as a single
use credential.  In this specific case, the one time use credential and the one
time use identity are linked.  This is especially important in recovery
scenarios to ensure that only the correct recovery communication can recover the
account.  This field identifies the which identity is associated with the
credential.

For regular use identities, there are no special credential requirements that
would be needed to for a link and the value in this column should be null.

This value may only be set on INSERT via this API view.  UPDATEs to this value
are not allowed after record creation.$DOC$;

COMMENT ON
    COLUMN msbms_syst.syst_credentials.credential_data IS
$DOC$The actual data which supports verifying the presented identity in relation to
the access account.$DOC$;

COMMENT ON
    COLUMN msbms_syst.syst_credentials.last_updated IS
$DOC$For credential types where rules regarding updating may apply, such as common
passwords, this column indicates when the credential was last updated (timestamp
of last password change, for example).   This field is explicitly not for dating
trivial or administrative changes which don't actually materially change the
credential data; please consult the appropriate diagnostic fields for those use
cases.$DOC$;

COMMENT ON
    COLUMN msbms_syst.syst_credentials.external_name IS
$DOC$An optional external identifier for use in user displays and similar scenarios.
This value is not unique and not suitable for anything more than informal record
identification by the user.  Some credential types may record a default value
automatically in this column.$DOC$;

COMMENT ON
    COLUMN msbms_syst.syst_credentials.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN msbms_syst.syst_credentials.diag_role_created IS
$DOC$The database role which created the record.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN msbms_syst.syst_credentials.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN msbms_syst.syst_credentials.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN msbms_syst.syst_credentials.diag_role_modified IS
$DOC$The database role which modified the record.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN msbms_syst.syst_credentials.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN msbms_syst.syst_credentials.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.

This value is read only from this API view.$DOC$;
