defmodule MsbmsSystOptions do

  @moduledoc """
  API for retrieving and working with option files stored in the application server file system.
  """

  alias MsbmsSystOptions.Constants
  alias MsbmsSystOptions.Impl.OptionsFile

  @startup_options_path Constants.get(:startup_options_path)

  @doc """
  Parses and returns the contents of a TOML file at `options_file_path` via a
  result tuple.

  If successful a tuple with a first value of `:ok` and second value containing
  a map of the options is returned.  When errors are found, a tuple with a first
  value of `:error` and second value of the relevant `MsbmsSystError` exception
  is returned.

  ## Examples

      iex> with {:ok, %{}} <- MsbmsSystOptions.get_options(), do: :map_returned
      :map_returned

      iex> with {:ok, %{}} <-
      ...>   MsbmsSystOptions.get_options("./msbms_startup_options.toml") do
      ...>   :map_returned
      ...> end
      :map_returned

      iex> with {:error, %MsbmsSystError{}} <-
      ...>   MsbmsSystOptions.get_options("./bad_file_name.toml") do
      ...>   :error_returned
      ...> end
      :error_returned

  """
  @spec get_options(String.t()) :: {:ok, map()} | {:error, MsbmsSystError.t()}
  defdelegate get_options(options_file_path \\ @startup_options_path), to: OptionsFile

  @doc """
  Parses and returns the contents of a TOML file at `options_file_path` or
  raises.

  The returned options will be in a map equivalent to the TOML file's structure.

  ## Examples

      iex> with %{} <- MsbmsSystOptions.get_options!(), do: :map_returned
      :map_returned

      iex> with %{} <-
      ...>   MsbmsSystOptions.get_options!("./msbms_startup_options.toml") do
      ...>   :map_returned
      ...> end
      :map_returned

      iex> MsbmsSystOptions.get_options!("./bad_file_name.toml")
      ** (MsbmsSystError) Problem reading options file './bad_file_name.toml'.
  """
  @spec get_options!(String.t()) :: map()
  defdelegate get_options!(options_file_path \\ @startup_options_path), to: OptionsFile

end
