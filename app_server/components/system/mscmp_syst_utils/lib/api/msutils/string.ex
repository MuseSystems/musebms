# Source File: string.ex
# Location:    musebms/app_server/components/system/mscmp_syst_utils/lib/api/msutils/string.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule Msutils.String do
  @moduledoc """
  This module provides string utilities.
  """

  alias MscmpSystUtils.Impl.StringUtils
  alias Msutils.Types.String, as: StringTypes

  ##############################################################################
  #
  # get_random_string
  #
  #

  @doc """
  Generates a random string drawn from a specified list of characters.

  ## Parameters

    * `string_length` - the number of characters in the returned string.

    * `tokens` - this optional parameter may either be a `charlist()` including
    the desired characters from which to randomly select characters for the
    string or the parameter may be an atom which designates a predefined
    character list.  The available predefined character lists are:

      * `:alphanum` - will return values from the set
      `0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ`.  This is the default value.

      * `:mixed_alphanum` - will return values from the set
      `0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz`

      * `b32e` - will return values from the set
      `0123456789ABCDEFGHIJKLMNOPQRSTUV`.  This equates to the character set
      used by Elixir's `Integer.to_string(x, 32)`.

      * `b32c` - will return values from the set
      `0123456789ABCDEFGHJKMNPQRSTVWXYZ`.  This is the Base32 character set
      compatible with Douglas Crockford's Base 32 (https://www.crockford.com/base32.html).

  ## Examples

  The following examples demonstrate usage and expected characteristics of the
  function.

  Default :alphanum token - 8 characters from 0-9 and A-Z

      iex> result = Msutils.String.get_random_string(8)
      iex> String.match?(result, ~r/^[0-9A-Z]{8}$/)
      true

  Mixed case alphanumeric - 10 characters from 0-9, A-Z, and a-z

      iex> result = Msutils.String.get_random_string(10, :mixed_alphanum)
      iex> String.match?(result, ~r/^[0-9A-Za-z]{10}$/)
      true

  Base32 Elixir style - 6 characters from 0-9 and A-V

      iex> result = Msutils.String.get_random_string(6, :b32e)
      iex> String.match?(result, ~r/^[0-9A-V]{6}$/)
      true

  Base32 Crockford style - 6 characters from Crockford's set

      iex> result = Msutils.String.get_random_string(6, :b32c)
      iex> String.match?(result, ~r/^[0-9ABCDEFGHJKMNPQRSTVWXYZ]{6}$/)
      true

  Custom character list

      iex> result = Msutils.String.get_random_string(4, ~c"ABC123")
      iex> String.match?(result, ~r/^[ABC123]{4}$/)
      true
  """
  @spec get_random_string(pos_integer()) :: String.t()
  @spec get_random_string(pos_integer(), StringTypes.tokens()) :: String.t()
  defdelegate get_random_string(string_length, tokens \\ :alphanum),
    to: StringUtils
end
