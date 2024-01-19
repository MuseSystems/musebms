# Source File: mscmp_syst_utils.ex
# Location:    musebms/app_server/components/system/mscmp_syst_utils/lib/api/mscmp_syst_utils.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystUtils do
  @external_resource "README.md"
  @moduledoc Path.join([__DIR__, "..", "..", "README.md"])
             |> File.read!()
             |> String.split("<!-- MDOC !-->")
             |> Enum.fetch!(1)

  alias MscmpSystUtils.Impl

  @doc section: :options_management
  @doc """
  Resolves function options provided as a Keyword List to either the value
  provided or a default from a Keyword List of default values.

  In many cases, we want to have optional functional parameters.  This small
  function will merge the user given options with a preset defined list of
  option defaults, always preferring the user given options.

  Note that for keys in the `opts_given` argument that have `nil` values, the
  default value of the argument is used instead; the default value may itself
  may be `nil`, but one should be aware that `nil` is not always respected as a
  given value.

  The result is a Keyword List of the merged lists.

  ## Parameters

    * `opts_given` - a Keyword List of options provided by the caller.  This
    list may include all options, any subset of options, be an empty list, or be
    nil.

    * `opts_default` - a Keyword List of options with their default values. This
    list defines the expected optional values and their default value should the
    user not provide a value.

  ## Examples

      iex> given_options = [test_value_one: 1]
      iex> default_options = [test_value_one: 0, test_value_two: 2]
      iex> MscmpSystUtils.resolve_options(given_options, default_options)
      [test_value_one: 1, test_value_two: 2]
  """
  @spec resolve_options(Keyword.t(), Keyword.t()) :: Keyword.t()
  defdelegate resolve_options(opts_given, opts_default), to: Impl.Utils

  @doc section: :string_utilities
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
  """
  @spec get_random_string(pos_integer(), charlist() | atom()) :: String.t()
  defdelegate get_random_string(string_length, tokens \\ :alphanum),
    to: Impl.Utils
end
