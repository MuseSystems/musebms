# Source File: mscmp_syst_utils_guards.ex
# Location:    musebms/app_server/components/system/mscmp_syst_utils_guards/lib/api/mscmp_syst_utils_guards.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule Msutils.Guards do
  @external_resource "README.md"
  @moduledoc Path.join([__DIR__, "..", "..", "README.md"])
             |> File.read!()
             |> String.split("<!-- MDOC !-->")
             |> Enum.fetch!(1)

  @spec __using__(any()) :: Macro.t()
  @doc false
  defmacro __using__(_opts) do
    quote do
      require Msutils.Guards
      import Msutils.Guards
    end
  end

  ##############################################################################
  #
  # is_reg_atom
  #
  #

  @doc """
  A guard function which returns true when the passed value is a regular atom
  that has no special meaning in Elixir or Erlang.

  This excludes `nil`, `true`, and `false`.

  ## Examples

      iex> is_reg_atom(:an_atom)
      true
      iex> is_reg_atom(nil)
      false
      iex> is_reg_atom(true)
      false
      iex> is_reg_atom(false)
      false
      iex> is_reg_atom("a string")
      false
  """
  @spec is_reg_atom(term()) :: Macro.t()
  defguard is_reg_atom(value) when is_atom(value) and value not in [nil, true, false]
end
