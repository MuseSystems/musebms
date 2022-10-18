-- File:        test_data.eex.sql
-- Location:    musebms/database/components/system/msbms_syst_authentication/testing_support/test_data.eex.sql
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
$AUTHENTICATION_TESTING_INIT$
    DECLARE
        var_data jsonb;
    BEGIN

        /**********************************************************************
         **
         **  Test Data Description
         **
         **********************************************************************/

        var_data := $TEST_DATA_DEFINTION$
        {
          "disallowed_passwords": [
            "password",
            "12345678",
            "123456789",
            "baseball",
            "football",
            "qwertyuiop",
            "1234567890",
            "superman",
            "1qaz2wsx",
            "trustno1"
          ],
          "disallowed_hosts": [
            "10.123.123.1",
            "10.123.123.2",
            "10.123.123.3",
            "10.123.123.4",
            "10.123.123.5"
          ],
          "owner_password_rules": [
            {
              "owner_name": "owner1",
              "password_length": {
                "lower": 6,
                "upper": 1024,
                "inclusion": "[]"
              },
              "max_age_days": 0,
              "require_upper_case": 0,
              "require_lower_case": 0,
              "require_numbers": 0,
              "require_symbols": 0,
              "disallow_recently_used": 0,
              "disallow_compromised": false,
              "require_mfa": false,
              "allowed_mfa_types": [
                "credential_types_secondary_totp"
              ]
            },
            {
              "owner_name": "owner2",
              "password_length": {
                "lower": 12,
                "upper": 64,
                "inclusion": "[]"
              },
              "max_age_days": 10,
              "require_upper_case": 2,
              "require_lower_case": 2,
              "require_numbers": 2,
              "require_symbols": 2,
              "disallow_recently_used": 2,
              "disallow_compromised": false,
              "require_mfa": true,
              "allowed_mfa_types": [
                "credential_types_secondary_totp"
              ]
            },
            {
              "owner_name": "owner3",
              "password_length": {
                "lower": 8,
                "upper": 512,
                "inclusion": "[]"
              },
              "max_age_days": 0,
              "require_upper_case": 0,
              "require_lower_case": 0,
              "require_numbers": 0,
              "require_symbols": 0,
              "disallow_recently_used": 0,
              "disallow_compromised": true,
              "require_mfa": false,
              "allowed_mfa_types": [
                "credential_types_secondary_totp"
              ]
            }
          ],
          "global_network_rules": [
            {
              "template_rule": true,
              "ordering": 1,
              "functional_type": "deny",
              "ip_host_or_network": "10.124.124.1",
              "ip_host_range_lower": null,
              "ip_host_range_upper": null
            },
            {
              "template_rule": true,
              "ordering": 2,
              "functional_type": "allow",
              "ip_host_or_network": "10.124.124.0/24",
              "ip_host_range_lower": null,
              "ip_host_range_upper": null
            },
            {
              "template_rule": true,
              "ordering": 3,
              "functional_type": "allow",
              "ip_host_or_network": null,
              "ip_host_range_lower": "10.123.123.1",
              "ip_host_range_upper": "10.123.123.254"
            },
            {
              "template_rule": false,
              "ordering": 1,
              "functional_type": "deny",
              "ip_host_or_network": "10.131.131.0/24",
              "ip_host_range_lower": null,
              "ip_host_range_upper": null
            },
            {
              "template_rule": false,
              "ordering": 2,
              "functional_type": "allow",
              "ip_host_or_network": "10.131.131.5",
              "ip_host_range_lower": null,
              "ip_host_range_upper": null
            },
            {
              "template_rule": false,
              "ordering": 3,
              "functional_type": "allow",
              "ip_host_or_network": "10.125.125.0/24",
              "ip_host_range_lower": null,
              "ip_host_range_upper": null
            },
            {
              "template_rule": false,
              "ordering": 4,
              "functional_type": "allow",
              "ip_host_or_network": null,
              "ip_host_range_lower": "10.123.123.5",
              "ip_host_range_upper": "10.123.123.254"
            }
          ],
          "owner_network_rules": [
            {
              "owner_name": "owner1",
              "ordering": 1,
              "functional_type": "deny",
              "ip_host_or_network": "10.128.128.1",
              "ip_host_range_lower": null,
              "ip_host_range_upper": null
            },
            {
              "owner_name": "owner1",
              "ordering": 2,
              "functional_type": "allow",
              "ip_host_or_network": "10.128.128.0/24",
              "ip_host_range_lower": null,
              "ip_host_range_upper": null
            },
            {
              "owner_name": "owner1",
              "ordering": 3,
              "functional_type": "deny",
              "ip_host_or_network": null,
              "ip_host_range_lower": "10.123.123.1",
              "ip_host_range_upper": "10.123.123.254"
            }
          ],
          "instance_network_rules": [
            {
              "instance_name": null,
              "ordering": 1,
              "functional_type": "allow",
              "ip_host_or_network": "10.126.126.1",
              "ip_host_range_lower": null,
              "ip_host_range_upper": null
            },
            {
              "instance_name": null,
              "ordering": 2,
              "functional_type": "deny",
              "ip_host_or_network": "10.126.126.2",
              "ip_host_range_lower": null,
              "ip_host_range_upper": null
            },
            {
              "instance_name": null,
              "ordering": 3,
              "functional_type": "allow",
              "ip_host_or_network": "10.126.126.0/24",
              "ip_host_range_lower": null,
              "ip_host_range_upper": null
            },
            {
              "instance_name": null,
              "ordering": 4,
              "functional_type": "deny",
              "ip_host_or_network": null,
              "ip_host_range_lower": "10.127.127.1",
              "ip_host_range_upper": "10.128.128.254"
            }
          ],
          "access_accounts": [
            {
              "access_account_name": "unowned_all_access",
              "external_name": "Unowned / All Access",
              "owning_owner_name": null,
              "allow_global_logins": true,
              "access_account_state_name": "access_account_states_sysdef_active",
              "instance_access": [
                {
                  "instance_name": null,
                  "no_owner_restriction": true,
                  "access_granted_days": -20,
                  "invitation_issued_days": -40,
                  "invitation_expires_days": -10,
                  "invitation_declined_days": null
                }
              ],
              "identities": [
                {
                  "identity_type_name": "identity_types_sysdef_email",
                  "account_identifier": "unowned_all_access@musesystems.com",
                  "account_identifier_length": null,
                  "validated_days": -15,
                  "validation_requested_days": -20,
                  "identity_expires_days": null,
                  "validation": null,
                  "credential": null
                },
                {
                  "identity_type_name": "identity_types_sysdef_api",
                  "account_identifier": null,
                  "account_identifier_length": 20,
                  "validated_days": -15,
                  "validation_requested_days": -20,
                  "identity_expires_days": null,
                  "validation": null,
                  "credential": {
                    "credential_type_name": "credential_types_sysdef_token_api",
                    "credential_plaintext": "TY7N2G9TADG6ADA80FFI4F24PTNYKAQGRG0LYK4FHNJ67NPS",
                    "credential_data": "$argon2id$v=19$m=65536,t=8,p=2$etwRUSNGUlv7SK7d3WCg5A$E1t6u7fI599HdoRJB8zXeEqoF/UdhL+lG7UfyAw3O28",
                    "last_updated_days": -1
                  }
                },
                {
                  "identity_type_name": "identity_types_sysdef_account",
                  "account_identifier": null,
                  "account_identifier_length": 12,
                  "validated_days": -15,
                  "validation_requested_days": -20,
                  "identity_expires_days": null,
                  "validation": null,
                  "credential": null
                }
              ],
              "credentials": [
                {
                  "credential_type_name": "credential_types_sysdef_password",
                  "credential_plaintext": "unowned.all.access.test.password",
                  "credential_data": "$argon2id$v=19$m=65536,t=8,p=2$WuXR7/MzTrdNzsYUaX/ssg$DZaMwZLHDX5z38tNck4vFIuGeZHOwfXxS87BonqETFc",
                  "last_updated_days": -1
                }
              ],
              "password_history": []
            },
            {
              "access_account_name": "owned_all_access",
              "external_name": "Owned / All Access",
              "owning_owner_name": "owner1",
              "allow_global_logins": true,
              "access_account_state_name": "access_account_states_sysdef_active",
              "instance_access": [
                {
                  "instance_name": null,
                  "access_granted_days": -20,
                  "invitation_issued_days": -40,
                  "invitation_expires_days": -10,
                  "invitation_declined_days": null
                }
              ],
              "identities": [
                {
                  "identity_type_name": "identity_types_sysdef_email",
                  "account_identifier": "owned_all_access@musesystems.com",
                  "account_identifier_length": null,
                  "validated_days": -15,
                  "validation_requested_days": -20,
                  "identity_expires_days": null,
                  "validation": null,
                  "credential": null
                },
                {
                  "identity_type_name": "identity_types_sysdef_api",
                  "account_identifier": null,
                  "account_identifier_length": 20,
                  "validated_days": -15,
                  "validation_requested_days": -20,
                  "identity_expires_days": null,
                  "validation": null,
                  "credential": {
                    "credential_type_name": "credential_types_sysdef_token_api",
                    "credential_plaintext": "QNXWXLSYLB8O3PHMSLOEU9Y1WZF4PIIPUQREXSRRYLVBMPU2",
                    "credential_data": "$argon2id$v=19$m=65536,t=8,p=2$HVjIPnRUzdzwubYxKJ6ZZg$vy4aDFg1hUBpMPm5S4/Bfs3Q7VUM725w9zIhcwUeXvQ",
                    "last_updated_days": -1
                  }
                },
                {
                  "identity_type_name": "identity_types_sysdef_account",
                  "account_identifier": null,
                  "account_identifier_length": 12,
                  "validated_days": -15,
                  "validation_requested_days": -20,
                  "identity_expires_days": null,
                  "validation": null,
                  "credential": null
                }
              ],
              "credentials": [
                {
                  "credential_type_name": "credential_types_sysdef_password",
                  "credential_plaintext": "owned.all.access.test.password",
                  "credential_data": "$argon2id$v=19$m=65536,t=8,p=2$E3Fo2aZ0ujVew+zFzVmQLg$HmOFV+om6gLAIp6rM8MFtqYpv8vPb8xWeY3RIjynxVw",
                  "last_updated_days": -1
                }
              ],
              "password_history": []
            },
            {
              "access_account_name": "update_test_accnt",
              "external_name": "Access Account Update Test Account",
              "owning_owner_name": "owner1",
              "allow_global_logins": false,
              "access_account_state_name": "access_account_states_sysdef_active",
              "instance_access": [],
              "identities": [],
              "credentials": [],
              "password_history": []
            },
            {
              "access_account_name": "bad_update_test_accnt",
              "external_name": "Bad Access Account Update Test Account",
              "owning_owner_name": "owner1",
              "allow_global_logins": false,
              "access_account_state_name": "access_account_states_sysdef_active",
              "instance_access": [],
              "identities": [],
              "credentials": [],
              "password_history": []
            },
            {
              "access_account_name": "purge_test_accnt",
              "external_name": "Purge Access Account Test Account",
              "owning_owner_name": "owner1",
              "allow_global_logins": false,
              "access_account_state_name": "access_account_states_sysdef_purge_eligible",
              "instance_access": [],
              "identities": [],
              "credentials": [],
              "password_history": []
            },
            {
              "access_account_name": "invite_to_instance_test_accnt",
              "external_name": "Invite Access Account/Instance Test Account",
              "owning_owner_name": "owner1",
              "allow_global_logins": false,
              "access_account_state_name": "access_account_states_sysdef_active",
              "instance_access": [],
              "identities": [],
              "credentials": [],
              "password_history": []
            },
            {
              "access_account_name": "decline_account_to_instance_test_accnt",
              "external_name": "Decline Access Account/Instance Invite Test Account",
              "owning_owner_name": null,
              "allow_global_logins": true,
              "access_account_state_name": "access_account_states_sysdef_active",
              "instance_access": [
                {
                  "instance_name": "app1_owner1_instance_types_std",
                  "access_granted_days": null,
                  "invitation_issued_days": -10,
                  "invitation_expires_days": 20,
                  "invitation_declined_days": null
                }
              ],
              "identities": [],
              "credentials": [],
              "password_history": []
            },
            {
              "access_account_name": "accept_account_to_instance_test_accnt",
              "external_name": "Accept Access Account/Instance Invite Test Account",
              "owning_owner_name": null,
              "allow_global_logins": true,
              "access_account_state_name": "access_account_states_sysdef_active",
              "instance_access": [
                {
                  "instance_name": "app1_owner1_instance_types_std",
                  "access_granted_days": null,
                  "invitation_issued_days": -10,
                  "invitation_expires_days": 20,
                  "invitation_declined_days": null
                }
              ],
              "identities": [],
              "credentials": [],
              "password_history": []
            },
            {
              "access_account_name": "revoke_account_to_instance_test_accnt",
              "external_name": "Revoke Access Account/Instance Invite Test Account",
              "owning_owner_name": null,
              "allow_global_logins": true,
              "access_account_state_name": "access_account_states_sysdef_active",
              "instance_access": [
                {
                  "instance_name": "app1_owner1_instance_types_std",
                  "access_granted_days": null,
                  "invitation_issued_days": -10,
                  "invitation_expires_days": 20,
                  "invitation_declined_days": null
                }
              ],
              "identities": [],
              "credentials": [],
              "password_history": []
            },
            {
              "access_account_name": "password_history_test_accnt",
              "external_name": "Password History Test Account",
              "owning_owner_name": "owner2",
              "allow_global_logins": false,
              "access_account_state_name": "access_account_states_sysdef_active",
              "instance_access": [
                {
                  "instance_name": null,
                  "access_granted_days": -20,
                  "invitation_issued_days": -40,
                  "invitation_expires_days": -10,
                  "invitation_declined_days": null
                }
              ],
              "identities": [],
              "credentials": [
                {
                  "credential_type_name": "credential_types_sysdef_password",
                  "credential_plaintext": "password.history.test.password",
                  "credential_data": "$argon2id$v=19$m=65536,t=8,p=2$ASAhNdIdchaF4N4nj/VYhw$Un97xyYZo9ExoW4tqkWsrgs8fj1FZl6MJgvRBZA0d4E",
                  "last_updated_days": -1
                }
              ],
              "password_history": [
                "$argon2id$v=19$m=65536,t=8,p=2$SlBSxy4bQcMu9UkayH6hOg$12DcQE3iI3IuPgqKpbEWNQwtcs1+SzAURaTygGKRdQE",
                "$argon2id$v=19$m=65536,t=8,p=2$AC7iCSdSXnho542OuE90rA$hU+oET8H8ovs3X2roWXsre5hENTUWxoxaSxqdM2sc+E"
              ]
            },
            {
              "access_account_name": "identity_set_expired_test_accnt",
              "external_name": "Identity Set Expired Test Account",
              "owning_owner_name": "owner2",
              "allow_global_logins": false,
              "access_account_state_name": "access_account_states_sysdef_active",
              "instance_access": [
                {
                  "instance_name": null,
                  "access_granted_days": -20,
                  "invitation_issued_days": -40,
                  "invitation_expires_days": -10,
                  "invitation_declined_days": null
                }
              ],
              "identities": [
                {
                  "identity_type_name": "identity_types_sysdef_email",
                  "account_identifier": "identity_set_expired_test_accnt@musesystems.com",
                  "account_identifier_length": null,
                  "validated_days": -15,
                  "validation_requested_days": -20,
                  "identity_expires_days": null,
                  "validation": null,
                  "credential": null
                }
              ],
              "credentials": [],
              "password_history": []
            },
            {
              "access_account_name": "identity_clear_expired_test_accnt",
              "external_name": "Identity Clear Expired Test Account",
              "owning_owner_name": "owner2",
              "allow_global_logins": false,
              "access_account_state_name": "access_account_states_sysdef_active",
              "instance_access": [
                {
                  "instance_name": null,
                  "access_granted_days": -20,
                  "invitation_issued_days": -40,
                  "invitation_expires_days": -10,
                  "invitation_declined_days": null
                }
              ],
              "identities": [
                {
                  "identity_type_name": "identity_types_sysdef_email",
                  "account_identifier": "identity_clear_expired_test_accnt@musesystems.com",
                  "account_identifier_length": null,
                  "validated_days": -15,
                  "validation_requested_days": -20,
                  "identity_expires_days": -10,
                  "validation": null,
                  "credential": null
                }
              ],
              "credentials": [],
              "password_history": []
            },
            {
              "access_account_name": "identity_expired_test_accnt",
              "external_name": "Identity Expired Test Account",
              "owning_owner_name": "owner2",
              "allow_global_logins": false,
              "access_account_state_name": "access_account_states_sysdef_active",
              "instance_access": [
                {
                  "instance_name": null,
                  "access_granted_days": -20,
                  "invitation_issued_days": -40,
                  "invitation_expires_days": -10,
                  "invitation_declined_days": null
                }
              ],
              "identities": [
                {
                  "identity_type_name": "identity_types_sysdef_email",
                  "account_identifier": "identity_expired_test_accnt@musesystems.com",
                  "account_identifier_length": null,
                  "validated_days": -15,
                  "validation_requested_days": -20,
                  "identity_expires_days": -10,
                  "validation": null,
                  "credential": null
                }
              ],
              "credentials": [],
              "password_history": []
            },
            {
              "access_account_name": "identity_not_expired_test_accnt",
              "external_name": "Identity Not Expired Test Account",
              "owning_owner_name": "owner2",
              "allow_global_logins": false,
              "access_account_state_name": "access_account_states_sysdef_active",
              "instance_access": [
                {
                  "instance_name": null,
                  "access_granted_days": -20,
                  "invitation_issued_days": -40,
                  "invitation_expires_days": -10,
                  "invitation_declined_days": null
                }
              ],
              "identities": [
                {
                  "identity_type_name": "identity_types_sysdef_email",
                  "account_identifier": "identity_not_expired_test_accnt@musesystems.com",
                  "account_identifier_length": null,
                  "validated_days": -15,
                  "validation_requested_days": -20,
                  "identity_expires_days": null,
                  "validation": null,
                  "credential": null
                }
              ],
              "credentials": [],
              "password_history": []
            },
            {
              "access_account_name": "identity_validated_test_accnt",
              "external_name": "Identity Validated Test Account",
              "owning_owner_name": "owner2",
              "allow_global_logins": false,
              "access_account_state_name": "access_account_states_sysdef_active",
              "instance_access": [
                {
                  "instance_name": null,
                  "access_granted_days": -20,
                  "invitation_issued_days": -40,
                  "invitation_expires_days": -10,
                  "invitation_declined_days": null
                }
              ],
              "identities": [
                {
                  "identity_type_name": "identity_types_sysdef_email",
                  "account_identifier": "identity_validated_test_accnt@musesystems.com",
                  "account_identifier_length": null,
                  "validated_days": -15,
                  "validation_requested_days": -20,
                  "identity_expires_days": null,
                  "validation": null,
                  "credential": null
                }
              ],
              "credentials": [],
              "password_history": []
            },
            {
              "access_account_name": "identity_not_validated_test_accnt",
              "external_name": "Identity Not Validated Test Account",
              "owning_owner_name": "owner2",
              "allow_global_logins": false,
              "access_account_state_name": "access_account_states_sysdef_active",
              "instance_access": [
                {
                  "instance_name": null,
                  "access_granted_days": -20,
                  "invitation_issued_days": -40,
                  "invitation_expires_days": -10,
                  "invitation_declined_days": null
                }
              ],
              "identities": [
                {
                  "identity_type_name": "identity_types_sysdef_email",
                  "account_identifier": "identity_not_validated_test_accnt@musesystems.com",
                  "account_identifier_length": null,
                  "validated_days": null,
                  "validation_requested_days": -20,
                  "identity_expires_days": null,
                  "validation": null,
                  "credential": null
                }
              ],
              "credentials": [],
              "password_history": []
            },
            {
              "access_account_name": "identity_delete_test_accnt",
              "external_name": "Identity Delete Test Account",
              "owning_owner_name": "owner2",
              "allow_global_logins": false,
              "access_account_state_name": "access_account_states_sysdef_active",
              "instance_access": [
                {
                  "instance_name": null,
                  "access_granted_days": -20,
                  "invitation_issued_days": -40,
                  "invitation_expires_days": -10,
                  "invitation_declined_days": null
                }
              ],
              "identities": [
                {
                  "identity_type_name": "identity_types_sysdef_email",
                  "account_identifier": "identity_delete_test_accnt@musesystems.com",
                  "account_identifier_length": null,
                  "validated_days": -15,
                  "validation_requested_days": -20,
                  "identity_expires_days": null,
                  "validation": null,
                  "credential": null
                }
              ],
              "credentials": [],
              "password_history": []
            },
            {
              "access_account_name": "identity_api_token_create_test_accnt",
              "external_name": "Identity API Token Create Test Account",
              "owning_owner_name": "owner2",
              "allow_global_logins": false,
              "access_account_state_name": "access_account_states_sysdef_active",
              "instance_access": [
                {
                  "instance_name": null,
                  "access_granted_days": -20,
                  "invitation_issued_days": -40,
                  "invitation_expires_days": -10,
                  "invitation_declined_days": null
                }
              ],
              "identities": [],
              "credentials": [],
              "password_history": []
            },
            {
              "access_account_name": "identity_email_create_test_accnt",
              "external_name": "Identity E-Mail Create Test Account",
              "owning_owner_name": "owner2",
              "allow_global_logins": false,
              "access_account_state_name": "access_account_states_sysdef_active",
              "instance_access": [
                {
                  "instance_name": null,
                  "access_granted_days": -20,
                  "invitation_issued_days": -40,
                  "invitation_expires_days": -10,
                  "invitation_declined_days": null
                }
              ],
              "identities": [],
              "credentials": [],
              "password_history": []
            },
            {
              "access_account_name": "identity_account_code_create_test_accnt",
              "external_name": "Identity Account Code Create Test Account",
              "owning_owner_name": "owner2",
              "allow_global_logins": false,
              "access_account_state_name": "access_account_states_sysdef_active",
              "instance_access": [
                {
                  "instance_name": null,
                  "access_granted_days": -20,
                  "invitation_issued_days": -40,
                  "invitation_expires_days": -10,
                  "invitation_declined_days": null
                }
              ],
              "identities": [],
              "credentials": [],
              "password_history": []
            },
            {
              "access_account_name": "identity_validation_request_test_accnt",
              "external_name": "Identity Request Validation Test Account",
              "owning_owner_name": "owner2",
              "allow_global_logins": false,
              "access_account_state_name": "access_account_states_sysdef_active",
              "instance_access": [
                {
                  "instance_name": null,
                  "access_granted_days": -20,
                  "invitation_issued_days": -40,
                  "invitation_expires_days": -10,
                  "invitation_declined_days": null
                }
              ],
              "identities": [
                {
                  "identity_type_name": "identity_types_sysdef_email",
                  "account_identifier": "identity_validation_request_test_accnt@musesystems.com",
                  "account_identifier_length": null,
                  "validated_days": -15,
                  "validation_requested_days": -20,
                  "identity_expires_days": null,
                  "validation": null,
                  "credential": null
                }
              ],
              "credentials": [],
              "password_history": []
            },
            {
              "access_account_name": "identity_validation_identify_test_accnt",
              "external_name": "Identity Identify Validation Test Account",
              "owning_owner_name": "owner2",
              "allow_global_logins": false,
              "access_account_state_name": "access_account_states_sysdef_active",
              "instance_access": [
                {
                  "instance_name": null,
                  "access_granted_days": -20,
                  "invitation_issued_days": -40,
                  "invitation_expires_days": -10,
                  "invitation_declined_days": null
                }
              ],
              "identities": [
                {
                  "identity_type_name": "identity_types_sysdef_email",
                  "account_identifier": "identity_validation_identify_test_accnt@musesystems.com",
                  "account_identifier_length": null,
                  "validated_days": null,
                  "validation_requested_days": -1,
                  "identity_expires_days": null,
                  "validation": {
                    "identity": {
                        "account_identifier_length": 40,
                        "identity_expires_days": 1
                      },
                    "credential": {
                        "credential_plaintext": "qnD7z4gUIv2dApSBwNgg1Ux7SR4f8bXt9Bu4J1Yo",
                        "credential_data": "$argon2id$v=19$m=65536,t=8,p=2$Wt8fHvrs8GTKKO0Kq9Baow$UGm0swdeGxfw6DKDsM/hoRnNVKf5DTmtLj9UEPnfgAw",
                        "last_updated_days": -10
                      }
                    },
                  "credential": null
                }
              ],
              "credentials": [],
              "password_history": []
            },
            {
              "access_account_name": "identity_validation_identify_unowned_test_accnt",
              "external_name": "Identity Identify Unowned Validation Test Account",
              "owning_owner_name": null,
              "allow_global_logins": false,
              "access_account_state_name": "access_account_states_sysdef_active",
              "instance_access": [
                {
                  "instance_name": null,
                  "access_granted_days": -20,
                  "invitation_issued_days": -40,
                  "invitation_expires_days": -10,
                  "invitation_declined_days": null
                }
              ],
              "identities": [
                {
                  "identity_type_name": "identity_types_sysdef_email",
                  "account_identifier": "identity_validation_identify_unowned_test_accnt@musesystems.com",
                  "account_identifier_length": null,
                  "validated_days": null,
                  "validation_requested_days": -1,
                  "identity_expires_days": null,
                  "validation": {
                    "identity": {
                        "account_identifier_length": 40,
                        "identity_expires_days": 1
                      },
                    "credential": {
                        "credential_plaintext": "XkdXg1y8BLHnhzGXk9gYILrvH5gHNE6UnCld4CvP",
                        "credential_data": "$argon2id$v=19$m=65536,t=8,p=2$/PB8n2/MwpPG/lRmysb3Kg$23vfvwzm+EH58ZEwrOm6wsP9vxM1XOarMRieOMaNjwM",
                        "last_updated_days": -10
                      }
                    },
                  "credential": null
                }
              ],
              "credentials": [],
              "password_history": []
            },
            {
              "access_account_name": "identity_validation_confirm_test_accnt",
              "external_name": "Identity Confirm Validation Test Account",
              "owning_owner_name": "owner2",
              "allow_global_logins": false,
              "access_account_state_name": "access_account_states_sysdef_active",
              "instance_access": [
                {
                  "instance_name": null,
                  "access_granted_days": -20,
                  "invitation_issued_days": -40,
                  "invitation_expires_days": -10,
                  "invitation_declined_days": null
                }
              ],
              "identities": [
                {
                  "identity_type_name": "identity_types_sysdef_email",
                  "account_identifier": "identity_validation_confirm_test_accnt@musesystems.com",
                  "account_identifier_length": null,
                  "validated_days": null,
                  "validation_requested_days": -1,
                  "identity_expires_days": null,
                  "validation": {
                    "identity": {
                        "account_identifier_length": 40,
                        "identity_expires_days": 1
                      },
                    "credential": {
                        "credential_plaintext": "Jt0hF7uCt6ILonJGxHhtxPchHKWzk3NjgLvaYXBF",
                        "credential_data": "$argon2id$v=19$m=65536,t=8,p=2$nMIKd72Q6sxDbTemdiWz8A$yJ1JgURszXZa1Db34twHlXvc9p0FZJxxxpUlN9DfS3o",
                        "last_updated_days": -10
                      }
                    },
                  "credential": null
                }
              ],
              "credentials": [],
              "password_history": []
            },
            {
              "access_account_name": "identity_validation_revoke_test_accnt",
              "external_name": "Identity Revoke Validation Test Account",
              "owning_owner_name": "owner2",
              "allow_global_logins": false,
              "access_account_state_name": "access_account_states_sysdef_active",
              "instance_access": [
                {
                  "instance_name": null,
                  "access_granted_days": -20,
                  "invitation_issued_days": -40,
                  "invitation_expires_days": -10,
                  "invitation_declined_days": null
                }
              ],
              "identities": [
                {
                  "identity_type_name": "identity_types_sysdef_email",
                  "account_identifier": "identity_validation_revoke_test_accnt@musesystems.com",
                  "account_identifier_length": null,
                  "validated_days": null,
                  "validation_requested_days": -1,
                  "identity_expires_days": null,
                  "validation": {
                    "identity": {
                        "account_identifier_length": 40,
                        "identity_expires_days": 1
                      },
                    "credential": {
                        "credential_plaintext": "RLOoCQHdMBKXCyYvF7wvJdaaqWSjJ3iw8QzKoRvR",
                        "credential_data": "$argon2id$v=19$m=65536,t=8,p=2$CYKpLJdNHn5zLpn7r4V17g$x2ZRkPeFRvVxBGpe6HfPqRcV+IDQjdU3D/ZbL5DdjA4",
                        "last_updated_days": -10
                      }
                    },
                  "credential": null
                }
              ],
              "credentials": [],
              "password_history": []
            },
            {
              "access_account_name": "identity_recovery_request_test_accnt",
              "external_name": "Identity Request Recovery Test Account",
              "owning_owner_name": "owner2",
              "allow_global_logins": false,
              "access_account_state_name": "access_account_states_sysdef_active",
              "instance_access": [
                {
                  "instance_name": null,
                  "access_granted_days": -20,
                  "invitation_issued_days": -40,
                  "invitation_expires_days": -10,
                  "invitation_declined_days": null
                }
              ],
              "identities": [
                {
                  "identity_type_name": "identity_types_sysdef_email",
                  "account_identifier": "identity_recovery_request_test_accnt@musesystems.com",
                  "account_identifier_length": null,
                  "validated_days": -15,
                  "validation_requested_days": -20,
                  "identity_expires_days": null,
                  "validation": null,
                  "credential": null
                }
              ],
              "credentials": [],
              "password_history": []
            },
            {
              "access_account_name": "identity_recovery_identify_test_accnt",
              "external_name": "Identity Identify Recovery Test Account",
              "owning_owner_name": "owner2",
              "allow_global_logins": false,
              "access_account_state_name": "access_account_states_sysdef_active",
              "instance_access": [
                {
                  "instance_name": null,
                  "access_granted_days": -20,
                  "invitation_issued_days": -40,
                  "invitation_expires_days": -10,
                  "invitation_declined_days": null
                }
              ],
              "identities": [
                {
                  "identity_type_name": "identity_types_sysdef_email",
                  "account_identifier": "identity_recovery_identify_test_accnt@musesystems.com",
                  "account_identifier_length": null,
                  "validated_days": -15,
                  "validation_requested_days": -20,
                  "identity_expires_days": null,
                  "validation": null,
                  "credential": null
                },
                {
                  "identity_type_name": "identity_types_sysdef_password_recovery",
                  "account_identifier": null,
                  "account_identifier_length": 40,
                  "validated_days": null,
                  "validation_requested_days": null,
                  "identity_expires_days": 1,
                  "validation": null,
                  "credential": {
                      "credential_type_name": "credential_types_sysdef_token_recovery",
                      "credential_plaintext": "IlfeZDnUjJYTx5RZwU2KofHALA5dCttFzREPauN2",
                      "credential_data": "$argon2id$v=19$m=65536,t=8,p=2$j6UoUu+BoYoh6ib3bNXCPw$lgGT0P/ccwiZ+BCf5pn/IxMyNO1EkSfTz4IYSZ5ozUI",
                      "last_updated_days": -10
                    }
                }
              ],
              "credentials": [],
              "password_history": []
            },
            {
              "access_account_name": "identity_recovery_identify_unowned_test_accnt",
              "external_name": "Identity Identify Unowned Recovery Test Account",
              "owning_owner_name": null,
              "allow_global_logins": false,
              "access_account_state_name": "access_account_states_sysdef_active",
              "instance_access": [
                {
                  "instance_name": null,
                  "access_granted_days": -20,
                  "invitation_issued_days": -40,
                  "invitation_expires_days": -10,
                  "invitation_declined_days": null
                }
              ],
              "identities": [
                {
                  "identity_type_name": "identity_types_sysdef_email",
                  "account_identifier": "identity_recovery_identify_unowned_test_accnt@musesystems.com",
                  "account_identifier_length": null,
                  "validated_days": -15,
                  "validation_requested_days": -20,
                  "identity_expires_days": null,
                  "validation": null,
                  "credential": null
                },
                {
                  "identity_type_name": "identity_types_sysdef_password_recovery",
                  "account_identifier": null,
                  "account_identifier_length": 40,
                  "validated_days": null,
                  "validation_requested_days": null,
                  "identity_expires_days": 1,
                  "validation": null,
                  "credential": {
                      "credential_type_name": "credential_types_sysdef_token_recovery",
                      "credential_plaintext": "sNvE0W76xzipySaWzvC7w320uqq0WDgKUarprbGR",
                      "credential_data": "$argon2id$v=19$m=65536,t=8,p=2$GPer4TJBid/JqbYNfi1xzg$KEUSEtI0YgTPdbPJZ3lftDBAVOkYb7AijJtZhI9VfZA",
                      "last_updated_days": -10
                    }
                }
              ],
              "credentials": [],
              "password_history": []
            },
            {
              "access_account_name": "identity_recovery_confirm_test_accnt",
              "external_name": "Identity Confirm Recovery Test Account",
              "owning_owner_name": "owner2",
              "allow_global_logins": false,
              "access_account_state_name": "access_account_states_sysdef_active",
              "instance_access": [
                {
                  "instance_name": null,
                  "access_granted_days": -20,
                  "invitation_issued_days": -40,
                  "invitation_expires_days": -10,
                  "invitation_declined_days": null
                }
              ],
              "identities": [
                {
                  "identity_type_name": "identity_types_sysdef_email",
                  "account_identifier": "identity_recovery_confirm_test_accnt@musesystems.com",
                  "account_identifier_length": null,
                  "validated_days": -15,
                  "validation_requested_days": -20,
                  "identity_expires_days": null,
                  "validation": null,
                  "credential": null
                },
                {
                  "identity_type_name": "identity_types_sysdef_password_recovery",
                  "account_identifier": null,
                  "account_identifier_length": 40,
                  "validated_days": null,
                  "validation_requested_days": null,
                  "identity_expires_days": 1,
                  "validation": null,
                  "credential": {
                      "credential_type_name": "credential_types_sysdef_token_recovery",
                      "credential_plaintext": "esxVkpEhfUe4ZJdH9oUu8kIkahihgpHeGdWTX5dW",
                      "credential_data": "$argon2id$v=19$m=65536,t=8,p=2$xFhIkMVaVjbZEIZ/eRwvkQ$5/zTrs6eTpPu9oRE4UxGKfaDWHeXFUWaGDMceh+mvFY",
                      "last_updated_days": -10
                    }
                }
              ],
              "credentials": [],
              "password_history": []
            },
            {
              "access_account_name": "identity_recovery_revoke_test_accnt",
              "external_name": "Identity Revoke Recovery Test Account",
              "owning_owner_name": null,
              "allow_global_logins": false,
              "access_account_state_name": "access_account_states_sysdef_active",
              "instance_access": [
                {
                  "instance_name": null,
                  "access_granted_days": -20,
                  "invitation_issued_days": -40,
                  "invitation_expires_days": -10,
                  "invitation_declined_days": null
                }
              ],
              "identities": [
                {
                  "identity_type_name": "identity_types_sysdef_email",
                  "account_identifier": "identity_recovery_revoke_test_accnt@musesystems.com",
                  "account_identifier_length": null,
                  "validated_days": -15,
                  "validation_requested_days": -20,
                  "identity_expires_days": null,
                  "validation": null,
                  "credential": null
                },
                {
                  "identity_type_name": "identity_types_sysdef_password_recovery",
                  "account_identifier": null,
                  "account_identifier_length": 40,
                  "validated_days": null,
                  "validation_requested_days": null,
                  "identity_expires_days": 1,
                  "validation": null,
                  "credential": {
                      "credential_type_name": "credential_types_sysdef_token_recovery",
                      "credential_plaintext": "TIWR3533FCirQhpnEeiY7qnag0e8mukTQKMXeUA2",
                      "credential_data": "$argon2id$v=19$m=65536,t=8,p=2$ua4Ry5BpkQrTUyB5FPoCyg$8jAzZGMRvACqtilv8yffZzIyC1OQq07J0gV0+uCIQ9g",
                      "last_updated_days": -10
                    }
                }
              ],
              "credentials": [],
              "password_history": []
            },
            {
              "access_account_name": "credential_api_token_create1_test_accnt",
              "external_name": "Credential API Token Create1 Test Account",
              "owning_owner_name": "owner2",
              "allow_global_logins": false,
              "access_account_state_name": "access_account_states_sysdef_active",
              "instance_access": [
                {
                  "instance_name": null,
                  "access_granted_days": -20,
                  "invitation_issued_days": -40,
                  "invitation_expires_days": -10,
                  "invitation_declined_days": null
                }
              ],
              "identities": [
                {
                  "identity_type_name": "identity_types_sysdef_email",
                  "account_identifier": "credential_api_token_create1_test_accnt@musesystems.com",
                  "account_identifier_length": null,
                  "validated_days": -15,
                  "validation_requested_days": -20,
                  "identity_expires_days": null,
                  "validation": null,
                  "credential": null
                },
                {
                  "identity_type_name": "identity_types_sysdef_api",
                  "account_identifier": null,
                  "account_identifier_length": 16,
                  "validated_days": null,
                  "validation_requested_days": null,
                  "identity_expires_days": 1,
                  "validation": null,
                  "credential": null
                }
              ],
              "credentials": [],
              "password_history": []
            },
            {
              "access_account_name": "credential_api_token_create2_test_accnt",
              "external_name": "Credential API Token Create2 Test Account",
              "owning_owner_name": "owner2",
              "allow_global_logins": false,
              "access_account_state_name": "access_account_states_sysdef_active",
              "instance_access": [
                {
                  "instance_name": null,
                  "access_granted_days": -20,
                  "invitation_issued_days": -40,
                  "invitation_expires_days": -10,
                  "invitation_declined_days": null
                }
              ],
              "identities": [
                {
                  "identity_type_name": "identity_types_sysdef_email",
                  "account_identifier": "credential_api_token_create2_test_accnt@musesystems.com",
                  "account_identifier_length": null,
                  "validated_days": -15,
                  "validation_requested_days": -20,
                  "identity_expires_days": null,
                  "validation": null,
                  "credential": null
                },
                {
                  "identity_type_name": "identity_types_sysdef_api",
                  "account_identifier": null,
                  "account_identifier_length": 16,
                  "validated_days": null,
                  "validation_requested_days": null,
                  "identity_expires_days": 1,
                  "validation": null,
                  "credential": null
                }
              ],
              "credentials": [],
              "password_history": []
            },
            {
              "access_account_name": "credential_api_token_create3_test_accnt",
              "external_name": "Credential API Token Create3 Test Account",
              "owning_owner_name": "owner2",
              "allow_global_logins": false,
              "access_account_state_name": "access_account_states_sysdef_active",
              "instance_access": [
                {
                  "instance_name": null,
                  "access_granted_days": -20,
                  "invitation_issued_days": -40,
                  "invitation_expires_days": -10,
                  "invitation_declined_days": null
                }
              ],
              "identities": [
                {
                  "identity_type_name": "identity_types_sysdef_email",
                  "account_identifier": "credential_api_token_create3_test_accnt@musesystems.com",
                  "account_identifier_length": null,
                  "validated_days": -15,
                  "validation_requested_days": -20,
                  "identity_expires_days": null,
                  "validation": null,
                  "credential": null
                },
                {
                  "identity_type_name": "identity_types_sysdef_api",
                  "account_identifier": null,
                  "account_identifier_length": 16,
                  "validated_days": null,
                  "validation_requested_days": null,
                  "identity_expires_days": 1,
                  "validation": null,
                  "credential": null
                }
              ],
              "credentials": [],
              "password_history": []
            },
            {
              "access_account_name": "credential_api_token_create4_test_accnt",
              "external_name": "Credential API Token Create4 Test Account",
              "owning_owner_name": "owner2",
              "allow_global_logins": false,
              "access_account_state_name": "access_account_states_sysdef_active",
              "instance_access": [
                {
                  "instance_name": null,
                  "access_granted_days": -20,
                  "invitation_issued_days": -40,
                  "invitation_expires_days": -10,
                  "invitation_declined_days": null
                }
              ],
              "identities": [
                {
                  "identity_type_name": "identity_types_sysdef_email",
                  "account_identifier": "credential_api_token_create4_test_accnt@musesystems.com",
                  "account_identifier_length": null,
                  "validated_days": -15,
                  "validation_requested_days": -20,
                  "identity_expires_days": null,
                  "validation": null,
                  "credential": null
                },
                {
                  "identity_type_name": "identity_types_sysdef_api",
                  "account_identifier": null,
                  "account_identifier_length": 16,
                  "validated_days": null,
                  "validation_requested_days": null,
                  "identity_expires_days": 1,
                  "validation": null,
                  "credential": null
                }
              ],
              "credentials": [],
              "password_history": []
            },
            {
              "access_account_name": "credential_api_token_delete_test_accnt",
              "external_name": "Credential API Token delete Test Account",
              "owning_owner_name": null,
              "allow_global_logins": false,
              "access_account_state_name": "access_account_states_sysdef_active",
              "instance_access": [
                {
                  "instance_name": null,
                  "access_granted_days": -20,
                  "invitation_issued_days": -40,
                  "invitation_expires_days": -10,
                  "invitation_declined_days": null
                }
              ],
              "identities": [
                {
                  "identity_type_name": "identity_types_sysdef_email",
                  "account_identifier": "credential_api_token_delete_test_accnt@musesystems.com",
                  "account_identifier_length": null,
                  "validated_days": -15,
                  "validation_requested_days": -20,
                  "identity_expires_days": null,
                  "validation": null,
                  "credential": null
                },
                {
                  "identity_type_name": "identity_types_sysdef_api",
                  "account_identifier": null,
                  "account_identifier_length": 16,
                  "validated_days": null,
                  "validation_requested_days": null,
                  "identity_expires_days": 1,
                  "validation": null,
                  "credential": {
                      "credential_type_name": "credential_types_sysdef_token_api",
                      "credential_plaintext": "m9n8hjd12GoElonrbSNwuHo6pTzSuKlOB3vXQPoo6jwZ73CB",
                      "credential_data": "$argon2id$v=19$m=65536,t=8,p=2$/0lP+TC+lrcnymLlez2f1Q$5SnuizyihWEMHvIIzDz3GU/ylmEaWfY2F+FVSZKFiFk",
                      "last_updated_days": -10
                    }
                }
              ],
              "credentials": [],
              "password_history": []
            },
            {
              "access_account_name": "credential_api_token_delete_id_test_accnt",
              "external_name": "Credential API Token delete ID Test Account",
              "owning_owner_name": null,
              "allow_global_logins": false,
              "access_account_state_name": "access_account_states_sysdef_active",
              "instance_access": [
                {
                  "instance_name": null,
                  "access_granted_days": -20,
                  "invitation_issued_days": -40,
                  "invitation_expires_days": -10,
                  "invitation_declined_days": null
                }
              ],
              "identities": [
                {
                  "identity_type_name": "identity_types_sysdef_email",
                  "account_identifier": "credential_api_token_delete_id_test_accnt@musesystems.com",
                  "account_identifier_length": null,
                  "validated_days": -15,
                  "validation_requested_days": -20,
                  "identity_expires_days": null,
                  "validation": null,
                  "credential": null
                },
                {
                  "identity_type_name": "identity_types_sysdef_api",
                  "account_identifier": null,
                  "account_identifier_length": 16,
                  "validated_days": null,
                  "validation_requested_days": null,
                  "identity_expires_days": 1,
                  "validation": null,
                  "credential": {
                      "credential_type_name": "credential_types_sysdef_token_api",
                      "credential_plaintext": "t53eMYBTSUUX846j2EPu7e8EPVE3zw30AQSlaZoDTLIB0b4k",
                      "credential_data": "$argon2id$v=19$m=65536,t=8,p=2$+51I/mOJNUVNC6U1oQeBOQ$oRyNPBrxDk7KUn3dOTSRtsILm5hGmaQlwspjG+Xl6yk",
                      "last_updated_days": -10
                    }
                }
              ],
              "credentials": [],
              "password_history": []
            },
            {
              "access_account_name": "example_purge_accnt",
              "external_name": "Example Purge Account",
              "owning_owner_name": null,
              "allow_global_logins": false,
              "access_account_state_name": "access_account_states_sysdef_purge_eligible",
              "instance_access": [
                {
                  "instance_name": null,
                  "access_granted_days": -20,
                  "invitation_issued_days": -40,
                  "invitation_expires_days": -10,
                  "invitation_declined_days": null
                }
              ],
              "identities": [
                {
                  "identity_type_name": "identity_types_sysdef_email",
                  "account_identifier": "example_purge_accnt@musesystems.com",
                  "account_identifier_length": null,
                  "validated_days": -15,
                  "validation_requested_days": -20,
                  "identity_expires_days": null,
                  "validation": null,
                  "credential": null
                },
                {
                  "identity_type_name": "identity_types_sysdef_api",
                  "account_identifier": null,
                  "account_identifier_length": 16,
                  "validated_days": null,
                  "validation_requested_days": null,
                  "identity_expires_days": 1,
                  "validation": null,
                  "credential": {
                      "credential_type_name": "credential_types_sysdef_token_api",
                      "credential_plaintext": "HZgRmnCwJ0ND8uKynUUodg41jWf8fe7Y28MWAeSGr3yksdMs",
                      "credential_data": "$argon2id$v=19$m=65536,t=8,p=2$TYuXhFE8ummSK7wdPhrprQ$1ASZF0VWX3w7c5TobSZRooZonRDpjxvaMF1Sz+0wvIA",
                      "last_updated_days": -10
                    }
                }
              ],
              "credentials": [],
              "password_history": []
            },
            {
              "access_account_name": "example_accnt",
              "external_name": "Example Account",
              "owning_owner_name": null,
              "allow_global_logins": false,
              "access_account_state_name": "access_account_states_sysdef_purge_eligible",
              "instance_access": [
                {
                  "instance_name": null,
                  "access_granted_days": -20,
                  "invitation_issued_days": -40,
                  "invitation_expires_days": -10,
                  "invitation_declined_days": null
                }
              ],
              "identities": [
                {
                  "identity_type_name": "identity_types_sysdef_email",
                  "account_identifier": "example_accnt@musesystems.com",
                  "account_identifier_length": null,
                  "validated_days": -15,
                  "validation_requested_days": -20,
                  "identity_expires_days": null,
                  "validation": null,
                  "credential": null
                },
                {
                  "identity_type_name": "identity_types_sysdef_api",
                  "account_identifier": null,
                  "account_identifier_length": 16,
                  "validated_days": null,
                  "validation_requested_days": null,
                  "identity_expires_days": 1,
                  "validation": null,
                  "credential": {
                      "credential_type_name": "credential_types_sysdef_token_api",
                      "credential_plaintext": "J7RJY39PCI2CJ2P6BWSRA98XFG5SAZ0PIMTELMGLCC3X5PYD",
                      "credential_data": "$argon2id$v=19$m=65536,t=8,p=2$IMiQN/YlkA+g20mMgsKV1w$/WP/6UFwnxo46oR4nN6/5MqncIu4JAsnRyCnkoiLS/I",
                      "last_updated_days": -10
                    }
                }
              ],
              "credentials": [
                {
                  "credential_type_name": "credential_types_sysdef_password",
                  "credential_plaintext": "example.test.password",
                  "credential_data": "$argon2id$v=19$m=65536,t=8,p=2$0n4sdMLjE7IeQNmR1YfFgg$BzujLUJVkKVvAH6LA8yKuqtGRd00qZN5iQTgskFHhxY",
                  "last_updated_days": -1
                }
              ],
              "password_history": []
            }
          ]
        }
        $TEST_DATA_DEFINTION$;

        /**********************************************************************
         **
         **  Test Data Creation
         **
         **********************************************************************/

        ----------------------------------------------------
        -- Disallowed Passwords
        ----------------------------------------------------

        INSERT INTO msbms_syst_data.syst_disallowed_passwords
            ( password_hash )
        SELECT
            digest( password, 'sha1' )
        FROM jsonb_array_elements_text( var_data -> 'disallowed_passwords' ) password;

        ----------------------------------------------------
        -- Disallowed Hosts
        ----------------------------------------------------

        INSERT INTO msbms_syst_data.syst_disallowed_hosts
            ( host_address )
        SELECT
            ip_addr::inet
        FROM jsonb_array_elements_text( var_data -> 'disallowed_hosts' ) ip_addr;

        ----------------------------------------------------
        -- Owner Password Rules
        ----------------------------------------------------

        INSERT INTO msbms_syst_data.syst_owner_password_rules
            ( owner_id
            , password_length
            , max_age
            , require_upper_case
            , require_lower_case
            , require_numbers
            , require_symbols
            , disallow_recently_used
            , disallow_compromised
            , require_mfa
            , allowed_mfa_types )
        SELECT
            o.id
          , int4range( ( opr #>> '{password_length, lower}' )::integer,
                       ( opr #>> '{password_length, upper}' )::integer,
                       opr #>> '{password_length, inclusion}' )
          , make_interval( days => ( opr ->> 'max_age_days' )::integer )
          , ( opr ->> 'require_upper_case' )::integer
          , ( opr ->> 'require_lower_case' )::integer
          , ( opr ->> 'require_numbers' )::integer
          , ( opr ->> 'require_symbols' )::integer
          , ( opr ->> 'disallow_recently_used' )::integer
          , ( opr ->> 'disallow_compromised' )::boolean
          , ( opr ->> 'require_mfa' )::boolean
          , array( SELECT jsonb_array_elements_text( opr -> 'allowed_mfa_types' ) )
        FROM jsonb_array_elements( var_data -> 'owner_password_rules' ) opr
            JOIN msbms_syst_data.syst_owners o ON o.internal_name = opr ->> 'owner_name';

        ----------------------------------------------------
        -- Network Rules
        ----------------------------------------------------

        INSERT INTO msbms_syst_data.syst_global_network_rules
            (
              template_rule
            , ordering
            , functional_type
            , ip_host_or_network
            , ip_host_range_lower
            , ip_host_range_upper
            )
        SELECT
              (gnr ->> 'template_rule')::boolean
            , (gnr ->> 'ordering')::integer
            , gnr ->> 'functional_type'
            , (gnr ->> 'ip_host_or_network')::inet
            , (gnr ->> 'ip_host_range_lower')::inet
            , (gnr ->> 'ip_host_range_upper')::inet
        FROM jsonb_array_elements( var_data -> 'global_network_rules' ) gnr;

        INSERT INTO msbms_syst_data.syst_owner_network_rules
            (
              owner_id
            , ordering
            , functional_type
            , ip_host_or_network
            , ip_host_range_lower
            , ip_host_range_upper
            )
        SELECT
              o.id
            , (onr ->> 'ordering')::integer
            , onr ->> 'functional_type'
            , (onr ->> 'ip_host_or_network')::inet
            , (onr ->> 'ip_host_range_lower')::inet
            , (onr ->> 'ip_host_range_upper')::inet
        FROM jsonb_array_elements( var_data -> 'owner_network_rules' ) onr
            JOIN msbms_syst_data.syst_owners o ON o.internal_name = onr ->> 'owner_name';

        INSERT INTO msbms_syst_data.syst_owner_network_rules
            ( owner_id
            , ordering
            , functional_type
            , ip_host_or_network
            , ip_host_range_lower
            , ip_host_range_upper )
        SELECT
            o.id
          , ( onr ->> 'ordering' )::integer
          , onr ->> 'functional_type'
          , ( onr ->> 'ip_host_or_network' )::inet
          , ( onr ->> 'ip_host_range_lower' )::inet
          , ( onr ->> 'ip_host_range_upper' )::inet
        FROM  jsonb_path_query( var_data, '$.owner_network_rules[*] ? (@.owner_name == null)' ) onr
            CROSS JOIN msbms_syst_data.syst_owners o
        WHERE o.id NOT IN (SELECT owner_id FROM msbms_syst_data.syst_owner_network_rules);

        INSERT INTO msbms_syst_data.syst_instance_network_rules
            ( instance_id
            , ordering
            , functional_type
            , ip_host_or_network
            , ip_host_range_lower
            , ip_host_range_upper )
        SELECT
            i.id
          , ( inr ->> 'ordering' )::integer
          , inr ->> 'functional_type'
          , ( inr ->> 'ip_host_or_network' )::inet
          , ( inr ->> 'ip_host_range_lower' )::inet
          , ( inr ->> 'ip_host_range_upper' )::inet
        FROM jsonb_array_elements( var_data -> 'instance_network_rules' ) inr
            JOIN msbms_syst_data.syst_instances i ON i.internal_name = inr ->> 'instance_name';

        INSERT INTO msbms_syst_data.syst_instance_network_rules
            ( instance_id
            , ordering
            , functional_type
            , ip_host_or_network
            , ip_host_range_lower
            , ip_host_range_upper )
        SELECT
            i.id
          , ( inr ->> 'ordering' )::integer
          , inr ->> 'functional_type'
          , ( inr ->> 'ip_host_or_network' )::inet
          , ( inr ->> 'ip_host_range_lower' )::inet
          , ( inr ->> 'ip_host_range_upper' )::inet
        FROM  jsonb_path_query( var_data, '$.instance_network_rules[*] ? (@.instance_name == null)' ) inr
            CROSS JOIN msbms_syst_data.syst_instances i
        WHERE i.id NOT IN (SELECT instance_id FROM msbms_syst_data.syst_instance_network_rules);

        ----------------------------------------------------
        -- Access Account Processing
        ----------------------------------------------------

        << access_account_creation >>
        DECLARE
            var_account_data           record;
            var_access_account_id      uuid;

            var_identity_data          record;
            var_primary_identity_id    uuid;
            var_validation_identity_id uuid;

            var_credential_data        record;

        BEGIN

            << access_account_loop >>
            FOR var_account_data IN
                SELECT
                    aa ->> 'access_account_name'              AS access_account_name
                  , aa ->> 'external_name'                    AS external_name
                  , o.internal_name                           AS owning_owner_name
                  , o.id                                      AS owning_owner_id
                  , ( aa ->> 'allow_global_logins' )::boolean AS allow_global_logins
                  , ei.id                                     AS access_account_state_id
                  , aa -> 'instance_access'                   AS instance_access
                  , aa -> 'identities'                        AS identities
                  , aa -> 'credentials'                       AS credentials
                  , aa -> 'password_history'                  AS password_history
                FROM jsonb_array_elements( var_data -> 'access_accounts' ) aa
                    JOIN msbms_syst_data.syst_enum_items ei
                        ON ei.internal_name = aa ->> 'access_account_state_name'
                    LEFT JOIN msbms_syst_data.syst_owners o
                        ON o.internal_name = aa ->> 'owning_owner_name'
            LOOP

                ----------------------------------------------------
                -- Access Accounts
                ----------------------------------------------------

                INSERT INTO msbms_syst_data.syst_access_accounts
                    ( internal_name
                    , external_name
                    , owning_owner_id
                    , allow_global_logins
                    , access_account_state_id )
                VALUES
                    ( var_account_data.access_account_name
                    , var_account_data.external_name
                    , var_account_data.owning_owner_id
                    , var_account_data.allow_global_logins
                    , var_account_data.access_account_state_id)
                RETURNING id INTO var_access_account_id;

                ----------------------------------------------------
                -- Access Account Instance Access
                ----------------------------------------------------

                INSERT INTO msbms_syst_data.syst_access_account_instance_assocs
                    ( access_account_id
                    , instance_id
                    , access_granted
                    , invitation_issued
                    , invitation_expires
                    , invitation_declined )
                SELECT
                      aa.id
                    , i.id
                    , now() + make_interval( days => ( ia ->> 'access_granted_days' )::integer )
                    , now() + make_interval( days => ( ia ->> 'invitation_issued_days' )::integer )
                    , now() + make_interval( days => ( ia ->> 'invitation_expires_days' )::integer )
                    , now() + make_interval( days => ( ia ->> 'invitation_declined_days' )::integer )
                FROM jsonb_array_elements( var_account_data.instance_access ) ia
                    JOIN msbms_syst_data.syst_access_accounts aa
                        ON aa.internal_name = var_account_data.access_account_name
                    JOIN msbms_syst_data.syst_instances i
                        ON i.internal_name = ia ->> 'instance_name';

                INSERT INTO msbms_syst_data.syst_access_account_instance_assocs
                    ( access_account_id
                    , instance_id
                    , access_granted
                    , invitation_issued
                    , invitation_expires
                    , invitation_declined )
                SELECT
                      aa.id
                    , i.id
                    , now() + make_interval( days => ( ia ->> 'access_granted_days' )::integer )
                    , now() + make_interval( days => ( ia ->> 'invitation_issued_days' )::integer )
                    , now() + make_interval( days => ( ia ->> 'invitation_expires_days' )::integer )
                    , now() + make_interval( days => ( ia ->> 'invitation_declined_days' )::integer )
                FROM jsonb_array_elements( var_account_data.instance_access ) ia
                    JOIN msbms_syst_data.syst_access_accounts aa
                        ON aa.internal_name = var_account_data.access_account_name
                    CROSS JOIN msbms_syst_data.syst_instances i
                WHERE i.id NOT IN (SELECT instance_id
                                   FROM msbms_syst_data.syst_access_account_instance_assocs
                                   WHERE access_account_id = var_access_account_id)
                  AND ( i.owner_id = aa.owning_owner_id or
                        coalesce( ( ia ->> 'no_owner_restriction' )::boolean, FALSE ) );

                ----------------------------------------------------
                -- Access Account Identities
                ----------------------------------------------------

                << access_account_identities_loop >>
                FOR var_identity_data IN
                    SELECT
                        i ->> 'identity_type_name'                                       AS identity_type_name
                      , ei.id                                                            AS identity_type_id
                      , coalesce( i ->> 'account_identifier',
                                  msbms_syst_priv.get_random_string(
                                      ( i ->> 'account_identifier_length' )::integer ) ) AS account_identifier
                      , now( ) +
                        make_interval(
                            days => ( i ->> 'validated_days' )::integer )                AS validated
                      , now( ) +
                        make_interval(
                            days => ( i ->> 'validation_requested_days' )::integer )     AS validation_requested
                      , now( ) +
                        make_interval(
                            days => ( i ->> 'identity_expires_days' )::integer )         AS identity_expires
                      , i -> 'validation'                                                AS validation
                      , i -> 'credential'                                                AS credential
                    FROM jsonb_array_elements( var_account_data.identities ) i
                        JOIN msbms_syst_data.syst_enum_items ei
                             ON ei.internal_name = i ->> 'identity_type_name'
                LOOP

                    ----------------------------------------------------
                    -- Identities
                    ----------------------------------------------------

                    INSERT INTO msbms_syst_data.syst_identities
                        ( access_account_id
                        , identity_type_id
                        , account_identifier
                        , validated
                        , validation_requested
                        , identity_expires)
                    VALUES
                        ( var_access_account_id
                        , var_identity_data.identity_type_id
                        , var_identity_data.account_identifier
                        , var_identity_data.validated
                        , var_identity_data.validation_requested
                        , var_identity_data.identity_expires )
                    RETURNING id INTO var_primary_identity_id;

                    ----------------------------------------------------
                    -- Identity Linked Credential
                    ----------------------------------------------------

                    IF jsonb_typeof(var_identity_data.credential) = 'object' THEN

                        INSERT INTO msbms_syst_data.syst_credentials
                            ( access_account_id
                            , credential_type_id
                            , credential_for_identity_id
                            , credential_data
                            , last_updated )
                        VALUES
                            ( var_access_account_id
                            , (SELECT id
                               FROM msbms_syst_data.syst_enum_items
                               WHERE internal_name = var_identity_data.credential ->> 'credential_type_name' )
                            , var_primary_identity_id
                            , var_identity_data.credential ->> 'credential_data'
                            , now() +
                              make_interval(
                                  days =>
                                      coalesce(
                                          ( var_identity_data.credential ->> 'last_updated_days' )::integer,
                                          0) ) );

                    END IF;

                    ----------------------------------------------------
                    -- Identity Linked Validation Identity/Credential
                    ----------------------------------------------------

                    IF jsonb_typeof(var_identity_data.validation) = 'object' THEN

                        INSERT INTO msbms_syst_data.syst_identities
                            ( access_account_id
                            , identity_type_id
                            , account_identifier
                            , validates_identity_id
                            , identity_expires )
                        VALUES
                            ( var_access_account_id
                            , ( SELECT
                                    id
                                FROM msbms_syst_data.syst_enum_items
                                WHERE internal_name = 'identity_types_sysdef_validation' )
                            , coalesce( var_identity_data.validation #>>
                                            '{identity, account_identifier}',
                                        msbms_syst_priv.get_random_string(
                                            ( var_identity_data.validation #>>
                                              '{identity, account_identifier_length}' )::integer ) )
                            , var_primary_identity_id
                            , now( ) +
                              make_interval(
                                  days => ( var_identity_data.validation #>>
                                            '{identity, identity_expires_days}' )::integer ) )
                        RETURNING id INTO var_validation_identity_id;

                        INSERT INTO msbms_syst_data.syst_credentials
                            ( access_account_id
                            , credential_type_id
                            , credential_for_identity_id
                            , credential_data
                            , last_updated )
                        VALUES
                            ( var_access_account_id
                            , ( SELECT
                                    id
                                FROM msbms_syst_data.syst_enum_items
                                WHERE internal_name = 'credential_types_sysdef_token_validation' )
                            , var_validation_identity_id
                            , var_identity_data.validation #>> '{credential, credential_data}'
                            , now( ) +
                              make_interval(
                                  days => coalesce(
                                      ( var_identity_data.validation #>>
                                        '{credential, last_updated_days}' )::integer,
                                      0 ) ) );

                    END IF;

                END LOOP access_account_identities_loop;

                ----------------------------------------------------
                -- Non-linked Credentials
                ----------------------------------------------------

                INSERT INTO msbms_syst_data.syst_credentials
                    ( access_account_id
                    , credential_type_id
                    , credential_data
                    , last_updated )
                SELECT
                      var_access_account_id
                    , ei.id
                    , c ->> 'credential_data'
                    , now( ) +
                      make_interval( days => coalesce( ( c ->> 'last_updated_days' )::integer, 0 ) )
                FROM jsonb_array_elements( var_account_data.credentials ) c
                    JOIN msbms_syst_data.syst_enum_items ei
                         ON ei.internal_name = c ->> 'credential_type_name';

                ----------------------------------------------------
                -- Password History
                ----------------------------------------------------

                INSERT INTO msbms_syst_data.syst_password_history
                    (access_account_id, credential_data )
                SELECT
                      var_access_account_id
                    , credential_data
                FROM jsonb_array_elements_text( var_account_data.password_history ) credential_data;

            END LOOP access_account_loop;

        END access_account_creation;

    END;
$AUTHENTICATION_TESTING_INIT$;
