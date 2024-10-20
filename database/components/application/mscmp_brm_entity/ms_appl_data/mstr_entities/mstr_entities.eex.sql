-- File:        mstr_entities.eex.sql
-- Location:    musebms/database/components/application/mscmp_brm_entity/ms_appl_data/mstr_entities/mstr_entities.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

CREATE TABLE ms_appl_data.mstr_entities
(
     id
         uuid
         NOT NULL DEFAULT uuid_generate_v7( )
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

DO
$DOCUMENTATION$
DECLARE
    -- Table
    var_comments_config ms_syst_priv.comments_config_table;

    -- Columns
    var_owning_entity_id ms_syst_priv.comments_config_table_column;
    var_entity_type_id   ms_syst_priv.comments_config_table_column;
    var_entity_state_id  ms_syst_priv.comments_config_table_column;

BEGIN

    --
    -- Table Config
    --

    var_comments_config.table_schema := 'ms_appl_data';
    var_comments_config.table_name   := 'mstr_entities';

    var_comments_config.description :=
$DOC$Master list of legal entities with whom the business interacts.

All legal entities are represented by this table, including the business using
this application itself.$DOC$;

    var_comments_config.general_usage :=
$DOC$The information stored in this record represents general information about the
entity that is broadly applicable in all contexts which might use the entity.$DOC$;

    --
    -- Column Configs
    --

    var_owning_entity_id.column_name := 'owning_entity_id';
    var_owning_entity_id.description :=
$DOC$Indicates which managing entity is the owning entity for purposes of default
visibility and usage limitations.$DOC$;
    var_owning_entity_id.general_usage :=
$DOC$The limited cases are primarily evident in searches and lists.

Explicit assignment of rights to entities, persons, facilities, etc. that are
not the owning entity is still possible and those rights will prevail over the
default access rules for non-owning entities.

There is a special case of owning entity where an entity is self owning.  There
may only be a single entity that is self owning and that, by definition,
establishes that entity as the 'global entity'.  The global entity has global
administrative rights as well as allows access to those persons, facilities, and
entities that it owns effectively making them global to all other managed
entities.  The global entity may be an actual business entity which essentially
owns the MSBMS Instance or it may a purely administrative construct for managing
the system.$DOC$;


    var_entity_type_id.column_name := 'entity_type_id';
    var_entity_type_id.description :=
$DOC$Defines the kind of entity that is being represented by the record and by
extension the kinds of uses in which the entity may be used.$DOC$;
    var_entity_type_id.general_usage :=
$DOC$Application functionality is determined in part by the configuration of the
selected type.$DOC$;

    var_entity_state_id.column_name := 'entity_state_id';
    var_entity_state_id.description :=
$DOC$Establishes current state of the entity in the established lifecycle of
entity records.$DOC$;
    var_entity_state_id.general_usage :=
$DOC$Certain application features and behaviors will depend on the configuration
of the state value selected for a entity record.$DOC$;


    var_comments_config.columns :=
        ARRAY [
              var_owning_entity_id
            , var_entity_type_id
            , var_entity_state_id
            ]::ms_syst_priv.comments_config_table_column[];

    PERFORM ms_syst_priv.generate_comments_table( var_comments_config );

END;
$DOCUMENTATION$;
