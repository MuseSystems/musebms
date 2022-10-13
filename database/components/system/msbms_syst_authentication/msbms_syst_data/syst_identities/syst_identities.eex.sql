-- File:        syst_identities.eex.sql
-- Location:    musebms/database/components/system/msbms_syst_authentication/msbms_syst_data/syst_identities/syst_identities.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE TABLE msbms_syst_data.syst_identities
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v1( )
        CONSTRAINT syst_identities_pk PRIMARY KEY
    ,access_account_id
        uuid
        NOT NULL
        CONSTRAINT syst_identities_access_accounts_fk
            REFERENCES msbms_syst_data.syst_access_accounts (id) ON DELETE CASCADE
    ,identity_type_id
        uuid
        NOT NULL
        CONSTRAINT syst_identities_identity_types_fk
            REFERENCES msbms_syst_data.syst_enum_items (id) ON DELETE CASCADE
    ,account_identifier
        text
        NOT NULL
    ,validated
        timestamptz
    ,validates_identity_id
        uuid
        CONSTRAINT syst_identities_validates_identities_fk
            REFERENCES msbms_syst_data.syst_identities (id) ON DELETE CASCADE
        CONSTRAINT syst_identities_validates_identities_udx UNIQUE
    ,validation_requested
        timestamptz
    ,CONSTRAINT syst_identities_primary_validator_chk
        CHECK ( ( validated IS NULL AND
                  validation_requested IS NULL AND
                  validates_identity_id IS NOT NULL ) OR validates_identity_id IS NULL )
    ,identity_expires
        timestamptz
    ,external_name
        text
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

ALTER TABLE msbms_syst_data.syst_identities OWNER TO <%= msbms_owner %>;

REVOKE ALL ON TABLE msbms_syst_data.syst_identities FROM public;
GRANT ALL ON TABLE msbms_syst_data.syst_identities TO <%= msbms_owner %>;

CREATE TRIGGER a50_trig_b_i_syst_identities_validate_uniqueness
    BEFORE INSERT ON msbms_syst_data.syst_identities
    FOR EACH ROW EXECUTE PROCEDURE msbms_syst_data.trig_b_i_syst_identities_validate_uniqueness();

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON msbms_syst_data.syst_identities
    FOR EACH ROW EXECUTE PROCEDURE msbms_syst_priv.trig_b_iu_set_diagnostic_columns();

CREATE CONSTRAINT TRIGGER a50_trig_a_i_identity_types_enum_item_check
    AFTER INSERT ON msbms_syst_data.syst_identities
    FOR EACH ROW EXECUTE PROCEDURE
        msbms_syst_priv.trig_a_iu_enum_item_check('identity_types', 'identity_type_id');

CREATE CONSTRAINT TRIGGER a50_trig_a_u_identity_types_enum_item_check
    AFTER UPDATE ON msbms_syst_data.syst_identities
    FOR EACH ROW WHEN ( old.identity_type_id != new.identity_type_id)
        EXECUTE PROCEDURE
            msbms_syst_priv.trig_a_iu_enum_item_check(
                'identity_types', 'identity_type_id');

COMMENT ON
    TABLE msbms_syst_data.syst_identities IS
$DOC$The identities with which access accounts are identified to the system.  The
most common example of an identity would be a user name such as an email
address.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_identities.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_identities.access_account_id IS
$DOC$The ID of the access account to be identified the identifier record.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_identities.identity_type_id IS
$DOC$The kind of identifier being described by the record.  Note that this value
influences the kind of credentials that can be used to complete the
authentication process.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_identities.account_identifier IS
$DOC$The actual identifier which identifies a user or system to the system.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_identities.validated IS
$DOC$The timestamp at which the identity was validated for use.  Depending on the
requirements of the identity functional type, the timestamp here may be set as
the time of the identity creation or it may set when the access account holder
actually makes a formal verification.  A null value here indicates that the
identity is not validated by the access account holder and is not able to be
used for authentication to the system.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_identities.validates_identity_id IS
$DOC$Each identity requiring validation will require its own validation.  Since
validation requests are also single use identities, we need to know which
permanent identifier is being validate.  This column points to the identifier
that is being validated.  When the current identifier is not being used for
validation, this field is null.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_identities.validation_requested IS
$DOC$The timestamp on which the validation request was issued to the access account
holder.  This value will be null if the identity did not require validation.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_identities.identity_expires IS
$DOC$The timestamp at which the identity record expires.  For validation and
recovery identities this would be the time of validation/recovery request
expiration.  For perpetual identity types, this value will be NULL.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_identities.external_name IS
$DOC$An optional external identifier for use in user displays and similar scenarios.
This value is not unique and not suitable for anything more than informal record
identification by the user.  Some identity types may record a default value
automatically in this column.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_identities.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_identities.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_identities.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_identities.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_identities.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_identities.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_identities.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;

CREATE INDEX syst_identities_account_type_identifier_idx
    ON msbms_syst_data.syst_identities USING btree
        ( identity_type_id, access_account_id, account_identifier );

CREATE INDEX syst_identities_access_account_idx
    ON msbms_syst_data.syst_identities USING btree ( access_account_id );
