# Source File: ip_v4_test.exs
# Location:    musebms/app_server/components/system/mscmp_syst_network/test/ip_v4_test.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule IpV4Test do
  use ExUnit.Case, async: true

  import Bitwise

  alias MscmpSystNetwork.Impl
  alias MscmpSystNetwork.Types.IpV4

  @moduletag :capture_log

  #
  # @spec to_string(IpV4.t()) :: String.t()
  #

  test "Can convert IP structs to string" do
    Enum.each(1..1_000_000, fn _ ->
      {_, addr_struct} = get_random_ip()
      %IpV4{address: {a, b, c, d}, mask: mask} = addr_struct

      expected_result =
        [a, b, c, d] |> Enum.join(".") |> then(&(&1 <> "/" <> Integer.to_string(mask)))

      assert expected_result === Impl.IpV4.to_string(addr_struct)
    end)
  end

  #
  # @spec get_netmask(IpV4.t()) :: Types.ip4_addr()
  #

  test "Can get network mask from struct" do
    Enum.each(1..1_000_000, fn _ ->
      {_, addr_struct} = get_random_ip(:any, {33, 33})

      <<a, b, c, d>> = <<-1 <<< (32 - addr_struct.mask)::32>>
      expected_result = {a, b, c, d}

      assert expected_result === Impl.IpV4.get_netmask(addr_struct)
    end)
  end

  #
  # @spec get_network(IpV4.t()) :: Types.ip4_addr() | nil
  #

  test "Can get network or nil from struct" do
    Enum.each(1..1_000_000, fn _ ->
      {kind, addr_struct} = get_random_ip(:any, {15, 70})

      expected_result =
        if kind !== :host do
          {a1, b1, c1, d1} = addr_struct.address
          <<int_addr::unsigned-integer-size(32)>> = <<a1, b1, c1, d1>>
          <<int_mask::unsigned-integer-size(32)>> = <<-1 <<< (32 - addr_struct.mask)::32>>
          <<a2, b2, c2, d2>> = <<band(int_addr, int_mask)::unsigned-integer-size(32)>>
          {a2, b2, c2, d2}
        end

      assert expected_result === Impl.IpV4.get_network(addr_struct)
    end)
  end

  #
  # @spec get_host(IpV4.t()) :: Types.ip4_addr() | nil
  #

  test "Can get host or nil from struct" do
    Enum.each(1..1_000_000, fn _ ->
      {kind, addr_struct} = get_random_ip()

      expected_result = if kind === :host, do: addr_struct.address

      assert expected_result === Impl.IpV4.get_host(addr_struct)
    end)
  end

  #
  # @spec host?(IpV4.t()) :: boolean()
  #

  test "Can test if struct represents a host" do
    Enum.each(1..1_000_000, fn _ ->
      {kind, addr_struct} = get_random_ip()

      expected_result = kind === :host

      assert expected_result === Impl.IpV4.host?(addr_struct)
    end)
  end

  #
  # @spec network?(IpV4.t()) :: boolean()
  #

  test "Can test if struct represents a subnet" do
    Enum.each(1..1_000_000, fn _ ->
      {kind, addr_struct} = get_random_ip(:any, {15, 70})

      expected_result = kind === :network

      assert expected_result === Impl.IpV4.network?(addr_struct)
    end)
  end

  #
  # @spec to_struct(Types.ip4_addr(), 1..32 | nil) :: IpV4.t()
  #

  test "Can create struct from Erlang IP address and mask" do
    Enum.each(1..1_000_000, fn _ ->
      {_, expected_result} = get_random_ip(:any, {15, 70})

      assert expected_result ===
               Impl.IpV4.to_struct(expected_result.address, expected_result.mask)
    end)
  end

  #
  # @spec in_network?(IpV4.t(), IpV4.t()) :: boolean()
  #

  test "Can test if IP address or network is contained by an identified network" do
    test_data =
      [
        {%IpV4{address: {10, 1, 1, 12}, mask: 32}, %IpV4{address: {10, 1, 1, 0}, mask: 24}, true},
        {%IpV4{address: {10, 1, 1, 0}, mask: 24}, %IpV4{address: {10, 1, 1, 0}, mask: 24}, true},
        {%IpV4{address: {10, 1, 2, 12}, mask: 32}, %IpV4{address: {10, 1, 1, 0}, mask: 24},
         false},
        {%IpV4{address: {10, 1, 1, 12}, mask: 32}, %IpV4{address: {10, 0, 0, 0}, mask: 8}, true},
        {%IpV4{address: {10, 1, 1, 12}, mask: 32}, %IpV4{address: {10, 0, 0, 0}, mask: 8}, true},
        {%IpV4{address: {10, 2, 1, 12}, mask: 32}, %IpV4{address: {10, 0, 0, 0}, mask: 8}, true},
        {%IpV4{address: {10, 2, 1, 0}, mask: 24}, %IpV4{address: {10, 0, 0, 0}, mask: 8}, true},
        {%IpV4{address: {10, 0, 0, 0}, mask: 8}, %IpV4{address: {10, 0, 0, 0}, mask: 8}, true},
        {%IpV4{address: {10, 255, 255, 255}, mask: 8}, %IpV4{address: {10, 0, 0, 0}, mask: 8},
         true},
        {%IpV4{address: {11, 0, 0, 0}, mask: 8}, %IpV4{address: {10, 0, 0, 0}, mask: 8}, false}
      ]

    Enum.each(test_data, fn curr_tuple ->
      assert elem(curr_tuple, 2) ===
               Impl.IpV4.in_network?(elem(curr_tuple, 0), elem(curr_tuple, 1))
    end)
  end

  #
  # @spec in_range?(IpV4.t(), IpV4.t(), IpV4.t()) :: boolean()
  #

  test "Can test if IP address or network is contained by an identified range" do
    test_data =
      [
        {%IpV4{address: {10, 1, 1, 12}, mask: 32}, %IpV4{address: {10, 1, 1, 1}, mask: 32},
         %IpV4{address: {10, 1, 1, 254}, mask: 32}, true},
        {%IpV4{address: {10, 1, 2, 12}, mask: 32}, %IpV4{address: {10, 1, 1, 1}, mask: 32},
         %IpV4{address: {10, 1, 1, 254}, mask: 32}, false},
        {%IpV4{address: {10, 1, 1, 12}, mask: 32}, %IpV4{address: {10, 1, 1, 0}, mask: 24},
         %IpV4{address: {10, 1, 1, 0}, mask: 24}, true},
        {%IpV4{address: {10, 2, 1, 12}, mask: 32}, %IpV4{address: {10, 1, 1, 0}, mask: 24},
         %IpV4{address: {10, 1, 1, 0}, mask: 24}, false},
        {%IpV4{address: {10, 1, 1, 0}, mask: 24}, %IpV4{address: {10, 0, 0, 0}, mask: 8},
         %IpV4{address: {10, 0, 0, 0}, mask: 8}, true},
        {%IpV4{address: {10, 1, 1, 0}, mask: 24}, %IpV4{address: {10, 1, 1, 0}, mask: 24},
         %IpV4{address: {10, 1, 1, 0}, mask: 24}, true},
        {%IpV4{address: {10, 1, 1, 2}, mask: 24}, %IpV4{address: {10, 1, 1, 0}, mask: 24},
         %IpV4{address: {10, 1, 1, 0}, mask: 24}, true},
        {%IpV4{address: {10, 2, 1, 2}, mask: 24}, %IpV4{address: {10, 1, 1, 0}, mask: 24},
         %IpV4{address: {10, 1, 1, 0}, mask: 24}, false},
        {%IpV4{address: {10, 2, 1, 2}, mask: 24}, %IpV4{address: {10, 0, 0, 0}, mask: 8},
         %IpV4{address: {11, 0, 0, 0}, mask: 8}, true},
        {%IpV4{address: {10, 10, 0, 0}, mask: 16}, %IpV4{address: {10, 0, 0, 0}, mask: 8},
         %IpV4{address: {11, 0, 0, 0}, mask: 8}, true},
        {%IpV4{address: {12, 10, 0, 0}, mask: 16}, %IpV4{address: {10, 0, 0, 0}, mask: 8},
         %IpV4{address: {11, 0, 0, 0}, mask: 8}, false},
        {%IpV4{address: {199, 10, 0, 0}, mask: 16}, %IpV4{address: {192, 168, 0, 0}, mask: 32},
         %IpV4{address: {201, 0, 0, 0}, mask: 32}, true},
        {%IpV4{address: {198, 168, 0, 0}, mask: 32}, %IpV4{address: {192, 168, 0, 0}, mask: 32},
         %IpV4{address: {201, 0, 0, 0}, mask: 32}, true},
        {%IpV4{address: {201, 0, 0, 0}, mask: 32}, %IpV4{address: {192, 168, 0, 0}, mask: 32},
         %IpV4{address: {201, 0, 0, 0}, mask: 32}, true},
        {%IpV4{address: {198, 167, 255, 255}, mask: 32},
         %IpV4{address: {192, 168, 0, 0}, mask: 32}, %IpV4{address: {201, 0, 0, 0}, mask: 32},
         true},
        {%IpV4{address: {201, 0, 0, 1}, mask: 32}, %IpV4{address: {192, 168, 0, 0}, mask: 32},
         %IpV4{address: {201, 0, 0, 0}, mask: 32}, false},
        {%IpV4{address: {200, 10, 1, 1}, mask: 16}, %IpV4{address: {192, 168, 0, 0}, mask: 32},
         %IpV4{address: {201, 0, 0, 0}, mask: 32}, true}
      ]

    Enum.each(test_data, fn curr_tuple ->
      assert elem(curr_tuple, 3) ===
               Impl.IpV4.in_range?(elem(curr_tuple, 0), elem(curr_tuple, 1), elem(curr_tuple, 2))
    end)
  end

  #
  # Private support functions
  #

  defp get_random_ip(:host) do
    <<a, b, c, d>> = :rand.bytes(4)
    {:host, %IpV4{address: {a, b, c, d}, mask: 32}}
  end

  defp get_random_ip(:network) do
    seed = :rand.bytes(4)
    <<seed_int::unsigned-integer-size(32)>> = seed

    mask_length = :rand.uniform(31)

    <<mask::unsigned-integer-size(32)>> = <<-1 <<< (32 - mask_length)::32>>

    <<a, b, c, d>> = <<band(seed_int, mask)::32>>

    {:network, %IpV4{address: {a, b, c, d}, mask: mask_length}}
  end

  defp get_random_ip(:broadcast) do
    seed = :rand.bytes(4)
    <<seed_int::unsigned-integer-size(32)>> = seed

    mask_length = :rand.uniform(31)

    <<mask::unsigned-integer-size(32)>> = <<-1 <<< (32 - mask_length)::32>>

    inverse_mask = bnot(mask) |> band(0xFFFF_FFFF)

    broadcast_address = seed_int ||| inverse_mask

    <<a, b, c, d>> = <<broadcast_address::32>>

    {:broadcast, %IpV4{address: {a, b, c, d}, mask: mask_length}}
  end

  defp get_random_ip(:any, weights \\ {70, 15}) do
    h_weight = elem(weights, 0)
    n_weight = elem(weights, 0) + elem(weights, 1)
    selector = :rand.uniform(100)

    cond do
      selector <= h_weight -> get_random_ip(:host)
      selector <= n_weight -> get_random_ip(:network)
      true -> get_random_ip(:broadcast)
    end
  end

  defp get_random_ip(), do: get_random_ip(:any)
end
