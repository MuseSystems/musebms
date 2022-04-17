-- File:        syst_person_logins.eex.sql
-- Location:    database\app_msbms_instance\mod_syst\msbms_syst_data\tables\syst_person_logins\syst_person_logins.eex.sql
-- Project:     Muse Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE TABLE msbms_syst_data.syst_person_logins
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v1( )
        CONSTRAINT syst_person_logins_pk PRIMARY KEY
    ,person_id
        uuid
        NOT NULL
        CONSTRAINT syst_person_logins_person_fk
            REFERENCES msbms_appl_data.mstr_persons (id) ON DELETE CASCADE
    ,owning_entity_id
        uuid
        NOT NULL
        CONSTRAINT syst_person_logins_owning_entity_fk
            REFERENCES msbms_appl_data.mstr_entities (id) ON DELETE CASCADE
    ,login_state_id
        uuid
        NOT NULL
        CONSTRAINT syst_person_logins_enum_login_state_fk
            REFERENCES msbms_syst_data.syst_enum_values (id)
    ,access_account_id
        uuid
        NOT NULL
    ,validity_start_end
        tstzrange
        NOT NULL DEFAULT tstzrange(now(), null, '[)')
    ,last_login
        timestamptz
        NOT NULL DEFAULT '-infinity'
    ,last_attempted_login
        timestamptz
        NOT NULL DEFAULT '-infinity'
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

ALTER TABLE msbms_syst_data.syst_person_logins OWNER TO <%= msbms_owner %>;

REVOKE ALL ON TABLE msbms_syst_data.syst_person_logins FROM public;
GRANT ALL ON TABLE msbms_syst_data.syst_person_logins TO <%= msbms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON msbms_syst_data.syst_person_logins
    FOR EACH ROW EXECUTE PROCEDURE msbms_syst_priv.trig_b_iu_set_diagnostic_columns();

CREATE CONSTRAINT TRIGGER a50_trig_a_i_login_states_enum_value_check
    AFTER INSERT ON msbms_syst_data.syst_person_logins
    FOR EACH ROW EXECUTE PROCEDURE
        msbms_syst_priv.trig_a_iu_enum_value_check('login_states', 'login_state_id');

CREATE CONSTRAINT TRIGGER a50_trig_a_u_login_states_enum_value_check
    AFTER UPDATE ON msbms_syst_data.syst_person_logins
    FOR EACH ROW WHEN ( old.login_state_id != new.login_state_id)
        EXECUTE PROCEDURE
            msbms_syst_priv.trig_a_iu_enum_value_check(
                'login_states', 'login_state_id');

COMMENT ON
    TABLE msbms_syst_data.syst_person_logins IS
$DOC$Provides the list of available login identities for people needing access to the
system for any reason.  Identity in this case isn't the person, but the means by
which a person identifies themselves to the system.  A login may be owned by the
entity to which the person record belongs, this is used in selling and
purchasing relationships since a customer or vendor controls their login
details, and also in inactive staffing relationships where on-going employee
portal access may be appropriate.  A login may be owned by the managed entity
such as in the case of an active staffing relationship; this must be true since
the employee login may have more stringent login requirements than is required
for selling and purchasing relationships, or secondary authentication may be
tied to company owned devices that cease to be available once the staffing
relationship terminates.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_person_logins.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_person_logins.person_id IS
$DOC$The person that this login will identify.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_person_logins.owning_entity_id IS
$DOC$The owning entity of this login.  See the table description for the broader
ownership concept.  This will point to the entity responsible for managing the
login.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_person_logins.login_state_id IS
$DOC$Establishes which life-cycle state the login record is in.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_person_logins.access_account_id IS
$DOC$A reference to the global database msbms_syst_data.syst_access_accounts table.
Authentication is handled centrally via the global database for all instance
owners, instances, and supported applications.  The reference in this column
indicates which of the global access account records is used for authentication
to this instance.  Authorization, including authorization to connect to the
instance is managed by the instance itself once the system authenticates the
user.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_person_logins.validity_start_end IS
$DOC$Indicates the starting and ending timestamps for which a given login may be
used to access the system, so long as the enum_login_state_id value also
represents a state which allows login attempts.  The allowed times include the
starting time and allow logins up to the ending time, but not including the
ending time itself.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_person_logins.last_login IS
$DOC$The last time the login was used and successfully authenticated.  This doesn't
mean that once authenticated that the user had permission to view data or
perform actions.  A successful login only indicates a successful authentication.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_person_logins.last_attempted_login IS
$DOC$The last time a login attempt was tried.  This value will updated be updated
without regard to the success or failure of the authentication.  An
authentication attempt will be considered as recordable here when both an
identity and an authenticator have both been provided to the system for
evaluation.  Secondary authenticator attempts are not necessary to count as an
attempted authentication; this means, for example, a good username and password
with no attempted answer to a required secondary authentication factor will
still count as an authentication attempt.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_person_logins.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_person_logins.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_person_logins.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_person_logins.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_person_logins.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_person_logins.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_person_logins.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;
