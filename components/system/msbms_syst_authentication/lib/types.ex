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
  alias MsbmsSystDatastore.DbTypes

  #
  # Note that the ordering of typespecs here is alphabetical.
  #

  @moduledoc """
  Types used by the Authentication module.
  """

  @type access_account_id() :: Ecto.UUID.t()

  @type access_account_instance_assoc_params() :: %{
          optional(:access_account_id) => access_account_id(),
          optional(:access_account_name) => access_account_name(),
          optional(:credential_type_id) => credential_type_id(),
          optional(:credential_type_name) => credential_type_name(),
          optional(:instance_id) => MsbmsSystInstanceMgr.Types.instance_id(),
          optional(:instance_name) => MsbmsSystInstanceMgr.Types.instance_name(),
          optional(:access_granted) => DateTime.t() | nil,
          optional(:invitation_issued) => DateTime.t(),
          optional(:invitation_expires) => DateTime.t() | nil,
          optional(:invitation_declined) => DateTime.t() | nil
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

  @type credential_params() :: %{
          optional(:access_account_id) => access_account_id(),
          optional(:access_account_name) => access_account_name(),
          optional(:credential_type_id) => credential_type_id(),
          optional(:credential_type_name) => credential_type_name(),
          optional(:credential_for_identity_id) => identity_id(),
          optional(:credential_data) => binary(),
          optional(:external_name) => String.t()
        }

  @type credential_type_id() :: MsbmsSystEnums.Types.enum_item_id()

  @type credential_type_name() :: MsbmsSystEnums.Types.enum_item_name()

  @type global_network_rule_params() :: %{
          optional(:template_rule) => boolean(),
          optional(:ordering) => pos_integer(),
          optional(:functional_type) => String.t(),
          optional(:ip_host_or_network) => DbTypes.Inet.t(),
          optional(:ip_host_range_lower) => DbTypes.Inet.t(),
          optional(:ip_host_range_upper) => DbTypes.Inet.t()
        }

  @type identity_id() :: Ecto.UUID.t()

  @type identity_type_id() :: MsbmsSystEnums.Types.enum_item_id()

  @type identity_type_name() :: MsbmsSystEnums.Types.enum_item_name()

  @type identity_params() :: %{
          optional(:access_account_id) => access_account_id(),
          optional(:access_account_name) => access_account_name(),
          optional(:identity_type_id) => identity_type_name(),
          optional(:identity_type_name) => identity_type_name(),
          optional(:account_identifier) => account_identifier(),
          optional(:validated) => DateTime.t(),
          optional(:validates_identity_id) => identity_id(),
          optional(:validation_requested) => DateTime.t(),
          optional(:validation_expires) => DateTime.t(),
          optional(:primary_contact) => boolean()
        }

  @type instance_network_rule_params() :: %{
          optional(:instance_id) => MsbmsSystInstanceMgr.Types.instance_id(),
          optional(:instance_name) => MsbmsSystInstanceMgr.Types.instance_name(),
          optional(:ordering) => pos_integer(),
          optional(:functional_type) => String.t(),
          optional(:ip_host_or_network) => DbTypes.Inet.t(),
          optional(:ip_host_range_lower) => DbTypes.Inet.t(),
          optional(:ip_host_range_upper) => DbTypes.Inet.t()
        }

  @type owner_network_rule_params() :: %{
          optional(:owner_id) => MsbmsSystInstanceMgr.Types.owner_id(),
          optional(:owner_name) => MsbmsSystInstanceMgr.Types.owner_name(),
          optional(:ordering) => pos_integer(),
          optional(:functional_type) => String.t(),
          optional(:ip_host_or_network) => DbTypes.Inet.t(),
          optional(:ip_host_range_lower) => DbTypes.Inet.t(),
          optional(:ip_host_range_upper) => DbTypes.Inet.t()
        }

  @type password_rule_params() :: %{
          optional(:owner_id) => MsbmsSystInstanceMgr.Types.owner_id() | nil,
          optional(:owner_name) => MsbmsSystInstanceMgr.Types.owner_name() | nil,
          optional(:password_length) => DbTypes.IntegerTypes.t(),
          optional(:max_age) => DbTypes.Interval.t(),
          optional(:require_upper_case) => non_neg_integer(),
          optional(:require_lower_case) => non_neg_integer(),
          optional(:require_numbers) => non_neg_integer(),
          optional(:require_symbols) => non_neg_integer(),
          optional(:disallow_recently_used) => non_neg_integer(),
          optional(:disallow_known_compromised) => boolean(),
          optional(:require_mfa) => boolean(),
          optional(:allowed_mfa_types) => list(String.t())
        }
end
