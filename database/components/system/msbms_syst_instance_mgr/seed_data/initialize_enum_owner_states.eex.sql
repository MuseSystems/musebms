-- File:        initialize_enum_owner_states.eex.sql
-- Location:    musebms/database/components/system/msbms_syst_instance_mgr/seed_data/initialize_enum_owner_states.eex.sql
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
        p_enum_def => $INIT_ENUM_OWNER_STATES$
        {
          "internal_name": "owner_states",
          "display_name": "Owner States",
          "syst_description": "Enumerates the life-cycle states that an owner record might exist in.  Chiefly, this has to do with whether or not a particular owner is considered active or not.",
          "syst_defined": true,
          "user_maintainable": true,
          "default_syst_options": null,
          "default_user_options": null,
          "functional_types": [
            {
              "internal_name": "owner_states_active",
              "display_name": "Owner State / Active",
              "external_name": "Active",
              "syst_description": "The owner is active and available for normal use."
            },
            {
              "internal_name": "owner_states_suspended",
              "display_name": "Owner State / Suspended",
              "external_name": "Suspended",
              "syst_description": "The owner is not available for regular use, though some limited functionality may be available.  The owner is likely visible to users for this reason."
            },
            {
              "internal_name": "owner_states_inactive",
              "display_name": "Owner State / Inactive",
              "external_name": "Inactive",
              "syst_description": "The owner is not available for any use and would not typically be visible tp users for any purpose."
            },
            {
              "internal_name": "owner_states_purge_eligible",
              "display_name": "Owner State / Purge Eligible",
              "external_name": "Purge Eligible",
              "syst_description": "The owner is not available for any use, not visible to users and subject to be completely deleted from the system at any point in time."
            }
          ],
          "enum_items": [
            {
              "internal_name": "owner_states_sysdef_active",
              "display_name": "Owner State / Active",
              "external_name": "Active",
              "functional_type_name": "owner_states_active",
              "enum_default": true,
              "functional_type_default": true,
              "syst_defined": true,
              "user_maintainable": true,
              "syst_description": "The owner account is active and all associated records are considered active unless otherwise indicated.",
              "syst_options": {}
            },
            {
              "internal_name": "owner_states_sysdef_suspended",
              "display_name": "Owner State / Suspended",
              "external_name": "Suspended",
              "functional_type_name": "owner_states_suspended",
              "enum_default": false,
              "functional_type_default": true,
              "syst_defined": true,
              "user_maintainable": true,
              "syst_description": "The owner related instances or users are not available for regular use, though some limited functionality may be available.  The owner instances and some access is likely visible to users for this reason.  This status supersedes any instance or user specific state.",
              "syst_options": {}
            },
            {
              "internal_name": "owner_states_sysdef_inactive",
              "display_name": "Owner State / Inactive",
              "external_name": "Inactive",
              "functional_type_name": "owner_states_inactive",
              "enum_default": false,
              "functional_type_default": true,
              "syst_defined": true,
              "user_maintainable": true,
              "syst_description": "The owner account is not available for any use and would not typically be visible to users for any purpose.",
              "syst_options": {}
            },
            {
              "internal_name": "owner_states_sysdef_purge_eligible",
              "display_name": "Owner State / Purge Eligible",
              "external_name": "Purge Eligible",
              "functional_type_name": "owner_states_purge_eligible",
              "enum_default": false,
              "functional_type_default": true,
              "syst_defined": true,
              "user_maintainable": true,
              "syst_description": "The instance is not available for any use, not visible to users and subject to be completely deleted from the system at any point in time.",
              "syst_options": {}
            }
          ]
        }
            $INIT_ENUM_OWNER_STATES$::jsonb);

END;
$INIT_ENUM$;
