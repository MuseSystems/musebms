-- File:        enum_access_account_states.eex.sql
-- Location:    database\global\msbms_syst_data\tables\enum_access_account_states.eex.sql
-- Project:     Muse Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems
CREATE TABLE msbms_syst_data.enum_access_account_states
(
     id                      uuid        DEFAULT uuid_generate_v1( ) NOT NULL 
        CONSTRAINT enum_access_account_states_pk PRIMARY KEY
    ,internal_name           text                                    NOT NULL 
        CONSTRAINT enum_access_account_states_internal_name_udx UNIQUE
    ,display_name            text                                    NOT NULL 
        CONSTRAINT enum_access_account_states_display_name_udx UNIQUE
    ,description             text                                    NOT NULL
    ,functional_type         text                                    NOT NULL
        CONSTRAINT enum_access_account_states_functional_type_chk
        CHECK (functional_type in (  'pending'
                                    ,'active'
                                    ,'suspended'
                                    ,'inactive'
                                    ,'purge_eligible'))
    ,options                 jsonb       DEFAULT '{}'::jsonb         NOT NULL
    ,user_options            jsonb       DEFAULT '{}'::jsonb         NOT NULL
    ,diag_timestamp_created  timestamptz DEFAULT now( )              NOT NULL
    ,diag_role_created       text                                    NOT NULL
    ,diag_timestamp_modified timestamptz DEFAULT now( )              NOT NULL
    ,diag_wallclock_modified timestamptz DEFAULT clock_timestamp( )  NOT NULL
    ,diag_role_modified      text                                    NOT NULL
    ,diag_row_version        bigint      DEFAULT 1                   NOT NULL
    ,diag_update_count       bigint      DEFAULT 0                   NOT NULL
);

ALTER TABLE msbms_syst_data.enum_access_account_states OWNER TO <%= msbms_owner %>;

REVOKE ALL ON TABLE msbms_syst_data.enum_access_account_states FROM public;
GRANT ALL ON TABLE msbms_syst_data.enum_access_account_states TO <%= msbms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON msbms_syst_data.enum_access_account_states
    FOR EACH ROW EXECUTE PROCEDURE msbms_syst_priv.trig_b_iu_set_diagnostic_columns();

COMMENT ON
    TABLE msbms_syst_data.enum_access_account_states IS
$DOC$Enumerates the available states which describe the life-cycle of the access account records.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.enum_access_account_states.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.enum_access_account_states.internal_name IS
$DOC$A candidate key useful for programmatic references to individual records.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.enum_access_account_states.display_name IS
$DOC$A friendly name and candidate key for the record, suitable for use in user
access_accounts.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.enum_access_account_states.description IS
$DOC$A text describing the meaning and use of the specific record that may be
visible to users of the record.$DOC$;

COMMENT ON
    COLUMN  msbms_syst_data.enum_access_account_states.functional_type IS
$DOC$Establishes what system recognized type the state represents.  Functional types
may determine how the system behaves in certain circumstances.  Functional types
recognized by this application:

    * pending:        Indicates that the access account is pending validation.
                      When pending validation, new access accounts have been
                      created, but verification that contact information such as
                      the account holder's email address is valid, has not been
                      completed.  When in pending status, the account cannot be
                      used for regular authentication until verification has
                      been completed.

    * active:         The access account is active and is considered active.

    * suspended:      The access account is currently suspended and not usable
                      for regular system access.  Some basic maintenance
                      functions may still be available to suspended access
                      accounts as appropriate.

    * inactive:       The access account is not available for any use and would
                      not typically be visible to users for any purpose.

    * purge_eligible: The access account is not available for any use, not
                      visible to users and subject to be completely deleted from
                      the system at any point in time.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.enum_access_account_states.options IS
$DOC$A JSON representation of various behaviorial options that the application may 
make when the enum is assigned to the record it is qualifying.  Options may 
include flags, rules to test, and other such arbitrary behaviors as required by 
the specific record to which the enum is assigned.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.enum_access_account_states.user_options IS
$DOC$Allows for user defined options related to the type similar to the way the
options field is envisioned.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.enum_access_account_states.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record 
started.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.enum_access_account_states.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.enum_access_account_states.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record 
started.  This field will be the same as diag_timestamp_created for inserted 
records.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.enum_access_account_states.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the 
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.enum_access_account_states.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.enum_access_account_states.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual 
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version 
is not updated, nor are any updates made to the other diag_* columns other than 
diag_update_count.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.enum_access_account_states.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if 
the update actually changed any data.  In this way needless or redundant record 
updates can be found.  This row starts at 0 and therefore may be the same as the 
diag_row_version - 1.$DOC$;
