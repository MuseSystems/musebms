-- File:        enum_menu_states.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_nav/seed_data/enum_menu_states.eex.sql
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
        p_enum_def => $INIT_ENUM_MENU_STATES$
        {
          "internal_name": "menu_states",
          "display_name": "Menu States",
          "syst_description": "Enumerates the available states which describe the life-cycle of the Menu records.",
          "syst_defined": true,
          "user_maintainable": false,
          "default_syst_options": null,
          "default_user_options": null,
          "functional_types": [
            {
              "internal_name": "menu_states_active",
              "display_name": "Menu State / Active",
              "external_name": "Active",
              "syst_description": "The menu is valid and is considered active.  A menu can only be made active if all child records defining the menu structure are self-consistent and valid."
            },
            {
              "internal_name": "menu_states_inactive",
              "display_name": "Menu State / Inactive",
              "external_name": "Inactive",
              "syst_description": "The menu is not available for any use and would not typically be visible to users for any purpose."
            }
          ],
          "enum_items": [
            {
              "internal_name": "menu_states_sysdef_active",
              "display_name": "Menu State / Active",
              "external_name": "Active",
              "functional_type_name": "menu_states_active",
              "enum_default": false,
              "functional_type_default": true,
              "syst_defined": true,
              "user_maintainable": false,
              "syst_description": "The menu is valid and considered active.  A menu can only be made active if all child records defining the menu structure are self-consistent and valid.",
              "syst_options": {}
            },
            {
              "internal_name": "menu_states_sysdef_inactive",
              "display_name": "Menu State / Inactive",
              "external_name": "Inactive",
              "functional_type_name": "menu_states_inactive",
              "enum_default": true,
              "functional_type_default": true,
              "syst_defined": true,
              "user_maintainable": false,
              "syst_description": "The menu is not available for any use and would not typically be visible to users for any purpose.",
              "syst_options": {}
            }
          ]
        }
            $INIT_ENUM_MENU_STATES$::jsonb);

END;
$INIT_ENUM$;
