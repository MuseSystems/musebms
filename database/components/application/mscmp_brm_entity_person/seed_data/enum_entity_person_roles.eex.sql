-- File:        enum_entity_person_roles.eex.sql
-- Location:    musebms/database/components/application/mscmp_brm_entity_person/seed_data/enum_entity_person_roles.eex.sql
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
        p_enum_def => $INIT_ENUM_ENTITY_PERSON_ROLES$
        {
          "internal_name": "entity_person_roles",
          "display_name": "Entity - Person Roles",
          "syst_description": "Defines the various roles which a person may assume on behalf of a given entity.",
          "syst_defined": true,
          "user_maintainable": true,
          "default_syst_options": null,
          "default_user_options": null,
          "functional_types": [],
          "enum_items": []
        }
            $INIT_ENUM_ENTITY_PERSON_ROLES$::jsonb);

END;
$INIT_ENUM$;
