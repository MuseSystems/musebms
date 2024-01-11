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
        NOT NULL DEFAULT uuid_generate_v7( )
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

DO
$DOCUMENTATION$
DECLARE
    -- Table
    var_comments_config ms_syst_priv.comments_config_table;

    -- Columns
    var_owner_id               ms_syst_priv.comments_config_table_column;
    var_password_length        ms_syst_priv.comments_config_table_column;
    var_max_age                ms_syst_priv.comments_config_table_column;
    var_require_upper_case     ms_syst_priv.comments_config_table_column;
    var_require_lower_case     ms_syst_priv.comments_config_table_column;
    var_require_numbers        ms_syst_priv.comments_config_table_column;
    var_require_symbols        ms_syst_priv.comments_config_table_column;
    var_disallow_recently_used ms_syst_priv.comments_config_table_column;
    var_disallow_compromised   ms_syst_priv.comments_config_table_column;
    var_require_mfa            ms_syst_priv.comments_config_table_column;
    var_allowed_mfa_types      ms_syst_priv.comments_config_table_column;

BEGIN

    --
    -- Table Config
    --

    var_comments_config.table_schema := 'ms_syst_data';
    var_comments_config.table_name   := 'syst_owner_password_rules';

    var_comments_config.description :=
$DOC$Defines the password credential complexity standard for a given Owner.  While
Owners may define stricter standards than the global password credential
complexity standard, looser standards than the global will not have any effect
and the global standard will be used instead.$DOC$;

    --
    -- Column Configs
    --

    var_owner_id.column_name := 'owner_id';
    var_owner_id.description :=
$DOC$Defines the relationship with the specific Owner for whom the password rule is
being defined.$DOC$;

    var_password_length.column_name := 'password_length';
    var_password_length.description :=
$DOC$An integer range of acceptable password lengths with the lower bound
representing the minimum length and the upper bound representing the maximum
password length.$DOC$;
        var_password_length.general_usage :=
$DOC$A zero or negative value on either bound indicates that the bound check is
disabled.  Note that disabling a bound may still result in a bounds check using
the application defined default for the bound.

Length is determined on a per character basis, not a per byte basis.$DOC$;

    var_max_age.column_name := 'max_age';
    var_max_age.description :=
$DOC$An interval indicating the maximum allowed age of a password.  Any password
older than this interval will typically result in the user being forced to
update their password prior to being allowed access to other functionality. The
specific user workflow will depend on the implementation details of application.$DOC$;
    var_max_age.general_usage :=
$DOC$An interval of 0 time disables the check and passwords may be of any age.$DOC$;

    var_require_upper_case.column_name := 'require_upper_case';
    var_require_upper_case.description :=
$DOC$Establishes the minimum number of upper case characters that are required to be
present in the password.$DOC$;
    var_require_upper_case.general_usage :=
$DOC$Setting this value to 0 disables the requirement for upper case characters.$DOC$;

    var_require_lower_case.column_name := 'require_lower_case';
    var_require_lower_case.description :=
$DOC$Establishes the minimum number of lower case characters that are required to be
present in the password.$DOC$;
    var_require_lower_case.description :=
$DOC$Setting this value to 0 disables the requirement for lower case characters.$DOC$;

    var_require_numbers.column_name := 'require_numbers';
    var_require_numbers.description :=
$DOC$Establishes the minimum number of numeric characters that are required to be
present in the password.$DOC$;
    var_require_numbers.general_usage :=
$DOC$Setting this value to 0 disables the requirement for numeric characters.$DOC$;

    var_require_symbols.column_name := 'require_symbols';
    var_require_symbols.description :=
$DOC$Establishes the minimum number of non-alphanumeric characters that are required
to be present in the password.$DOC$;
    var_require_symbols.general_usage :=
$DOC$Setting this value to 0 disables the requirement for non-alphanumeric
characters.$DOC$;

    var_disallow_recently_used.column_name := 'disallow_recently_used';
    var_disallow_recently_used.description :=
$DOC$When passwords are changed, this value determines how many prior passwords
should be checked in order to prevent password re-use.$DOC$;
    var_disallow_recently_used.general_usage :=
$DOC$Setting this value to zero or a negative number will disable the recently used
password check.$DOC$;

    var_disallow_compromised.column_name := 'disallow_compromised';
    var_disallow_compromised.description :=
$DOC$When true new passwords submitted through the change password process will be
checked against a list of common passwords and passwords known to have been
compromised and disallow their use as password credentials in the system.$DOC$;
        var_disallow_compromised.general_usage :=
$DOC$When false submitted passwords are not checked as being common or against known
compromised passwords; such passwords would therefore be usable in the system.$DOC$;

    var_require_mfa.column_name := 'require_mfa';
    var_require_mfa.description :=
$DOC$When true, an approved multi-factor authentication method must be used in
addition to the password credential.$DOC$;

    var_allowed_mfa_types.column_name := 'allowed_mfa_types';
    var_allowed_mfa_types.description :=
$DOC$A array of the approved multi-factor authentication methods.$DOC$;

    var_comments_config.columns :=
        ARRAY [
              var_owner_id
            , var_password_length
            , var_max_age
            , var_require_upper_case
            , var_require_lower_case
            , var_require_numbers
            , var_require_symbols
            , var_disallow_recently_used
            , var_disallow_compromised
            , var_require_mfa
            , var_allowed_mfa_types
            ]::ms_syst_priv.comments_config_table_column[];

    PERFORM ms_syst_priv.generate_comments_table( var_comments_config );

END;
$DOCUMENTATION$;
