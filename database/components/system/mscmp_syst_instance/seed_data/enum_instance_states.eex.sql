-- File:        enum_instance_states.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_instance/seed_data/enum_instance_states.eex.sql
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

CALL
    ms_syst_priv.initialize_enum(
        p_enum_def => $INIT_ENUM_INSTANCE_STATES$
        {
          "internal_name": "instance_states",
          "display_name": "Instance States",
          "syst_description": "Establishes the available states in the life-cycle of a system instance (ms_syst_data.syst_instances) record, including some direction of state related system functionality.",
          "syst_defined": true,
          "user_maintainable": true,
          "default_syst_options": null,
          "default_user_options": null,
          "functional_types": [
            {
              "internal_name": "instance_states_uninitialized",
              "display_name": "Instance State / Uninitialized",
              "external_name": "Uninitialized",
              "syst_description": "The instance definition record has been created, but the corresponding instance has not been created on the database server and is awaiting processing."
            },
            {
              "internal_name": "instance_states_initializing",
              "display_name": "Instance State / Initializing",
              "external_name": "Initializing",
              "syst_description": "The process of creating the instance has been started."
            },
            {
              "internal_name": "instance_states_initialized",
              "display_name": "Instance State / Initialized",
              "external_name": "Initialized",
              "syst_description": "Indicates that the Instance is initialized, but not yet active."
            },
            {
              "internal_name": "instance_states_active",
              "display_name": "Instance State / Active",
              "external_name": "Active",
              "syst_description": "The instance is created and usable by users."
            },
            {
              "internal_name": "instance_states_migrating",
              "display_name": "Instance State / Migrating",
              "external_name": "Migrating",
              "syst_description": "Indicates that the Instance is being migrated to the most recent application version."
            },
            {
              "internal_name": "instance_states_suspended",
              "display_name": "Instance State / Suspended",
              "external_name": "Suspended",
              "syst_description": "The instance is not available for regular use, though some limited functionality may be available.  The instance is likely visible to users for this reason."
            },
            {
              "internal_name": "instance_states_inactive",
              "display_name": "Instance State / Inactive",
              "external_name": "Inactive",
              "syst_description": "The instance is not available for any use and would not typically be visible tp users for any purpose."
            },
            {
              "internal_name": "instance_states_failed",
              "display_name": "Instance State / Failed",
              "external_name": "Failed",
              "syst_description": "The instance is in an error state and is not available for use."
            },
            {
              "internal_name": "instance_states_purge_eligible",
              "display_name": "Instance State / Purge Eligible",
              "external_name": "Purge Eligible",
              "syst_description": "The instance is not available for any use, not visible to users and subject to be completely deleted from the system at any point in time."
            }
          ],
          "enum_items": [
            {
              "internal_name": "instance_states_sysdef_uninitialized",
              "display_name": "Instance State / Uninitialized",
              "external_name": "Uninitialized",
              "functional_type_name": "instance_states_uninitialized",
              "enum_default": true,
              "functional_type_default": true,
              "syst_defined": true,
              "user_maintainable": true,
              "syst_description": "The instance definition record has been created, but the corresponding instance has not been created on the database server and is awaiting processing.",
              "syst_options": {}
            },
            {
              "internal_name": "instance_states_sysdef_initializing",
              "display_name": "Instance State / Initializing",
              "external_name": "Initializing",
              "functional_type_name": "instance_states_initializing",
              "enum_default": false,
              "functional_type_default": true,
              "syst_defined": true,
              "user_maintainable": true,
              "syst_description": "The process of creating the instance has been started.",
              "syst_options": {}
            },
            {
              "internal_name": "instance_states_sysdef_initialized",
              "display_name": "Instance State / Initialized",
              "external_name": "Initialized",
              "functional_type_name": "instance_states_initialized",
              "enum_default": false,
              "functional_type_default": true,
              "syst_defined": true,
              "user_maintainable": true,
              "syst_description": "Indicates that the Instance is initialized, but not yet active.",
              "syst_options": {}
            },
            {
              "internal_name": "instance_states_sysdef_active",
              "display_name": "Instance State / Active",
              "external_name": "Active",
              "functional_type_name": "instance_states_active",
              "enum_default": false,
              "functional_type_default": true,
              "syst_defined": true,
              "user_maintainable": true,
              "syst_description": "The instance is created and usable by users.",
              "syst_options": {}
            },
            {
              "internal_name": "instance_states_sysdef_migrating",
              "display_name": "Instance State / Migrating",
              "external_name": "Initialized",
              "functional_type_name": "instance_states_migrating",
              "enum_default": false,
              "functional_type_default": true,
              "syst_defined": true,
              "user_maintainable": true,
              "syst_description": "Indicates that the Instance is being migrated to the most recent application version.",
              "syst_options": {}
            },
            {
              "internal_name": "instance_states_sysdef_suspended",
              "display_name": "Instance State / Suspended",
              "external_name": "Suspended",
              "functional_type_name": "instance_states_suspended",
              "enum_default": false,
              "functional_type_default": true,
              "syst_defined": true,
              "user_maintainable": true,
              "syst_description": "The instance is not available for regular use, though some limited functionality may be available.  The instance is likely visible to users for this reason.",
              "syst_options": {}
            },
            {
              "internal_name": "instance_states_sysdef_inactive",
              "display_name": "Instance State / Inactive",
              "external_name": "Inactive",
              "functional_type_name": "instance_states_inactive",
              "enum_default": false,
              "functional_type_default": true,
              "syst_defined": true,
              "user_maintainable": true,
              "syst_description": "The instance is not available for any use and would not typically be visible tp users for any purpose.",
              "syst_options": {}
            },
            {
              "internal_name": "instance_states_sysdef_failed",
              "display_name": "Instance State / Failed",
              "external_name": "Inactive",
              "functional_type_name": "instance_states_failed",
              "enum_default": false,
              "functional_type_default": true,
              "syst_defined": true,
              "user_maintainable": true,
              "syst_description": "The instance is in an error state and is not available for use.",
              "syst_options": {}
            },
            {
              "internal_name": "instance_states_sysdef_purge_eligible",
              "display_name": "Instance State / Purge Eligible",
              "external_name": "Purge Eligible",
              "functional_type_name": "instance_states_purge_eligible",
              "enum_default": false,
              "functional_type_default": true,
              "syst_defined": true,
              "user_maintainable": true,
              "syst_description": "The instance is not available for any use, not visible to users and subject to be completely deleted from the system at any point in time.",
              "syst_options": {}
            }
          ]
        }
            $INIT_ENUM_INSTANCE_STATES$::jsonb);

END;
$INIT_ENUM$;
