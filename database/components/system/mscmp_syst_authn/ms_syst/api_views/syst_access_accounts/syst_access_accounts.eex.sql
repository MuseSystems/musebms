-- File:        syst_access_accounts.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/ms_syst/api_views/syst_access_accounts/syst_access_accounts.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE VIEW ms_syst.syst_access_accounts AS
    SELECT
          id
        , internal_name
        , external_name
        , owning_owner_id
        , allow_global_logins
        , access_account_state_id
        , diag_timestamp_created
        , diag_role_created
        , diag_timestamp_modified
        , diag_wallclock_modified
        , diag_role_modified
        , diag_row_version
        , diag_update_count
    FROM ms_syst_data.syst_access_accounts;

ALTER VIEW ms_syst.syst_access_accounts OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst.syst_access_accounts FROM PUBLIC;

CREATE TRIGGER a50_trig_i_i_syst_access_accounts
    INSTEAD OF INSERT ON ms_syst.syst_access_accounts
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_i_syst_access_accounts();

CREATE TRIGGER a50_trig_i_u_syst_access_accounts
    INSTEAD OF UPDATE ON ms_syst.syst_access_accounts
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_u_syst_access_accounts();

CREATE TRIGGER a50_trig_i_d_syst_access_accounts
    INSTEAD OF DELETE ON ms_syst.syst_access_accounts
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_d_syst_access_accounts();

COMMENT ON
    VIEW ms_syst.syst_access_accounts IS
$DOC$Contains the known login accounts which are used solely for the purpose of
authentication of users.  Authorization is handled on a per-instance basis
within the application.

This API View allows the application to read and maintain the data according to
well defined application business rules.  Using this API view for updates to
data is the preferred method of data maintenance in the course of normal usage.

Only user maintainable values may be maintained via this API.  System created or
maintained data is not maintainable via this view.  Attempts at invalid data
maintenance via this API may result in the invalid changes being ignored or may
raise an exception.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_access_accounts.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.

This value may not be updated via this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_access_accounts.internal_name IS
$DOC$A candidate key useful for programmatic references to individual records.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_access_accounts.external_name IS
$DOC$Provides a user visible name for display purposes only.  This field is not
unique and may not be used as a key.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_access_accounts.owning_owner_id IS
$DOC$Associates the access account with a specific owner.  This allows for access
accounts which are identified and managed exclusively by a given owner.

When this field is NULL, the assumption is that it's an independent access
account.  An independent access account may be used, for example, by third party
accountants that need to access the instances of different owners.

This value may only be set on INSERT via this API view.  UPDATEs to this value
are not allowed after record creation.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_access_accounts.allow_global_logins IS
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

Another way to think about global logins is in relation to user interface.  A
global login interface may present the user with a choice of instance owners and
then their instances whereas the non-global login user must go directly to the
login interface for a specific owner (be that URL or other client-side specific
identification.)$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_access_accounts.access_account_state_id IS
$DOC$The current life-cycle state of the access account.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_access_accounts.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_access_accounts.diag_role_created IS
$DOC$The database role which created the record.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_access_accounts.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_access_accounts.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_access_accounts.diag_role_modified IS
$DOC$The database role which modified the record.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_access_accounts.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_access_accounts.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.

This value is read only from this API view.$DOC$;
