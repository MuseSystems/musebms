# Source File: authentication_state.ex
# Location:    musebms/app_server/components/system/mscmp_syst_authn/lib/types/authentication_state.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystAuthn.Types.AuthenticationState do
  @moduledoc """
  The return type describing the result of authentication attempts via the
  authentication functions.

  When a user attempts to validate an Access Account, the result is returned as
  a value of this type. This includes whether or not an authentication attempt
  was successful or rejected.

  A result indicating that the status is pending may also be returned from an
  attempt if the authentication requires intervention to complete successfully.
  """

  alias MscmpSystAuthn.Types

  @enforce_keys [
    :status,
    :deadline,
    :access_account_id,
    :instance_id,
    :identity_type_id,
    :host_address,
    :applied_network_rule,
    :pending_operations
  ]
  @derive {Jason.Encoder,
           only: [
             :status,
             :deadline,
             :access_account_id,
             :instance_id,
             :identity_type_id,
             :host_address,
             :applied_network_rule,
             :pending_operations,
             :identifier,
             :owning_owner_id,
             :identity_id,
             :identity,
             :reset_reason
           ]}
  defstruct [
    :status,
    :deadline,
    :access_account_id,
    :instance_id,
    :identity_type_id,
    :host_address,
    :applied_network_rule,
    :pending_operations,
    :identifier,
    :plaintext_credential,
    :owning_owner_id,
    :identity_id,
    :identity,
    :reset_reason
  ]

  @typedoc """
  The return type describing the result of authentication attempts via the
  authentication functions.

  ## Attributes

    * `status` - the result of the authentication attempt.

    * `deadline` - the date/time by which the authentication attempt must be
    resolved by before being considered expired.  Since the authentication
    process may be interrupted and resumed, it requires that we establish some
    limit by which the process must be completed.  By default this value will be
    5 minutes after the time the authentication process starts.

    * `access_account_id` - the Access Account record ID if the authentication
    attempt has successfully completed the identification operation.

    * `instance_id` - the Instance ID that the Access Account holder is
    attempting to authenticate to.  For certain authentication types, this value
    may initially be `nil` for later resolution to a specific instance.  In some
    special cases, authentication may not be contextually bound to a specific
    Instance.  In this cases, the special value `:bypass` can be used it
    indicate that the Instance is not relevant for the authentication.

    * `identity_type_id` - the record ID referencing the Identity Type used to
    identify the Access Account.

    * `host_address` -  the apparent Host IP Address from which the
    authentication attempt originated.

    * `applied_network_rule` - the Network Rule that was applied during the
    authentication attempt.  This value may be `nil` if the evaluation of the
    Network Rules has not yet made.

    * `pending_operations` - the ordered list of remaining authentication
    operations which must complete successfully prior to the authentication
    being successfully completed.

    * `identifier` - the user supplied account identifier used to identify the
    Access Account.

    * `plaintext_credential` - the unencrypted, user supplied credential to
    test during the authentication process.  This value will be made `nil` as
    soon as it has been tested or is created `nil` for the Account Code
    Authenticator which isn't a true authentication method (it's just a lookup).

    * `owning_owner_id` - an Owner record ID for the Owner which manages the
    authenticating Access Account in cases where it's an Owned Access Account.

    * `identity_id` - the record ID of the Identity record located to identify
    the Access Account.

    * `identity` - the Identity record data struct.  This should be the same
    record as that identified by the `identity_id` attribute

    * `reset_reason` - in cases where a pending operation of
    `:require_credential_reset` is added to the authentication process, this
    value indicates the reason for the reset.  Available values are defined in
    `t:credential_reset_reason/0`.

  See `MscmpSystAuthn.Types.AuthenticationState` for more.
  """
  @type t :: %__MODULE__{
          status: Types.authentication_status(),
          deadline: DateTime.t(),
          access_account_id: Types.access_account_id() | nil,
          instance_id: MscmpSystInstance.Types.instance_id() | :bypass | nil,
          identity_type_id: Types.identity_type_id() | nil,
          host_address: Types.host_address(),
          applied_network_rule: Types.AppliedNetworkRule.t() | nil,
          pending_operations: list(Types.authentication_operations()),
          identifier: Types.account_identifier(),
          plaintext_credential: Types.credential() | nil,
          owning_owner_id: MscmpSystInstance.Types.owner_id() | nil,
          identity_id: Types.identity_id() | nil,
          identity: Msdata.SystIdentities.t() | nil,
          reset_reason: Types.credential_reset_reason() | nil
        }
end
