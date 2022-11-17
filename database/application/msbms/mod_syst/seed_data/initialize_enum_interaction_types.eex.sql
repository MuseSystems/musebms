-- File:        initialize_enum_interaction_types.eex.sql
-- Location:    musebms/database/application/msbms/mod_syst/seed_data/initialize_enum_interaction_types.eex.sql
-- Project:     Muse Systems Business Management System
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
        p_enum_def => $INIT_ENUM_INTERACTION_TYPES$
        {
          "internal_name": "interaction_types",
          "display_name": "Interaction Types",
          "syst_description": "Identifies classes of actions that a user or external system may request of the application.",
          "syst_defined": true,
          "user_maintainable": true,
          "default_syst_options": null,
          "default_user_options": null,
          "functional_types": [],
          "enum_items": []
        }
            $INIT_ENUM_INTERACTION_TYPES$::jsonb);

END;
$INIT_ENUM$;
