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
  Looks up an Access Account record ID by its internal name.

  ## Parameters

    * `access_account_name` - the internal name of the record for which to 
    retrieve the record ID.

  ## Examples

    iex> {:ok, access_account_id}  = 
    ...>   MsbmsSystAuthentication.get_access_account_id_by_name("accnt1")
    iex> is_binary(access_account_id)
    true   
  """

  @spec get_access_account_id_by_name(Types.access_account_name()) ::
          {:ok, Types.access_account_id()} | {:error, MsbmsSystError.t()}
  defdelegate get_access_account_id_by_name(access_account_name), to: Impl.AccessAccount
end
