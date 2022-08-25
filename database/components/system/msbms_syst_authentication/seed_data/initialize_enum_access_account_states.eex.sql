-- File:        initialize_enum_access_account_states.eex.sql
-- Location:    musebms/database/components/system/msbms_syst_authentication/seed_data/initialize_enum_access_account_states.eex.sql
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
        p_enum_def => $INIT_ENUM_ACCESS_ACCOUNT_STATES$
        {
          "internal_name": "access_account_states",
          "display_name": "Access Account States",
          "syst_description": "Enumerates the available states which describe the life-cycle of the access account records.",
          "syst_defined": true,
          "user_maintainable": true,
          "default_syst_options": null,
          "default_user_options": null,
          "functional_types": [
            {
              "internal_name": "access_account_states_pending",
              "display_name": "Access Account State / Pending",
              "external_name": "Pending",
              "syst_description": "Indicates that the access account is pending validation.  When pending validation, new access accounts have been created, but verification that contact information such as the account holder's email address is valid, has not been completed.  When in pending status, the account cannot be used for regular authentication until verification has been completed."
            },
            {
              "internal_name": "access_account_states_active",
              "display_name": "Access Account State / Active",
              "external_name": "Active",
              "syst_description": "The access account is active and is considered active."
            },
            {
              "internal_name": "access_account_states_suspended",
              "display_name": "Access Account State / Suspended",
              "external_name": "Suspended",
              "syst_description": "The access account is currently suspended and not usable for regular system access.  Some basic maintenance functions may still be available to suspended access accounts as appropriate."
            },
            {
              "internal_name": "access_account_states_inactive",
              "display_name": "Access Account State / Inactive",
              "external_name": "Inactive",
              "syst_description": "The access account is not available for any use and would not typically be visible to users for any purpose."
            },
            {
              "internal_name": "access_account_states_purge_eligible",
              "display_name": "Access Account State / Purge Eligible",
              "external_name": "Purge Eligible",
              "syst_description": "The access account is not available for any use, not visible to users and subject to be completely deleted from the system at any point in time."
            }
          ],
          "enum_items": [
            {
              "internal_name": "access_account_states_sysdef_pending",
              "display_name": "Access Account State / Pending",
              "external_name": "Pending",
              "functional_type_name": "access_account_states_pending",
              "enum_default": true,
              "functional_type_default": true,
              "syst_defined": true,
              "user_maintainable": true,
              "syst_description": "Indicates that the access account is pending validation.  When pending validation, new access accounts have been created, but verification that contact information such as the account holder's email address is valid, has not been completed.  When in pending status, the account cannot be used for regular authentication until verification has been completed.",
              "syst_options": {}
            },
            {
              "internal_name": "access_account_states_sysdef_active",
              "display_name": "Access Account State / Active",
              "external_name": "Active",
              "functional_type_name": "access_account_states_active",
              "enum_default": false,
              "functional_type_default": true,
              "syst_defined": true,
              "user_maintainable": true,
              "syst_description": "The access account is active and is considered active.",
              "syst_options": {}
            },
            {
              "internal_name": "access_account_states_sysdef_suspended",
              "display_name": "Access Account State / Suspended",
              "external_name": "Suspended",
              "functional_type_name": "access_account_states_suspended",
              "enum_default": false,
              "functional_type_default": true,
              "syst_defined": true,
              "user_maintainable": true,
              "syst_description": "The access account is currently suspended and not usable for regular system access.  Some basic maintenance functions may still be available to suspended access accounts as appropriate.",
              "syst_options": {}
            },
            {
              "internal_name": "access_account_states_sysdef_inactive",
              "display_name": "Access Account State / Inactive",
              "external_name": "Inactive",
              "functional_type_name": "access_account_states_inactive",
              "enum_default": false,
              "functional_type_default": true,
              "syst_defined": true,
              "user_maintainable": true,
              "syst_description": "The access account is not available for any use and would not typically be visible to users for any purpose.",
              "syst_options": {}
            },
            {
              "internal_name": "access_account_states_sysdef_purge_eligible",
              "display_name": "Access Account State / Purge Eligible",
              "external_name": "Purge Eligible",
              "functional_type_name": "access_account_states_purge_eligible",
              "enum_default": false,
              "functional_type_default": true,
              "syst_defined": true,
              "user_maintainable": true,
              "syst_description": "The access account is not available for any use, not visible to users and subject to be completely deleted from the system at any point in time.",
              "syst_options": {}
            }
          ]
        }
            $INIT_ENUM_ACCESS_ACCOUNT_STATES$::jsonb);

END;
$INIT_ENUM$;
