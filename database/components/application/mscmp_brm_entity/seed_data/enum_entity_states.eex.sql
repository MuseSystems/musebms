-- File:        enum_entity_states.eex.sql
-- Location:    musebms/database/components/application/mscmp_brm_entity/seed_data/enum_entity_states.eex.sql
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

PERFORM
    ms_syst_priv.initialize_enum(
        p_enum_def => $INIT_ENUM_ENTITY_STATES$
        {
          "internal_name": "entity_states",
          "display_name": "Entity States",
          "syst_description": "Lifecycle management stages for business entities.",
          "syst_defined": true,
          "user_maintainable": true,
          "default_syst_options": null,
          "default_user_options": null,
          "functional_types": [],
          "enum_items": []
        }
            $INIT_ENUM_ENTITY_STATES$::jsonb);

END;
$INIT_ENUM$;
