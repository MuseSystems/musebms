-- File:        initialize_enum_person_types.eex.sql
-- Location:    musebms/database/application/msbms_instance/mod_brm/seed_data/initialize_enum_person_types.eex.sql
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
        p_enum_def => $INIT_ENUM_PERSON_TYPES$
        {
          "internal_name": "person_types",
          "display_name": "Person Types",
          "syst_description": "A list of the various types of entities may be represented by a person.",
          "syst_defined": true,
          "user_maintainable": true,
          "default_syst_options": null,
          "default_user_options": null,
          "functional_types": [
            {
              "internal_name": "person_types_individual",
              "display_name": "Person Type / Individual",
              "external_name": "Individual",
              "syst_description": "In this case the person record represents an actual person."
            },
            {
              "internal_name": "person_types_function",
              "display_name": "Person Type / Function",
              "external_name": "Function",
              "syst_description": "This type indicates that the person is defining a role where the specific person performing that role is not important.  For example, \"Accounts Receivable\" may be a generic person to contact for payment remission or for the resolution of other payment issues.  The key is the specific person contacted is not important but contacting someone acting in that capacity is."
            }
          ],
          "enum_items": [
            {
              "internal_name": "person_types_sysdef_individual",
              "display_name": "Person Type / Individual",
              "external_name": "Individual",
              "functional_type_name": "person_types_individual",
              "enum_default": true,
              "functional_type_default": true,
              "syst_defined": true,
              "user_maintainable": true,
              "syst_description": "In this case the person record represents an actual person.",
              "syst_options": {}
            },
            {
              "internal_name": "person_types_sysdef_function",
              "display_name": "Person Type / Function",
              "external_name": "Function",
              "functional_type_name": "person_types_function",
              "enum_default": false,
              "functional_type_default": true,
              "syst_defined": true,
              "user_maintainable": true,
              "syst_description": "This type indicates that the person is defining a role where the specific person performing that role is not important.  For example, \"Accounts Receivable\" may be a generic person to contact for payment remission or for the resolution of other payment issues.  The key is the specific person contacted is not important but contacting someone acting in that capacity is.",
              "syst_options": {}
            }
          ]
        }
            $INIT_ENUM_PERSON_TYPES$::jsonb);

END;
$INIT_ENUM$;
