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
  @moduledoc """
  Provides guards which can do basic IP address tuple and IP address struct
  validation.
  """
  @doc false
  defguardp is_byte(n) when is_integer(n) and n >= 0 and n <= 255

  @doc false
  defguardp is_short(n) when is_integer(n) and n >= 0 and n <= 0xFFFF

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

  @doc """
  A guard function which returns true when a passed value is either an Erlang
  style IPv4 or IPv6 tuple.

  ## Examples

    IPv4 Examples

      iex> import MscmpSystNetwork.Guards
      iex> is_ip_tuple({10, 1, 1, 20})
      true
      iex> is_ip_tuple({10, 1, 1, 0})
      true
      iex> is_ip_tuple(:foo)
      false

    IPv6 Examples

      iex> import MscmpSystNetwork.Guards
      iex> is_ip_tuple({64923, 30712, 29005, 51899, 0, 0, 0, 32})
      true
      iex> is_ip_tuple({64923, 30712, 29005, 51899, 0, 0, 0, 0})
      true
      iex> is_ip_tuple({0x10000, 0, 0, 0, 0, 0, 0, 1})
      false
  """
  defguard is_ip_tuple(addr) when is_ipv4_tuple(addr) or is_ipv6_tuple(addr)

  @doc """
  A guard function which returns true when the passed value is an integer which
  is a valid IPv4 sub-net mask length.

  ## Examples

      iex> import MscmpSystNetwork.Guards
      iex> is_ipv4_mask(24)
      true
      iex> is_ipv4_mask(32)
      true
      iex> is_ipv4_mask(64)
      false
      iex> is_ipv4_mask(:"24")
      false
  """
  defguard is_ipv4_mask(mask) when is_integer(mask) and mask >= 0 and mask <= 32

  @doc """
  A guard function which returns true when the passed value is an integer which
  is a valid IPv6 sub-net mask length.

  ## Examples

      iex> import MscmpSystNetwork.Guards
      iex> is_ipv6_mask(64)
      true
      iex> is_ipv6_mask(128)
      true
      iex> is_ipv6_mask(68)
      true
      iex> is_ipv6_mask(:"68")
      false
  """
  defguard is_ipv6_mask(prefix) when is_integer(prefix) and prefix >= 0 and prefix <= 128

  @doc """
  A guard function which returns true when the passed value is a valid
  `t:MscmpSystNetwork.Types.IpV4.t/0` value.

  ## Examples

      iex> import MscmpSystNetwork.Guards
      iex> alias MscmpSystNetwork.Types.IpV4
      iex> host_addr = %IpV4{address: {10, 1, 1, 10}, mask: 32}
      iex> is_ipv4(host_addr)
      true
      iex> subnet_addr = %IpV4{address: {10, 1, 0, 0}, mask: 16}
      iex> is_ipv4(subnet_addr)
      true
      iex> bad_addr = {10, 1, 1, 10}
      iex> is_ipv4(bad_addr)
      false
  """
  defguard is_ipv4(addr)
           when is_struct(addr) and
                  :erlang.map_get(:__struct__, addr) == MscmpSystNetwork.Types.IpV4 and
                  is_ipv4_tuple(:erlang.map_get(:address, addr)) and
                  is_ipv4_mask(:erlang.map_get(:mask, addr))

  @doc """
  A guard function which returns true when the passed value is a valid
  `t:MscmpSystNetwork.Types.IpV6.t/0` value.

  ## Examples

      iex> import MscmpSystNetwork.Guards
      iex> alias MscmpSystNetwork.Types.IpV6
      iex> host_addr = %IpV6{address: {64923, 30712, 29005, 51899, 0, 0, 0, 32}, mask: 128}
      iex> is_ipv6(host_addr)
      true
      iex> subnet_addr =
      ...>   %IpV6{
      ...>     address: {64923, 30712, 29005, 51899, 0, 0, 0, 0},
      ...>     mask: 64
      ...>   }
      iex> is_ipv6(subnet_addr)
      true
      iex> bad_addr = {64923, 30712, 29005, 51899, 0, 0, 0, 32}
      iex> is_ipv6(bad_addr)
      false
  """
  defguard is_ipv6(addr)
           when is_struct(addr) and
                  :erlang.map_get(:__struct__, addr) == MscmpSystNetwork.Types.IpV6 and
                  is_ipv6_tuple(:erlang.map_get(:address, addr)) and
                  is_ipv6_mask(:erlang.map_get(:mask, addr))

  @doc """
  A guard function which returns true when the passed value is either a valid
  `t:MscmpSystNetwork.Types.IpV4.t/0` or `t:MscmpSystNetwork.Types.IpV6.t/0`
  struct.

  ## Examples

    IPv4 Examples

      iex> import MscmpSystNetwork.Guards
      iex> alias MscmpSystNetwork.Types.IpV4
      iex> host_addr = %IpV4{address: {10, 1, 1, 10}, mask: 32}
      iex> is_ip(host_addr)
      true
      iex> subnet_addr = %IpV4{address: {10, 1, 0, 0}, mask: 16}
      iex> is_ip(subnet_addr)
      true
      iex> bad_addr = {10, 1, 1, 10}
      iex> is_ip(bad_addr)
      false

    IPv6 Examples

      iex> import MscmpSystNetwork.Guards
      iex> alias MscmpSystNetwork.Types.IpV6
      iex> host_addr = %IpV6{address: {64923, 30712, 29005, 51899, 0, 0, 0, 32}, mask: 128}
      iex> is_ip(host_addr)
      true
      iex> subnet_addr =
      ...>   %IpV6{
      ...>     address: {64923, 30712, 29005, 51899, 0, 0, 0, 0},
      ...>     mask: 64
      ...>   }
      iex> is_ip(subnet_addr)
      true
      iex> bad_addr = {64923, 30712, 29005, 51899, 0, 0, 0, 32}
      iex> is_ip(bad_addr)
      false
  """
  defguard is_ip(addr) when is_ipv4(addr) or is_ipv6(addr)
end
