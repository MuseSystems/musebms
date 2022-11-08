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

  @type authenticator_result() :: %{
          required(:access_account_id) => access_account_id(),
          optional(:account_identifier) => account_identifier(),
          optional(:credential) => credential(),
          optional(:validation_identifier) => account_identifier() | nil,
          optional(:validation_credential) => credential_id() | nil
        }

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

  @typedoc """
  Defines the available parameters for use in creating or updating Global
  Network Rule records.

  ## Map Attributes

    * `ordering` - the order in which the new record should apply relative to
    other Global Network Rule records.  lower `ordering` values take precedence
    over higher `ordering` values.  If the `ordering` value in the parameters
    matches the `ordering` value of an existing Global Network Rule record, the
    inserted record will be treated as an "insert before" record, with the
    existing records being reordered to be after the new record, recursively.
    This attribute is required in record creation scenarios.

    * `functional_type` - defines what action the rule specifies once matched.
    The possible functional types are `:allow` which means the rule intends to
    explicitly allow the associated IP Address(es) to attempt authentication
    or `:deny` which explicitly prevents the IP Address(es) from attempting
    an authorization.  This attribute is required in record creation scenarios.

    * `ip_host_or_network` - a single Host IP Address or a single CIDR network
    used in matching user Host IP Addresses to rules.  Note that if this value
    is provided that the `ip_host_range_lower` and `ip_host_range_upper`
    values must be nil or not provided.

    * `ip_host_range_lower` - defines the lower bound of a simple range of IP
    Addresses, inclusive, to which rule should apply.  When this value is
    provided the `ip_host_range_upper` attribute must also be provided and the
    `ip_host_or_network` attribute value must be nil or not provided.

    * `ip_host_range_upper` - defines the upper bound of a simple range of IP
    Addresses, inclusive, to which rule should apply.  When this value is
    provided the `ip_host_range_lower` attribute must also be provided and the
    `ip_host_or_network` attribute value must be nil or not provided.

  Note that either the `ip_host_or_network` attribute or the
  `ip_host_range_lower` and `ip_host_range_upper` are required and exclusive.
  """
  @type global_network_rule_params() :: %{
          optional(:ordering) => pos_integer(),
          optional(:functional_type) => network_rule_functional_type() | String.t(),
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

  @typedoc """
  Defines the available parameters for use in creating or updating Instance
  Network Rule records.

  ## Map Attributes

    * `instance_id` - the value of this attribute identifies the Instance for
    which the Network Rule is being defined.  This value doesn't have to be set
    explicitly when using the `MsbmsSystAuthentication` module API as the API
    calls set this value based on the function `instance_id` parameters they
    require.

    * `instance_name` - an alternate means of identifying the Instance instead
    of the `instance_id` attribute.   Currently there is no API which makes use
    of this value.

    * `ordering` - the order in which the new record should apply relative to
    other Instance Network Rule records.  lower `ordering` values take
    precedence over higher `ordering` values.  If the `ordering` value in the
    parameters matches the `ordering` value of an existing Instance Network Rule
    record, the inserted record will be treated as an "insert before" record,
    with the existing records being reordered to be after the new record,
    recursively. This attribute is required in record creation scenarios.

    * `functional_type` - defines what action the rule specifies once matched.
    The possible functional types are `:allow` which means the rule intends to
    explicitly allow the associated IP Address(es) to attempt authentication
    or `:deny` which explicitly prevents the IP Address(es) from attempting
    an authorization.  This attribute is required in record creation scenarios.

    * `ip_host_or_network` - a single Host IP Address or a single CIDR network
    used in matching user Host IP Addresses to rules.  Note that if this value
    is provided that the `ip_host_range_lower` and `ip_host_range_upper`
    values must be nil or not provided.

    * `ip_host_range_lower` - defines the lower bound of a simple range of IP
    Addresses, inclusive, to which rule should apply.  When this value is
    provided the `ip_host_range_upper` attribute must also be provided and the
    `ip_host_or_network` attribute value must be nil or not provided.

    * `ip_host_range_upper` - defines the upper bound of a simple range of IP
    Addresses, inclusive, to which rule should apply.  When this value is
    provided the `ip_host_range_lower` attribute must also be provided and the
    `ip_host_or_network` attribute value must be nil or not provided.

  Note that either the `ip_host_or_network` attribute or the
  `ip_host_range_lower` and `ip_host_range_upper` are required and exclusive.
  """
  @type instance_network_rule_params() ::
          %{
            optional(:instance_id) => MsbmsSystInstanceMgr.Types.instance_id(),
            optional(:instance_name) => MsbmsSystInstanceMgr.Types.instance_name(),
            optional(:ordering) => pos_integer(),
            optional(:functional_type) => network_rule_functional_type() | String.t(),
            optional(:ip_host_or_network) => DbTypes.Inet.t(),
            optional(:ip_host_range_lower) => DbTypes.Inet.t(),
            optional(:ip_host_range_upper) => DbTypes.Inet.t()
          }
          | nil

  @type network_rule_functional_type() :: :allow | :deny

  @type network_rule_precedence() ::
          :disallowed | :global | :instance | :instance_owner | :implied

  @typedoc """
  Defines the available parameters for use in creating or updating Owner
  Network Rule records.

  ## Map Attributes

    * `owner_id` - the value of this attribute identifies the Owner for which
    the Network Rule is being defined.  This value doesn't have to be set
    explicitly when using the `MsbmsSystAuthentication` module API as the API
    calls set this value based on the function `owner_id` parameters they
    require.

    * `owner_name` - an alternate means of identifying the Owner instead of the
    `owner_id` attribute.   Currently there is no API which makes use of this
    value.

    * `ordering` - the order in which the new record should apply relative to
    other Owner Network Rule records.  lower `ordering` values take precedence
    over higher `ordering` values.  If the `ordering` value in the parameters
    matches the `ordering` value of an existing Owner Network Rule record, the
    inserted record will be treated as an "insert before" record, with the
    existing records being reordered to be after the new record, recursively.
    This attribute is required in record creation scenarios.

    * `functional_type` - defines what action the rule specifies once matched.
    The possible functional types are `:allow` which means the rule intends to
    explicitly allow the associated IP Address(es) to attempt authentication
    or `:deny` which explicitly prevents the IP Address(es) from attempting
    an authorization.  This attribute is required in record creation scenarios.

    * `ip_host_or_network` - a single Host IP Address or a single CIDR network
    used in matching user Host IP Addresses to rules.  Note that if this value
    is provided that the `ip_host_range_lower` and `ip_host_range_upper`
    values must be nil or not provided.

    * `ip_host_range_lower` - defines the lower bound of a simple range of IP
    Addresses, inclusive, to which rule should apply.  When this value is
    provided the `ip_host_range_upper` attribute must also be provided and the
    `ip_host_or_network` attribute value must be nil or not provided.

    * `ip_host_range_upper` - defines the upper bound of a simple range of IP
    Addresses, inclusive, to which rule should apply.  When this value is
    provided the `ip_host_range_lower` attribute must also be provided and the
    `ip_host_or_network` attribute value must be nil or not provided.

  Note that either the `ip_host_or_network` attribute or the
  `ip_host_range_lower` and `ip_host_range_upper` are required and exclusive.
  """
  @type owner_network_rule_params() :: %{
          optional(:owner_id) => MsbmsSystInstanceMgr.Types.owner_id(),
          optional(:owner_name) => MsbmsSystInstanceMgr.Types.owner_name(),
          optional(:ordering) => pos_integer(),
          optional(:functional_type) => network_rule_functional_type() | String.t(),
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

  @typedoc """
  A map of attributes used to create or update Global and Owner Password Rules.

  Note that only those attributes which are necessary to represent the desired
  rules are required to appear in the parameter submission.  All attributes not
  provided will take on a default value which assumes the specific rule has no
  effect.

  ## Map Attributes

    * `password_length` - A value of type `t:MsbmsSystDatastore.DbTypes.IntegerRange/0`
    describing the password length in terms of the number of characters.  The
    lower bound defines the minimum number of characters a password may have and
    the upper bound is the most characters that can be added to password.

    * `max_age` - A value of type `t:MsbmsSystDatastore.DbTypes.Interval/0`
    which, when added to the `last_updated` value of the Password Credential
    record, sets the expiration date of the password.  After the password's age
    has exceeded it's max age, the password must be reset prior to finalizing
    authentication. A zero interval value here means that password ages are not
    checked.  The zero interval is the default setting.

    * `require_upper_case` - A positive integer which sets the minimum number
    of upper case characters that a valid password must posses.  A setting of
    zero here disables the requirement.

    * `require_lower_case` - A positive integer which sets the minimum number
    of lower case characters that a valid password must posses.  A setting of
    zero here disables the requirement.

    * `require_numbers` - A positive integer which sets the minimum number
    of number characters that a valid password must posses.  A setting of zero
    here disables the requirement.

    * `require_symbols` - A positive integer which sets the minimum number
    of symbol characters that a valid password must posses.  A setting of zero
    here disables the requirement.

    * `disallow_recently_used` - A positive integer representing the number of
    most recently used passwords to track and prohibit from re-use.  A zero
    setting for this attribute indicates that recently used passwords should not
    be tracked or prohibited.

    * `disallow_compromised` - A boolean value which, if true, indicates that
    any new password requested by a user be first checked against the Disallowed
    Passwords list and, if found on the list, rejected for use.  When set true,
    the system will also check the password against the Disallowed Password list
    on authentication; if found on the list at authentication time, the user
    will be required to reset their password to something value not otherwise
    disallowed.  If set false the Disallowed Password list is not checked.

    * `require_mfa` - A boolean value which indicates if multi-factor
    authentication is required for password authentication.  If true MFA is
    required, otherwise MFA is per user preference.  MFA may not be completely
    disabled.

    * `allowed_mfa_types` - A list of strings identifying the allowed second
    factor methods. Currently only MFA type `credential_types_secondary_totp` is
    available.

  """
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
