-- Source File: syst_person_logins.eex.sql
-- Location:    msbms/database/instance/msbms_syst_data/tables/syst_person_logins.eex.sql
-- Project:     musebms
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
     id                             uuid        DEFAULT uuid_generate_v1( )          NOT NULL
        CONSTRAINT syst_person_logins_pk PRIMARY KEY
    ,person_id                      uuid                                             NOT NULL
        CONSTRAINT syst_person_logins_person_fk
        REFERENCES msbms_appl_data.mstr_persons (id)
        ON DELETE CASCADE
    ,owning_entity_id               uuid                                             NOT NULL
        CONSTRAINT syst_person_logins_owning_entity_fk
        REFERENCES msbms_appl_data.mstr_entities (id)
        ON DELETE CASCADE
    ,enum_login_state_id            uuid                                             NOT NULL
        CONSTRAINT syst_person_logins_enum_login_state_fk
        REFERENCES msbms_syst_data.enum_login_states (id)
    ,validity_start_end             tstzrange   DEFAULT tstzrange(now(), null, '[)') NOT NULL
    ,identity                       text                                             NOT NULL
        CONSTRAINT syst_person_logins_identity_udx UNIQUE
    ,proxy_for_syst_person_login_id uuid
        CONSTRAINT syst_person_logins_proxy_for_syst_person_login_fk
        REFERENCES msbms_syst_data.syst_person_logins (id)
        ON DELETE CASCADE
    ,last_login                     timestamptz DEFAULT '-infinity'                  NOT NULL
    ,last_attempted_login           timestamptz DEFAULT '-infinity'                  NOT NULL
    ,diag_timestamp_created         timestamptz DEFAULT now( )                       NOT NULL
    ,diag_role_created              text                                             NOT NULL
    ,diag_timestamp_modified        timestamptz DEFAULT now( )                       NOT NULL
    ,diag_wallclock_modified        timestamptz DEFAULT clock_timestamp( )           NOT NULL
    ,diag_role_modified             text                                             NOT NULL
    ,diag_row_version               bigint      DEFAULT 1                            NOT NULL
    ,diag_update_count              bigint      DEFAULT 0                            NOT NULL
);

ALTER TABLE msbms_syst_data.syst_person_logins OWNER TO <%= msbms_owner %>;

REVOKE ALL ON TABLE msbms_syst_data.syst_person_logins FROM public;
GRANT ALL ON TABLE msbms_syst_data.syst_person_logins TO <%= msbms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON msbms_syst_data.syst_person_logins
    FOR EACH ROW EXECUTE PROCEDURE msbms_syst_priv.trig_b_iu_set_diagnostic_columns();

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
    COLUMN msbms_syst_data.syst_person_logins.enum_login_state_id IS
$DOC$Establishes which life-cycle state the login record is in.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_person_logins.validity_start_end IS
$DOC$Indicates the starting and ending timestamps for which a given login may be
used to access the system, so long as the enum_login_state_id value also
represents a state which allows login attempts.  The allowed times include the
starting time and allow logins up to the ending time, but not including the
ending time itself.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_person_logins.identity IS
$DOC$Defines the identifier that is presented to the system by a user or system
login.  Traditionally this would be the user name.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_person_logins.proxy_for_syst_person_login_id IS
$DOC$For cases such as self-serve password resets, it may be necessary to create a
temporary authentication path with an ad hoc identity and, ultimately, an ad hoc
authenticator.  If the syst_person_logins record in question is such an ad hoc
login, this field will reference the login record which is being reset or for
which the ad hoc login record is serving as a proxy.$DOC$;

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
