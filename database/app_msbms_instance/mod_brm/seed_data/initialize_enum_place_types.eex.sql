-- File:        initialize_enum_place_types.eex.sql
-- Location:    musebms/database/app_msbms_instance/mod_brm/seed_data/initialize_enum_place_types.eex.sql
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
        p_enum_def => $INIT_ENUM_PLACE_TYPES$
        {
          "internal_name": "pace_types",
          "display_name": "Place Types",
          "syst_description": "Establishes the different kinds of places in which the place may be categorized",
          "syst_defined": true,
          "user_maintainable": true,
          "default_syst_options": null,
          "default_user_options": null,
          "functional_types": [],
          "enum_items": []
        }
            $INIT_ENUM_PLACE_TYPES$::jsonb);

END;
$INIT_ENUM$;
