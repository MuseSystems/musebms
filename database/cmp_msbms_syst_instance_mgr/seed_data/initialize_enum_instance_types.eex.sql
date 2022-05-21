-- File:        initialize_enum_instance_types.eex.sql
-- Location:    database\cmp_msbms_syst_instance_mgr\seed_data\initialize_enum_instance_types.eex.sql
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

    PERFORM msbms_syst_priv.initialize_enum(
        p_enum_def =>
            $INIT_ENUM_INSTANCE_TYPES$
            {
              "internal_name": "instance_types",
              "display_name": "Instance Types",
              "syst_description": "Defines the available kinds of instances and specifies their capabilities.  This typing works both for simple informational categorization as well as functional concerns within the application.",
              "syst_defined": true,
              "user_maintainable": true,
              "default_syst_options": null,
              "default_user_options": null,
              "functional_types": [
                {
                  "internal_name": "instance_types_primary",
                  "display_name": "Instance Types / Primary",
                  "external_name": "Primary",
                  "syst_description": "General purpose instance type which includes instances designated as 'production'.  In most cases, this is the only instance functional type that is required."
                },
                {
                  "internal_name": "instance_types_linked",
                  "display_name": "Instance Types / Linked",
                  "external_name": "Linked",
                  "syst_description": "Designates a class of instances which are the children of a parent instance.  Typically these are non-production instances which are copies of their parent instance."
                },
                {
                  "internal_name": "instance_types_demo",
                  "display_name": "Instance Types / Demo",
                  "external_name": "Demo",
                  "syst_description": "Instances which support application demonstration purposes.  Most installations will not require this type to be used."
                },
                {
                  "internal_name": "instance_types_reserved",
                  "display_name": "Instance Types / Reserved",
                  "external_name": "Reserved",
                  "syst_description": "Other special use instances which don't fall under the other categories.  Typically there is no need to use this class of instance type."
                }
              ],
              "enum_items": []
            }
            $INIT_ENUM_INSTANCE_TYPES$::jsonb );

END;
$INIT_ENUM$;
