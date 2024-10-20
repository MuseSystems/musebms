-- File:        enum_credential_types.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/seed_data/enum_credential_types.eex.sql
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
        p_enum_def => $INIT_ENUM_CREDENTIAL_TYPES$
        {
          "internal_name": "credential_types",
          "display_name": "Credential Types",
          "syst_description": "Established the various kinds of credentials that are available for verifying an identity.",
          "syst_defined": true,
          "user_maintainable": true,
          "default_syst_options": null,
          "default_user_options": null,
          "functional_types": [
            {
              "internal_name": "credential_types_password",
              "display_name": "Credential Type / Password",
              "external_name": "Password",
              "syst_description": "A simple user provided password."
            },
            {
              "internal_name": "credential_types_mfa_totp",
              "display_name": "Credential Type / Multi-factor, TOTP",
              "external_name": "MFA - TOTP",
              "syst_description": "Second factor authenticator for TOTP credentials."
            },
            {
              "internal_name": "credential_types_mfa_totp_recovery_code",
              "display_name": "Credential Type / Multi-factor, TOTP Recovery Code",
              "external_name": "MFA - TOTP Recovery Code",
              "syst_description": "Recovery codes for TOTP authenticator device loss support."
            },
            {
              "internal_name": "credential_types_mfa_known_host",
              "display_name": "Credential Type / Multi-factor, Known Host",
              "external_name": "MFA - Know Hosts",
              "syst_description": "When a user has been fully authenticated on a device, the user may elect to remember the device for a period of time and will not be prompted for secondary authentication when using that device.  This credential type assumes stored information on the device is sufficient to meet the multi-factor requirement."
            },
            {
              "internal_name": "credential_types_token_api",
              "display_name": "Credential Type / API Token",
              "external_name": "API Token",
              "syst_description": "Persistent tokens used for API access and similar automated systems access.  Typically this credential type would allow application access per the access account user's authorizations."
            },
            {
              "internal_name": "credential_types_token_validation",
              "display_name": "Credential Type / Validation Token",
              "external_name": "Validation Token",
              "syst_description": "A token based credential where the user is performing an identifier validation.  This credential type is restricted for use only in the validation process and should not be used for providing other application related functionality."
            },
            {
              "internal_name": "credential_types_token_recovery",
              "display_name": "Credential Type / Recovery Token",
              "external_name": "Recovery Token",
              "syst_description": "A token based credential where the user is requesting to recover from loss of another credential type, such as password recovery.  These credentials should be time limited and unusable for other authentication scenarios."
            }
          ],
          "enum_items": [
            {
              "internal_name": "credential_types_sysdef_password",
              "display_name": "Credential Type / Password",
              "external_name": "Password",
              "functional_type_name": "credential_types_password",
              "enum_default": true,
              "functional_type_default": true,
              "syst_defined": true,
              "user_maintainable": true,
              "syst_description": "A simple user provided password.",
              "syst_options": {}
            },
            {
              "internal_name": "credential_types_sysdef_mfa_totp",
              "display_name": "Credential Type / Multi-factor, TOTP",
              "external_name": "MFA - TOTP",
              "functional_type_name": "credential_types_mfa_totp",
              "enum_default": false,
              "functional_type_default": true,
              "syst_defined": true,
              "user_maintainable": true,
              "syst_description": "Second factor authenticator for TOTP credentials.",
              "syst_options": {}
            },
            {
              "internal_name": "credential_types_sysdef_mfa_totp_recovery_code",
              "display_name": "Credential Type / Multi-factor, TOTP Recovery Code",
              "external_name": "MFA - TOTP Recovery Code",
              "functional_type_name": "credential_types_mfa_totp_recovery_code",
              "enum_default": false,
              "functional_type_default": true,
              "syst_defined": true,
              "user_maintainable": true,
              "syst_description": "Recovery codes for TOTP authenticator device loss support.",
              "syst_options": {}
            },
            {
              "internal_name": "credential_types_sysdef_mfa_known_host",
              "display_name": "Credential Type / Multi-factor, Known Host",
              "external_name": "MFA - Know Hosts",
              "functional_type_name": "credential_types_mfa_known_host",
              "enum_default": false,
              "functional_type_default": true,
              "syst_defined": true,
              "user_maintainable": true,
              "syst_description": "When a user has been fully authenticated on a device, the user may elect to remember the device for a period of time and will not be prompted for secondary authentication when using that device.  This credential type assumes stored information on the device is sufficient to meet the multi-factor requirement.",
              "syst_options": {}
            },
            {
              "internal_name": "credential_types_sysdef_token_api",
              "display_name": "Credential Type / API Token",
              "external_name": "API Token",
              "functional_type_name": "credential_types_token_api",
              "enum_default": false,
              "functional_type_default": true,
              "syst_defined": true,
              "user_maintainable": true,
              "syst_description": "Persistent tokens used for API access and similar automated systems access.  Typically this credential type would allow application access per the access account user's authorizations.",
              "syst_options": {}
            },
            {
              "internal_name": "credential_types_sysdef_token_validation",
              "display_name": "Credential Type / Validation Token",
              "external_name": "Validation Token",
              "functional_type_name": "credential_types_token_validation",
              "enum_default": false,
              "functional_type_default": true,
              "syst_defined": true,
              "user_maintainable": true,
              "syst_description": "A token based credential where the user is performing an identifier validation.  This credential type is restricted for use only in the validation process and should not be used for providing other application related functionality.",
              "syst_options": {}
            },
            {
              "internal_name": "credential_types_sysdef_token_recovery",
              "display_name": "Credential Type / Recovery Token",
              "external_name": "Recovery Token",
              "functional_type_name": "credential_types_token_recovery",
              "enum_default": false,
              "functional_type_default": true,
              "syst_defined": true,
              "user_maintainable": true,
              "syst_description": "A token based credential where the user is requesting to recover from loss of another credential type, such as password recovery.  These credentials should be time limited and unusable for other authentication scenarios.",
              "syst_options": {}
            }
          ]
        }
            $INIT_ENUM_CREDENTIAL_TYPES$::jsonb);

END;
$INIT_ENUM$;
