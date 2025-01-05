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

  import Msutils.Guards

  import MscmpSystNetwork.Guards

  alias MscmpSystAuthn.Impl
  alias MscmpSystAuthn.Types
  alias MscmpSystError.Types.Context, as: ErrorContext
  alias MscmpSystNetwork.Types, as: NetTypes

  ##############################################################################
  #
  # Options Definition
  #
  #

  # Note that the defaults expressed in these general option statements should
  # reflect the most secure value possible, not necessarily the most common
  # option selected.  For example, `:create_validated` is more commonly
  # defaulted to `true`, but in contexts where it should be `false` failing to
  # override the general default would lead to a security vulnerability.

  option_defs = [
    access_account_id: [
      type: :string,
      doc: """
      References a specific Access Account record to use by its record ID.
      """
    ],
    access_account_name: [
      type: :string,
      doc: """
      References a specific Access Account record to use by its Internal Name
      value.
      """
    ],
    create_accepted: [
      type: :boolean,
      default: false,
      doc: "Whether to create the association as already accepted"
    ],
    expiration_days: [
      type: :integer,
      default: 30,
      doc: "Number of days until the invitation expires"
    ],
    pg_format: [
      type: {:in, [:bytea, :plain_text]},
      default: :plain_text,
      doc: """
      Indicates the format of the disallowed password text.  `:bytea` is the
      PostgreSQL textual representation of its `bytea` data type and
      `:plain_text` is just what it sounds like.
      """
    ],
    timeout: [
      type: :non_neg_integer,
      default: 300_000,
      doc: """
      The timeout (in milliseconds) of the database disallowed password load.
      If the disallowed password load takes longer than this value, the load is
      aborted and an error is raised.
      """
    ],
    create_validated: [
      type: :boolean,
      default: false,
      doc: """
      Specifies whether or not to create a Identity record as being considered
      validated, thereby bypassing any interactive validation process.
      """
    ],
    credential_token: [
      type: :string,
      doc: """
      Specifies a specific token value to use as a validation credential.
      If this value is `nil`, which is typically the case, a token will be
      randomly generated.  Therefore this option should be seen as an override
      to standard behavior.
      """
    ],
    credential_token_length: [
      type: :pos_integer,
      default: 40,
      doc: """
      Specifies the length of the token to generate when dealing with generated
      credentials such as validation credentials.
      """
    ],
    credential_tokens: [
      type: {:or, [{:list, :any}, {:in, [:alphanum, :mixed_alphanum, :b32e, :b32c]}]},
      type_doc: "t:Msutils.String.Types.tokens/0",
      type_spec: quote(do: Msutils.String.Types.tokens()),
      default: :mixed_alphanum,
      doc: """
      Specifies a pre-defined token set or a custom set of tokens for use in
      generating credentials, such as validation credentials.  A custom token
      set must be expressed as an Erlang charlist.
      """
    ],
    identity_token: [
      type: :string,
      doc: """
      Specifies a specific token value to use as an Identity in cases where an
      identity is located by a token value. If this value is `nil`, which is
      typically the case, a token will be randomly generated.  Therefore this
      option should be seen as an override to standard behavior.
      """
    ],
    identity_token_length: [
      type: :pos_integer,
      default: 40,
      doc: """
      Specifies the length of the token to generate when dealing with generated
      identities such as validation identity.
      """
    ],
    identity_tokens: [
      type: {:or, [{:list, :any}, {:in, [:alphanum, :mixed_alphanum, :b32e, :b32c]}]},
      type_doc: "t:Msutils.String.Types.tokens/0",
      type_spec: quote(do: Msutils.String.Types.tokens()),
      default: :mixed_alphanum,
      doc: """
      Specifies the pre-defined token set or a set of tokens to use for
      generated identities, such as validation identities.  A token set must
      be expressed as an erlang charlist.
      """
    ],
    expiration_hours: [
      type: :pos_integer,
      default: 24,
      doc: """
      Specifies the number of hours that the recovery or validation identity
      should be considered valid.
      """
    ],
    account_code: [
      type: :string,
      doc: """
      this option overrides the randomly generated Account Code with the value
      of this option.  By default the system randomly generates the Account
      Code.
      """
    ],
    external_name: [
      type: :string,
      doc: """
      API Token Identities permit Access Account holder naming of the Identity
      as it may be common for an one Access Account to require multiple API
      Token Authenticators for different purposes.  This option allows that name
      to be set at Identity creation time.
      """
    ],
    owning_owner_id: [
      type: {:or, [:string, nil]},
      doc: """
      if the Access Account is an Owned Access Account, this value must be set
      to the record ID of the Access Account's Owner.Otherwise it must be set
      `nil` or not provided.
      """
    ],
    instance_id: [
      type: {:or, [:string, {:in, [:bypass]}, nil]},
      doc: """
      the record ID of the Application Instance to which the Access Account
      holder wishes to authenticate.  A final value for instance_id is not
      required when the Email/Password authentication process is initiated but
      is required for it to complete.  If this value is not initially provided,
      the function will be `interrupted` returning an Authentication State
      status value of `:pending`.  Deferral may be appropriate if, for example,
      we want to allow the Access Account holder to select the specific Instance
      they wish to access from a list of their permitted Instances.  Final
      resolution of the value must reference an Instance for which the Access
      Account permitted authentication attempts or must be set `:bypass` if the
      authentication attempt is a special case where a specific Instance is not
      relevant.
      """
    ],
    deadline_minutes: [
      type: :non_neg_integer,
      default: 5,
      doc: """
      overrides the default number of minutes that an authentication process can
      take before being rejected for taking too long.  This deadline is needed
      because an arbitrary time can pass due to user interaction, such as
      selecting an Instance or providing an MFA credential.
      """
    ],
    identifier_rate_limit: [
      type: {:tuple, [:pos_integer, :pos_integer]},
      default: {5, 60_000 * 30},
      doc: """
      The number of allowed attempts within a given time period to authenticate
      using any single identifier.  The tuple is of the form: {<attempts>,
      <milliseconds>}.
      """
    ],
    host_ban_rate_limit: [
      type: {:tuple, [:pos_integer, :pos_integer]},
      default: {30, 60_000 * 60 * 2},
      doc: """
      The number of consecutive failed attempts made from a single host
      permitted during the given time period before that host is added to the
      "banned hosts" list.  The tuple is of the form:
      {<attempts>, <milliseconds>}
      """
    ]
  ]

  # ==============================================================================================
  # ==============================================================================================
  #
  # Enumerations Data
  #
  # ==============================================================================================
  # ==============================================================================================

  ##############################################################################
  #
  # get_identity_type_by_name
  #
  #

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
  def get_identity_type_by_name(identity_type_name) when is_binary(identity_type_name),
    do: Impl.Identity.get_identity_type_by_name(identity_type_name)

  ##############################################################################
  #
  # get_identity_type_default
  #
  #

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
  @spec get_identity_type_default() :: Msdata.SystEnumItems.t()
  @spec get_identity_type_default(Types.identity_type_functional_types() | nil) ::
          Msdata.SystEnumItems.t()
  def get_identity_type_default(functional_type \\ nil)
      when is_reg_atom(functional_type) or is_nil(functional_type),
      do: Impl.Identity.get_identity_type_default(functional_type)

  ##############################################################################
  #
  # get_credential_type_by_name
  #
  #

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
  def get_credential_type_by_name(credential_type_name) when is_binary(credential_type_name),
    do: Impl.Credential.get_credential_type_by_name(credential_type_name)

  ##############################################################################
  #
  # get_credential_type_default
  #
  #

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
  @spec get_credential_type_default() :: Msdata.SystEnumItems.t()
  @spec get_credential_type_default(Types.credential_type_functional_types() | nil) ::
          Msdata.SystEnumItems.t()
  def get_credential_type_default(functional_type \\ nil)
      when is_reg_atom(functional_type) or is_nil(functional_type),
      do: Impl.Credential.get_credential_type_default(functional_type)

  # ==============================================================================================
  # ==============================================================================================
  #
  # Access Account Data
  #
  # ==============================================================================================
  # ==============================================================================================

  ##############################################################################
  #
  # get_access_account_state_by_name
  #
  #

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
  def get_access_account_state_by_name(access_account_state_name)
      when is_binary(access_account_state_name),
      do: Impl.AccessAccount.get_access_account_state_by_name(access_account_state_name)

  ##############################################################################
  #
  # get_access_account_state_default
  #
  #

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
  @spec get_access_account_state_default() :: Msdata.SystEnumItems.t()
  @spec get_access_account_state_default(Types.access_account_state_functional_types() | nil) ::
          Msdata.SystEnumItems.t()
  def get_access_account_state_default(functional_type \\ nil)
      when is_reg_atom(functional_type) or is_nil(functional_type),
      do: Impl.AccessAccount.get_access_account_state_default(functional_type)

  ##############################################################################
  #
  # create_access_account
  #
  #

  @doc section: :access_account_data
  @doc """
  Create a new Access Account.

  ## Parameters

    * `access_account_params` - a map of required and optional parameters which
    define the new Access Account record.  Required attributes in this map are:
    `internal_name`, `external_name`, `access_account_state_id`, and
    `allow_global_logins`.

  ## Example

      iex> state = MscmpSystEnums.get_default_item("access_account_states")
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
          {:ok, Msdata.SystAccessAccounts.t()} | {:error, Mserror.AuthnError.t()}
  def create_access_account(access_account_params) when is_map(access_account_params) do
    case Impl.AccessAccount.create_access_account(access_account_params) do
      {:ok, access_account} ->
        {:ok, access_account}

      {:error, error} ->
        {:error,
         Mserror.AuthnError.new(:access_account_data, "Error creating access account",
           cause: error,
           context: %ErrorContext{
             origin: {__MODULE__, :create_access_account, 1},
             parameters: %{access_account_params: access_account_params}
           }
         )}
    end
  end

  ##############################################################################
  #
  # get_access_account_id_by_name
  #
  #

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
          {:ok, Types.access_account_id()} | {:error, Mserror.AuthnError.t()}
  def get_access_account_id_by_name(access_account_name) when is_binary(access_account_name) do
    case Impl.AccessAccount.get_access_account_id_by_name(access_account_name) do
      {:ok, access_account_id} ->
        {:ok, access_account_id}

      {:error, error} ->
        {:error,
         Mserror.AuthnError.new(:access_account_data, "Error getting access account ID by name",
           cause: error,
           context: %ErrorContext{
             origin: {__MODULE__, :get_access_account_id_by_name, 1},
             parameters: %{access_account_name: access_account_name}
           }
         )}
    end
  end

  ##############################################################################
  #
  # get_access_account_by_name
  #
  #

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
          {:ok, Msdata.SystAccessAccounts.t()} | {:error, Mserror.AuthnError.t()}
  def get_access_account_by_name(access_account_name) when is_binary(access_account_name) do
    case Impl.AccessAccount.get_access_account_by_name(access_account_name) do
      {:ok, access_account} ->
        {:ok, access_account}

      {:error, error} ->
        {:error,
         Mserror.AuthnError.new(:access_account_data, "Error getting access account by name",
           cause: error,
           context: %ErrorContext{
             origin: {__MODULE__, :get_access_account_by_name, 1},
             parameters: %{access_account_name: access_account_name}
           }
         )}
    end
  end

  ##############################################################################
  #
  # update_access_account
  #
  #

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
          {:ok, Msdata.SystAccessAccounts.t()} | {:error, Mserror.AuthnError.t()}
  def update_access_account(access_account, access_account_params)
      when (is_uuid(access_account) or is_struct(access_account, Msdata.SystAccessAccounts)) and
             is_map(access_account_params) do
    case Impl.AccessAccount.update_access_account(access_account, access_account_params) do
      {:ok, access_account} ->
        {:ok, access_account}

      {:error, error} ->
        {:error,
         Mserror.AuthnError.new(:access_account_data, "Error updating access account",
           cause: error,
           context: %ErrorContext{
             origin: {__MODULE__, :update_access_account, 2},
             parameters: %{
               access_account: access_account,
               access_account_params: access_account_params
             }
           }
         )}
    end
  end

  ##############################################################################
  #
  # purge_access_account
  #
  #

  @doc section: :access_account_data
  @doc """
  Purges the requested Access Account if the Access Account State is of
  a purge eligible functional type.

  ## Parameters

    * `access_account` - is either the record ID of the Access Account to purge
    or the populated `Msdata.SystAccessAccounts` struct
    representing the record to purge.

  ## Returns

    * `:ok` - The Access Account was successfully purged

    * `{:error, %Mserror.AuthnError{cause: <cause>}}` - The purge operation failed.

  Common error causes include:

    * `:not_found` - The specified Access Account ID does not exist

    * `{:purge_ineligible, functional_type}` - The Access Account's state is not
      eligible for purging (functional type is not
      "access_account_states_purge_eligible")

    * `{:database_error, error}` - An error occurred during the database delete operation

  ## Example

      iex> {:ok, target_access_account} =
      ...>   MscmpSystAuthn.get_access_account_by_name("example_purge_accnt")
      iex> MscmpSystAuthn.purge_access_account(target_access_account)
      :ok
  """
  @spec purge_access_account(Types.access_account_id() | Msdata.SystAccessAccounts.t()) ::
          :ok | {:error, Mserror.AuthnError.t()}
  def purge_access_account(access_account)
      when is_uuid(access_account) or is_struct(access_account, Msdata.SystAccessAccounts) do
    case Impl.AccessAccount.purge_access_account(access_account) do
      :ok ->
        :ok

      {:error, error} ->
        {:error,
         Mserror.AuthnError.new(:access_account_data, "Error purging access account",
           cause: error,
           context: %ErrorContext{
             origin: {__MODULE__, :purge_access_account, 1},
             parameters: %{access_account: access_account}
           }
         )}
    end
  end

  ##############################################################################
  #
  # access_accounts_exist?
  #
  #

  @doc section: :access_account_data
  @doc """
  Tests to see if any Access Accounts exist in the database.

  If an appropriate Access Account record is found, the function returns true,
  otherwise false.  Any other condition is considered an error and will
  result in an error tuple being returned indicating the cause of the error.


  ## Examples

  Check if any Access Account record exists.

      iex> MscmpSystAuthn.access_accounts_exist?()
      true

  """
  @spec access_accounts_exist?() :: boolean()
  defdelegate access_accounts_exist?, to: Impl.AccessAccount

  ##############################################################################
  #
  # access_account_name_exists?
  #
  #

  @doc section: :access_account_data
  @doc """
  Tests to see if a named Access Account exists in the database.

  If an appropriate Access Account record is found, the function returns true,
  otherwise false.  Any other condition is considered an error and will
  result in an error tuple being returned indicating the cause of the error.


  ## Examples

  Check if a specific named Access Account record exists.

      iex> MscmpSystAuthn.access_account_name_exists?("example_accnt")
      true

  If a non-existent Access Account is requested, the function indicates the
  record was not found by returning false

      iex> MscmpSystAuthn.access_account_name_exists?("nonexistent_access_account")
      false
  """
  @spec access_account_name_exists?(Types.access_account_name()) :: boolean()
  def access_account_name_exists?(access_account_name) when is_binary(access_account_name),
    do: Impl.AccessAccount.access_account_name_exists?(access_account_name)

  ##############################################################################
  #
  # access_account_id_exists?
  #
  #

  @doc section: :access_account_data
  @doc """
  Tests to see if an Access Account with the given record ID exists in the
  database.

  If an appropriate Access Account record is found, the function returns true,
  otherwise false.  Any other condition is considered an error and will
  result in an error tuple being returned indicating the cause of the error.


  ## Examples

  Check if a specific Access Account record exists for the given ID.

      iex> {:ok, access_account_id} =
      ...>   MscmpSystAuthn.get_access_account_id_by_name("example_accnt")
      iex> MscmpSystAuthn.access_account_id_exists?(access_account_id)
      true

  If a non-existent Access Account is requested, the function indicates the
  record was not found by returning false

      iex> MscmpSystAuthn.access_account_id_exists?("00000000-0000-0000-0000-000000000000")
      false
  """
  @spec access_account_id_exists?(Types.access_account_id()) :: boolean()
  def access_account_id_exists?(access_account_id) when is_uuid(access_account_id),
    do: Impl.AccessAccount.access_account_id_exists?(access_account_id)

  # ==============================================================================================
  # ==============================================================================================
  #
  # Access Account Instance Association Data
  #
  # ==============================================================================================
  # ==============================================================================================

  ##############################################################################
  #
  # invite_to_instance
  #
  #

  @invite_to_instance_opts NimbleOptions.new!(
                             Keyword.take(option_defs, [:create_accepted, :expiration_days])
                           )

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
    and behaviors.

  ## Options

    #{NimbleOptions.docs(@invite_to_instance_opts)}
  """
  @spec invite_to_instance(
          Types.access_account_id(),
          MscmpSystInstance.Types.instance_id()
        ) :: {:ok, Msdata.SystAccessAccountInstanceAssocs.t()} | {:error, Mserror.AuthnError.t()}
  @spec invite_to_instance(
          Types.access_account_id(),
          MscmpSystInstance.Types.instance_id(),
          Keyword.t()
        ) :: {:ok, Msdata.SystAccessAccountInstanceAssocs.t()} | {:error, Mserror.AuthnError.t()}
  def invite_to_instance(access_account_id, instance_id, opts \\ [])
      when is_uuid(access_account_id) and is_uuid(instance_id) do
    validated_opts = NimbleOptions.validate!(opts, @invite_to_instance_opts)

    case Impl.AccessAccountInstanceAssoc.invite_to_instance(
           access_account_id,
           instance_id,
           validated_opts
         ) do
      {:ok, assoc} ->
        {:ok, assoc}

      {:error, error} ->
        {:error,
         Mserror.AuthnError.new(
           :access_account_instance_assoc_data,
           "Error inviting access account to instance",
           cause: error,
           context: %ErrorContext{
             origin: {__MODULE__, :invite_to_instance, 3},
             parameters: %{
               access_account_id: access_account_id,
               instance_id: instance_id,
               opts: opts
             }
           }
         )}
    end
  end

  ##############################################################################
  #
  # accept_instance_invite
  #
  #

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
        ) :: {:ok, Msdata.SystAccessAccountInstanceAssocs.t()} | {:error, Mserror.AuthnError.t()}
  def accept_instance_invite(access_account_instance_assoc)
      when is_uuid(access_account_instance_assoc) or
             is_struct(access_account_instance_assoc, Msdata.SystAccessAccountInstanceAssocs) do
    case Impl.AccessAccountInstanceAssoc.accept_instance_invite(access_account_instance_assoc) do
      {:ok, assoc} ->
        {:ok, assoc}

      {:error, error} ->
        {:error,
         Mserror.AuthnError.new(
           :access_account_instance_assoc_data,
           "Error accepting instance invite",
           cause: error,
           context: %ErrorContext{
             origin: {__MODULE__, :accept_instance_invite, 1},
             parameters: %{access_account_instance_assoc: access_account_instance_assoc}
           }
         )}
    end
  end

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
        ) :: {:ok, Msdata.SystAccessAccountInstanceAssocs.t()} | {:error, Mserror.AuthnError.t()}
  def accept_instance_invite(access_account_id, instance_id)
      when is_uuid(access_account_id) and is_uuid(instance_id) do
    case Impl.AccessAccountInstanceAssoc.accept_instance_invite(access_account_id, instance_id) do
      {:ok, assoc} ->
        {:ok, assoc}

      {:error, error} ->
        {:error,
         Mserror.AuthnError.new(
           :access_account_instance_assoc_data,
           "Error accepting instance invite",
           cause: error,
           context: %ErrorContext{
             origin: {__MODULE__, :accept_instance_invite, 2},
             parameters: %{access_account_id: access_account_id, instance_id: instance_id}
           }
         )}
    end
  end

  ##############################################################################
  #
  # decline_instance_invite
  #
  #

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
        ) :: {:ok, Msdata.SystAccessAccountInstanceAssocs.t()} | {:error, Mserror.AuthnError.t()}
  def decline_instance_invite(access_account_instance_assoc)
      when is_uuid(access_account_instance_assoc) or
             is_struct(access_account_instance_assoc, Msdata.SystAccessAccountInstanceAssocs) do
    case Impl.AccessAccountInstanceAssoc.decline_instance_invite(access_account_instance_assoc) do
      {:ok, assoc} ->
        {:ok, assoc}

      {:error, error} ->
        {:error,
         Mserror.AuthnError.new(
           :access_account_instance_assoc_data,
           "Error declining instance invite",
           cause: error,
           context: %ErrorContext{
             origin: {__MODULE__, :decline_instance_invite, 1},
             parameters: %{access_account_instance_assoc: access_account_instance_assoc}
           }
         )}
    end
  end

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
        ) :: {:ok, Msdata.SystAccessAccountInstanceAssocs.t()} | {:error, Mserror.AuthnError.t()}
  def decline_instance_invite(access_account_id, instance_id)
      when is_uuid(access_account_id) and is_uuid(instance_id) do
    case Impl.AccessAccountInstanceAssoc.decline_instance_invite(access_account_id, instance_id) do
      {:ok, assoc} ->
        {:ok, assoc}

      {:error, error} ->
        {:error,
         Mserror.AuthnError.new(
           :access_account_instance_assoc_data,
           "Error declining instance invite",
           cause: error,
           context: %ErrorContext{
             origin: {__MODULE__, :decline_instance_invite, 2},
             parameters: %{access_account_id: access_account_id, instance_id: instance_id}
           }
         )}
    end
  end

  ##############################################################################
  #
  # revoke_instance_access
  #
  #

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
        ) :: :ok | {:error, Mserror.AuthnError.t()}
  def revoke_instance_access(access_account_instance_assoc)
      when is_uuid(access_account_instance_assoc) or
             is_struct(access_account_instance_assoc, Msdata.SystAccessAccountInstanceAssocs) do
    case Impl.AccessAccountInstanceAssoc.revoke_instance_access(access_account_instance_assoc) do
      :ok ->
        :ok

      {:error, error} ->
        {:error,
         Mserror.AuthnError.new(
           :access_account_instance_assoc_data,
           "Error revoking instance access",
           cause: error,
           context: %ErrorContext{
             origin: {__MODULE__, :revoke_instance_access, 1},
             parameters: %{access_account_instance_assoc: access_account_instance_assoc}
           }
         )}
    end
  end

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
        ) :: :ok | {:error, Mserror.AuthnError.t()}
  def revoke_instance_access(access_account_id, instance_id)
      when is_uuid(access_account_id) and is_uuid(instance_id) do
    case Impl.AccessAccountInstanceAssoc.revoke_instance_access(access_account_id, instance_id) do
      :ok ->
        :ok

      {:error, error} ->
        {:error,
         Mserror.AuthnError.new(
           :access_account_instance_assoc_data,
           "Error revoking instance access",
           cause: error,
           context: %ErrorContext{
             origin: {__MODULE__, :revoke_instance_access, 2},
             parameters: %{access_account_id: access_account_id, instance_id: instance_id}
           }
         )}
    end
  end

  # ==============================================================================================
  # ==============================================================================================
  #
  # Password Rule Data
  #
  # ==============================================================================================
  # ==============================================================================================

  ##############################################################################
  #
  # load_disallowed_passwords
  #
  #

  @load_disallowed_passwords_opts NimbleOptions.new!(
                                    Keyword.take(option_defs, [:pg_format, :timeout])
                                  )

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

    * `opts` - An optional Keyword List of settings with which the caller can
    influence the behavior of this function.

  ## Options

      #{NimbleOptions.docs(@load_disallowed_passwords_opts)}

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
      ...>   |> MscmpSystAuthn.load_disallowed_passwords(pg_format: :bytea)
      :ok
      iex> MscmpSystAuthn.password_disallowed?("example_pg_disallowed")
      true
  """
  @spec load_disallowed_passwords(Enumerable.t()) :: :ok | {:error, Mserror.AuthnError.t()}
  @spec load_disallowed_passwords(Enumerable.t(), Keyword.t()) ::
          :ok | {:error, Mserror.AuthnError.t()}
  def load_disallowed_passwords(password_list, opts \\ [])
      when not is_nil(password_list) and is_list(opts) do
    validated_opts = NimbleOptions.validate!(opts, @load_disallowed_passwords_opts)

    case Impl.PasswordRules.load_disallowed_passwords(password_list, validated_opts) do
      :ok ->
        :ok

      {:error, error} ->
        {:error,
         Mserror.AuthnError.new(:password_rule_data, "Error loading disallowed passwords",
           cause: error,
           context: %ErrorContext{
             origin: {__MODULE__, :load_disallowed_passwords, 2},
             parameters: %{password_list: password_list, opts: opts}
           }
         )}
    end
  end

  ##############################################################################
  #
  # disallowed_passwords_populated?
  #
  #

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
  defdelegate disallowed_passwords_populated?, to: Impl.PasswordRules

  ##############################################################################
  #
  # create_disallowed_password
  #
  #

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
  @spec create_disallowed_password(Types.credential()) :: :ok | {:error, Mserror.AuthnError.t()}
  def create_disallowed_password(password) when is_binary(password) do
    case Impl.PasswordRules.create_disallowed_password(password) do
      :ok ->
        :ok

      {:error, error} ->
        {:error,
         Mserror.AuthnError.new(:password_rule_data, "Error creating disallowed password",
           cause: error,
           context: %ErrorContext{
             origin: {__MODULE__, :create_disallowed_password, 1},
             parameters: %{password: password}
           }
         )}
    end
  end

  ##############################################################################
  #
  # password_disallowed
  #
  #

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
  def password_disallowed?(password) when is_binary(password) do
    Impl.PasswordRules.password_disallowed?(password)
  end

  ##############################################################################
  #
  # delete_disallowed_password
  #
  #

  @doc section: :password_rule_data
  @doc """
  Removes a password from the disallowed passwords list.

  On success a success tuple in the form `:ok` is returned.  In all other cases
  an error tuple is returned.

  ## Parameters

    * `password` - the plaintext password to delete from the disallowed
    passwords list.

  ## Examples

    Result when deleting a record from the list.

      iex> MscmpSystAuthn.delete_disallowed_password("No Longer Disallowed")
      :ok

    Result when trying to delete a record not already on the list.

      iex> {:error, %Mserror.AuthnError{cause: :not_found}} =
      ...>   MscmpSystAuthn.delete_disallowed_password("Not on List")
  """
  @spec delete_disallowed_password(Types.credential()) ::
          :ok | {:error, Mserror.AuthnError.t()}
  def delete_disallowed_password(password) when is_binary(password) do
    case Impl.PasswordRules.delete_disallowed_password(password) do
      :ok ->
        :ok

      {:error, error} ->
        {:error,
         Mserror.AuthnError.new(:password_rule_data, "Error deleting disallowed password",
           cause: error,
           context: %ErrorContext{
             origin: {__MODULE__, :delete_disallowed_password, 1},
             parameters: %{password: password}
           }
         )}
    end
  end

  ##############################################################################
  #
  # create_owner_password_rules
  #
  #

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
          {:ok, Msdata.SystOwnerPasswordRules.t()}
          | {:error, Mserror.AuthnError.t()}
  def create_owner_password_rules(owner_id, insert_params)
      when is_uuid(owner_id) and is_map(insert_params) do
    case Impl.PasswordRules.create_owner_password_rules(owner_id, insert_params) do
      {:ok, result} ->
        {:ok, result}

      {:error, error} ->
        {:error,
         Mserror.AuthnError.new(:password_rule_data, "Error creating Owner Password Rules",
           cause: error,
           context: %ErrorContext{
             origin: {__MODULE__, :create_owner_password_rules, 2},
             parameters: %{owner_id: owner_id, insert_params: insert_params}
           }
         )}
    end
  end

  ##############################################################################
  #
  # update_global_password_rules
  #
  #

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
          {:ok, Msdata.SystGlobalPasswordRules.t()}
          | {:error, Mserror.AuthnError.t()}
  def update_global_password_rules(update_params) when is_map(update_params) do
    case Impl.PasswordRules.update_global_password_rules(update_params) do
      {:ok, result} ->
        {:ok, result}

      {:error, error} ->
        {:error,
         Mserror.AuthnError.new(:password_rule_data, "Error updating Global Password Rules",
           cause: error,
           context: %ErrorContext{
             origin: {__MODULE__, :update_global_password_rules, 1},
             parameters: %{update_params: update_params}
           }
         )}
    end
  end

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
          {:ok, Msdata.SystGlobalPasswordRules.t()}
          | {:error, Mserror.AuthnError.t()}
  def update_global_password_rules(
        %Msdata.SystGlobalPasswordRules{} = global_password_rules,
        update_params
      )
      when is_map(update_params) do
    case Impl.PasswordRules.update_global_password_rules(global_password_rules, update_params) do
      {:ok, result} ->
        {:ok, result}

      {:error, error} ->
        {:error,
         Mserror.AuthnError.new(:password_rule_data, "Error updating Global Password Rules",
           cause: error,
           context: %ErrorContext{
             origin: {__MODULE__, :update_global_password_rules, 2},
             parameters: %{
               global_password_rules: global_password_rules,
               update_params: update_params
             }
           }
         )}
    end
  end

  ##############################################################################
  #
  # update_owner_password_rules
  #
  #

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
          {:ok, Msdata.SystOwnerPasswordRules.t()}
          | {:error, Mserror.AuthnError.t()}
  def update_owner_password_rules(owner, update_params)
      when (is_uuid(owner) or is_struct(owner, Msdata.SystOwnerPasswordRules)) and
             is_map(update_params) do
    case Impl.PasswordRules.update_owner_password_rules(owner, update_params) do
      {:ok, result} ->
        {:ok, result}

      {:error, error} ->
        {:error,
         Mserror.AuthnError.new(:password_rule_data, "Error updating Owner Password Rules",
           cause: error,
           context: %ErrorContext{
             origin: {__MODULE__, :update_owner_password_rules, 2},
             parameters: %{owner: owner, update_params: update_params}
           }
         )}
    end
  end

  ##############################################################################
  #
  # get_global_password_rules
  #
  #

  @doc section: :password_rule_data
  @doc """
  Retrieves the currently active Global Password Rules.

  On successful retrieval a success tuple in the form of `{:ok, <record>}` is
  returned where record is a `Msdata.SystGlobalPasswordRules`
  struct.  Any exceptions are returned via an error tuple.
  """
  @spec get_global_password_rules() ::
          {:ok, Msdata.SystGlobalPasswordRules.t()}
          | {:error, :not_found}
          | {:error, Mserror.AuthnError.t()}
  def get_global_password_rules do
    case Impl.PasswordRules.get_global_password_rules() do
      {:ok, result} ->
        {:ok, result}

      {:error, error} ->
        {:error,
         Mserror.AuthnError.new(:password_rule_data, "Error retrieving Global Password Rules",
           cause: error,
           context: %ErrorContext{
             origin: {__MODULE__, :get_global_password_rules, 0},
             parameters: %{}
           }
         )}
    end
  end

  ##############################################################################
  #
  # get_owner_password_rules
  #
  #

  @doc section: :password_rule_data
  @doc """
  Retrieves the currently active Owner Password Rules for the requested Owner.

  On successful retrieval a success tuple in the form of `{:ok, <record>}` is
  returned where `<record>` is a populated
  `Msdata.SystOwnerPasswordRules` struct if Password Rules
  for the requested Owner was found or `nil` otherwise.  Any exceptions are
  returned via an error tuple.

  ## Parameters

    * `owner_id` - the Owner record ID for whom to retrieve Password Rules.
  """
  @spec get_owner_password_rules(MscmpSystInstance.Types.owner_id()) ::
          {:ok, Msdata.SystOwnerPasswordRules.t()} | {:error, Mserror.AuthnError.t()}
  def get_owner_password_rules(owner_id) when is_uuid(owner_id) do
    case Impl.PasswordRules.get_owner_password_rules(owner_id) do
      {:ok, result} ->
        {:ok, result}

      {:error, error} ->
        {:error,
         Mserror.AuthnError.new(:password_rule_data, "Error retrieving Owner Password Rules",
           cause: error,
           context: %ErrorContext{
             origin: {__MODULE__, :get_owner_password_rules, 1},
             parameters: %{owner_id: owner_id}
           }
         )}
    end
  end

  ##############################################################################
  #
  # get_generic_password_rules
  #
  #

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
          Msdata.SystGlobalPasswordRules.t()
          | Msdata.SystOwnerPasswordRules.t()
        ) :: Types.PasswordRules.t() | nil
  @spec get_generic_password_rules(
          Msdata.SystGlobalPasswordRules.t() | Msdata.SystOwnerPasswordRules.t(),
          Types.access_account_id() | nil
        ) :: Types.PasswordRules.t() | nil
  def get_generic_password_rules(pwd_rules_struct, access_account_id \\ nil)
      when (is_struct(pwd_rules_struct, Msdata.SystGlobalPasswordRules) or
              is_struct(pwd_rules_struct, Msdata.SystOwnerPasswordRules)) and
             (is_uuid(access_account_id) or is_nil(access_account_id)) do
    Impl.PasswordRules.get_generic_password_rules(pwd_rules_struct, access_account_id)
  end

  ##############################################################################
  #
  # get_access_account_password_rule
  #
  #

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
          {:ok, Types.PasswordRules.t()} | {:error, Mserror.AuthnError.t()}
  def get_access_account_password_rule(access_account_id) when is_uuid(access_account_id) do
    case Impl.PasswordRules.get_access_account_password_rule(access_account_id) do
      {:ok, result} ->
        {:ok, result}

      {:error, error} ->
        {:error,
         Mserror.AuthnError.new(
           :password_rule_data,
           "Error retrieving Access Account Password Rules",
           cause: error,
           context: %ErrorContext{
             origin: {__MODULE__, :get_access_account_password_rule, 1},
             parameters: %{access_account_id: access_account_id}
           }
         )}
    end
  end

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
  def get_access_account_password_rule!(access_account_id) when is_uuid(access_account_id) do
    case Impl.PasswordRules.get_access_account_password_rule(access_account_id) do
      {:ok, result} -> result
      {:error, error} -> raise error
    end
  end

  ##############################################################################
  #
  # verify_password_rules
  #
  #

  @doc section: :password_rule_data
  @doc """
  Compares a "Test" set of Password Rules against a "Standard" set of Password
  Rules and reports on which of the "Test" Rules are considered less stringent
  than the "Standard" Rules.

  The primary use case for this function is to test how Owner Password Rules
  ("Test" Rules) compare against the Global Password Rules ("Standard" Rules),
  but the function can compare any two rules.

  The function returns `:ok` if all rules pass validation, or
  `{:error, %Mserror.AuthnError{cause: {:invalid_password_rules, violations}}}`
  if any rules are violated. The violations will be a keyword list where each
  key represents the rule violated and the value that is the required value for
  the violated rule; whether the required value is a minimum or maximum depends
  on the nature of the specific rule being reported.

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
  @spec verify_password_rules(Types.PasswordRules.t()) :: :ok | {:error, Mserror.AuthnError.t()}
  @spec verify_password_rules(
          Types.PasswordRules.t(),
          Msdata.SystGlobalPasswordRules.t() | Types.PasswordRules.t() | nil
        ) :: :ok | {:error, Mserror.AuthnError.t()}
  def verify_password_rules(test_rules, standard_rules \\ nil)
      when (is_struct(test_rules, Msdata.SystGlobalPasswordRules) or
              is_struct(test_rules, Types.PasswordRules)) and
             (is_struct(standard_rules, Msdata.SystGlobalPasswordRules) or
                is_struct(standard_rules, Types.PasswordRules) or is_nil(standard_rules)) do
    case Impl.PasswordRules.verify_password_rules(test_rules, standard_rules) do
      :ok ->
        :ok

      {:error, error} ->
        {:error,
         Mserror.AuthnError.new(:password_rule_data, "Password rule verification error",
           cause: error,
           context: %ErrorContext{
             origin: {__MODULE__, :verify_password_rules, 2},
             parameters: %{test_rules: test_rules, standard_rules: standard_rules}
           }
         )}
    end
  end

  ##############################################################################
  #
  # delete_owner_password_rules
  #
  #

  @doc section: :password_rule_data
  @doc """
  Deletes an Owner Password Rules record from the system.

  ## Parameters

    * `owner_id` - the Owner record ID whose Password Rules are to be deleted.
  """
  @spec delete_owner_password_rules(MscmpSystInstance.Types.owner_id()) ::
          :ok | {:error, Mserror.AuthnError.t()}
  def delete_owner_password_rules(owner_id) when is_uuid(owner_id) do
    case Impl.PasswordRules.delete_owner_password_rules(owner_id) do
      :ok ->
        :ok

      {:error, error} ->
        {:error,
         Mserror.AuthnError.new(:password_rule_data, "Error deleting Owner Password Rules",
           cause: error,
           context: %ErrorContext{
             origin: {__MODULE__, :delete_owner_password_rules, 1},
             parameters: %{owner_id: owner_id}
           }
         )}
    end
  end

  ##############################################################################
  #
  # test_credential
  #
  #

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
      :ok

    An invalid password test.

      iex> {:ok, access_account_id} =
      ...>   MscmpSystAuthn.get_access_account_id_by_name("example_accnt")
      iex> {:error, %Mserror.AuthnError{cause: {:invalid_credential, [password_rule_length_min: 8]}}} =
      ...>   MscmpSystAuthn.test_credential(access_account_id, "short")
  """
  @spec test_credential(Types.access_account_id() | Types.PasswordRules.t(), Types.credential()) ::
          :ok | {:error, Mserror.AuthnError.t()}
  def test_credential(pwd_rules_or_access_account_id, plaintext_pwd)
      when (is_uuid(pwd_rules_or_access_account_id) or
              is_struct(pwd_rules_or_access_account_id, Types.PasswordRules)) and
             is_binary(plaintext_pwd) do
    case Impl.Credential.Password.test_credential(pwd_rules_or_access_account_id, plaintext_pwd) do
      :ok ->
        :ok

      {:error, error} ->
        {:error,
         Mserror.AuthnError.new(:password_rule_data, "Password testing error",
           cause: error,
           context: %ErrorContext{
             origin: {__MODULE__, :test_credential, 2},
             parameters: %{
               pwd_rules_or_access_account_id: pwd_rules_or_access_account_id,
               plaintext_pwd: "(Redacted)"
             }
           }
         )}
    end
  end

  # ==============================================================================================
  # ==============================================================================================
  #
  # Network Rule Data
  #
  # ==============================================================================================
  # ==============================================================================================

  ##############################################################################
  #
  # host_disallowed
  #
  #

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
  def host_disallowed?(host_addr) when is_ip(host_addr),
    do: Impl.NetworkRules.host_disallowed?(host_addr)

  ##############################################################################
  #
  # create_disallowed_host
  #
  #

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
      iex> false = MscmpSystAuthn.host_disallowed?(~i"10.123.123.20")
      iex> {:ok, {:disallowed, %Msdata.SystDisallowedHosts{}}} =
      ...>   MscmpSystAuthn.create_disallowed_host(~i"10.123.123.20")

    Attempting to add a host already on the list.

      iex> import MscmpSystNetwork, only: [sigil_i: 2]
      iex> true = MscmpSystAuthn.host_disallowed?(~i"10.123.123.3")
      iex> {:ok, :already_disallowed} =
      ...>   MscmpSystAuthn.create_disallowed_host(~i"10.123.123.3")
  """
  @spec create_disallowed_host(Types.host_address()) ::
          {:ok, :already_disallowed}
          | {:ok, {:disallowed, Msdata.SystDisallowedHosts.t()}}
          | {:error, Mserror.AuthnError.t()}
  def create_disallowed_host(host_addr) when is_ip(host_addr) do
    case Impl.NetworkRules.create_disallowed_host(host_addr) do
      {:ok, result} ->
        {:ok, result}

      {:error, error} ->
        {:error,
         Mserror.AuthnError.new(:network_rule_data, "Error creating Disallowed Host",
           cause: error,
           context: %ErrorContext{
             origin: {__MODULE__, :create_disallowed_host, 1},
             parameters: %{host_addr: host_addr}
           }
         )}
    end
  end

  ##############################################################################
  #
  # get_disallowed_host_record_by_host
  #
  #

  @doc section: :network_rule_data
  @doc """
  Retrieves a Disallowed Host record from the database as identified by its host
  address.

  ## Parameters

    * `host_address` - the IP address of the disallowed host record to retrieve.

  ## Examples

    Retrieving a Disallowed Host record by IP address.

      iex> import MscmpSystNetwork, only: [sigil_i: 2]
      iex> {:ok, {:disallowed, %Msdata.SystDisallowedHosts{}}} =
      ...>   MscmpSystAuthn.get_disallowed_host_record_by_host(~i"10.123.123.4")

    Attempting to retrieve a record for a host not on the list.

      iex> import MscmpSystNetwork, only: [sigil_i: 2]
      iex> MscmpSystAuthn.get_disallowed_host_record_by_host(~i"10.125.120.20")
      {:ok, :allowed}
  """
  @spec get_disallowed_host_record_by_host(Types.host_address()) ::
          {:ok, :allowed}
          | {:ok, {:disallowed, Msdata.SystDisallowedHosts.t()}}
          | {:error, Mserror.AuthnError.t()}
  def get_disallowed_host_record_by_host(host_addr) when is_ip(host_addr) do
    case Impl.NetworkRules.get_disallowed_host_record_by_host(host_addr) do
      {:ok, result} ->
        {:ok, result}

      {:error, error} ->
        {:error,
         Mserror.AuthnError.new(:network_rule_data, "Error retrieving Disallowed Host",
           cause: error,
           context: %ErrorContext{
             origin: {__MODULE__, :get_disallowed_host_record_by_host, 1},
             parameters: %{host_addr: host_addr}
           }
         )}
    end
  end

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
      iex> {:disallowed, %Msdata.SystDisallowedHosts{}} =
      ...>   MscmpSystAuthn.get_disallowed_host_record_by_host!(~i"10.123.123.4")

    Attempting to retrieve a record for a host not on the list.

      iex> import MscmpSystNetwork, only: [sigil_i: 2]
      iex> MscmpSystAuthn.get_disallowed_host_record_by_host!(~i"10.125.120.20")
      :allowed
  """
  @spec get_disallowed_host_record_by_host!(Types.host_address()) ::
          :allowed | {:disallowed, Msdata.SystDisallowedHosts.t()}
  def get_disallowed_host_record_by_host!(host_addr) do
    case get_disallowed_host_record_by_host(host_addr) do
      {:ok, result} -> result
      {:error, error} -> raise error
    end
  end

  ##############################################################################
  #
  # delete_disallowed_host_addr
  #
  #

  @doc section: :network_rule_data
  @doc """
  Deletes a host IP address from the Disallowed Hosts list as looked up by the
  host IP address.

  If the record is found and deleted a success tuple in the form `:ok` is
  returned.  Any other condition would cause an error tuple to be returned.

  Once a host is removed from the Disallowed Hosts list, users are allowed to
  authenticate from the host, so long as no other effective Network Rule
  prevents the action.

  ## Parameters

    * `host_addr` - the IP address of the host that is no longer to be
    disallowed.

  ## Examples

    Deleting a host that does exist in the list.

      iex> import MscmpSystNetwork, only: [sigil_i: 2]
      iex> true = MscmpSystAuthn.host_disallowed?(~i"10.10.251.1")
      iex> :ok = MscmpSystAuthn.delete_disallowed_host_addr(~i"10.10.251.1")
      iex> false = MscmpSystAuthn.host_disallowed?(~i"10.10.251.1")

    Attempting to delete a host not already on the list.

      iex> import MscmpSystNetwork, only: [sigil_i: 2]
      iex> false = MscmpSystAuthn.host_disallowed?(~i"10.10.251.10")
      iex> {:error, %Mserror.AuthnError{cause: :not_found}} =
      ...>   MscmpSystAuthn.delete_disallowed_host_addr(~i"10.10.251.10")
  """
  @spec delete_disallowed_host_addr(Types.host_address()) ::
          :ok | {:error, Mserror.AuthnError.t()}
  def delete_disallowed_host_addr(host_addr) when is_ip(host_addr) do
    case Impl.NetworkRules.delete_disallowed_host_addr(host_addr) do
      :ok ->
        :ok

      {:error, error} ->
        {:error,
         Mserror.AuthnError.new(:network_rule_data, "Error deleting Disallowed Host",
           cause: error,
           context: %ErrorContext{
             origin: {__MODULE__, :delete_disallowed_host_addr, 1},
             parameters: %{host_addr: host_addr}
           }
         )}
    end
  end

  ##############################################################################
  #
  # get_disallowed_host_record_by_id
  #
  #

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
          {:ok, Msdata.SystDisallowedHosts.t()} | {:error, Mserror.AuthnError.t()}
  def get_disallowed_host_record_by_id(disallowed_host_id) when is_uuid(disallowed_host_id) do
    case Impl.NetworkRules.get_disallowed_host_record_by_id(disallowed_host_id) do
      {:ok, record} ->
        {:ok, record}

      {:error, error} ->
        {:error,
         Mserror.AuthnError.new(:network_rule_data, "Error retrieving Disallowed Host",
           cause: error,
           context: %ErrorContext{
             origin: {__MODULE__, :get_disallowed_host_record_by_id, 1},
             parameters: %{disallowed_host_id: disallowed_host_id}
           }
         )}
    end
  end

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
  def get_disallowed_host_record_by_id!(disallowed_host_id)
      when is_uuid(disallowed_host_id) do
    case get_disallowed_host_record_by_id(disallowed_host_id) do
      {:ok, record} -> record
      {:error, error} -> raise error
    end
  end

  ##############################################################################
  #
  # delete_disallowed_host
  #
  #

  @doc section: :network_rule_data
  @doc """
  Deletes a host IP address from the Disallowed Hosts list based on either a
  `Msdata.SystDisallowedHosts` record or the ID of such a
  record.

  If the record is found and deleted a success tuple in the form `:ok` is
  returned.  An error tuple is returned in any other circumstance.

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
      iex> {:ok, {:disallowed, target_host_record}} =
      ...>   MscmpSystAuthn.get_disallowed_host_record_by_host(~i"10.10.250.4")
      iex> MscmpSystAuthn.delete_disallowed_host(target_host_record.id)
      :ok

    Deleting a host by record struct.

      iex> import MscmpSystNetwork, only: [sigil_i: 2]
      iex> {:ok, {:disallowed, target_host_record}} =
      ...>   MscmpSystAuthn.get_disallowed_host_record_by_host(~i"10.10.250.5")
      iex> MscmpSystAuthn.delete_disallowed_host(target_host_record)
      :ok

    Deleting a struct for a no longer existent record.

      iex> import MscmpSystNetwork, only: [sigil_i: 2]
      iex> {:ok, {:disallowed, target_host_record}} =
      ...>   MscmpSystAuthn.get_disallowed_host_record_by_host(~i"10.10.250.6")
      iex> MscmpSystAuthn.delete_disallowed_host(target_host_record)
      :ok
      iex> {:error, %Mserror.AuthnError{cause: :not_found}} =
      ...>   MscmpSystAuthn.delete_disallowed_host(target_host_record)

  """
  @spec delete_disallowed_host(Types.disallowed_host_id() | Msdata.SystDisallowedHosts.t()) ::
          :ok | {:error, Mserror.AuthnError.t()}
  def delete_disallowed_host(disallowed_host)
      when is_uuid(disallowed_host) or is_struct(disallowed_host, Msdata.SystDisallowedHosts) do
    case Impl.NetworkRules.delete_disallowed_host(disallowed_host) do
      :ok ->
        :ok

      {:error, error} ->
        {:error,
         Mserror.AuthnError.new(:network_rule_data, "Error deleting Disallowed Host",
           cause: error,
           context: %ErrorContext{
             origin: {__MODULE__, :delete_disallowed_host, 1},
             parameters: %{disallowed_host: disallowed_host}
           }
         )}
    end
  end

  ##############################################################################
  #
  # get_applied_network_rule
  #
  #

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
  @spec get_applied_network_rule(Types.host_address()) ::
          {:ok, Types.AppliedNetworkRule.t()} | {:error, Mserror.AuthnError.t()}
  @spec get_applied_network_rule(
          Types.host_address(),
          MscmpSystInstance.Types.instance_id() | nil
        ) :: {:ok, Types.AppliedNetworkRule.t()} | {:error, Mserror.AuthnError.t()}
  @spec get_applied_network_rule(
          Types.host_address(),
          MscmpSystInstance.Types.instance_id() | nil,
          MscmpSystInstance.Types.owner_id() | nil
        ) :: {:ok, Types.AppliedNetworkRule.t()} | {:error, Mserror.AuthnError.t()}
  def get_applied_network_rule(host_addr, instance_id \\ nil, instance_owner_id \\ nil)
      when is_ip(host_addr) and (is_uuid(instance_id) or is_nil(instance_id)) and
             (is_uuid(instance_owner_id) or is_nil(instance_owner_id)) do
    case Impl.NetworkRules.get_applied_network_rule(host_addr, instance_id, instance_owner_id) do
      {:ok, record} ->
        {:ok, record}

      {:error, error} ->
        {:error,
         Mserror.AuthnError.new(:network_rule_data, "Error getting Applied Network Rule",
           cause: error,
           context: %ErrorContext{
             origin: {__MODULE__, :get_applied_network_rule, 3},
             parameters: %{
               host_addr: host_addr,
               instance_id: instance_id,
               instance_owner_id: instance_owner_id
             }
           }
         )}
    end
  end

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
  @spec get_applied_network_rule!(Types.host_address()) :: Types.AppliedNetworkRule.t()
  @spec get_applied_network_rule!(
          Types.host_address(),
          MscmpSystInstance.Types.instance_id() | nil
        ) :: Types.AppliedNetworkRule.t()
  @spec get_applied_network_rule!(
          Types.host_address(),
          MscmpSystInstance.Types.instance_id() | nil,
          MscmpSystInstance.Types.owner_id() | nil
        ) :: Types.AppliedNetworkRule.t()
  def get_applied_network_rule!(host_addr, instance_id \\ nil, instance_owner_id \\ nil) do
    case get_applied_network_rule(host_addr, instance_id, instance_owner_id) do
      {:ok, record} -> record
      {:error, error} -> raise error
    end
  end

  ##############################################################################
  #
  # create_global_network_rule
  #
  #

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
          {:ok, Msdata.SystGlobalNetworkRules.t()} | {:error, Mserror.AuthnError.t()}
  def create_global_network_rule(insert_params) when is_map(insert_params) do
    case Impl.NetworkRules.create_global_network_rule(insert_params) do
      {:ok, record} ->
        {:ok, record}

      {:error, error} ->
        {:error,
         Mserror.AuthnError.new(:network_rule_data, "Error creating Global Network Rule",
           cause: error,
           context: %ErrorContext{
             origin: {__MODULE__, :create_global_network_rule, 1},
             parameters: %{insert_params: insert_params}
           }
         )}
    end
  end

  ##############################################################################
  #
  # create_owner_network_rule
  #
  #

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
        ) :: {:ok, Msdata.SystOwnerNetworkRules.t()} | {:error, Mserror.AuthnError.t()}
  def create_owner_network_rule(owner_id, insert_params)
      when is_uuid(owner_id) and is_map(insert_params) do
    case Impl.NetworkRules.create_owner_network_rule(owner_id, insert_params) do
      {:ok, record} ->
        {:ok, record}

      {:error, error} ->
        {:error,
         Mserror.AuthnError.new(:network_rule_data, "Error creating Owner Network Rule",
           cause: error,
           context: %ErrorContext{
             origin: {__MODULE__, :create_owner_network_rule, 2},
             parameters: %{owner_id: owner_id, insert_params: insert_params}
           }
         )}
    end
  end

  ##############################################################################
  #
  # create_instance_network_rule
  #
  #

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
        ) :: {:ok, Msdata.SystInstanceNetworkRules.t()} | {:error, Mserror.AuthnError.t()}
  def create_instance_network_rule(instance_id, insert_params)
      when is_uuid(instance_id) and is_map(insert_params) do
    case Impl.NetworkRules.create_instance_network_rule(instance_id, insert_params) do
      {:ok, record} ->
        {:ok, record}

      {:error, error} ->
        {:error,
         Mserror.AuthnError.new(:network_rule_data, "Error creating Instance Network Rule",
           cause: error,
           context: %ErrorContext{
             origin: {__MODULE__, :create_instance_network_rule, 2},
             parameters: %{instance_id: instance_id, insert_params: insert_params}
           }
         )}
    end
  end

  ##############################################################################
  #
  # update_global_network_rule
  #
  #

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
        ) :: {:ok, Msdata.SystGlobalNetworkRules.t()} | {:error, Mserror.AuthnError.t()}
  def update_global_network_rule(global_network_rule, update_params)
      when (is_uuid(global_network_rule) or
              is_struct(global_network_rule, Msdata.SystGlobalNetworkRules)) and
             is_map(update_params) do
    case Impl.NetworkRules.update_global_network_rule(global_network_rule, update_params) do
      {:ok, record} ->
        {:ok, record}

      {:error, error} ->
        {:error,
         Mserror.AuthnError.new(:network_rule_data, "Error updating Global Network Rule",
           cause: error,
           context: %ErrorContext{
             origin: {__MODULE__, :update_global_network_rule, 2},
             parameters: %{global_network_rule: global_network_rule, update_params: update_params}
           }
         )}
    end
  end

  ##############################################################################
  #
  # update_owner_network_rule
  #
  #

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
        ) :: {:ok, Msdata.SystOwnerNetworkRules.t()} | {:error, Mserror.AuthnError.t()}
  def update_owner_network_rule(owner_network_rule, update_params)
      when (is_uuid(owner_network_rule) or
              is_struct(owner_network_rule, Msdata.SystOwnerNetworkRules)) and
             is_map(update_params) do
    case Impl.NetworkRules.update_owner_network_rule(owner_network_rule, update_params) do
      {:ok, record} ->
        {:ok, record}

      {:error, error} ->
        {:error,
         Mserror.AuthnError.new(:network_rule_data, "Error updating Owner Network Rule",
           cause: error,
           context: %ErrorContext{
             origin: {__MODULE__, :update_owner_network_rule, 2},
             parameters: %{owner_network_rule: owner_network_rule, update_params: update_params}
           }
         )}
    end
  end

  ##############################################################################
  #
  # update_instance_network_rule
  #
  #

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
        ) :: {:ok, Msdata.SystInstanceNetworkRules.t()} | {:error, Mserror.AuthnError.t()}
  def update_instance_network_rule(instance_network_rule, update_params)
      when (is_uuid(instance_network_rule) or
              is_struct(instance_network_rule, Msdata.SystInstanceNetworkRules)) and
             is_map(update_params) do
    case Impl.NetworkRules.update_instance_network_rule(instance_network_rule, update_params) do
      {:ok, record} ->
        {:ok, record}

      {:error, error} ->
        {:error,
         Mserror.AuthnError.new(:network_rule_data, "Error updating Instance Network Rule",
           cause: error,
           context: %ErrorContext{
             origin: {__MODULE__, :update_instance_network_rule, 2},
             parameters: %{
               instance_network_rule: instance_network_rule,
               update_params: update_params
             }
           }
         )}
    end
  end

  ##############################################################################
  #
  # get_global_network_rule
  #
  #

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
          {:ok, Msdata.SystGlobalNetworkRules.t()} | {:error, Mserror.AuthnError.t()}
  def get_global_network_rule(global_network_rule_id) when is_uuid(global_network_rule_id) do
    case Impl.NetworkRules.get_global_network_rule(global_network_rule_id) do
      {:ok, record} ->
        {:ok, record}

      {:error, error} ->
        {:error,
         Mserror.AuthnError.new(:network_rule_data, "Error retrieving Global Network Rule",
           cause: error,
           context: %ErrorContext{
             origin: {__MODULE__, :get_global_network_rule, 1},
             parameters: %{global_network_rule_id: global_network_rule_id}
           }
         )}
    end
  end

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
  @spec get_global_network_rule!(Ecto.UUID.t()) :: Msdata.SystGlobalNetworkRules.t()
  def get_global_network_rule!(global_network_rule_id) do
    case get_global_network_rule(global_network_rule_id) do
      {:ok, record} -> record
      {:error, error} -> raise error
    end
  end

  ##############################################################################
  #
  # get_owner_network_rule
  #
  #

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
          {:ok, Msdata.SystOwnerNetworkRules.t()} | {:error, Mserror.AuthnError.t()}
  def get_owner_network_rule(owner_network_rule_id) when is_uuid(owner_network_rule_id) do
    case Impl.NetworkRules.get_owner_network_rule(owner_network_rule_id) do
      {:ok, record} ->
        {:ok, record}

      {:error, error} ->
        {:error,
         Mserror.AuthnError.new(:network_rule_data, "Error retrieving Owner Network Rule",
           cause: error,
           context: %ErrorContext{
             origin: {__MODULE__, :get_owner_network_rule, 1},
             parameters: %{owner_network_rule_id: owner_network_rule_id}
           }
         )}
    end
  end

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
  @spec get_owner_network_rule!(Ecto.UUID.t()) :: Msdata.SystOwnerNetworkRules.t()
  def get_owner_network_rule!(owner_network_rule_id) do
    case get_owner_network_rule(owner_network_rule_id) do
      {:ok, record} -> record
      {:error, error} -> raise error
    end
  end

  ##############################################################################
  #
  # get_instance_network_rule
  #
  #

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
          {:ok, Msdata.SystInstanceNetworkRules.t()} | {:error, Mserror.AuthnError.t()}
  def get_instance_network_rule(instance_network_rule_id)
      when is_uuid(instance_network_rule_id) do
    case Impl.NetworkRules.get_instance_network_rule(instance_network_rule_id) do
      {:ok, record} ->
        {:ok, record}

      {:error, error} ->
        {:error,
         Mserror.AuthnError.new(:network_rule_data, "Error retrieving Instance Network Rule",
           cause: error,
           context: %ErrorContext{
             origin: {__MODULE__, :get_instance_network_rule, 1},
             parameters: %{instance_network_rule_id: instance_network_rule_id}
           }
         )}
    end
  end

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
  @spec get_instance_network_rule!(Ecto.UUID.t()) :: Msdata.SystInstanceNetworkRules.t()
  def get_instance_network_rule!(instance_network_rule_id) do
    case get_instance_network_rule(instance_network_rule_id) do
      {:ok, record} -> record
      {:error, error} -> raise error
    end
  end

  ##############################################################################
  #
  # delete_global_network_rule
  #
  #

  @doc section: :network_rule_data
  @doc """
  Deletes an existing Global Network Rule record as referenced by the record ID.

  On successful deletion, a simple result of `:ok` is returned.  On error, an
  error tuple in the form of `{:error, <exception>}` is returned.

  ## Parameters

    * `global_network_rule_id` - The record ID of the Global Network Rule record
    to delete.
  """
  @spec delete_global_network_rule(Ecto.UUID.t()) :: :ok | {:error, Mserror.AuthnError.t()}
  def delete_global_network_rule(global_network_rule_id) when is_uuid(global_network_rule_id) do
    case Impl.NetworkRules.delete_global_network_rule(global_network_rule_id) do
      :ok ->
        :ok

      {:error, error} ->
        {:error,
         Mserror.AuthnError.new(:network_rule_data, "Error deleting Global Network Rule",
           cause: error,
           context: %ErrorContext{
             origin: {__MODULE__, :delete_global_network_rule, 1},
             parameters: %{global_network_rule_id: global_network_rule_id}
           }
         )}
    end
  end

  ##############################################################################
  #
  # delete_owner_network_rule
  #
  #

  @doc section: :network_rule_data
  @doc """
  Deletes an existing Owner Network Rule record as referenced by the record ID.

  On successful deletion, a simple result of `:ok` is returned.  On error, an
  error tuple in the form of `{:error, <exception>}` is returned.

  ## Parameters

    * `owner_network_rule_id` - The record ID of the Owner Network Rule record
    to delete.
  """
  @spec delete_owner_network_rule(Ecto.UUID.t()) :: :ok | {:error, Mserror.AuthnError.t()}
  def delete_owner_network_rule(owner_network_rule_id) when is_uuid(owner_network_rule_id) do
    case Impl.NetworkRules.delete_owner_network_rule(owner_network_rule_id) do
      :ok ->
        :ok

      {:error, error} ->
        {:error,
         Mserror.AuthnError.new(:network_rule_data, "Error deleting Owner Network Rule",
           cause: error,
           context: %ErrorContext{
             origin: {__MODULE__, :delete_owner_network_rule, 1},
             parameters: %{owner_network_rule_id: owner_network_rule_id}
           }
         )}
    end
  end

  ##############################################################################
  #
  # delete_instance_network_rule
  #
  #

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
  @spec delete_instance_network_rule(Ecto.UUID.t()) :: :ok | {:error, Mserror.AuthnError.t()}
  def delete_instance_network_rule(instance_network_rule_id)
      when is_uuid(instance_network_rule_id) do
    case Impl.NetworkRules.delete_instance_network_rule(instance_network_rule_id) do
      :ok ->
        :ok

      {:error, error} ->
        {:error,
         Mserror.AuthnError.new(:network_rule_data, "Error deleting Instance Network Rule",
           cause: error,
           context: %ErrorContext{
             origin: {__MODULE__, :delete_instance_network_rule, 1},
             parameters: %{instance_network_rule_id: instance_network_rule_id}
           }
         )}
    end
  end

  # ==============================================================================================
  # ==============================================================================================
  #
  # Account Code Identity Management
  #
  # ==============================================================================================
  # ==============================================================================================

  ##############################################################################
  #
  # create_or_reset_account_code
  #
  #

  @create_or_reset_account_code_opts NimbleOptions.new!(
                                       Keyword.take(option_defs, [
                                         :account_code,
                                         :identity_token_length,
                                         :identity_tokens,
                                         :create_validated
                                       ])
                                       |> put_in([:identity_tokens, :default], :b32c)
                                       |> put_in([:create_validated, :default], true)
                                       |> put_in([:identity_token_length, :default], 12)
                                     )

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
    behavior of the function call.

  ## Options

    #{NimbleOptions.docs(@create_or_reset_account_code_opts)}
  """

  # TODO: Dialyzer cannot match the success tuple even through in tests it
  #       works.  There is almost certainly something wrong in our code that
  #       is causing the problem and should be resolved.

  @dialyzer {:no_match, create_or_reset_account_code: 2}
  @spec create_or_reset_account_code(Types.access_account_id()) ::
          {:ok, Types.AuthenticatorResult.t()} | {:error, Mserror.AuthnError.t()}
  @spec create_or_reset_account_code(Types.access_account_id(), Keyword.t()) ::
          {:ok, Types.AuthenticatorResult.t()} | {:error, Mserror.AuthnError.t()}
  def create_or_reset_account_code(access_account_id, opts \\ [])
      when is_uuid(access_account_id) and is_list(opts) do
    validated_opts = NimbleOptions.validate!(opts, @create_or_reset_account_code_opts)

    case Impl.ExtendedMgmtLogic.create_or_reset_account_code(access_account_id, validated_opts) do
      {:ok, result} ->
        {:ok, result}

      {:error, error} ->
        {:error,
         Mserror.AuthnError.new(
           :account_code,
           "Error creating or resetting Account Code Identity",
           cause: error,
           context: %ErrorContext{
             origin: {__MODULE__, :create_or_reset_account_code, 2},
             parameters: %{access_account_id: access_account_id, opts: validated_opts}
           }
         )}
    end
  end

  ##############################################################################
  #
  # identify_access_account_by_code
  #
  #

  @doc section: :account_code
  @doc """
  Identifies an Access Account by its Account Code identifier.

  The Account Code can represent an Access Account which is either Unowned or
  Owned by an Owner.  The `owner_id` parameter is used to differentiate between
  these two cases.

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
        ) :: {:ok, Msdata.SystIdentities.t()} | {:error, Mserror.AuthnError.t()}
  def identify_access_account_by_code(account_code, owner_id)
      when is_binary(account_code) and (is_uuid(owner_id) or is_nil(owner_id)) do
    case Impl.ExtendedAuthLogic.identify_access_account_by_code(account_code, owner_id) do
      {:ok, identity} ->
        {:ok, identity}

      {:error, error} ->
        {:error,
         Mserror.AuthnError.new(
           :account_code,
           "Error identifying Access Account by Account Code",
           cause: error,
           context: %ErrorContext{
             origin: {__MODULE__, :identify_access_account_by_code, 2},
             parameters: %{account_code: account_code, owner_id: owner_id}
           }
         )}
    end
  end

  ##############################################################################
  #
  # get_account_code_by_access_account_id
  #
  #

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
          {:ok, Msdata.SystIdentities.t()} | {:error, Mserror.AuthnError.t()}
  def get_account_code_by_access_account_id(access_account_id) when is_uuid(access_account_id) do
    case Impl.Identity.AccountCode.get_account_code_by_access_account_id(access_account_id) do
      {:ok, identity} ->
        {:ok, identity}

      {:error, error} ->
        {:error,
         Mserror.AuthnError.new(
           :account_code,
           "Error retrieving Account Code Identity",
           cause: error,
           context: %ErrorContext{
             origin: {__MODULE__, :get_account_code_by_access_account_id, 1},
             parameters: %{access_account_id: access_account_id}
           }
         )}
    end
  end

  ##############################################################################
  #
  # revoke_account_code
  #
  #

  @doc section: :account_code
  @doc """
  Revokes a previously create Account Code Identity from an Access Account,
  deleting it from the system.

  ## Parameters

    * `access_account_id` - the Access Account record ID from which to revoke
    the Account Code Identity.
  """
  @spec revoke_account_code(Types.access_account_id()) ::
          :ok | {:error, Mserror.AuthnError.t()}
  def revoke_account_code(access_account_id) when is_uuid(access_account_id) do
    case Impl.ExtendedMgmtLogic.revoke_account_code(access_account_id) do
      :ok ->
        :ok

      {:error, error} ->
        {:error,
         Mserror.AuthnError.new(
           :account_code,
           "Error revoking Account Code Identity",
           cause: error,
           context: %ErrorContext{
             origin: {__MODULE__, :revoke_account_code, 1},
             parameters: %{access_account_id: access_account_id}
           }
         )}
    end
  end

  # ==============================================================================================
  # ==============================================================================================
  #
  # Extended Logic / Authenticator Management
  #
  # ==============================================================================================
  # ==============================================================================================

  ##############################################################################
  #
  # create_authenticator_email_password
  #
  #

  @create_authenticator_email_password_opts NimbleOptions.new!(
                                              Keyword.take(option_defs, [
                                                :create_validated,
                                                :credential_token,
                                                :credential_token_length,
                                                :credential_tokens,
                                                :identity_token,
                                                :identity_token_length,
                                                :identity_tokens,
                                                :expiration_hours
                                              ])
                                            )

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

    * `opts` - a keyword list of options to control the creation process.

  ## Options

    #{NimbleOptions.docs(@create_authenticator_email_password_opts)}

  """
  @spec create_authenticator_email_password(
          Types.access_account_id(),
          Types.account_identifier(),
          Types.credential()
        ) :: {:ok, Types.AuthenticatorResult.t()} | {:error, Mserror.AuthnError.t()}
  @spec create_authenticator_email_password(
          Types.access_account_id(),
          Types.account_identifier(),
          Types.credential(),
          Keyword.t()
        ) :: {:ok, Types.AuthenticatorResult.t()} | {:error, Mserror.AuthnError.t()}
  def create_authenticator_email_password(
        access_account_id,
        email_addr,
        plaintext_pwd,
        opts \\ []
      )
      when is_uuid(access_account_id) and is_binary(email_addr) and is_binary(plaintext_pwd) and
             is_list(opts) do
    validated_opts = NimbleOptions.validate!(opts, @create_authenticator_email_password_opts)

    case Impl.ExtendedMgmtLogic.create_authenticator_email_password(
           access_account_id,
           email_addr,
           plaintext_pwd,
           validated_opts
         ) do
      {:ok, result} ->
        {:ok, result}

      {:error, error} ->
        {:error,
         Mserror.AuthnError.new(
           :authenticator_management,
           "Error creating Email/Password Authenticator",
           cause: error,
           context: %ErrorContext{
             origin: {__MODULE__, :create_authenticator_email_password, 4},
             parameters: %{
               access_account_id: access_account_id,
               email_addr: email_addr,
               plaintext_pwd: "(Redacted)",
               opts: validated_opts
             }
           }
         )}
    end
  end

  ##############################################################################
  #
  # reset_password_credential
  #
  #

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
  it, the function will return an error tuple with a cause of type
  `{:invalid_credential, t:MscmpSystAuthn.Types.credential_set_failures/0}`.  All
  other return conditions are errors and result in an error tuple.

  ## Parameters

    * `access_account_id` - the Access Account for whom the Password is being
    changed.

    * `new_credential` - the new Password which will become the credential on
    the successful completion of the function.
  """
  @spec reset_password_credential(Types.access_account_id(), Types.credential()) ::
          :ok | {:error, Mserror.AuthnError.t()}
  def reset_password_credential(access_account_id, new_credential)
      when is_uuid(access_account_id) and is_binary(new_credential) do
    case Impl.ExtendedMgmtLogic.reset_password_credential(access_account_id, new_credential) do
      {:ok, _credential} ->
        :ok

      {:error, error} ->
        {:error,
         Mserror.AuthnError.new(:authenticator_management, "Error resetting password credential",
           cause: error,
           context: %ErrorContext{
             origin: {__MODULE__, :reset_password_credential, 2},
             parameters: %{access_account_id: access_account_id, new_credential: "(Redacted)"}
           }
         )}
    end
  end

  ##############################################################################
  #
  # request_identity_validation
  #
  #

  @request_identity_validation NimbleOptions.new!(
                                 Keyword.take(option_defs, [
                                   :expiration_hours,
                                   :identity_token_length,
                                   :identity_tokens,
                                   :credential_token_length,
                                   :credential_tokens,
                                   :credential_token,
                                   :create_validated
                                 ])
                                 |> put_in([:create_validated, :default], true)
                               )

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

  ## Options

    #{NimbleOptions.docs(@request_identity_validation)}
  """

  # TODO: Dialyzer cannot match the success tuple even through in tests it
  #       works.  There is almost certainly something wrong in our code that
  #       is causing the problem and should be resolved.

  @dialyzer {:no_match, request_identity_validation: 2}
  @spec request_identity_validation(Types.identity_id() | Msdata.SystIdentities.t()) ::
          {:ok, Types.AuthenticatorResult.t()} | {:error, Mserror.AuthnError.t()}
  @spec request_identity_validation(Types.identity_id() | Msdata.SystIdentities.t(), Keyword.t()) ::
          {:ok, Types.AuthenticatorResult.t()} | {:error, Mserror.AuthnError.t()}
  def request_identity_validation(target_identity, opts \\ [])
      when (is_struct(target_identity, Msdata.SystIdentities) or is_uuid(target_identity)) and
             is_list(opts) do
    validated_opts = NimbleOptions.validate!(opts, @request_identity_validation)

    case Impl.ExtendedMgmtLogic.request_identity_validation(target_identity, validated_opts) do
      {:ok, result} ->
        {:ok, result}

      {:error, error} ->
        {:error,
         Mserror.AuthnError.new(:authenticator_management, "Error requesting identity validation",
           cause: error,
           context: %ErrorContext{
             origin: {__MODULE__, :request_identity_validation, 2},
             parameters: %{target_identity: target_identity, opts: validated_opts}
           }
         )}
    end
  end

  ##############################################################################
  #
  # revoke_validator_for_identity_id
  #
  #

  @doc section: :authenticator_management
  @doc """
  Revokes a Validation Authenticator ("Validator") issued for the requested
  Identity.

  While Validators will expire on their own if not confirmed first, there are
  cases where Validators should be revoked prior to that time, such as if the
  Validator communication to the user has been lost and a new Validator needs to
  be generated.

  If the Validator is successfully revoked, `:ok` is returned.  In any other
  circumstance an error tuple is returned.

  ## Parameters

    * `target_identity_id` - the record ID of the Identity record which the
    Validator was meant to validate.  So if the Validator to revoke was for an
    Email Identity, this value would be the ID of the Email Identity and not the
    Validation Identity.
  """
  @spec revoke_validator_for_identity_id(Types.identity_id()) ::
          :ok | {:error, Mserror.AuthnError.t()}
  def revoke_validator_for_identity_id(target_identity_id) when is_uuid(target_identity_id) do
    case Impl.ExtendedMgmtLogic.revoke_validator_for_identity_id(target_identity_id) do
      :ok ->
        :ok

      {:error, error} ->
        {:error,
         Mserror.AuthnError.new(
           :authenticator_management,
           "Error revoking validator for identity",
           cause: error,
           context: %ErrorContext{
             origin: {__MODULE__, :revoke_validator_for_identity_id, 1},
             parameters: %{target_identity_id: target_identity_id}
           }
         )}
    end
  end

  ##############################################################################
  #
  # access_account_credential_recoverable
  #
  #

  @doc section: :authenticator_management
  @doc """
  Indicates if an Access Account's Password Credential is recoverable or not.

  Access Account Password Credentials are only recoverable when they: 1) exist,
  and 2) are not already awaiting recovery. The function returns a result tuple
  with one of three possible values:

  - `{:ok, :recoverable}` - The Password Credential exists and can be recovered
  - `{:ok, :existing_recovery}` - A recovery process is already underway
  - `{:error, error}` - An error occurred while checking recoverability

  ## Parameters

    * `access_account_id` - the record ID of the Access Account which owns the
    Password Credential to test for recoverability.
  """
  @spec access_account_credential_recoverable(Types.access_account_id()) ::
          {:ok, :recoverable} | {:ok, :existing_recovery} | {:error, Mserror.AuthnError.t()}
  def access_account_credential_recoverable(access_account_id)
      when is_uuid(access_account_id) do
    case Impl.Identity.Recovery.access_account_credential_recoverable(access_account_id) do
      {:ok, result} ->
        {:ok, result}

      {:error, error} ->
        {:error,
         Mserror.AuthnError.new(
           :authenticator_management,
           "Error determining if Access Account Password Credential is recoverable",
           cause: error,
           context: %ErrorContext{
             origin: {__MODULE__, :access_account_credential_recoverable, 1},
             parameters: %{access_account_id: access_account_id}
           }
         )}
    end
  end

  ##############################################################################
  #
  # request_password_recovery
  #
  #

  @request_password_recovery NimbleOptions.new!(
                               Keyword.take(option_defs, [
                                 :expiration_hours,
                                 :identity_token_length,
                                 :identity_tokens,
                                 :credential_token_length,
                                 :credential_tokens,
                                 :credential_token,
                                 :create_validated
                               ])
                               |> put_in([:create_validated, :default], true)
                             )

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
    password recovery request.

  ## Options

    #{NimbleOptions.docs(@request_password_recovery)}
  """
  @spec request_password_recovery(Types.access_account_id()) ::
          {:ok, Types.AuthenticatorResult.t()} | {:error, Mserror.AuthnError.t()}
  @spec request_password_recovery(Types.access_account_id(), Keyword.t()) ::
          {:ok, Types.AuthenticatorResult.t()} | {:error, Mserror.AuthnError.t()}
  def request_password_recovery(access_account_id, opts \\ [])
      when is_uuid(access_account_id) and is_list(opts) do
    validated_opts = NimbleOptions.validate!(opts, @request_password_recovery)

    case Impl.ExtendedMgmtLogic.request_password_recovery(access_account_id, validated_opts) do
      {:ok, result} ->
        {:ok, result}

      {:error, error} ->
        {:error,
         Mserror.AuthnError.new(:authenticator_management, "Error requesting password recovery",
           cause: error,
           context: %ErrorContext{
             origin: {__MODULE__, :request_password_recovery, 2},
             parameters: %{access_account_id: access_account_id, opts: validated_opts}
           }
         )}
    end
  end

  ##############################################################################
  #
  # revoke_password_recovery
  #
  #

  @doc section: :authenticator_management
  @doc """
  Revokes the Recovery Token Authenticator for a previously initiated Password
  Credential recovery.

  While Recovery Token Authenticators expire of their own accord after a time,
  they may also explicitly be revoked.  In reality this means simply deleting
  the Recovery Token Authenticator from the system.

  If the Validator is successfully revoked, `:ok` is returned.  In any other
  circumstance an error tuple is returned.

  ## Parameters

    * `access_account_id` - identifies the Access Account for whom the Recovery
    Token Authenticator should be revoked.  The expected value is the record ID
    of the Access Account.
  """
  @spec revoke_password_recovery(Types.access_account_id()) ::
          :ok | {:error, Mserror.AuthnError.t()}
  def revoke_password_recovery(access_account_id) when is_uuid(access_account_id) do
    case Impl.ExtendedMgmtLogic.revoke_password_recovery(access_account_id) do
      :ok ->
        :ok

      {:error, error} ->
        {:error,
         Mserror.AuthnError.new(:authenticator_management, "Error revoking password recovery",
           cause: error,
           context: %ErrorContext{
             origin: {__MODULE__, :revoke_password_recovery, 1},
             parameters: %{access_account_id: access_account_id}
           }
         )}
    end
  end

  ##############################################################################
  #
  # create_authenticator_api_token
  #
  #

  @create_authenticator_api_token NimbleOptions.new!(
                                    Keyword.take(option_defs, [
                                      :identity_token_length,
                                      :identity_tokens,
                                      :identity_token,
                                      :external_name,
                                      :credential_token_length,
                                      :credential_tokens,
                                      :credential_token,
                                      :create_validated
                                    ])
                                    |> put_in([:identity_token_length, :default], 20)
                                    |> put_in([:create_validated, :default], true)
                                  )

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
    behavior of the Authenticator creation process.

  ## Options

    #{NimbleOptions.docs(@create_authenticator_api_token)}
  """
  @spec create_authenticator_api_token(Types.access_account_id()) ::
          {:ok, Types.AuthenticatorResult.t()} | {:error, Mserror.AuthnError.t()}
  @spec create_authenticator_api_token(Types.access_account_id(), Keyword.t()) ::
          {:ok, Types.AuthenticatorResult.t()} | {:error, Mserror.AuthnError.t()}
  def create_authenticator_api_token(access_account_id, opts \\ [])
      when is_uuid(access_account_id) and is_list(opts) do
    validated_opts = NimbleOptions.validate!(opts, @create_authenticator_api_token)

    case Impl.ExtendedMgmtLogic.create_authenticator_api_token(access_account_id, validated_opts) do
      {:ok, result} ->
        {:ok, result}

      {:error, error} ->
        {:error,
         Mserror.AuthnError.new(
           :authenticator_management,
           "Error creating API Token Authenticator",
           cause: error,
           context: %ErrorContext{
             origin: {__MODULE__, :create_authenticator_api_token, 2},
             parameters: %{access_account_id: access_account_id, opts: validated_opts}
           }
         )}
    end
  end

  ##############################################################################
  #
  # update_api_token_external_name
  #
  #

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
          {:ok, Msdata.SystIdentities.t()} | {:error, Mserror.AuthnError.t()}
  def update_api_token_external_name(identity, external_name)
      when (is_struct(identity, Msdata.SystIdentities) or is_uuid(identity)) and
             (is_binary(external_name) or is_nil(external_name)) do
    case Impl.ExtendedMgmtLogic.update_api_token_external_name(identity, external_name) do
      {:ok, result} ->
        {:ok, result}

      {:error, error} ->
        {:error,
         Mserror.AuthnError.new(
           :authenticator_management,
           "Error updating API Token external name",
           cause: error,
           context: %ErrorContext{
             origin: {__MODULE__, :update_api_token_external_name, 2},
             parameters: %{identity: identity, external_name: external_name}
           }
         )}
    end
  end

  ##############################################################################
  #
  # revoke_api_token
  #
  #

  @doc section: :authenticator_management
  @doc """
  Revokes the request API Token Authenticator by deleting it from the system.

  API Token Authenticators will regularly need to be decommissioned from the
  system by the Access Account holders they represent.  By revoking an API
  Token it is deleted from system.

  If the API Token Identity is successfully revoked, `:ok` is returned.  In any
  other circumstance an error tuple is returned.

  ## Parameters

    * `identity` - either the record ID of the API Token Identity to revoke or
    the current-state `Msdata.SystIdentities` struct of
    that record.
  """
  @spec revoke_api_token(Types.identity_id() | Msdata.SystIdentities.t()) ::
          :ok | {:error, Mserror.AuthnError.t()}
  def revoke_api_token(identity)
      when is_struct(identity, Msdata.SystIdentities) or is_uuid(identity) do
    case Impl.ExtendedMgmtLogic.revoke_api_token(identity) do
      :ok ->
        :ok

      {:error, error} ->
        {:error,
         Mserror.AuthnError.new(:authenticator_management, "Error revoking API Token",
           cause: error,
           context: %ErrorContext{
             origin: {__MODULE__, :revoke_api_token, 1},
             parameters: %{identity: identity}
           }
         )}
    end
  end

  # ==============================================================================================
  # ==============================================================================================
  #
  # Extended Logic / Authentication
  #
  # ==============================================================================================
  # ==============================================================================================

  ##############################################################################
  #
  # authenticate_email_password
  #
  #

  @authenticate_email_password_opts NimbleOptions.new!(
                                      Keyword.take(option_defs, [
                                        :owning_owner_id,
                                        :instance_id,
                                        :deadline_minutes,
                                        :identifier_rate_limit,
                                        :host_ban_rate_limit
                                      ])
                                    )

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

  Email/Password authentication is an interruptable process, meaning that this
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
    deferred basis (eventually required).

  ## Options

    #{NimbleOptions.docs(@authenticate_email_password_opts)}
  """
  @spec authenticate_email_password(
          Types.account_identifier(),
          Types.credential(),
          NetTypes.addr_structs()
        ) :: {:ok, Types.AuthenticationState.t()}
  @spec authenticate_email_password(
          Types.account_identifier(),
          Types.credential(),
          NetTypes.addr_structs(),
          Keyword.t()
        ) :: {:ok, Types.AuthenticationState.t()}
  def authenticate_email_password(email_address, plaintext_pwd, host_addr, opts \\ [])
      when is_binary(email_address) and is_binary(plaintext_pwd) and is_ip(host_addr) and
             is_list(opts) do
    validated_opts = NimbleOptions.validate!(opts, @authenticate_email_password_opts)

    Impl.ExtendedAuthLogic.authenticate_email_password(
      email_address,
      plaintext_pwd,
      host_addr,
      validated_opts
    )
  end

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
  @spec authenticate_email_password(Types.AuthenticationState.t()) ::
          {:ok, Types.AuthenticationState.t()}
  @spec authenticate_email_password(Types.AuthenticationState.t(), Keyword.t()) ::
          {:ok, Types.AuthenticationState.t()}
  def authenticate_email_password(%Types.AuthenticationState{} = authentication_state, opts \\ [])
      when is_list(opts) do
    validated_opts = NimbleOptions.validate!(opts, @authenticate_email_password_opts)

    Impl.ExtendedAuthLogic.authenticate_email_password(authentication_state, validated_opts)
  end

  ##############################################################################
  #
  # authenticate_validation_token
  #
  #

  @authenticate_validation_token_opts NimbleOptions.new!(
                                        Keyword.take(option_defs, [
                                          :owning_owner_id,
                                          :deadline_minutes,
                                          :identifier_rate_limit,
                                          :host_ban_rate_limit
                                        ])
                                      )

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

  The authentication process executed by this function is not interruptable.
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
    behaviors of this function or are optionally required.


  ## Options

    #{NimbleOptions.docs(@authenticate_validation_token_opts)}
  """
  @spec authenticate_validation_token(
          Types.account_identifier(),
          Types.credential(),
          NetTypes.addr_structs()
        ) :: {:ok, Types.AuthenticationState.t()}
  @spec authenticate_validation_token(
          Types.account_identifier(),
          Types.credential(),
          NetTypes.addr_structs(),
          Keyword.t()
        ) :: {:ok, Types.AuthenticationState.t()}
  def authenticate_validation_token(identifier, plaintext_token, host_addr, opts \\ [])
      when is_binary(identifier) and is_binary(plaintext_token) and is_ip(host_addr) and
             is_list(opts) do
    validated_opts = NimbleOptions.validate!(opts, @authenticate_validation_token_opts)

    Impl.ExtendedAuthLogic.authenticate_validation_token(
      identifier,
      plaintext_token,
      host_addr,
      validated_opts
    )
  end

  ##############################################################################
  #
  # authenticate_recovery_token
  #
  #

  @authenticate_recovery_token_opts NimbleOptions.new!(
                                      Keyword.take(option_defs, [
                                        :owning_owner_id,
                                        :deadline_minutes,
                                        :identifier_rate_limit,
                                        :host_ban_rate_limit
                                      ])
                                    )

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

  The authentication process executed by this function is not interruptable.
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
    behaviors of this function or are optionally required.

  ## Options

    #{NimbleOptions.docs(@authenticate_recovery_token_opts)}
  """
  @spec authenticate_recovery_token(
          Types.account_identifier(),
          Types.credential(),
          NetTypes.addr_structs()
        ) :: {:ok, Types.AuthenticationState.t()} | {:error, Mserror.AuthnError.t()}
  @spec authenticate_recovery_token(
          Types.account_identifier(),
          Types.credential(),
          NetTypes.addr_structs(),
          Keyword.t()
        ) :: {:ok, Types.AuthenticationState.t()} | {:error, Mserror.AuthnError.t()}
  def authenticate_recovery_token(identifier, plaintext_token, host_addr, opts \\ [])
      when is_binary(identifier) and is_binary(plaintext_token) and is_ip(host_addr) and
             is_list(opts) do
    validated_opts = NimbleOptions.validate!(opts, @authenticate_recovery_token_opts)

    Impl.ExtendedAuthLogic.authenticate_recovery_token(
      identifier,
      plaintext_token,
      host_addr,
      validated_opts
    )
    |> case do
      {:ok, result} ->
        {:ok, result}

      {:error, error} ->
        {:error,
         Mserror.AuthnError.new(:authentication, "Recovery Token Authentication failed",
           cause: error,
           context: %ErrorContext{
             origin: {__MODULE__, :authenticate_recovery_token, 4},
             parameters: %{
               identifier: identifier,
               plaintext_token: "(redacted)",
               host_addr: host_addr,
               opts: validated_opts
             }
           }
         )}
    end
  end

  ##############################################################################
  #
  # authenticate_api_token
  #
  #

  @authenticate_api_token_opts NimbleOptions.new!(
                                 Keyword.take(option_defs, [
                                   :owning_owner_id,
                                   :deadline_minutes,
                                   :identifier_rate_limit,
                                   :host_ban_rate_limit
                                 ])
                               )

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

  The authentication process executed by this function is not interruptable.
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
    behaviors of this function or are optionally required.

  ## Options

    #{NimbleOptions.docs(@authenticate_api_token_opts)}
  """
  @spec authenticate_api_token(
          Types.account_identifier(),
          Types.credential(),
          NetTypes.addr_structs(),
          MscmpSystInstance.Types.instance_id()
        ) :: {:ok, Types.AuthenticationState.t()}
  @spec authenticate_api_token(
          Types.account_identifier(),
          Types.credential(),
          NetTypes.addr_structs(),
          MscmpSystInstance.Types.instance_id(),
          Keyword.t()
        ) :: {:ok, Types.AuthenticationState.t()}

  def authenticate_api_token(identifier, plaintext_token, host_addr, instance_id, opts \\ [])
      when is_binary(identifier) and is_binary(plaintext_token) and is_ip(host_addr) and
             (is_uuid(instance_id) or instance_id === :bypass) and is_list(opts) do
    validated_opts = NimbleOptions.validate!(opts, @authenticate_api_token_opts)

    Impl.ExtendedAuthLogic.authenticate_api_token(
      identifier,
      plaintext_token,
      host_addr,
      instance_id,
      validated_opts
    )
  end
end
