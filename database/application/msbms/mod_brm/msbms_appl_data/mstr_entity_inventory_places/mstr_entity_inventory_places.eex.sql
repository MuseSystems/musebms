-- File:        mstr_entity_inventory_places.eex.sql
-- Location:    musebms/database/application/msbms/mod_brm/msbms_appl_data/mstr_entity_inventory_places/mstr_entity_inventory_places.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE TABLE msbms_appl_data.mstr_entity_inventory_places
(
     id
         uuid
         NOT NULL DEFAULT uuid_generate_v1( )
        CONSTRAINT mstr_entity_inventory_places_pk PRIMARY KEY
    ,place_id
        uuid
        NOT NULL
        CONSTRAINT mstr_entity_inventory_places_place_fk
            REFERENCES msbms_appl_data.mstr_places (id) ON DELETE CASCADE
    ,owning_entity_id
        uuid
        NOT NULL
        CONSTRAINT mstr_entity_inventory_places_owning_entity_fk
            REFERENCES msbms_appl_data.mstr_entities (id) ON DELETE CASCADE
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

ALTER TABLE msbms_appl_data.mstr_entity_inventory_places OWNER TO <%= msbms_owner %>;

REVOKE ALL ON TABLE msbms_appl_data.mstr_entity_inventory_places FROM public;
GRANT ALL ON TABLE msbms_appl_data.mstr_entity_inventory_places TO <%= msbms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON msbms_appl_data.mstr_entity_inventory_places
    FOR EACH ROW EXECUTE PROCEDURE msbms_syst_priv.trig_b_iu_set_diagnostic_columns();

COMMENT ON
    TABLE msbms_appl_data.mstr_entity_inventory_places IS
$DOC$Establishes one or more inventory relationships between a managed entity and a
place.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.mstr_entity_inventory_places.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.mstr_entity_inventory_places.place_id IS
$DOC$Identifies the place that will have an inventory relationship with the owning
entity.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.mstr_entity_inventory_places.owning_entity_id IS
$DOC$Establishes the entity which has an inventory relationship to the identified
place.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.mstr_entity_inventory_places.receives_external_inventory IS
$DOC$If true, this inventory may receive inventory shipments from third parties such
as might originate from purchase order transactions.  If false, this inventory
may not receive inventory from external third parties.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.mstr_entity_inventory_places.fulfills_external_inventory IS
$DOC$If true, inventory units may be fulfilled from this place, for this entity. If
false, this inventory may not participate as a source of fulfillment to third
parties.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.mstr_entity_inventory_places.receives_internal_inventory IS
$DOC$If true, inventory units may be received into this inventory from other
inventories managed by the system.  If false, other managed inventories will not
be valid sources to replenish stocks in this inventory.  Transferred inventory
would be an example of a transaction requiring the inventory to allow the
processing of internal receipts.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.mstr_entity_inventory_places.fulfills_internal_inventory IS
$DOC$If true, inventory units may be fulfilled from this managed inventory to another
inventory managed by the system. If false, the inventory may not serve as the
source of inventory units to other managed inventories.  Transferring inventory
out is an example of a transaction requiring this internal fulfillment ability.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.mstr_entity_inventory_places.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.mstr_entity_inventory_places.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.mstr_entity_inventory_places.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.mstr_entity_inventory_places.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.mstr_entity_inventory_places.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.mstr_entity_inventory_places.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.mstr_entity_inventory_places.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;
