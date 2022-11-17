-- File:        syst_owner_password_rules.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/ms_syst_data/syst_owner_password_rules/syst_owner_password_rules.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

CREATE TABLE ms_syst_data.syst_owner_password_rules
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v1( )
        CONSTRAINT syst_owner_password_rules_pk PRIMARY KEY
    ,owner_id
        uuid
        NOT NULL
        CONSTRAINT syst_owner_password_rules_owner_fk
            REFERENCES ms_syst_data.syst_owners ( id )
            ON DELETE CASCADE
        CONSTRAINT syst_owner_password_rules_owner_udx UNIQUE
    ,password_length
        int4range
        NOT NULL DEFAULT int4range(8, 64, '[]')
    ,max_age
        interval
        NOT NULL DEFAULT '0 days'::interval
    ,require_upper_case
        integer
        NOT NULL DEFAULT 0
    ,require_lower_case
        integer
        NOT NULL DEFAULT 0
    ,require_numbers
        integer
        NOT NULL DEFAULT 0
    ,require_symbols
        integer
        NOT NULL DEFAULT 0
    ,disallow_recently_used
        integer
        NOT NULL DEFAULT 0
    ,disallow_compromised
        boolean
        NOT NULL DEFAULT TRUE
    ,require_mfa
        boolean
        NOT NULL DEFAULT TRUE
    ,allowed_mfa_types
        text[]
        NOT NULL DEFAULT ARRAY[]::text[]
    ,diag_timestamp_created
        timestamptz
        NOT NULL DEFAULT now( )
    ,diag_role_created
        text
    ,diag_timestamp_modified
        timestamptz
        NOT NULL DEFAULT now( )
    ,diag_wallclock_modified
        timestamptz
        NOT NULL DEFAULT clock_timestamp( )
    ,diag_role_modified
        text
    ,diag_row_version
        bigint
        NOT NULL DEFAULT 1
    ,diag_update_count
        bigint
        NOT NULL DEFAULT 0
);

ALTER TABLE ms_syst_data.syst_owner_password_rules OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst_data.syst_owner_password_rules FROM public;
GRANT ALL ON TABLE ms_syst_data.syst_owner_password_rules TO <%= ms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_syst_data.syst_owner_password_rules
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

COMMENT ON
    TABLE ms_syst_data.syst_owner_password_rules IS
$DOC$Defines the password credential complexity standard for a given Owner.  While
Owners may define stricter standards than the global password credential
complexity standard, looser standards than the global will not have any effect
and the global standard will be used instead.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_owner_password_rules.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_owner_password_rules.owner_id IS
$DOC$Defined the relationship with a specific Owner for whom the password rule the
specific rule is being defined.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_owner_password_rules.password_length IS
$DOC$An integer range of acceptable password lengths with the lower bound
representing the minimum length and the upper bound representing the maximum
password length.   Length is determined on a per character basis, not a per
byte basis.

A zero or negative value on either bound indicates that the bound check is
disabled.  Note that disabling a bound may still result in a bounds check using
the application defined default for the bound.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_owner_password_rules.max_age IS
$DOC$An interval indicating the maximum allowed age of a password.  Any password
older than this interval will typically result in the user being forced to
update their password prior to being allowed access to other functionality. The
specific user workflow will depend on the implementation details of application.

An interval of 0 time disables the check and passwords may be of any age.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_owner_password_rules.require_upper_case IS
$DOC$Establishes the minimum number of upper case characters that are required to be
present in the password.  Setting this value to 0 disables the requirement for
upper case characters.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_owner_password_rules.require_lower_case IS
$DOC$Establishes the minimum number of lower case characters that are required to be
present in the password.  Setting this value to 0 disables the requirement for
lower case characters.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_owner_password_rules.require_numbers IS
$DOC$Establishes the minimum number of numeric characters that are required to be
present in the password.  Setting this value to 0 disables the requirement for
numeric characters.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_owner_password_rules.require_symbols IS
$DOC$Establishes the minimum number of non-alphanumeric characters that are required
to be present in the password.  Setting this value to 0 disables the requirement
for non-alphanumeric characters.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_owner_password_rules.disallow_recently_used IS
$DOC$When passwords are changed, this value determines how many prior passwords
should be checked in order to prevent password re-use.  Setting this value to
zero or a negative number will disable the recently used password check.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_owner_password_rules.disallow_compromised IS
$DOC$When true new passwords submitted through the change password process will be
checked against a list of common passwords and passwords known to have been
compromised and disallow their use as password credentials in the system.

When false submitted passwords are not checked as being common or against known
compromised passwords; such passwords would therefore be usable in the system.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_owner_password_rules.require_mfa IS
$DOC$When true, an approved multi-factor authentication method must be used in
addition to the password credential.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_owner_password_rules.allowed_mfa_types IS
$DOC$A array of the approved multi-factor authentication methods.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_owner_password_rules.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_owner_password_rules.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_owner_password_rules.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_owner_password_rules.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_owner_password_rules.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_owner_password_rules.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_owner_password_rules.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;
