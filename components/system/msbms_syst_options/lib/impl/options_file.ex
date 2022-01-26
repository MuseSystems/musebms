# Source File: options_file.ex
# Location:    components/system/msbms_syst_options/lib/impl/options_file.ex
# Project:     msbms
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https: //muse.systems

defmodule MsbmsSystOptions.Impl.OptionsFile do

  @moduledoc false

  @spec get_options(options_file_path :: String.t()) :: {:ok, map()} | {:error, MsbmsSystError.t()}
  def get_options(options_file_path) when is_binary(options_file_path) do
    options_file_path
    |> maybe_file_read()
    |> maybe_file_decode()
  end

  @spec maybe_file_read(String.t()) :: {:ok, binary()} | {:error, MsbmsSystError.t()}
  defp maybe_file_read(options_file_path) do
    with error = {:error, _reason} <- File.read(options_file_path) do
      {
        :error,
        %MsbmsSystError{
          code:    :file_error,
          message: "Problem reading options file '#{options_file_path}'.",
          cause:   error
        }
      }
    end
  end

  @spec maybe_file_decode({:ok, binary()} | {:error, MsbmsSystError.t()}) ::
    {:ok , map()} | {:error, MsbmsSystError.t()}
  defp maybe_file_decode({:ok, file_contents}) do
    with error = {:error, _reason} <- Toml.decode(file_contents) do
      {
        :error,
        %MsbmsSystError{
          code:    :invalid_data,
          message: "Problem decoding the options file.",
          cause:   error
        }
      }
    end
  end

  defp maybe_file_decode(error = {:error, _reason}), do: error

  @spec get_options!(String.t()) :: map()
  def get_options!(options_file_path) when is_binary(options_file_path) do

    options_file_path
    |> get_options()
    |> extract_or_raise_options_map!()

  end

  @spec extract_or_raise_options_map!({:ok, map()} | {:error, MsbmsSystError.t()}) :: map()
  defp extract_or_raise_options_map!({:ok, options_map}) do
    options_map
  end

  defp extract_or_raise_options_map!({:error, msbms_error = %MsbmsSystError{}}) do
    raise MsbmsSystError,
      message: msbms_error.message,
      code:    msbms_error.code,
      cause:   msbms_error.cause
  end

end
