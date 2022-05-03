defmodule MsbmsSystInstanceMgr do
  @moduledoc """
  Documentation for `MsbmsSystInstanceMgr`.
  """

  @doc """
  Returns a simple list of applications sorted according to the database
  collation.

  ## Examples
      iex> {:ok, apps} = MsbmsSystInstanceMgr.list_applications()
  """
  @spec list_applications() :: {:ok, list()} | {:error, MsbmsSystError.t()}
  defdelegate list_applications, to: MsbmsSystInstanceMgr.Impl.Applications
end
