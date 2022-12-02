-- File:        initialize_enum_contact_types.eex.sql
-- Location:    musebms/database/components/application/mscmp_brm_contact/seed_data/initialize_enum_contact_types.eex.sql
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
        p_enum_def => $INIT_ENUM_CONTACT_TYPES$
        {
          "internal_name": "contact_types",
          "display_name": "Contact Types",
          "syst_description": "Identifies the available types of contact that may be associated with a person, entity, or place.",
          "syst_defined": true,
          "user_maintainable": true,
          "default_syst_options": null,
          "default_user_options": null,
          "functional_types": [
            {
              "internal_name": "contact_types_phone",
              "display_name": "Contact Type / Phone",
              "external_name": "Phone",
              "syst_description": "Telephone system dependent communications.  Contacts of this type will include formatting information from the configured phone number formats."
            },
            {
              "internal_name": "contact_types_physical_address",
              "display_name": "Contact Type / Physical Address",
              "external_name": "Physical Address",
              "syst_description": "Street and mailing addresses.  Contacts of this type will include formatting information from the configured street address formats."
            },
            {
              "internal_name": "contact_types_email_address",
              "display_name": "Contact Type / Email Address",
              "external_name": "Email Address",
              "syst_description": "Email address"
            },
            {
              "internal_name": "contact_types_website",
              "display_name": "Contact Type / Website",
              "external_name": "Website",
              "syst_description": "Website URL"
            },
            {
              "internal_name": "contact_types_chat",
              "display_name": "Contact Type / Chat",
              "external_name": "Chat",
              "syst_description": "Chat & messaging user and service."
            },
            {
              "internal_name": "contact_types_social_media",
              "display_name": "Contact Type / Social Media",
              "external_name": "Social Media",
              "syst_description": "Social media account name and service."
            },
            {
              "internal_name": "contact_types_generic",
              "display_name": "Contact Type / Generic",
              "external_name": "Generic",
              "syst_description": "A miscellaneous type to record non-functional, but still needed contact information."
            }
          ],
          "enum_items": [
            {
              "internal_name": "contact_types_sysdef_phone",
              "display_name": "Contact Type / Phone",
              "external_name": "Phone",
              "functional_type_name": "contact_types_phone",
              "enum_default": true,
              "functional_type_default": true,
              "syst_defined": true,
              "user_maintainable": true,
              "syst_description": "Telephone system dependent communications.  Contacts of this type will include formatting information from the configured phone number formats.",
              "syst_options": {}
            },
            {
              "internal_name": "contact_types_sysdef_physical_address",
              "display_name": "Contact Type / Physical Address",
              "external_name": "Physical Address",
              "functional_type_name": "contact_types_physical_address",
              "enum_default": true,
              "functional_type_default": true,
              "syst_defined": true,
              "user_maintainable": true,
              "syst_description": "Street and mailing addresses.  Contacts of this type will include formatting information from the configured street address formats.",
              "syst_options": {}
            },
            {
              "internal_name": "contact_types_sysdef_email_address",
              "display_name": "Contact Type / Email Address",
              "external_name": "Email Address",
              "functional_type_name": "contact_types_email_address",
              "enum_default": true,
              "functional_type_default": true,
              "syst_defined": true,
              "user_maintainable": true,
              "syst_description": "Email address",
              "syst_options": {}
            },
            {
              "internal_name": "contact_types_sysdef_website",
              "display_name": "Contact Type / Website",
              "external_name": "Website",
              "functional_type_name": "contact_types_website",
              "enum_default": true,
              "functional_type_default": true,
              "syst_defined": true,
              "user_maintainable": true,
              "syst_description": "Website URL",
              "syst_options": {}
            },
            {
              "internal_name": "contact_types_sysdef_chat",
              "display_name": "Contact Type / Chat",
              "external_name": "Chat",
              "functional_type_name": "contact_types_chat",
              "enum_default": true,
              "functional_type_default": true,
              "syst_defined": true,
              "user_maintainable": true,
              "syst_description": "Chat & messaging user and service.",
              "syst_options": {}
            },
            {
              "internal_name": "contact_types_sysdef_social_media",
              "display_name": "Contact Type / Social Media",
              "external_name": "Social Media",
              "functional_type_name": "contact_types_social_media",
              "enum_default": true,
              "functional_type_default": true,
              "syst_defined": true,
              "user_maintainable": true,
              "syst_description": "Social media account name and service.",
              "syst_options": {}
            },
            {
              "internal_name": "contact_types_sysdef_generic",
              "display_name": "Contact Type / Generic",
              "external_name": "Generic",
              "functional_type_name": "contact_types_generic",
              "enum_default": true,
              "functional_type_default": true,
              "syst_defined": true,
              "user_maintainable": true,
              "syst_description": "A miscellaneous type to record non-functional, but still needed contact information.",
              "syst_options": {}
            }
          ]
        }
            $INIT_ENUM_CONTACT_TYPES$::jsonb);

END;
$INIT_ENUM$;
