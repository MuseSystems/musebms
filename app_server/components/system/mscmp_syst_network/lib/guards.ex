# Source File: guards.ex
# Location:    musebms/app_server/components/system/mscmp_syst_network/lib/guards.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystNetwork.Guards do
  @doc false
  defguard is_byte(n) when is_integer(n) and n >= 0 and n <= 255
  @doc false
  defguard is_short(n) when is_integer(n) and n >= 0 and n <= 0xFFFF

  @doc """
  A guard function which indicates whether a passed value is an Erlang style
  IPv4 tuple.

  ## Examples

      iex> import MscmpSystNetwork.Guards
      iex> is_ipv4_tuple({10, 0, 0, 1})
      true
      iex> is_ipv4_tuple(:foo)
      false
      iex> is_ipv4_tuple({256, 0, 0, 0})
      false
  """
  defguard is_ipv4_tuple(addr)
           when is_tuple(addr) and tuple_size(addr) == 4 and
                  is_byte(elem(addr, 0)) and is_byte(elem(addr, 1)) and
                  is_byte(elem(addr, 2)) and is_byte(elem(addr, 3))

  @doc """
  A guard function which indicates whether a passed value is an Erlang style
  IPv6 tuple.

  ## Examples

      iex> import MscmpSystNetwork.Guards
      iex> is_ipv6_tuple({0, 0, 0, 0, 0, 0, 0, 1})
      true
      iex> is_ipv6_tuple(:foo)
      false
      iex> is_ipv6_tuple({0x10000, 0, 0, 0, 0, 0, 0, 1})
      false
  """
  defguard is_ipv6_tuple(addr)
           when is_tuple(addr) and tuple_size(addr) == 8 and
                  is_short(elem(addr, 0)) and is_short(elem(addr, 1)) and
                  is_short(elem(addr, 2)) and is_short(elem(addr, 3)) and
                  is_short(elem(addr, 4)) and is_short(elem(addr, 5)) and
                  is_short(elem(addr, 6)) and is_short(elem(addr, 7))
end
