# Source File: utils.ex
# Location:    musebms/components/system/msbms_syst_utils/lib/impl/utils.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MsbmsSystUtils.Impl.Utils do
  @moduledoc false

  @spec resolve_options(Keyword.t(), Keyword.t()) :: Keyword.t()
  def resolve_options(opts_given, opts_default) do
    Keyword.merge(opts_given || [], opts_default, fn _k, given, default -> given || default end)
  end

  @spec get_random_string(pos_integer(), charlist() | atom()) :: String.t()
  def get_random_string(string_length, tokens) when is_list(tokens) do
    <<i1::unsigned-integer-32, i2::unsigned-integer-32, i3::unsigned-integer-32>> =
      :crypto.strong_rand_bytes(12)

    :rand.seed(:exsss, {i1, i2, i3})

    for _ <- 1..string_length, into: [] do
      Enum.random(tokens)
    end
    |> to_string()
  end

  def get_random_string(string_length, :alphanum),
    do: get_random_string(string_length, '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ')

  def get_random_string(string_length, :b32e),
    do: get_random_string(string_length, '0123456789ABCDEFGHIJKLMNOPQRSTUV')

  def get_random_string(string_length, :b32c),
    do: get_random_string(string_length, '0123456789ABCDEFGHJKMNPQRSTVWXYZ')

  def get_random_string(string_length, :mixed_alphanum),
    do:
      get_random_string(
        string_length,
        '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'
      )
end
