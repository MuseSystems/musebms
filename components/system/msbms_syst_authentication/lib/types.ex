# Source File: types.ex
# Location:    musebms/components/system/msbms_syst_authentication/lib/types.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MsbmsSystAuthentication.Types do
  alias MsbmsSystAuthentication.Data
  alias MsbmsSystDatastore.DbTypes

  #
  # Note that the ordering of typespecs here is alphabetical.
  #

  @moduledoc """
  Types used by the Authentication module.
  """

  @type access_account_id() :: Ecto.UUID.t()

  @type access_account_instance_assoc_id() :: Ecto.UUID.t()

  @type access_account_instance_assoc_params() :: %{
          optional(:access_account_id) => access_account_id(),
          optional(:access_account_name) => access_account_name(),
          optional(:instance_id) => MsbmsSystInstanceMgr.Types.instance_id(),
          optional(:instance_name) => MsbmsSystInstanceMgr.Types.instance_name(),
          optional(:access_granted) => DateTime.t(),
          optional(:invitation_issued) => DateTime.t(),
          optional(:invitation_expires) => DateTime.t(),
          optional(:invitation_declined) => DateTime.t()
        }

  @type access_account_name() :: String.t()

  @type access_account_params() :: %{
          optional(:internal_name) => access_account_name(),
          optional(:external_name) => String.t(),
          optional(:owning_owner_id) => MsbmsSystInstanceMgr.Types.owner_id(),
          optional(:owning_owner_name) => MsbmsSystInstanceMgr.Types.owner_name(),
          optional(:allow_global_logins) => boolean(),
          optional(:access_account_state_id) => access_account_state_id(),
          optional(:access_account_state_name) => access_account_name()
        }

  @type access_account_state_id() :: MsbmsSystEnums.Types.enum_item_id()

  @type access_account_state_name() :: MsbmsSystEnums.Types.enum_item_name()

  @type account_identifier() :: String.t()

  @type applied_network_rule() :: %{
          required(:precedence) => network_rule_precedence(),
          required(:network_rule_id) => Ecto.UUID.t() | nil,
          required(:functional_type) => network_rule_functional_type()
        }

  @type authentication_extended_operations() ::
          :require_mfa | :require_mfa_setup | :require_instance | :require_credential_reset

  @type authentication_operations() ::
          :check_global_network_rules
          | :check_identifier_rate_limit
          | :check_identity
          | :check_credential
          | :check_instance
          | :check_instance_network_rules
          | :check_host_rate_limit
          | authentication_extended_operations()

  @type authentication_state() :: %{
          required(:status) => authentication_status(),
          required(:access_account_id) => access_account_id() | nil,
          required(:instance_id) => MsbmsSystInstanceMgr.Types.instance_id() | nil,
          required(:identity_type_id) => identity_type_id(),
          required(:host_address) => host_address(),
          required(:applied_network_rule) => applied_network_rule() | nil,
          required(:pending_operations) => list(authentication_operations()),
          optional(:identifier) => account_identifier(),
          optional(:plaintext_credential) => credential(),
          optional(:owning_owner_id) => MsbmsSystInstanceMgr.Types.owner_id() | nil,
          optional(:identity_id) => identity_id(),
          optional(:identity) => Data.SystIdentities.t(),
          optional(:reset_reason) => credential_reset_reason()
        }

  @type authentication_status() ::
          :not_started
          | :pending
          | :rejected_host_check
          | :rejected_rate_limited
          | :rejected_validation
          | :rejected_identity_expired
          | :rejected
          | :authenticated

  @type credential() :: String.t()

  @type credential_id() :: Ecto.UUID.t()

  @type credential_params() :: %{
          optional(:access_account_id) => access_account_id(),
          optional(:access_account_name) => access_account_name(),
          optional(:credential_type_id) => credential_type_id(),
          optional(:credential_type_name) => credential_type_name(),
          optional(:credential_for_identity_id) => identity_id(),
          optional(:credential_data) => binary()
        }

  @type credential_confirm_result() ::
          {credential_confirm_state(), list(credential_extended_state())}

  @type credential_confirm_state() :: :confirmed | :no_credential | :wrong_credential

  @type credential_extended_state() :: :require_mfa | credential_reset_reason()

  @type credential_reset_reason() :: :reset_forced | :reset_age | :reset_disallowed

  @type credential_set_failures() :: {:invalid_credential, Keyword.t()}

  @type credential_type_id() :: MsbmsSystEnums.Types.enum_item_id()

  @type credential_type_name() :: MsbmsSystEnums.Types.enum_item_name()

  @type credential_types() ::
          :credential_types_sysdef_password
          | :credential_types_sysdef_mfa_totp
          | :credential_types_sysdef_mfa_totp_recovery_code
          | :credential_types_sysdef_mfa_known_host
          | :credential_types_sysdef_token_api
          | :credential_types_sysdef_token_validation
          | :credential_types_sysdef_token_recovery

  @type disallowed_host_id() :: Ecto.UUID.t()

  @type global_network_rule_params() :: %{
          optional(:ordering) => pos_integer(),
          optional(:functional_type) => String.t(),
          optional(:ip_host_or_network) => DbTypes.Inet.t(),
          optional(:ip_host_range_lower) => DbTypes.Inet.t(),
          optional(:ip_host_range_upper) => DbTypes.Inet.t()
        }

  @type host_address() :: IP.addr()

  @type identity_id() :: Ecto.UUID.t()

  @type identity_type_id() :: MsbmsSystEnums.Types.enum_item_id()

  @type identity_type_name() :: MsbmsSystEnums.Types.enum_item_name()

  @type identity_types() ::
          :identity_types_sysdef_email
          | :identity_types_sysdef_account
          | :identity_types_sysdef_api
          | :identity_types_sysdef_validation
          | :identity_types_sysdef_password_recovery

  @type identity_params() :: %{
          optional(:access_account_id) => access_account_id(),
          optional(:access_account_name) => access_account_name(),
          optional(:identity_type_id) => identity_type_name(),
          optional(:identity_type_name) => identity_type_name(),
          optional(:account_identifier) => account_identifier(),
          optional(:validated) => DateTime.t() | nil,
          optional(:validates_identity_id) => identity_id() | nil,
          optional(:validation_requested) => DateTime.t() | nil,
          optional(:identity_expires) => DateTime.t() | nil,
          optional(:external_name) => String.t() | nil
        }

  @type instance_network_rule_params() ::
          %{
            optional(:instance_id) => MsbmsSystInstanceMgr.Types.instance_id(),
            optional(:instance_name) => MsbmsSystInstanceMgr.Types.instance_name(),
            optional(:ordering) => pos_integer(),
            optional(:functional_type) => String.t(),
            optional(:ip_host_or_network) => DbTypes.Inet.t(),
            optional(:ip_host_range_lower) => DbTypes.Inet.t(),
            optional(:ip_host_range_upper) => DbTypes.Inet.t()
          }
          | nil

  @type network_rule_functional_type() :: :allow | :deny

  @type network_rule_precedence() ::
          :disallowed | :global | :instance | :instance_owner | :implied

  @type owner_network_rule_params() :: %{
          optional(:owner_id) => MsbmsSystInstanceMgr.Types.owner_id(),
          optional(:owner_name) => MsbmsSystInstanceMgr.Types.owner_name(),
          optional(:ordering) => pos_integer(),
          optional(:functional_type) => String.t(),
          optional(:ip_host_or_network) => DbTypes.Inet.t(),
          optional(:ip_host_range_lower) => DbTypes.Inet.t(),
          optional(:ip_host_range_upper) => DbTypes.Inet.t()
        }

  @type password_rule() :: %{
          optional(:access_account_id) => access_account_id() | nil,
          optional(:owner_id) => MsbmsSystInstanceMgr.Types.owner_id() | nil,
          optional(:password_length) => DbTypes.IntegerRange.t(),
          optional(:max_age) => DbTypes.Interval.t(),
          optional(:require_upper_case) => non_neg_integer(),
          optional(:require_lower_case) => non_neg_integer(),
          optional(:require_numbers) => non_neg_integer(),
          optional(:require_symbols) => non_neg_integer(),
          optional(:disallow_recently_used) => non_neg_integer(),
          optional(:disallow_compromised) => boolean(),
          optional(:require_mfa) => boolean(),
          optional(:allowed_mfa_types) => list(String.t())
        }

  @type password_rule_params() :: %{
          optional(:owner_id) => MsbmsSystInstanceMgr.Types.owner_id() | nil,
          optional(:owner_name) => MsbmsSystInstanceMgr.Types.owner_name() | nil,
          optional(:password_length) => DbTypes.IntegerRange.t(),
          optional(:max_age) => DbTypes.Interval.t(),
          optional(:require_upper_case) => non_neg_integer(),
          optional(:require_lower_case) => non_neg_integer(),
          optional(:require_numbers) => non_neg_integer(),
          optional(:require_symbols) => non_neg_integer(),
          optional(:disallow_recently_used) => non_neg_integer(),
          optional(:disallow_compromised) => boolean(),
          optional(:require_mfa) => boolean(),
          optional(:allowed_mfa_types) => list(String.t())
        }

  @type password_rule_violations() ::
          {:password_rule_length_min, pos_integer()}
          | {:password_rule_length_max, pos_integer()}
          | {:password_rule_required_upper, pos_integer()}
          | {:password_rule_required_lower, pos_integer()}
          | {:password_rule_required_numbers, pos_integer()}
          | {:password_rule_required_symbols, pos_integer()}
          | {:password_rule_disallowed_password, true}
          | {:password_rule_recent_password, true}
end
