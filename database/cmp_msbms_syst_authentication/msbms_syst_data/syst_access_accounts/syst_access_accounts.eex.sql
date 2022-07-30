-- File:        syst_access_accounts.eex.sql
-- Location:    musebms/database/cmp_msbms_syst_authentication/msbms_syst_data/syst_access_accounts/syst_access_accounts.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE TABLE msbms_syst_data.syst_access_accounts
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v1( )
        CONSTRAINT syst_access_accounts_pk PRIMARY KEY
    ,internal_name
        text
        NOT NULL
        CONSTRAINT syst_access_accounts_internal_name_udx UNIQUE
    ,external_name
        text
        NOT NULL
    ,owning_owner_id
        uuid
        CONSTRAINT syst_access_accounts_owners_fk
            REFERENCES msbms_syst_data.syst_owners (id) ON DELETE CASCADE
    ,allow_global_logins
        boolean
        NOT NULL DEFAULT false
        CONSTRAINT syst_access_accounts_global_login_chk
            CHECK (NOT allow_global_logins OR owning_owner_id IS NULL)
    ,access_account_state_id
        uuid
        NOT NULL
        CONSTRAINT syst_access_accounts_access_account_states_fk
            REFERENCES msbms_syst_data.syst_enum_items (id)
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

ALTER TABLE msbms_syst_data.syst_access_accounts OWNER TO <%= msbms_owner %>;

REVOKE ALL ON TABLE msbms_syst_data.syst_access_accounts FROM public;
GRANT ALL ON TABLE msbms_syst_data.syst_access_accounts TO <%= msbms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON msbms_syst_data.syst_access_accounts
    FOR EACH ROW EXECUTE PROCEDURE msbms_syst_priv.trig_b_iu_set_diagnostic_columns();

CREATE CONSTRAINT TRIGGER a50_trig_a_i_access_account_states_enum_item_check
    AFTER INSERT ON msbms_syst_data.syst_access_accounts
    FOR EACH ROW EXECUTE PROCEDURE
        msbms_syst_priv.trig_a_iu_enum_item_check(
            'access_account_states', 'access_account_state_id');

CREATE CONSTRAINT TRIGGER a50_trig_a_u_access_account_states_enum_item_check
    AFTER UPDATE ON msbms_syst_data.syst_access_accounts
    FOR EACH ROW WHEN ( old.access_account_state_id != new.access_account_state_id)
        EXECUTE PROCEDURE
            msbms_syst_priv.trig_a_iu_enum_item_check(
                'access_account_states', 'access_account_state_id');

COMMENT ON
    TABLE msbms_syst_data.syst_access_accounts IS
$DOC$Contains the known login accounts which are used solely for the purpose of
authentication of users.  Authorization is handled on a per-instance basis
within the application.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_access_accounts.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_access_accounts.internal_name IS
$DOC$A candidate key useful for programmatic references to individual records.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_access_accounts.external_name IS
$DOC$Provides a user visible name for display purposes only.  This field is not
unique and may not be used as a key.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_access_accounts.owning_owner_id IS
$DOC$Associates the access account with a specific owner.  This allows for access
accounts which are identified and managed exclusively by a given owner.

When this field is NULL, the assumption is that it's an independent access
account.  An independent access account may be used, for example, by third party
accountants that need to access the instances of different owners.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_access_accounts.allow_global_logins IS
$DOC$When true, allows an access account to log into the system without having
an owner or instance specified in the login process.  This use case supports
access accounts which are independently managed, such as might be the case for
external bookkeepers.  When false, the access account is more tightly bound to a
specific owner and so only a specific owner and instances should be evaluated at
login time.

The need for this distinction arises when considering logins for access account
holders such as customers or vendors.  In these cases access to the owner's
environment should appear to be unique, but they may use the same identifier as
used for a different, but unrelated, owner.  In this case you have multiple
access accounts with possibly the same identifier; to resolve the conflict, it
is required therefore to know which owner or instance the access accounts holder
is trying to access.  In the allow global case we can just ask the account
holder but in the disallow global case we need to know it in advance.

Note that when an owning_owner_id value is NOT NULL, then the
allow_global_logins value must be false.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_access_accounts.access_account_state_id IS
$DOC$The current life-cycle state of the access account.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_access_accounts.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_access_accounts.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_access_accounts.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_access_accounts.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_access_accounts.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_access_accounts.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_access_accounts.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;
