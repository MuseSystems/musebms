# Source File: types.ex
# Location:    musebms/components/system/mscmp_syst_authn/lib/types.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystAuthn.Types do
  alias MscmpSystDb.DbTypes

  #
  # Note that the ordering of typespecs here is alphabetical.
  #

  @moduledoc """
  Types used by the Authentication module.
  """

  @typedoc """
  Access Account State functional types which are assigned to Access Account
  State records for the purpose of influencing system functionality and
  behavior.

    * `:access_account_states_pending` - Access Accounts in states of this
    functional type are not considered active and are limited in use to
    facilitating full activation.


    * `:access_account_states_active` - active states are those which all full
    use of the associated Access Accounts for all permitted uses of the system.


    * `:access_account_states_suspended` - when an Access Account is in a state
    of functional type suspended only certain basic Access Account maintenance
    functionality is permitted to the Access Account holder.  Regular usage is
    naturally denied.


    * `:access_account_states_inactive` - inactive states are not allowed to use
    make regular use of the system and are disabled for most purposes.   Regular
    account maintenance is also typically not allowed.


    * `:access_account_states_purge_eligible` -  Access Accounts in states
    designated as purge eligible are permitted to be deleted from the system.
  """
  @type access_account_state_functional_types() ::
          :access_account_states_pending
          | :access_account_states_active
          | :access_account_states_suspended
          | :access_account_states_inactive
          | :access_account_states_purge_eligible

  @typedoc """
  Defines the expected type of Access Account record ID values.
  """
  @type access_account_id() :: Ecto.UUID.t()

  @typedoc """
  Defines the expected type of Access Account Instance Association record ID
  values.
  """
  @type access_account_instance_assoc_id() :: Ecto.UUID.t()

  @typedoc """
  Defines the expected shape and types of Access Account Instance Association
  Parameters.

  These parameters are passed to the database Changeset functions for tasks such
  as record creation or updating.

  ## Attributes

    * `access_account_id` - the Access Account record ID which will be
    associated with the Instance.

    * `access_account_name` - an alternate method of identifying an Access
    Account record by using its Internal Name value.  This can be used instead
    of the `access_account_id` attribute.

    * `instance_id` - the record ID of the Instance to which the designated
    Access Account record will be associated.

    * `instance_name` - an alternate method of identifying the target Instance
    record by using its Internal Name value.  This can be used instead of the
    `instance_id` attribute.

    * `access_granted` - when populated the value indicates both that the Access
    Account has access to the Instance and indicates specifically when that
    access was granted.  When `nil` this value means that the Access Account has
    been invited to the access the Instance, but that the Access Account holder
    (the user) has not yet accepted the invitation.

    * `invitation_issued` - the specific date and time when the Access Account
    was invited to access the Instance.  When `nil` the invitation has not yet
    been issued.

    * `invitation_expires` - the date and time by which an invitation for access
    must be accepted by the Access Account holder.  If the Access Account holder
    has not accepted the invitation by the value of this attribute, the record
    is considered invalid and the invitation must be reissued.

    * `invitation_declined` - the date and time at which the Access Account
    holder declined an invitation to access an Instance.  If this value is `nil`
    then the Access Account holder has not specifically declined the request.
  """
  @type access_account_instance_assoc_params() :: %{
          optional(:access_account_id) => access_account_id(),
          optional(:access_account_name) => access_account_name(),
          optional(:instance_id) => MscmpSystInstance.Types.instance_id(),
          optional(:instance_name) => MscmpSystInstance.Types.instance_name(),
          optional(:access_granted) => DateTime.t(),
          optional(:invitation_issued) => DateTime.t(),
          optional(:invitation_expires) => DateTime.t(),
          optional(:invitation_declined) => DateTime.t()
        }

  @typedoc """
  Defines the type of Access Account Internal Name values.
  """
  @type access_account_name() :: String.t()

  @typedoc """
  Defines the shape and expected types of Access Account Changeset parameters.

  ## Attributes

    * `internal_name` - a candidate key for the Access Account record. This
    value must be unique system wide.

    * `external_name` - an externally/user visible name of the Access Account.
    This value does not require uniqueness, though care should be exercised in
    contexts where it may be displayed alongside other Access Accounts to avoid
    confusion.

    * `owning_owner_id` - the record ID of the Owner which manages the Access
    Account, if the Access Account is in fact Owner managed.  If the Access '
    Account is not Owner managed this attribute should be left `nil`.

    * `owning_owner_name` - an alternative means of identifying the Access
    Account's Owner using the Internal Name of the Owner instead of its ID.

    * `allow_global_logins` - if true, the Access Account can log into the
    system without specification of an Owner or Instance for context.  Typically
    this is is used for unowned Access Accounts which may log into a global
    interface and then select their desired Application Instance from a list of
    those they have been granted access to.  If false, a specific Owner or
    Instance context is required.

    * `access_account_state_id` - identifies the current life-cycle state of the
    Access Account.

    * `access_account_state_name` - an alternative means of identifying the
    Access Account State using the Internal Name of the State instead of its
    record ID.
  """
  @type access_account_params() :: %{
          optional(:internal_name) => access_account_name(),
          optional(:external_name) => String.t(),
          optional(:owning_owner_id) => MscmpSystInstance.Types.owner_id(),
          optional(:owning_owner_name) => MscmpSystInstance.Types.owner_name(),
          optional(:allow_global_logins) => boolean(),
          optional(:access_account_state_id) => access_account_state_id(),
          optional(:access_account_state_name) => access_account_name()
        }

  @typedoc """
  Defines the type of Access Account State record ID values.
  """
  @type access_account_state_id() :: MscmpSystEnums.Types.enum_item_id()

  @typedoc """
  Defines the type of Access Account State Internal Name values.
  """
  @type access_account_state_name() :: MscmpSystEnums.Types.enum_item_name()

  @typedoc """
  The expected type of values used to identify an Access Account.

  The value of the Account Identifier will vary by context.  For example, in the
  case of Email Identities, the Account Identifier will be an email address; for
  API Token Identities, the Account Identifier will likely be a pre-generated
  short string of random characters.
  """
  @type account_identifier() :: String.t()

  @typedoc """
  Represents the return value of functions which evaluate whether or not a
  specific originating host IP address is allowed to attempt an authentication.

  When an authentication is attempted, a number of different rules and data
  sources may determine what kind of connection is allowed based on the host IP
  address from which the attempt appears to be originating and the destination
  Instance for which the authentication is being processed.  To normalize the
  return from the evaluation of these different network based evaluations we
  define a simplified `t:applied_network_rule/0` value to represent the
  actionable data of the evaluation.

  ## Attributes

    * `precedence` - this will indicate the precedence of the applied Network
    Rule.  This value can aid in identifying the origin of a given applied
    allowance or denial.

    * `network_rule_id` - this is the record ID of the rule which was evaluated
    to govern the authentication attempt.  Which specific relation the ID refers
    to will depend on the specific precedence of the rule applied.  This value
    may be `nil` if the implied default Network Rule is applied since, by
    definition, this means no other explicitly defined Network Rule was found.

    * `functional_type` - May be either `:allow` or `:deny`.  `:allow` means
    that the Network Rule evaluation allows the host IP address to attempt
    authentication.  `:deny` indicates that the host IP address may not attempt
    an authentication.
  """
  @type applied_network_rule() :: %{
          required(:precedence) => network_rule_precedence(),
          required(:network_rule_id) => Ecto.UUID.t() | nil,
          required(:functional_type) => network_rule_functional_type()
        }

  @typedoc """
  Defines required operations during an authentication attempt which are
  considered `extended`, meaning that they interrupt the normal authentication
  flow.

  Certain authentication methods, such as Email/Password authentication, have
  certain defined points where an authentication attempt may be interrupted.
  Examples of such interruptions include when Multi-Factor Authentication is
  required or when the password requires resetting prior to proceeding.  In all
  of these cases, we have some action that must take place, including possibly
  user interactive actions, which must be completed before the full
  authentication process can complete successfully.

  This type defines the known extended operations which can force this
  functionality.
  """
  @type authentication_extended_operations() ::
          :require_mfa | :require_mfa_setup | :require_instance | :require_credential_reset

  @typedoc """
  A list of known operations which may occur during an authentication attempt.

  Each type of authentication defines the steps which that kind of
  authentication requires to be completed prior to considering the attempt
  "authenticated".  This type defines references to all of the known operations
  that may be required and then includes the
  `t:authentication_extended_operations/0` which may cause an interruption to
  to the authentication process.
  """
  @type authentication_operations() ::
          :check_global_network_rules
          | :check_identifier_rate_limit
          | :check_identity
          | :check_credential
          | :check_instance
          | :check_instance_network_rules
          | :check_host_rate_limit
          | authentication_extended_operations()

  @typedoc """
  The return type describing the result of authentication attempts via the
  authentication functions.

  When a user attempts to validate an Access Account, the result is returned as
  a value of this type. This includes whether or not an authentication attempt
  was successful or rejected.

  An result indicating that the status is pending may also be returned from an
  attempt if the authentication requires intervention to complete successfully.

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
    may initially be `nil`, but must be non-nil prior to a successful completion
    of the authentication process.

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
  """
  @type authentication_state() :: %{
          required(:status) => authentication_status(),
          required(:deadline) => DateTime.t(),
          required(:access_account_id) => access_account_id() | nil,
          required(:instance_id) => MscmpSystInstance.Types.instance_id() | nil,
          required(:identity_type_id) => identity_type_id(),
          required(:host_address) => host_address(),
          required(:applied_network_rule) => applied_network_rule() | nil,
          required(:pending_operations) => list(authentication_operations()),
          optional(:identifier) => account_identifier(),
          optional(:plaintext_credential) => credential(),
          optional(:owning_owner_id) => MscmpSystInstance.Types.owner_id() | nil,
          optional(:identity_id) => identity_id(),
          optional(:identity) => Msdata.SystIdentities.t(),
          optional(:reset_reason) => credential_reset_reason()
        }

  @typedoc """
  The understood life-cycle states of the authentication process.

  Any authentication process will exist in one of the states defined by the
  list below.  The list is used to populate the `status` field of the
  `t:authentication_state/0` type.

  Note that while the authentication process may provide the caller information
  regarding the nature of any rejection, the developer should nonetheless make
  well considered judgements regarding what, if any, detail to disclose to the
  user attempting authentication.  More often than not no specificity for a
  rejection should be given.

    * `:not_started` - the authentication process has not yet begun.

    * `:pending` - the authentication process is underway.   It is possible for
    a call to an authentication function to return a `:pending` authentication
    state status.  In these cases the authentication has been interrupted and
    requires intervention to proceed.

    * `:rejected_host_check` - the authentication process has rejected the
    authentication attempt because the apparent Host IP Address is not allowed
    to authenticate as presented.

    * `:rejected_rate_limited` - the authentication process has rejected the
    authentication attempt because the identifier has failed to successfully
    authenticate within the prescribed number of tries within a prescribed
    duration.

    * `:rejected_validation` - the authentication process has rejected the
    authentication attempt because the identity used to identify the Access
    Account is subject to prior validation/confirmation by the Access Account
    holder.  This is the case with newly created Email Identities, for example.

    * `:rejected_identity_expired` - the authentication process has rejected the
    authentication attempt because the Identity record used to identity the
    Access Account is beyond its configured expiration date and may not be use
    again until the Identity's expiration has been reset.  Note that not all
    Identity records expire.

    * `:rejected_deadline_expired` - the authentication process is rejected
    because it has taken too long to resolve to a final authentication status.

    * `:rejected` - the authentication process has rejected the authentication
    attempt for undeclared reasons.  Examples of reasons that can prompt this
    authentication end state are a user providing a wrong password or no
    Instance to access being identified.

    * `:authenticated` - the authentication process has finished successfully
    and the Access Account is now authenticated for the identified Instance.
  """
  @type authentication_status() ::
          :not_started
          | :pending
          | :rejected_host_check
          | :rejected_rate_limited
          | :rejected_validation
          | :rejected_identity_expired
          | :rejected_deadline_expired
          | :rejected
          | :authenticated

  @typedoc """
  The return type used when creating Authenticators via the API.

  The included values and attributes will vary somewhat from Authenticator type
  to Authenticator type, but they will all follow this basic form.

  ## Attributes

    * `access_account_id` - the Access Account record ID for which the
    Authenticator has been created.

    * `account_identifier` - the Access Account Identifier for use in
    identifying the Access Account in the authentication process.  Depending on
    the Authenticator type, this could be a restatement of what the user
    provided, such as an Email address, or may be system generated such as the
    identifier for user with an API Token.

    * `credential` - the plaintext Credential created for the Authenticator.
    This attribute is only returned in cases where the typical Authenticator
    creation flow includes the system randomly generating the Credential.  For
    example, an API Token Credential is automatically created by the system and
    the Credential must be communicated to the user once created.  Note that
    even in these cases the only time the Credential is available for disclosure
    to the user is immediately after the Authenticator creation via this value.
    Once the return result is discarded the Credential is unrecoverable.

    * `validation_identifier` - when creating an Email/Password Authenticator,
    the default options mandate that validating the Email Identity is required.
    Assuming the default is not overridden, the system generated Identifier for
    the user to use to validate the Email Identity is provided via this
    attribute.  If validation is not required this attribute will not be present
    in the return value of the Authenticator creation call.

    * `validation_credential` - the (usually) system generated Credential in
    plaintext which compliments the `validation_identifier` value.  This
    attribute is either included or excluded on the same terms as the
    `validation_identifier`.  Note that the return of this value after
    the creation of an Email/Password Authenticator is the only time that this
    value is available in plaintext; after this point the plaintext is not
    retrievable.
  """
  @type authenticator_result() :: %{
          required(:access_account_id) => access_account_id(),
          optional(:account_identifier) => account_identifier(),
          optional(:credential) => credential(),
          optional(:validation_identifier) => account_identifier() | nil,
          optional(:validation_credential) => credential_id() | nil
        }

  @typedoc """
  The supported types of authentication.

  Though the system separates out the notion of what Identities & Credentials
  are, there are nonetheless matched pairs of identities/credentials which the
  system treat as a unit.  This type encapsulates those functional combinations
  making it easier for code to communicate intentions while avoiding invalid
  combinations of Identity/Credential Types.
  """
  @type authenticator_types() :: :email_password | :api_token

  @typedoc """
  Defines the type expected for user provided plaintext Credentials.
  """
  @type credential() :: String.t()

  @typedoc """
  Defines the Credential record ID type.
  """
  @type credential_id() :: Ecto.UUID.t()

  @typedoc """
  A type to facilitate data maintenance operations related to Credential
  records.

  ## Attributes

    * `access_account_id` - identifies the Access Account to which the
    Credential pertains as identified by its record ID.

    * `access_account_name` - an alternative method of using the Access Account
    internal name to identify the Access Account.

    * `credential_type_id` - the record ID of the Credential Type which
    classifies the Credential record.

    * `credential_type_name` - an alternative method of identifying the
    Credential Type using its Internal Name.

    * `credential_for_identity_id` - certain Credentials are only valid when
    used in conjunction with specific Identity records.  This value records the
    record ID of the Identity record to which the Credential record belongs.

    * `credential_data` - the hashed or encrypted value of the Credential.  The
    specific details of what is stored in this value will depend on the method
    used to secure the Credential, but the most typical scenario includes both
    the credential hash and the record specific salting value used in creating
    the hash.
  """
  @type credential_params() :: %{
          optional(:access_account_id) => access_account_id(),
          optional(:access_account_name) => access_account_name(),
          optional(:credential_type_id) => credential_type_id(),
          optional(:credential_type_name) => credential_type_name(),
          optional(:credential_for_identity_id) => identity_id(),
          optional(:credential_data) => binary()
        }

  @typedoc """
  Used to define the return value of an attempted Credential Confirmation.

  Attempting to confirm a user provided Credential returns a tuple where the
  first element is an indication of whether or not a valid Credential was
  supplied by the user and the second element is a list of extended states which
  might indicate that additional processing is required even if the Credential
  is successfully confirmed.  If no additional processing is required the second
  element will simply be an empty list.
  """
  @type credential_confirm_result() ::
          {credential_confirm_state(), list(credential_extended_state())}

  @typedoc """
  Defines the possible outcomes of an attempt to confirm a user provided
  Credential.

  This type is used to set the available values of the first element of the
  `t:credential_confirm_result/0` tuple.

    * `:confirmed` - the Credential provided by the user is confirmed as being
    correct.

    * `:no_credential` - no matching Credential record of the correct type was
    found for the Access Account.

    * `:wrong_credential` - the user provided Credential does not match the
    stored Credential record for that Access Account.

  While outcomes other than confirm give some information to the caller, the
  specific reason for the failure should usually not be disclosed to the user
  attempting authentication; users should just see a binary confirmed/
  unconfirmed state without additional details regarding a failure.
  """
  @type credential_confirm_state() :: :confirmed | :no_credential | :wrong_credential

  @typedoc """
  Known extended Credential confirmation states indicating required post-
  confirmation actions.

  This type defines the values which may appear in a list as the second element
  of `t:credential_confirm_result/0`.

    * `:require_mfa` - when present this value indicates that even though a
    Credential confirmation succeeded, an additional multi-factor credential
    confirmation is required prior to the authentication attempt resulting in
    an authenticated status.  This will be true when the Access Account has
    one or more configured MFA Credentials and the primary Authenticator is one
    that supports MFA Credential confirmation (e.g. Password Credentials support
    MFA Credential confirmation).

  Additional states that can be represented as extended states here include the
  Credential reset related reasons defined in `t:credential_reset_reason/0`.
  """
  @type credential_extended_state() :: :require_mfa | credential_reset_reason()

  @typedoc """
  Established classes of Credential Types which share common system
  functionality.

    * `:credential_types_password` - used to identify Credential Types which
    use passwords as their credential.


    * `:credential_types_mfa_totp` - associates a Credential Type with Time
    based One Time Password Multi-Factor Authentication functionality.


    * `:credential_types_mfa_totp_recovery_code` - designates a Credential Type
    as representing an MFA/TOTP recovery code.


    * `:credential_types_mfa_known_host` - designates a Credential Type
    as representing a known MFA/TOTP host allowed to bypass interactive MFA
    secondary authentication.


    * `:credential_types_token_api` - indicates that the Credential Type makes
    use of API Token credential functionality.


    * `:credential_types_token_validation` - indicates that the Credential Type
    facilitates the validation of certain types of Identity records.


    * `:credential_types_token_recovery` - associates Credential Types which
    facilitate recovery of other Credential Types with the necessary recovery
    functionality.

  """
  @type credential_type_functional_types() ::
          :credential_types_password
          | :credential_types_mfa_totp
          | :credential_types_mfa_totp_recovery_code
          | :credential_types_mfa_known_host
          | :credential_types_token_api
          | :credential_types_token_validation
          | :credential_types_token_recovery

  @typedoc """
  Provides additional Credential Extended State values when Credential resets
  are required.

  These values are related in that they all deal with a primary Credential reset
  being required and describe the reason for such a requirement.  This is
  information useful to users that must take action.

  Note that currently the only Credential type that may require Credential reset
  is the Password Credential Type.

    * `reset_forced` - the reset is required because it has been
    administratively forced.  See the `force_reset` field of
    `Msdata.SystCredentials` for more.

    * `reset_age` - the Password Credential has exceeded the applicable Max Age
    Password Rule and must be updated.

    * `reset_disallowed` - the password used in the Credential has been found to
    be included in the Disallowed Passwords list and may no longer be used for
    authentication.
  """
  @type credential_reset_reason() :: :reset_forced | :reset_age | :reset_disallowed

  @typedoc """
  A extended return value used when Credentials setting operations have failed.

  This type allows the reason for failure to be communicated.  This will most
  often be when a candidate password has failed the effective Password Rule and
  will describe which specific Password Rules have been violated.
  """
  @type credential_set_failures() :: {:invalid_credential, Keyword.t(password_rule_violations())}

  @typedoc """
  The Credential Type record ID database type.
  """
  @type credential_type_id() :: MscmpSystEnums.Types.enum_item_id()

  @typedoc """
  Defines the expected type of the Credential Type record Internal Name.
  """
  @type credential_type_name() :: MscmpSystEnums.Types.enum_item_name()

  @typedoc """
  The Credential Types known by the system.
  """
  @type credential_types() ::
          :credential_types_sysdef_password
          | :credential_types_sysdef_mfa_totp
          | :credential_types_sysdef_mfa_totp_recovery_code
          | :credential_types_sysdef_mfa_known_host
          | :credential_types_sysdef_token_api
          | :credential_types_sysdef_token_validation
          | :credential_types_sysdef_token_recovery

  @typedoc """
  The Disallowed Host record ID database type.
  """
  @type disallowed_host_id() :: Ecto.UUID.t()

  @typedoc """
  Defines the available parameters for use in creating or updating Global
  Network Rule records.

  ## Attributes

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

  @typedoc """
  Defines the data type and structure of Host IP Addresses.
  """
  @type host_address() :: IP.addr()

  @typedoc """
  Establishes the data type of the Identity record ID.
  """
  @type identity_id() :: Ecto.UUID.t()

  @typedoc """
  Defines the Identity Type record ID data type.
  """
  @type identity_type_id() :: MscmpSystEnums.Types.enum_item_id()

  @typedoc """
  Defines the expected data type of the Identity Type record Internal Name
  value.
  """
  @type identity_type_name() :: MscmpSystEnums.Types.enum_item_name()

  @typedoc """
  Defines the list of Identity Types known to the system.
  """
  @type identity_types() ::
          :identity_types_sysdef_email
          | :identity_types_sysdef_account
          | :identity_types_sysdef_api
          | :identity_types_sysdef_validation
          | :identity_types_sysdef_password_recovery

  @typedoc """
  Defines a map of attributes for use in Identity record Changeset processing.


  ## Attributes

    * `access_account_id` - the record ID of the Access Account for which the
    record is being defined.

    * `access_account_name` - an alternative means of selecting the Access
    Account using its Internal Name value.

    * `identity_type_id` - the record ID of the Identity Type of the Identity.

    * `identity_type_name` - an alternative means of selecting the Identity Type
    of the record using the Identity Type Internal Name value.

    * `account_identifier` - the identifier presented by the Access Account
    holder to identify their Access Account.  For example, for Email Identities
    this value would be the Access Account holder's email address.

    * `validated` - this value indicates both that the Identity record
    is valid for use in identification requests and the timestamp at which that
    valid condition came into effect.  When `nil`, the Identity record is not
    valid to use for identifying Access Accounts.

    * `validates_identity_id` - if the Identity record is of type
    `identity_types_sysdef_validation` this value will reference the record
    which is to be validated on confirmation of the validation request.  In all
    other instances the value should be `nil`.

    * `validation_requested` - if the Identity record is of type
    `identity_types_sysdef_validation` this value will record the timestamp when
    the validation was requested.

    * `identity_expires` - the optional timestamp of when the Identity record
    expires and after which the Identity record may not be used for
    identification purposes.  If this value is `nil`, the Identity record may be
    used indefinitely.

    * `external_name` - certain Identities, such as API Token Identities, allow
    the Access Account holder to provide names with which they will more easily
    recognize in maintenance tasks.  This value allows for the establishment of
    a user defined name for the Identity record.  Note that this value does not
    need to be unique on any basis and therefore is unsuitable for use in
    looking up Identity records.
  """
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
  Identifies the categorizations of Identity Types which the system will treat
  with different functional responses.

    * `:identity_types_email` - indicates that the Identity Type represents
    Identities which can be used in email address contexts.

    * `:identity_types_account` - designates Identity Types which are used for
    simple identification and are not typically used for Access Account
    identification for authentication purposes.

    * `:identity_types_api` - associates API Token Identity functionality with
    Identity Types.

    * `:identity_types_validation` - indicates that an Identity Type designates
    Identities used to validate other Identity Types, such as
    `:identity_types_email` Identity Types.

    * `:identity_types_password_recovery` - designates Identity Types use in
    Password Credential recovery.

  """
  @type identity_type_functional_types() ::
          :identity_types_email
          | :identity_types_account
          | :identity_types_api
          | :identity_types_validation
          | :identity_types_password_recovery

  @typedoc """
  Defines the available parameters for use in creating or updating Instance
  Network Rule records.

  ## Attributes

    * `instance_id` - the value of this attribute identifies the Instance for
    which the Network Rule is being defined.  This value doesn't have to be set
    explicitly when using the `MscmpSystAuthn` module API as the API
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
            optional(:instance_id) => MscmpSystInstance.Types.instance_id(),
            optional(:instance_name) => MscmpSystInstance.Types.instance_name(),
            optional(:ordering) => pos_integer(),
            optional(:functional_type) => network_rule_functional_type() | String.t(),
            optional(:ip_host_or_network) => DbTypes.Inet.t(),
            optional(:ip_host_range_lower) => DbTypes.Inet.t(),
            optional(:ip_host_range_upper) => DbTypes.Inet.t()
          }
          | nil

  @typedoc """
  Establishes the two basic operations that Network Rule may define.

    * `:allow` - this essentially whitelists any host IP address(es) or networks
    defined by the Network Rule, allowing an authentication attempt.

    * `:deny` - this value denies any specified host IP address(es) or networks
    from attempting an authentication.
  """
  @type network_rule_functional_type() :: :allow | :deny

  @typedoc """
  The known precedence classes of Network Rule definitions.

  Network Rules are applied in order of their Precedence Class and then of their
  ordering value withing the Precedence Class; first matching found becomes the
  Applied Network Rule.

  Each Precedence Class is a group of rules defined within the same scope of
  applicability which can range from being globally applicable to applying only
  to a single Instance.  The known Precedence Classes in order of application
  are:

    * `:disallowed` - disallowed hosts are individual host IP addresses which
    are denied access on a global basis, effectively banning their use with the
    system.  Defined by `Msdata.SystDisallowedHosts`.

    * `:global` - Network Rules which are defined to apply global without regard
    to Owner or Instance.  Such rules may explicitly whitelist or blacklist
    hosts.  Defined by `Msdata.SystGlobalNetworkRules`.

    * `:instance` - Network Rules which apply to only a specific Application
    Instance.  Defined by `Msdata.SystInstanceNetworkRules`.

    * `:instance_owner` - Network Rules which apply to all Application Instances
    belonging to a specific Owner.  Defined by
    `Msdata.SystOwnerNetworkRules`.

    * `:implied` - when no explicitly defined applicable Disallowed Host or
    Network Rule records can be found, the system will use an implicit globally
    applied rule to Apply to the authentication attempt.  The `:implied` rule
    allows any host to attempt authentication.
  """
  @type network_rule_precedence() ::
          :disallowed | :global | :instance | :instance_owner | :implied

  @typedoc """
  Defines the available parameters for use in creating or updating Owner
  Network Rule records.

  ## Attributes

    * `owner_id` - the value of this attribute identifies the Owner for which
    the Network Rule is being defined.  This value doesn't have to be set
    explicitly when using the `MscmpSystAuthn` module API as the API
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
          optional(:owner_id) => MscmpSystInstance.Types.owner_id(),
          optional(:owner_name) => MscmpSystInstance.Types.owner_name(),
          optional(:ordering) => pos_integer(),
          optional(:functional_type) => network_rule_functional_type() | String.t(),
          optional(:ip_host_or_network) => DbTypes.Inet.t(),
          optional(:ip_host_range_lower) => DbTypes.Inet.t(),
          optional(:ip_host_range_upper) => DbTypes.Inet.t()
        }

  @typedoc """
  Defines a generic Password Rule record allowing Password Rules originating
  from different database sources a common representation.

  Password Rules are defined in two different database tables,
  `Msdata.SystGlobalPasswordRules` and
  `Msdata.SystOwnerPasswordRules`.  This type defines a
  common representation of Password Rule data for those parts of the system that
  apply Password Rules after the applicable Password Rules have been resolved.

  ## Attributes

    * `access_account_id` - the Access Account for which the effective Password
    Rules has been resolved.

    * `owner_id` - the Owner record ID of the Owner which owns the Access
    Account.  The Access Account's Owner may have established Password Rules
    which would apply to the Access Account.  A value here does not mean that
    the Owner's rules necessarily are part of the resolved Password Rule, just
    that they would have been considered.

    * `password_length` - the resolved value of type
    `t:MscmpSystDb.DbTypes.IntegerRange.t/0` describing the password
    length in terms of the number of characters.  The lower bound defines the
    minimum number of characters a password may have and the upper bound is the
    most characters that can be added to password.

    * `max_age` - the resolved value of type `t:MscmpSystDb.DbTypes.Interval.t/0`
    which, when added to the `last_updated` value of the Password Credential
    record, sets the expiration date of the password.  After the password's age
    has exceeded it's max age, the password must be reset prior to finalizing
    authentication. A zero interval value here means that password ages are not
    checked.  The zero interval is the default setting.

    * `require_upper_case` - the resolved minimum number of upper case
    characters that a valid password must posses.  A setting of zero here
    disables the requirement.

    * `require_lower_case` - the resolved minimum number of lower case
    characters that a valid password must posses.  A setting of zero here
    disables the requirement.

    * `require_numbers` - the resolved minimum number of number characters that
    a valid password must posses.  A setting of zero here disables the
    requirement.

    * `require_symbols` - the resolved minimum number of symbol characters that
    a valid password must posses.  A setting of zero here disables the
    requirement.

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
  @type password_rules() :: %{
          optional(:access_account_id) => access_account_id() | nil,
          optional(:owner_id) => MscmpSystInstance.Types.owner_id() | nil,
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

  ## Attributes

    * `password_length` - A value of type `t:MscmpSystDb.DbTypes.IntegerRange.t/0`
    describing the password length in terms of the number of characters.  The
    lower bound defines the minimum number of characters a password may have and
    the upper bound is the most characters that can be added to password.

    * `max_age` - A value of type `t:MscmpSystDb.DbTypes.Interval.t/0`
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
          optional(:owner_id) => MscmpSystInstance.Types.owner_id() | nil,
          optional(:owner_name) => MscmpSystInstance.Types.owner_name() | nil,
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
  Defines the known Password Rule violations.

  Various functions evaluation a candidate password against the set of
  applicable Password Rules and return lists of violations for resolution.  The
  possible violations are:

    * `:password_rule_length_min` - the candidate password violates the minimum
    password length rule.  The accompanying value is the required number of
    characters the password must contain.

    * `:password_rule_length_max` -  the candidate password violates the maximum
    password length rule.  The accompanying value is the maximum permitted
    number of characters that the password may contain.

    * `:password_rule_required_upper` - the candidate password violates the
    minimum upper case characters rule.  The accompanying value is the required
    number of upper case characters.

    * `:password_rule_required_lower` - the candidate password violates the
    minimum lower case characters rule.  The accompanying value is the required
    number of lower case characters.

    * `:password_rule_required_numbers` - the candidate password violates the
    minimum number characters rule.  The accompanying value is the required
    number of number characters.

    * `:password_rule_required_symbols` - the candidate password violates the
    minimum symbol characters rule.  The accompanying value is the required
    number of symbol characters.

    * `:password_rule_disallowed_password` - the candidate password is known
    password which is disallowed from use in the system.  A new allowed password
    must be selected.

    * `:password_rule_recent_password` - the candidate password has been too
    recently used for this Access Account and another not recently used password
    must be selected.
  """
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
