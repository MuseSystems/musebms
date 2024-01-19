# Source File: mscmp_syst_authn.ex
# Location:    musebms/app_server/components/system/mscmp_syst_authn/lib/api/mscmp_syst_authn.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystAuthn do
  @external_resource "README.md"
  @moduledoc Path.join([__DIR__, "..", "..", "README.md"])
             |> File.read!()
             |> String.split("<!-- MDOC !-->")
             |> Enum.fetch!(1)

  alias MscmpSystAuthn.Impl
  alias MscmpSystAuthn.Types
  alias MscmpSystNetwork.Types, as: NetTypes

  # ==============================================================================================
  # ==============================================================================================
  #
  # Enumerations Data
  #
  # ==============================================================================================
  # ==============================================================================================

  @doc section: :enumerations_data
  @doc """
  Returns the Identity Type record for the given Internal Name; raises on error.

  On successful execution either the requested Identity Type Enumeration record
  is returned or `nil` if the record does not exist.

  ## Parameters

    * `identity_type_name` - the Internal Name of the desire Identity Type
    record to return.

  ## Examples

  Finding a Identity Type record by Internal Name.

      iex> %Msdata.SystEnumItems{} =
      ...>   MscmpSystAuthn.get_identity_type_by_name("identity_types_sysdef_account")

  Looking for a non-existent record.

      iex> MscmpSystAuthn.get_identity_type_by_name("nonexistent_type")
      nil
  """
  @spec get_identity_type_by_name(Types.identity_type_name()) :: Msdata.SystEnumItems.t() | nil
  defdelegate get_identity_type_by_name(identity_type_name), to: Impl.Identity

  @doc section: :enumerations_data
  @doc """
  Returns the Identity Type Enumeration record which is configured as being
  default.

  If no Identity Type record is configured as default, then `nil` is returned.

  ## Parameters

    * `functional_type` - an optional parameter which, if provided and not
    `nil`, will return the default Identity Type record configured for the
    requested functional type rather than the system default Identity Type.
    The default for this parameter is to treat the parameter as not provided
    (`nil`).

  ## Examples

  Requesting the system default Identity Type.

      iex> %Msdata.SystEnumItems{internal_name: "identity_types_sysdef_email"} =
      ...>   MscmpSystAuthn.get_identity_type_default()

  Requesting the default Identity Type for a specific functional type.

      iex> %Msdata.SystEnumItems{internal_name: "identity_types_sysdef_api"} =
      ...>   MscmpSystAuthn.get_identity_type_default(:identity_types_api)
  """
  @spec get_identity_type_default(Types.identity_type_functional_types() | nil) ::
          Msdata.SystEnumItems.t()
  defdelegate get_identity_type_default(functional_type \\ nil), to: Impl.Identity

  @doc section: :enumerations_data
  @doc """
  Returns the Credential Type record for the given Internal Name; raises on error.

  On successful execution either the requested Credential Type Enumeration record
  is returned or `nil` if the record does not exist.

  ## Parameters

    * `credential_type_name` - the Internal Name of the desire Credential Type
    record to return.

  ## Examples

  Finding a Credential Type record by Internal Name.

      iex> %Msdata.SystEnumItems{} =
      ...>   MscmpSystAuthn.get_credential_type_by_name("credential_types_sysdef_token_api")

  Looking for a non-existent record.

      iex> MscmpSystAuthn.get_credential_type_by_name("nonexistent_type")
      nil
  """
  @spec get_credential_type_by_name(Types.credential_type_name()) ::
          Msdata.SystEnumItems.t() | nil
  defdelegate get_credential_type_by_name(credential_type_name), to: Impl.Credential

  @doc section: :enumerations_data
  @doc """
  Returns the Credential Type Enumeration record which is configured as being
  default.

  If no Credential Type record is configured as default, then `nil` is returned.

  ## Parameters

    * `functional_type` - an optional parameter which, if provided and not
    `nil`, will return the default Credential Type record configured for the
    requested functional type rather than the system default Credential Type.
    The default for this parameter is to treat the parameter as not provided
    (`nil`).

  ## Examples

  Requesting the system default Credential Type.

      iex> %Msdata.SystEnumItems{internal_name: "credential_types_sysdef_password"} =
      ...>   MscmpSystAuthn.get_credential_type_default()

  Requesting the default Credential Type for a specific functional type.

      iex> %Msdata.SystEnumItems{internal_name: "credential_types_sysdef_mfa_totp"} =
      ...>   MscmpSystAuthn.get_credential_type_default(:credential_types_mfa_totp)
  """
  @spec get_credential_type_default(Types.credential_type_functional_types() | nil) ::
          Msdata.SystEnumItems.t()
  defdelegate get_credential_type_default(functional_type \\ nil), to: Impl.Credential

  # ==============================================================================================
  # ==============================================================================================
  #
  # Access Account Data
  #
  # ==============================================================================================
  # ==============================================================================================

  @doc section: :access_account_data
  @doc """
  Returns the Access Account State record for the given Internal Name; raises on
  error.

  On successful execution either the requested Access Account State Enumeration
  record is returned or `nil` if the record does not exist.

  ## Parameters

    * `access_account_state_name` - the Internal Name of the desire Access Account
    State record to return.

  ## Examples

  Finding a Access Account State record by Internal Name.

      iex> %Msdata.SystEnumItems{} =
      ...>   MscmpSystAuthn.get_access_account_state_by_name("access_account_states_sysdef_active")

  Looking for a non-existent record.

      iex> MscmpSystAuthn.get_access_account_state_by_name("nonexistent_type")
      nil
  """
  @spec get_access_account_state_by_name(Types.access_account_state_name()) ::
          Msdata.SystEnumItems.t() | nil
  defdelegate get_access_account_state_by_name(access_account_state_name), to: Impl.AccessAccount

  @doc section: :access_account_data
  @doc """
  Returns the Access Account State Enumeration record which is configured as
  being default.

  If no Access Account State record is configured as default, then `nil` is
  returned.

  ## Parameters

    * `functional_type` - an optional parameter which, if provided and not
    `nil`, will return the default Access Account State record configured for
    the requested functional type rather than the system default Access Account
    State.  The default for this parameter is to treat the parameter as not
    provided (`nil`).

  ## Examples

  Requesting the system default Access Account State.

      iex> %Msdata.SystEnumItems{internal_name: "access_account_states_sysdef_pending"} =
      ...>   MscmpSystAuthn.get_access_account_state_default()

  Requesting the default Access Account State for a specific functional type.

      iex> %Msdata.SystEnumItems{internal_name: "access_account_states_sysdef_inactive"} =
      ...>   MscmpSystAuthn.get_access_account_state_default(:access_account_states_inactive)
  """
  @spec get_access_account_state_default(Types.access_account_state_functional_types() | nil) ::
          Msdata.SystEnumItems.t()
  defdelegate get_access_account_state_default(functional_type \\ nil), to: Impl.AccessAccount

  @doc section: :access_account_data
  @doc """
  Create a new Access Account.

  ## Parameters

    * `access_account_params` - a map of required and optional parameters which
    define the new Access Account record.  Required attributes in this map are:
    `internal_name`, `external_name`, `access_account_state_id`, and
    `allow_global_logins`.

  ## Example

      iex> state = MscmpSystEnums.get_default_enum_item("access_account_states")
      iex> {:ok, %Msdata.SystAccessAccounts{}} =
      ...>   MscmpSystAuthn.create_access_account(
      ...>     %{
      ...>       internal_name: "example_create_accnt",
      ...>       external_name: "Create Access Account Example",
      ...>       access_account_state_id: state.id,
      ...>       allow_global_logins: true
      ...>      }
      ...>    )
  """

  @spec create_access_account(Types.access_account_params()) ::
          {:ok, Msdata.SystAccessAccounts.t()} | {:error, MscmpSystError.t()}
  defdelegate create_access_account(access_account_params), to: Impl.AccessAccount

  @doc section: :access_account_data
  @doc """
  Looks up an Access Account record ID by its internal name.

  ## Parameters

    * `access_account_name` - the internal name of the record for which to
    retrieve the record ID.

  ## Examples

      iex> {:ok, access_account_id}  =
      ...>   MscmpSystAuthn.get_access_account_id_by_name("example_accnt")
      iex> is_binary(access_account_id)
      true
  """

  @spec get_access_account_id_by_name(Types.access_account_name()) ::
          {:ok, Types.access_account_id()} | {:error, MscmpSystError.t()}
  defdelegate get_access_account_id_by_name(access_account_name), to: Impl.AccessAccount

  @doc section: :access_account_data
  @doc """
  Retrieves a fully populated Access Account record as found by internal name.

  'Fully populated' in this context means that the related Account Account State
  and related functional type data is also retrieved along with the actual
  Access Account data.

  ## Parameters

    * `access_account_name` - the internal name of the Access Account record to
    retrieve.

  ## Example

      iex> {
      ...>   :ok,
      ...>   %Msdata.SystAccessAccounts{internal_name: "example_accnt"}
      ...> } =
      ...>   MscmpSystAuthn.get_access_account_by_name("example_accnt")
  """

  @spec get_access_account_by_name(Types.access_account_name()) ::
          Msdata.SystAccessAccounts.t() | {:error, MscmpSystError.t()}
  defdelegate get_access_account_by_name(access_account_name), to: Impl.AccessAccount

  @doc section: :access_account_data
  @doc """
  Updates the maintainable fields of a given Access Account record.

  ## Parameters

    * `access_account` - either the record ID value of the Access Account to
    update or is the complete `Msdata.SystAccessAccounts`
    struct representing the before-update state of the Access Account record.

    * `access_account_params` - a map containing those attributes to be changed
    along with their new values.

  ## Example

      iex> {:ok, target_access_account} =
      ...>   MscmpSystAuthn.get_access_account_by_name("example_accnt")
      iex> {:ok, updated_access_account} =
      ...>   MscmpSystAuthn.update_access_account(
      ...>     target_access_account,
      ...>     %{external_name: "Updated Example Account Name"}
      ...>   )
      iex> %Msdata.SystAccessAccounts{
      ...>   external_name: "Updated Example Account Name"
      ...> } = updated_access_account
  """

  @spec update_access_account(
          Types.access_account_id() | Msdata.SystAccessAccounts.t(),
          Types.access_account_params()
        ) ::
          {:ok, Msdata.SystAccessAccounts.t()} | {:error, MscmpSystError.t()}
  defdelegate update_access_account(access_account, access_account_params), to: Impl.AccessAccount

  @doc section: :access_account_data
  @doc """
  Purges the requested Access Account if the Access Account State is of
  a purge eligible functional type.

  ## Parameters

    * `access_account` - is either the record ID of the Access Account to purge
    or the populated `Msdata.SystAccessAccounts` struct
    representing the record to purge.

  ## Example

      iex> {:ok, target_access_account} =
      ...>   MscmpSystAuthn.get_access_account_by_name("example_purge_accnt")
      iex> MscmpSystAuthn.purge_access_account(target_access_account)
      :ok
  """
  @spec purge_access_account(Types.access_account_id() | Msdata.SystAccessAccounts.t()) ::
          :ok | {:error, MscmpSystError.t()}
  defdelegate purge_access_account(access_account), to: Impl.AccessAccount

  @doc section: :access_account_data
  @doc """
  Tests to see if a specific Access Account, or any Access Account, record
  exists in the database.

  The functions provides an optional test on either an Access Account record's
  Internal Name or record ID value.  If no selectivity option is made, the test
  checks if any Access Account records exist in the database at all.

  If an appropriate Access Account record is found, the function returns true,
  otherwise false.  Any other condition is considered an error and will
  result in an error tuple being returned indicating the cause of the error.

  ## Parameters

    * `opts` - an optional Keyword List of optional parameters which can
    influence the result of calling the function.  The available options are:

      * `access_account_id` - tests if a specific Access Account record exists
      as referenced by its record ID value.

      * `access_account_name` - tests if a specific Access Account record exists
      as referenced by its Internal Name.

  ## Examples

  Check if any Access Account record exists.

      iex> MscmpSystAuthn.access_account_exists?()
      true

  Check if a specific Access Account record exists.

      iex> MscmpSystAuthn.access_account_exists?(access_account_name: "example_accnt")
      true

  If a non-existent Access Account is requested, the function indicates the record was
  not found.

      iex> MscmpSystAuthn.access_account_exists?(access_account_name: "nonexistent_access_account")
      false
  """
  @spec access_account_exists?(Keyword.t()) :: boolean() | {:error, MscmpSystError.t()}
  defdelegate access_account_exists?(opts \\ []), to: Impl.AccessAccount

  # ==============================================================================================
  # ==============================================================================================
  #
  # Access Account Instance Association Data
  #
  # ==============================================================================================
  # ==============================================================================================

  @doc section: :access_account_instance_assoc_data
  @doc """
  Invites or re-invites an Access Account to establish access rights to a
  specific Instance.

  The invitation process creates a `syst_access_account_instance_assocs` record
  for the requested Access Account and Instance and sets the `invitation_issued`
  field to the current date/time.  Re-invitation will update an existing
  `syst_access_account_instance_assocs` record resetting invite data such as the
  invitation expiration date or resetting the declined state if the record was
  previously declined by the Access Account holder. Once a
  `syst_access_account_instance_assocs` record is accepted, it may not be re-
  invited again using this process until the record is revoked (deleted).

  `syst_access_account_instance_assocs` are unique to the Access Account and
  Instance combination and only one such record may exist for that combination
  at any one time.

  ## Parameters

    * `access_account_id` - the record ID of the Access Account to invite to the
    Instance.

    * `instance_id` - the Instance record ID to which the Access Account is
    being invited.

    * `opts` - a keyword list of optional parameters used to set record values
    and behaviors.  Available options are:

      * `create_accepted` - will create a `syst_access_account_instance_assocs`
      record which is already accepted when set `true`.  The default value is
      `false`.

      * `expiration_days` - for records that are not created as accepted and act
      as true invitations, this option sets the number of days in which an
      Access Account holder may accept the invitation.  After this time the
      invitation is considered expired and must be re-invited before it can be
      used to grant access again.  The default value for this option is 30 days.
  """
  @spec invite_to_instance(
          Types.access_account_id(),
          MscmpSystInstance.Types.instance_id(),
          Keyword.t()
        ) :: {:ok, Msdata.SystAccessAccountInstanceAssocs.t()} | {:error, MscmpSystError.t()}
  defdelegate invite_to_instance(access_account_id, instance_id, opts \\ []),
    to: Impl.AccessAccountInstanceAssoc

  @doc section: :access_account_instance_assoc_data
  @doc """
  Accepts the invitation made to an Access Account to access an Instance.

  This process is only needed in the case where a
  `syst_access_account_instance_assocs` invitation may be accepted or declined
  by the Access Account holder.  To be accepted in this process the invitation
  record must have been previously created (see `invite_to_instance/3`), must
  not be expired, previously declined, or previously accepted; trying to accept
  a record in such a state will result in an error tuple being returned.

  Naturally, the Access Account holder may choose to never accept or decline the
  invitation and may simply allow the invitation to expire.

  ## Parameters

    * `access_account_instance_assoc` - this value may be either the populated
    `Msdata.SystAccessAccountInstanceAssocs` struct to
    accept or the record ID of the record to accept.
  """
  @spec accept_instance_invite(
          Types.access_account_instance_assoc_id()
          | Msdata.SystAccessAccountInstanceAssocs.t()
        ) :: {:ok, Msdata.SystAccessAccountInstanceAssocs.t()} | {:error, MscmpSystError.t()}
  defdelegate accept_instance_invite(access_account_instance_assoc),
    to: Impl.AccessAccountInstanceAssoc

  @doc section: :access_account_instance_assoc_data
  @doc """
  Accepts the invitation made to an Access Account to access an Instance,
  referencing the record by its composite key values.

  This function performs the same process as `accept_instance_invite/1`, but
  will look up the record to accept using the Access Account, Instance, and
  Credential Type record ID values.

  ## Parameters

    * `access_account_id` - the record ID of the Access Account accepting the
    invitation to the Instance.

    * `instance_id` - the Instance record ID to which the Access Account has
    been invited.
  """
  @spec accept_instance_invite(
          Types.access_account_id(),
          MscmpSystInstance.Types.instance_id()
        ) :: {:ok, Msdata.SystAccessAccountInstanceAssocs.t()} | {:error, MscmpSystError.t()}
  defdelegate accept_instance_invite(access_account_id, instance_id),
    to: Impl.AccessAccountInstanceAssoc

  @doc section: :access_account_instance_assoc_data
  @doc """
  Declines an unaccepted/unexpired invitation made to an Access Account to
  access an Instance.

  This process is only needed in the case where a
  `syst_access_account_instance_assocs` invitation may be accepted or declined
  by the Access Account holder.  To be declined in this process the invitation
  record must have been previously created (see `invite_to_instance/3`), must
  not be expired, previously declined, or previously accepted; trying to decline
  a record in such a state will result in an error tuple being returned.

  Naturally, the Access Account holder may choose to never accept or decline the
  invitation and may simply allow the invitation to expire.

  ## Parameters

    * `access_account_instance_assoc` - this value may be either the populated
    `Msdata.SystAccessAccountInstanceAssocs` struct to
    decline or the record ID of the record to decline.
  """
  @spec decline_instance_invite(
          Types.access_account_instance_assoc_id()
          | Msdata.SystAccessAccountInstanceAssocs.t()
        ) :: {:ok, Msdata.SystAccessAccountInstanceAssocs.t()} | {:error, MscmpSystError.t()}
  defdelegate decline_instance_invite(access_account_instance_assoc),
    to: Impl.AccessAccountInstanceAssoc

  @doc section: :access_account_instance_assoc_data
  @doc """
  Declines an unaccepted/unexpired invitation made to an Access Account to
  access an Instance, referencing the record by its composite key values.

  This function performs the same process as `decline_instance_invite/1`, but
  will look up the record to decline using the Access Account, Instance, and
  Credential Type record ID values.

  ## Parameters

    * `access_account_id` - the record ID of the Access Account declining the
    invitation to the Instance.

    * `instance_id` - the Instance record ID to which the Access Account has
    been invited.
  """
  @spec decline_instance_invite(
          Types.access_account_id(),
          MscmpSystInstance.Types.instance_id()
        ) :: {:ok, Msdata.SystAccessAccountInstanceAssocs.t()} | {:error, MscmpSystError.t()}
  defdelegate decline_instance_invite(access_account_id, instance_id),
    to: Impl.AccessAccountInstanceAssoc

  @doc section: :access_account_instance_assoc_data
  @doc """
  Revokes the access or invitation to access an Instance from the given Access
  Account.

  Simply put, Access Accounts are both invited and granted access to Instances
  via Access Account Instance Association records (see:
  `Msdata.SystAccessAccountInstanceAssocs`) and this
  function deletes those records.  This has the effect of revoking the
  invitation to access an Instance from the Access Account/Credential Type
  combination.

  Records in any state of invited, accepted, or declined may be revoked/deleted
  using this function.

  ## Parameters

    * `access_account_instance_assoc` - this value may be either the populated
    `Msdata.SystAccessAccountInstanceAssocs` struct to
    revoke or the record ID of the record to revoke.
  """
  @spec revoke_instance_access(
          Types.access_account_instance_assoc_id()
          | Msdata.SystAccessAccountInstanceAssocs.t()
        ) :: :ok | {:error, MscmpSystError.t()}
  defdelegate revoke_instance_access(access_account_instance_assoc),
    to: Impl.AccessAccountInstanceAssoc

  @doc section: :access_account_instance_assoc_data
  @doc """
  Revokes the access or invitation to access an Instance from the given Access
  Account/Credential Type combination, referencing the record by its composite
  key values.

  This function performs the same action as `revoke_instance_access/1` but
  identified the record being revoked (deleted) using its composite/candidate
  key values.

  ## Parameters

    * `access_account_id` - the record ID of the Access Account from which the
    invitation to access is being revoked.

    * `instance_id` - the Instance record ID from which the Access Account had
    previously been invited to access.
  """
  @spec revoke_instance_access(
          Types.access_account_id(),
          MscmpSystInstance.Types.instance_id()
        ) :: {:ok, Msdata.SystAccessAccountInstanceAssocs.t()} | {:error, MscmpSystError.t()}
  defdelegate revoke_instance_access(access_account_id, instance_id),
    to: Impl.AccessAccountInstanceAssoc

  # ==============================================================================================
  # ==============================================================================================
  #
  # Password Rule Data
  #
  # ==============================================================================================
  # ==============================================================================================

  @doc section: :password_rule_data
  @doc """
  Bulk loads a list of passwords into the Disallowed Passwords database table.

  Typically this function will be used to receive a stream of passwords which
  should be added to the system Disallowed Passwords list.  The passwords
  passed to this function are streamed into the PostgreSQL database via a
  `COPY ms_syst.syst_disallowed_passwords FROM` command.

  The system Disallowed Password List is stored using SHA-1 hashes of the
  disallowed passwords to prevent the casual disclosure of possibly sensitive
  information including so called "Personally Identifiable Information" (PII).
  If passwords to this function are provided via plain text this function will
  convert them to the expected SHA-1 representation.

  ## Parameters

    * `password_list` - A required Enumerable of passwords to disallow. The
    passwords in this list are accepted in one of two possible formats: simple
    plain text passwords or as sha1 hashes represented using PostgreSQL's `bytea`
    textual export format (e.g. "example_pg_disallowed" =
    "\\\\x32dc749fd3ef7bcf79d125a3f9146c0f122f8763").  Which is expected depends
    on the `pg_format` option described below.

    > #### Plain Text Processing Tip {: .tip}
    >
    > If the `password_list` is using the plain text representation, some
    > sources, such as `File.stream!/3` may add an extraneous newline (or
    > similar) to the password which must be stripped prior to passing to this
    > function.  Failing to do so will result in incorrect hashing and the
    > requested passwords will not be effectively disallowed.

    * `options` - An optional Keyword List of settings with which the caller can
    influence the behavior of this function.  The available options are:

      * `pg_format` - a boolean value which indicates the format that the source
      passwords are being provided in.  If true, the passwords to disallow are
      expected to be already be SHA-1 hashed and represented using PostgreSQL's
      `bytea` textual representation; if false, the passwords are assumed to be
      represented using simple plain text which will be transformed as needed by
      this function.  The default value of this parameter is `false` for plain
      text processing.

      * `timeout` - an integer representing the number of milliseconds that the
      database transaction processing the load operation will wait prior to
      timing out with an error.  Bulk loading is assumed to be used in cases
      where a substantial amount of data might be processed; certainly enough
      data to possibly exceed the system default database transaction timeout.
      As such it is recommend to be sure the timeout here is fit for the data
      requirements expected for any given call.  The default value is 300,000
      milliseconds (5 minutes).

  ## Examples

  Loading the Disallowed Passwords List using a file listing plain text
  passwords.

      iex> MscmpSystAuthn.password_disallowed?("example_plain_disallowed")
      false
      iex> Path.join(["database", "example_plain_disallowed_passwords.txt"])
      ...>   |> File.stream!()
      ...>   |> Stream.map(&String.trim_trailing(&1, "\\n"))
      ...>   |> MscmpSystAuthn.load_disallowed_passwords()
      :ok
      iex> MscmpSystAuthn.password_disallowed?("example_plain_disallowed")
      true

  Loading the Disallowed Passwords List using a file already formatted for
  direct loading into PostgreSQL.

      iex> MscmpSystAuthn.password_disallowed?("example_pg_disallowed")
      false
      iex> Path.join(["database", "example_pg_disallowed_passwords.txt"])
      ...>   |> File.stream!()
      ...>   |> MscmpSystAuthn.load_disallowed_passwords(pg_format: true)
      :ok
      iex> MscmpSystAuthn.password_disallowed?("example_pg_disallowed")
      true
  """
  @spec load_disallowed_passwords(Enumerable.t(), Keyword.t()) ::
          :ok | {:error, MscmpSystError.t()}
  defdelegate load_disallowed_passwords(password_list, opts \\ []), to: Impl.PasswordRules

  @doc section: :password_rule_data
  @doc """
  Tests if the Disallowed Password List has any entries or not.

  Returns a simple boolean value.  If true, there are existing entries in the
  Disallowed Passwords Lists; otherwise false is returned.

  ## Examples

      iex> MscmpSystAuthn.disallowed_passwords_populated?()
      true
  """
  @spec disallowed_passwords_populated?() :: boolean()
  defdelegate disallowed_passwords_populated?(), to: Impl.PasswordRules

  @doc section: :password_rule_data
  @doc """
  Adds a new password to the Disallowed Passwords list.

  Disallowed passwords are passwords that are commonly known, are known to have
  been revealed in a successful hacking attack, or are otherwise not available
  for users to choose for their authentication credential.  Enforcing that these
  passwords are not available for use depends upon the effective
  `disallow_compromised` Password Rule for the Access Account attempting
  authentication.

  An attempt to add a password which is already on the list will succeed as
  though the password were not already part of the list.

  ## Parameters

    * `password` - The plaintext password to add to the list of disallowed
    passwords.

  ## Examples

  Adding a password successfully will simply return `:ok`.

      iex> MscmpSystAuthn.create_disallowed_password("Example Disallowed Password")
      :ok

  Any subsequent attempt to add the same password to the list again will appear
  to succeed while silently doing nothing.

      iex> MscmpSystAuthn.create_disallowed_password("Example Disallowed Password")
      :ok
  """
  @spec create_disallowed_password(Types.credential()) :: :ok | {:error, MscmpSystError.t()}
  defdelegate create_disallowed_password(password), to: Impl.PasswordRules

  @doc section: :password_rule_data
  @doc """
  Indicates whether the requested password is disallowed.

  This function returns a tuple in the form of `{:ok, <disallowed>}` where the
  `disallowed` value is either `true` meaning that the requested password is
  disallowed or `false` if the password is available for use.

  Regardless of the return of this function, disallowed passwords are only
  prevented for use if the effective `disallow_compromised` Password Rule for
  the Access Account attempting authentication is set.

  ## Parameters

    * `password` - the plaintext password to test for disallowed status.

  ## Examples

    When a password has been previously disallowed and cannot be used as a
    user credential.

      iex> MscmpSystAuthn.password_disallowed("Is Disallowed")
      {:ok, true}

    When a password has not been previously disallowed.

      iex> MscmpSystAuthn.password_disallowed("Is Not Disallowed")
      {:ok, false}
  """
  @spec password_disallowed(Types.credential()) :: {:ok, boolean()} | {:error, MscmpSystError.t()}
  defdelegate password_disallowed(password), to: Impl.PasswordRules

  @doc section: :password_rule_data
  @doc """
  Indicates whether the requested password is disallowed, raising on error.

  This function works the same as `disallowed_password/1` except this function
  returns a simple `boolean` value rather than a result tuple.  If an error is
  encountered an exception is raised.

  ## Parameters

    * `password` - the plaintext password to test for disallowed status.

  ## Examples

    When a password has been previously disallowed and cannot be used as a
    user credential.

      iex> MscmpSystAuthn.password_disallowed?("Is Disallowed")
      true

    When a password has not been previously disallowed.

      iex> MscmpSystAuthn.password_disallowed?("Is Not Disallowed")
      false

  """
  @spec password_disallowed?(Types.credential()) :: boolean()
  defdelegate password_disallowed?(password), to: Impl.PasswordRules

  @doc section: :password_rule_data
  @doc """
  Removes a password from the disallowed passwords list.

  On success, this function will return a success tuple indicating if the
  requested password was deleted from the disallowed passwords list
  (`{:ok, :deleted}`) or if the password simply wasn't found in the list
  (`{:ok, :not_found}`).

  ## Parameters

    * `password` - the plaintext password to delete from the disallowed
    passwords list.

  ## Examples

    Result when deleting a record from the list.

      iex> MscmpSystAuthn.delete_disallowed_password("No Longer Disallowed")
      {:ok, :deleted}

    Result when trying to delete a record not already on the list.

      iex> MscmpSystAuthn.delete_disallowed_password("Not on List")
      {:ok, :not_found}
  """
  @spec delete_disallowed_password(Types.credential()) ::
          {:ok, :deleted | :not_found} | {:error, MscmpSystError.t()}
  defdelegate delete_disallowed_password(password), to: Impl.PasswordRules

  @doc section: :password_rule_data
  @doc """
  Creates Owner Password Rules for the requested Owner.

  Owners may optionally define their own Password Rules for their users so long
  as their desired rules are of equal or greater stringency than the Global
  Password Rules.  If the new Owner Password Rules are defined to be less
  stringent than the current Global Password Rules, the Owner Password Rules
  will be saved as requested, but ignored when applied in favor of the more
  stringent rule.

  ## Parameters

    * `owner_id` - the record ID of the Owner for whom the Password Rules are
    being created.

    * `insert_params` - a map of the values to use when creating the new record.
    See `t:MscmpSystAuthn.Types.password_rule_params/0` for details
    regarding the available attributes.

  """
  @spec create_owner_password_rules(
          MscmpSystInstance.Types.owner_id(),
          Types.password_rule_params()
        ) ::
          {:ok, Msdata.SystOwnerPasswordRules.t()} | {:error, MscmpSystError.t() | Exception.t()}
  defdelegate create_owner_password_rules(owner_id, insert_params), to: Impl.PasswordRules

  @doc section: :password_rule_data
  @doc """
  Updates the Global Password Rules with new values.

  The Global Password Rules are created at system installation time with a
  default and recommended set of values, but these values may be customized as
  desired any time after installation.

  Note that the original Global Password Rules data will be retrieved for use in
  the update process and that no Ecto optimistic locking will be employed with
  this update.

  ## Parameters

    * `update_params` - a map of the values to use when updating the Global
    Password Rules record. See
    `t:MscmpSystAuthn.Types.password_rule_params/0` for details
    regarding the available attributes.
  """
  @spec update_global_password_rules(Types.password_rule_params()) ::
          {:ok, Msdata.SystGlobalPasswordRules.t()} | {:error, MscmpSystError.t() | Exception.t()}
  defdelegate update_global_password_rules(update_params), to: Impl.PasswordRules

  @doc section: :password_rule_data
  @doc """
  Updates the Global Password Rules with new values using a caller provided
  data source record.

  This function works the same as described in `create_update_global_password_rules/1`
  except that in this version the caller must also provide a source
  data struct to act as the basis of the update.  Ecto optimistic locking will
  be applied to the update process.

  ## Parameters

    * `global_password_rules` - a fully populated
    `Msdata.SystGlobalPasswordRules` record representing
    the state of the Global Password Rules prior to the change.

    * `update_params` - a map of the values to use when updating the Global
    Password Rules record. See
    `t:MscmpSystAuthn.Types.password_rule_params/0` for details
    regarding the available attributes.
  """
  @spec update_global_password_rules(
          Msdata.SystGlobalPasswordRules.t(),
          Types.password_rule_params()
        ) ::
          {:ok, Msdata.SystGlobalPasswordRules.t()} | {:error, MscmpSystError.t() | Exception.t()}
  defdelegate update_global_password_rules(global_password_rules, update_params),
    to: Impl.PasswordRules

  @doc section: :password_rule_data
  @doc """
  Updates the Owner Password Rules with new values.

  After creation, Owner Password Rules may be updated with new values as might
  meet the specific needs of the Owner.

  ## Parameters

    * `owner` - the record ID of the Owner for whom the Password Rules are
    being updated or the fully populated data struct representing the current
    Owner Password Rules.  Note that if the data struct is provided Ecto
    optimistic locking will be in effect.

    * `update_params` - a map of the values to use when updating the Owner
    Password Rules record. See
    `t:MscmpSystAuthn.Types.password_rule_params/0` for details
    regarding the available attributes.
  """
  @spec update_owner_password_rules(
          MscmpSystInstance.Types.owner_id() | Msdata.SystOwnerPasswordRules.t(),
          Types.password_rule_params()
        ) ::
          {:ok, Msdata.SystOwnerPasswordRules.t()} | {:error, MscmpSystError.t() | Exception.t()}
  defdelegate update_owner_password_rules(owner, update_params), to: Impl.PasswordRules

  @doc section: :password_rule_data
  @doc """
  Retrieves the currently active Global Password Rules.

  On successful retrieval a success tuple in the form of `{:ok, <record>}` is
  returned where record is a `Msdata.SystGlobalPasswordRules`
  struct.  Any exceptions are returned via an error tuple.
  """
  @spec get_global_password_rules() ::
          {:ok, Msdata.SystGlobalPasswordRules.t()} | {:error, MscmpSystError.t()}
  defdelegate get_global_password_rules, to: Impl.PasswordRules

  @doc section: :password_rule_data
  @doc """
  Retrieves the currently active Global Password Rules, raising on error.

  This function works the same as `get_global_password_rules/0` except that
  any errors cause an exception to be raised.
  """
  @spec get_global_password_rules!() :: Msdata.SystGlobalPasswordRules.t()
  defdelegate get_global_password_rules!, to: Impl.PasswordRules

  @doc section: :password_rule_data
  @doc """
  Retrieves the currently active Owner Password Rules for the requested Owner.

  On successful retrieval a success tuple in the form of `{:ok, <record>}` is
  returned where `<record>` is a populated
  `Msdata.SystownerPasswordRules` struct if Password Rules
  for the requested Owner was found or `nil` otherwise.  Any exceptions are
  returned via an error tuple.

  ## Parameters

    * `owner_id` - the Owner record ID for whom to retrieve Password Rules.
  """
  @spec get_owner_password_rules(MscmpSystInstance.Types.owner_id()) ::
          {:ok, Msdata.SystOwnerPasswordRules.t()}
          | {:ok, :not_found}
          | {:error, MscmpSystError.t() | Exception.t()}
  defdelegate get_owner_password_rules(owner_id), to: Impl.PasswordRules

  @doc section: :password_rule_data
  @doc """
  Retrieves the currently active Owner Password Rules for the requested Owner,
  raising on error.

  This function works the same as `get_owner_password_rules/1` except that
  any errors cause an exception to be raised.

  ## Parameters

    * `owner_id` - the Owner record ID for whom to retrieve Password Rules.
  """
  @spec get_owner_password_rules!(MscmpSystInstance.Types.owner_id()) ::
          Msdata.SystOwnerPasswordRules.t() | :not_found
  defdelegate get_owner_password_rules!(owner_id), to: Impl.PasswordRules

  @doc section: :password_rule_data
  @doc """
  Converts a Global or Owner Password Rule struct into the generic map based
  Password Rule required by some functions.

  `Msdata.SystGlobalPasswordRules` and `Msdata.SystOwnerPasswordRules` both
  define a standard set of known password rules, but do so as different data
  types.  While this works well for database record management features, testing
  and validating actual password rules do not benefit from the distinction.
  In these evaluation scenarios it's better to treat the password rule without
  consideration of its source.  This function returns the generic representation
  that certain evaluation features such as `test_credential/2` are expecting.
  """
  @spec get_generic_password_rules(
          Msdata.SystGlobalPasswordRules.t() | Msdata.SystOwnerPasswordRules.t(),
          Types.access_account_id() | nil
        ) :: Types.PasswordRules.t() | nil
  defdelegate get_generic_password_rules(pwd_rules_struct, access_account_id \\ nil),
    to: Impl.PasswordRules

  @doc section: :password_rule_data
  @doc """
  Retrieves the Password Rules to apply for a requested Access Account as
  identified by its record ID.

  When evaluating the validity of candidate passwords for a user the system
  retrieves the Global Password Rules and then the Access Account Owner Password
  Rules, if such Rules have been defined.  The system will compare each of the
  Rules in the Global and Owner Password Rules with each other and select the
  rule which demands the greatest stringency.  This process results in a
  composite Password Rule which can then be applied to test any candidate
  password for validity. This calculated composite Password Rule is what is
  returned by this function.

  The return value is wrapped in a result tuple, `{:ok, <rule>}` on success and
  `{:error, <exception>}` in cases of failure.

  ## Parameters

    * `access_account_id` - the Access Account record ID of the user.
  """
  @spec get_access_account_password_rule(Types.access_account_id()) ::
          {:ok, Types.PasswordRules.t()} | {:error, MscmpSystError.t() | Exception.t()}
  defdelegate get_access_account_password_rule(access_account_id), to: Impl.PasswordRules

  @doc section: :password_rule_data
  @doc """
  Retrieves the Password Rules to apply for a requested Access Account as
  identified by its record ID, raising on error.

  This function works the same as `get_access_account_password_rule/1` except
  that any errors cause an exception to be raised.

  ## Parameters

    * `access_account_id` - the Access Account record ID of the user.
  """
  @spec get_access_account_password_rule!(Types.access_account_id()) :: Types.PasswordRules.t()
  defdelegate get_access_account_password_rule!(access_account_id), to: Impl.PasswordRules

  @doc section: :password_rule_data
  @doc """
  Compares a "Test" set of Password Rules against a "Standard" set of Password
  Rules and reports on which of the "Test" Rules are considered less stringent
  than the "Standard" Rules.

  The primary use case for this function is to test how Owner Password Rules
  ("Test" Rules) compare against the Global Password Rules ("Standard" Rules),
  but the function can compare any two rules.

  The return value of this function is wrapped in a result tuple. A result of
  `{:ok, <rule violations>}` is returned on success and an error tuple in the
  form of `{:error, <exception>}` is returned on error.  The `<rule violations>`
  value is a Keyword List where each tuple's key represents the rule violated
  and the tuple's value is the required value for that rule; whether the
  required value is a minimum or maximum depends on the nature of the specific
  rule being reported.

  ## Parameters

    * `test_rules` - a Password Rule which will be tested against the value
    of the `standard_rules`.  Where the `test_rules` are less stringent than the
    `standard_rules`, a violation is reported in the result.

    * `standard_rules` - the "Standard" against which the `test_rules` are
    judged.  This parameter is optional and when nil the Global Password
    Rule is retrieved and used as the default "Standard" Rules.  Otherwise
    either a generic `t:MscmpSystAuthn.Types.PasswordRules.t/0` value
    or a populated `Msdata.SystGlobalPasswordRules` data
    struct may be provided.
  """
  @spec verify_password_rules(
          Types.PasswordRules.t(),
          Msdata.SystGlobalPasswordRules.t() | Types.PasswordRules.t() | nil
        ) ::
          {:ok, Keyword.t(Types.password_rule_violations())}
          | {:error, MscmpSystError.t() | Exception.t()}
  defdelegate verify_password_rules(test_rules, standard_rules \\ nil), to: Impl.PasswordRules

  @doc section: :password_rule_data
  @doc """
  Compares a "Test" set of Password Rules against a "Standard" set of Password
  Rules and reports on which of the "Test" Rules are considered less stringent
  than the "Standard" Rules, raising on error.

  This function works the same as `verify_password_rules/2` except that any
  errors cause an exception to be raised.

  ## Parameters

    * `test_rules` - a Password Rule which will be tested against the value
    of the `standard_rules`.  Where the `test_rules` are less stringent than the
    `standard_rules`, a violation is reported in the result.

    * `standard_rules` - the "Standard" against which the `test_rules` are
    judged.  This parameter is optional and when nil the Global Password
    Rule is retrieved and used as the default "Standard" Rules.  Otherwise
    either a generic `t:MscmpSystAuthn.Types.PasswordRules.t/0` value
    or a populated `Msdata.SystGlobalPasswordRules` data
    struct may be provided.
  """
  @spec verify_password_rules!(
          Types.PasswordRules.t(),
          Msdata.SystGlobalPasswordRules.t() | Types.PasswordRules.t() | nil
        ) ::
          Keyword.t(Types.password_rule_violations())
  defdelegate verify_password_rules!(test_rules, standard_rules \\ nil),
    to: Impl.PasswordRules

  @doc section: :password_rule_data
  @doc """
  Deletes an Owner Password Rules record from the system.

  ## Parameters

    * `owner_id` - the Owner record ID whose Password Rules are to be deleted.
  """
  @spec delete_owner_password_rules(MscmpSystInstance.Types.owner_id()) ::
          {:ok, :deleted | :not_found} | {:error, MscmpSystError.t() | Exception.t()}
  defdelegate delete_owner_password_rules(owner_id), to: Impl.PasswordRules

  @doc section: :password_rule_data
  @doc """
  Tests a candidate password against the effective Password Rules for a given
  Access Account.

  Prior to attempting to save a Password Credential, it should be tested for
  compliance with the Global Password Rules and any Owner Password Rules that
  exist for the Owner of the Access Account.  This function performs that test
  and will return all of the violations detected.  If no issues are detected,
  a success tuple with a value of empty list will be returned (`{:ok, []}`).

  Note that this function is recommended to run prior to attempting to save a
  Password Credential, but is not required.  Any function which can save a new
  password to the database will independently test the candidate password
  against the effective Password Rules prior to saving the Credential, erroring
  on any invalid password.

  ## Parameters

    * `access_account_id` - the record ID of the Access Account for whom to
    perform the test.  The applicable Password Rules may derive from the
    Access Account Owner if the Access Account is in fact owned.

    * `plaintext_pwd` - the candidate Password to test against the rules.

  ## Examples

    A successful password test.

      iex> {:ok, access_account_id} =
      ...>   MscmpSystAuthn.get_access_account_id_by_name("example_accnt")
      iex> MscmpSystAuthn.test_credential(access_account_id, "A Passing Password.")
      {:ok, []}

    An invalid password test.

      iex> {:ok, access_account_id} =
      ...>   MscmpSystAuthn.get_access_account_id_by_name("example_accnt")
      iex> MscmpSystAuthn.test_credential(access_account_id, "short")
      {:ok, [password_rule_length_min: 8]}
  """
  @spec test_credential(Types.access_account_id() | Types.PasswordRules.t(), Types.credential()) ::
          {:ok, Keyword.t(Types.password_rule_violations())}
          | {:error, MscmpSystError.t() | Exception.t()}
  defdelegate test_credential(pwd_rules_or_access_account_id, plaintext_pwd),
    to: Impl.Credential.Password

  # ==============================================================================================
  # ==============================================================================================
  #
  # Network Rule Data
  #
  # ==============================================================================================
  # ==============================================================================================

  @doc section: :network_rule_data
  @doc """
  Indicates whether the provided host IP address is to be denied access to the
  system.

  This function returns a tuple in the form of `{:ok, <disallowed>}` where the
  `disallowed` value is either `true` meaning that the requested host is
  disallowed from authenticating with the system or `false` if the host is
  permitted to attempt an authentication.

  ## Parameters

    * `host_address` - the host IP address to test.  Typically this will be the
    host address of a user wishing to authenticate with the system.

  ## Examples

    An allowed host will return a `false` result tuple.

      iex> import MscmpSystNetwork, only: [sigil_i: 2]
      iex> MscmpSystAuthn.host_disallowed(~i"10.150.150.10")
      {:ok, false}

    A disallowed host returns a `true` result tuple.

      iex> import MscmpSystNetwork, only: [sigil_i: 2]
      iex> MscmpSystAuthn.host_disallowed(~i"10.123.123.5")
      {:ok, true}
  """
  @spec host_disallowed(Types.host_address()) :: {:ok, boolean()} | {:error, MscmpSystError.t()}
  defdelegate host_disallowed(host_address), to: Impl.NetworkRules

  @doc section: :network_rule_data
  @doc """
  Indicates whether the provided host IP address is to be denied access to the
  system, raising on error.

  This function works the same as `host_disallowed/1` except this function
  returns its result without wrapping it in a result tuple.  If an error is
  encountered an exception is raised.

  ## Parameters

    * `host_address` - the host IP address to test.  Typically this will be the
    host address of a user wishing to authenticate with the system.

  ## Examples

    An allowed host will return a `false` value.

      iex> import MscmpSystNetwork, only: [sigil_i: 2]
      iex> MscmpSystAuthn.host_disallowed?(~i"10.150.150.10")
      false

    A disallowed host returns a `true` value.

      iex> import MscmpSystNetwork, only: [sigil_i: 2]
      iex> MscmpSystAuthn.host_disallowed?(~i"10.123.123.5")
      true
  """
  @spec host_disallowed?(Types.host_address()) :: boolean()
  defdelegate host_disallowed?(host_address), to: Impl.NetworkRules

  @doc section: :network_rule_data
  @doc """
  Adds a host IP address to the global disallowed hosts list.

  Disallowed hosts are IP addresses which are prevented from authenticating
  users with the system, and by extension prevents host access to application
  functions generally.  Hosts are disallowed on a global basis and may be added
  to the list based on system heuristics which detect suspicious activity.

  Successfully adding a host to the list returns a success tuple and a struct
  representing the record just created.  Attempting to add a host which is
  already part of the list will also result in a success tuple, but no record is
  returned.

  ## Parameters

    * `host_address` - the IP address of the host to disallow.

  ## Examples

    Adding a new host to the list.

      iex> import MscmpSystNetwork, only: [sigil_i: 2]
      iex> {:ok, false} = MscmpSystAuthn.host_disallowed(~i"10.123.123.20")
      iex> {:ok, %Msdata.SystDisallowedHosts{}} =
      ...>   MscmpSystAuthn.create_disallowed_host(~i"10.123.123.20")

    Attempting to add a host already on the list.

      iex> import MscmpSystNetwork, only: [sigil_i: 2]
      iex> {:ok, true} = MscmpSystAuthn.host_disallowed(~i"10.123.123.3")
      iex> {:ok, nil} =
      ...>   MscmpSystAuthn.create_disallowed_host(~i"10.123.123.3")
  """
  @spec create_disallowed_host(Types.host_address()) ::
          {:ok, Msdata.SystDisallowedHosts.t()} | {:error, MscmpSystError.t()}
  defdelegate create_disallowed_host(host_address), to: Impl.NetworkRules

  @doc section: :network_rule_data
  @doc """
  Retrieves a Disallowed Host record from the database as identified by its host
  address.

  ## Parameters

    * `host_address` - the IP address of the disallowed host record to retrieve.

  ## Example

    Retrieving a Disallowed Host record by IP address.

      iex> import MscmpSystNetwork, only: [sigil_i: 2]
      iex> {:ok, %Msdata.SystDisallowedHosts{}} =
      ...>   MscmpSystAuthn.get_disallowed_host_record_by_host(~i"10.123.123.4")

    Attempting to retrieve a record for a host not on the list.

      iex> import MscmpSystNetwork, only: [sigil_i: 2]
      iex> MscmpSystAuthn.get_disallowed_host_record_by_host(~i"10.125.120.20")
      {:ok, nil}
  """
  @spec get_disallowed_host_record_by_host(Types.host_address()) ::
          {:ok, Msdata.SystDisallowedHosts.t() | nil} | {:error, MscmpSystError.t()}
  defdelegate get_disallowed_host_record_by_host(host_addr), to: Impl.NetworkRules

  @doc section: :network_rule_data
  @doc """
  Retrieves a Disallowed Host record from the database as identified by its host
  address, raising on error.

  This function works the same as `get_disallowed_host_record_by_host/1` except
  this function returns its result without wrapping it in a result tuple.  If an
  error is encountered an exception is raised.

  ## Parameters

    * `host_address` - the IP address of the disallowed host record to retrieve.

  ## Example

    Retrieving a Disallowed Host record by IP address.

      iex> import MscmpSystNetwork, only: [sigil_i: 2]
      iex> %Msdata.SystDisallowedHosts{} =
      ...>   MscmpSystAuthn.get_disallowed_host_record_by_host!(~i"10.123.123.4")

    Attempting to retrieve a record for a host not on the list.

      iex> import MscmpSystNetwork, only: [sigil_i: 2]
      iex> MscmpSystAuthn.get_disallowed_host_record_by_host!(~i"10.125.120.20")
      nil
  """
  @spec get_disallowed_host_record_by_host!(Types.host_address()) ::
          Msdata.SystDisallowedHosts.t() | nil
  defdelegate get_disallowed_host_record_by_host!(host_addr), to: Impl.NetworkRules

  @doc section: :network_rule_data
  @doc """
  Deletes a host IP address from the Disallowed Hosts list as looked up by the
  host IP address.

  If the record is found and deleted a success tuple in the form `{:ok, :deleted}`
  is returned.  If the record is not found the success tuple `{:ok, :not_found}`
  is returned.  Any other condition would cause an error tuple to be returned.

  Once a host is removed from the Disallowed Hosts list, users are allowed to
  authenticate from the host, so long as no other effective Network Rule
  prevents the action.

  ## Parameters

    * `host_addr` - the IP address of the host that is no longer to be
    disallowed.

  ## Examples

    Deleting a host that does exist in the list.

      iex> import MscmpSystNetwork, only: [sigil_i: 2]
      iex> {:ok, true} = MscmpSystAuthn.host_disallowed(~i"10.10.251.1")
      iex> {:ok, :deleted} =
      ...>   MscmpSystAuthn.delete_disallowed_host_addr(~i"10.10.251.1")
      iex> {:ok, false} = MscmpSystAuthn.host_disallowed(~i"10.10.251.1")

    Attempting to delete a host not already on the list.

      iex> import MscmpSystNetwork, only: [sigil_i: 2]
      iex> {:ok, false} = MscmpSystAuthn.host_disallowed(~i"10.10.251.10")
      iex> {:ok, :not_found} =
      ...>   MscmpSystAuthn.delete_disallowed_host_addr(~i"10.10.251.10")
  """
  @spec delete_disallowed_host_addr(Types.host_address()) ::
          {:ok, :deleted | :not_found} | {:error, MscmpSystError.t()}
  defdelegate delete_disallowed_host_addr(host_addr), to: Impl.NetworkRules

  @doc section: :network_rule_data
  @doc """
  Retrieves a Disallowed Host record by the record ID.

  This function assumes the record exists.  If the record does not exist an
  error tuple will be returned.

  ## Parameters

    * `disallowed_host_id` - the record ID of the Disallowed Host record to retrieve.

  ## Example

    Retrieving a Disallowed Host record by record ID.

    ```elixir
    {:ok, %Msdata.SystDisallowedHosts{}} =
      MscmpSystAuthn.get_disallowed_host_record_by_id(
        "ad7f2030-5895-11ed-a888-0f8a20e745a9")
    ```
  """
  @spec get_disallowed_host_record_by_id(Types.disallowed_host_id()) ::
          {:ok, Msdata.SystDisallowedHosts.t()} | {:error, MscmpSystError.t() | Exception.t()}
  defdelegate get_disallowed_host_record_by_id(disallowed_host_id), to: Impl.NetworkRules

  @doc section: :network_rule_data
  @doc """
  Retrieves a Disallowed Host record by the record ID, raising on error.

  This function works the same as `get_disallowed_host_record_by_id/1` except
  this function returns its result without wrapping it in a result tuple.  If an
  error is encountered, including if the record does not exist, an exception is
  raised.

  ## Parameters

    * `disallowed_host_id` - the record ID of the Disallowed Host record to retrieve.

  ## Example

    Retrieving a Disallowed Host record by record ID.

    ```elixir
    %Msdata.SystDisallowedHosts{} =
      MscmpSystAuthn.get_disallowed_host_record_by_id!(
        "ad7f2030-5895-11ed-a888-0f8a20e745a9")
    ```
  """
  @spec get_disallowed_host_record_by_id!(Types.disallowed_host_id()) ::
          Msdata.SystDisallowedHosts.t()
  defdelegate get_disallowed_host_record_by_id!(disallowed_host_id), to: Impl.NetworkRules

  @doc section: :network_rule_data
  @doc """
  Deletes a host IP address from the Disallowed Hosts list based on either a
  `Msdata.SystDisallowedHosts` record or the ID of such a
  record.

  If the record is found and deleted a success tuple in the form `{:ok, :deleted}`
  is returned.  If the record is not found the success tuple `{:ok, :not_found}`
  is returned.

  Once a host is removed from the Disallowed Hosts list, users are allowed to
  authenticate from the host, so long as no other effective Network Rule
  prevents the action.

  ## Parameters

    * `disallowed_host` - either the fully populated
    `Msdata.SystDisallowedHosts` data struct for the
    record to delete or the ID of the record.  Note that when the data struct
    is provided Ecto optimistic locking is applied to the the delete operation.


  ## Examples

    Deleting a host by record ID.

      iex> import MscmpSystNetwork, only: [sigil_i: 2]
      iex> {:ok, target_host_record} =
      ...>   MscmpSystAuthn.get_disallowed_host_record_by_host(~i"10.10.250.4")
      iex> MscmpSystAuthn.delete_disallowed_host(target_host_record.id)
      {:ok, :deleted}

    Deleting a host by record struct.

      iex> import MscmpSystNetwork, only: [sigil_i: 2]
      iex> {:ok, target_host_record} =
      ...>   MscmpSystAuthn.get_disallowed_host_record_by_host(~i"10.10.250.5")
      iex> MscmpSystAuthn.delete_disallowed_host(target_host_record)
      {:ok, :deleted}

    Deleting a struct for a no longer existent record.

      iex> import MscmpSystNetwork, only: [sigil_i: 2]
      iex> {:ok, target_host_record} =
      ...>   MscmpSystAuthn.get_disallowed_host_record_by_host(~i"10.10.250.6")
      iex> MscmpSystAuthn.delete_disallowed_host(target_host_record)
      {:ok, :deleted}
      iex> MscmpSystAuthn.delete_disallowed_host(target_host_record)
      {:ok, :not_found}
  """
  @spec delete_disallowed_host(Types.disallowed_host_id() | Msdata.SystDisallowedHosts.t()) ::
          {:ok, :deleted | :not_found} | {:error, MscmpSystError.t()}
  defdelegate delete_disallowed_host(disallowed_host), to: Impl.NetworkRules

  @doc section: :network_rule_data
  @doc """
  Returns the Network Rule which should be applied for the given Host IP Address.

  This function compares the provided Host IP Address against the applicable
  Network Rules which apply to it and return the specific rule which should be
  applied during the authentication process.

  ## Network Rule Precedence

  The specific rules to check for applicability depends on the other provided
  parameters.  The available Network Rule sets in order of precedence are:

    1. __Disallowed Hosts__: Globally disallowed hosts are always checked first and
    no later rule can override the denial.  Only removing the host from the
    Disallowed Hosts List can reverse this denial.

    2. __Global Network Rules__: These are rules applied to all presented Host IP
    Addresses.

    3. __Instance Network Rules__: Rules defined by Instance Owners and are the
    most granular rule level available.  These Network Rules are only evaluated
    if the `instance_id` parameter is provided.

    4. __Owner Network Rules__: Network Rules which are applicable to all
    Instances of a given Owner, provided no superseding Instance Network Rule
    was found.  This rule set is included if either the `instance_id` or
    `owner_id` parameter is provided.

    5. __Default Network Rule__: When no explicitly defined Network Rule has
    been found for a host, this rule will apply implicitly.  The current rule
    grants access from any host.

  ## Return Value

    This function returns a result tuple.  The value element of the result tuple
    is a map of type `t:MscmpSystAuthn.Types.AppliedNetworkRule.t/0`.
    The map indicates which precedence group the rule came from, the ID of the
    Network Rule record if the rule was derived from the various Network Rule
    data tables, and the Functional Type of the rule: `:allow` meaning the
    rule explicitly allows the host to attempt an authentication, or `:deny`
    indicating that the host is not allowed to attempt authentication.

  ## Parameters

    * `host_address` - the Host IP Address which the user wishes to authenticate
    from.

    * `instance_id` - the record ID of an Instance to which the user wants to
    gain access.  This parameter is optional, though excluding this parameter
    will leave the Instance Network Rules might properly apply unevaluated.  If
    this parameter is provided, the Owner of the Instance is implied and there
    is no need to also supply the `owner_id` parameter.

    * `owner_id` - the record ID of an Owner which owns the candidate Instances
    to which the user wishes to authenticate.  This parameter is not required if
    the `instance_id` parameter has been provided.  Otherwise, this parameter is
    optional, though if the Owner has not been resolved through this parameter
    or via the `instance_id`, the Owner Network Rules that might apply to the
    authentication attempt will not be applied.

  ## Examples

    When the host is a member of the Disallowed Hosts lists.

      iex> import MscmpSystNetwork, only: [sigil_i: 2]
      iex> {:ok,
      ...>   %MscmpSystAuthn.Types.AppliedNetworkRule{
      ...>     functional_type: :deny, network_rule_id: id, precedence: :disallowed
      ...>   }
      ...>  } =  MscmpSystAuthn.get_applied_network_rule(~i"10.123.123.3")
      iex> is_binary(id)
      true

    When the Host IP Address does not match any explicitly defined rule and the
    implicit rule applies.

      iex> import MscmpSystNetwork, only: [sigil_i: 2]
      iex> MscmpSystAuthn.get_applied_network_rule(~i"10.124.124.3")
      {:ok,
        %MscmpSystAuthn.Types.AppliedNetworkRule{
          functional_type: :allow, network_rule_id: nil, precedence: :implied
        }
      }

    When a Global Network Rule explicitly allows the Host IP Address to attempt
    authentication.

      iex> import MscmpSystNetwork, only: [sigil_i: 2]
      iex> {:ok,
      ...>   %MscmpSystAuthn.Types.AppliedNetworkRule{
      ...>     functional_type: :allow, network_rule_id: id, precedence: :global
      ...>   }
      ...> } = MscmpSystAuthn.get_applied_network_rule(~i"10.125.125.3")
      iex> is_binary(id)
      true

    Note that while the examples did not include Instance or Owner IDs, the
    examples are none-the-less representative of cases where they are included.

  """
  @spec get_applied_network_rule(
          Types.host_address(),
          MscmpSystInstance.Types.instance_id() | nil,
          MscmpSystInstance.Types.owner_id() | nil
        ) :: {:ok, Types.AppliedNetworkRule.t()} | {:error, MscmpSystError.t() | Exception.t()}
  defdelegate get_applied_network_rule(
                host_address,
                instance_id \\ nil,
                instance_owner_id \\ nil
              ),
              to: Impl.NetworkRules

  @doc section: :network_rule_data
  @doc """
  Returns the Network Rule which should be applied for the given Host IP
  Address, raising on error.

  This function works the same as `get_applied_network_rule/3` except this
  function returns its result without wrapping it in a result tuple.  If an
  error is encountered an exception is raised.

  ## Parameters

    * `host_address` - the Host IP Address which the user wishes to authenticate
    from.

    * `instance_id` - the record ID of an Instance to which the user wants to
    gain access.  This parameter is optional, though excluding this parameter
    will leave the Instance Network Rules might properly apply unevaluated.  If
    this parameter is provided, the Owner of the Instance is implied and there
    is no need to also supply the `owner_id` parameter.

    * `owner_id` - the record ID of an Owner which owns the candidate Instances
    to which the user wishes to authenticate.  This parameter is not required if
    the `instance_id` parameter has been provided.  Otherwise, this parameter is
    optional, though if the Owner has not been resolved through this parameter
    or via the `instance_id`, the Owner Network Rules that might apply to the
    authentication attempt will not be applied.

  ## Examples

    When the host is a member of the Disallowed Hosts lists.

      iex> import MscmpSystNetwork, only: [sigil_i: 2]
      iex> %MscmpSystAuthn.Types.AppliedNetworkRule{
      ...>   functional_type: :deny, network_rule_id: id, precedence: :disallowed
      ...> } = MscmpSystAuthn.get_applied_network_rule!(~i"10.123.123.3")
      iex> is_binary(id)
      true

    When the Host IP Address does not match any explicitly defined rule and the
    implicit rule applies.

      iex> import MscmpSystNetwork, only: [sigil_i: 2]
      iex> MscmpSystAuthn.get_applied_network_rule!(~i"10.124.124.3")
      %MscmpSystAuthn.Types.AppliedNetworkRule{
        functional_type: :allow, network_rule_id: nil, precedence: :implied
      }

    When a Global Network Rule explicitly allows the Host IP Address to attempt
    authentication.

      iex> import MscmpSystNetwork, only: [sigil_i: 2]
      iex> %MscmpSystAuthn.Types.AppliedNetworkRule{
      ...>   functional_type: :allow, network_rule_id: id, precedence: :global
      ...> } = MscmpSystAuthn.get_applied_network_rule!(~i"10.125.125.3")
      iex> is_binary(id)
      true

    Note that while the examples did not include Instance or Owner IDs, the
    examples are none-the-less representative of cases where they are included.
  """
  @spec get_applied_network_rule!(
          Types.host_address(),
          MscmpSystInstance.Types.instance_id() | nil,
          MscmpSystInstance.Types.owner_id() | nil
        ) :: Types.AppliedNetworkRule.t()
  defdelegate get_applied_network_rule!(
                host_address,
                instance_id \\ nil,
                instance_owner_id \\ nil
              ),
              to: Impl.NetworkRules

  @doc section: :network_rule_data
  @doc """
  Creates a new Global Network Rule using the provided parameters.

  Global Network Rules are checked prior to all attempted user authentication
  events and have precedence over Owner and Instance Network Rules, though they
  are secondary to the Disallowed Hosts list.

  On successful creation, a result tuple in the form `{:ok, <new record>}` is
  returned where the <new record> is the fully populated Data struct of the
  record just created.  If an exception is raised this function will return a
  failure tuple in the form of `{:error, <exception data>}`.

  ## Parameters

    * `insert_params` - a map representing the values to use when creating the
    new Global Network Rule.  See
    `t:MscmpSystAuthn.Types.global_network_rule_params/0` for the
    available attributes.

  ## Example

    Adding a new "Allow" Global Network Rule for a CIDR network.

      iex> import MscmpSystNetwork, only: [sigil_i: 2]
      iex> new_global_rule = %{
      ...>   ordering: 20,
      ...>   functional_type: :allow,
      ...>   ip_host_or_network: ~i"10.100.150.0/24"
      ...> }
      iex> {:ok, %Msdata.SystGlobalNetworkRules{}} =
      ...>   MscmpSystAuthn.create_global_network_rule(new_global_rule)

    Adding a new "Deny" Global Network Rule for an IP Address range.

      iex> import MscmpSystNetwork, only: [sigil_i: 2]
      iex> new_global_rule = %{
      ...>   ordering: 21,
      ...>   functional_type: :deny,
      ...>   ip_host_or_network: nil,
      ...>   ip_host_range_lower: ~i"10.100.151.1",
      ...>   ip_host_range_upper: ~i"10.100.152.254"
      ...> }
      iex> {:ok, %Msdata.SystGlobalNetworkRules{}} =
      ...>   MscmpSystAuthn.create_global_network_rule(new_global_rule)
  """
  @spec create_global_network_rule(Types.global_network_rule_params()) ::
          {:ok, Msdata.SystGlobalNetworkRules.t()} | {:error, MscmpSystError.t()}
  defdelegate create_global_network_rule(insert_params), to: Impl.NetworkRules

  @doc section: :network_rule_data
  @doc """
  Creates a new Owner Network Rule using the provided parameters.

  Owner Network Rules the checked after the Disallowed Hosts list, the Global
  Network Rules, and the Instance Network Rules and apply to all Instances owned
  by the specified Owner, unless a higher precedence rule already applies to the
  host.

  On successful creation, a result tuple in the form `{:ok, <new record>}` is
  returned where the <new record> is the fully populated Data struct of the
  record just created.  If an exception is raised this function will return a
  failure tuple in the form of `{:error, <exception data>}`.

  ## Parameters

    * `owner_id` - the record ID of the Owner for whom the Owner Network Rule is
    being created.

    * `insert_params` - a map representing the values to use when creating the
    new Owner Network Rule.  See
    `t:MscmpSystAuthn.Types.owner_network_rule_params/0` for the
    available attributes.

  ## Example

    Adding a new "Allow" Owner Network Rule for a CIDR network.

      iex> import MscmpSystNetwork, only: [sigil_i: 2]
      iex> {:ok, owner_id} = MscmpSystInstance.get_owner_id_by_name("owner1")
      iex> new_owner_rule = %{
      ...>   ordering: 1,
      ...>   functional_type: :allow,
      ...>   ip_host_or_network: ~i"10.100.160.0/24"
      ...> }
      iex> {:ok, %Msdata.SystOwnerNetworkRules{}} =
      ...>   MscmpSystAuthn.create_owner_network_rule(owner_id, new_owner_rule)

    Adding a new "Deny" Owner Network Rule for an IP Address range.

      iex> import MscmpSystNetwork, only: [sigil_i: 2]
      iex> {:ok, owner_id} = MscmpSystInstance.get_owner_id_by_name("owner1")
      iex> new_owner_rule = %{
      ...>   ordering: 2,
      ...>   functional_type: :deny,
      ...>   ip_host_or_network: nil,
      ...>   ip_host_range_lower: ~i"10.100.161.1",
      ...>   ip_host_range_upper: ~i"10.100.162.254"
      ...> }
      iex> {:ok, %Msdata.SystOwnerNetworkRules{}} =
      ...>   MscmpSystAuthn.create_owner_network_rule(owner_id, new_owner_rule)
  """
  @spec create_owner_network_rule(
          MscmpSystInstance.Types.owner_id(),
          Types.owner_network_rule_params()
        ) ::
          {:ok, Msdata.SystOwnerNetworkRules.t()} | {:error, MscmpSystError.t()}
  defdelegate create_owner_network_rule(owner_id, insert_params), to: Impl.NetworkRules

  @doc section: :network_rule_data
  @doc """
  Creates a new Instance Network Rule using the provided parameters.

  Instance Network Rules the checked after the Disallowed Hosts list, the Global
  Network Rules, and the Instance Network Rules and apply to all Instances owned
  by the specified Instance, unless a higher precedence rule already applies to the
  host.

  On successful creation, a result tuple in the form `{:ok, <new record>}` is
  returned where the <new record> is the fully populated Data struct of the
  record just created.  If an exception is raised this function will return a
  failure tuple in the form of `{:error, <exception data>}`.

  ## Parameters

    * `instance_id` - the record ID of the Instance for whom the Instance Network Rule is
    being created.

    * `insert_params` - a map representing the values to use when creating the
    new Instance Network Rule.  See
    `t:MscmpSystAuthn.Types.instance_network_rule_params/0` for the
    available attributes.

  ## Example

    Adding a new "Allow" Instance Network Rule for a CIDR network.

      iex> import MscmpSystNetwork, only: [sigil_i: 2]
      iex> {:ok, instance_id} =
      ...>   MscmpSystInstance.get_instance_id_by_name("app1_owner1_instance_types_std")
      iex> new_instance_rule = %{
      ...>   ordering: 1,
      ...>   functional_type: :allow,
      ...>   ip_host_or_network: ~i"10.100.170.0/24"
      ...> }
      iex> {:ok, %Msdata.SystInstanceNetworkRules{}} =
      ...>   MscmpSystAuthn.create_instance_network_rule(instance_id, new_instance_rule)

    Adding a new "Deny" Instance Network Rule for an IP Address range.

      iex> import MscmpSystNetwork, only: [sigil_i: 2]
      iex> {:ok, instance_id} =
      ...>   MscmpSystInstance.get_instance_id_by_name("app1_owner1_instance_types_std")
      iex> new_instance_rule = %{
      ...>   ordering: 2,
      ...>   functional_type: :deny,
      ...>   ip_host_or_network: nil,
      ...>   ip_host_range_lower: ~i"10.100.171.1",
      ...>   ip_host_range_upper: ~i"10.100.172.254"
      ...> }
      iex> {:ok, %Msdata.SystInstanceNetworkRules{}} =
      ...>   MscmpSystAuthn.create_instance_network_rule(instance_id, new_instance_rule)
  """
  @spec create_instance_network_rule(
          MscmpSystInstance.Types.instance_id(),
          Types.instance_network_rule_params()
        ) ::
          {:ok, Msdata.SystInstanceNetworkRules.t()} | {:error, MscmpSystError.t()}
  defdelegate create_instance_network_rule(instance_id, insert_params), to: Impl.NetworkRules

  @doc section: :network_rule_data
  @doc """
  Updates an existing Global Network Rule with new values.

  This function works similar to `create_global_network_rule/1` but updates an
  existing Global Network Rule record rather than creating a new one.

  On successful update, a result tuple in the form `{:ok, <record>}` is returned
  where the <record> is the fully populated Data struct of the record just
  updated.  If an exception is raised this function will return a failure tuple
  in the form of `{:error, <exception data>}`.

  ## Parameters

    * `global_network_rule` - this value is either a fully populated
    `Msdata.SystGlobalNetworkRules` struct of an existing
    Global Network Rule record or the ID of such a record.  If the data struct
    is provided, Ecto optimistic locking is applied to the update operation.

    * `update_params` - a map representing the values to use when updating the
    Global Network Rule.  All parameters are optional, with omission meaning
    that the existing value should retain its current value.  See
    `t:MscmpSystAuthn.Types.global_network_rule_params/0` for the
    available attributes.

  """
  @spec update_global_network_rule(
          Ecto.UUID.t() | Msdata.SystGlobalNetworkRules.t(),
          Types.global_network_rule_params()
        ) ::
          {:ok, Msdata.SystGlobalNetworkRules.t()} | {:error, MscmpSystError.t() | Exception.t()}
  defdelegate update_global_network_rule(global_network_rule, update_params),
    to: Impl.NetworkRules

  @doc section: :network_rule_data
  @doc """
  Updates an existing Owner Network Rule with new values.

  This function works similar to `create_owner_network_rule/2` but updates an
  existing Owner Network Rule record rather than creating a new one.

  On successful update, a result tuple in the form `{:ok, <record>}` is returned
  where the <record> is the fully populated Data struct of the record just
  updated.  If an exception is raised this function will return a failure tuple
  in the form of `{:error, <exception data>}`.

  ## Parameters

    * `owner_network_rule` - this value is either a fully populated
    `Msdata.SystOwnerNetworkRules` struct of an existing
    Owner Network Rule record or the ID of such a record.  If the data struct
    is provided, Ecto optimistic locking is applied to the update operation.

    * `update_params` - a map representing the values to use when updating the
    Owner Network Rule.  All parameters are optional, with omission meaning
    that the existing value should retain its current value.  See
    `t:MscmpSystAuthn.Types.owner_network_rule_params/0` for the
    available attributes.
  """
  @spec update_owner_network_rule(
          Ecto.UUID.t() | Msdata.SystOwnerNetworkRules.t(),
          Types.owner_network_rule_params()
        ) ::
          {:ok, Msdata.SystOwnerNetworkRules.t()} | {:error, MscmpSystError.t() | Exception.t()}
  defdelegate update_owner_network_rule(owner_network_rule, update_params), to: Impl.NetworkRules

  @doc section: :network_rule_data
  @doc """
  Updates an existing Instance Network Rule with new values.

  This function works similar to `create_instance_network_rule/2` but updates an
  existing Instance Network Rule record rather than creating a new one.

  On successful update, a result tuple in the form `{:ok, <record>}` is returned
  where the <record> is the fully populated Data struct of the record just
  updated.  If an exception is raised this function will return a failure tuple
  in the form of `{:error, <exception data>}`.

  ## Parameters

    * `instance_network_rule` - this value is either a fully populated
    `Msdata.SystInstanceNetworkRules` struct of an
    existing Instance Network Rule record or the ID of such a record.  If the
    data struct  is provided, Ecto optimistic locking is applied to the update
    operation.

    * `update_params` - a map representing the values to use when updating the
    Instance Network Rule.  All parameters are optional, with omission meaning
    that the existing value should retain its current value.  See
    `t:MscmpSystAuthn.Types.instance_network_rule_params/0` for the
    available attributes.
  """
  @spec update_instance_network_rule(
          Ecto.UUID.t() | Msdata.SystInstanceNetworkRules.t(),
          Types.instance_network_rule_params()
        ) ::
          {:ok, Msdata.SystInstanceNetworkRules.t()}
          | {:error, MscmpSystError.t() | Exception.t()}
  defdelegate update_instance_network_rule(instance_network_rule, update_params),
    to: Impl.NetworkRules

  @doc section: :network_rule_data
  @doc """
  Retrieves a Global Network Rule record based on its record ID.

  For a given Global Network Rule record ID this function will return a result
  tuple in the form of `{:ok, <record>}` where `<record>` is the fully
  populated `Msdata.SystGlobalNetworkRules`.  If the
  record does not exist, then `{:ok, :not_found}` is returned.  Otherwise, an
  error tuple in the form of `{:error, <exception>}` is returned.

  ## Parameters

  * `global_network_rule_id` - the record ID of the desired Global Network Rule
  record.
  """
  @spec get_global_network_rule(Ecto.UUID.t()) ::
          {:ok, Msdata.SystGlobalNetworkRules.t()}
          | {:ok, :not_found}
          | {:error, MscmpSystError.t() | Exception.t()}
  defdelegate get_global_network_rule(global_network_rule_id), to: Impl.NetworkRules
  @doc section: :network_rule_data
  @doc """
  Retrieves a Global Network Rule record based on its record ID, raising on
  error.

  This function works the same as `get_global_network_rule/1` except this
  function returns its result without wrapping it in a result tuple.  If an
  error is encountered, including if the record does not exist, an exception is
  raised.

  ## Parameters

  * `global_network_rule_id` - the record ID of the desired Global Network Rule
  record.
  """
  @spec get_global_network_rule!(Ecto.UUID.t()) :: Msdata.SystGlobalNetworkRules.t() | :not_found
  defdelegate get_global_network_rule!(global_network_rule_id), to: Impl.NetworkRules

  @doc section: :network_rule_data
  @doc """
  Retrieves a Owner Network Rule record based on its record ID.

  For a given Owner Network Rule record ID this function will return a result
  tuple in the form of `{:ok, <record>}` where `<record>` is the fully
  populated `Msdata.SystOwnerNetworkRules`.  If the
  record does not exist, then `{:ok, :not_found}` is returned.  Otherwise, an
  error tuple in the form of `{:error, <exception>}` is returned.

  ## Parameters

  * `owner_network_rule_id` - the record ID of the desired Owner Network Rule
  record.
  """
  @spec get_owner_network_rule(Ecto.UUID.t()) ::
          {:ok, Msdata.SystOwnerNetworkRules.t()}
          | {:ok, :not_found}
          | {:error, MscmpSystError.t() | Exception.t()}
  defdelegate get_owner_network_rule(owner_network_rule_id), to: Impl.NetworkRules
  @doc section: :network_rule_data
  @doc """
  Retrieves a Owner Network Rule record based on its record ID, raising on
  error.

  This function works the same as `get_owner_network_rule/1` except this
  function returns its result without wrapping it in a result tuple.  If an
  error is encountered, including if the record does not exist, an exception is
  raised.

  ## Parameters

  * `owner_network_rule_id` - the record ID of the desired Owner Network Rule
  record.
  """
  @spec get_owner_network_rule!(Ecto.UUID.t()) :: Msdata.SystOwnerNetworkRules.t() | :not_found
  defdelegate get_owner_network_rule!(owner_network_rule_id), to: Impl.NetworkRules

  @doc section: :network_rule_data
  @doc """
  Retrieves a Instance Network Rule record based on its record ID.

  For a given Instance Network Rule record ID this function will return a result
  tuple in the form of `{:ok, <record>}` where `<record>` is the fully
  populated `Msdata.SystInstanceNetworkRules`.  If the
  record does not exist, then `{:ok, :not_found}` is returned.  Otherwise, an
  error tuple in the form of `{:error, <exception>}` is returned.

  ## Parameters

  * `instance_network_rule_id` - the record ID of the desired Instance Network
  Rule record.
  """
  @spec get_instance_network_rule(Ecto.UUID.t()) ::
          {:ok, Msdata.SystInstanceNetworkRules.t()}
          | {:ok, :not_found}
          | {:error, MscmpSystError.t() | Exception.t()}
  defdelegate get_instance_network_rule(instance_network_rule_id), to: Impl.NetworkRules

  @doc section: :network_rule_data
  @doc """
  Retrieves a Instance Network Rule record based on its record ID, raising on
  error.

  This function works the same as `get_instance_network_rule/1` except this
  function returns its result without wrapping it in a result tuple.  If an
  error is encountered, including if the record does not exist, an exception is
  raised.

  ## Parameters

  * `instance_network_rule_id` - the record ID of the desired Instance Network
  Rule record.
  """
  @spec get_instance_network_rule!(Ecto.UUID.t()) ::
          Msdata.SystInstanceNetworkRules.t() | :not_found
  defdelegate get_instance_network_rule!(instance_network_rule_id), to: Impl.NetworkRules

  @doc section: :network_rule_data
  @doc """
  Deletes an existing Global Network Rule record as referenced by the record ID.

  On successful deletion, a simple result of `:ok` is returned.  On error, an
  error tuple in the form of `{:error, <exception>}` is returned.

  ## Parameters

    * `global_network_rule_id` - The record ID of the Global Network Rule record
    to delete.
  """
  @spec delete_global_network_rule(Ecto.UUID.t()) ::
          :ok | {:error, MscmpSystError.t() | Exception.t()}
  defdelegate delete_global_network_rule(global_network_rule_id), to: Impl.NetworkRules

  @doc section: :network_rule_data
  @doc """
  Deletes an existing Owner Network Rule record as referenced by the record ID.

  On successful deletion, a simple result of `:ok` is returned.  On error, an
  error tuple in the form of `{:error, <exception>}` is returned.

  ## Parameters

    * `owner_network_rule_id` - The record ID of the Owner Network Rule record
    to delete.
  """
  @spec delete_owner_network_rule(Ecto.UUID.t()) ::
          :ok | {:error, MscmpSystError.t() | Exception.t()}
  defdelegate delete_owner_network_rule(owner_network_rule_id), to: Impl.NetworkRules

  @doc section: :network_rule_data
  @doc """
  Deletes an existing Instance Network Rule record as referenced by the record
  ID.

  On successful deletion, a simple result of `:ok` is returned.  On error, an
  error tuple in the form of `{:error, <exception>}` is returned.

  ## Parameters

    * `instance_network_rule_id` - The record ID of the Instance Network Rule
    record to delete.
  """
  @spec delete_instance_network_rule(Ecto.UUID.t()) ::
          :ok | {:error, MscmpSystError.t() | Exception.t()}
  defdelegate delete_instance_network_rule(instance_network_rule_id), to: Impl.NetworkRules

  # ==============================================================================================
  # ==============================================================================================
  #
  # Account Code Identity Management
  #
  # ==============================================================================================
  # ==============================================================================================

  @doc section: :account_code
  @doc """
  Creates a new Account Code for an Access Account or resets the Account Code if
  is already exists.

  On successful Account Code Identity creation or reset, an Authenticator Result
  value is returned via a success tuple (`{:ok, <result>}`).  The expected form
  of the result for a new Account Code is:

      %{
        access_account_id: "c3c7fafd-5c45-11ed-ab46-f3d9be809bf9",
        account_identifier: "QY7QJTWH7MSK"
      }

  There is no associated Credential or Validator for this Identity Type.

  ## Parameters

    * `access_account_id` - the record ID of the Access Account that will be
    identified by the Account Code Identity.

    * `opts` - a Keyword list of optional settings which can influence the
    behavior of the function call.  Available options are:

      * `account_code` - this option overrides the randomly generated Account
      Code with the value of this option.  By default the system randomly
      generates the Account Code.

      * `identity_token_length` - overrides the number of characters to randomly
      generate for use as the Account Code Identifier.  The default value is 12.

      * `identity_tokens` - overrides the character set used to create the
      randomly generated Account Code Identifier.  The default value is `:b32c`.
      See the `MscmpSystUtils.get_random_string/2` documentation for the
      `tokens` parameter which receives this option for more information
      regarding valid values for this setting.
  """
  @spec create_or_reset_account_code(Types.access_account_id(), Keyword.t()) ::
          {:ok, Types.AuthenticatorResult.t()} | {:error, MscmpSystError.t() | Exception.t()}
  defdelegate create_or_reset_account_code(access_account_id, opts \\ []),
    to: Impl.ExtendedMgmtLogic

  @doc section: :account_code
  @doc """
  Identifies an Access Account by its Account Code identifier.

  On successful identification, the Account Code Identity record which was found
  based on the supplied parameters is returned via a success tuple.  If the
  function completes successfully but no Identity record is found for the
  Identifier a value of `{:ok, :not_found}` is returned.

  ## Parameters

    * `account_code` - the Account Code identifier which will identify the
    Access Account

    * `owner_id` - if the expected Access Account is an Owned Access Account,
    the Owner must be identified.  If the Access Account is Unowned, this
    parameter should be `nil`.
  """
  @spec identify_access_account_by_code(
          Types.account_identifier(),
          MscmpSystInstance.Types.owner_id() | nil
        ) ::
          {:ok, Msdata.SystIdentities.t() | :not_found} | {:error, MscmpSystError.t()}
  defdelegate identify_access_account_by_code(account_code, owner_id), to: Impl.ExtendedAuthLogic

  @doc section: :account_code
  @doc """
  Retrieves the Account Code Identity record defined for the requested Access
  Account if one exists.

  If no Account Code Identity exists for the requested Access Account a tuple in
  the form of `{:ok, :not_found}` is returned.

  ## Parameters

    * `access_account_id` - the Access Account record ID for which to retrieve
    the Account Code Identity.
  """
  @spec get_account_code_by_access_account_id(Types.access_account_id()) ::
          {:ok, Msdata.SystIdentities.t() | :not_found} | {:error, MscmpSystError.t()}
  defdelegate get_account_code_by_access_account_id(access_account_id),
    to: Impl.Identity.AccountCode

  @doc section: :account_code
  @doc """
  Revokes a previously create Account Code Identity from an Access Account,
  deleting it from the system.

  On successful deletion a success tuple in the form `{:ok, :deleted}` is
  returned.  If no existing Account Code Identity is found a tuple in this form
  `{:ok, :not_found}` is returned.  All other outcomes are error conditions
  resulting in the return of an error tuple.

  ## Parameters

    * `access_account_id` - the Access Account record ID from which to revoke
    the Account Code Identity.
  """
  @spec revoke_account_code(Types.access_account_id()) ::
          {:ok, :deleted | :not_found} | {:error, MscmpSystError.t()}
  defdelegate revoke_account_code(access_account_id), to: Impl.ExtendedMgmtLogic

  # ==============================================================================================
  # ==============================================================================================
  #
  # Extended Logic / Authenticator Management
  #
  # ==============================================================================================
  # ==============================================================================================

  @doc section: :authenticator_management
  @doc """
  Creates an Email/Password Authenticator for an Access Account.

  This function creates an Email Identity, Password Credential, and optionally
  an Identity Validation Authenticator (created by default).  This function is
  typically used on adding a new Access Account to the system.  The process is
  wrapped in a database transaction so if any one part of the Authenticator
  creation process fails, all parts should fail.

  This function will fail if you attempt to create an Authenticator of this
  type for an Access Account which already has one.  In the case of Email
  Identity replacement, use the specific Identity process to create a new Email
  Identity instead of this more expansive process.

  On successful save of the Authenticator records, a success tuple is returned
  where the value element of the tuple will include basic data that might be
  required for later processing.

  If Email/Password Authenticator was created requiring validation (the
  default), the success tuple's value element will include data required to
  process the Validation Authenticator:


      {:ok,
        %{
          access_account_id: "c3c7fafd-5c45-11ed-ab46-f3d9be809bf9",
          account_identifier: "SomeEmail@somedomain.com",
          validation_credential: "Uo0kPoCOZd004g4X7IFWg3iJ7pz7XiBRBDkBGGiu",
          validation_identifier: "5D7i6XmmH0HpYL72tePlEdSUMVL9ygMrEsDSGoTE"
      }}


  Note that this is the only time the Validation Authenticator is provided and
  the Validation Credential plaintext is not recoverable after this return value
  is provided.

  When a Validation Authenticator is not created, no validation data will be
  included in the result:


      {:ok,
        %{
          access_account_id: "c3c7fafd-5c45-11ed-ab46-f3d9be809bf9",
          account_identifier: "SomeEmail@somedomain.com"
      }}


  ## Parameters

    * `access_account_id` - the Access Account for whom the Email/Password
    Authenticator is being created.

    * `email_address` - the email address which will identify the Access
    Account.

    * `plaintext_pwd` - the candidate password for use a the Credential in
    Email/Password authentication processes.

  """
  @spec create_authenticator_email_password(
          Types.access_account_id(),
          Types.account_identifier(),
          Types.credential(),
          Keyword.t()
        ) ::
          {:ok, Types.AuthenticatorResult.t()}
          | {:error, MscmpSystError.t() | Exception.t()}
  defdelegate create_authenticator_email_password(
                access_account_id,
                email_address,
                plaintext_pwd,
                opts \\ []
              ),
              to: Impl.ExtendedMgmtLogic

  @doc section: :authenticator_management
  @doc """
  Allows for an existing password to be changed to a new password.

  The assumption is that a Password Credential already exists and that only the
  password itself is being changed from an old value to a new value.

  This function ensures that the new password meets all applicable Password 
  Rules prior to completing the change.  This function will not allow you to set
  the password to an invalid value.

  Finally, in the case of a user initiated password change, it is traditional 
  that the user has to re-authenticate or provide their current password to 
  verify they are, in fact, the person initiating the change.  This function 
  does not try to achieve this goal.  The scope of this function assumes that 
  any such confirmation of identity has been completed satisfactorily elsewhere. 

  On successful Password Credential reset this function will return `:ok`.  If
  the new credential fails to meet the Password Rule criteria that applies to 
  it, the function will return a failure tuple of type 
  `t:MscmpSystAuthn.Types.credential_set_failures/0`.  All other return 
  conditions are errors and result in an error tuple.

  ## Parameters

    * `access_account_id` - the Access Account for whom the Password is being
    changed.

    * `new_credential` - the new Password which will become the credential on
    the successful completion of the function.
  """
  @spec reset_password_credential(Types.access_account_id(), Types.credential()) ::
          :ok | Types.credential_set_failures() | {:error, MscmpSystError.t()}
  defdelegate reset_password_credential(access_account_id, new_credential),
    to: Impl.ExtendedMgmtLogic

  @doc section: :authenticator_management
  @doc """
  Requests the creation of a Validation Token Authenticator for the specified
  Identity.

  On successful creation of the requested Validation Token Authenticator, an
  Authenticator Result will be returned as the value element of a success tuple:

      { :ok,
        %{
          access_account_id: "c3c7fafd-5c45-11ed-ab46-f3d9be809bf9",
          validation_identifier: "psYFOfuULJPTbs5MUvOYTyt71fAbQCj7XcmerRlQ",
          validation_credential: "zz29w7l5Ev7vuRlGFHcPPjLTXjepdbYlyQwbBjDe"
      }}

  Importantly, the system generated Validation Token identifier and plaintext
  credential are returned to the caller.  This is the only opportunity to obtain
  the plaintext credential; after the return value of the function is disposed
  of there is no way to once again retrieve the plaintext of the Validation
  Token Credential.

  Once the Validation Token Authenticator has been successfully created, the
  target Identity (typically an Email Identity) may not be used for
  authentication until the Validation Token itself has been successfully
  authenticated via the `authenticate_validation_token/4` function.

  The created Validation Token Authenticator will expire after a time.  After
  expiration the the Authenticator will no longer be to be authenticated by
  `authenticate_validation_token/4`.  The only way to validate the target
  Identity at that point is to create a new Validation Token Authenticator for
  the Identity using this function.

  ## Parameters

    * `target_identity` - either the record ID or the
    `Msdata.SystIdentities` struct of the Identity record
    to validate.  Typically this Identity will be an Email Identity.

    * `opts` - a Keyword List of options which can change the behavior to the
    Identity validation request.  The available options are:

      * `expiration_hours` - overrides the default number of hours after which
      to consider the Validation Authenticator expired.  By default the
      Validation Authenticator expires 24 hours after creation.

      * `identity_token_length` - this option overrides the default number of
      random characters to generate for the Validation Token Identity
      identifier.  The default number of characters generated is 40.

      * `identity_tokens` - overrides the default character set to use in the
      generation of the Validation Token Identity identifier.  The default value
      is `:mixed_alphanum`.  See the `MscmpSystUtils.get_random_string/2`
      documentation for the `tokens` parameter which receives this option for
      more information regarding valid values for this setting.

      * `credential_token_length` - this option overrides the default number of
      random characters to generate for the Validation Token Credential. The
      default number of characters generated is 40.

      * `credential_tokens` - overrides the default character set to use in the
      generation of the Validation Token Credential.  The default value is
      `:mixed_alphanum`.  See the `MscmpSystUtils.get_random_string/2`
      documentation for the `tokens` parameter which receives this option for
      more information regarding valid values for this setting.

      * `credential_token` - overrides the system generated Validation
      Credential with the value of this option.  The default is to allow the
      system to automatically generate the credential.
  """
  @spec request_identity_validation(Types.identity_id() | Msdata.SystIdentities.t(), Keyword.t()) ::
          {:ok, Types.AuthenticatorResult.t()} | {:error, MscmpSystError.t() | Exception.t()}
  defdelegate request_identity_validation(target_identity, opts \\ []), to: Impl.ExtendedMgmtLogic

  @doc section: :authenticator_management
  @doc """
  Revokes a Validation Authenticator ("Validator") issued for the requested
  Identity.

  While Validators will expire on their own if not confirmed first, there are
  cases where Validators should be revoked prior to that time, such as if the
  Validator communication to the user has been lost and a new Validator needs to
  be generated.

  The return value is a result tuple which indicates whether or not the
  revocation happened (`{:ok, :deleted}`), if the Validator was not found
  (`{:ok, :not_found}`), or an error tuple in any other circumstance.

  ## Parameters

    * `target_identity_id` - the record ID of the Identity record which the
    Validator was meant to validate.  So if the Validator to revoke was for an
    Email Identity, this value would be the ID of the Email Identity and not the
    Validation Identity.
  """
  @spec revoke_validator_for_identity_id(Types.identity_id()) ::
          {:ok, :deleted | :not_found} | {:error, MscmpSystError.t() | Exception.t()}
  defdelegate revoke_validator_for_identity_id(target_identity_id), to: Impl.ExtendedMgmtLogic

  @doc section: :authenticator_management
  @doc """
  Indicates if an Access Account's Password Credential is recoverable or not.

  Access Account Password Credentials are only recoverable when they: 1) exist,
  and 2) are not already awaiting recovery.  When the Password Credential is
  recoverable this function will return a simple `:ok` value.  If the Access
  Account's Password Credential already has an issued recovery underway, the
  value `:existing_recovery` is returned.  If the Access Account lacks a
  Password Credential record to recover, the value `:not_found` is returned. Any
  errors encountered cause the function to raise an exception.

  ## Parameters

    * `access_account_id` - the record ID of the Access Account which owns the
    Password Credential to test for recoverability.
  """
  @spec access_account_credential_recoverable!(Types.access_account_id()) ::
          :ok | :not_found | :existing_recovery
  defdelegate access_account_credential_recoverable!(access_account_id),
    to: Impl.Identity.Recovery

  @doc section: :authenticator_management
  @doc """
  Requests to start a Password Credential recovery process for the specified
  Access Account.

  Assuming that the Access Account's Password Credential exists and isn't
  already being recovered, this function will create a new Recovery Token
  Authenticator for the Access Account's Password Credential.

  On successful creation of the requested Recovery Token Authenticator, an
  Authenticator Result will be returned as the value element of a success tuple:

      { :ok,
        %{
          access_account_id: "c3c7fafd-5c45-11ed-ab46-f3d9be809bf9",
          account_identifier: "acdyItesdmUvUoM7mKwPKd3mrBBnH87L2WA1DPip",
          credential: "WYbFG2vkJOLD5ITX9tSE5OTZ9JlHdJE8BQ8Ukiiq"
      }}

  Importantly, the system generated Recovery Token account identifier and
  plaintext credential are returned to the caller.  This is the only opportunity
  to obtain the plaintext credential; after the return value of the function is
  disposed of there is no way to once again retrieve the plaintext of the
  Recovery Token Credential.

  The existence of a Recovery Token Authenticator for a Password Credential does
  not prevent that Password Credential from continuing to be used in the
  authentication process.

  A Recovery Token Authenticator will expire after a time.  After expiration the
  Recovery Token will no longer be able to be authenticated with
  `authenticate_recovery_token/4`.  Any further recovery of the Password
  Credential will require a new Recovery Token be created.

  ## Parameters

    * `access_account_id` - the record ID of the Access Account to which the
    Password Credential needing recovering belongs.

    * `opts` - a Keyword List of options which can change the behavior to the
    password recovery request.  The available options are:

      * `expiration_hours` - overrides the default number of hours after which
      to consider the Recovery Authenticator expired.  By default the Recovery
      Authenticator expires 24 hours after creation.

      * `identity_token_length` - this option overrides the default number of
      random characters to generate for the Recovery Token Identity identifier.
      The default number of characters generated is 40.

      * `identity_tokens` - overrides the default character set to use in the
      generation of the Recovery Token Identity identifier.  The default value
      is `:mixed_alphanum`.  See the `MscmpSystUtils.get_random_string/2`
      documentation for the `tokens` parameter which receives this option for
      more information regarding valid values for this setting.

      * `credential_token_length` - this option overrides the default number of
      random characters to generate for the Recovery Token Credential. The
      default number of characters generated is 40.

      * `credential_tokens` - overrides the default character set to use in the
      generation of the Recovery Token Credential.  The default value is
      `:mixed_alphanum`.  See the `MscmpSystUtils.get_random_string/2`
      documentation for the `tokens` parameter which receives this option for
      more information regarding valid values for this setting.

      * `credential_token` - overrides the system generated Recovery Credential
      with the value of this option.  The default is to allow the system to
      automatically generate the credential.
  """
  @spec request_password_recovery(Types.access_account_id(), Keyword.t()) ::
          {:ok, Types.AuthenticatorResult.t()} | {:error, MscmpSystError.t() | Exception.t()}
  defdelegate request_password_recovery(access_account_id, opts \\ []), to: Impl.ExtendedMgmtLogic

  @doc section: :authenticator_management
  @doc """
  Revokes the Recovery Token Authenticator for a previously initiated Password
  Credential recovery.

  While Recovery Token Authenticators expire of their own accord after a time,
  they may also explicitly be revoked.  In reality this means simply deleting
  the Recovery Token Authenticator from the system.

  The return value of this function on successful execution will be the success
  tuple `{:ok, :deleted}`.  If a recovery is not already underway for the
  requested Access Account, the function will return successfully but will
  indicate that no action took place with a return of `{:ok, :not_found}`.  Any
  other condition is an error condition and the return value will be an error
  tuple indicating the nature of the issue.

  ## Parameters

    * `access_account_id` - identifies the Access Account for whom the Recovery
    Token Authenticator should be revoked.  The expected value is the record ID
    of the Access Account.
  """
  @spec revoke_password_recovery(Types.access_account_id()) ::
          {:ok, :deleted | :not_found} | {:error, MscmpSystError.t() | Exception.t()}
  defdelegate revoke_password_recovery(access_account_id), to: Impl.ExtendedMgmtLogic

  @doc section: :authenticator_management
  @doc """
  Creates an API Token Authenticator for the requested Access Account.

  On successful API Token Authenticator creation, a success tuple is returned
  where the value element is an Authenticator Result in the form of:

      { :ok,
        %{
          access_account_id: "c3c7fafd-5c45-11ed-ab46-f3d9be809bf9",
          account_identifier: "EQH2jj38ha4qnYWAC8VZ",
          credential: "8N5Tp81aeOCrYW9PECANrcwKCroSet3MlMp5BbKb"
      }}

  It is important to note that this result value is the only time that the API
  Token Credential plaintext is available.  After the function result is
  discarded the credential is no longer obtainable in plaintext form.

  ## Parameters

    * `access_account_id` - the record ID of the Access Account for which to
    create the API Token Authenticator.

    * `opts` - a Keyword List of optional values which changes the default
    behavior of the Authenticator creation process.  Available options are:

      * `identity_token_length` - this option overrides the default number of
      random characters to generate for the API Token Identity identifier. The
      default number of characters generated is 20.

      * `identity_tokens` - overrides the default character set to use in the
      generation of the API Token Identity identifier.  The default value is
      `:mixed_alphanum`.  See the `MscmpSystUtils.get_random_string/2`
      documentation for the `tokens` parameter which receives this option for
      more information regarding valid values for this setting.

      * `external_name` - API Token Identities permit Access Account holder
      naming of the Identity as it may be common for an one Access Account to
      require multiple API Token Authenticators for different purposes.  This
      option allows that name to be set at Identity creation time.  The default
      value is `nil`.

      * `credential_token_length` - this option overrides the default number of
      random characters to generate for the API Token Credential. The default
      number of characters generated is 40.

      * `credential_tokens` - overrides the default character set to use in the
      generation of the API Token Credential.  The default value is
      `:mixed_alphanum`.  See the `MscmpSystUtils.get_random_string/2`
      documentation for the `tokens` parameter which receives this option for
      more information regarding valid values for this setting.

      * `credential_token` - overrides the system generated API Token Credential
      with the value of this option.  The default is to allow the system to
      automatically generate the credential.
  """
  @spec create_authenticator_api_token(Types.access_account_id(), Keyword.t()) ::
          {:ok, Types.AuthenticatorResult.t()} | {:error, MscmpSystError.t() | Exception.t()}
  defdelegate create_authenticator_api_token(access_account_id, opts \\ []),
    to: Impl.ExtendedMgmtLogic

  @doc section: :authenticator_management
  @doc """
  Updates the External Name value of an existing API Token Identity.

  API Token Identities permit Access Account holder naming of the Identity as it
  may be common for an one Access Account to require multiple API Token
  Authenticators for different purposes.

  On success this function returns a success tuple where the value element of
  the tuple is the updated `Msdata.SystIdentities` struct.
  On error, an error tuple is returned.

  ## Parameters

    * `identity` - either the record ID of the API Token Identity to update or
    the current-state `Msdata.SystIdentities` struct of
    that record.

    * `external_name` - the text of the updated External Name value or `nil` to
    remove the text of an existing non-nil value.
  """
  @spec update_api_token_external_name(
          Types.identity_id() | Msdata.SystIdentities.t(),
          String.t() | nil
        ) ::
          {:ok, Msdata.SystIdentities.t()} | {:error, MscmpSystError.t()}
  defdelegate update_api_token_external_name(identity, external_name), to: Impl.ExtendedMgmtLogic

  @doc section: :authenticator_management
  @doc """
  Revokes the request API Token Authenticator by deleting it from the system.

  API Token Authenticators will regularly need to be decommissioned from the
  system by the Access Account holders they represent.  By revoking an API
  Token it is deleted from system.

  A successful deletion will return a success tuple if the form
  `{:ok, :deleted}`.  If the API Token Identity is not found this function will
  return a success tuple of `{:ok, :not_found}`.  Any other outcome is an error
  and results in an error tuple being returned.

  ## Parameters

    * `identity` - either the record ID of the API Token Identity to revoke or
    the current-state `Msdata.SystIdentities` struct of
    that record.
  """
  @spec revoke_api_token(Types.identity_id() | Msdata.SystIdentities.t()) ::
          {:ok, :deleted | :not_found} | {:error, MscmpSystError.t()}
  defdelegate revoke_api_token(identity), to: Impl.ExtendedMgmtLogic

  # ==============================================================================================
  # ==============================================================================================
  #
  # Extended Logic / Authentication
  #
  # ==============================================================================================
  # ==============================================================================================

  @doc section: :authentication
  @doc """
  Identities and authenticates an Access Account using an Email/Password
  Authenticator.

  The return value of this function is a result tuple where a success tuple
  (`{:ok, <value>}`) indicates that the function processed without error, not
  that the authentication was successful.  The value element of the success
  tuple, the Authentication State, carries information about the outcome of the
  authentication attempt; see
  `t:MscmpSystAuthn.Types.AuthenticationState.t/0` for more about the
  specific information carried by the Authentication State value.  Otherwise,
  an error tuple is returned indicating the nature of the processing failure.

  Email/Password authentication is an interruptible process, meaning that this
  function may return prior to the authentication having been fully processed to
  a final result.  The two most common examples of when this partial processing
  may happen are:

  1. The Application Instance was not initially identified.
  2. Further authentication is required such as when Multi-Factor Authentication
  is required.

  In these cases the returned Authentication State is resubmitted
  for processing via `authenticate_email_password/2` along with the updated
  information which allows authentication processing to complete.

  ## Parameters

    * `email_address` - this is the username in the form of an email address
    used to identify the correct Email Identity record which in turn identifies
    a specific Access Account.

    * `plaintext_pwd` - the Access Account holder's password as submitted in
    plaintext.  This is the credential that will be authenticated using the
    Password Credential record belonging to the identified Access Account.

    * `host_address` - the apparent origin host IP address from where the
    authentication attempt is originating.  This value is used in the
    enforcement of applicable Network Rules.

    * `opts` - a Keyword List of values that either optionally override default
    behaviors of this function, are optionally required, or are required on a
    deferred basis (eventually required).  The available options are:

      * `owning_owner_id` - if the Access Account is an Owned Access Account,
      this value must be set to the record ID of the Access Account's Owner.
      Otherwise it must be set `nil` or not provided.  The default value is
      `nil`.

      * `instance_id` - the record ID of the Application Instance to which the
      Access Account holder wishes to authenticate.  A final value for
      instance_id is not required when the Email/Password authentication process
      is initiated but is required for it to complete.  If this value is not
      initially provided, the function will be `interrupted` returning an
      Authentication State status value of `:pending`.  Deferral may be
      appropriate if, for example, we want to allow the Access Account holder to
      select the specific Instance they wish to access from a list of their
      permitted Instances.  Final resolution of the value must reference an
      Instance for which the Access Account permitted authentication attempts or
      must be set `:bypass` if the authentication attempt is a special case
      where a specific Instance is not relevant.  The default value of this
      option is `nil`.

      * `host_ban_rate_limit` - overrides the default host IP address based Rate
      Limit.  The value is set via a tuple in the following form:
      `{<Maximum Attempts>, <Time Window in Seconds>}`.  The default value is 30
      attempts over a time window of 2 hours.

      * `identifier_rate_limit` - overrides the default identifier based Rate
      Limit.  The value is set via a tuple in the following form:
      `{<Maximum Attempts>, <Time Window in Seconds>}`.  The default value is 5
      attempts over a time window of 30 minutes.

      * `deadline_minutes` - overrides the default number of minutes that an
      authentication process can take before being rejected for taking too long.
      This deadline is needed because an arbitrary time can pass due to user
      interaction, such as selecting an Instance or providing an MFA credential.
      The default value is 5 minutes from the time the authentication process is
      started.
  """
  @spec authenticate_email_password(
          Types.account_identifier(),
          Types.credential(),
          NetTypes.addr_structs(),
          Keyword.t()
        ) ::
          {:ok, Types.AuthenticationState.t()} | {:error, MscmpSystError.t()}
  defdelegate authenticate_email_password(email_address, plaintext_pwd, host_address, opts \\ []),
    to: Impl.ExtendedAuthLogic

  @doc section: :authentication
  @doc """
  Identifies and authenticates an Access Account on the basis of a starting
  Authentication State value constructed for Email/Password authentication.

  This function works the same as `authenticate_email_password/4` except that it
  expects an existing Authentication State value to contain the basic
  information to process the authentication, with other parameters provided via
  the `opts` parameter.  This function is typically used to continue a
  previously interrupted call to `authenticate_email_password/4` and supplying
  it the necessary additional information to continue processing the
  authentication to completion.

  The options available for use here are the same as for
  `authenticate_email_password/4`.  However the options specified here are only
  valid if they are applied to authentication process operations that are still
  pending when this function is called.  Options influencing operations
  previously processed, such as `owning_owner_id` as used in Access Account
  identification will simply be ignored if they are different in the resumption
  of the process than they were in the initiating call.

  See `authenticate_email_password/4` for a discussion of the possible return
  values.
  """
  @spec authenticate_email_password(Types.AuthenticationState.t(), Keyword.t()) ::
          {:ok, Types.AuthenticationState.t()} | {:error, MscmpSystError.t()}
  defdelegate authenticate_email_password(authentication_state, opts \\ []),
    to: Impl.ExtendedAuthLogic

  @doc section: :authentication
  @doc """
  Confirms a specific Access Account Identity record as being valid for use.

  The return value of this function is a result tuple where a success tuple
  (`{:ok, <value>}`) indicates that the function processed without error, not
  that the validation was successful.  The value element of the success
  tuple, the Authentication State, carries information about the actual outcome
  of the authentication attempt; see
  `t:MscmpSystAuthn.Types.AuthenticationState.t/0` for more about the
  specific information carried by the Authentication State value.  Otherwise,
  an error tuple is returned indicating the nature of the processing failure.

  If the Authentication State's status is returned as `:authenticated`, the
  validation process succeeded.  On success the target Identity record has its
  `validated` field set to the current date/time and the Validation
  Authenticator is deleted from the system.

  The authentication process executed by this function is not interruptible.
  The initial call to this function must contain all parameter values required
  to fully complete the authentication process.  Any missing information will
  cause the authentication attempt to be rejected.

  ## Parameters

    * `identifier` - the identifier defined by the Validation Token identifier.
    Typically this would have been a system generated random string of
    characters available at Validation Token Authenticator creation time.

    * `plaintext_token` - the plaintext Validation Token credential.  Typically
    this would have been a system generated random string of characters
    available at Validation Token Authenticator creation time.

    * `host_address` - the apparent origin host IP address from where the
    authentication attempt is originating.  This value is used in the
    enforcement of applicable Network Rules.

    * `opts` - a Keyword List of values that either optionally override default
    behaviors of this function or are optionally required.  The available
    options are:

      * `owning_owner_id` - if the Access Account is an Owned Access Account,
      this value must be set to the record ID of the Access Account's Owner.
      Otherwise it must be set `nil` or not provided.  The default value is
      `nil`.

      * `host_ban_rate_limit` - overrides the default host IP address based Rate
      Limit.  The value is set via a tuple in the following form:
      `{<Maximum Attempts>, <Time Window in Seconds>}`.  The default value is 30
      attempts over a time window of 2 hours.

      * `identifier_rate_limit` - overrides the default identifier based Rate
      Limit.  The value is set via a tuple in the following form:
      `{<Maximum Attempts>, <Time Window in Seconds>}`.  The default value is 5
      attempts over a time window of 30 minutes.

      * `deadline_minutes` - overrides the default number of minutes that an
      authentication process can take before being rejected for taking too long.
      This deadline is needed because an arbitrary time can pass due to user
      interaction if the authenticator allows for an interruptable
      authentication process.  The default deadline allows for 5 minutes to
      complete the authentication process.
  """
  @spec authenticate_validation_token(
          Types.account_identifier(),
          Types.credential(),
          NetTypes.addr_structs(),
          Keyword.t()
        ) ::
          {:ok, Types.AuthenticationState.t()} | {:error, MscmpSystError.t()}
  defdelegate authenticate_validation_token(
                identifier,
                plaintext_token,
                host_address,
                opts \\ []
              ),
              to: Impl.ExtendedAuthLogic

  @doc section: :authentication
  @doc """
  Confirms an Access Account's password Recovery Token Authenticator.

  The return value of this function is a result tuple where a success tuple
  (`{:ok, <value>}`) indicates that the function processed without error, not
  that the Recovery Token Authenticator was successfully authenticated.  The
  value element of the success tuple, the Authentication State, carries
  information about the actual outcome of the authentication attempt; see
  `t:MscmpSystAuthn.Types.AuthenticationState.t/0` for more about the
  specific information carried by the Authentication State value.  Otherwise,
  an error tuple is returned indicating the nature of the processing failure.

  If the Authentication State's status is returned as `:authenticated`, the
  process of Password Credential recovery may be undertaken.  On success the
  Recovery Token Authenticator is deleted from the system, but no further action
  is taken by this function.  The actual process of recovering a password is
  external to this function.

  The authentication process executed by this function is not interruptible.
  The initial call to this function must contain all parameter values required
  to fully complete the authentication process.  Any missing information will
  cause the authentication attempt to be rejected.

  ## Parameters

    * `identifier` - the identifier defined by the Recovery Token identifier.
    Typically this would have been a system generated random string of
    characters available at Recovery Token Authenticator creation time.

    * `plaintext_token` - the plaintext Recovery Token credential.  Typically
    this would have been a system generated random string of characters
    available at Recovery Token Authenticator creation time.

    * `host_address` - the apparent origin host IP address from where the
    authentication attempt is originating.  This value is used in the
    enforcement of applicable Network Rules.

    * `opts` - a Keyword List of values that either optionally override default
    behaviors of this function or are optionally required.  The available
    options are:

      * `owning_owner_id` - if the Access Account is an Owned Access Account,
      this value must be set to the record ID of the Access Account's Owner.
      Otherwise it must be set `nil` or not provided.  The default value is
      `nil`.

      * `host_ban_rate_limit` - overrides the default host IP address based Rate
      Limit.  The value is set via a tuple in the following form:
      `{<Maximum Attempts>, <Time Window in Seconds>}`.  The default value is 30
      attempts over a time window of 2 hours.

      * `identifier_rate_limit` - overrides the default identifier based Rate
      Limit.  The value is set via a tuple in the following form:
      `{<Maximum Attempts>, <Time Window in Seconds>}`.  The default value is 5
      attempts over a time window of 30 minutes.

      * `deadline_minutes` - overrides the default number of minutes that an
      authentication process can take before being rejected for taking too long.
      This deadline is needed because an arbitrary time can pass due to user
      interaction if the authenticator allows for an interruptable
      authentication process.  The default deadline allows for 5 minutes to
      complete the authentication process.
  """
  @spec authenticate_recovery_token(
          Types.account_identifier(),
          Types.credential(),
          NetTypes.addr_structs(),
          Keyword.t()
        ) ::
          {:ok, Types.AuthenticationState.t()} | {:error, MscmpSystError.t()}
  defdelegate authenticate_recovery_token(identifier, plaintext_token, host_addr, opts \\ []),
    to: Impl.ExtendedAuthLogic

  @doc section: :authentication
  @doc """
  Identities and authenticates an Access Account using an API Token
  Authenticator.

  The return value of this function is a result tuple where a success tuple
  (`{:ok, <value>}`) indicates that the function processed without error, not
  that the API Token Authenticator was successfully authenticated.  The value
  element of the success tuple, the Authentication State, carries information
  about the actual outcome of the authentication attempt; see
  `t:MscmpSystAuthn.Types.AuthenticationState.t/0` for more about the
  specific information carried by the Authentication State value.  Otherwise,
  an error tuple is returned indicating the nature of the processing failure.

  The authentication process executed by this function is not interruptible.
  The initial call to this function must contain all parameter values required
  to fully complete the authentication process.  Any missing information will
  cause the authentication attempt to be rejected.

  ## Parameters

    * `identifier` - the identifier defined by the API Token identifier.
    Typically this would have been a system generated random string of
    characters available at API Token Authenticator creation time.

    * `plaintext_token` - the plaintext API Token credential.  Typically this
    would have been a system generated random string of characters available at
    API Token Authenticator creation time.

    * `host_address` - the apparent origin host IP address from where the
    authentication attempt is originating.  This value is used in the
    enforcement of applicable Network Rules.

    * `opts` - a Keyword List of values that either optionally override default
    behaviors of this function or are optionally required.  The available
    options are:

      * `owning_owner_id` - if the Access Account is an Owned Access Account,
      this value must be set to the record ID of the Access Account's Owner.
      Otherwise it must be set `nil` or not provided.  The default value is
      `nil`.

      * `instance_id` - the record ID of the Application Instance to which the
      Access Account holder wishes to authenticate.  This value is required must
      be provided at function call time or the Authentication State will be
      returned in a `:rejected` status.  In special cases where the
      authentication attempt is outside of the context of a specific Instance,
      the special value `:bypass` may be used for this option indicating that
      the authentication attempt may skip the permitted Instance check. There is
      no default value (default `nil`).

      * `host_ban_rate_limit` - overrides the default host IP address based Rate
      Limit.  The value is set via a tuple in the following form:
      `{<Maximum Attempts>, <Time Window in Seconds>}`.  The default value is 30
      attempts over a time window of 2 hours.

      * `identifier_rate_limit` - overrides the default identifier based Rate
      Limit.  The value is set via a tuple in the following form:
      `{<Maximum Attempts>, <Time Window in Seconds>}`.  The default value is 5
      attempts over a time window of 30 minutes.

      * `deadline_minutes` - overrides the default number of minutes that an
      authentication process can take before being rejected for taking too long.
      This deadline is needed because an arbitrary time can pass due to user
      interaction if the authenticator allows for an interruptable
      authentication process.  The default deadline allows for 5 minutes to
      complete the authentication process.
  """
  @spec authenticate_api_token(
          Types.account_identifier(),
          Types.credential(),
          NetTypes.addr_structs(),
          MscmpSystInstance.Types.instance_id(),
          Keyword.t()
        ) ::
          {:ok, Types.AuthenticationState.t()} | {:error, MscmpSystError.t()}

  defdelegate authenticate_api_token(
                identifier,
                plaintext_token,
                host_addr,
                instance_id,
                opts \\ []
              ),
              to: Impl.ExtendedAuthLogic
end
