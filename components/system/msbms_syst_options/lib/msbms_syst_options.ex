defmodule MsbmsSystOptions do

  @moduledoc """
  API for retrieving and working with option files stored in the application server file system.
  """

  alias MsbmsSystOptions.Impl.OptionsFile

  @doc """
  Parses and returns the contents of a TOML file at `options_file_path` via a
  result tuple.

  If successful a tuple with a first value of `:ok` and second value containing
  a map of the options is returned.  When errors are found, a tuple with a first
  value of `:error` and second value of the relevant `MsbmsSystError` exception
  is returned.

  ## Examples

      iex> MsbmsSystOptions.get_options("./testing_options.toml")
      { :ok,
        %{
          "test_key1" => "test value",
          "test_list" => [
            %{"test_key2" => "test value 2", "test_key3" => "test value 3"},
            %{"test_key2" => "test value 2", "test_key3" => "test value 3"}
          ]
        } }

      iex> with {:error, %MsbmsSystError{}} <-
      ...>   MsbmsSystOptions.get_options("./bad_file_name.toml") do
      ...>   :error_returned
      ...> end
      :error_returned

  """
  @spec get_options(String.t()) :: {:ok, map()} | {:error, MsbmsSystError.t()}
  defdelegate get_options(options_file_path), to: OptionsFile

  @doc """
  Parses and returns the contents of a TOML file at `options_file_path` or
  raises.

  The returned options will be in a map equivalent to the TOML file's structure.

  ## Examples

      iex> MsbmsSystOptions.get_options!("./testing_options.toml")
      %{
        "test_key1" => "test value",
        "test_list" => [
          %{"test_key2" => "test value 2", "test_key3" => "test value 3"},
          %{"test_key2" => "test value 2", "test_key3" => "test value 3"}
        ]
      }

      iex> MsbmsSystOptions.get_options!("./bad_file_name.toml")
      ** (MsbmsSystError) Problem reading options file './bad_file_name.toml'.
  """
  @spec get_options!(String.t()) :: map()
  defdelegate get_options!(options_file_path), to: OptionsFile

end
