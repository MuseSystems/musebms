-- File:        mstr_persons.eex.sql
-- Location:    musebms/database/app_msbms_instance/mod_brm/msbms_appl_data/mstr_persons/mstr_persons.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE TABLE msbms_appl_data.mstr_persons
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v1( )
        CONSTRAINT mstr_persons_pk PRIMARY KEY
    ,owning_entity_id
        uuid
        NOT NULL
        CONSTRAINT mstr_persons_entities_fk
            REFERENCES msbms_appl_data.mstr_entities (id)
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
    ,formatted_name
        jsonb
        NOT NULL DEFAULT '{}'::jsonb
    ,person_type_id
        uuid
        NOT NULL
        CONSTRAINT mstr_persons_person_types_fk
            REFERENCES msbms_syst_data.syst_enum_items (id)
    ,person_state_id
        uuid
        CONSTRAINT mstr_persons_person_states_fk
            REFERENCES msbms_syst_data.syst_enum_items (id)
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

ALTER TABLE msbms_appl_data.mstr_persons OWNER TO <%= msbms_owner %>;

REVOKE ALL ON TABLE msbms_appl_data.mstr_persons FROM public;
GRANT ALL ON TABLE msbms_appl_data.mstr_persons TO <%= msbms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON msbms_appl_data.mstr_persons
    FOR EACH ROW EXECUTE PROCEDURE msbms_syst_priv.trig_b_iu_set_diagnostic_columns();

CREATE CONSTRAINT TRIGGER a50_trig_a_i_person_types_enum_item_check
    AFTER INSERT ON msbms_appl_data.mstr_persons
    FOR EACH ROW EXECUTE PROCEDURE
        msbms_syst_priv.trig_a_iu_enum_item_check('person_types', 'person_type_id');

CREATE CONSTRAINT TRIGGER a50_trig_a_u_person_types_enum_item_check
    AFTER UPDATE ON msbms_appl_data.mstr_persons
    FOR EACH ROW WHEN ( old.person_type_id != new.person_type_id)
        EXECUTE PROCEDURE
            msbms_syst_priv.trig_a_iu_enum_item_check(
                'person_types', 'person_type_id');

CREATE CONSTRAINT TRIGGER a50_trig_a_i_person_states_enum_item_check
    AFTER INSERT ON msbms_appl_data.mstr_persons
    FOR EACH ROW EXECUTE PROCEDURE
        msbms_syst_priv.trig_a_iu_enum_item_check('person_states', 'person_state_id');

CREATE CONSTRAINT TRIGGER a50_trig_a_u_person_states_enum_item_check
    AFTER UPDATE ON msbms_appl_data.mstr_persons
    FOR EACH ROW WHEN ( old.person_state_id != new.person_state_id)
        EXECUTE PROCEDURE
            msbms_syst_priv.trig_a_iu_enum_item_check(
                'person_states', 'person_state_id');

COMMENT ON
    TABLE msbms_appl_data.mstr_persons IS
$DOC$Represents real people in the world.  Ideally, there is one record in this table
for each person the various entities interact with.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.mstr_persons.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN   msbms_appl_data.mstr_persons.owning_entity_id IS
$DOC$Indicates which managing entity owns the person record for the purposes of
default visibility and access.  Any person record owned by the global entity is
by default visible and usable by any managed entity.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.mstr_persons.internal_name IS
$DOC$A candidate key useful for programmatic references to individual records.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.mstr_persons.display_name IS
$DOC$A friendly name and candidate key for the record, suitable for use in user
interfaces.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.mstr_persons.external_name IS
$DOC$A friendly name for externally facing uses such as in communications with the
person.  Note that this is not a key value and has no UNIQUE enforcement.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.mstr_persons.formatted_name IS
$DOC$Contains a jsonb object describing the naming fields, field layout, and the
actual values of the user's name.  Note that the format will normally have
originated from the msbms_appl_data.syst_name_formats table, but reflects the
name formatting configuration at the time of capture.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.mstr_persons.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.mstr_persons.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.mstr_persons.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.mstr_persons.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.mstr_persons.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.mstr_persons.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.mstr_persons.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;
