-- File:        initialize_enum_instance_types.eex.sql
-- Location:    database\app_msbms_global\mod_instance_mgr\seed_data\initialize_enum_instance_types.eex.sql
-- Project:     Muse Business Management System
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
        p_enum_def => $INIT_ENUM_INSTANCE_TYPES$
        {
          "internal_name": "instance_types",
          "display_name": "Instance Types",
          "syst_description": "Defines the available kinds of instances and specifies their capabilities.  This typing works both for simple informational categorizaton as well as functional concerns within the application.",
          "syst_defined": true,
          "user_maintainable": true,
          "default_syst_options": null,
          "default_user_options": null,
          "functional_types": [],
          "enum_items": [
            {
              "internal_name": "instance_types_sysdef_nonproduction",
              "display_name": "Instance Type / Non-Production",
              "external_name": "Non-Production",
              "functional_type_internal_name": null,
              "enum_default": true,
              "functional_type_default": true,
              "syst_defined": true,
              "user_maintainable": true,
              "syst_description": "Instances dedicated for development, training, and user accepting testing.",
              "syst_options": {}
            },
            {
              "internal_name": "instance_types_sysdef_production",
              "display_name": "Instance Type / Production",
              "external_name": "Production",
              "functional_type_internal_name": null,
              "enum_default": false,
              "functional_type_default": false,
              "syst_defined": true,
              "user_maintainable": true,
              "syst_description": "Instances dedicated for conducting real business transactions.",
              "syst_options": {}
            }
          ]
        }
            $INIT_ENUM_INSTANCE_TYPES$::jsonb);

END;
$INIT_ENUM$;
