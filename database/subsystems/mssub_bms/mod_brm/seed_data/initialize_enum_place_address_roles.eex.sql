-- File:        initialize_enum_place_address_roles.eex.sql
-- Location:    musebms/database/application/msbms/mod_brm/seed_data/initialize_enum_place_address_roles.eex.sql
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
    ms_syst_priv.initialize_enum(
        p_enum_def => $INIT_ENUM_PLACE_ADDRESS_ROLES$
        {
          "internal_name": "place_address_roles",
          "display_name": "Place - Address Roles",
          "syst_description": "Established the roles which an address may assume related to a parent place.",
          "syst_defined": true,
          "user_maintainable": true,
          "default_syst_options": null,
          "default_user_options": null,
          "functional_types": [],
          "enum_items": []
        }
            $INIT_ENUM_PLACE_ADDRESS_ROLES$::jsonb);

END;
$INIT_ENUM$;
