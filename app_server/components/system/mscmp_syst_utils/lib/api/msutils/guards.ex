# Source File: guards.ex
# Location:    musebms/app_server/components/system/mscmp_syst_utils/lib/api/msutils/guards.ex
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
  @moduledoc """
  This module defines common guards.
  """

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

  ##############################################################################
  #
  # is_uuid
  #
  #

  @doc """
  Returns `true` when the passed value is a binary string is in a format that
  is consistent with the standard "8-4-4-4-12" textual representation of a UUID.

  > #### Limitation {: .warning}
  >
  > This guard does not validate that the characters are valid hex digits and thus
  > it will return `true` even in cases where the value is not a valid UUID. In
  > this regard, this guard acts more as a sanity check than a true validation.

  For a more complete check, consider using `Ecto.UUID.dump/1` rather than a
  guard.

  ## Examples

  Proper UUIDs are validated as expected.

      iex> is_uuid("123e4567-e89b-12d3-a456-426614174000")
      true

  Non-UUID binaries are rejected.

      iex> is_uuid("not a uuid")
      false

  Non-UUIDs that happen to have the same format of a UUID are also validated.

      iex> is_uuid("zzzzzzzz-zzzz-zzzz-zzzz-zzzzzzzzzzzz")
      true

  """
  @spec is_uuid(term()) :: Macro.t()
  defguard is_uuid(value)
           when is_binary(value) and byte_size(value) == 36 and
                  binary_part(value, 8, 1) == "-" and
                  binary_part(value, 13, 1) == "-" and
                  binary_part(value, 18, 1) == "-" and
                  binary_part(value, 23, 1) == "-"
end
