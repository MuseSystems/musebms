-- File:        mstr_persons.eex.sql
-- Location:    musebms/database/components/application/mscmp_brm_person/ms_appl_data/mstr_persons/mstr_persons.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

CREATE TABLE ms_appl_data.mstr_persons
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v7( )
        CONSTRAINT mstr_persons_pk PRIMARY KEY
    ,internal_name
        text
        NOT NULL
        CONSTRAINT mstr_persons_internal_name_udx UNIQUE
    ,display_name
        text
        CONSTRAINT mstr_persons_display_name_udx UNIQUE
    ,external_name
        text
        NOT NULL
    ,owning_entity_id
        uuid
        NOT NULL
        CONSTRAINT mstr_persons_entities_fk
            REFERENCES ms_appl_data.mstr_entities ( id )
    ,formatted_name
        jsonb
        NOT NULL DEFAULT '{}'::jsonb
    ,person_type_id
        uuid
        NOT NULL
        CONSTRAINT mstr_persons_person_types_fk
            REFERENCES ms_syst_data.syst_enum_items ( id )
    ,person_state_id
        uuid
        CONSTRAINT mstr_persons_person_states_fk
            REFERENCES ms_syst_data.syst_enum_items ( id )
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

ALTER TABLE ms_appl_data.mstr_persons OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_appl_data.mstr_persons FROM public;
GRANT ALL ON TABLE ms_appl_data.mstr_persons TO <%= ms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_appl_data.mstr_persons
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

CREATE CONSTRAINT TRIGGER a50_trig_a_i_person_types_enum_item_check
    AFTER INSERT ON ms_appl_data.mstr_persons
    FOR EACH ROW EXECUTE PROCEDURE
        ms_syst_priv.trig_a_iu_enum_item_check('person_types', 'person_type_id');

CREATE CONSTRAINT TRIGGER a50_trig_a_u_person_types_enum_item_check
    AFTER UPDATE ON ms_appl_data.mstr_persons
    FOR EACH ROW WHEN ( old.person_type_id != new.person_type_id)
        EXECUTE PROCEDURE
            ms_syst_priv.trig_a_iu_enum_item_check(
                'person_types', 'person_type_id');

CREATE CONSTRAINT TRIGGER a50_trig_a_i_person_states_enum_item_check
    AFTER INSERT ON ms_appl_data.mstr_persons
    FOR EACH ROW EXECUTE PROCEDURE
        ms_syst_priv.trig_a_iu_enum_item_check('person_states', 'person_state_id');

CREATE CONSTRAINT TRIGGER a50_trig_a_u_person_states_enum_item_check
    AFTER UPDATE ON ms_appl_data.mstr_persons
    FOR EACH ROW WHEN ( old.person_state_id != new.person_state_id)
        EXECUTE PROCEDURE
            ms_syst_priv.trig_a_iu_enum_item_check(
                'person_states', 'person_state_id');

DO
$DOCUMENTATION$
DECLARE
    -- Table
    var_comments_config ms_syst_priv.comments_config_table;

    -- Columns
    var_owning_entity_id  ms_syst_priv.comments_config_table_column;
    var_formatted_name    ms_syst_priv.comments_config_table_column;
    var_person_type_id    ms_syst_priv.comments_config_table_column;

BEGIN

    --
    -- Table Config
    --

    var_comments_config.table_schema := 'ms_appl_data';
    var_comments_config.table_name   := 'mstr_persons';

    var_comments_config.description :=
$DOC$A Person is someone who acts as an agent on behalf of an Entity. This may be a
real individual person in the world or indicate a function, such as “Customer
Support”, where the actual person contacted may vary and identifying a specific
individual is unimportant.$DOC$;

    --
    -- Column Configs
    --

    var_owning_entity_id.column_name := 'owning_entity_id';
    var_owning_entity_id.description :=
$DOC$Indicates which Managing Entity owns the Person record for the purposes of
default visibility and access.$DOC$;
    var_owning_entity_id.general_usage :=
$DOC$Any Person record owned by the Global Entity is by default visible and usable by
any Managed Entity.$DOC$;

    var_formatted_name.column_name := 'formatted_name';
    var_formatted_name.description :=
$DOC$Contains a jsonb object describing the naming fields, field layout, and the
actual values of the user's name.  Note that the format will normally have
originated from the `ms_appl_data.syst_name_formats` table, but reflects the
name formatting configuration at the time of capture.$DOC$;

    var_person_type_id.column_name := 'person_type_id';
    var_person_type_id.description :=
$DOC$The "kind" of Person being represented by the record.  Specifically if the
record represents an actual individual person or a function such as "clerk".$DOC$;

    var_person_state_id.column_name := 'person_state_id';
    var_person_state_id.description :=
$DOC$Indicates in which Person life-cycle state the record current sits.  This can
include designating the record as active or inactive.$DOC$;

    var_comments_config.columns :=
        ARRAY [
              var_owning_entity_id
            , var_formatted_name
            , var_person_type_id
            , var_person_state_id
            ]::ms_syst_priv.comments_config_table_column[];

    PERFORM ms_syst_priv.generate_comments_table( var_comments_config );

END;
$DOCUMENTATION$;
