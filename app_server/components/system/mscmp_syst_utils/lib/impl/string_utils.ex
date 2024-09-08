# Source File: string_utils.ex
# Location:    musebms/app_server/components/system/mscmp_syst_utils/lib/impl/string_utils.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystUtils.Impl.StringUtils do
  @moduledoc false

  alias MscmpSystUtils.Types

  @spec get_random_string(pos_integer(), Types.tokens()) :: String.t()
  def get_random_string(string_length, tokens) when is_list(tokens) do
    <<i1::unsigned-integer-32, i2::unsigned-integer-32, i3::unsigned-integer-32>> =
      :crypto.strong_rand_bytes(12)

    _ = :rand.seed(:exsss, {i1, i2, i3})

    for _ <- 1..string_length, into: [] do
      Enum.random(tokens)
    end
    |> to_string()
  end

  def get_random_string(string_length, :alphanum),
    do: get_random_string(string_length, ~c"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ")

  def get_random_string(string_length, :b32e),
    do: get_random_string(string_length, ~c"0123456789ABCDEFGHIJKLMNOPQRSTUV")

  def get_random_string(string_length, :b32c),
    do: get_random_string(string_length, ~c"0123456789ABCDEFGHJKMNPQRSTVWXYZ")

  def get_random_string(string_length, :mixed_alphanum) do
    get_random_string(
      string_length,
      ~c"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
    )
  end
end
