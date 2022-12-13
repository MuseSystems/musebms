-- File:        enum_contact_states.eex.sql
-- Location:    musebms/database/components/application/mscmp_brm_contact/seed_data/enum_contact_states.eex.sql
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
        p_enum_def => $INIT_ENUM_CONTACT_STATES$
        {
          "internal_name": "contact_states",
          "display_name": "Contact States",
          "syst_description": "Establishes the available life-cycle states for contact information.",
          "syst_defined": true,
          "user_maintainable": true,
          "default_syst_options": null,
          "default_user_options": null,
          "functional_types": [],
          "enum_items": []
        }
            $INIT_ENUM_CONTACT_STATES$::jsonb);

END;
$INIT_ENUM$;
