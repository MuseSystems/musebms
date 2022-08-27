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

  @spec invite_access_account_to_instance(
          Types.access_account_id(),
          MsbmsSystInstanceMgr.Types.instance_id(),
          Types.credential_type_id(),
          Keyword.t()
        ) :: {:ok, Data.SystAccessAccountInstanceAssocs.t()} | {:error, MsbmsSystError.t()}
  defdelegate invite_access_account_to_instance(
                access_account_id,
                instance_id,
                credential_type_id,
                opts \\ []
              ),
              to: Impl.AccessAccountInstanceAssoc
end
