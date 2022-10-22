defmodule MsbmsSystAuthentication do
  alias MsbmsSystAuthentication.Data
  alias MsbmsSystAuthentication.Impl
  alias MsbmsSystAuthentication.Types

  @moduledoc """
  API for the management of system user authentication.

  Authentication is a global concern allowing users to be either bound to
  specific Application Instances and Owners or to be independent and valid for
  a number of Applications and Instances.
  """

  @doc section: :access_account_data
  @doc """
  Create a new Access Account.

  ## Parameters

    * `access_account_params` - a map of required and optional parameters which
    define the new Access Account record.  Required attributes in this map are:
    `internal_name`, `external_name`, `access_account_state_id`, and
    `allow_global_logins`.

  ## Example

      iex> state = MsbmsSystEnums.get_default_enum_item("access_account_states")
      iex> {:ok, %MsbmsSystAuthentication.Data.SystAccessAccounts{}} =
      ...>   MsbmsSystAuthentication.create_access_account(
      ...>     %{
      ...>       internal_name: "example_create_accnt",
      ...>       external_name: "Create Access Account Example",
      ...>       access_account_state_id: state.id,
      ...>       allow_global_logins: true
      ...>      }
      ...>    )
  """

  @spec create_access_account(Types.access_account_params()) ::
          {:ok, Data.SystAccessAccounts.t()} | {:error, MsbmsSystError.t()}
  defdelegate create_access_account(access_account_params), to: Impl.AccessAccount

  @doc section: :access_account_data
  @doc """
  Looks up an Access Account record ID by its internal name.

  ## Parameters

    * `access_account_name` - the internal name of the record for which to
    retrieve the record ID.

  ## Examples

      iex> {:ok, access_account_id}  =
      ...>   MsbmsSystAuthentication.get_access_account_id_by_name("example_accnt")
      iex> is_binary(access_account_id)
      true
  """

  @spec get_access_account_id_by_name(Types.access_account_name()) ::
          {:ok, Types.access_account_id()} | {:error, MsbmsSystError.t()}
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
      ...>   %MsbmsSystAuthentication.Data.SystAccessAccounts{internal_name: "example_accnt"}
      ...> } =
      ...>   MsbmsSystAuthentication.get_access_account_by_name("example_accnt")
  """

  @spec get_access_account_by_name(Types.access_account_name()) ::
          Data.SystAccessAccounts.t() | {:error, MsbmsSystError.t()}
  defdelegate get_access_account_by_name(access_account_name), to: Impl.AccessAccount

  @doc section: :access_account_data
  @doc """
  Updates the maintainable fields of a given Access Account record.

  ## Parameters

    * `access_account` - either the record ID value of the Access Account to
    update or is the complete `MsbmsSystAccessAccount.Data.SystAccessAccounts`
    struct representing the before-update state of the Access Account record.

    * `access_account_params` - a map containing those attributes to be changed
    along with their new values.

  ## Example

      iex> {:ok, target_access_account} =
      ...>   MsbmsSystAuthentication.get_access_account_by_name("example_accnt")
      iex> {:ok, updated_access_account} =
      ...>   MsbmsSystAuthentication.update_access_account(
      ...>     target_access_account,
      ...>     %{external_name: "Updated Example Account Name"}
      ...>   )
      iex> %MsbmsSystAuthentication.Data.SystAccessAccounts{
      ...>   external_name: "Updated Example Account Name"
      ...> } = updated_access_account
  """

  @spec update_access_account(
          Types.access_account_id() | Data.SystAccessAccounts.t(),
          Types.access_account_params()
        ) ::
          {:ok, Data.SystAccessAccounts.t()} | {:error, MsbmsSystError.t()}
  defdelegate update_access_account(access_account, access_account_params), to: Impl.AccessAccount

  @doc section: :access_account_data
  @doc """
  Purges the requested Access Account if the Access Account State is of
  a purge eligible functional type.

  ## Parameters

    * `access_account` - is either the record ID of the Access Account to purge
    or the populated `MsbmsSystAccessAccount.Data.SystAccessAccounts` struct
    representing the record to purge.

  ## Example

      iex> {:ok, target_access_account} =
      ...>   MsbmsSystAuthentication.get_access_account_by_name("example_purge_accnt")
      iex> MsbmsSystAuthentication.purge_access_account(target_access_account)
      :ok
  """
  @spec purge_access_account(Types.access_account_id() | Data.SystAccessAccounts.t()) ::
          :ok | {:error, MsbmsSystError.t()}
  defdelegate purge_access_account(access_account), to: Impl.AccessAccount

  @doc section: :access_account_instance_assoc_data
  @doc """
  Invites or re-invites an Access Account to establish access rights to a
  specific Instance.

  The invitation process creates a `syst_access_account_instance_assocs` record
  for the requested Access Account, Instance, and Credential Type and sets the
  `invitation_issued` field to the current date/time.  Re-invitation will
  update an existing `syst_access_account_instance_assocs` record resetting
  invite data such as the invitation expiration date or resetting the declined
  state if the record was previously declined by the Access Account holder.
  Once a `syst_access_account_instance_assocs` record is accepted, it may not
  be re-invited again using this process until the record is revoked (deleted).

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
          MsbmsSystInstanceMgr.Types.instance_id(),
          Keyword.t()
        ) :: {:ok, Data.SystAccessAccountInstanceAssocs.t()} | {:error, MsbmsSystError.t()}
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
    `MsbmsSystAuthentication.Data.SystAccessAccountInstanceAssocs` struct to
    accept or the record ID of the record to accept.
  """
  @spec accept_instance_invite(
          Types.access_account_instance_assoc_id()
          | Data.SystAccessAccountInstanceAssocs.t()
        ) :: {:ok, Data.SystAccessAccountInstanceAssocs.t()} | {:error, MsbmsSystError.t()}
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
          MsbmsSystInstanceMgr.Types.instance_id()
        ) :: {:ok, Data.SystAccessAccountInstanceAssocs.t()} | {:error, MsbmsSystError.t()}
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
    `MsbmsSystAuthentication.Data.SystAccessAccountInstanceAssocs` struct to
    decline or the record ID of the record to decline.
  """
  @spec decline_instance_invite(
          Types.access_account_instance_assoc_id()
          | Data.SystAccessAccountInstanceAssocs.t()
        ) :: :ok | {:error, MsbmsSystError.t()}
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
          MsbmsSystInstanceMgr.Types.instance_id()
        ) :: {:ok, Data.SystAccessAccountInstanceAssocs.t()} | {:error, MsbmsSystError.t()}
  defdelegate decline_instance_invite(access_account_id, instance_id),
    to: Impl.AccessAccountInstanceAssoc

  @doc section: :access_account_instance_assoc_data
  @doc """
  Revokes the access or invitation to access an Instance from the given Access
  Account.

  Simply put, Access Accounts are both invited and granted access to Instances
  via Access Account Instance Association records (see:
  `MsbmsSystAuthentication.Data.SystAccessAccountInstanceAssocs`) and this
  function deletes those records.  This has the effect of revoking the
  invitation to access an Instance from the Access Account/Credential Type
  combination.

  Records in any state of invited, accepted, or declined may be revoked/deleted
  using this function.

  ## Parameters

    * `access_account_instance_assoc` - this value may be either the populated
    `MsbmsSystAuthentication.Data.SystAccessAccountInstanceAssocs` struct to
    revoke or the record ID of the record to revoke.
  """
  @spec revoke_instance_access(
          Types.access_account_instance_assoc_id()
          | Data.SystAccessAccountInstanceAssocs.t()
        ) :: :ok | {:error, MsbmsSystError.t()}
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
          MsbmsSystInstanceMgr.Types.instance_id()
        ) :: {:ok, Data.SystAccessAccountInstanceAssocs.t()} | {:error, MsbmsSystError.t()}
  defdelegate revoke_instance_access(access_account_id, instance_id),
    to: Impl.AccessAccountInstanceAssoc

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

      iex> MsbmsSystAuthentication.create_disallowed_password("Example Disallowed Password")
      :ok

  Any subsequent attempt to add the same password to the list again will appear
  to succeed while silently doing nothing.

      iex> MsbmsSystAuthentication.create_disallowed_password("Example Disallowed Password")
      :ok
  """
  @spec create_disallowed_password(Types.credential()) :: :ok | {:error, MsbmsSystError.t()}
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

      iex> MsbmsSystAuthentication.password_disallowed("Is Disallowed")
      {:ok, true}

    When a password has not been previously disallowed.

      iex> MsbmsSystAuthentication.password_disallowed("Is Not Disallowed")
      {:ok, false}
  """
  @spec password_disallowed(Types.credential()) :: {:ok, boolean()} | {:error, MsbmsSystError.t()}
  defdelegate password_disallowed(password), to: Impl.PasswordRules

  @doc section: :password_rule_data
  @doc """
  Removes a password from the disallowed passwords list.

  On success, this function will return a success tuple indicating if the
  requested password was deleted from the disallowed passwords list
  (`{:ok, :deleted}`) or if the password simply wasn't found in the list
  (`{:ok, :no_record}`).

  ## Parameters

    * `password` - the plaintext password to delete from the disallowed
    passwords list.

  ## Examples

    Result when deleting a record from the list.

      iex> MsbmsSystAuthentication.delete_disallowed_password("No Longer Disallowed")
      {:ok, :deleted}

    Result when trying to delete a record not already on the list.

      iex> MsbmsSystAuthentication.delete_disallowed_password("Not on List")
      {:ok, :no_record}
  """
  @spec delete_disallowed_password(Types.credential()) ::
          {:ok, :deleted | :no_record} | {:error, MsbmsSystError.t()}
  defdelegate delete_disallowed_password(password), to: Impl.PasswordRules
end
