-- File:        mstr_contacts.eex.sql
-- Location:    musebms/database/components/application/mscmp_brm_contact/ms_appl_data/mstr_contacts/mstr_contacts.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

CREATE TABLE ms_appl_data.mstr_contacts
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v7( )
        CONSTRAINT mstr_contacts_pk PRIMARY KEY
    ,internal_name
        text
        NOT NULL
        CONSTRAINT mstr_contacts_internal_name_udx UNIQUE
    ,display_name
        text
        NOT NULL
        CONSTRAINT mstr_contacts_display_name_udx UNIQUE
    ,owning_entity_id
        uuid
        NOT NULL
        CONSTRAINT mstr_contacts_owning_entity_fk
            REFERENCES ms_appl_data.mstr_entities (id) ON DELETE CASCADE
    ,external_name
        text
        NOT NULL
    ,contact_type_id
        uuid
        NOT NULL
        CONSTRAINT mstr_contacts_contact_types_fk
            REFERENCES ms_syst_data.syst_enum_items (id)
    ,contact_state_id
        uuid
        NOT NULL
        CONSTRAINT mstr_contacts_contact_states_fk
            REFERENCES ms_syst_data.syst_enum_items (id)
    ,contact_data
        jsonb
        NOT NULL DEFAULT '{}'::jsonb
    ,contact_notes
        text
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

ALTER TABLE ms_appl_data.mstr_contacts OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_appl_data.mstr_contacts FROM public;
GRANT ALL ON TABLE ms_appl_data.mstr_contacts TO <%= ms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_appl_data.mstr_contacts
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

CREATE CONSTRAINT TRIGGER a50_trig_a_i_contact_types_enum_item_check
    AFTER INSERT ON ms_appl_data.mstr_contacts
    FOR EACH ROW EXECUTE PROCEDURE
        ms_syst_priv.trig_a_iu_enum_item_check('contact_types', 'contact_type_id');

CREATE CONSTRAINT TRIGGER a50_trig_a_u_contact_types_enum_item_check
    AFTER UPDATE ON ms_appl_data.mstr_contacts
    FOR EACH ROW WHEN ( old.contact_type_id != new.contact_type_id)
        EXECUTE PROCEDURE
            ms_syst_priv.trig_a_iu_enum_item_check(
                'contact_types', 'contact_type_id');

CREATE CONSTRAINT TRIGGER a50_trig_a_i_contact_states_enum_item_check
    AFTER INSERT ON ms_appl_data.mstr_contacts
    FOR EACH ROW EXECUTE PROCEDURE
        ms_syst_priv.trig_a_iu_enum_item_check('contact_states', 'contact_state_id');

CREATE CONSTRAINT TRIGGER a50_trig_a_u_contact_states_enum_item_check
    AFTER UPDATE ON ms_appl_data.mstr_contacts
    FOR EACH ROW WHEN ( old.contact_state_id != new.contact_state_id)
        EXECUTE PROCEDURE
            ms_syst_priv.trig_a_iu_enum_item_check(
                'contact_states', 'contact_state_id');

DO
$DOCUMENTATION$
DECLARE
    -- Table
    var_comments_config ms_syst_priv.comments_config_table;

    -- Columns
    var_owning_entity_id ms_syst_priv.comments_config_table_column;
    var_contact_type_id  ms_syst_priv.comments_config_table_column;
    var_contact_state_id ms_syst_priv.comments_config_table_column;
    var_contact_data     ms_syst_priv.comments_config_table_column;
    var_contact_notes    ms_syst_priv.comments_config_table_column;

BEGIN

    --
    -- Table Config
    --

    var_comments_config.table_schema := 'ms_appl_data';
    var_comments_config.table_name   := 'mstr_contacts';

    var_comments_config.description :=
$DOC$Represents a single method of contact for a person, entity, place, or other
contextually relevant association.$DOC$;

    var_comments_config.general_usage :=
$DOC$Note that there is a weakness in this part of the schema design in that contact
information doesn't make sense outside of assignment to a person, facility, or
entity, but such assignment is indirect through role assignments.  This means it
is conceivable that records in this table could become orphaned.  At this stage,
however, it doesn't seem worth it to denormalize the data to record the direct
association.$DOC$;

    --
    -- Column Configs
    --

    var_owning_entity_id.column_name := 'owning_entity_id';
    var_owning_entity_id.description :=
$DOC$Indicates the entity which is the owner or "controlling".$DOC$;
    var_owning_entity_id.general_usage :=
$DOC$There are a couple of ways this can be used.  The first case is illustrated by
the example of a managed entity and an staffing entity that is an individual.
The owning entity in this case will be the managed entity for contacts such as
the details of the person's office address, phone, and email addresses that is
used in carrying out their duties as staff.  The second case is where the entity
is in a selling, purchasing, or banking relationship with the managed entity.
In this case the owning entity is the entity with which the managed entity has a
relationship since a customer, vendor, or bank determines their own contact
details.$DOC$;

    var_contact_state_id.column_name := 'contact_state_id';
    var_contact_state_id.description :=
$DOC$Establishes the current life-cycle state of the contact record, such as
whether the record is active or not.$DOC$;

    var_contact_type_id.column_name := 'contact_type_id';
    var_contact_type_id.description :=
$DOC$Indicates the type of the contact record.  Contact records store inforamtion of
varying types such as phone numbers, physical addresses, email addresses, etc.
The value in this column establishes which kind of contact data is being stored
and indicates the data processing rules to apply.$DOC$;

    var_contact_data.column_name := 'contact_data';
    var_contact_data.description :=
$DOC$Contains the actual contact data being stored by the record as well as
associated metadata such as specialized data fields, mapping of the specialized
fields to standard representation for data maintenance, display, printing, and
integration.$DOC$;


    var_comments_config.columns :=
        ARRAY [
              var_owning_entity_id
            , var_contact_type_id
            , var_contact_state_id
            , var_contact_data
            , var_contact_notes
            ]::ms_syst_priv.comments_config_table_column[];

    PERFORM ms_syst_priv.generate_comments_table( var_comments_config );

END;
$DOCUMENTATION$;
