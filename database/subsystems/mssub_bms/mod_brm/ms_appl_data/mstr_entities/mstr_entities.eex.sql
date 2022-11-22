-- File:        mstr_entities.eex.sql
-- Location:    musebms/database/application/msbms/mod_brm/ms_appl_data/mstr_entities/mstr_entities.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE TABLE ms_appl_data.mstr_entities
(
     id
         uuid
         NOT NULL DEFAULT uuid_generate_v1( )
        CONSTRAINT mstr_entities_pk PRIMARY KEY
    ,owning_entity_id
        uuid
        NOT NULL
        CONSTRAINT mstr_entities_entities_fk
            REFERENCES ms_appl_data.mstr_entities (id)
    ,internal_name
        text
        NOT NULL
        CONSTRAINT mstr_entities_internal_name_udx UNIQUE
    ,display_name
        text
        NOT NULL
        CONSTRAINT mstr_entities_display_name_udx UNIQUE
    ,external_name
        text
        NOT NULL
    ,entity_type_id
        uuid
        NOT NULL
        CONSTRAINT mstr_entities_entity_types_fk
            REFERENCES ms_syst_data.syst_enum_items (id)
    ,entity_state_id
        uuid
        NOT NULL
        CONSTRAINT mstr_entities_entity_states_fk
            REFERENCES ms_syst_data.syst_enum_items (id)
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

ALTER TABLE ms_appl_data.mstr_entities OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_appl_data.mstr_entities FROM public;
GRANT ALL ON TABLE ms_appl_data.mstr_entities TO <%= ms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_appl_data.mstr_entities
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

CREATE CONSTRAINT TRIGGER a50_trig_a_i_entity_types_enum_item_check
    AFTER INSERT ON ms_appl_data.mstr_entities
    FOR EACH ROW EXECUTE PROCEDURE
        ms_syst_priv.trig_a_iu_enum_item_check('entity_types', 'entity_type_id');

CREATE CONSTRAINT TRIGGER a50_trig_a_u_entity_types_enum_item_check
    AFTER UPDATE ON ms_appl_data.mstr_entities
    FOR EACH ROW WHEN ( old.entity_type_id != new.entity_type_id)
        EXECUTE PROCEDURE
            ms_syst_priv.trig_a_iu_enum_item_check(
                'entity_types', 'entity_type_id');

CREATE CONSTRAINT TRIGGER a50_trig_a_i_entity_states_enum_item_check
    AFTER INSERT ON ms_appl_data.mstr_entities
    FOR EACH ROW EXECUTE PROCEDURE
        ms_syst_priv.trig_a_iu_enum_item_check('entity_states', 'entity_state_id');

CREATE CONSTRAINT TRIGGER a50_trig_a_u_entity_states_enum_item_check
    AFTER UPDATE ON ms_appl_data.mstr_entities
    FOR EACH ROW WHEN ( old.entity_state_id != new.entity_state_id)
        EXECUTE PROCEDURE
            ms_syst_priv.trig_a_iu_enum_item_check(
                'entity_states', 'entity_state_id');

COMMENT ON
    TABLE ms_appl_data.mstr_entities IS
$DOC$Master list of legal entities with whom the business interacts.  All legal
entities are represented by this table, including the business using this
application itself.  The information stored in this record represents general
information about the entity that is broadly applicable in all contexts which
might use the entity.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entities.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entities.owning_entity_id IS
$DOC$Indicates which managing entity is the owning entity for purposes of default
visibility and usage limitations.  This limitation primarily is evident in
searches and lists.  Explicit assignment of rights to entities, persons,
facilities, etc. that are not the owning entity is still possible and those
rights will prevail over the default access rules for non-owning entities.

There is a special case of owning entity where an entity is self owning.  There
may only be a single entity that is self owning and that, by definition,
establishes that entity as the 'global entity'.  The global entity has global
administrative rights as well as allows access to those persons, facilities, and
entities that it owns effectively making them global to all other managed
entities.  The global entity may be an actual business entity which essentially
owns the MSBMS instance or it may a purely administrative construct for managing
the system.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entities.internal_name IS
$DOC$A candidate key useful for programmatic references to individual records.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entities.display_name IS
$DOC$A friendly name and candidate key for the record, suitable for use in user
interfaces.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entities.external_name IS
$DOC$A friendly name for externally facing uses such as in communications with the
entity.  Note that this is not a key value and has no UNIQUE enforcement.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entities.entity_type_id IS
$DOC$Defines the kind of entity that is being represented by the record and by
extension the kinds of uses in which the entity may be used.  Application
functionality is determined in part by the configuration of the selected type.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entities.entity_state_id IS
$DOC$Establishes current state of the entity in the established lifecycle of
entity records.  Certain application features and behaviors will depend on
the configuration of the state value selected for a entity record.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entities.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entities.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entities.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entities.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entities.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entities.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entities.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;
