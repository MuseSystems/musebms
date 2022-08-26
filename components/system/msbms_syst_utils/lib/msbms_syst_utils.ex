# Source File: msbms_syst_utils.ex
# Location:    musebms/components/system/msbms_syst_utils/lib/msbms_syst_utils.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MsbmsSystUtils do
  alias MsbmsSystUtils.Impl

  @moduledoc """
  Common utility functions generally useful across components.
  """

  @doc section: :options_management
  @doc """
  Resolves function options provided as a Keyword List to either the value
  provided or a default from a Keyword List of default values.

  In many cases, we want to have optional functional parameters.  This small
  function will merge the user given options with a preset defined list of
  option defaults, always preferring the user given options.

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
      iex> MsbmsSystUtils.resolve_options(given_options, default_options)
      [test_value_one: 1, test_value_two: 2]
  """
  @spec resolve_options(Keyword.t(), Keyword.t()) :: Keyword.t()
  defdelegate resolve_options(opts_given, opts_default), to: Impl.Utils
end
