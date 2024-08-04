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

  ##############################################################################
  #
  # String Utilities
  #
  ##############################################################################

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

  defdelegate get_random_string(string_length, tokens \\ :alphanum),
    to: Impl.StringUtils
end
