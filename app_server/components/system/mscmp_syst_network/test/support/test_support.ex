# Source File: test_support.ex
# Location:    musebms/app_server/components/system/mscmp_syst_network/test/support/test_support.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule TestSupport do
  @moduledoc false

  import Bitwise

  alias MscmpSystNetwork.Types.{IpV4, IpV6}

  def get_random_ipv4(:host) do
    <<a, b, c, d>> = :rand.bytes(4)
    {:host, %IpV4{address: {a, b, c, d}, mask: 32}}
  end

  def get_random_ipv4(:network) do
    seed = :rand.bytes(4)
    <<seed_int::unsigned-integer-size(32)>> = seed

    mask_length = :rand.uniform(31)

    <<mask::unsigned-integer-size(32)>> = <<-1 <<< (32 - mask_length)::32>>

    <<a, b, c, d>> = <<band(seed_int, mask)::32>>

    {:network, %IpV4{address: {a, b, c, d}, mask: mask_length}}
  end

  def get_random_ipv4(:broadcast) do
    seed = :rand.bytes(4)
    <<seed_int::unsigned-integer-size(32)>> = seed

    mask_length = :rand.uniform(31)

    <<mask::unsigned-integer-size(32)>> = <<-1 <<< (32 - mask_length)::32>>

    inverse_mask = bnot(mask) |> band(0xFFFF_FFFF)

    broadcast_address = seed_int ||| inverse_mask

    <<a, b, c, d>> = <<broadcast_address::32>>

    {:broadcast, %IpV4{address: {a, b, c, d}, mask: mask_length}}
  end

  def get_random_ipv4(:any, weights \\ {70, 15}) do
    h_weight = elem(weights, 0)
    n_weight = elem(weights, 0) + elem(weights, 1)
    selector = :rand.uniform(100)

    cond do
      selector <= h_weight -> get_random_ipv4(:host)
      selector <= n_weight -> get_random_ipv4(:network)
      true -> get_random_ipv4(:broadcast)
    end
  end

  def get_random_ipv4, do: get_random_ipv4(:any)

  def get_random_ipv6(:host) do
    <<a::unsigned-integer-size(16), b::unsigned-integer-size(16), c::unsigned-integer-size(16),
      d::unsigned-integer-size(16), e::unsigned-integer-size(16), f::unsigned-integer-size(16),
      g::unsigned-integer-size(16), h::unsigned-integer-size(16)>> = :rand.bytes(16)

    {:host, %IpV6{address: {a, b, c, d, e, f, g, h}, mask: 128}}
  end

  def get_random_ipv6(:network) do
    seed = :rand.bytes(16)
    <<seed_int::unsigned-integer-size(128)>> = seed

    # Make our network prefixes a multiple of 4 for readability.
    prefix = :rand.uniform(31) * 4

    <<mask::unsigned-integer-size(128)>> = <<-1 <<< (128 - prefix)::128>>

    <<a::unsigned-integer-size(16), b::unsigned-integer-size(16), c::unsigned-integer-size(16),
      d::unsigned-integer-size(16), e::unsigned-integer-size(16), f::unsigned-integer-size(16),
      g::unsigned-integer-size(16), h::unsigned-integer-size(16)>> = <<band(seed_int, mask)::128>>

    {:network, %IpV6{address: {a, b, c, d, e, f, g, h}, mask: prefix}}
  end

  def get_random_ipv6(:any, h_weight \\ 70) do
    if :rand.uniform(100) <= h_weight, do: get_random_ipv6(:host), else: get_random_ipv6(:network)
  end

  def get_random_ipv6, do: get_random_ipv6(:any)

  def ipv4_mask_to_tuple(mask) do
    <<a, b, c, d>> = <<-1::size(mask), 0::size(32 - mask)>>
    {a, b, c, d}
  end

  def ipv6_mask_to_tuple(mask) do
    <<a::unsigned-integer-size(16), b::unsigned-integer-size(16), c::unsigned-integer-size(16),
      d::unsigned-integer-size(16), e::unsigned-integer-size(16), f::unsigned-integer-size(16),
      g::unsigned-integer-size(16), h::unsigned-integer-size(16)>> = <<-1 <<< (128 - mask)::128>>

    {a, b, c, d, e, f, g, h}
  end

  def ipv4_network_to_tuple(_, 32), do: nil

  def ipv4_network_to_tuple(address, mask) do
    {a, b, c, d} = address
    {m1, m2, m3, m4} = ipv4_mask_to_tuple(mask)
    {a &&& m1, b &&& m2, c &&& m3, d &&& m4}
  end

  def ipv6_network_to_tuple(_, 128), do: nil

  def ipv6_network_to_tuple(address, mask) do
    {a, b, c, d, e, f, g, h} = address
    {m1, m2, m3, m4, m5, m6, m7, m8} = ipv6_mask_to_tuple(mask)
    {a &&& m1, b &&& m2, c &&& m3, d &&& m4, e &&& m5, f &&& m6, g &&& m7, h &&& m8}
  end

  def ipv4_in_network?(host, network) do
    host_int = ipv4_to_integer(host.address)
    network_int = ipv4_to_integer(network.address)
    mask_int = (1 <<< 32) - (1 <<< (32 - network.mask))

    (host_int &&& mask_int) == (network_int &&& mask_int)
  end

  def ipv6_in_network?(host, network) do
    host_int = ipv6_to_integer(host.address)
    network_int = ipv6_to_integer(network.address)
    mask_int = (1 <<< 128) - (1 <<< (128 - network.mask))

    (host_int &&& mask_int) == (network_int &&& mask_int)
  end

  def ipv4_in_range?(test_addr, low_addr, high_addr) do
    test_int = ipv4_to_integer(test_addr.address)

    low_int =
      if network?(low_addr) do
        ipv4_to_integer(low_addr.address) &&& mask_to_int(low_addr.mask, 32)
      else
        ipv4_to_integer(low_addr.address)
      end

    high_int =
      if network?(high_addr) do
        ipv4_to_integer(high_addr.address) |||
          (bnot(mask_to_int(high_addr.mask, 32)) &&& 0xFFFFFFFF)
      else
        ipv4_to_integer(high_addr.address)
      end

    test_int >= low_int and test_int <= high_int
  end

  def ipv6_in_range?(test_addr, low_addr, high_addr) do
    test_int = ipv6_to_integer(test_addr.address)

    low_int =
      if network?(low_addr) do
        ipv6_to_integer(low_addr.address) &&& mask_to_int(low_addr.mask, 128)
      else
        ipv6_to_integer(low_addr.address)
      end

    high_int =
      if network?(high_addr) do
        ipv6_to_integer(high_addr.address) ||| bnot(mask_to_int(high_addr.mask, 128))
      else
        ipv6_to_integer(high_addr.address)
      end

    test_int >= low_int and test_int <= high_int
  end

  defp mask_to_int(mask, bits), do: bnot((1 <<< (bits - mask)) - 1)

  defp network?(%{mask: mask}), do: mask < 128

  defp ipv4_to_integer({a, b, c, d}), do: a <<< 24 ||| b <<< 16 ||| c <<< 8 ||| d

  defp ipv6_to_integer({a, b, c, d, e, f, g, h}) do
    a <<< 112 ||| b <<< 96 ||| c <<< 80 ||| d <<< 64 ||| e <<< 48 ||| f <<< 32 ||| g <<< 16 ||| h
  end
end
