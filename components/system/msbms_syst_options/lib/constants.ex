# Source File: constants.ex
# Location:    components/system/msbms_syst_options/lib/constants.ex
# Project:     msbms
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https: //muse.systems

defmodule MsbmsSystOptions.Constants do

  @moduledoc """
  Defines constant values for use across the application. The currently defined
  constants are:

    * __:startup_options_path__

      A default path for finding the location of the msbms_startup_options.toml
      file.

    * __:example_constant__

      An example constant for use in documentation examples.  This allows the
      examples to pass doctests without coding an actual constant into the
      documentation.
  """
  constants = [
    example_constant:     "Example Value",
    startup_options_path: Path.join(["msbms_startup_options.toml"]),
  ]

  @spec get( atom() ) :: any()
  @doc """
  Allows for application retrieval of defined option constants for use across
  the application.  Constants defined in this module are by definition public.
  Non-public constants should either be defined as module attributes or defined
  in the config.exs files.

  ## Examples

      iex> MsbmsSystOptions.Constants.get(:example_constant)
      "Example Value"
  """
  for {const, value} <- constants do
    def get(unquote(const)), do: unquote(value)
  end

  def get(bad_constant) when is_atom(bad_constant) do
    raise MsbmsSystError,
      code:    :invalid_parameter,
      message: "Constant not found: #{inspect(bad_constant)}"
  end
end
