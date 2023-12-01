-- File:        enum_hierarchy_states.eex.sql
-- Location:    musebms/database/components/application/mscmp_core_hierarchy/seed_data/enum_hierarchy_states.eex.sql
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
        p_enum_def => $INIT_ENUM_HIERARCHY_STATES$
        {
          "internal_name": "hierarchy_states",
          "display_name": "Hierarchy States",
          "syst_description": "Enumerates the available states which describe the life-cycle of the Hierarchy records.",
          "syst_defined": true,
          "user_maintainable": false,
          "default_syst_options": null,
          "default_user_options": null,
          "functional_types": [
            {
              "internal_name": "hierarchy_states_active",
              "display_name": "Hierarchy State / Active",
              "external_name": "Active",
              "syst_description": "The hierarchy is active and is considered active.  A hierarchy can only be made active if all child records defining the hierarchy structure are self-consistent and valid.  If a hierarchy record is referenced by a record in a hierarchy implementation, the hierarchy may not be made inactive."
            },
            {
              "internal_name": "hierarchy_states_inactive",
              "display_name": "Hierarchy State / Inactive",
              "external_name": "Inactive",
              "syst_description": "The hierarchy is not available for any use and would not typically be visible to users for any purpose."
            }
          ],
          "enum_items": [
            {
              "internal_name": "hierarchy_states_sysdef_active",
              "display_name": "Hierarchy State / Active",
              "external_name": "Active",
              "functional_type_name": "hierarchy_states_active",
              "enum_default": false,
              "functional_type_default": true,
              "syst_defined": true,
              "user_maintainable": false,
              "syst_description": "The hierarchy is active and is considered active.  A hierarchy can only be made active if all child records defining the hierarchy structure are self-consistent and valid.  If a hierarchy record is referenced by a record in a hierarchy implementation, the hierarchy may not be made inactive.",
              "syst_options": {}
            },
            {
              "internal_name": "hierarchy_states_sysdef_inactive",
              "display_name": "Hierarchy State / Inactive",
              "external_name": "Inactive",
              "functional_type_name": "hierarchy_states_inactive",
              "enum_default": true,
              "functional_type_default": true,
              "syst_defined": true,
              "user_maintainable": false,
              "syst_description": "The hierarchy is not available for any use and would not typically be visible to users for any purpose.",
              "syst_options": {}
            }
          ]
        }
            $INIT_ENUM_HIERARCHY_STATES$::jsonb);

END;
$INIT_ENUM$;
