-- File:        mstr_places.eex.sql
-- Location:    musebms/database/components/application/mscmp_brm_place/ms_appl_data/mstr_places/mstr_places.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

CREATE TABLE ms_appl_data.mstr_places
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v7( )
        CONSTRAINT mstr_places_pk PRIMARY KEY
    ,owning_entity_id
        uuid
        NOT NULL
        CONSTRAINT mstr_places_entities_fk
            REFERENCES ms_appl_data.mstr_entities (id)
    ,internal_name
        text
        NOT NULL
        CONSTRAINT mstr_places_internal_name_udx UNIQUE
    ,display_name
        text
        CONSTRAINT mstr_places_display_name_udx UNIQUE
    ,external_name
        text
        NOT NULL
    ,place_type_id
        uuid
        NOT NULL
        CONSTRAINT mstr_places_place_types_fk
            REFERENCES ms_syst_data.syst_enum_items (id)
    ,place_state_id
        uuid
        CONSTRAINT mstr_places_place_states_fk
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

ALTER TABLE ms_appl_data.mstr_places OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_appl_data.mstr_places FROM public;
GRANT ALL ON TABLE ms_appl_data.mstr_places TO <%= ms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_appl_data.mstr_places
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

CREATE CONSTRAINT TRIGGER a50_trig_a_i_place_states_enum_item_check
    AFTER INSERT ON ms_appl_data.mstr_places
    FOR EACH ROW EXECUTE PROCEDURE
        ms_syst_priv.trig_a_iu_enum_item_check('place_states', 'place_state_id');

CREATE CONSTRAINT TRIGGER a50_trig_a_u_place_states_enum_item_check
    AFTER UPDATE ON ms_appl_data.mstr_places
    FOR EACH ROW WHEN ( old.place_state_id != new.place_state_id)
        EXECUTE PROCEDURE
            ms_syst_priv.trig_a_iu_enum_item_check(
                'place_states', 'place_state_id');

CREATE CONSTRAINT TRIGGER a50_trig_a_i_place_types_enum_item_check
    AFTER INSERT ON ms_appl_data.mstr_places
    FOR EACH ROW EXECUTE PROCEDURE
        ms_syst_priv.trig_a_iu_enum_item_check('place_types', 'place_type_id');

CREATE CONSTRAINT TRIGGER a50_trig_a_u_place_types_enum_item_check
    AFTER UPDATE ON ms_appl_data.mstr_places
    FOR EACH ROW WHEN ( old.place_type_id != new.place_type_id)
        EXECUTE PROCEDURE
            ms_syst_priv.trig_a_iu_enum_item_check(
                'place_types', 'place_type_id');

DO
$DOCUMENTATION$
DECLARE
    -- Table
    var_comments_config ms_syst_priv.comments_config_table;

    -- Columns
    var_owning_entity_id ms_syst_priv.comments_config_table_column;
    var_place_type_id    ms_syst_priv.comments_config_table_column;
    var_place_state_id   ms_syst_priv.comments_config_table_column;

BEGIN

    --
    -- Table Config
    --

    var_comments_config.table_schema := 'ms_appl_data';
    var_comments_config.table_name   := 'mstr_places';

    var_comments_config.description :=
$DOC$Places are the retail stores, warehouses, factories, and offices in which
businesses conduct their operations.  This is not synonymous with "address" as a
place may have multiple, different addresses for different purposes.$DOC$;

    --
    -- Column Configs
    --

    var_owning_entity_id.column_name := 'owning_entity_id';
    var_owning_entity_id.description :=
$DOC$Indicates which Managing Entity owns the Place record for the purposes of
default visibility and access.$DOC$;
    var_owning_entity_id.general_usage :=
$DOC$Any Place record owned by the Global Entity is by default visible and usable by
any Managed Entity.$DOC$;

    var_place_type_id.column_name := 'place_type_id';
    var_place_type_id.description :=
$DOC$Defines the kind of Place the record represents.  Different types of Places may
offer different functional abilities and limitations.$DOC$;

    var_place_state_id.column_name := 'place_state_id';
    var_place_state_id.description :=
$DOC$Establishes where in the record life-cycle that the record current sits.$DOC$;

    var_comments_config.columns :=
        ARRAY [
              var_owning_entity_id
            , var_place_type_id
            , var_place_state_id
            ]::ms_syst_priv.comments_config_table_column[];

    PERFORM ms_syst_priv.generate_comments_table( var_comments_config );

END;
$DOCUMENTATION$;
