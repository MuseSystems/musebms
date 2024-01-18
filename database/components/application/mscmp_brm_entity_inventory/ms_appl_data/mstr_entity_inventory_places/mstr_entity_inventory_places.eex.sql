-- File:        mstr_entity_inventory_places.eex.sql
-- Location:    musebms/database/components/application/mscmp_brm_entity_inventory/ms_appl_data/mstr_entity_inventory_places/mstr_entity_inventory_places.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

CREATE TABLE ms_appl_data.mstr_entity_inventory_places
(
     id
         uuid
         NOT NULL DEFAULT uuid_generate_v7( )
        CONSTRAINT mstr_entity_inventory_places_pk PRIMARY KEY
    ,place_id
        uuid
        NOT NULL
        CONSTRAINT mstr_entity_inventory_places_place_fk
            REFERENCES ms_appl_data.mstr_places (id) ON DELETE CASCADE
    ,owning_entity_id
        uuid
        NOT NULL
        CONSTRAINT mstr_entity_inventory_places_owning_entity_fk
            REFERENCES ms_appl_data.mstr_entities (id) ON DELETE CASCADE
    ,receives_external_inventory
        boolean
        NOT NULL DEFAULT false
    ,fulfills_external_inventory
        boolean
        NOT NULL DEFAULT false
    ,receives_internal_inventory
        boolean
        NOT NULL DEFAULT false
    ,fulfills_internal_inventory
        boolean
        NOT NULL DEFAULT false
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

ALTER TABLE ms_appl_data.mstr_entity_inventory_places OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_appl_data.mstr_entity_inventory_places FROM public;
GRANT ALL ON TABLE ms_appl_data.mstr_entity_inventory_places TO <%= ms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_appl_data.mstr_entity_inventory_places
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

DO
$DOCUMENTATION$
DECLARE
    -- Table
    var_comments_config ms_syst_priv.comments_config_table;

    -- Columns
    var_place_id                    ms_syst_priv.comments_config_table_column;
    var_owning_entity_id            ms_syst_priv.comments_config_table_column;
    var_receives_external_inventory ms_syst_priv.comments_config_table_column;
    var_fulfills_external_inventory ms_syst_priv.comments_config_table_column;
    var_receives_internal_inventory ms_syst_priv.comments_config_table_column;
    var_fulfills_internal_inventory ms_syst_priv.comments_config_table_column;


BEGIN

    --
    -- Table Config
    --

    var_comments_config.table_schema := 'ms_appl_data';
    var_comments_config.table_name   := 'mstr_entity_inventory_places';

    var_comments_config.description :=
$DOC$Establishes one or more Inventory Relationships between an Owning Entity and a
Place.$DOC$;

    --
    -- Column Configs
    --

    var_place_id.column_name := 'place_id';
    var_place_id.description :=
$DOC$Identifies the place that will have an Inventory Relationship with the Owning
Entity.$DOC$;

    var_owning_entity_id.column_name := 'owning_entity_id';
    var_owning_entity_id.description :=
$DOC$Establishes the Entity which has an Inventory Relationship to the identified
place.$DOC$;

    var_receives_external_inventory.column_name := 'receives_external_inventory';
    var_receives_external_inventory.description :=
$DOC$If true, this inventory may receive inventory shipments from third parties such
as might originate from purchase order transactions.  If false, this inventory
may not receive inventory from external third parties.$DOC$;

    var_fulfills_external_inventory.column_name := 'fulfills_external_inventory';
    var_fulfills_external_inventory.description :=
$DOC$If true, inventory units may be fulfilled from this place, for this entity. If
false, this inventory may not participate as a source of fulfillment to third
parties.$DOC$;

    var_receives_internal_inventory.column_name := 'receives_internal_inventory';
    var_receives_internal_inventory.description :=
$DOC$If true, inventory units may be received into this inventory from other
inventories managed by the system.  If false, other managed inventories will not
be valid sources to replenish stocks in this inventory.  Transferred inventory
would be an example of a transaction requiring the inventory to allow the
processing of internal receipts.$DOC$;

    var_fulfills_internal_inventory.column_name := 'fulfills_internal_inventory';
    var_fulfills_internal_inventory.description :=
$DOC$If true, inventory units may be fulfilled from this managed inventory to another
inventory managed by the system. If false, the inventory may not serve as the
source of inventory units to other managed inventories.  Transferring inventory
out is an example of a transaction requiring this internal fulfillment ability.$DOC$;


    var_comments_config.columns :=
        ARRAY [
              var_place_id
            , var_owning_entity_id
            , var_receives_external_inventory
            , var_fulfills_external_inventory
            , var_receives_internal_inventory
            , var_fulfills_internal_inventory
            ]::ms_syst_priv.comments_config_table_column[];

    PERFORM ms_syst_priv.generate_comments_table( var_comments_config );

END;
$DOCUMENTATION$;
