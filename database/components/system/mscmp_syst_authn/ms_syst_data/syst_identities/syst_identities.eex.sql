-- File:        syst_identities.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/ms_syst_data/syst_identities/syst_identities.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE TABLE ms_syst_data.syst_identities
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v7( )
        CONSTRAINT syst_identities_pk PRIMARY KEY
    ,access_account_id
        uuid
        NOT NULL
        CONSTRAINT syst_identities_access_accounts_fk
            REFERENCES ms_syst_data.syst_access_accounts (id) ON DELETE CASCADE
    ,identity_type_id
        uuid
        NOT NULL
        CONSTRAINT syst_identities_identity_types_fk
            REFERENCES ms_syst_data.syst_enum_items (id) ON DELETE CASCADE
    ,account_identifier
        text
        NOT NULL
    ,validated
        timestamptz
    ,validates_identity_id
        uuid
        CONSTRAINT syst_identities_validates_identities_fk
            REFERENCES ms_syst_data.syst_identities (id) ON DELETE CASCADE
        CONSTRAINT syst_identities_validates_identities_udx UNIQUE
    ,validation_requested
        timestamptz
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

ALTER TABLE ms_syst_data.syst_identities OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst_data.syst_identities FROM public;
GRANT ALL ON TABLE ms_syst_data.syst_identities TO <%= ms_owner %>;

CREATE TRIGGER a50_trig_b_i_syst_identities_validate_uniqueness
    BEFORE INSERT ON ms_syst_data.syst_identities
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_data.trig_b_i_syst_identities_validate_uniqueness();

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_syst_data.syst_identities
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

CREATE CONSTRAINT TRIGGER a50_trig_a_i_identity_types_enum_item_check
    AFTER INSERT ON ms_syst_data.syst_identities
    FOR EACH ROW EXECUTE PROCEDURE
        ms_syst_priv.trig_a_iu_enum_item_check('identity_types', 'identity_type_id');

CREATE CONSTRAINT TRIGGER a50_trig_a_u_identity_types_enum_item_check
    AFTER UPDATE ON ms_syst_data.syst_identities
    FOR EACH ROW WHEN ( old.identity_type_id != new.identity_type_id)
        EXECUTE PROCEDURE
            ms_syst_priv.trig_a_iu_enum_item_check(
                'identity_types', 'identity_type_id');


CREATE INDEX syst_identities_account_type_identifier_idx
    ON ms_syst_data.syst_identities USING btree
        ( identity_type_id, access_account_id, account_identifier );

CREATE INDEX syst_identities_access_account_idx
    ON ms_syst_data.syst_identities USING btree ( access_account_id );

DO
$DOCUMENTATION$
DECLARE
    -- Table
    var_comments_config ms_syst_priv.comments_config_table;

    -- Columns
    var_access_account_id     ms_syst_priv.comments_config_table_column;
    var_identity_type_id      ms_syst_priv.comments_config_table_column;
    var_account_identifier    ms_syst_priv.comments_config_table_column;
    var_validated             ms_syst_priv.comments_config_table_column;
    var_validates_identity_id ms_syst_priv.comments_config_table_column;
    var_validation_requested  ms_syst_priv.comments_config_table_column;
    var_identity_expires      ms_syst_priv.comments_config_table_column;

BEGIN

    --
    -- Table Config
    --

    var_comments_config.table_schema := 'ms_syst_data';
    var_comments_config.table_name   := 'syst_identities';

    var_comments_config.description :=
$DOC$The identities with which access accounts are identified to the system.  The
most common example of an identity would be a user name such as an email
address.$DOC$;

    --
    -- Column Configs
    --

    var_access_account_id.column_name := 'access_account_id';
    var_access_account_id.description :=
$DOC$The ID of the access account to be identified the identifier record.$DOC$;

    var_identity_type_id.column_name := 'identity_type_id';
    var_identity_type_id.description :=
$DOC$The kind of identifier being described by the record.$DOC$;
    var_identity_type_id.general_usage :=
$DOC$Note that this value influences the kind of credentials that can be used to
complete the authentication process.$DOC$;

    var_account_identifier.column_name   := 'account_identifier';
    var_account_identifier.description   :=
$DOC$The actual Identifier which identifies a user or system to the system.$DOC$;
    var_account_identifier.general_usage :=
$DOC$Identifiers of the same Identifier Type are unique to the Owner/Access
Account combination. All Unowned Access Accounts are considered as being in the
same Owner group for this purpose.$DOC$;

    var_validated.column_name := 'validated';
    var_validated.description :=
$DOC$The timestamp at which the identity was validated for use.$DOC$;
    var_validated.general_usage :=
$DOC$  Depending on the requirements of the identity functional type, the timestamp
here may be set as the time of the identity creation or it may set when the
access account holder actually makes a formal verification.  A null value here
indicates that the identity is not validated by the access account holder and is
not able to be used for authentication to the system.$DOC$;

    var_validates_identity_id.column_name := 'validates_identity_id';
    var_validates_identity_id.description :=
$DOC$Each identity requiring validation will require its own validation.$DOC$;
    var_validates_identity_id.general_usage :=
$DOC$Since validation requests are also single use identities, we need to know which
permanent identifier is being validate.  This column points to the identifier
that is being validated.  When the current identifier is not being used for
validation, this field is null.$DOC$;

    var_validation_requested.column_name := 'validation_requested';
    var_validation_requested.description :=
$DOC$The timestamp on which the validation request was issued to the access account
holder.$DOC$;
    var_validation_requested.general_usage :=
        $DOC$This value will be null if the identity did not require validation.$DOC$;


    var_identity_expires.column_name := 'identity_expires';
    var_identity_expires.description :=
$DOC$The timestamp at which the identity record expires.$DOC$;
    var_identity_expires.general_usage :=
$DOC$For validation and recovery identities this would be the time of
validation/recovery request expiration.  For perpetual identity types, this
value will be NULL.$DOC$;

    var_comments_config.columns :=
        ARRAY [
              var_access_account_id
            , var_identity_type_id
            , var_account_identifier
            , var_validated
            , var_validates_identity_id
            , var_validation_requested
            , var_identity_expires
            ]::ms_syst_priv.comments_config_table_column[];

    PERFORM ms_syst_priv.generate_comments_table( var_comments_config );

END;
$DOCUMENTATION$;
