# Source File: ip_v6_test.exs
# Location:    musebms/app_server/components/system/mscmp_syst_network/test/ip_v6_test.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

# credo:disable-for-this-file Credo.Check.Readability.LargeNumbers

defmodule IpV6Test do
  use ExUnit.Case, async: true

  import Bitwise

  alias MscmpSystNetwork.Impl
  alias MscmpSystNetwork.Types.IpV6

  @moduletag :unit
  @moduletag :capture_log

  #
  # @spec to_string(IpV6.t()) :: String.t()
  #

  test "Can convert IP structs to string" do
    # In some ways this test is silly since we're creating the test data and
    # expected result using the same method as the function being tested (as
    # of this writing).  Of course the test is about making sure that future
    # changes don't break the expected result that is known good (as of this
    # writing).

    Enum.each(1..1_000_000, fn _ ->
      {_, addr_struct} = TestSupport.get_random_ipv6()

      expected_result =
        addr_struct.address
        |> :inet.ntoa()
        |> List.to_string()
        |> then(&(&1 <> "/" <> Integer.to_string(addr_struct.mask)))

      assert expected_result === Impl.IpV6.to_string(addr_struct)
    end)
  end

  #
  # @spec get_netmask(IpV6.t()) :: Types.ipv6_addr()
  #

  test "Can get network mask from struct" do
    Enum.each(1..1_000_000, fn _ ->
      {_, addr_struct} = TestSupport.get_random_ipv6(:any, 50)

      <<a::unsigned-integer-size(16), b::unsigned-integer-size(16), c::unsigned-integer-size(16),
        d::unsigned-integer-size(16), e::unsigned-integer-size(16), f::unsigned-integer-size(16),
        g::unsigned-integer-size(16),
        h::unsigned-integer-size(16)>> = <<-1 <<< (128 - addr_struct.mask)::128>>

      expected_result = {a, b, c, d, e, f, g, h}

      assert expected_result === Impl.IpV6.get_netmask(addr_struct)
    end)
  end

  #
  # @spec get_network(IpV6.t()) :: Types.ipv6_addr() | nil
  #

  test "Can get network or nil from struct" do
    Enum.each(1..1_000_000, fn _ ->
      {kind, addr_struct} = TestSupport.get_random_ipv6(:any, 30)

      expected_result =
        if kind !== :host do
          {a1, b1, c1, d1, e1, f1, g1, h1} = addr_struct.address

          <<int_addr::unsigned-integer-size(128)>> =
            <<a1::unsigned-integer-size(16), b1::unsigned-integer-size(16),
              c1::unsigned-integer-size(16), d1::unsigned-integer-size(16),
              e1::unsigned-integer-size(16), f1::unsigned-integer-size(16),
              g1::unsigned-integer-size(16), h1::unsigned-integer-size(16)>>

          <<int_mask::unsigned-integer-size(128)>> = <<-1 <<< (128 - addr_struct.mask)::128>>

          <<a2::unsigned-integer-size(16), b2::unsigned-integer-size(16),
            c2::unsigned-integer-size(16), d2::unsigned-integer-size(16),
            e2::unsigned-integer-size(16), f2::unsigned-integer-size(16),
            g2::unsigned-integer-size(16),
            h2::unsigned-integer-size(16)>> =
            <<band(int_addr, int_mask)::unsigned-integer-size(128)>>

          {a2, b2, c2, d2, e2, f2, g2, h2}
        end

      assert expected_result === Impl.IpV6.get_network(addr_struct)
    end)
  end

  #
  # @spec get_host(IpV6.t()) :: Types.ipv6_addr() | nil
  #

  test "Can get host or nil from struct" do
    Enum.each(1..1_000_000, fn _ ->
      {kind, addr_struct} = TestSupport.get_random_ipv6()

      expected_result = if kind === :host, do: addr_struct.address

      assert expected_result === Impl.IpV6.get_host(addr_struct)
    end)
  end

  #
  # @spec host?(IpV6.t()) :: boolean()
  #

  test "Can test if struct represents a host" do
    Enum.each(1..1_000_000, fn _ ->
      {kind, addr_struct} = TestSupport.get_random_ipv6()

      expected_result = kind === :host

      assert expected_result === Impl.IpV6.host?(addr_struct)
    end)
  end

  #
  # @spec network?(IpV6.t()) :: boolean()
  #

  test "Can test if struct represents a subnet" do
    Enum.each(1..1_000_000, fn _ ->
      {kind, addr_struct} = TestSupport.get_random_ipv6(:any, 30)

      expected_result = kind === :network

      assert expected_result === Impl.IpV6.network?(addr_struct)
    end)
  end

  #
  # @spec to_struct(Types.ipv6_addr(), Types.ipv6_mask() | nil) :: IpV6.t()
  #

  test "Can create struct from Erlang IP address and mask" do
    Enum.each(1..1_000_000, fn _ ->
      {_, expected_result} = TestSupport.get_random_ipv6(:any, 30)

      assert expected_result ===
               Impl.IpV6.to_struct(expected_result.address, expected_result.mask)
    end)
  end

  #
  # @spec in_network?(IpV6.t(), IpV6.t()) :: boolean()
  #

  test "Can test if IP address or network is contained by an identified network" do
    test_data =
      [
        {%IpV6{address: {64923, 30712, 29005, 51899, 43862, 34375, 43879, 57106}, mask: 128},
         %IpV6{address: {64923, 30712, 29005, 51899, 0, 0, 0, 0}, mask: 64}, true},
        {%IpV6{address: {64923, 30712, 29005, 51900, 43862, 34375, 43879, 57106}, mask: 128},
         %IpV6{address: {64923, 30712, 29005, 51899, 0, 0, 0, 0}, mask: 64}, false},
        {%IpV6{address: {64768, 0, 0, 0, 0, 0, 0, 57106}, mask: 8},
         %IpV6{address: {64768, 0, 0, 0, 0, 0, 0, 0}, mask: 8}, true},
        {%IpV6{address: {64768, 0, 0, 0, 0, 0, 0, 0}, mask: 4},
         %IpV6{address: {64768, 0, 0, 0, 0, 0, 0, 0}, mask: 8}, false},
        {%IpV6{address: {64923, 30712, 29005, 51899, 0, 0, 0, 0}, mask: 64},
         %IpV6{address: {64923, 30712, 29005, 51899, 0, 0, 0, 0}, mask: 64}, true},
        {%IpV6{address: {64923, 30712, 29005, 51898, 43862, 34375, 43879, 57106}, mask: 128},
         %IpV6{address: {64923, 30712, 29005, 51899, 0, 0, 0, 0}, mask: 64}, false},
        {%IpV6{address: {64923, 30712, 29005, 51899, 0, 0, 0, 0}, mask: 64},
         %IpV6{address: {64923, 30712, 29005, 49152, 0, 0, 0, 0}, mask: 52}, true},
        {%IpV6{address: {64924, 30712, 29005, 51899, 0, 0, 0, 0}, mask: 64},
         %IpV6{address: {64923, 30712, 29005, 49152, 0, 0, 0, 0}, mask: 52}, false}
      ]

    Enum.each(test_data, fn curr_tuple ->
      assert elem(curr_tuple, 2) ===
               Impl.IpV6.in_network?(elem(curr_tuple, 0), elem(curr_tuple, 1))
    end)
  end

  #
  # @spec in_range?(IpV6.t(), IpV6.t(), IpV6.t()) :: boolean()
  #

  test "Can test if IP address or network is contained by an identified range" do
    test_data =
      [
        # Simple host, flat range
        {%IpV6{address: {64923, 30712, 29005, 51899, 43862, 34375, 43879, 57106}, mask: 128},
         %IpV6{address: {64923, 30712, 29005, 51899, 43862, 34375, 43879, 57106}, mask: 128},
         %IpV6{address: {64923, 30712, 29005, 51899, 43862, 34375, 43879, 57106}, mask: 128},
         true},
        # Simple host, out of flat range
        {%IpV6{address: {64923, 30712, 29005, 51899, 43862, 34375, 43879, 57107}, mask: 128},
         %IpV6{address: {64923, 30712, 29005, 51899, 43862, 34375, 43879, 57106}, mask: 128},
         %IpV6{address: {64923, 30712, 29005, 51899, 43862, 34375, 43879, 57106}, mask: 128},
         false},
        # Simple host, in network
        {%IpV6{address: {64923, 30712, 29005, 51899, 43862, 34375, 43879, 57106}, mask: 128},
         %IpV6{address: {64923, 30712, 29005, 51899, 0, 0, 0, 0}, mask: 64},
         %IpV6{address: {64923, 30712, 29005, 51899, 0, 0, 0, 0}, mask: 64}, true},
        # Simple host, out of network
        {%IpV6{address: {64923, 30712, 29005, 51898, 43862, 34375, 43879, 57106}, mask: 128},
         %IpV6{address: {64923, 30712, 29005, 51899, 0, 0, 0, 0}, mask: 64},
         %IpV6{address: {64923, 30712, 29005, 51899, 0, 0, 0, 0}, mask: 64}, false},
        # Simple host, in host based range
        {%IpV6{address: {64923, 30712, 29005, 51898, 43862, 34375, 43879, 57106}, mask: 128},
         %IpV6{address: {64923, 30712, 29005, 51897, 43862, 34375, 43879, 57106}, mask: 128},
         %IpV6{address: {64923, 30712, 29005, 51899, 43862, 34375, 43879, 57106}, mask: 128},
         true},
        # Simple host, out of host based range
        {%IpV6{address: {64921, 30712, 29005, 51898, 43862, 34375, 43879, 57106}, mask: 128},
         %IpV6{address: {64923, 30712, 29005, 51897, 43862, 34375, 43879, 57106}, mask: 128},
         %IpV6{address: {64923, 30712, 29005, 51899, 43862, 34375, 43879, 57106}, mask: 128},
         false},
        # Simple host, in network based range
        {%IpV6{address: {64923, 30712, 29005, 51899, 43862, 34375, 43879, 57106}, mask: 128},
         %IpV6{address: {64923, 30712, 29004, 51899, 0, 0, 0, 0}, mask: 64},
         %IpV6{address: {64923, 30712, 29006, 51899, 0, 0, 0, 0}, mask: 64}, true},
        # Simple host, out of network based range
        {%IpV6{address: {64923, 30712, 29005, 51899, 43862, 34375, 43879, 57106}, mask: 128},
         %IpV6{address: {64921, 30712, 29005, 51899, 0, 0, 0, 0}, mask: 64},
         %IpV6{address: {64922, 30712, 29005, 51899, 0, 0, 0, 0}, mask: 64}, false},
        # Network, matches flat range
        {%IpV6{address: {64923, 30712, 29005, 51899, 0, 0, 0, 0}, mask: 64},
         %IpV6{address: {64923, 30712, 29005, 51899, 0, 0, 0, 0}, mask: 128},
         %IpV6{address: {64923, 30712, 29005, 51899, 65535, 65535, 65535, 65535}, mask: 128},
         true},
        # Network, matches network
        {%IpV6{address: {64923, 30712, 29005, 51899, 0, 0, 0, 0}, mask: 64},
         %IpV6{address: {64923, 30712, 29005, 51899, 0, 0, 0, 0}, mask: 64},
         %IpV6{address: {64923, 30712, 29005, 51899, 0, 0, 0, 0}, mask: 64}, true},
        # Network, exceeds network
        {%IpV6{address: {64923, 30712, 29005, 51888, 0, 0, 0, 0}, mask: 60},
         %IpV6{address: {64923, 30712, 29005, 51899, 0, 0, 0, 0}, mask: 64},
         %IpV6{address: {64923, 30712, 29005, 51899, 0, 0, 0, 0}, mask: 64}, false},
        # Network, contained by network
        {%IpV6{address: {64923, 30712, 29005, 51899, 40960, 0, 0, 0}, mask: 68},
         %IpV6{address: {64923, 30712, 29005, 51899, 0, 0, 0, 0}, mask: 64},
         %IpV6{address: {64923, 30712, 29005, 51899, 0, 0, 0, 0}, mask: 64}, true},
        # Network, contained by range
        {%IpV6{address: {64923, 30712, 29005, 51899, 0, 0, 0, 0}, mask: 64},
         %IpV6{address: {64923, 30712, 29005, 51890, 0, 0, 0, 0}, mask: 64},
         %IpV6{address: {64923, 30712, 29005, 51900, 0, 0, 0, 0}, mask: 64}, true}
      ]

    Enum.each(test_data, fn curr_tuple ->
      assert elem(curr_tuple, 3) ===
               Impl.IpV6.in_range?(elem(curr_tuple, 0), elem(curr_tuple, 1), elem(curr_tuple, 2))
    end)
  end
end
