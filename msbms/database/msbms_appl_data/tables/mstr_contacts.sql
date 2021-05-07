-- File:        mstr_contacts.sql
-- Location:    msbms/database/msbms_appl_data/tables/mstr_contacts.sql
-- Project:     Muse Systems Business Management System
--
-- Licensed to Lima Buttgereit Holdings LLC (d/b/a Muse Systems) under one or
-- more agreements.  Muse Systems licenses this file to you under the terms and
-- conditions of your Muse Systems Master Services Agreement or governing
-- Statement of Work.
--
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems
CREATE TABLE msbms_appl_data.mstr_contacts
(
     id                      uuid        DEFAULT uuid_generate_v1( ) NOT NULL
        CONSTRAINT mstr_contacts_pk PRIMARY KEY
    ,internal_name           text                                    NOT NULL
        CONSTRAINT mstr_contacts_internal_name_udx UNIQUE
    ,display_name            text                                    NOT NULL
        CONSTRAINT mstr_contacts_display_name_udx UNIQUE
    ,external_name           text                                    NOT NULL
    ,contact_type_id         uuid                                    NOT NULL
        CONSTRAINT mstr_contacts_contact_types_fk
        REFERENCES msbms_appl_data.enum_contact_types (id)
    ,contact_state_id        uuid                                    NOT NULL
        CONSTRAINT mstr_contacts_contact_states_fk
        REFERENCES msbms_appl_data.enum_contact_states (id)
    ,diag_timestamp_created  timestamptz DEFAULT now( )              NOT NULL
    ,diag_role_created       text                                    NOT NULL
    ,diag_timestamp_modified timestamptz DEFAULT now( )              NOT NULL
    ,diag_wallclock_modified timestamptz DEFAULT clock_timestamp( )  NOT NULL
    ,diag_role_modified      text                                    NOT NULL
    ,diag_row_version        bigint      DEFAULT 1                   NOT NULL
    ,diag_update_count       bigint      DEFAULT 0                   NOT NULL
);

ALTER TABLE msbms_appl_data.mstr_contacts OWNER TO msbms_owner;

REVOKE ALL ON TABLE msbms_appl_data.mstr_contacts FROM public;
GRANT ALL ON TABLE msbms_appl_data.mstr_contacts TO msbms_owner;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON msbms_appl_data.mstr_contacts
    FOR EACH ROW EXECUTE PROCEDURE msbms_syst_priv.trig_b_iu_set_diagnostic_columns();

COMMENT ON
    TABLE msbms_appl_data.mstr_contacts IS
$DOC$Represents a single method of contact for a person, entity, facility, or other
contextually relevant association.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.mstr_contacts.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.mstr_contacts.internal_name IS
$DOC$ A candidate key useful for programmatic references to individual records.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.mstr_contacts.display_name IS
$DOC$A friendly name and candidate key for the record, suitable for use in user
interactions$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.mstr_contacts.external_name IS
$DOC$A non-unique/non-key value used to display to users and external parties where
uniqueness is less of a concern than specific end user presentation.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.mstr_contacts.contact_type_id IS
$DOC$$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.mstr_contacts.contact_state_id IS
$DOC$$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.mstr_contacts.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.mstr_contacts.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.mstr_contacts.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.mstr_contacts.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.mstr_contacts.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.mstr_contacts.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.mstr_contacts.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;
