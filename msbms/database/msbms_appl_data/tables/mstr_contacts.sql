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
    ,owning_entity_id        uuid                                    NOT NULL
        CONSTRAINT mstr_contacts_owning_entity_fk
        REFERENCES msbms_appl_data.mstr_entities (id)
        ON DELETE CASCADE
    ,external_name           text                                    NOT NULL
    ,contact_type_id         uuid                                    NOT NULL
        CONSTRAINT mstr_contacts_contact_types_fk
        REFERENCES msbms_appl_data.enum_contact_types (id)
    ,contact_state_id        uuid                                    NOT NULL
        CONSTRAINT mstr_contacts_contact_states_fk
        REFERENCES msbms_appl_data.enum_contact_states (id)
    ,contact_data            jsonb       DEFAULT '{}'::jsonb         NOT NULL
    ,contact_notes           text
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
$DOC$Represents a single method of contact for a person, entity, place, or other
contextually relevant association.

Note that there is a weakness in this part of the schema design in that contact
information doesn't make sense outside of assignment to a person, facility, or
entity, but such assignment is indirect through role assignments.  This means it
is conceivable that records in this table could become orphaned.  At this stage,
however, it doesn't seem worth it to denormalize the data to record the direct
association.$DOC$;

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
    COLUMN msbms_appl_data.mstr_contacts.owning_entity_id IS
$DOC$Indicates the entity which is the owner or "controlling".   There are a couple
of ways this can be used.  The first case is illustrated by the example of a
managed entity and an staffing entity that is an individual.  The owning entity
in this case will be the managed entity for contacts such as the details of the
person's office address, phone, and email addresses that is used in carrying out
their duties as staff.  The second case is where the entity is in a selling,
purchasing, or banking relationship with the managed entity.  In this case the
owning entity is the entity with which the managed entity has a relationship
since a customer, vendor, or bank determines their own contact details.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.mstr_contacts.external_name IS
$DOC$A non-unique/non-key value used to display to users and external parties where
uniqueness is less of a concern than specific end user presentation.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.mstr_contacts.contact_state_id IS
$DOC$Establishes the current life-cycle state of the contact record, such as
whether the record is active or not.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.mstr_contacts.contact_type_id IS
$DOC$Indicates the type of the contact record.  Contact records store inforamtion of
varying types such as phone numbers, physical addresses, email addresses, etc.
The value in this column establishes which kind of contact data is being stored
and indicates the data processing rules to apply.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.mstr_contacts.contact_data IS
$DOC$Contains the actual contact data being stored by the record as well as
associated metadata such as specialized data fields, mapping of the specialized
fields to standard representation for data maintenance, display, printing, and
integration.$DOC$;

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
