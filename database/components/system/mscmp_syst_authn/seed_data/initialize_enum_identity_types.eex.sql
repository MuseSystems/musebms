-- File:        initialize_enum_identity_types.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/seed_data/initialize_enum_identity_types.eex.sql
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
    ms_syst_priv.initialize_enum(
        p_enum_def => $INIT_ENUM_IDENTITY_TYPES$
        {
          "internal_name": "identity_types",
          "display_name": "Identity Types",
          "syst_description": "Established the various kinds of credentials that are available for verifying an identity.",
          "syst_defined": true,
          "user_maintainable": false,
          "default_syst_options": null,
          "default_user_options": null,
          "functional_types": [
            {
              "internal_name": "identity_types_email",
              "display_name": "Identity Type / Email",
              "external_name": "Email",
              "syst_description": "This identity type indicates the sort of user name a human user would enter into a login form to identify themselves. The user identifier will always be an email address.  This identity may only be used for interactive logins and explicitly not for in scenarios where you would use token credential types for authentication."
            },
            {
              "internal_name": "identity_types_account",
              "display_name": "Identity Type / Account",
              "external_name": "Account",
              "syst_description": "Account IDs are system generated IDs which can be used similar to user name, but can be given to third parties, such as the administrator of an application instance for the purpose of being granted user access to the instance, without also disclosing personal ID information such as an email address.  These IDs are typical simple and easy to provide via verbal or written communication.  This ID type is not allowed for login."
            },
            {
              "internal_name": "identity_types_api",
              "display_name": "Identity Type / API",
              "external_name": "API",
              "syst_description": "A system generated ID for use in identifying the user account in automated access scenarios.  This kind of ID differs from the account_id in that it is significantly larger than an account ID would be and may only be used with token credential types."
            },
            {
              "internal_name": "identity_types_validation",
              "display_name": "Identity Type / Validation",
              "external_name": "Validation",
              "syst_description": "A one time use identifier which, along with a one time use credential, validates that an access account has been setup correctly."
            },
            {
              "internal_name": "identity_types_password_recovery",
              "display_name": "Identity Type / Password Recovery",
              "external_name": "Password Recovery",
              "syst_description": "A one time use identifier which, along with a one time use credential, allows a user to reset their password after alternative method of authentication."
            }
          ],
          "enum_items": [
            {
              "internal_name": "identity_types_sysdef_email",
              "display_name": "Identity Type / Email",
              "external_name": "Email",
              "functional_type_name": "identity_types_email",
              "enum_default": true,
              "functional_type_default": true,
              "syst_defined": true,
              "user_maintainable": false,
              "syst_description": "This identity type indicates the sort of user name a human user would enter into a login form to identify themselves. The user identifier will always be an email address.  This identity may only be used for interactive logins and explicitly not for in scenarios where you would use token credential types for authentication.",
              "syst_options": {}
            },
            {
              "internal_name": "identity_types_sysdef_account",
              "display_name": "Identity Type / Account",
              "external_name": "Account",
              "functional_type_name": "identity_types_account",
              "enum_default": false,
              "functional_type_default": true,
              "syst_defined": true,
              "user_maintainable": false,
              "syst_description": "Account IDs are system generated IDs which can be used similar to user name, but can be given to third parties, such as the administrator of an application instance for the purpose of being granted user access to the instance, without also disclosing personal ID information such as an email address.  These IDs are typical simple and easy to provide via verbal or written communication.  This ID type is not allowed for login.",
              "syst_options": {}
            },
            {
              "internal_name": "identity_types_sysdef_api",
              "display_name": "Identity Type / API",
              "external_name": "API",
              "functional_type_name": "identity_types_api",
              "enum_default": false,
              "functional_type_default": true,
              "syst_defined": true,
              "user_maintainable": false,
              "syst_description": "A system generated ID for use in identifying the user account in automated access scenarios.  This kind of ID differs from the account_id in that it is significantly larger than an account ID would be and may only be used with token credential types.",
              "syst_options": {}
            },
            {
              "internal_name": "identity_types_sysdef_validation",
              "display_name": "Identity Type / Validation",
              "external_name": "Validation",
              "functional_type_name": "identity_types_validation",
              "enum_default": false,
              "functional_type_default": true,
              "syst_defined": true,
              "user_maintainable": false,
              "syst_description": "A one time use identifier which, along with a one time use credential, validates that an access account has been setup correctly.",
              "syst_options": {}
            },
            {
              "internal_name": "identity_types_sysdef_password_recovery",
              "display_name": "Identity Type / Password Recovery",
              "external_name": "Password Recovery",
              "functional_type_name": "identity_types_password_recovery",
              "enum_default": false,
              "functional_type_default": true,
              "syst_defined": true,
              "user_maintainable": false,
              "syst_description": "A one time use identifier which, along with a one time use credential, validates that an access account has been setup correctly.",
              "syst_options": {}
            }
          ]
        }
            $INIT_ENUM_IDENTITY_TYPES$::jsonb);

END;
$INIT_ENUM$;
