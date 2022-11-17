-- File:        initialize_enum_address_states.eex.sql
-- Location:    musebms/database/application/msbms/mod_brm/seed_data/initialize_enum_address_states.eex.sql
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
        p_enum_def => $INIT_ENUM_ADDRESS_STATES$
        {
          "internal_name": "address_states",
          "display_name": "Address States",
          "syst_description": "Defines the life-cycle states for addresses in the system.",
          "syst_defined": true,
          "user_maintainable": true,
          "default_syst_options": null,
          "default_user_options": null,
          "functional_types": [],
          "enum_items": []
        }
            $INIT_ENUM_ADDRESS_STATES$::jsonb);

END;
$INIT_ENUM$;
