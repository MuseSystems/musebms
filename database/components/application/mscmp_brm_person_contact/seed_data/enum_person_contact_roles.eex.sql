-- File:        enum_person_contact_roles.eex.sql
-- Location:    musebms/database/components/application/mscmp_brm_person_contact/seed_data/enum_person_contact_roles.eex.sql
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
        p_enum_def => $INIT_ENUM_PERSON_CONTACT_ROLES$
        {
          "internal_name": "person_contact_roles",
          "display_name": "Person - Contact Roles",
          "syst_description": "Defines the role that a contact information record may fulfill with a given person.  This could be mailing address, mobile phone contact, primary email, etc.",
          "syst_defined": true,
          "user_maintainable": true,
          "default_syst_options": null,
          "default_user_options": null,
          "functional_types": [],
          "enum_items": []
        }
            $INIT_ENUM_PERSON_CONTACT_ROLES$::jsonb);

END;
$INIT_ENUM$;
