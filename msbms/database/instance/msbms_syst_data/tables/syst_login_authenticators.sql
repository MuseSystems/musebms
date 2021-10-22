-- Source File: syst_login_authenticators.sql
-- Location:    msbms/database/msbms_syst_data/tables/syst_login_authenticators.sql
-- Project:     musebms
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from thrid parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems
CREATE TABLE msbms_syst_data.syst_login_authenticators
(
     id                          uuid        DEFAULT uuid_generate_v1( ) NOT NULL
        CONSTRAINT syst_login_authenticators_pk PRIMARY KEY
    ,syst_person_login_id        uuid                                    NOT NULL
        CONSTRAINT syst_login_authenticators_syst_person_login_fk
        REFERENCES msbms_syst_data.syst_person_logins (id)
        ON DELETE CASCADE
    ,enum_authentication_type_id uuid                                    NOT NULL
        CONSTRAINT syst_login_authenticators_enum_authentication_type_fk
        REFERENCES msbms_syst_data.enum_authentication_types (id)
    ,authentication_data         text                                    NOT NULL
    ,invalidated                 boolean     DEFAULT false               NOT NULL
    ,last_login                  timestamptz DEFAULT '-infinity'         NOT NULL
    ,last_attempted_login        timestamptz DEFAULT '-infinity'         NOT NULL
    ,diag_timestamp_created      timestamptz DEFAULT now( )              NOT NULL
    ,diag_role_created           text                                    NOT NULL
    ,diag_timestamp_modified     timestamptz DEFAULT now( )              NOT NULL
    ,diag_wallclock_modified     timestamptz DEFAULT clock_timestamp( )  NOT NULL
    ,diag_role_modified          text                                    NOT NULL
    ,diag_row_version            bigint      DEFAULT 1                   NOT NULL
    ,diag_update_count           bigint      DEFAULT 0                   NOT NULL
);

ALTER TABLE msbms_syst_data.syst_login_authenticators OWNER TO msbms_owner;

REVOKE ALL ON TABLE msbms_syst_data.syst_login_authenticators FROM public;
GRANT ALL ON TABLE msbms_syst_data.syst_login_authenticators TO msbms_owner;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON msbms_syst_data.syst_login_authenticators
    FOR EACH ROW EXECUTE PROCEDURE msbms_syst_priv.trig_b_iu_set_diagnostic_columns();

COMMENT ON
    TABLE msbms_syst_data.syst_login_authenticators IS
$DOC$Provides the authenticators for syst_person_logins records.  This table may$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_login_authenticators.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_login_authenticators.syst_person_login_id IS
$DOC$References the login for which this record serves as an authenticator.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_login_authenticators.enum_authentication_type_id IS
$DOC$Indicates the authentication mechanism to use to validate the authenticator and
whether the authenticator is a primary or secondary authenticator.  A primary
authenticator may be something like a password ("what you know") and a secondary
authenticator may be along the lines of a TOTP authenticator ("what you have").$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_login_authenticators.authentication_data IS
$DOC$This is the authenticator itself.  In reality this is a compound field that
presumes both (presumably) hashed secret along with the salt.  The details of
this data structure will depend on the specific authentication type represented
by this record.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_login_authenticators.invalidated IS
$DOC$If the authenticator is invalidated, it means on next use it must be updated.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_login_authenticators.last_login IS
$DOC$The last time this specific authenticator was successfully used to access the
system.  Note that only this individual factor must be sucessfully authenticated
to update this field to the date/time of the success.  This differs from the
syst_person_logins field which requires a fully successful login to be recorded.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_login_authenticators.last_attempted_login IS
$DOC$The last time this authenticator was used in an authentication attempt without
regard to if the attempt was successful or not.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_login_authenticators.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_login_authenticators.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_login_authenticators.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_login_authenticators.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_login_authenticators.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_login_authenticators.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_login_authenticators.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;
