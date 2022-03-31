-- File:        initialize_enum_entity_place_roles.eex.sql
-- Location:    database\instance\seed_data\brm\initialize_enum_entity_place_roles.eex.sql
-- Project:     Muse Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

DO
$INIT_ENUM$
BEGIN

PERFORM
    msbms_syst_priv.initialize_enum(
        p_enum_def => $INIT_ENUM_ENTITY_PLACE_ROLES$
        {
          "internal_name": "entity_place_roles",
          "display_name": "Entity - Place Roles",
          "syst_description": "Defines the different roles that a given place may assume for a specific entity.",
          "feature_internal_name": "instance_brm_master_entities_enumerations",
          "syst_defined": true,
          "user_maintainable": true,
          "default_syst_options": null,
          "default_user_options": null,
          "functional_types": [],
          "enum_values": []
        }
            $INIT_ENUM_ENTITY_PLACE_ROLES$::jsonb);

END;
$INIT_ENUM$;
