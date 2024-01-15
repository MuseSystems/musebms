-- File:        enum_hierarchy_types.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_hierarchy/seed_data/enum_hierarchy_types.eex.sql
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
        p_enum_def => $INIT_ENUM_HIERARCHY_TYPES$
        {
          "internal_name": "hierarchy_types",
          "display_name": "Hierarchy Types",
          "syst_description": "Enumerates the functional area or purpose for which a specific hierarchy may be created.",
          "syst_defined": true,
          "user_maintainable": false,
          "default_syst_options": null,
          "default_user_options": null,
          "functional_types": [],
          "enum_items": []
        }
        $INIT_ENUM_HIERARCHY_TYPES$::jsonb );
END;
$INIT_ENUM$;
