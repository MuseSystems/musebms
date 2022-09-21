-- File:        syst_identities.eex.sql
-- Location:    musebms/database/components/system/msbms_syst_authentication/msbms_syst/api_views/syst_identities/syst_identities.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE VIEW msbms_syst.syst_identities AS
SELECT
    id
  , access_account_id
  , identity_type_id
  , account_identifier
  , validated
  , validates_identity_id
  , validation_requested
  , identity_expires
  , external_name
  , diag_timestamp_created
  , diag_role_created
  , diag_timestamp_modified
  , diag_wallclock_modified
  , diag_role_modified
  , diag_row_version
  , diag_update_count
FROM msbms_syst_data.syst_identities;

ALTER VIEW msbms_syst.syst_identities OWNER TO <%= msbms_owner %>;

REVOKE ALL ON TABLE msbms_syst.syst_identities FROM PUBLIC;

CREATE TRIGGER a50_trig_i_i_syst_identities
    INSTEAD OF INSERT ON msbms_syst.syst_identities
    FOR EACH ROW EXECUTE PROCEDURE msbms_syst.trig_i_i_syst_identities();

CREATE TRIGGER a50_trig_i_u_syst_identities
    INSTEAD OF UPDATE ON msbms_syst.syst_identities
    FOR EACH ROW EXECUTE PROCEDURE msbms_syst.trig_i_u_syst_identities();

CREATE TRIGGER a50_trig_i_d_syst_identities
    INSTEAD OF DELETE ON msbms_syst.syst_identities
    FOR EACH ROW EXECUTE PROCEDURE msbms_syst.trig_i_d_syst_identities();

COMMENT ON
    VIEW msbms_syst.syst_identities IS
$DOC$The identities with which access accounts are identified to the system.  The
most common example of an identity would be a user name such as an email
address.

This API View allows the application to read and maintain the data according to
well defined application business rules.  Using this API view for updates to
data is the preferred method of data maintenance in the course of normal usage.

Only user maintainable values may be maintained via this API.  System created or
maintained data is not maintainable via this view.  Attempts at invalid data
maintenance via this API may result in the invalid changes being ignored or may
raise an exception.$DOC$;

COMMENT ON
    COLUMN msbms_syst.syst_identities.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN msbms_syst.syst_identities.access_account_id IS
$DOC$The ID of the access account to be identified the identifier record.

This value may only be set on INSERT via this API view.  UPDATEs to this value
are not allowed after record creation.$DOC$;

COMMENT ON
    COLUMN msbms_syst.syst_identities.identity_type_id IS
$DOC$The kind of identifier being described by the record.  Note that this value
influences the kind of credentials that can be used to complete the
authentication process.

This value may only be set on INSERT via this API view.  UPDATEs to this value
are not allowed after record creation.$DOC$;

COMMENT ON
    COLUMN msbms_syst.syst_identities.account_identifier IS
$DOC$The actual identifier which identifies a user or system to the system.

This value may only be set on INSERT via this API view.  UPDATEs to this value
are not allowed after record creation.$DOC$;

COMMENT ON
    COLUMN msbms_syst.syst_identities.validated IS
$DOC$The timestamp at which the identity was validated for use.  Depending on the
requirements of the identity functional type, the timestamp here may be set as
the time of the identity creation or it may set when the access account holder
actually makes a formal verification.  A null value here indicates that the
identity is not validated by the access account holder and is not able to be
used for authentication to the system.$DOC$;

COMMENT ON
    COLUMN msbms_syst.syst_identities.validates_identity_id IS
$DOC$Each identity requiring validation will require its own validation.  Since
validation requests are also single use identities, we need to know which
permanent identifier is being validate.  This column points to the identifier
that is being validated.  When the current identifier is not being used for
validation, this field is null.

This value may only be set on INSERT via this API view.  UPDATEs to this value
are not allowed after record creation.$DOC$;

COMMENT ON
    COLUMN msbms_syst.syst_identities.validation_requested IS
$DOC$The timestamp on which the validation request was issued to the access account
holder.  This value will be null if the identity did not require validation.$DOC$;

COMMENT ON
    COLUMN msbms_syst.syst_identities.identity_expires IS
$DOC$The timestamp at which the identity record expires.  For validation and
recovery identities this would be the time of validation/recovery request
expiration.  For perpetual identity types, this value will be NULL.$DOC$;

COMMENT ON
    COLUMN msbms_syst.syst_identities.external_name IS
$DOC$An optional external identifier for use in user displays and similar scenarios.
This value is not unique and not suitable for anything more than informal record
identification by the user.  Some identity types may record a default value
automatically in this column.$DOC$;

COMMENT ON
    COLUMN msbms_syst.syst_identities.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN msbms_syst.syst_identities.diag_role_created IS
$DOC$The database role which created the record.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN msbms_syst.syst_identities.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN msbms_syst.syst_identities.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN msbms_syst.syst_identities.diag_role_modified IS
$DOC$The database role which modified the record.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN msbms_syst.syst_identities.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN msbms_syst.syst_identities.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.

This value is read only from this API view.$DOC$;
