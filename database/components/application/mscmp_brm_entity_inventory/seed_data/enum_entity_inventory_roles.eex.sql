-- File:        enum_entity_inventory_roles.eex.sql
-- Location:    musebms/database/components/application/mscmp_brm_entity_inventory/seed_data/enum_entity_inventory_roles.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

DO
$INIT_ENUM$
BEGIN

CALL
    ms_syst_priv.initialize_enum(
        p_enum_def => $INIT_ENUM_ENTITY_PLACE_ROLES$
        {
          "internal_name": "entity_inventory_roles",
          "display_name": "Entity - Place Roles",
          "syst_description": "Defines the different roles that a given Inventory Place may assume for a specific Entity.",
          "syst_defined": true,
          "user_maintainable": true,
          "default_syst_options": null,
          "default_user_options": null,
          "functional_types": [],
          "enum_items": []
        }
            $INIT_ENUM_ENTITY_PLACE_ROLES$::jsonb);

END;
$INIT_ENUM$;
