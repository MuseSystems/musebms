-- File:        syst_access_accounts.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/ms_syst_data/syst_access_accounts/syst_access_accounts.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE TABLE ms_syst_data.syst_access_accounts
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v7( )
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
            REFERENCES ms_syst_data.syst_owners (id) ON DELETE CASCADE
    ,allow_global_logins
        boolean
        NOT NULL DEFAULT false
    ,access_account_state_id
        uuid
        NOT NULL
        CONSTRAINT syst_access_accounts_access_account_states_fk
            REFERENCES ms_syst_data.syst_enum_items (id)
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

ALTER TABLE ms_syst_data.syst_access_accounts OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst_data.syst_access_accounts FROM public;
GRANT ALL ON TABLE ms_syst_data.syst_access_accounts TO <%= ms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_syst_data.syst_access_accounts
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

CREATE CONSTRAINT TRIGGER a50_trig_a_i_access_account_states_enum_item_check
    AFTER INSERT ON ms_syst_data.syst_access_accounts
    FOR EACH ROW EXECUTE PROCEDURE
        ms_syst_priv.trig_a_iu_enum_item_check(
            'access_account_states', 'access_account_state_id');

CREATE CONSTRAINT TRIGGER a50_trig_a_u_access_account_states_enum_item_check
    AFTER UPDATE ON ms_syst_data.syst_access_accounts
    FOR EACH ROW WHEN ( old.access_account_state_id != new.access_account_state_id)
        EXECUTE PROCEDURE
            ms_syst_priv.trig_a_iu_enum_item_check(
                'access_account_states', 'access_account_state_id');

DO
$DOCUMENTATION$
DECLARE
    -- Table
    var_comments_config ms_syst_priv.comments_config_table;

    -- Columns
    var_owning_owner_id         ms_syst_priv.comments_config_table_column;
    var_allow_global_logins     ms_syst_priv.comments_config_table_column;
    var_access_account_state_id ms_syst_priv.comments_config_table_column;

BEGIN

    --
    -- Table Config
    --

    var_comments_config.table_schema := 'ms_syst_data';
    var_comments_config.table_name   := 'syst_access_accounts';

    var_comments_config.description :=
$DOC$Contains the known login accounts which are used solely for the purpose of
authentication of users.  Authorization is handled on a per-Instance basis
within the application.$DOC$;

    --
    -- Column Configs
    --

    var_owning_owner_id.column_name := 'owning_owner_id';
    var_owning_owner_id.description :=
$DOC$Associates the Access Account with a specific Owner.  This allows for access
accounts which are identified and managed exclusively by a given Owner.$DOC$;
    var_owning_owner_id.general_usage :=
$DOC$When this field is NULL, the assumption is that it's an independent access
account.  An independent Access Account may be used, for example, by third party
accountants that need to access the Instances of different Owners.$DOC$;

    var_allow_global_logins.column_name := 'allow_global_logins';
    var_allow_global_logins.description :=
$DOC$Indicates whether or not an Access Account may be used to login outside of the
context of a specific Owner or Instance.  This use case supports Access Accounts
which are independently managed, such as might be the case for external
bookkeepers.

The need for this distinction arises when considering logins for Access Account
holders such as customers or vendors.  In these cases access to the Owner's
environment should appear to be unique, but they may use the same identifier as
used for a different, but unrelated, Owner.  In this case you have multiple
Access Accounts with possibly the same identifier; to resolve the conflict, it
is required therefore to know which Owner or Instance the Access Accounts holder
is trying to access.  In the allow global case we can just ask the account
holder but in the disallow global case we need to know it in advance.

Another way to think about global logins is in relation to user interface.  A
global login interface may present the user with a choice of Instance Owners and
then their Instances whereas the non-global login user must go directly to the
login interface for a specific Owner (be that URL or other client-side specific
identification.)$DOC$;
    var_allow_global_logins.general_usage :=
$DOC$When true, allows an Access Account to log into the system without having an
Owner or Instance specified in the login process.  When false, the Access
Account is more tightly bound to a specific Owner and so only a specific Owner
and Instances should be evaluated at login time.$DOC$;

var_access_account_state_id.column_name := 'access_account_state_id';
    var_access_account_state_id.description :=
$DOC$The current life-cycle state of the Access Account.$DOC$;

    var_comments_config.columns :=
        ARRAY [
              var_owning_owner_id
            , var_allow_global_logins
            , var_access_account_state_id
            ]::ms_syst_priv.comments_config_table_column[];

    PERFORM ms_syst_priv.generate_comments_table( var_comments_config );

END;
$DOCUMENTATION$;
