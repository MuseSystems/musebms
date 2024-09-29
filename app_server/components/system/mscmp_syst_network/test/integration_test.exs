# Source File: integration_test.exs
# Location:    musebms/app_server/components/system/mscmp_syst_network/test/integration_test.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule IntegrationTest do
  @moduledoc false

  use ExUnit.Case, async: true

  @moduletag :integration
  @moduletag :capture_log

  describe "Parse API" do
    test "Can convert Erlang tuples to IPv4 network structs" do
      Enum.each(1..1_000, fn _ ->
        {_, test_addr} = TestSupport.get_random_ipv4(:network)
        assert test_addr === MscmpSystNetwork.to_struct(test_addr.address, test_addr.mask)
      end)
    end

    test "Can convert Erlang tuples to IPv4 host structs" do
      Enum.each(1..1_000, fn _ ->
        {_, test_addr} = TestSupport.get_random_ipv4(:host)
        assert test_addr === MscmpSystNetwork.to_struct(test_addr.address, nil)
      end)
    end

    test "Can convert Erlang tuples to IPv6 network structs" do
      Enum.each(1..1_000, fn _ ->
        {_, test_addr} = TestSupport.get_random_ipv6(:network)
        assert test_addr === MscmpSystNetwork.to_struct(test_addr.address, test_addr.mask)
      end)
    end

    test "Can convert Erlang tuples to IPv6 host structs" do
      Enum.each(1..1_000, fn _ ->
        {_, test_addr} = TestSupport.get_random_ipv6(:host)
        assert test_addr === MscmpSystNetwork.to_struct(test_addr.address, nil)
      end)
    end

    #
    # IpV4 parse! Testing
    #

    test "Can parse! IPv4 simple IP address" do
      Enum.each(1..500_000, fn _ ->
        {:host, test_addr} = TestSupport.get_random_ipv4(:host)
        test_str = :inet.ntoa(test_addr.address) |> List.to_string()

        assert test_addr === MscmpSystNetwork.parse!(test_str)
      end)
    end

    test "Can parse! IPv4 host address using CIDR notation" do
      Enum.each(1..500_000, fn _ ->
        {:host, test_addr} = TestSupport.get_random_ipv4(:host)
        test_str = MscmpSystNetwork.to_string(test_addr)

        assert test_addr === MscmpSystNetwork.parse!(test_str)
      end)
    end

    test "Can parse! IPv4 subnet address using CIDR notation" do
      Enum.each(1..500_000, fn _ ->
        {:network, test_addr} = TestSupport.get_random_ipv4(:network)
        test_str = MscmpSystNetwork.to_string(test_addr)

        assert test_addr === MscmpSystNetwork.parse!(test_str)
      end)
    end

    test "Cannot parse! invalid IPv4 strings" do
      assert catch_error(MscmpSystNetwork.parse!("10.1.1.1.1"))
      assert catch_error(MscmpSystNetwork.parse!("10.1.1.1.1/32"))
      assert catch_error(MscmpSystNetwork.parse!("10.1.1.1/32/32"))
      assert catch_error(MscmpSystNetwork.parse!("10.1.1.1/-32"))
    end

    #
    # IpV4 parse Testing
    #

    test "Can parse IPv4 simple IP address" do
      Enum.each(1..10, fn _ ->
        {:host, test_addr} = TestSupport.get_random_ipv4(:host)
        test_str = :inet.ntoa(test_addr.address) |> List.to_string()

        assert {:ok, test_addr} === MscmpSystNetwork.parse(test_str)
      end)
    end

    test "Can parse IPv4 host address using CIDR notation" do
      Enum.each(1..10, fn _ ->
        {:host, test_addr} = TestSupport.get_random_ipv4(:host)
        test_str = MscmpSystNetwork.to_string(test_addr)

        assert {:ok, test_addr} === MscmpSystNetwork.parse(test_str)
      end)
    end

    test "Can parse IPv4 subnet address using CIDR notation" do
      Enum.each(1..10, fn _ ->
        {:network, test_addr} = TestSupport.get_random_ipv4(:network)
        test_str = MscmpSystNetwork.to_string(test_addr)

        assert {:ok, test_addr} === MscmpSystNetwork.parse(test_str)
      end)
    end

    test "Cannot parse invalid IPv4 strings" do
      assert {:error, %MscmpSystError{code: :undefined_error}} =
               MscmpSystNetwork.parse("10.1.1.1.1")

      assert {:error, %MscmpSystError{code: :undefined_error}} =
               MscmpSystNetwork.parse("10.1.1.1.1/32")

      assert {:error, %MscmpSystError{code: :undefined_error}} =
               MscmpSystNetwork.parse("10.1.1.1/32/32")

      assert {:error, %MscmpSystError{code: :undefined_error}} =
               MscmpSystNetwork.parse("10.1.1.1/-32")
    end

    #
    # IpV6 parse! Testing
    #

    test "Can parse! IPv6 simple IP address" do
      Enum.each(1..500_000, fn _ ->
        {:host, test_addr} = TestSupport.get_random_ipv6(:host)
        test_str = :inet.ntoa(test_addr.address) |> List.to_string()

        assert test_addr === MscmpSystNetwork.parse!(test_str)
      end)
    end

    test "Can parse! IPv6 host address using CIDR notation" do
      Enum.each(1..500_000, fn _ ->
        {:host, test_addr} = TestSupport.get_random_ipv6(:host)
        test_str = MscmpSystNetwork.to_string(test_addr)

        assert test_addr === MscmpSystNetwork.parse!(test_str)
      end)
    end

    test "Can parse! IPv6 subnet address using CIDR notation" do
      Enum.each(1..500_000, fn _ ->
        {:network, test_addr} = TestSupport.get_random_ipv6(:network)
        test_str = MscmpSystNetwork.to_string(test_addr)

        assert test_addr === MscmpSystNetwork.parse!(test_str)
      end)
    end

    test "Cannot parse! invalid IPv6 strings" do
      assert catch_error(MscmpSystNetwork.parse!("2001::0010::abcd"))
      assert catch_error(MscmpSystNetwork.parse!("2001::0010::abcd/128"))
      assert catch_error(MscmpSystNetwork.parse!("2001::0010:abcd/128/128"))
      assert catch_error(MscmpSystNetwork.parse!("2001::0010:abcd/-128"))
    end

    #
    # IpV6 parse Testing
    #

    test "Can parse IPv6 simple IP address" do
      Enum.each(1..10, fn _ ->
        {:host, test_addr} = TestSupport.get_random_ipv6(:host)
        test_str = :inet.ntoa(test_addr.address) |> List.to_string()

        assert {:ok, test_addr} === MscmpSystNetwork.parse(test_str)
      end)
    end

    test "Can parse IPv6 host address using CIDR notation" do
      Enum.each(1..10, fn _ ->
        {:host, test_addr} = TestSupport.get_random_ipv6(:host)
        test_str = MscmpSystNetwork.to_string(test_addr)

        assert {:ok, test_addr} === MscmpSystNetwork.parse(test_str)
      end)
    end

    test "Can parse IPv6 subnet address using CIDR notation" do
      Enum.each(1..10, fn _ ->
        {:network, test_addr} = TestSupport.get_random_ipv6(:network)
        test_str = MscmpSystNetwork.to_string(test_addr)

        assert {:ok, test_addr} === MscmpSystNetwork.parse(test_str)
      end)
    end

    test "Cannot parse invalid IPv6 strings" do
      assert {:error, %MscmpSystError{code: :undefined_error}} =
               MscmpSystNetwork.parse("2001::0010::abcd")

      assert {:error, %MscmpSystError{code: :undefined_error}} =
               MscmpSystNetwork.parse("2001::0010::abcd/128")

      assert {:error, %MscmpSystError{code: :undefined_error}} =
               MscmpSystNetwork.parse("2001::0010:abcd/128/128")

      assert {:error, %MscmpSystError{code: :undefined_error}} =
               MscmpSystNetwork.parse("2001::0010:abcd/-128")
    end
  end

  describe "Protocol API" do
    test "to_string/1 correctly formats IPv4 addresses" do
      # Test simple host address
      assert MscmpSystNetwork.to_string(%MscmpSystNetwork.Types.IpV4{
               address: {192, 168, 1, 1},
               mask: 32
             }) == "192.168.1.1/32"

      # Test host address with non-default mask
      assert MscmpSystNetwork.to_string(%MscmpSystNetwork.Types.IpV4{
               address: {10, 0, 0, 1},
               mask: 8
             }) == "10.0.0.1/8"

      # Test network address
      assert MscmpSystNetwork.to_string(%MscmpSystNetwork.Types.IpV4{
               address: {172, 16, 0, 0},
               mask: 16
             }) == "172.16.0.0/16"

      # Test with random valid IPv4 addresses
      Enum.each(1..500_000, fn _ ->
        {type, addr} = TestSupport.get_random_ipv4(Enum.random([:host, :network]))
        str = MscmpSystNetwork.to_string(addr)
        assert {:ok, ^addr} = MscmpSystNetwork.parse(str)

        case type do
          :host ->
            [address_part, _] = String.split(str, "/")
            assert Regex.match?(~r/^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/, address_part)
            {a, b, c, d} = addr.address
            assert address_part == "#{a}.#{b}.#{c}.#{d}"

          :network ->
            [address_part, mask_part] = String.split(str, "/")
            assert Regex.match?(~r/^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/, address_part)
            {a, b, c, d} = addr.address
            assert address_part == "#{a}.#{b}.#{c}.#{d}"
            {mask, _} = Integer.parse(mask_part)
            assert mask >= 0 and mask < 32
        end
      end)
    end

    test "to_string/1 correctly formats IPv6 addresses" do
      # Test simple host address
      assert MscmpSystNetwork.to_string(%MscmpSystNetwork.Types.IpV6{
               address: {8193, 3512, 0, 0, 0, 0, 0, 1},
               mask: 128
             }) == "2001:db8::1/128"

      # Test host address with non-default mask
      assert MscmpSystNetwork.to_string(%MscmpSystNetwork.Types.IpV6{
               address: {8193, 3512, 0, 1, 0, 0, 0, 1},
               mask: 64
             }) == "2001:db8:0:1::1/64"

      # Test network address
      assert MscmpSystNetwork.to_string(%MscmpSystNetwork.Types.IpV6{
               address: {8193, 3512, 0, 0, 0, 0, 0, 0},
               mask: 32
             }) == "2001:db8::/32"

      # Test with random valid IPv6 addresses
      Enum.each(1..500_000, fn _ ->
        {type, addr} = TestSupport.get_random_ipv6(Enum.random([:host, :network]))
        str = MscmpSystNetwork.to_string(addr)
        assert {:ok, ^addr} = MscmpSystNetwork.parse(str)

        case type do
          :host ->
            [address_part, _] = String.split(str, "/")
            assert Regex.match?(~r/^[\da-f:]+(%\w+)?$/, address_part)

            assert match?({:ok, _}, :inet.parse_ipv6_address(String.to_charlist(address_part)))

          :network ->
            [address_part, mask_part] = String.split(str, "/")
            assert Regex.match?(~r/^[\da-f:]+(%\w+)?$/, address_part)

            assert match?({:ok, _}, :inet.parse_ipv6_address(String.to_charlist(address_part)))

            {mask, _} = Integer.parse(mask_part)
            assert mask >= 0 and mask <= 128
        end
      end)
    end

    test "get_netmask/1 correctly returns the netmask for IPv4 addresses" do
      assert MscmpSystNetwork.get_netmask(%MscmpSystNetwork.Types.IpV4{
               address: {192, 168, 1, 1},
               mask: 32
             }) == {255, 255, 255, 255}

      assert MscmpSystNetwork.get_netmask(%MscmpSystNetwork.Types.IpV4{
               address: {10, 0, 0, 1},
               mask: 8
             }) == {255, 0, 0, 0}

      assert MscmpSystNetwork.get_netmask(%MscmpSystNetwork.Types.IpV4{
               address: {172, 16, 0, 0},
               mask: 16
             }) == {255, 255, 0, 0}

      # Test with random valid IPv4 addresses
      Enum.each(1..500_000, fn _ ->
        {_, test_addr} = TestSupport.get_random_ipv4(:network)
        expected_netmask = TestSupport.ipv4_mask_to_tuple(test_addr.mask)
        assert MscmpSystNetwork.get_netmask(test_addr) == expected_netmask
      end)
    end

    test "get_netmask/1 correctly returns the netmask for IPv6 addresses" do
      assert MscmpSystNetwork.get_netmask(%MscmpSystNetwork.Types.IpV6{
               address: {8193, 3512, 0, 0, 0, 0, 0, 0},
               mask: 32
             }) == {65_535, 65_535, 0, 0, 0, 0, 0, 0}

      assert MscmpSystNetwork.get_netmask(%MscmpSystNetwork.Types.IpV6{
               address: {8193, 3512, 0, 0, 0, 0, 0, 1},
               mask: 128
             }) == {65_535, 65_535, 65_535, 65_535, 65_535, 65_535, 65_535, 65_535}

      # Test with random valid IPv6 addresses
      Enum.each(1..500_000, fn _ ->
        {_, test_addr} = TestSupport.get_random_ipv6(:any, 50)
        expected_netmask = TestSupport.ipv6_mask_to_tuple(test_addr.mask)
        assert MscmpSystNetwork.get_netmask(test_addr) == expected_netmask
      end)
    end

    test "get_network/1 correctly returns the network address for IPv4 addresses" do
      assert MscmpSystNetwork.get_network(%MscmpSystNetwork.Types.IpV4{
               address: {192, 168, 1, 1},
               mask: 32
             }) == nil

      assert MscmpSystNetwork.get_network(%MscmpSystNetwork.Types.IpV4{
               address: {192, 168, 1, 1},
               mask: 24
             }) == {192, 168, 1, 0}

      assert MscmpSystNetwork.get_network(%MscmpSystNetwork.Types.IpV4{
               address: {10, 0, 0, 1},
               mask: 8
             }) == {10, 0, 0, 0}

      assert MscmpSystNetwork.get_network(%MscmpSystNetwork.Types.IpV4{
               address: {172, 16, 0, 0},
               mask: 16
             }) == {172, 16, 0, 0}

      Enum.each(1..500_000, fn _ ->
        {_, test_addr} = TestSupport.get_random_ipv4(:network)
        expected_network = TestSupport.ipv4_network_to_tuple(test_addr.address, test_addr.mask)
        assert MscmpSystNetwork.get_network(test_addr) == expected_network
      end)
    end

    test "get_network/1 correctly returns the network address for IPv6 addresses" do
      assert MscmpSystNetwork.get_network(%MscmpSystNetwork.Types.IpV6{
               address: {8193, 3512, 0, 0, 0, 0, 0, 0},
               mask: 32
             }) == {8193, 3512, 0, 0, 0, 0, 0, 0}

      assert MscmpSystNetwork.get_network(%MscmpSystNetwork.Types.IpV6{
               address: {8193, 3512, 0, 0, 0, 0, 0, 1},
               mask: 128
             }) == nil

      # Test with random valid IPv6 addresses
      Enum.each(1..500_000, fn _ ->
        {_, test_addr} = TestSupport.get_random_ipv6(:any, 50)
        expected_network = TestSupport.ipv6_network_to_tuple(test_addr.address, test_addr.mask)
        assert MscmpSystNetwork.get_network(test_addr) == expected_network
      end)
    end

    test "get_host/1 correctly returns the host address for IPv4 addresses" do
      assert MscmpSystNetwork.get_host(%MscmpSystNetwork.Types.IpV4{
               address: {192, 168, 1, 1},
               mask: 32
             }) == {192, 168, 1, 1}

      assert MscmpSystNetwork.get_host(%MscmpSystNetwork.Types.IpV4{
               address: {192, 168, 1, 1},
               mask: 24
             }) == {192, 168, 1, 1}

      assert MscmpSystNetwork.get_host(%MscmpSystNetwork.Types.IpV4{
               address: {10, 0, 0, 1},
               mask: 8
             }) == {10, 0, 0, 1}

      assert MscmpSystNetwork.get_host(%MscmpSystNetwork.Types.IpV4{
               address: {172, 16, 0, 0},
               mask: 16
             }) == nil

      Enum.each(1..500_000, fn _ ->
        {kind, test_addr} = TestSupport.get_random_ipv4(:any)

        expected_result =
          case kind do
            :host -> test_addr.address
            :network -> nil
            :broadcast -> nil
          end

        assert MscmpSystNetwork.get_host(test_addr) == expected_result
      end)
    end

    test "get_host/1 correctly returns the host address for IPv6 addresses" do
      assert MscmpSystNetwork.get_host(%MscmpSystNetwork.Types.IpV6{
               address: {8193, 3512, 0, 0, 0, 0, 0, 0},
               mask: 32
             }) == nil

      assert MscmpSystNetwork.get_host(%MscmpSystNetwork.Types.IpV6{
               address: {8193, 3512, 0, 0, 0, 0, 0, 1},
               mask: 128
             }) == {8193, 3512, 0, 0, 0, 0, 0, 1}

      # Test with random valid IPv6 addresses
      Enum.each(1..500_000, fn _ ->
        {kind, test_addr} = TestSupport.get_random_ipv6(:any, 50)

        expected_result =
          case kind do
            :host -> test_addr.address
            :network -> nil
          end

        assert MscmpSystNetwork.get_host(test_addr) == expected_result
      end)
    end

    test "host?/1 correctly identifies IPv4 host addresses" do
      assert MscmpSystNetwork.host?(%MscmpSystNetwork.Types.IpV4{
               address: {192, 168, 1, 1},
               mask: 32
             })

      assert MscmpSystNetwork.host?(%MscmpSystNetwork.Types.IpV4{
               address: {192, 168, 1, 1},
               mask: 24
             })

      assert not MscmpSystNetwork.host?(%MscmpSystNetwork.Types.IpV4{
               address: {10, 0, 0, 0},
               mask: 8
             })

      assert not MscmpSystNetwork.host?(%MscmpSystNetwork.Types.IpV4{
               address: {172, 16, 0, 0},
               mask: 16
             })

      # Test with random valid IPv4 addresses
      Enum.each(1..500_000, fn _ ->
        {kind, test_addr} = TestSupport.get_random_ipv4(:any)
        assert MscmpSystNetwork.host?(test_addr) == (kind == :host)
      end)
    end

    test "host?/1 correctly identifies IPv6 host addresses" do
      assert MscmpSystNetwork.host?(%MscmpSystNetwork.Types.IpV6{
               address: {8193, 3512, 0, 0, 0, 0, 0, 1},
               mask: 128
             })

      assert not MscmpSystNetwork.host?(%MscmpSystNetwork.Types.IpV6{
               address: {8193, 3512, 0, 0, 0, 0, 0, 0},
               mask: 32
             })

      # Test with random valid IPv6 addresses
      Enum.each(1..500_000, fn _ ->
        {kind, test_addr} = TestSupport.get_random_ipv6(:any, 50)
        assert MscmpSystNetwork.host?(test_addr) == (kind == :host)
      end)
    end

    test "network?/1 correctly identifies IPv4 network addresses" do
      assert not MscmpSystNetwork.network?(%MscmpSystNetwork.Types.IpV4{
               address: {192, 168, 1, 1},
               mask: 32
             })

      assert not MscmpSystNetwork.network?(%MscmpSystNetwork.Types.IpV4{
               address: {192, 168, 1, 1},
               mask: 24
             })

      assert MscmpSystNetwork.network?(%MscmpSystNetwork.Types.IpV4{
               address: {10, 0, 0, 0},
               mask: 8
             })

      assert MscmpSystNetwork.network?(%MscmpSystNetwork.Types.IpV4{
               address: {172, 16, 0, 0},
               mask: 16
             })

      # Test with random valid IPv4 addresses
      Enum.each(1..500_000, fn _ ->
        {kind, test_addr} = TestSupport.get_random_ipv4(:any)
        assert MscmpSystNetwork.network?(test_addr) == (kind == :network)
      end)
    end

    test "network?/1 correctly identifies IPv6 network addresses" do
      assert MscmpSystNetwork.network?(%MscmpSystNetwork.Types.IpV6{
               address: {8193, 3512, 0, 0, 0, 0, 0, 0},
               mask: 32
             })

      assert not MscmpSystNetwork.network?(%MscmpSystNetwork.Types.IpV6{
               address: {8193, 3512, 0, 0, 0, 0, 0, 1},
               mask: 128
             })

      # Test with random valid IPv6 addresses
      Enum.each(1..500_000, fn _ ->
        {kind, test_addr} = TestSupport.get_random_ipv6(:any, 50)
        assert MscmpSystNetwork.network?(test_addr) == (kind == :network)
      end)
    end

    test "in_network?/2 correctly identifies if an IPv4 address is within a network" do
      assert MscmpSystNetwork.in_network?(
               %MscmpSystNetwork.Types.IpV4{
                 address: {192, 168, 1, 100},
                 mask: 32
               },
               %MscmpSystNetwork.Types.IpV4{
                 address: {192, 168, 1, 0},
                 mask: 24
               }
             )

      assert not MscmpSystNetwork.in_network?(
               %MscmpSystNetwork.Types.IpV4{
                 address: {192, 168, 2, 100},
                 mask: 32
               },
               %MscmpSystNetwork.Types.IpV4{
                 address: {192, 168, 1, 0},
                 mask: 24
               }
             )

      # Test with random valid IPv4 addresses
      Enum.each(1..500_000, fn _ ->
        {_, host} = TestSupport.get_random_ipv4(:host)
        {_, network} = TestSupport.get_random_ipv4(:network)

        expected = TestSupport.ipv4_in_network?(host, network)

        assert MscmpSystNetwork.in_network?(host, network) == expected
      end)
    end

    test "in_network?/2 correctly identifies if an IPv6 address is within a network" do
      assert MscmpSystNetwork.in_network?(
               %MscmpSystNetwork.Types.IpV6{
                 address: {8193, 3512, 0, 0, 0, 0, 0, 1},
                 mask: 128
               },
               %MscmpSystNetwork.Types.IpV6{
                 address: {8193, 3512, 0, 0, 0, 0, 0, 0},
                 mask: 32
               }
             )

      assert not MscmpSystNetwork.in_network?(
               %MscmpSystNetwork.Types.IpV6{
                 address: {8193, 3513, 0, 0, 0, 0, 0, 1},
                 mask: 128
               },
               %MscmpSystNetwork.Types.IpV6{
                 address: {8193, 3512, 0, 0, 0, 0, 0, 0},
                 mask: 32
               }
             )

      # Test with random valid IPv6 addresses
      Enum.each(1..500_000, fn _ ->
        {_, host} = TestSupport.get_random_ipv6(:host)
        {_, network} = TestSupport.get_random_ipv6(:network)

        expected = TestSupport.ipv6_in_network?(host, network)

        assert MscmpSystNetwork.in_network?(host, network) == expected
      end)
    end

    test "in_range?/3 correctly identifies if an IPv4 address is within a range" do
      assert MscmpSystNetwork.in_range?(
               %MscmpSystNetwork.Types.IpV4{
                 address: {192, 168, 1, 100},
                 mask: 32
               },
               %MscmpSystNetwork.Types.IpV4{
                 address: {192, 168, 1, 0},
                 mask: 24
               },
               %MscmpSystNetwork.Types.IpV4{
                 address: {192, 168, 2, 0},
                 mask: 24
               }
             )

      assert not MscmpSystNetwork.in_range?(
               %MscmpSystNetwork.Types.IpV4{
                 address: {192, 168, 0, 100},
                 mask: 32
               },
               %MscmpSystNetwork.Types.IpV4{
                 address: {192, 168, 1, 0},
                 mask: 24
               },
               %MscmpSystNetwork.Types.IpV4{
                 address: {192, 168, 2, 0},
                 mask: 24
               }
             )

      assert not MscmpSystNetwork.in_range?(
               %MscmpSystNetwork.Types.IpV4{
                 address: {192, 168, 3, 100},
                 mask: 32
               },
               %MscmpSystNetwork.Types.IpV4{
                 address: {192, 168, 1, 0},
                 mask: 24
               },
               %MscmpSystNetwork.Types.IpV4{
                 address: {192, 168, 2, 0},
                 mask: 24
               }
             )

      # Test with random valid IPv4 addresses
      Enum.each(1..500_000, fn _ ->
        {_, host} = TestSupport.get_random_ipv4(:host)
        {_, low} = TestSupport.get_random_ipv4(:any, {50, 50})
        {_, high} = TestSupport.get_random_ipv4(:any, {50, 50})

        expected = TestSupport.ipv4_in_range?(host, low, high)

        assert MscmpSystNetwork.in_range?(host, low, high) == expected
      end)
    end

    test "in_range?/3 correctly identifies if an IPv6 address is within a range" do
      assert MscmpSystNetwork.in_range?(
               %MscmpSystNetwork.Types.IpV6{
                 address: {8193, 3512, 0, 0, 0, 0, 0, 100},
                 mask: 128
               },
               %MscmpSystNetwork.Types.IpV6{
                 address: {8193, 3512, 0, 0, 0, 0, 0, 0},
                 mask: 64
               },
               %MscmpSystNetwork.Types.IpV6{
                 address: {8193, 3512, 0, 0, 0, 0, 1, 0},
                 mask: 64
               }
             )

      assert not MscmpSystNetwork.in_range?(
               %MscmpSystNetwork.Types.IpV6{
                 address: {8193, 3511, 0, 0, 0, 0, 0, 100},
                 mask: 128
               },
               %MscmpSystNetwork.Types.IpV6{
                 address: {8193, 3512, 0, 0, 0, 0, 0, 0},
                 mask: 64
               },
               %MscmpSystNetwork.Types.IpV6{
                 address: {8193, 3512, 0, 0, 0, 0, 1, 0},
                 mask: 64
               }
             )

      assert not MscmpSystNetwork.in_range?(
               %MscmpSystNetwork.Types.IpV6{
                 address: {8193, 3512, 0, 0, 0, 0, 2, 0},
                 mask: 128
               },
               %MscmpSystNetwork.Types.IpV6{
                 address: {8193, 3512, 0, 0, 0, 0, 0, 0},
                 mask: 64
               },
               %MscmpSystNetwork.Types.IpV6{
                 address: {8193, 3512, 0, 0, 0, 0, 1, 0},
                 mask: 64
               }
             )

      # Test with random valid IPv6 addresses
      Enum.each(1..500_000, fn _ ->
        {_, host} = TestSupport.get_random_ipv6(:host)
        {_, low} = TestSupport.get_random_ipv6(:any, 50)
        {_, high} = TestSupport.get_random_ipv6(:any, 50)

        expected = TestSupport.ipv6_in_range?(host, low, high)

        assert MscmpSystNetwork.in_range?(host, low, high) == expected
      end)
    end
  end
end
