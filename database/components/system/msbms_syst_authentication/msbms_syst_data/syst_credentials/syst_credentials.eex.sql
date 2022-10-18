-- File:        syst_credentials.eex.sql
-- Location:    musebms/database/components/system/msbms_syst_authentication/msbms_syst_data/syst_credentials/syst_credentials.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE TABLE msbms_syst_data.syst_credentials
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v1( )
        CONSTRAINT syst_credentials_pk PRIMARY KEY
    ,access_account_id
        uuid
        NOT NULL
        CONSTRAINT syst_credentials_access_accounts_fk
            REFERENCES msbms_syst_data.syst_access_accounts (id) ON DELETE CASCADE
    ,credential_type_id
        uuid
        NOT NULL
        CONSTRAINT syst_credentials_credential_types_fk
            REFERENCES msbms_syst_data.syst_enum_items (id)
    ,credential_for_identity_id
        uuid
        CONSTRAINT syst_credentials_for_identities_fk
            REFERENCES msbms_syst_data.syst_identities (id) ON DELETE CASCADE
    ,CONSTRAINT syst_credentials_udx
        UNIQUE NULLS NOT DISTINCT
            (access_account_id, credential_type_id, credential_for_identity_id)
    ,credential_data
        text
        NOT NULL
    ,last_updated
        timestamptz
        NOT NULL DEFAULT now( )
    ,force_reset
        timestamptz
    ,diag_timestamp_created
        timestamptz
        NOT NULL DEFAULT now( )
    ,diag_role_created
        text
        NOT NULL
    ,diag_timestamp_modified
        timestamptz
        NOT NULL DEFAULT now( )
    ,diag_wallclock_modified
        timestamptz
        NOT NULL DEFAULT clock_timestamp( )
    ,diag_role_modified
        text
        NOT NULL
    ,diag_row_version
        bigint
        NOT NULL DEFAULT 1
    ,diag_update_count
        bigint
        NOT NULL DEFAULT 0
);

ALTER TABLE msbms_syst_data.syst_credentials OWNER TO <%= msbms_owner %>;

REVOKE ALL ON TABLE msbms_syst_data.syst_credentials FROM public;
GRANT ALL ON TABLE msbms_syst_data.syst_credentials TO <%= msbms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON msbms_syst_data.syst_credentials
    FOR EACH ROW EXECUTE PROCEDURE msbms_syst_priv.trig_b_iu_set_diagnostic_columns();

CREATE CONSTRAINT TRIGGER a50_trig_a_i_credential_types_enum_item_check
    AFTER INSERT ON msbms_syst_data.syst_credentials
    FOR EACH ROW EXECUTE PROCEDURE
        msbms_syst_priv.trig_a_iu_enum_item_check('credential_types', 'credential_type_id');

CREATE CONSTRAINT TRIGGER a50_trig_a_u_credential_types_enum_item_check
    AFTER UPDATE ON msbms_syst_data.syst_credentials
    FOR EACH ROW WHEN ( old.credential_type_id != new.credential_type_id)
        EXECUTE PROCEDURE
            msbms_syst_priv.trig_a_iu_enum_item_check(
                'credential_types', 'credential_type_id');

CREATE CONSTRAINT TRIGGER b50_trig_a_d_syst_credentials_delete_identity
    AFTER DELETE ON msbms_syst_data.syst_credentials
    FOR EACH ROW WHEN ( old.credential_for_identity_id IS NOT NULL)
    EXECUTE PROCEDURE msbms_syst_data.trig_a_d_syst_credentials_delete_identity();

COMMENT ON
    TABLE msbms_syst_data.syst_credentials IS
$DOC$Hosts the credentials by which a user or external system will prove its identity.
Note that not all credential types are available for authentication with all
identity types.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_credentials.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_credentials.access_account_id IS
$DOC$The access account for which the credential is to be used.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_credentials.credential_type_id IS
$DOC$The kind of credential that the record represents.  Note that the behavior and
use cases of the credential may have specific processing and handling
requirements based on the functional type of the credential type.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_credentials.credential_for_identity_id IS
$DOC$When an access account identity is created for either identity validation or
access account recovery, a single use identity is created as well as a single
use credential.  In this specific case, the one time use credential and the one
time use identity are linked.  This is especially important in recovery
scenarios to ensure that only the correct recovery communication can recover the
account.  This field identifies the which identity is associated with the
credential.

For regular use identities, there are no special credential requirements that
would be needed to for a link and the value in this column should be null.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_credentials.credential_data IS
$DOC$The actual data which supports verifying the presented identity in relation to
the access account.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_credentials.last_updated IS
$DOC$For credential types where rules regarding updating may apply, such as common
passwords, this column indicates when the credential was last updated (timestamp
of last password change, for example).   This field is explicitly not for dating
trivial or administrative changes which don't actually materially change the
credential data; please consult the appropriate diagnostic fields for those use
cases.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_credentials.force_reset IS
$DOC$Indicates whether or not certain credential types, such as passwords, must be
updated.  When NOT NULL, the user must update their credential on the next
login; when NULL updating the credential is not being administratively forced.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_credentials.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_credentials.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_credentials.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_credentials.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_credentials.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_credentials.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_credentials.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;
